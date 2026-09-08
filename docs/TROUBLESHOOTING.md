# Troubleshooting

## Triage Order

1. Docker node health.
2. Traefik service health.
3. port binding.
4. DNS.
5. Traefik dashboard/router existence.
6. labels.
7. network attachment.
8. backend service health.
9. app logs and database state.

## Traefik Is Down

```bash
docker service ps traefik_RP --no-trunc
docker service logs traefik_RP --tail 200
```

Common causes:

- port 80/443 conflict.
- missing external volume.
- bad command flag.
- Docker socket permission/access issue.
- missing `TRAEFIK_AUTH_USERS`.

## Route Does Not Appear

```bash
docker service inspect <stack>_<service> --format '{{json .Spec.Labels}}'
```

Check:

- `traefik.enable=true`.
- router name.
- host rule.
- entrypoint.
- TLS resolver.
- labels are under `deploy.labels` for Swarm services.

## Route Appears But Returns 502

```bash
docker service inspect <stack>_<service> --format '{{json .Spec.TaskTemplate.Networks}}'
docker stack ps <stack>
docker service logs <stack>_<service> --tail 100
```

Likely causes:

- service is not attached to `edge-net`.
- target port label is wrong.
- backend task is down.
- app is listening on a different port.

## Certificate Fails

```bash
docker service logs traefik_RP --tail 300 | rg -i "acme|challenge|certificate|error"
dig +short <host>
```

Check:

- DNS.
- port 80/443 reachability.
- resolver name `leresolver`.
- ACME storage write access.
- Let's Encrypt rate limits.

## Dashboard Auth Fails

Check `.env`:

```text
TRAEFIK_AUTH_USERS=admin:$$2y$$...
```

Dollar signs must be escaped for Compose/stack interpolation.

Redeploy:

```bash
cd traefik
./deploy.sh
```

## App Starts But Data Missing

Likely causes:

- wrong volume name.
- volume not externalized as expected.
- app initialized a new empty database.
- secret mismatch caused new credentials or failed migration.

Stop and investigate before writing more data.

