# About LAPI::GIT

### Intent
LAPI::GIT is the **Git integration microservice** for LAP::CORE. It exposes Git operations (scan, status, branch, log, config) over a secure FastAPI service, making Git state and actions **machine-queryable** and **agent-controllable**.

It is both a **standalone LAPI** (for humans and teams) and a **plug-in integration** (for LAP::CORE).

---

### Function
- **API:** FastAPI routes under `/git/*` for status, branch, log, config, scan.  
- **Scanning:** `/git/scan` finds and reports on all repos under a root.  
- **Repo status:** structured JSON with branch, staged/unstaged/untracked counts, ahead/behind vs main.  
- **Safe operations:** status, config, remotes are live. Mutating ops (push/pull/commit/reset) are HITL-gated.  
- **Shared library:** uses `scanlib.py`, also leveraged by `scan_git_report.py` CLI.  
- **Agent support:** exposes Git health and compliance checks to LAP::CORE and Marvin.

---

### Usage Examples
```bash
# Human CLI scan
scan-git --mode lapi --root /work/projects --human

# Query API directly
curl http://localhost:8200/git/scan?root=/work/projects

# Ask LAP::CORE MCP for repo status
lapctl mcp call lapi_git.scan --root=/work/projects
```

---

### Why it Exists
**Humans:**  
- Provides a fast dashboard of repo health, avoiding manual `git status` checks.  
- Normalizes across many repos (dozens of lapi_* integrations).  
- Adds safety by blocking accidental destructive commands.

**Agents:**  
- Machine-readable git status for Marvin and Zerene.  
- Forms the foundation of LAP::CORE’s **self-awareness**.  
- Enables automated parity checks between local/lapi/core modes.  
- Provides versioned diagnostics for audit trails.

---

### Roadmap
1. **Add HITL gating** for push/pull/commit.  
2. **Deeper Git metrics** – submodule detection, last commit age, contributor stats.  
3. **Integrate with validate_lapi_repo** – ensure Git compliance is part of validation.  
4. **MCP-native wrapper** – tighter integration with LAP::CORE’s message bus.  
5. **Agent actions** – allow Marvin to suggest or auto-run safe git maintenance.  
