# Production Readiness

## Position

The Traefik Swarm repo is a valid first-phase infrastructure. Production readiness depends on operational controls around the stacks.

## Matrix

| Area | Current repo | Production expectation |
| --- | --- | --- |
| edge routing | Traefik labels | route inventory and label review |
| TLS | Traefik ACME resolver | expiry alerts and ACME storage backup |
| secrets | Docker secrets for databases and Superset; `.env` for non-secret routing metadata and legacy WordPress variables | migrate remaining application passwords to Docker secrets and document rotation ownership |
| state | Docker volumes | off-node backups and restore drills |
| logs | Traefik log volume | central logging and retention |
| dashboard | basic auth | VPN/IP restriction recommended |
| deployment | mixed per-folder scripts; hardened Traefik and Superset updates are idempotent | converge on one validated release workflow |
| validation | manual commands | synthetic route checks |
| migration | documented evolution | Nginx/K3s path maintained |
| supply chain | public images pinned by digest; custom images carry explicit tags | controlled image registry, scanning, signatures and digest pins for custom builds |
| database exposure | MongoDB and development MySQL have no host-published ports | preserve private overlay-only access and audit the host firewall |

## High-Priority Improvements

- create a route owner list.
- alert on certificate expiry.
- back up `letsencrypt` volume.
- back up all stateful service data.
- restrict dashboard and admin tools.
- migrate the remaining legacy `.env` application passwords to Docker secrets.
- validate Docker secrets in every per-service deploy script, as already done for Superset.
- remove or replace the privileged Docker-socket cleanup helper.
- document exact restore procedure per stateful app.

## Production Gate For New Services

Do not expose a new service until:

1. DNS is correct.
2. route labels are complete.
3. middleware is selected.
4. service is attached to `edge-net`.
5. secrets exist.
6. volumes exist.
7. health is validated.
8. backup owner is known if stateful.

## When To Move Beyond This Phase

Move toward Nginx or K3s when:

- route audit becomes too difficult.
- Git-based desired state becomes important.
- namespaces/RBAC/policies are needed.
- platform onboarding requires stronger standards.
- the team needs Kubernetes experience for GKE or other managed platforms.
