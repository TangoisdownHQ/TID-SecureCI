#!/usr/bin/env bash
set -euo pipefail

VERSION=${1:-2.3.0}
INSTALL_DIR=${2:-tools}

mkdir -p "${INSTALL_DIR}"

echo "[TID-SecureCI] Installing osv-scanner v${VERSION} into ${INSTALL_DIR}/"
curl -fsSL \
  "https://github.com/google/osv-scanner/releases/download/v${VERSION}/osv-scanner_linux_amd64" \
  -o "${INSTALL_DIR}/osv-scanner"
chmod +x "${INSTALL_DIR}/osv-scanner"
echo "[TID-SecureCI] osv-scanner installed at ${INSTALL_DIR}/osv-scanner"
