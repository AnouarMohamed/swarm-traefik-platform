# Service Inventory

## Inventory

| Folder | Stack/service role | Main dependencies | Public exposure model |
| --- | --- | --- | --- |
| `traefik/` | edge proxy | `edge-net`, ACME storage, auth env | dashboard and routers |
| `portainer/` | Swarm management UI and agent | Docker socket/agent, volume | Traefik route |
| `jenkins/` | CI/CD | persistent home volume | Traefik route |
| `glpi/` | ITSM app | database, files | Traefik route |
| `passbolt/` | password manager | MariaDB, Docker secrets, keys | Traefik route |
| `superset/` | BI/dashboard app | custom image, env, metadata state | Traefik route |
| `mongodb/` | MongoDB and Mongo Express | Docker secrets, volumes | Mongo Express route |
| `mysql-admin/` | production MySQL and phpMyAdmin | Docker secrets, volumes | phpMyAdmin route |
| `mysql-development/` | development MySQL and phpMyAdmin | Docker secrets, volumes | phpMyAdmin route |
| `wordpress-apps/` | multiple WordPress apps | shared image, per-site DB/env | per-site Traefik routes |
| `cleanup/` | cleanup helper | Docker engine access | internal/helper |

## Dependency Notes

Data services should be treated as foundational. Applications may start without them, but they will not be healthy.

High-sensitivity services:

- Passbolt.
- phpMyAdmin.
- Mongo Express.
- Jenkins.
- Portainer.

These routes should never be considered normal public websites. They require auth, rate limiting, and ideally network restrictions.

## WordPress Pattern

The WordPress folders share:

- a common Dockerfile under `wordpress-apps/`.
- `custom.ini` for PHP upload/runtime tuning.
- per-site stack files.
- per-site sample env files.
- per-site deploy scripts.

This pattern is useful because it keeps app creation repeatable. The tradeoff is that image updates affect several sites and need coordinated testing.

## Data Ownership

| Service | Data that matters |
| --- | --- |
| WordPress | database, uploads, themes, plugins |
| Jenkins | jobs, credentials, plugins, build history |
| GLPI | database, attachments, plugins |
| Superset | metadata database, dashboards, secret key |
| Passbolt | database, GPG/JWT keys, user state |
| Mongo | database data and users |
| MySQL | databases and phpMyAdmin access credentials |

No migration should proceed until the relevant data owner is known.

