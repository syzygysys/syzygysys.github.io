# ACE::SYS — Central Knowledge Library (MVP)

> **Goal**: A centralized, versioned, queriable store for *all* ACE instance knowledge: docs, configs, code refs, prompts, reports, artifacts, provenance, and links — with first‑class RAT (record/audit trail), embedded prompts, and graph relationships.

---

## Table of Contents
1. [Non‑goals & Constraints](#non-goals--constraints)
2. [Core Concepts](#core-concepts)
3. [MVP Architecture](#mvp-architecture)
4. [Data Model](#data-model)
5. [APIs (FastAPI)](#apis-fastapi)
6. [Storage Layout](#storage-layout)
7. [Ingestion Pipeline](#ingestion-pipeline)
8. [Search & Retrieval](#search--retrieval)
9. [Embedded Prompts (Entangled HREFs)](#embedded-prompts-entangled-hrefs)
10. [Security & IAM](#security--iam)
11. [Observability](#observability)
12. [CLI](#cli)
13. [Repo Layout & Scaffolding](#repo-layout--scaffolding)
14. [Migrations & Seeds](#migrations--seeds)
15. [Tests](#tests)
16. [DoD & Jira Tickets](#dod--jira-tickets)

---

## Non‑goals & Constraints
- Non‑goal: build a general CMS. SYS is an *internal knowledge substrate* for ACE.
- Must be **FOSS‑first**, clean IP, bootstrap friendly.
- **Deterministic rehydration**: a fresh clone + seeds must fully reconstruct SYS state.
- **Offline‑capable** (no mandatory SaaS deps). Optional connectors gated.

---

## Core Concepts
- **Resource**: the atomic unit (file, snippet, dataset, graph node, binary artifact, dashboard JSON, etc.).
- **Facet**: structured metadata view over a Resource (e.g., `doc`, `config`, `prompt`, `report`, `schema`, `artifact`).
- **Bundle**: logical grouping (e.g., “ACE::LEDGER v0.9.0 release pack”).
- **Edge**: typed relation (RDF‑lite): `references`, `derives_from`, `duplicates`, `supersedes`, `generated_by`.
- **RAT**: immutable append‑only audit trail; every mutation emits an event.
- **PromptLink**: an embedded, executable prompt (the “entangled href”).

---

## MVP Architecture
- **API**: FastAPI service `ace_library_api` (REST + minimal gRPC later).
- **DB**: Postgres 16 w/ pgvector for embeddings; SQLAlchemy/Alembic.
- **ObjStore**: S3‑compatible (MinIO) for blobs; content‑addressed (`sha256/xx/…`).
- **Search**: Postgres full‑text + pgvector hybrid. (Optional: Meilisearch later.)
- **Queue**: NATS (event bus) for RAT events, async ingestion.
- **Cache**: Redis for hot indices and pre‑renders.
- **Auth**: ACE IAM (JWT w/ service roles; row‑level policies by org/project).
- **Obs**: Prometheus metrics + OTLP traces optional.

---

## Data Model
**Tables (prefix `sys_`)**
- `resources` — id (UUID), kind, title, summary, mime, size, content_sha256, content_url, created_at, created_by, version, bundle_id?, project, tags (array), visibility.
- `facets` — id, resource_id → `resources.id`, facet_type, jsonb.
- `edges` — id, src_id, dst_id, edge_type, weight?, note?, created_at.
- `bundles` — id, name, version, jsonb_meta, created_at.
- `rat_events` — id, resource_id?, actor, action, at, payload jsonb, sig.
- `prompt_links` — id, resource_id, title, prompt_text, schema jsonb?, runtime (mcp/a2a/tool), policy jsonb.
- `embeddings` — id, resource_id, facet_type, model, dim, vec vector(dim), chunk_idx, text_range.

**Indexes**
- GIN on `facets.jsonb`, `tags`, FTS on `summary + extracted_text`, HNSW/IVFFlat on `embeddings.vec`.

**Content Addressing**
- Blob path: `s3://sys/${sha256:0:2}/${sha256:2:2}/${sha256}`

---

## APIs (FastAPI)
**Resources**
- `POST /v1/resources` (multipart or JSON+external_url)
- `GET /v1/resources/{id}`
- `PATCH /v1/resources/{id}` (metadata only)
- `POST /v1/resources/{id}:version` (freeze new version)
- `GET /v1/resources/{id}/facets`

**Search**
- `POST /v1/search` → { q, filters, top_k, hybrid_weight }
- `POST /v1/semantic` → { query, top_k, model }

**Graph**
- `POST /v1/edges` / `GET /v1/graph?start=…&depth=…&types=…`

**RAT**
- `GET /v1/rat/{resource_id}`; `GET /v1/rat/events?since=…`

**Prompt Links**
- `POST /v1/prompt_links` (attach to resource)
- `POST /v1/prompt_links/{id}:execute` (returns tool call plan + result)

**Admin**
- `GET /v1/health` `GET /v1/metrics`

---

## Storage Layout
```
./data/               # local dev volume mounts
  ├─ postgres/
  ├─ minio/
  ├─ redis/
  └─ nats/
./artifacts/          # exported bundles, docs, reports
```

---

## Ingestion Pipeline
1. **Detect**: file watcher / webhook / CLI import.
2. **Classify**: mime sniff + heuristics (YAML, JSON, md, code, pdf).
3. **Extract**: text (md/html), code symbols, front‑matter, images (EXIF), PDFs.
4. **Facetize**: emit `facets` rows (e.g., `{type: "doc", headings:[…]}`).
5. **Embed**: chunk + embed → `embeddings` rows.
6. **Graph**: link refs (e.g., md links, issue keys, repo paths).
7. **RAT**: publish `sys.resource.created` to NATS.

---

## Search & Retrieval
- **Hybrid**: score = λ·(BM25) + (1−λ)·(cosine(vec, q))
- Filters: `project`, `bundle`, `kind`, `tags`, `visibility`.
- **Traceable**: results include provenance (which chunks, which facet).

---

## Embedded Prompts (Entangled HREFs)
- Markdown syntax: `[Run: SDF Summary](:prompt:123e4567)`
- Execution: API validates policy, resolves runtime target (MCP/A2A), emits audit RAT, returns artefact resource id for outputs.

---

## Security & IAM
- JWT claims → `project`, `role`, `scopes`.
- Row‑level policies: `visibility in ('public','internal') AND (project = any(jwt.projects))`.
- Signed download URLs for ObjStore.

---

## Observability
- Metrics: `sys_ingest_latency_seconds`, `sys_resources_total`, `sys_embeddings_total`, `sys_prompt_exec_total/errors`, `db_query_duration_seconds`.
- Tracing: request spans, ingestion steps, prompt exec.

---

## CLI
```
ace-sys ingest <path|url> --project ACE --tags doc,design
ace-sys search "prompt_links" --k 20 --filters project=ACE kind=doc
ace-sys bundle create --name ACE_LIBRARY_MVP --query "project=ACE"
ace-sys prompt exec <prompt_id> --input '{…}'
```

---

## Repo Layout & Scaffolding
```
ace_library/
  ├─ pyproject.toml
  ├─ README.md
  ├─ ACE_LIBRARY/
  │   ├─ api/            # FastAPI routers
  │   ├─ core/           # services: ingest, storage, search, graph
  │   ├─ models/         # SQLAlchemy + Pydantic
  │   ├─ rat/            # event bus (NATS) emit/consume
  │   ├─ auth/
  │   ├─ cli/
  │   └─ utils/
  ├─ migrations/         # Alembic
  ├─ docker/
  │   ├─ docker-compose.yml
  │   └─ Dockerfile.api
  ├─ scripts/
  │   ├─ scaffold.sh
  │   └─ seed_demo.sh
  └─ tests/
```

**`pyproject.toml` (key deps)**
- fastapi, uvicorn, pydantic, sqlalchemy, alembic
- psycopg[binary], pgvector, python‑magic, pypdf, markdown‑it‑py
- boto3/minio, redis, nats‑py, prometheus‑fastapi‑instrumentator

---

## Migrations & Seeds
- Alembic rev `0001_init_sys` creates tables/indexes.
- `seed_demo.sh` loads sample docs, a PDF, a config, and a PromptLink.

---

## Tests
- Unit: models (constraints), services (ingest, embed stub), auth.
- API: resource CRUD, search hybrid scoring determinism, prompt exec policy.
- E2E (docker‑compose): happy‑path ingest → search → graph traverse.

---

## DoD & Jira Tickets
**Definition of Done (MVP)**
- Start via `docker compose up`: API 200/`/health`, metrics exposed, seed loaded.
- Ingest md/pdf/json; search returns deterministic ranked hits; graph edges visible; prompt link executes a stub runtime.
- RAT events persisted and queryable.

**Jira‑sized tickets**
1. SYS‑1: Init repo, pyproject, Dockerfiles, compose, CI.
2. SYS‑2: Alembic `0001_init_sys` + pgvector enablement.
3. SYS‑3: Resource storage (S3 Content‑Addressing) + upload/download.
4. SYS‑4: Ingestion v0 (md, json, pdf) + facetizers.
5. SYS‑5: Embedding service w/ pluggable provider (env‑selectable, can stub).
6. SYS‑6: Hybrid search endpoint + filters + pagination.
7. SYS‑7: Graph edges + simple traverse API.
8. SYS‑8: RAT events (NATS) producer + persistence.
9. SYS‑9: PromptLink model + execute stub + audit.
10. SYS‑10: Auth/JWT + row‑level policies; signed URLs.
11. SYS‑11: Observability metrics + dashboards.
12. SYS‑12: CLI (Typer) for ingest/search/bundle/prompt.
13. SYS‑13: Seed data + E2E docker‑compose harness.
14. SYS‑14: Docs (README, OpenAPI, ADRs); Confluence page import.

---

## Minimal Code Snippets (reference)
**SQLAlchemy: `Resource`**
```python
class Resource(Base):
    __tablename__ = "sys_resources"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    kind = Column(String(32), nullable=False)
    title = Column(String(512), nullable=False)
    summary = Column(Text)
    mime = Column(String(128))
    size = Column(BigInteger)
    content_sha256 = Column(String(64), index=True, unique=True)
    content_url = Column(String(1024))
    project = Column(String(64), index=True)
    tags = Column(ARRAY(String(64)), server_default="{}")
    version = Column(Integer, nullable=False, default=1)
    visibility = Column(String(16), default="internal")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    created_by = Column(String(128))
```

**FastAPI: create resource**
```python
@router.post("/v1/resources", response_model=ResourceOut)
async def create_resource(meta: ResourceIn, blob: UploadFile | None = None):
    sha = await store_blob(blob) if blob else await fetch_external(meta.url)
    r = Resource(**meta.model_dump(exclude={"url"}), content_sha256=sha, content_url=addr_for(sha))
    db.add(r); db.commit()
    enqueue("sys.resource.created", {"id": str(r.id), "sha": sha})
    return r
```

**Search hybrid (sketch)**
```sql
SELECT id, kind, title,
       (ts_rank_cd(fts, plainto_tsquery(:q)) * :lambda) +
       ((1 - :lambda) * (1 - (1 - (embedding <=> :qvec)))) AS score
FROM sys_search_view
WHERE project = ANY(:projects) AND kind = ANY(:kinds)
ORDER BY score DESC LIMIT :k;
```

---

## Confluence/Jira Entanglement
- Publish OpenAPI + ERD + ADRs to Confluence `active_doc_hub`.
- Create epic **ACE::SYS — Central Library** with tickets SYS‑1..SYS‑14.
- Link RAT metrics to Prometheus dashboards under `./config/grafana`.

---

### Runbook (dev)
```bash
# 1) bootstrap
make dev-up          # docker compose: pg, minio, redis, nats, api
make db-migrate

# 2) seed
./scripts/seed_demo.sh

# 3) smoke
http :8088/health
http :8088/v1/search q=="ledger" top_k==10
```

---

**Notes**
- Embedding provider is pluggable: env `SYS_EMBED_BACKEND={openai,ollama,stub}`.
- PDF extraction via `pypdf`; safe fallback stores plain text if parser fails.
- Prompt exec runtime can be MCP/A2A adapter; MVP uses a stub that records input and returns an echo artefact.

