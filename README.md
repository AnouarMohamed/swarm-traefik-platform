# Swarm Traefik Platform

This repository contains the first infrastructure phase for the platform: Docker Swarm application stacks exposed through Traefik. It is retained as a documented historical baseline; the later Nginx edge and K3s repository contain the forward architecture.

Presentation and learning notes: [DevOps infrastructure defense guide](https://github.com/AnouarMohamed/devops-infrastructure-defense-guide).

It is intended as a presentation-ready and sanitized infrastructure reference. Secrets are not committed. Runtime credentials must be supplied through Docker secrets or local `.env` files.

## Contents

- `traefik/` - Traefik reverse proxy stack, ACME TLS, dashboard route, middlewares.
- `portainer/` - Portainer CE and Swarm agent stack.
- `jenkins/` - Jenkins service stack.
- `glpi/` - GLPI stack.
- `passbolt/` - Passbolt and MariaDB stack using Docker secrets.
- `superset/` - Superset custom image and stack template.
- `mongodb/` - MongoDB and Mongo Express stack using Docker secrets.
- `mysql-admin/` - Production MySQL and phpMyAdmin stack.
- `mysql-development/` - Development MySQL and phpMyAdmin stack.
- `wordpress-apps/` - Shared WordPress image and per-site stack files.
- `cleanup/` - Docker cleanup helper stack.

## Security Notes

- Real `.env` files are ignored.
- Docker secrets are referenced by name only.
- Traefik Basic Auth users are injected through `TRAEFIK_AUTH_USERS`.
- ACME account data such as `acme.json` is ignored.
- Public images are pinned by digest where the upstream registry supports it.
- MongoDB and development MySQL are reachable only on their overlay networks, not through published host ports.
- Portainer is exposed through the edge route only; direct UI/tunnel ports are not published by this baseline.
- Superset credentials and signing keys are runtime Docker secrets and are never Docker build arguments.

Traefik still needs read-only access to the Docker socket for label discovery. Read-only mounting prevents ordinary writes but does not make the Docker API harmless; access to the socket remains a privileged trust boundary and is one reason this is treated as the first architecture phase rather than the final security model.

## Minimal Setup

Create the Swarm network once:

```bash
docker network create --driver overlay --attachable edge-net
```

Create required external volumes and Docker secrets before deploying stacks that reference them.

Copy the example environment file:

```bash
cp .env.example .env
```

Generate the Traefik Basic Auth value:

```bash
docker run --rm httpd:2.4 htpasswd -nbB admin 'change-me'
```

Paste the generated value into `TRAEFIK_AUTH_USERS` in `.env`.

## Deploy Order

1. `traefik/`
2. data services: `mysql-admin/`, `mysql-development/`, `mongodb/`, `passbolt/`
3. applications: `portainer/`, `jenkins/`, `glpi/`, `superset/`, `wordpress-apps/*`
4. `cleanup/`

Each service folder keeps its own deployment script and stack file.

Validate every stack and shell script before deployment:

```bash
make validate
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Operations](docs/OPERATIONS.md)
- [Security](docs/SECURITY.md)
- [Service Inventory](docs/SERVICE_INVENTORY.md)
- [Evolution To Nginx And K3s](docs/EVOLUTION_TO_NGINX_AND_K3S.md)
- [Architecture Decisions](docs/DECISIONS.md)
- [Dependency Map](docs/DEPENDENCIES.md)
- [Traefik Label Model](docs/LABEL_MODEL.md)
- [Route Catalog](docs/ROUTE_CATALOG.md)
- [Secrets And Volumes](docs/SECRETS_AND_VOLUMES.md)
- [Change Management](docs/CHANGE_MANAGEMENT.md)
- [Observability](docs/OBSERVABILITY.md)
- [Backup And Restore](docs/BACKUP_AND_RESTORE.md)
- [Production Readiness](docs/PRODUCTION_READINESS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Validation Guide](docs/VALIDATION.md)
- [Architecture Diagrams](docs/DIAGRAMS.md)
- [Stack Names](docs/STACK_NAMES.md)
- [Runbooks](runbooks/README.md)
