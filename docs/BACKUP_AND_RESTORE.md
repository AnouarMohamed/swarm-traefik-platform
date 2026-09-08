# Backup And Restore

## Scope

This repo documents infrastructure, but several stacks contain state. Backups are mandatory for any serious operation.

## Backup Inventory

| Asset | Why it matters |
| --- | --- |
| Traefik `letsencrypt` volume | ACME account and certificates |
| Traefik logs | incident analysis |
| MySQL production volume | production database state |
| MySQL dev volume | development database state |
| Mongo volume | Mongo data |
| Passbolt database and keys | password manager integrity |
| Jenkins home volume | jobs, plugins, credentials |
| GLPI data/database | ITSM records and attachments |
| Superset metadata and secret key | dashboards and auth/session integrity |
| WordPress DB/uploads | site content |

## Backup Principles

- database dumps are not optional.
- volume snapshots are not enough unless restore is tested.
- off-node backups are required.
- secrets and application keys must be backed up with the data that depends on them.
- restore drills should happen before migration.

## Example Volume Backup

```bash
docker run --rm \
  -v letsencrypt:/data:ro \
  -v "$PWD:/backup" \
  alpine tar czf /backup/traefik-letsencrypt-backup.tgz -C /data .
```

## Example Database Dump Pattern

Use the appropriate database credentials and service names for each stack:

```bash
docker exec <mysql-container> \
  mysqldump -u root -p --all-databases > mysql-backup.sql
```

Do not commit dumps.

## Restore Order

1. restore Docker Swarm node and network.
2. restore Traefik ACME data or prepare reissuance.
3. restore databases.
4. restore app volumes and keys.
5. deploy Traefik.
6. deploy data services.
7. deploy applications.
8. validate routes.

## Restore Gate

A backup is credible only after:

- a service starts from restored data.
- authentication still works.
- files/uploads are present.
- public route works.
- rollback is documented.

