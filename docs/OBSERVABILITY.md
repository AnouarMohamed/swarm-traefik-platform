# Observability

## Core Questions

The platform should quickly answer:

1. Is Traefik running?
2. Are routers discovered?
3. Are certificates issued?
4. Are backend services reachable?
5. Are stateful services healthy?

## Traefik Logs

```bash
docker service logs traefik_RP --tail 200
```

Look for:

- ACME challenge errors.
- router creation messages.
- backend connection failures.
- middleware errors.
- Docker provider errors.

## Dashboard

The dashboard shows:

- routers.
- services.
- middlewares.
- TLS state.
- provider status.

It should be treated as sensitive operational information and protected.

## Swarm Checks

```bash
docker service ls
docker stack ls
docker node ls
docker network inspect edge-net
```

## Service Checks

```bash
docker stack services <stack>
docker stack ps <stack>
docker service logs <stack>_<service> --tail 100
```

## Suggested Alerts

| Alert | Reason |
| --- | --- |
| Traefik service has zero running tasks | edge down |
| ACME errors in logs | future TLS or immediate issuance failure |
| certificate near expiry | renewal may be broken |
| Docker node disk pressure | databases/logs/cert storage at risk |
| high restart count on data service | stateful app instability |
| route returns 5xx | backend unavailable |

## Future Improvements

- keep the normal log level at `INFO`; enable `DEBUG` only for a bounded troubleshooting window and revert it afterward.
- ship Traefik logs to a central log system.
- export metrics to Prometheus.
- add synthetic probes for each public hostname.
- track stack health in a dashboard.
