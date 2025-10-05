---
title: SyzygySys Reference & Docs — Master TOC
tags: [reference, canon, toc, organization]
audience: [internal, investor, board, customers, technical]
version: 0.1.0
---

# SyzygySys — Canon & Structure (TOC)

> This file is the **single source of truth** for structure. Pages are mostly stubs now.  
> Conventions: each page begins with YAML front‑matter including `tags` and `audience`.  
> Diagram placeholders use square-bracket tokens like `[LAP DIAGRAM]`.

---

## 0. Orientation
- `/index.md` — Landing: **Why, Who, What, How**
- `/about/mission.md` — Mission, values, credo, Syzygy Way
- `/about/personas.md` — **Personas**: internal, investor, board, customers, technical
- `/about/glossary.md` — terms: intent, trust, speed, spend, sovereignty, security
- `/about/ethos.md` — openness, governance, HITL-first

---

## 1. Core Vision & Narrative
- `/vision/value-proposition.md` — turn intent → outcomes (safe, governed, affordable)
- `/vision/metaphors.md` — “BGP for models”, “Kubernetes for agents”, “Trend radar”, “Linux moment”
- `/vision/whitepaper.md` — investor-facing white paper (summary + link)
- `/vision/roadshow.md` — pitch one-liners per audience
- `/vision/diagrams.md` — [PLATFORM OVERVIEW DIAGRAM], [VALUE FLOW DIAGRAM]

---

## 2. System Architecture
- `/architecture/overview.md` — planes: **Policy, Control (CROWN), Intelligence (IO), Data (LAP)**
- `/architecture/lap.md` — Local Agent Proxy overview  [LAP DIAGRAM]
- `/architecture/io.md` — Intent Optimizer (routing)  [IO DIAGRAM]
- `/architecture/crown.md` — CROWN control loop (PID, ladders, dampening)  [CROWN DIAGRAM]
- `/architecture/research-engine.md` — ingestion → vector → feeds  [RE DIAGRAM]
- `/architecture/core.md` — Syzygy Core (governance, observability, security)  [CORE DIAGRAM]
- `/architecture/routing.md` — RIB/FIB model, OSPF/BGP analogies, policy gates
- `/architecture/data-model.md` — schema reference (providers/models/agents/intents/telemetry/budgets/routes/rat)
- `/architecture/interfaces.md` — APIs: `/classify`, `/route`, `/feedback`, `/fib/next`, `/override`

---

## 3. Crown Jewels (Product Pillars)
- `/pillars/lap/index.md`  
  - `features.md`, `integrations.md` (GitHub/Jira/Confluence/Slack), `security.md`, `roadmap.md`
- `/pillars/io/index.md`  
  - `scoring.md` (math), `policies.md`, `budgets.md`, `telemetry.md`, `calibration.md`
- `/pillars/research-engine/index.md`  
  - `sources.md` (MarkTechPost, arXiv, Trail of Bits, etc.), `pipeline.md`, `taxonomy.md`, `api.md`
- `/pillars/core/index.md`  
  - `governance.md` (HITL, RAT), `observability.md` (OTEL/Grafana/Langfuse), `compliance.md`

---

## 4. Value-Add Subsystems
- `/subsystems/auditor.md` — HITL, RAT, replay, audit export
- `/subsystems/expediter.md` — intent queue, chunking, task assignment
- `/subsystems/router.md` — request router mechanics, multipath, dampening
- `/subsystems/sdf.md` — **SyzygySys Diagnostics Framework** (levels 1/2/3)
- `/subsystems/security.md` — sensitivity classes (P0–P2), secrets, privacy
- `/subsystems/resources.md` — GPU/VRAM policy, quantization, batching, cache reuse
- `/subsystems/observability.md` — dashboards, alerts, budgets, bill-of-tokens

---

## 5. Governance & Policy
- `/policy/llm-governance/index.md`  
  - `mvp-steps.md`, `task-list-mvp.md`, `local-llm-shell-project-spec.md`
- `/policy/compliance.md` — DPAs, data handling, retention
- `/policy/budgets.md` — soft/hard caps, escalation rules
- `/policy/risk.md` — model risks, red-teaming, incident playbooks

---

## 6. Development Lifecycle
- `/dev/roadmap.md` — phases: MVP → Demo → Launch (milestones + dates)
- `/dev/burndown.md` — current sprint checklist
- `/dev/release.md` — semver, changelog, release train
- `/dev/contrib.md` — contribution guide (open-core)
- `/dev/ops.md` — SLO/SLA, runbooks, “restart docs” one-liners

---

## 7. Research & Futures Shelf (parked)
- `/futures/index.md` — scope of “parked” ideas
- `/futures/meld.md` — parked
- `/futures/zith.md` — parked
- `/futures/zphone.md` — parked
- `/futures/rew00.md` — parked
- `/futures/mcp-plus.md` — parked
> This shelf is intentionally **out of MVP scope** but preserved for later mining.

---

## 8. Reference Tables & Matrices
- `/reference/models.md` — catalog (local/paid), costs, ctx, sovereignty, tool support
- `/reference/sources.md` — publications & feeds matrix (site, type, cadence, license)
- `/reference/tech.md` — core technologies table (LAP, IO, CROWN, RE, Core) → detail links
- `/reference/scoring-math.md` — normalized weighted score; constraints
- `/reference/bibliography.md` — citations and influences
- `/reference/taxonomy.md` — tags, facets, topics

---

## 9. Audience Portals (filtered views)
- `/portals/investor.md` — value, traction, moat, business model, timeline
- `/portals/board.md` — risk, compliance, budget, hiring, KPIs
- `/portals/customers.md` — benefits, demos, pricing, deployment modes
- `/portals/technical.md` — architecture deep dive, APIs, runbooks
- `/portals/internal.md` — decisions, ADRs, internal conventions

---

## 10. Public-Facing
- `/public/website.md` — landing structure, feeds, SEO checklist
- `/public/blog/whitepaper.md` — “Crowning the Future” draft
- `/public/changelog.md` — biweekly progress notes
- `/public/pr-bot.md` — **Relations Bot** behavior: audience filters, content allow/deny lists

---

## 11. Operations (Dev & Lab)
- `/ops/names.md` — internal DNS names (e.g., docs/prometheus/grafana *.lab.syzygysys.io)
- `/ops/proxy.md` — Caddy reverse-proxy config snippets
- `/ops/mkdocs.md` — dev reliable runbook (`../scripts/run_mkdocs.sh`)
- `/ops/secrets.md` — “Marvin in the half shell” rules (no secrets in repo)

---

## Appendices
- `/appendix/api.md` — OpenAPI fragments
- `/appendix/diagrams.md` — diagram index ([LAP DIAGRAM], [IO DIAGRAM], etc.)
- `/appendix/faq.md` — internal + external FAQs
- `/appendix/ack.md` — credits and OSS licenses
