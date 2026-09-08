# Stack names

Stack names describe the workload, never an organization or customer.

| Stack name | Stack file | Purpose |
|---|---|---|
| `traefik` | `traefik/traefik.stack.yml` | Dynamic edge and ACME. |
| `mysql-admin` | `mysql-admin/mysql-admin.stack.yml` | Main MySQL and phpMyAdmin pair. |
| `mysql-development` | `mysql-development/mysql-development.stack.yml` | Development MySQL and phpMyAdmin pair. |
| `mongodb` | `mongodb/mongodb.stack.yml` | MongoDB and Mongo Express. |
| `portainer` | `portainer/portainer-agent-stack.yml` | Docker management UI and agent. |
| `jenkins` | `jenkins/jenkins-stack.yml` | CI server. |
| `glpi` | `glpi/glpi.stack.yml` | GLPI application. |
| `superset` | `superset/superset.stack.yml` | Superset BI application. |
| `passbolt` | `passbolt/passbolt.stack.yml` | Passbolt and MariaDB. |
| `wordpress-school` | `wordpress-apps/wordpress-school/wordpress-school.stack.yml` | Protected WordPress example. |
| `wordpress-invoice` | `wordpress-apps/wordpress-invoice/wordpress-invoice.stack.yml` | Protected WordPress example. |
| `wordpress-portfolio` | `wordpress-apps/wordpress-portfolio/wordpress-portfolio.stack.yml` | Public WordPress example. |
| `wordpress-community` | `wordpress-apps/wordpress-community/wordpress-community.stack.yml` | Public WordPress example. |
| `wordpress-resume` | `wordpress-apps/wordpress-resume/wordpress-resume.stack.yml` | Public WordPress example. |
| `wordpress-blog` | `wordpress-apps/wordpress-blog/wordpress-blog.stack.yml` | Public WordPress example. |

Swarm service DNS follows the pattern `<stack>_<service>`. For example, service `wp` in stack `wordpress-blog` is reached as `wordpress-blog_wp` on the shared overlay network.

