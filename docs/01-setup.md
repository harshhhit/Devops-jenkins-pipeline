# Setup

Local DevOps lab: Nginx (website), Jenkins (CI/CD) and SonarQube (code quality), all run with Docker Compose. Trivy is used for security scanning.

## Layout

```
.
├── docker-compose.yml   # nginx + jenkins + sonarqube
├── Dockerfile           # nginx image (ubuntu:24.04 + nginx)
└── website/
    └── index.html       # the site that gets deployed
```

## Prerequisites

- Docker Engine and the Docker Compose plugin
- Free host ports: 8080, 8081, 9000
- Linux host setting needed by SonarQube (Elasticsearch):
  ```bash
  sudo sysctl -w vm.max_map_count=262144
  ```

## Start

```bash
docker compose up -d --build
docker compose ps
```

| Service   | URL                   | Notes                              |
|-----------|-----------------------|------------------------------------|
| Nginx     | http://localhost:8081 | Serves `./website`                 |
| Jenkins   | http://localhost:8080 | Image `jenkins/jenkins:lts-jdk21`  |
| SonarQube | http://localhost:9000 | Default login `admin` / `admin`, you must change it on first login |

## First-time Jenkins unlock

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Paste it at http://localhost:8080, install the suggested plugins, create an admin user.

## How deployment works

`./website` is mounted in two places:

- into Nginx at `/var/www/html`
- into Jenkins at `/var/jenkins_home/deployment`

So a Jenkins job that writes files to `/var/jenkins_home/deployment` updates the live site immediately. No container restart is needed.

## Install Trivy (in the Jenkins container)

```bash
docker exec -u root jenkins bash -c \
  "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
docker exec jenkins trivy --version
```
This is lost if the container is recreated. For something permanent, build a custom Jenkins image.

## Stop / reset

```bash
docker compose down        # keep data
docker compose down -v     # also delete Jenkins and SonarQube volumes
```

## Troubleshooting

- SonarQube exits at start: check `vm.max_map_count` (above) and `docker compose logs sonarqube`.
- Permission errors writing to `deployment`: the Jenkins user is uid 1000, so make `./website` writable by it (`chmod -R u+rwX,g+rwX website`).
