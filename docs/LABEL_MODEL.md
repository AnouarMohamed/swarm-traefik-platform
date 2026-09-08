# Traefik Label Model

## Objective

Traefik routes in this repo are declared with Docker service labels. This keeps route configuration near the application stack, but it requires disciplined naming and review.

## Minimum Public Route Labels

```yaml
deploy:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.<router>.rule=Host(`<host>`)"
    - "traefik.http.routers.<router>.entrypoints=websecure"
    - "traefik.http.routers.<router>.tls=true"
    - "traefik.http.routers.<router>.tls.certresolver=leresolver"
    - "traefik.http.services.<service>.loadbalancer.server.port=<port>"
```

## Middlewares In This Repo

| Middleware | Purpose | Defined in |
| --- | --- | --- |
| `authinfra` | basic auth for infrastructure surfaces | `traefik/traefik.stack.yml` |
| `infra-ratelimit` | request rate limiting | `traefik/traefik.stack.yml` |
| `infra-retry` | retry failed upstream requests | `traefik/traefik.stack.yml` |
| `infra-compress` | response compression | `traefik/traefik.stack.yml` |
| `redirect-to-https` | HTTP to HTTPS redirect | `traefik/traefik.stack.yml` |
| `redirect-to-www` | optional www redirect | `traefik/traefik.stack.yml` |
| `biHeader` | Superset CORS/embedding headers | `superset/superset.stack.yml` |

## Label Review Rules

Before merging or deploying labels:

- `traefik.enable=true` appears only on intended public services.
- `Host(...)` matches the real DNS name.
- router name is unique.
- service name is unique.
- target port matches the internal container port.
- `entrypoints=websecure` is present.
- TLS resolver is `leresolver`.
- admin tools include `authinfra` or another protection.
- high-risk tools include rate limiting.

## Common Label Mistakes

| Mistake | Symptom |
| --- | --- |
| wrong target port | 502 or blank response |
| missing `edge-net` | route exists but backend is unreachable |
| duplicate router name | unpredictable route conflict |
| missing TLS resolver | route may not receive certificate |
| missing middleware | admin route exposed too broadly |
| typo in hostname | route never matches real request |

## Why This Became A Migration Driver

Labels are powerful for fast growth. Over time, the route model becomes harder to audit because public exposure is distributed across many stack files. That is one reason the later Nginx repo centralizes routes.
