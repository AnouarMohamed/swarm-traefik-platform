# Security

## Security Objective

The Traefik Swarm platform uses dynamic discovery while keeping secrets out of Git. The main security challenge is visibility: routes are distributed across stack files, so review discipline is required.

## Secrets

Never commit:

- `.env`.
- Docker secret files.
- ACME private data.
- database passwords.
- Passbolt keys.
- Superset secret keys.
- generated htpasswd values for real users.

Committed examples must remain placeholders.

## Traefik Dashboard

The dashboard is useful but sensitive. It reveals routers, services, middlewares, and operational topology.

Rules:

- protect it with basic auth.
- do not expose it without TLS.
- consider IP allowlisting or VPN for production.
- rotate the basic-auth hash when access changes.

## ACME Storage

Traefik ACME state must be protected because it contains certificate account data and private key material.

Rules:

- keep ACME storage out of Git.
- back it up if production depends on it.
- restrict file permissions.
- avoid deleting it during normal stack cleanup.

## Middleware Model

Traefik middlewares can enforce:

- HTTPS redirect.
- basic auth.
- security headers.
- rate limiting.
- compression.

Because middlewares can be attached by label, reviews must confirm that each public route has the correct middleware chain.

## Threat Model

| Threat | Control |
| --- | --- |
| accidental route exposure | review `traefik.enable` and router labels |
| weak dashboard protection | basic auth through `TRAEFIK_AUTH_USERS` |
| secret leak | `.env`, secret files, and ACME data ignored |
| certificate failure | Traefik ACME logs and resolver configuration |
| lateral network exposure | attach only required services to `edge-net` |
| app compromise | separate stacks, secrets, and volumes |

## Hardening Backlog

- centralize route inventory.
- add CI checks for labels.
- restrict dashboard by IP or VPN.
- document each Docker secret owner.
- add log shipping.
- alert on ACME failures.
- minimize service attachment to shared networks.

