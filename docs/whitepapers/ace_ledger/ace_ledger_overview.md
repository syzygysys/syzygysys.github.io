# ACE::LEDGER Overview

ACE::LEDGER is the attestation backbone for the ACE platform. It receives
artifact evidence, enforces deduplication, persists provenance records, and
publishes anchor material that other ACE services can verify. The codebase is
organised around a small asynchronous worker and a PostgreSQL schema that
protects integrity through least‑privilege access.

## Core Components

- **Intake worker** (`src/ace_ledger/main.py`, `src/ace_ledger/services/intake/`)
  subscribes to the `ace.ledger.artifact.event` NATS subject. It normalises
  CloudEvents metadata, persists ingress payloads, tracks dedupe keys, emits
  acknowledgement messages on `ace.ledger.artifact.ack`, and maintains
  Prometheus metrics (`src/ace_ledger/services/metrics_server.py`).
- **Ledger schema** (`src/ace_ledger/db/models.py`) defines tables inside the
  dedicated `ledger` schema: `ledger_entries`, `ledger_attestations`,
  `ledger_blocks`, `ledger_anchors`, and the `ledger_intake_dedupe` guard table.
  Alembic migrations live in `alembic/versions/` and use the same schema to keep
  metadata isolated from the default `public` schema.
- **Role bootstrap** scripts (`scripts/db/`) provision the
  `ace_ledger_intake`, `ace_ledger_reader`, and `ace_ledger_admin` roles. Each
  script enforces explicit `CONNECT`, `USAGE`, and table‑level grants so the
  intake service never escalates beyond the tables it owns.
- **Schema definitions** (`src/ace_ledger/schemas/`) publish the canonical JSON
  schema for artifact envelopes (`ace.artifact.v1`) and attestation envelopes
  (`ace.attestation.v1`). Producers validate payloads against these documents
  before pushing them to NATS.
- **Operational harness** lives under `sdf/`. The SDF tests exercise database
  connectivity, schema expectations, NATS ACLs, and a smoke end-to-end ingest
  path using real credentials.
- **Monitoring dashboard** (`dashboard/`) delivers both a Flask web dashboard
  and terminal monitor mirroring the ACE::REGISTRY tooling. They query the
  `/api/dashboard` FastAPI router to render intake throughput, acknowledgement
  health, dedupe state, and DLQ statistics.

## Runtime Topology

| Component | Purpose | Ports / Subjects |
|-----------|---------|------------------|
| Postgres 16 (`docker-compose.yml`) | Hosts the `ledger` schema and roles. | 5435/tcp on the host |
| NATS JetStream (`config/environments/development/nats.conf`) | Message bus for artifact events, acknowledgements, and DLQ traffic. | 4222/tcp client, 8222/http monitoring |
| Intake service (`ace-ledger intake`) | Asynchronous consumer that writes to Postgres, exposes `/metrics`. | Internal port 9202 |
| Dashboard (`dashboard/app.py`) | Read-only dashboard served via Flask/gunicorn. | 8600/tcp (default) |

Prometheus metrics include total intake events, in‑flight processing gauge,
latency histograms, and a DLQ counter (`ace_ledger_intake_dlq_total`). All
metrics are namespaced `ace_ledger_*` for easy scraping by platform observers.

## Configuration

Environment variables map through `src/ace_ledger/config/settings.py`. Key
settings include:

- `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` – intake
  connection settings (defaults to the `ace_ledger_intake` role).
- `NATS_SERVERS`, `NATS_USERNAME`, `NATS_PASSWORD` – connection details for the
  message bus. Development uses two accounts: `ledger-producer` (publish) and
  `ledger-intake` (subscribe + ack/DLQ publish).
- `INTAKE_SUBJECT`, `INTAKE_ACK_SUBJECT`, `DEAD_LETTER_SUBJECT` – subject names
  for intake, acknowledgement, and dead-letter channels. Defaults align with
  the ACLs defined in the dev NATS config.
- `ACE_LEDGER_API_URL`, `ACE_LEDGER_METRICS_URL`, `ACE_LEDGER_DASHBOARD_PORT` –
  dashboard settings for web/terminal tooling.

## Observability & Testing

- Metrics are exposed on `http://<container>:9202/metrics` and captured via the
  `start_metrics_http_server` helper (`ace_ledger_intake_events_total`,
  `ace_ledger_intake_dlq_total`, etc.). The Flask dashboard fetches these via
  `/api/metrics` for quick inspection.
- The SDF suite (`poetry run pytest sdf/sdf_test_*.py`) validates database and
  NATS connectivity, ensures required tables exist, and proves the round‑trip
  ingestion path with real dedupe enforcement.
- Integration tests (`tests/integration/test_intake_role_permissions.py`) assert
  the least‑privilege contract for the intake database role, including negative
  checks against disallowed operations.

## Repository Structure (selected)

```
src/ace_ledger/
  config/           # Pydantic settings and env integration
  db/               # Async engine + SQLAlchemy models
  domain/           # Domain objects (e.g., IntakeRecord)
  repositories/     # Data access layer (LedgerRepository)
  services/
    intake/         # NATS consumer, startup checks, metrics
    metrics_server.py
schemas/            # JSON schema assets for envelopes
alembic/            # Migration environment and versions
scripts/db/         # Bootstrap SQL + admin helpers
sdf/                # System definition framework tests
```

Keep this map handy when onboarding new contributors or integrating with other
ACE services.
