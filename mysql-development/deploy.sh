#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scripts/deploy-stack.sh" mysql-development "${SCRIPT_DIR}/mysql-development.stack.yml"
