# Architecture Decisions

## ADR-001: Use Docker Swarm For The First Platform Phase

Decision: use Docker Swarm stacks as the first orchestration model.

Reasoning:

- Swarm is simple to operate on a small VPS.
- stack files are readable and close to Docker Compose syntax.
- overlay networking is enough for the initial service set.
- the platform can deploy multiple apps without a full Kubernetes learning curve.

Tradeoff:

- Swarm has fewer platform primitives than Kubernetes.
- GitOps, RBAC, policy, and advanced health behavior are limited.

Status: accepted for phase one.

## ADR-002: Use Traefik As The Dynamic Edge

Decision: use Traefik with Docker provider and Swarm mode.

Reasoning:

- Traefik discovers routes from service labels.
- ACME support is built in.
- middleware can be expressed with labels.
- each stack can declare its own public hostname.
- route updates do not require editing a central proxy file.

Tradeoff:

- route state is spread across many files.
- label mistakes can create confusing behavior.
- the dashboard becomes important for debugging.
- audit is harder than a central Nginx route file.

Status: accepted for phase one, later evolved to Nginx.

## ADR-003: Set `exposedByDefault=false`

Decision: require explicit `traefik.enable=true` labels.

Reasoning:

- services should not become public just because they exist.
- route exposure is a deliberate per-service decision.
- it reduces accidental exposure on the shared Docker provider.

Tradeoff:

- missing labels cause routes not to appear.
- every public service requires a complete label set.

Status: accepted.

## ADR-004: Use A Shared Overlay Network

Decision: use `edge-net` as the shared network between Traefik and routed services.

Reasoning:

- Traefik needs network reachability to backends.
- a shared overlay network is simple and standard in Swarm.
- app stacks can be deployed independently while still becoming routable.

Tradeoff:

- attaching too many services increases lateral exposure.
- network membership must be reviewed.

Status: accepted with review discipline.

## ADR-005: Use Docker Secrets For Sensitive App Values

Decision: reference sensitive values through Docker secrets where stack files support it.

Reasoning:

- secrets should not live in Git.
- Docker secrets are available to Swarm services at runtime.
- stack files can document secret names without exposing values.

Tradeoff:

- secrets must be created manually or by a separate process.
- secret rotation requires a deployment plan.

Status: accepted.

## ADR-006: Keep A Migration Path To Nginx And K3s

Decision: treat this repo as phase one, not the final architecture.

Reasoning:

- Traefik + Swarm solves initial deployment needs.
- Nginx improves edge auditability without moving apps.
- K3s later introduces Kubernetes-native controls.
- each phase has a clear learning and maturity purpose.

Tradeoff:

- maintaining multiple architecture repos requires clear documentation.

Status: accepted.

