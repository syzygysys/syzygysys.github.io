# About LAP::CORE

## Overview
LAP::CORE is the beating heart of SyzygySys. It provides the common runtime,
shared infrastructure, and diagnostic framework that all LAPIs plug into.
While each `lapi_*` repo offers specialized functionality, LAP::CORE supplies
the orchestration, coordination, and system-wide self-awareness.

It is both the **platform kernel** and the **conductor** of ACE
---

## Mission
To create a self-diagnosing, self-maintaining, and self-extending core that
humans and agents can rely on for critical infrastructure and next-generation
AI-driven operations.

---

## Core Responsibilities
- Provide common runtime services (logging, configuration, health).
- Expose the MCP (Model Context Protocol) interface for LAPI and LAP plugins.
- Manage system-wide diagnostics via **SDF** (SyzygySys Diagnostic Framework).
- Serve as the **baseline validator** for other repos.

---

## LAP::CORE Subrepos

### Network
The **network** subrepo provides integration with essential networking and
infrastructure layers.  

- **Docker**: Container runtime and workload management.  
- **Firewall (WAF and net)**: Core firewalling and traffic filtering for
  ingress/egress.  
- **Pi-hole**: DNS-level ad/tracker blocking.  
- **WireGuard**: Secure mesh VPN integration for distributed clusters.  

Network ensures every LAPI can reach and be reached securely and sanely.

---

### Platform
The **platform** subrepo covers observability, GPU compute, ingress, and cluster
management layers.

- **Prometheus**: Metrics collection.  
- **Grafana**: Visualization of system health and AI metrics.  
- **NVIDIA GPU**: Harnessing CUDA/RTX hardware for local inference.  
- **Caddy**: Smart TLS reverse proxy.  
- **Portainer**: Web UI for managing containers and clusters.  

**Roadmap**: AI-managed Kubernetes, where LAP::CORE agents orchestrate pods,
nodes, and services autonomously.

---

### Reference
The **reference** subrepo documents SyzygySys itself.

- **MkDocs**: Generates live documentation portals.  
- **Live Docs**: Continuously updated docs as code.  
- **Ask Marvin / Marvin+PGV**: Integrates the Marvin agent with vectorized docs
  for human+AI collaborative knowledge retrieval.  

This repo ensures humans and agents can always read, search, and understand
what the system knows about itself.

---

### Scripts
The **scripts** subrepo collects operational and developer scripts.

- Utility scripts for setup, release, and environment management.  
- Candidates for evolution into first-class `lapi_*` repos as patterns emerge.  

This provides agility: scripts start lightweight, then graduate into full LAPIs
when stabilized.

---

## Roadmap
- Harden diagnostics in LAP::CORE with full **level-based SDF runs**.  
- Expand **MCP** coverage across all subrepos.  
- Deliver **AI-managed Kubernetes** (with Marvin + Zerene orchestration).  
- Grow `scripts` into incubator → `lapi_*`.  
- Use **reference** as the canonical memory source for Marvin’s RAG vector DB.  

---

## Why LAP::CORE?
Because without a strong, reflective core, the ecosystem is just a collection of
tools. LAP::CORE makes them a living system.
