# Change Management

## Change Classes

| Change type | Risk | Review expectation |
| --- | --- | --- |
| documentation | low | normal review |
| add app stack | medium | dependencies, route, volumes, secrets |
| add public route | medium/high | labels, DNS, TLS, middleware |
| change middleware | high | security review |
| change database stack | high | backup/restore plan |
| change Traefik command | high | full edge review |
| rotate secret | high | consumer and rollback plan |

## Standard Workflow

```bash
git status --short
find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
git diff
cd <stack-folder>
./deploy.sh
```

## Pre-Deployment Checklist

- required Docker secrets exist.
- required external volumes exist.
- `edge-net` exists.
- DNS points to the Swarm edge.
- labels are complete.
- middleware choice is correct.
- rollback command is known.
- stateful data is backed up if needed.

## Post-Deployment Checklist

```bash
docker stack services <stack>
docker stack ps <stack>
docker service logs <stack>_<service> --tail 100
curl -Ik https://<host>/
```

For Traefik itself:

```bash
docker service ps traefik_RP
docker service logs traefik_RP --tail 200
```

## Rollback Model

For an app stack:

```bash
git revert <bad_commit>
cd <stack-folder>
./deploy.sh
```

For Traefik edge failure:

1. inspect logs.
2. revert the Traefik stack change.
3. redeploy Traefik.
4. validate dashboard and one known route.

## Why Discipline Matters

Traefik makes route creation easy. That is useful, but it also means a small label change can expose or break a route. Change management keeps the dynamic model safe.

