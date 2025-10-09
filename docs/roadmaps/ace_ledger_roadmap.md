# ACE::LEDGER Roadmap (Back-Burner Snapshot)

This refresh captures where the ledger sits as we pause active development. Use it to rehydrate context quickly when the team returns to MVP or post-MVP workstreams.

## MVP Closeout Focus
- **NATS ACLs & Secret Management** — ~70%: Dev accounts exist; production-ready subject ACLs and Vault-backed credentials still need implementation and rollout runbook (README.md:37, docs/archive/phase1_followups.md:21).
- **Database Role Provisioning & Pooling (ACE-39)** — ~55%: Roles and compose wiring exist; finalize grant scripts, add startup privilege assertions, and slot pgBouncer or equivalent as required (jira_json/ace_ledger_writer.json, docs/archive/ACE-19_template_patch.md:1).
- **Integration Harness Expansion** — ~60%: SDF smoke covers health + single roundtrip; broaden coverage for DLQ cases, policy errors, and negative privilege tests (sdf/sdf.yml, sdf/sdf_test_functions.py:107).
- **Dashboard & DLQ Tooling** — ~65%: Flask dashboard surfaces intake metrics; add DLQ explorer, status history, and operational docs to round out observability (dashboard/README.md:12).

## Post-MVP Horizon
- **Block Sequencing & Anchor Execution** — sequence entries into ledger_blocks and push anchor proofs to the chosen trust anchor service (docs/Attestation_Pipeline.md:75).
- **Attestation Policy Engine** — enforce policy decisions before persistence; integrate warnings into acknowledgements and dashboards (scratch.md:31).
- **Reader API & Historical Pruning** — expose read-only FastAPI endpoints using the reader role and trim long-lived dedupe/anchor state (docs/ACE_LEDGER_Overview.md:32).
- **Extended Metrics & DLQ Automation** — add per-attester latency, dedupe hit ratios, alert hooks, and retry tooling (README_project_rehydration.md).

## Long-Term Considerations
- **Secrets & Credential Lifecycle** — align ledger secrets platform-wide once Vault automation lands; ensure compose/dev paths stay in sync.
- **Multi-Region Story** — design replication/federation while maintaining ordering guarantees (docs/archive/phase1_followups.md:32).
- **Schema Versioning & Self-Service Onboarding** — formalize envelope evolutions and auto-provision producer roles, aligning with future ACE governance processes (docs/ACE_LEDGER_Overview.md:21).

Keep this roadmap updated when tickets move. Cross-link future edits to the rehydration README plus `zerene_ace_ledger_issue_tracking.json` so the dormant context stays accurate.
