# Validation Guide

## Local Validation

Shell syntax:

```bash
find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

Secret scan:

```bash
rg -n "BEGIN|PRIVATE KEY|password=|PASSWORD=|token=|TOKEN=|acme|htpasswd" .
```

Only placeholders, examples, and secret references should appear in tracked files.

## Swarm Validation

```bash
docker node ls
docker network inspect edge-net
docker service ls
docker stack ls
```

## Traefik Validation

```bash
docker service ps traefik_traefik
docker service logs traefik_traefik --tail 200
```

Validate dashboard route with authentication.

## Route Validation

For each public hostname:

```bash
curl -I http://<host>/
curl -Ik https://<host>/
```

Expected:

- HTTP redirects or serves ACME as intended.
- HTTPS certificate is valid.
- router matches the intended service.
- protected routes challenge for auth.

## Stack Validation

For each stack:

```bash
docker stack services <stack>
docker stack ps <stack>
docker service logs <stack>_<service> --tail 100
```

Common problems:

- missing Docker secret.
- missing volume.
- service not attached to `edge-net`.
- invalid Traefik label.
- DNS not pointed at the edge.

