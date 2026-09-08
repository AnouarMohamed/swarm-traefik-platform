#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scripts/deploy-stack.sh" jenkins "${SCRIPT_DIR}/jenkins-stack.yml"
