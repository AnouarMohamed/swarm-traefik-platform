# Superset Runtime Setup

The image contains code and non-secret configuration only. Database credentials,
the Flask secret key, the guest-token signing key, and the bootstrap password are
Docker secrets created on the target Swarm manager.

Create them without placing their values on a command line:

```bash
openssl rand -base64 48 | docker secret create SUPERSET_SECRET_KEY -
openssl rand -base64 48 | docker secret create SUPERSET_GUEST_TOKEN_JWT_SECRET -
printf '%s' 'postgresql+psycopg2://superset:REPLACE@db:5432/superset' \
  | docker secret create SUPERSET_DATABASE_URI -
openssl rand -base64 32 | docker secret create SUPERSET_ADMIN_PASSWORD -
```

The database URI example must be replaced with a dedicated, reachable production
metadata database. Apache Superset does not recommend SQLite for production.

Then copy `.env.example` to `.env`, replace the example identity and embedding
origin, and run:

```bash
./deploy.sh
```

The deployment script verifies all four secrets, builds the pinned image, renders
the stack, and submits an in-place Swarm update. It never passes credentials to
`docker build`, so they cannot leak into image layers or build history.
