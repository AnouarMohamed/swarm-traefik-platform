# Dependency Map

## Platform Dependencies

| Dependency | Purpose | Failure impact |
| --- | --- | --- |
| Docker Swarm | schedules stacks and services | no stack deployment or service reconciliation |
| manager node | runs stack commands and Traefik placement | deployment and edge control fail |
| `edge-net` | shared overlay for public routes | routers cannot reach services |
| ports 80 and 443 | public HTTP/S entrypoints | no public access or ACME challenge |
| Docker socket | Traefik Docker provider reads service metadata | route discovery fails |
| `letsencrypt` volume | stores Traefik ACME account and certificates | certificate loss or reissuance required |
| `traefik-logs` volume | stores Traefik logs | weak incident investigation |
| `.env` | runtime email and auth hash | deployment can fail or dashboard auth missing |

## Service Dependencies

| Service group | Depends on | Notes |
| --- | --- | --- |
| Traefik | Docker socket, `edge-net`, ACME volume, auth env | must start before public routes work |
| Portainer | agent, Docker/Swarm access, data volume | operational UI |
| MySQL production/dev | secrets, persistent volumes | foundational data layer |
| Mongo | secrets, persistent volumes | Mongo Express depends on MongoDB |
| Passbolt | MariaDB, secrets, keys, persistent volumes | high sensitivity |
| Superset | custom image, env, metadata persistence | BI dashboards depend on secret key |
| Jenkins | persistent home volume | CI/CD state in volume |
| GLPI | persistent files and database strategy | stateful business app |
| WordPress apps | per-site env, volumes, database | shared image pattern |
| Cleanup | Docker engine access | should run only after platform is stable |

## Critical Path For A Public Request

```text
DNS -> port 443 -> Traefik -> Docker provider labels -> router -> middleware -> service load balancer -> Swarm task
```

## Critical Path For ACME

```text
DNS -> public entrypoint -> Traefik ACME resolver -> Let's Encrypt -> /letsencrypt/acme.json
```

## Dependency Checks

```bash
docker node ls
docker network inspect edge-net
docker volume inspect letsencrypt
docker volume inspect traefik-logs
docker service ls
docker service ps traefik_RP
```

Check whether a service is attached to the edge network:

```bash
docker service inspect <stack>_<service> \
  --format '{{json .Spec.TaskTemplate.Networks}}'
```

Check labels:

```bash
docker service inspect <stack>_<service> \
  --format '{{json .Spec.Labels}}'
```

