# About lapi_template_cookiecutter

## Purpose
The `lapi_template_cookiecutter` repository is the official scaffolding system for creating new LAPI (Local Agent Plugin Interface) repositories within the SyzygySys ecosystem. It ensures every new LAPI repo starts from a consistent, validated baseline.

## How It Works
- Uses [Cookiecutter](https://cookiecutter.readthedocs.io/) to generate new repo structures.
- Pulls its "gold standard" template files from:  
  `reference/docs/templates/lapi_template`
- When you create a new LAPI repo, it instantiates a folder structure with:
  - `CHANGELOG.md`, `README.md`, `LICENSE`, `NOTICE`
  - `VERSION`, `lap_plugin.toml`, `pyproject.toml`
  - `src/server.py`, `scripts/hooks/clean_zone.sh`, `scripts/lapi_integration.sh`
  - `sdf/` diagnostics baseline (sdf.yml, sdf_test_template.py)
  - `tests/test_mock.py`
  - `docker-compose.yml` (with healthcheck)
  - CI/CD hooks and release scaffolding

This guarantees alignment with the reference template and allows automation tools (like `validate_lapi_repo`) to verify repos easily.

## Why It Exists
- **For humans**: Engineers can spin up new integrations rapidly, without having to remember the required boilerplate.
- **For agents**: Automated diagnostics and validation rely on known structure. Cookiecutter ensures every repo has predictable paths and files.

## Roadmap
- Tighten integration with `validate_lapi_repo` so it checks against the cookiecutter template itself.
- Add version pinning: template versions tied to `VERSION` so repos can declare which gold standard they follow.
- Provide an "upgrade" command to align older repos with the latest template.
- Automate inclusion of SDF diagnostics into every new repo by default.

## Example Usage
To create a new repo from the template:

```bash
cookiecutter gh:syzygysys/lapi_template_cookiecutter
```

Answer prompts for repo name, description, and other metadata, and a new compliant repo will be generated.

---

## Relationship to Gold Standard
The gold standard lives in:
```
reference/docs/templates/lapi_template
```
This directory is treated as canonical for structure and content.  
The cookiecutter repo consumes this reference and produces real-world repos that agents and validators can check.

---

## Conclusion
The `lapi_template_cookiecutter` is a key enabler for consistency, automation, and trust across all LAPI integrations.  
It bridges the gap between **developer ergonomics** and **agentic automation**, allowing SyzygySys to scale rapidly while remaining clean, verifiable, and maintainable.
