# Evolution To Nginx And K3s

## Why This Repo Still Matters

This repository is the source of truth for the original infrastructure phase. Even after the Nginx edge and K3s lab exist, this repo explains:

- what services exist.
- how they were exposed.
- which dependencies were required.
- where dynamic Traefik labels were used.
- what risks motivated the next phase.

## Phase Comparison

| Phase | Strength | Weakness |
| --- | --- | --- |
| Traefik + Swarm | fast service discovery, integrated ACME, labels close to app | distributed routing, harder audit, label mistakes possible |
| Nginx + Swarm | central route control, clear TLS/bootstrap model, predictable debugging | manual route updates, redeploy needed |
| K3s lab | Kubernetes primitives, namespaces, probes, Ingress, cert-manager, GitOps path | higher complexity, storage and security need more discipline |

## Why Nginx Was A Good Intermediate Step

Nginx improved the edge without forcing all applications to migrate. It changed one layer at a time:

```text
same apps + same Swarm network + same hostnames + new edge proxy
```

That is a strong migration pattern because the blast radius is controlled.

## Why K3s Is The Next Learning Step

K3s adds value when the startup needs:

- Kubernetes-native deployment objects.
- stronger separation by namespace.
- readiness checks before traffic.
- cert-manager for certificates.
- NetworkPolicy.
- GitOps reconciliation.
- easier future movement to GKE.

K3s should be introduced through a lab first. The correct sequence is:

1. keep Swarm stable.
2. learn and document K3s.
3. migrate one low-risk stateless service.
4. prove backup and restore for stateful workloads.
5. decide if production migration is worth the operational cost.

## Migration Rule

Do not migrate because Kubernetes is fashionable. Migrate only when the platform receives concrete value:

- fewer manual operations.
- clearer change history.
- stronger security boundaries.
- better recovery.
- easier scaling.
- better developer onboarding.

