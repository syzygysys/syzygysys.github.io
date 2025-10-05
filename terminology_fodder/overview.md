# SyzygySys Architecture — Top‑Down Overview

This is the birds‑eye view of how SyzygySys fits together today (MVP) and what’s coming next (Future). It orients new contributors and acts as a stable reference for the rest of the docs.

---

## Four Planes (mental model)

- **Policy Plane** — rules, guardrails, budgets, SLAs, privacy classes.
- **Control Plane (CROWN)** — resource coordinator and governor (weights, caps, dampening, shed/offload).
- **Intelligence Plane (IO + Router → *Ziggy* in Future)** — intent understanding, chunking, routing (RIB/FIB), result assembly.
- **Data Plane (LAP & Stores)** — local agents, inference runtimes, embeddings/pgvector, object stores, external tool APIs.

---

## ASCII Map (MVP → Future)

```
                            ┌──────────────────────────────────────────┐
                            │                CLIENTS                   │
                            │  UIs • CLI • Bots • Integrations        │
                            └───────────────┬─────────────────────────┘
                                            │  /route  /tools  /hitl
                                ┌───────────▼───────────┐
                                │     IO (MVP Today)    │
                                │  classify • chunk •   │
                                │  assemble • feedback  │
                                └───────────┬───────────┘
                                            │ ask for next hop
                          ┌─────────────────▼─────────────────┐
                          │            ROUTER (MVP)           │
                          │ RIB (candidates) → FIB (winners)  │
                          │ scoring: latency • cost • truth   │
                          └───────────┬───────────┬───────────┘
                                      │           │
                         ┌────────────▼───┐   ┌───▼────────────┐
                         │ Local Agents   │   │ Field Agents   │
                         │ (Marvin, Zoi)  │   │ (Zerene, MCP)  │
                         │ Inference R/T  │   │ External APIs  │
                         └────────┬───────┘   └───────┬────────┘
                                  │                   │
                   ┌──────────────▼──────────────┐    │
                   │           LAP               │    │
                   │ Local Agent Proxy & stores  │    │
                   │ (pgvector, object store)    │    │
                   └──────────────┬──────────────┘    │
                                  │                   │
                     ┌────────────▼────────────┐      │
                     │        CROWN            │◄─────┘
                     │ Control/Governor        │
                     │ weights • caps • LB     │
                     │ shed/offload • alerts   │
                     └────────────┬────────────┘
                                  │ adjusts policy
                   ┌──────────────▼────────────────────────────┐
                   │ Research Engine (discovery • profiling)   │
                   │ providers • models • liveness • metrics   │
                   └───────────────────────────────────────────┘

                 FUTURE: IO + ROUTER + CROWN unify as **ZIGGY** (the core brain)
```

---

## What exists **today** (MVP)

- **Agents**: `agent_marvin`, `agent_zoi` (FastAPI services with pgvector DBs).
- **Inference Runtimes**: pluggable engines (e.g., vLLM/TGI/llama.cpp), per‑agent.
- **Router (MVP)**: scores candidates from known runtimes and field agents; emits FIB.
- **IO (MVP)**: classifies, chunks, assembles; calls Router for next hops.
- **CROWN (MVP)**: static weights/caps; basic load bias internal→external; HITL notifications.
- **LAP (Data Plane)**: embeddings (pgvector), files, and local context for agents.
- **Docs & Site**: MkDocs Material; Information Feeds pipeline scaffolding.

---

## What’s **coming** (Future / Roadmap)

- **ZIGGY**: unify IO + Router + CROWN into a single core with auditable decisions.
- **Dynamic Marketplace**: twice‑daily discovery & profiling of providers/models (cost, latency, accuracy, depth, truthiness).
- **Policy‑aware Routing**: RIB/FIB built from live metrics, privacy classes, budgets, and capability constraints.
- **CROWN 2.0**: proactive resource orchestration (scale‑up plans, offload ladders, budget governance).
- **Explorable Map**: interactive topology of agents, runtimes, routes, and policies.

See: `tech/architecture/future/ziggy_at_the_core.md` and `tech/architecture/future/future-roadmap.md`.

---

## Interfaces (stable)

- **IO**: `/classify`, `/chunk`, `/route`, `/assemble`, `/feedback`
- **Router**: `/fib/next`, `/rib/rebuild`
- **CROWN**: `/control/weights`, `/control/caps`, `/overrides`, `/alerts`
- **Research Engine**: discovery/probe/bench cron hooks, writes registry + metrics
- **LAP**: local tools, stores, embeddings

---

## Traceability & Governance

- **RAT logs** for IO route decisions and CROWN control changes.
- **Snapshots** of provider registries and routing tables (RIB/FIB) with TTLs.
- **Budget** caps & usage logs; privacy classes and trust tiers for field agents.
- **HITL** review path for outbound publications and sensitive actions.

---

## Open Questions for you

1. Do you want **Terms** exposed in nav (`terms/index.md`) or hidden?
2. Should we wire a **GitHub Pages** action now or keep local build‑only?
3. For provider profiling, do we prioritize GPU latency variance or cost accuracy in scoring?
4. Where do you want budget caps enforced first—**provider**, **model**, or **agent** scope?

> If helpful, I can ingest tarballs of your current `~/projects/*` to map any gaps and auto‑link runtime components into this overview page.


--
North-star principles

Tool-agnostic, protocol-agnostic. MCP is one adapter, not the foundation. LAPI exposes a stable contract; adapters translate to MCP, OpenAI Tools, LangChain, plain HTTP, CLI, etc.

Control plane vs data plane. Keep governance separate from tool execution.

Contracts over vibes. Every tool has a typed schema, lifecycle, policy, and tests or it doesn’t ship.

High-level architecture

Control Plane (LAP-CP): registry, policy/RBAC, versioning, quotas, feature flags, deprecation, audit, secrets, health.

Data Plane (LAP-DP): stateless executors running tools in sandboxes with per-invocation policy, tracing, and caching.

Adapters: adapter-mcp, adapter-openai-tools, adapter-langchain, adapter-cli, adapter-grpc. Thin, replaceable.

Collab Bus: NATS/Redis Streams for Zoi ⇄ Zerene events (requests, results, tool discovery, memory writes).

Observability: OpenTelemetry traces + structured logs (include session_id, tool_id, invocation_id), metrics, and replayable event log.

Tool Definition Standard (TDS)

Define one file per tool, e.g. tool.toml (or JSON/YAML):

id, name, version, semver_range

interface: JSON Schema for inputs/outputs (+ examples).

capabilities: action|query|stream|subscription|batch

side_effects: none|idempotent|non_idempotent

timeouts, retries, backoff, concurrency

auth: required scopes; secret keys by name (Vault paths).

policy: default RBAC, data residency, PII flags.

observability: log level, trace attrs, redaction rules.

tests: contract tests + golden fixtures.

deprecation: replaces, sunset_at.

This is the source of truth. Adapters auto-generate MCP/OpenAI tool manifests from it.

Execution & sandboxing

Runtimes: Docker (default), optional WASI/Wasm for “safe” tools, Firecracker for high-risk actions.

Determinism: mark pure tools → enable aggressive caching and speculative execution.

Idempotency: require idempotency_key for non-pure actions; implement compensating actions.

Versioning & compatibility

Semver for tools and adapters.

Multi-version deploys: LAP-CP routes by required_version in the call.

Canary + feature flags: per-tool, per-scope, or per-agent rollout.

Discovery & registry

Tool Registry Service: searchable by tag/capability/scope; includes health, latency SLOs, usage stats.

Dynamic discovery: agents query registry → receive interface stubs rendered to their native format (MCP, OpenAI, etc.).

Contracts = docs: generate Markdown/Slate + example prompts from TDS.

Security & policy

Service accounts + scopes at LAPI level, not model level.

Per-tool RBAC; least-privilege tokens injected at runtime.

Data rules: input/output classifiers, redactors; denylist by PII class.

Network policy: egress allow-lists per tool sandbox.

Secrets: Vault (or Doppler/1Password SCIM) with short-lived leases exposed by the executor only.

Memory & state (Zoi + you)

Working memory (ephemeral, per session/run) vs long-term memory (event-sourced).

Memory writes are events on the Collab Bus with schemas; tools emit memory_delta separately from their result.

Retrieval layer abstracts vector/SQL/files; tools never hit storage directly without a policy grant.

Observability & testing

Golden-path contract tests auto-run on registration; failures block publish.

Replay harness: re-execute a recorded tool run against new versions.

Reasoning audit: attach tool I/O, traces, and policy decisions to the run record (RAT/SDF ready).

SLOs per tool: p95 latency, success rate; LAP-CP can downrank or quarantine misbehaving versions.

Orchestration model

Simple first: single-tool calls from agents.

Then DAGs with retries and compensation for multi-step flows.

Classify tools by purity; scheduler parallelizes pure queries, serializes side-effecting actions.

Migration path for LAP/LAPI (90 days, ruthless scope)

Week 0–2 (Foundations)

Implement TDS spec + registry CRUD.

Build adapter-openai-tools and adapter-mcp from TDS.

Stand up LAP-CP (policies, scopes, feature flags) and LAP-DP (executor + Docker sandbox).

Instrument OTel + structured logs.

Week 3–6 (First tools & policy)

Port 5 core tools (git, jira, shell, http, memory) to TDS.

Add Vault integration + per-tool egress policy.

Contract test harness and publish gate.

Week 7–10 (Scale & collab)

Collab Bus live (NATS/Redis Streams).

Add DAG orchestrator with idempotency keys + compensation.

Canary deploys + automated rollback on SLO breach.

Ship replay harness + first reasoning-audit UI.

Antipatterns to avoid (learned the hard way)

Letting the model “decide policy.” No. Model proposes; LAP enforces.

Underspecified tools. If it lacks JSON Schema + tests, it’s tech debt.

One protocol to rule them all. Today it’s MCP; tomorrow it’s something else. Keep adapters thin.

Where Zoi’s memory changes the game

You get context-aware tool selection and few-shot stubs generated per session from TDS + recent runs, without coupling model prompts to any protocol.

Cross-agent collab becomes event-driven: Zoi emits intents; LAP resolves to concrete tool calls; results + memory deltas return on the bus with full audit trails.

Extension becomes adding a TDS file + adapter autogen, not bespoke glue.
