#!/usr/bin/env bash
# Idempotent Traefik stack deployment with explicit context selection and
# configuration preflight. Existing tasks are updated in place by Swarm.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${SCRIPT_DIR}"

if [[ -f "${REPO_DIR}/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "${REPO_DIR}/.env"
    set +a
fi

STACK_NAME="${STACK_NAME:-traefik}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-}"
ORIGINAL_CONTEXT="$(docker context show 2>/dev/null || echo default)"

restore_context() {
    docker context use "${ORIGINAL_CONTEXT}" >/dev/null 2>&1 || true
}
trap restore_context EXIT

require_configuration() {
    local email="${LETSENCRYPT_EMAIL:-}"
    local auth_users="${TRAEFIK_AUTH_USERS:-}"

    if [[ "${email}" == "admin@example.com" || ! "${email}" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; then
        echo "LETSENCRYPT_EMAIL must be a real, valid operator address." >&2
        exit 1
    fi

    if [[ -z "${auth_users}" || "${auth_users}" == *replace-this* ]]; then
        echo "TRAEFIK_AUTH_USERS must contain a real bcrypt htpasswd entry." >&2
        exit 1
    fi
}

select_context() {
    local choice

    if [[ -n "${DOCKER_CONTEXT}" ]]; then
        docker context inspect "${DOCKER_CONTEXT}" >/dev/null
        docker context use "${DOCKER_CONTEXT}"
        return
    fi

    if [[ ! -t 0 ]]; then
        echo "DOCKER_CONTEXT is unset; using current context ${ORIGINAL_CONTEXT}."
        return
    fi

    echo "Select Docker context:"
    echo "1. Current (${ORIGINAL_CONTEXT})"
    echo "2. Default"
    echo "3. Remote"
    read -r -p "Enter your choice (1, 2 or 3): " choice
    case "${choice}" in
        1) return ;;
        2) docker context use default ;;
        3) docker context use remote ;;
        *)
            echo "Invalid Docker context choice." >&2
            exit 1
            ;;
    esac
}

ensure_runtime_objects() {
    docker network inspect edge-net >/dev/null 2>&1 || \
        docker network create --driver overlay --attachable edge-net >/dev/null
    docker volume inspect letsencrypt >/dev/null 2>&1 || \
        docker volume create letsencrypt >/dev/null
    docker volume inspect traefik-logs >/dev/null 2>&1 || \
        docker volume create traefik-logs >/dev/null
}

require_configuration
select_context
ensure_runtime_objects
docker stack config -c traefik.stack.yml >/dev/null
docker stack deploy --prune --resolve-image always -c traefik.stack.yml "${STACK_NAME}"

echo "Traefik stack ${STACK_NAME} submitted successfully."
