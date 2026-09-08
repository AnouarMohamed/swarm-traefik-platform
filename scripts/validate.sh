#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_DIR}"

mapfile -t shell_files < <(find . -type f -name '*.sh' -print | sort)
bash -n "${shell_files[@]}"

if grep -RInE '^[[:space:]]*docker stack rm ' \
  --include='*.sh' --exclude-dir='.git' .; then
  echo "Deploy scripts must update stacks idempotently; automatic stack removal is forbidden." >&2
  exit 1
fi

render_stack() {
  local stack_file="$1"
  local stack_dir
  stack_dir="$(dirname "${stack_file}")"
  stack_file="$(basename "${stack_file}")"
  (
    cd "${stack_dir}"
    docker stack config -c "${stack_file}" >/dev/null
  )
}

export LETSENCRYPT_EMAIL="validation@example.com"
export TRAEFIK_AUTH_USERS='validation:$$2y$$05$$not-a-runtime-credential'
export SUPERSET_ADMIN_USERNAME="validation-admin"
export SUPERSET_ADMIN_EMAIL="validation@example.com"
export SUPERSET_ALLOWED_ORIGIN="https://portal.example.com"
export SUPERSET_FRAME_ANCESTORS="'self' https://portal.example.com"

render_stack traefik/traefik.stack.yml
render_stack mysql-admin/mysql-admin.stack.yml
render_stack mysql-development/mysql-development.stack.yml
render_stack mongodb/mongodb.stack.yml
render_stack portainer/portainer-agent-stack.yml
render_stack jenkins/jenkins-stack.yml
render_stack glpi/glpi.stack.yml
render_stack passbolt/passbolt.stack.yml
render_stack superset/superset.stack.yml

created_env_files=()
cleanup() {
  local env_file
  for env_file in "${created_env_files[@]}"; do
    rm -f -- "${env_file}"
  done
}
trap cleanup EXIT

for app_dir in wordpress-apps/wordpress-*; do
  if [[ ! -e "${app_dir}/.env" ]]; then
    cp "${app_dir}/sample.env" "${app_dir}/.env"
    created_env_files+=("${app_dir}/.env")
  fi
  render_stack "${app_dir}/$(basename "${app_dir}").stack.yml"
done

echo "All Swarm stacks and shell scripts passed static validation."

