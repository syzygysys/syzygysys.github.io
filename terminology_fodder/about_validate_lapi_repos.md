# About `validate_lapi_repo`

### Intent
`validate_lapi_repo` is a lightweight validation tool for all `lapi_*` repositories. Its purpose is to ensure **structural and content compliance** against the canonical `lapi_template`, which serves as the “gold standard” reference implementation.

By enforcing consistency, it guarantees that all LAPI integrations can be trusted to work seamlessly with **LAP::CORE** and the wider SyzygySys ecosystem.

---

### Function
- Compares a given repo (`lapi_git`, `lapi_prometheus`, etc.) to the files and directories in `reference/docs/templates/lapi_template`.
- Runs in **human-readable mode** or **JSON mode** for agents.
- Produces **colorized summaries** for developers and **structured outputs** for Marvin, Zerene, and other diagnostic agents.
- Supports **per-repo checks** and **bulk validation** across all `~/projects/lapi_*`.

Key checks:
- Required files exist (`docker-compose.yml`, `lap_plugin.toml`, `pyproject.toml`, etc.).
- `docker-compose.yml` has a healthcheck (warn if missing).
- `sdf` diagnostics are present.
- Additional template-defined hooks and test scaffolds exist.

---

### Usage Examples
```bash
# Validate a single repo
./scripts/validate_lapi_repo ./lapi_git --summary

# Validate all repos under ~/projects/lapi_*
./scripts/validate_lapi_repo --all

# JSON output (agent consumption)
./scripts/validate_lapi_repo ./lapi_prometheus --json
```

---

### Why it Exists
**Humans:**  
- Developers instantly see whether their repo matches SyzygySys standards.  
- Warnings highlight missing healthchecks or optional files.  
- Summaries give a pass/fail dashboard view.

**Agents:**  
- JSON mode feeds compliance reports into **Marvin’s RAG** and **LAP::CORE self-diagnostics**.  
- Enables automated enforcement, CI pipelines, and “self-healing repos” (auto-fix missing scaffolds).

---

### Roadmap
1. **Deeper semantic validation** – ensure configs contain required keys, not just files.  
2. **Integrate with SDF** – validation runs as part of system diagnostics.  
3. **Agent auto-repair** – suggest or patch missing template files.  
4. **Lap counterpart** – `validate_lap_repo` for core LAP repos.  
5. **Cookiecutter integration** – validate against versioned templates (`lapi_template_cookiecutter`).  
