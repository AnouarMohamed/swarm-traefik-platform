# Route Catalog

## Public Routes

| Host | Stack file | Router | Backend port | Controls |
| --- | --- | --- | --- | --- |
| `edge-status.example.com` | `traefik/traefik.stack.yml` | `traefik` | `api@internal` | `authinfra`, `infra-ratelimit`, `infra-compress` |
| `portainer.example.com` | `portainer/portainer-agent-stack.yml` | `portainer` | `9000` | `infra-ratelimit` |
| `jenkins.example.com` | `jenkins/jenkins-stack.yml` | `jenkins` | `8080` | `authinfra` |
| `glpi.example.com` | `glpi/glpi.stack.yml` | `glpi` | `80` | `infra-ratelimit`, `infra-compress` |
| `passbolt.example.com` | `passbolt/passbolt.stack.yml` | `passbolt` | `8080` | `infra-ratelimit`, `infra-compress` |
| `superset.example.com` | `superset/superset.stack.yml` | `superset` | `8088` | `biHeader` |
| `mongodb-admin.example.com` | `mongodb/mongodb.stack.yml` | `mongo-express` | `8081` | `infra-ratelimit` |
| `db-admin.example.com` | `mysql-admin/mysql-admin.stack.yml` | `phpmyadmin` | `80` | `authinfra` |
| `db-development.example.com` | `mysql-development/mysql-development.stack.yml` | `phpmyadmin-dev` | `80` | `authinfra` |
| `wordpress-school.example.com` | `wordpress-apps/wordpress-school/wordpress-school.stack.yml` | `wordpress-school-wp` | `80` | `authinfra` |
| `wordpress-invoice.example.com` | `wordpress-apps/wordpress-invoice/wordpress-invoice.stack.yml` | `wordpress-invoice-wp` | `80` | `authinfra` |
| `wordpress-portfolio.example.com` | `wordpress-apps/wordpress-portfolio/wordpress-portfolio.stack.yml` | `wordpress-portfolio-wp` | `80` | `infra-compress` |
| `wordpress-community.example.com` | `wordpress-apps/wordpress-community/wordpress-community.stack.yml` | `wordpress-community-wp` | `80` | default TLS route |
| `wordpress-resume.example.com` | `wordpress-apps/wordpress-resume/wordpress-resume.stack.yml` | `wordpress-resume-wp` | `80` | default TLS route |
| `wordpress-blog.example.com` | `wordpress-apps/wordpress-blog/wordpress-blog.stack.yml` | `wordpress-blog` | `80` | default TLS route |

## Route Categories

Infrastructure/admin:

- Traefik dashboard.
- Portainer.
- Jenkins.
- phpMyAdmin.
- Mongo Express.

Business/internal apps:

- GLPI.
- Superset.
- Passbolt.

Public website apps:

- WordPress sites.

## Route Review Checklist

- Is the route still needed?
- Is the hostname correct?
- Is DNS pointed at the edge?
- Is TLS enabled?
- Is the correct middleware attached?
- Does the route expose an admin surface?
- Does the service use the correct internal port?
- Is the service attached to `edge-net`?
