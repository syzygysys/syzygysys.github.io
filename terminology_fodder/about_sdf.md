# About SDF (SyzygySys Diagnostic Framework)

### Intent
SDF is the **diagnostic backbone** of SyzygySys. It standardizes how repos declare, organize, and run **self-tests**, so that both humans and agents can trust the health of the system at any level — from one repo to the full stack.

---

### Function
- **Directory standard:** every repo has an `sdf/` folder with tests, configs, and artifacts.  
- **Test entrypoint:** `python3 -m sdf run` discovers `sdf_test_*.py` and executes them with pytest.  
- **Configuration:** `sdf.yml` defines diagnostic stages (unit tests, integration, perf).  
- **Artifacts:** logs and reports are captured for analysis, triage, and RAG indexing.  
- **Levels:**  
  - **Level 1** – Full stack, recursive, includes offline/quiescent tests.  
  - **Level 2** – Full stack, no quiescence.  
  - **Level 3** – Local, repo-scoped diagnostics.

---

### Usage Examples
```bash
# Run repo-level diagnostics
python3 -m sdf run --verbose

# Run system-wide diagnostics from top of ~/projects
sdf run --level 1

# Agents can recurse into all repos with ./sdf directories
marvin sdf scan --json
```

---

### Why it Exists
**Humans:**  
- One consistent way to run tests across all repos.  
- Provides confidence that repos remain template-compliant and functional.  
- Produces human-readable summaries with pass/fail icons.

**Agents:**  
- Machine-readable JSON output for Marvin’s diagnostic pipelines.  
- RAG-friendly logs: structured, timestamped, stored in `sdf/logs`.  
- Agents can **self-diagnose** repos before deploying, patching, or upgrading.

---

### Roadmap
1. **Centralized RAG integration** – feed all diagnostics into Marvin’s vector DB.  
2. **Extended level semantics** – quiescence, perf tests, resource checks.  
3. **Agent-triggered SDF** – LAPI services self-run their sdf when queried.  
4. **Validate hooks** – ensure every repo’s sdf includes tests, config, artifacts.  
5. **Standardize docs** – `reference/docs/tech/sdf` becomes canonical reference.  
