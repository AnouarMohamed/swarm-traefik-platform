# Architecture diagrams

The diagrams are deliberately linear. Detailed route mappings live in tables so connectors never obscure nodes.

## Request path

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant D as Public DNS
    participant T as Traefik edge
    participant A as Swarm application
    participant B as Private database

    U->>D: Resolve app.example.com
    D-->>U: Swarm node address
    U->>T: HTTPS with SNI and Host
    T->>T: Router then middleware chain
    T->>A: Overlay request to internal port
    A->>B: Private network query
    B-->>A: Data
    A-->>T: HTTP response
    T-->>U: HTTPS response
```

## Dynamic configuration path

```mermaid
flowchart TB
    A[1. Application stack declares labels]
    B[2. Docker provider reads Swarm services]
    C[3. Traefik builds routers]
    D[4. Middlewares apply policies]
    E[5. Traefik selects the internal service port]
    F[6. Overlay network reaches the task]

    A --> B --> C --> D --> E --> F
```

## Trust zones

```mermaid
flowchart TB
    I[Untrusted Internet]

    subgraph EDGE[Edge zone]
        T[Traefik on ports 80 and 443]
    end

    subgraph APPS[Application zone]
        A[WordPress, GLPI, Jenkins, Superset and Passbolt]
    end

    subgraph DATA[Data zone]
        D[MySQL, MariaDB and MongoDB]
    end

    I --> T
    T --> A
    A --> D
```

