#!/usr/bin/env bash
set -euo pipefail

REPO_URL=${1:-}
BRANCH=${2:-main}
TARGET_DIR=${3:-target}

if [ -z "${REPO_URL}" ]; then
  echo "usage: $0 <repo-url> [branch] [target-dir]" >&2
  exit 1
fi

if [ "${TARGET_DIR}" = "/" ] || [ "${TARGET_DIR}" = "." ]; then
  echo "[TID-SecureCI] Refusing to remove unsafe target directory: ${TARGET_DIR}" >&2
  exit 1
fi

echo "[TID-SecureCI] Cloning repo: ${REPO_URL} (branch/ref: ${BRANCH})"
rm -rf "${TARGET_DIR}"
git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}" "${TARGET_DIR}"
echo "[TID-SecureCI] Clone complete. Code is in ./${TARGET_DIR}"
