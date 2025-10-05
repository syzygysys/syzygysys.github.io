# About lapi_prometheus (Current Implementation)

## Intent
`lapi_prometheus` is a LAP Integration (LAPI) module that provides MCP-structured access to Prometheus monitoring services within the SyzygySys ecosystem. It serves as a bridge between Prometheus time-series data and LAP::CORE's diagnostic framework, enabling both direct monitoring queries and standardized health validation.

The service focuses on exposing Prometheus functionality through a consistent MCP (Model Control Protocol) interface while maintaining compatibility with direct API access patterns.

---

## How it Functions
- **FastAPI Service**: Runs as a containerized FastAPI application with health monitoring endpoints
- **MCP Interface**: Provides 5 core MCP capabilities for Prometheus interaction:
  - `prometheus.targets` - Monitor scrape target health
  - `prometheus.health` - Check Prometheus service status  
  - `prometheus.metrics` - Retrieve internal Prometheus metrics
  - `prometheus.query` - Execute instant queries
  - `prometheus.query_range` - Execute time-range queries
- **Direct Proxy**: Offers `/lapi_prometheus/query` and `/lapi_prometheus/query_range` endpoints for direct API access
- **Network Resilience**: Uses urllib-based HTTP client for reliable container-to-container communication
- **SDF Integration**: Ships with comprehensive SyzygySys Diagnostic Framework tests including recursive discovery

---

## Current Architecture
```
lapi_prometheus/
├── src/
│   ├── server.py              # FastAPI application with health endpoints
│   ├── mcp.py                 # MCP protocol implementation
│   └── routes_prometheus.py   # Direct Prometheus proxy routes
├── sdf/                       # SDF test framework
│   ├── __main__.py           # Recursive test runner
│   ├── sdf_test_functions.py # Comprehensive validation tests
│   └── sdf.yml              # Test configuration
├── docker-compose.yml        # Service containerization
└── pyproject.toml            # Poetry dependencies (no httpx dependency)
```

---

## Examples

**MCP Queries:**
```bash
# Check Prometheus target health
curl -X POST http://localhost:8115/mcp/query \
  -H "Content-Type: application/json" \
  -d '{"action": "prometheus.targets"}'

# Execute Prometheus query
curl -X POST http://localhost:8115/mcp/query \
  -H "Content-Type: application/json" \
  -d '{"action": "prometheus.query", "params": {"query": "up"}}'
```

**Direct API Access:**
```bash
# Direct query proxy
curl "http://localhost:8115/lapi_prometheus/query?q=up"

# Service health check
curl http://localhost:8115/lapi_prometheus/health
```

**SDF Validation:**
```bash
# Run comprehensive diagnostics
python3 -m sdf run --debug

# Local tests only (skip recursive discovery)
python3 -m sdf run --local-only
```

---

## Key Features

### MCP Protocol Implementation
- **Standardized Actions**: 5 core Prometheus capabilities with consistent parameter validation
- **Error Handling**: Robust error responses for invalid actions and missing parameters
- **Response Formats**: Maintains Prometheus API response structures while adding MCP metadata

### Service Health Monitoring
- **Health Endpoints**: Basic (`/health`) and extended (`/lapi_prometheus/status`) health reporting
- **Target Validation**: Monitors Prometheus scrape target health with detailed failure reporting
- **Connectivity Checks**: Validates Prometheus service readiness and health endpoints

### Diagnostic Framework Integration
- **Comprehensive Testing**: 14 SDF test functions covering all service capabilities
- **Recursive Discovery**: Automatic test discovery across project hierarchies
- **Debug Enumeration**: Detailed test breakdown with individual test tracking
- **Error Isolation**: Process-isolated test execution with timeout protection

---

## Technical Implementation Details

### Network Architecture
- **Container Communication**: Uses Docker network `platform_net` for service discovery
- **HTTP Client**: urllib-based implementation for reliable container networking (replaced httpx due to compatibility issues)
- **Service Discovery**: Connects to `prometheus:9090` via Docker network aliases

### Response Handling
- **MCP Responses**: Returns raw Prometheus API responses maintaining protocol fidelity
- **Error Formats**: Handles both FastAPI error formats (`detail`) and MCP error formats (`status`, `error`)
- **Status Codes**: Appropriate HTTP status codes with detailed error messages

### Development Standards
- **Poetry Packaging**: Uses `package-mode = false` for standalone service deployment
- **Import Structure**: Consistent module imports following `src.module` pattern
- **Environment Configuration**: Configurable via `PROM_URL` environment variable

---

## Why it Exists
- **MCP Standardization**: Provides consistent protocol interface for Prometheus integration across LAP ecosystem
- **Health Validation**: Enables automated monitoring and validation of Prometheus infrastructure
- **Diagnostic Integration**: Supports SDF recursive testing for comprehensive platform validation
- **Service Bridge**: Connects time-series monitoring data with LAP::CORE's diagnostic and observability framework

---

## Technical Debt

The following features were planned in the original design but are not currently implemented:

### Missing Integrations
- **`validate_lapi_repo`**: No integration with repo structure validation tooling
- **`lapi_template` compliance**: No automated compliance checking against template standards
- **Grafana integration**: No Grafana service in docker-compose.yml for dashboard access
- **LAP subsystem exporters**: No custom exporters for git, shell, or MCP metrics

### API Gaps
- **`/prometheus/*` routes**: Original design expected `/prometheus/query` rather than `/lapi_prometheus/query`
- **Direct `/metrics` endpoint**: No direct Prometheus metrics exposure endpoint
- **JSON response wrapping**: Planned agent-friendly JSON wrapping not implemented
- **Unified observability hub**: No integration with logs (Loki) or traces (Tempo/OTel)

### Agent Integration Features
- **Agent-triggered alerts**: No subscription mechanism for Prometheus rule changes
- **Auto-diagnosis pipelines**: No agent interpretation of metrics for automated fix suggestions
- **Templated dashboards**: No automated Grafana dashboard generation per LAPI repo

### Advanced Capabilities
- **Alert management integration**: No connection to alert routing systems
- **Cross-service correlation**: No unified metrics aggregation across LAPI services
- **Performance benchmarking**: No integration with performance testing frameworks

---

## Current Roadmap Status

**Completed (MVP+):**
- ✅ Prometheus service containerization with health checks
- ✅ MCP protocol implementation with 5 core capabilities
- ✅ SDF validation framework with recursive discovery
- ✅ Robust error handling and network resilience
- ✅ Comprehensive test coverage (14 test functions)

**Planned for Future Iterations:**
- Agent-friendly JSON API wrappers
- Grafana dashboard integration
- Repository structure validation tooling
- Direct `/metrics` endpoint implementation
- Cross-LAPI service metrics aggregation

---

## Alignment with SyzygySys

The current implementation successfully bridges Prometheus monitoring with the SDF diagnostic framework, providing both human-accessible health endpoints and machine-readable MCP interfaces. While some originally planned features remain as technical debt, the core functionality enables reliable Prometheus integration within the LAP::CORE ecosystem.

The service maintains consistency with LAPI patterns through standardized health endpoints, MCP protocol compliance, and comprehensive SDF testing, ensuring it integrates seamlessly with other LAP services while providing essential monitoring capabilities.