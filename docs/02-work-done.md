# Work Done So Far

## Completed

- Docker Compose stack with Nginx, Jenkins and SonarQube.
- Nginx image built from `Dockerfile` (Ubuntu 24.04 + nginx) serving `website/`.
- Static site in `website/index.html`.
- Shared `website/` folder between Nginx and Jenkins, which is the deployment path.

## Fixes applied to the original files

| Problem | Fix |
|---|---|
| Markdown code fences (```` ```yaml ````) inside the compose file made it invalid YAML | Removed them |
| `dockercompose.yml` is not a name Compose looks for | Renamed to `docker-compose.yml` |
| Compose referenced `Dockerfile` but the file was `dockerfile` (case-sensitive on Linux) | Renamed to `Dockerfile` |
| `COPY website/` and the `./website` mount pointed at a folder that did not exist | Created `website/` and moved `index.html` into it |
| `ubuntu:latest` is unpinned, so builds and scan results drift | Pinned to `ubuntu:24.04` |

`docker compose config` validates the result. The containers have not been started or tested end to end yet.

## Not done yet

- Jenkins first-time setup, plugins and credentials
- Trivy installed in Jenkins
- SonarQube project, token and Jenkins integration
- Git repository connected to Jenkins
- Any actual Jenkins job or pipeline. See the three guides:
  - [Freestyle job](03-freestyle-job.md)
  - [Basic pipeline](04-basic-pipeline.md)
  - [Advanced pipeline](05-advanced-pipeline.md)
