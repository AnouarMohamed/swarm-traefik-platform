# Secrets And Volumes

## Principle

The repository must document secrets and volumes without storing real sensitive values. Runtime values belong in Docker secrets, local `.env` files, or the Swarm node storage layer.

## Secret Classes

| Class | Examples | Handling |
| --- | --- | --- |
| edge auth | `TRAEFIK_AUTH_USERS` | local `.env`, escaped bcrypt hash |
| database passwords | MySQL, Mongo, MariaDB | Docker secrets |
| application secret keys | Superset, Passbolt | Docker secrets or app env outside Git |
| certificate account data | ACME account and cert material | Traefik `letsencrypt` volume |
| app keys | Passbolt GPG/JWT material | app-specific secure backup |

## Docker Secret Review

Before deploying a stack that references secrets:

```bash
docker secret ls
docker stack config -c <stack-file>
```

The stack should reference secret names, not raw values.

## Volume Classes

| Volume type | Examples | Risk |
| --- | --- | --- |
| edge state | `letsencrypt`, `traefik-logs` | certificate and incident evidence |
| database state | MySQL, Mongo, MariaDB volumes | business data loss |
| app state | Jenkins home, WordPress content, GLPI files | service data loss |
| helper state | cleanup helper data if any | lower risk |

## Backup Priority

Highest priority:

- Passbolt database and keys.
- MySQL production data.
- GLPI data and attachments.
- WordPress databases and uploads.
- Superset metadata and secret key.
- Traefik ACME storage.

## Rotation Notes

Secrets should not be rotated blindly. For each rotation:

1. identify consumers.
2. create the new secret.
3. update stack references or env.
4. redeploy affected stack.
5. verify the app works.
6. remove the old secret only after rollback is no longer needed.

## What Not To Commit

- `.env`.
- secret files.
- database dumps.
- private keys.
- ACME storage.
- generated password hashes for real accounts.

