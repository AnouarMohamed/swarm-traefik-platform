# Operations

## Operator Contract

The operator is responsible for:

- Docker context selection.
- Swarm network creation.
- Docker secret creation.
- external volume creation.
- stack deployment order.
- DNS records.
- Traefik ACME storage safety.
- validating public routes after deploy.

## Minimal Bootstrap

```bash
docker network create --driver overlay --attachable edge-net
cp .env.example .env
```

Generate the dashboard/basic-auth hash:

```bash
docker run --rm httpd:2.4 htpasswd -nbB admin 'change-me'
```

Place the escaped value in:

```text
TRAEFIK_AUTH_USERS=...
```

## Deployment Order

Recommended order:

1. Traefik.
2. Portainer.
3. data services.
4. business applications.
5. WordPress applications.
6. cleanup helper last.

Why this order:

- the edge must exist before public routes can work.
- Portainer helps inspect later deployments.
- databases should exist before dependent apps initialize.
- cleanup helpers should not run before the platform is stable.

## Deploying A Stack

Most folders contain a `deploy.sh` script. The expected pattern is:

```bash
cd <service-folder>
./deploy.sh
```

Before deploying, check:

- required secrets exist.
- required volumes exist.
- the stack references `edge-net` if it needs public routing.
- labels use the intended hostname.
- DNS points to the edge node.

## Adding A New Public Service

1. Create the app stack file.
2. Attach the service to `edge-net`.
3. Add Traefik router labels.
4. Add TLS resolver label.
5. Add middleware labels if needed.
6. Deploy the stack.
7. Check Traefik dashboard and logs.
8. Test `curl -I https://<host>/`.

## Traefik Operations

Useful checks:

```bash
docker service ls
docker service ps traefik_traefik
docker service logs traefik_traefik --tail 100
```

Dashboard access should be protected by the configured basic-auth middleware.

## Rollback

Swarm rollback is normally a stack redeploy from Git:

```bash
git revert <bad_commit>
cd <service-folder>
./deploy.sh
```

For a broken app route, remove or fix the labels and redeploy that app stack. Traefik will update dynamically.

## Backup Responsibilities

This repo documents deployment, not backup execution. Production operation must include:

- database dumps.
- off-node backups.
- volume backup strategy.
- secret backup and recovery.
- restore drills.

Passbolt, GLPI, Superset, and WordPress databases must not be treated as disposable container state.

