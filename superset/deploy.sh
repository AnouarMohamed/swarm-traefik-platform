#!/usr/bin/env bash
# Build and update Superset without embedding credentials in image layers and
# without deleting the running stack before the replacement is ready.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [[ ! -f .env ]]; then
    echo "Missing superset/.env. Copy .env.example and replace all placeholders." >&2
    exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

SUPERSET_IMAGE="${SUPERSET_IMAGE:-registry.example.com/platform/superset:4.0.0-r1}"
STACK_NAME="${STACK_NAME:-superset}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-remote}"
ORIGINAL_CONTEXT="$(docker context show 2>/dev/null || echo default)"

restore_context() {
    docker context use "${ORIGINAL_CONTEXT}" >/dev/null 2>&1 || true
}
trap restore_context EXIT

for required in \
    SUPERSET_ADMIN_USERNAME \
    SUPERSET_ADMIN_EMAIL \
    SUPERSET_FRAME_ANCESTORS \
    SUPERSET_ALLOWED_ORIGIN; do
    value="${!required:-}"
    if [[ -z "${value}" || "${value}" == *example.com* || "${value}" == *admin@example.com* ]]; then
        echo "${required} is missing or still contains an example value." >&2
        exit 1
    fi
done

for secret_name in \
    SUPERSET_SECRET_KEY \
    SUPERSET_DATABASE_URI \
    SUPERSET_GUEST_TOKEN_JWT_SECRET \
    SUPERSET_ADMIN_PASSWORD; do
    if ! docker --context "${DOCKER_CONTEXT}" secret inspect "${secret_name}" >/dev/null 2>&1; then
        echo "Missing Docker secret ${secret_name} in context ${DOCKER_CONTEXT}." >&2
        exit 1
    fi
done

docker context use "${DOCKER_CONTEXT}"
docker build --pull -t "${SUPERSET_IMAGE}" -f ./dockerfile .
docker stack config -c superset.stack.yml >/dev/null
docker stack deploy --prune --resolve-image always -c superset.stack.yml "${STACK_NAME}"

echo "Superset stack ${STACK_NAME} submitted with runtime-only secrets."
