#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL_CONTEXT="$(docker context show)"
TARGET_CONTEXT="${DOCKER_CONTEXT:-${ORIGINAL_CONTEXT}}"
IMAGE="${CLEANUP_IMAGE:-registry.example.com/platform/cleanup:3.22-r1}"

restore_context() {
  docker context use "${ORIGINAL_CONTEXT}" >/dev/null 2>&1 || true
}
trap restore_context EXIT

docker context inspect "${TARGET_CONTEXT}" >/dev/null
docker context use "${TARGET_CONTEXT}" >/dev/null

docker build --pull -t "${IMAGE}" "${SCRIPT_DIR}/core"
CLEANUP_IMAGE="${IMAGE}" docker compose -f "${SCRIPT_DIR}/docker-compose.yaml" config >/dev/null
CLEANUP_IMAGE="${IMAGE}" docker compose -f "${SCRIPT_DIR}/docker-compose.yaml" up -d --remove-orphans

echo "Cleanup helper submitted with Docker context ${TARGET_CONTEXT}."
