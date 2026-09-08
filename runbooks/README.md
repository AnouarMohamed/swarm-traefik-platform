# Runbooks

## 1. Traefik Down

```bash
docker service ls
docker service ps traefik_traefik
docker service logs traefik_traefik --tail 200
```

Check:

- Docker node is healthy.
- ports 80 and 443 are available.
- ACME storage is mounted.
- `TRAEFIK_AUTH_USERS` exists.
- `edge-net` exists.

## 2. Route Missing From Dashboard

```bash
docker service inspect <stack>_<service> --format '{{json .Spec.Labels}}'
docker service inspect <stack>_<service> --format '{{json .Spec.TaskTemplate.Networks}}'
```

Common causes:

- `traefik.enable=true` missing.
- service not attached to `edge-net`.
- router rule typo.
- wrong service port label.
- stack not redeployed after label edit.

## 3. Certificate Issue

```bash
docker service logs traefik_traefik --tail 300 | rg -i "acme|certificate|challenge|error"
```

Check:

- DNS points to the Swarm edge.
- port 80 reaches Traefik.
- resolver name matches labels.
- ACME storage is writable.
- production Let's Encrypt is not rate-limited.

## 4. App Stack Failing

```bash
docker stack ps <stack>
docker service logs <stack>_<service> --tail 200
docker service inspect <stack>_<service>
```

Check:

- required Docker secrets.
- required volumes.
- image pull errors.
- database availability.
- environment variables.

## 5. Emergency Move To Nginx Edge

If the Nginx edge repo has already been validated:

```bash
cd ../swarm-nginx-edge
./deploy.sh bootstrap
./deploy.sh certs
./deploy.sh rm-bootstrap
./deploy.sh deploy
```

Only one edge stack can bind ports 80 and 443. Stop Traefik before deploying the full Nginx edge.

## 6. Pre-Push Safety Check

```bash
find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
rg -n "BEGIN|PRIVATE KEY|password=|PASSWORD=|token=|TOKEN=|acme|htpasswd" .
git status --short
```

Real secrets must not appear in tracked files.

## 7. Validate All Traefik Labels

```bash
rg -n "traefik.http.routers|traefik.http.services|traefik.enable" .
```

For a deployed service:

```bash
docker service inspect <stack>_<service> --format '{{json .Spec.Labels}}'
```

Check router name, host rule, TLS resolver, middleware, and target port.

## 8. Recreate Edge Network

Only do this if the network is missing and no services are attached.

```bash
docker network create --driver overlay --attachable edge-net
```

If services already exist, redeploy affected stacks so they attach to the recreated network.

## 9. Restore Traefik ACME Volume

```bash
docker volume create letsencrypt || true
docker run --rm \
  -v letsencrypt:/data \
  -v "$PWD:/backup" \
  alpine sh -c "cd /data && tar xzf /backup/traefik-letsencrypt-backup.tgz"
cd traefik
./deploy.sh
```

Validate:

```bash
docker service logs traefik_RP --tail 100
curl -Ik https://edge-status.example.com/
```

## 10. Emergency Disable A Public Route

Remove or set:

```yaml
- "traefik.enable=false"
```

Then redeploy the affected stack:

```bash
cd <stack-folder>
./deploy.sh
```

Confirm the route disappeared from the dashboard.
