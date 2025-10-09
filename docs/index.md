---
title: SyzygySys Internal Reference Docs
audience: [internal]
tags: [reference, home, toc]
version: v0.1.x
---

# SyzygySys Internal Reference

> **Internal only.** Working canon for architecture, policies, org, and runbooks.  
> Use **Ask Marvin** (bar at the top of the page) instead of legacy search.

---

## Quick Starts

- **About → [Structure (TOC)](about/structure.md)** — canonical map of sections and pages  
- **Tech → Architecture** — platform planes, pillars, runbooks, diagrams  
- **Internals → Section 11** — org, legal, IP, and policy source of truth  
- **Sources** — external research indices & terminology  
- **Assets → Brand** — logos, favicon, guidelines

---

## Core Pillars (what we’re building)
- **LAP** — Local Agent Proxy (integrations & execution)  
- **IO ** — intent optimization, 
- **CROWN ** - policy-aware routing, budget shaping, resource utilization, load_balancing
- **Research Engine** — feeds → vector store → signals → decisions  
- **Core** — governance, HITL gating, observability, compliance

*[LAP DIAGRAM]* · *[IO DIAGRAM]* · *[CROWN DIAGRAM]* · *[RE DIAGRAM]*

---

## Daily Use (jump right in)

- **Runbooks**
  - Comms Bridge Ops: `Tech → Architecture → Comms Bridge → Operations`
  - SRE / SDF: `Tech → Architecture → SRE → SDF`
  - Networking: `Internals → Networking Runbook`

- **Policies**
  - LLM Governance (MVP → Post-MVP): `Internals → Section 11 → Policies → LLM Governance`
  - Security & Licensing: `Internals → Section 11 → Policies`

- **Organization**
  - Mission & Section 11 Overview: `Internals → Section 11`

---

## How to Use “Ask Marvin”

Type an intent or question in the **Ask Marvin** field above.  
Marvin will (WIP) route to IO/LAP for retrieval or action and reply inline.

Tips:
- Ask for **pages** (“show LLM Governance MVP steps”)
- Ask for **procedures** (“bootstrap comms bridge on staging”)
- Ask for **definitions** (“what is sovereignty score?”)

---

## Contributing (docs repo)

1. Create/modify pages under `docs/…`  
2. Keep names **lowercase-with-hyphens** (no spaces) for new content  
3. Add YAML front-matter (`audience`, `tags`) to each page  
4. Update `mkdocs.yml` only at the top-level section if needed  
5. Serve locally (`etc/mkdocs-ssl/up.sh`) or `mkdocs serve -a 0.0.0.0:8080`

> All changes are versioned in Git. MkDocs auto-reloads during local dev.

---

## What’s New

- Simplified **top tabs**: Home / About / Tech / Internals / Sources / Assets  
- Collapsible **left nav** with section grouping  
- **Ask Marvin** input replaces legacy search  
- Section 11 consolidated under **Internals** (org/legal/IP/policies)

---

## Pointers

- TOC: [about/structure](about/structure.md)  
- Org: [internals/section11_SyzygySys_Organization/](internals/section11_SyzygySys_Organization/)  
- Brand: [assets/brand/guidelines](assets/brand/guidelines.md)

---

*SyzygySys — HITL · Governance · Intent Routing*
