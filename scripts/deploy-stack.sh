#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# != 2 )); then
  echo "Usage: $0 <stack-name> <stack-file>" >&2
  exit 2
fi

STACK_NAME="$1"
STACK_FILE="$2"
STACK_DIR="$(cd "$(dirname "${STACK_FILE}")" && pwd)"
STACK_FILE="${STACK_DIR}/$(basename "${STACK_FILE}")"
ORIGINAL_CONTEXT="$(docker context show)"
TARGET_CONTEXT="${DOCKER_CONTEXT:-${ORIGINAL_CONTEXT}}"

restore_context() {
  docker context use "${ORIGINAL_CONTEXT}" >/dev/null 2>&1 || true
}
trap restore_context EXIT

docker context inspect "${TARGET_CONTEXT}" >/dev/null
docker context use "${TARGET_CONTEXT}" >/dev/null
cd "${STACK_DIR}"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# Render first. A malformed or incompletely interpolated stack never reaches
# the manager. This action is safe to repeat and does not remove the old stack.
docker stack config -c "${STACK_FILE}" >/dev/null

if [[ "${MODE:-deploy}" == "validate" ]]; then
  echo "Stack ${STACK_NAME} validated with Docker context ${TARGET_CONTEXT}."
  exit 0
fi

docker stack deploy --prune --resolve-image always \
  -c "${STACK_FILE}" "${STACK_NAME}"

echo "Stack ${STACK_NAME} submitted with Docker context ${TARGET_CONTEXT}."

