Alright Kevin—here’s a tight, execution-ready roadmap to build the **Certainty Engine** and wire it into **LAP::CORE**. No fluff.

# Pre-MVP (Weeks 0–4): Make it real, make it safe

**Goal:** ship a working certainty header + policy gates that *reduce risk today* without slowing ops.

## W0–1: Core scoring + schema

* Implement **penalized harmonic mean** aggregator; load `weights.json` (default + domain profiles).
* Emit **certainty header** (score, tier, gates, notes) per spec.
* Map score→tier (Unknown…Verified).
* **Kill-switch:** if scoring fails, tier=Unknown, **deny** high/destructive.

**Deliverables**

* `core/certainty/aggregator.py`
* `schemas/certainty_header.schema.json`
* Unit tests: deterministic vectors → expected tiers.

## W1–2: OPA policy + gates

* Integrate **OPA** with `policy.certainty.rego` (allow/abstain/HITL/break-glass).
* Enforce **deny by default** on destructive with tier\<HighConfidence.
* Add **intent-diff allow-list** pre-exec.

**Deliverables**

* `core/policy/opa_client.py`
* E2E tests: simulated ops → policy outcomes.

## W2: Observability (PROMTAIL LOKI GRIND)

* Log dims + score + tier + gate decision to **Loki**.
* Import **dashboard stub** (ECE/Brier placeholders, tier distribution, abstentions).
* Emit RED metrics: `certainty_score`, `action_allowed`, `abstain`.

**Deliverables**

* `observability/certainty_logging.py`
* `dashboards/certainty_calibration.loki.json`

## W2–3: Self-consistency + retrieval hooks

* Implement **K-path self-consistency** (configurable K).
* Add retrieval “grounding” flag and **source reliability** scorer.
* Time/entropy decay per domain.

**Deliverables**

* `core/certainty/self_consistency.py`
* `core/certainty/source_scoring.py`

## W3: JIT-QVS gate for high/destructive ops

* Require **green JIT-QVS** before applying high/destructive changes.
* Upload artifacts (attestation bundle) to logs.

**Deliverables**

* `scripts/jitqvs.sh` (already built), `core/hooks/jitqvs_runner.py`

## W3–4: HITL minimal UI + workflow

* Require **HITL approve** for: risk\_class∈{high, destructive} & tier\<Verified.
* Store reviewer identity, time-box, and diff they approved.

**Deliverables**

* `ui/hitl/review_panel` (CLI/JSON first)
* Audit records in Loki.

## MVP gate (end of W4)

* **Calibration:** ECE ≤ **0.07** on internal gold sets; Brier improves vs baseline.
* **Safety SLO:** destructive ops **denied** without JIT-QVS green + HITL.
* **Perf SLO:** p95 overhead ≤ **60 ms**/request (K≤5, retrieval on).
* **Rollback:** one flag disables engine but keeps deny-by-default for destructive.

---

# Post-MVP (Weeks 5–12): Make it sharp, make it scalable

**Goal:** improve calibration, cut toil, broaden coverage, harden edge cases.

## W5–6: Ensemble & token-level signals

* Add **cross-model consensus** (Zoe/Marvin/Zerene) scoring.
* Compute **token uncertainty** (entropy/top-k margin on key claims).
* Merge into aggregator with updated weights.

**Metrics**

* ECE ≤ **0.06**, denial precision↑, false-abstain↓.

## W6–7: Verification pipeline

* Replace `further_research` with **verification\_status** + **verification\_cost**.
* Auto-trigger cheap verifications (lint/syntax/API ping) before allowing “High”.

**Deliverables**

* `verify/runner.py`, pluggable checks (ssh -t, netplan, API HEAD, etc.)

## W7–8: Domain packs

* Profiles: **compliance**, **medical**, **finance** (weights + policy deltas).
* Add domain-specific gold sets and eval jobs in CI.

**Metrics**

* Domain ECE ≤ **0.05**; abstain where gold ground truth missing.

## W8–9: UX polish + docs

* Badges (tier), tooltips (why), quick links to evidence & logs.
* **Runbook generator**: auto-assemble change plan + attestation bundle.

## W9–10: Red-team overconfidence + HOT PATCH hooks

* Adversarial prompts suite; fail closed if over-assertive language vs tier.
* Optional **live patch** hook (HOT PATCH) with signature checks for rapid fixes.

## W10–11: MCP/CLI integration (CODELLM track)

* MCP servers expose `/certainty/score` and `/policy/gate`.
* CLI: `lap certainty score <json>`; `lap policy gate …`.

## W11–12: Calibration automation

* Nightly evals; drift alerts; auto-tune small weights on hold-out sets.
* Guardrails on auto-tune (no >10% shift without approval).

**Post-MVP gate**

* Global ECE ≤ **0.05**, p95 overhead ≤ **45 ms**, abstain behavior matches policy in 99.5% of cases, incident rate trending ↓.

---

## Operating rules (always on)

* **Fail closed** on engine/OPA errors for high/destructive.
* **Break-glass** requires 2× HITL + time-boxed token; force tier=Logged-Override.
* **RAT/HITL** first-class: every high-impact action must have a reviewer & diff.

## Risks & mitigations

* **Reviewer fatigue:** rotate reviewers; small batch windows; auto-draft diffs.
* **Retrieval outages:** degrade to **Plausible** cap; deny risky actions.
* **Drift in weights:** monthly review; calibration dashboard alerts.

---

## Success KPIs

* **Risk:** catastrophic unrecoverable per executed high-risk op ≤ **2e-6** (with JIT-QVS + 2×HITL).
* **Efficiency:** human time per high-risk change ↓ **≥40–60%** vs expert-only baseline.
* **Honesty:** abstention rate aligns with evidence gaps; overconfidence lint rate < **1%**.

If you want, I’ll generate:

* a tiny **LAP adaptor** (`certainty_service.py`) that computes score→tier, calls OPA, and invokes `jitqvs.sh`,
* a **GitHub Actions** CI job to run calibration on gold sets and publish the Loki dashboard JSON.
