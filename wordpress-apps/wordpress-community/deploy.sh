#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../../scripts/deploy-stack.sh" wordpress-community "${SCRIPT_DIR}/wordpress-community.stack.yml"
