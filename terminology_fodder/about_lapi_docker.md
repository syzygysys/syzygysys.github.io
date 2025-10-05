# About lapi_docker

## Intent
`lapi_docker` provides the Docker integration for LAP and LAPI repos. Its purpose is to standardize container builds, runtime configuration, and testing workflows across the SyzygySys ecosystem. It ensures that each integration can be run in a containerized environment with minimal setup.

## How It Functions
- Provides a Dockerfile and docker-compose.yml baseline for running LAP/LAPI modules.
- Integrates healthcheck definitions into `docker-compose.yml` for self-diagnostics.
- Works with `validate_lapi_repo` to confirm compliance with containerization standards.
- Hooks and scripts support local dev + CI/CD builds.

## Why It Exists (Human + Agent)
- **Humans**: Gives developers a consistent, repeatable way to spin up LAP/LAPI modules in Docker for local testing and deployment.
- **Agents**: Serves as a standardized environment for Marvin/Zerene to build, test, and run modules, with diagnostics exposed via healthchecks for SDF.

## Examples
- Run `docker-compose up` in a `lapi_*` repo to start its service and healthcheck.
- Extend the Dockerfile in a new repo with custom dependencies.
- Use SDF to validate that container builds include healthchecks.

## Roadmap
1. Standardize all LAP/LAPI repos to include healthcheck-enabled docker-compose.yml files.
2. Add prebuilt Docker images to a SyzygySys container registry.
3. Integrate `lapi_docker` with `sdf` for containerized test runs.
4. Expand hooks to auto-lint Dockerfiles and enforce best practices.
