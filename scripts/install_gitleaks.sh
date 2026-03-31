#!/usr/bin/env bash
set -euo pipefail

VERSION=${1:-8.24.2}
INSTALL_DIR=${2:-tools}

mkdir -p "${INSTALL_DIR}"

echo "[TID-SecureCI] Installing gitleaks v${VERSION} into ${INSTALL_DIR}/"
curl -fsSL \
  "https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/gitleaks_${VERSION}_linux_x64.tar.gz" \
  -o "${INSTALL_DIR}/gitleaks.tar.gz"
tar -xzf "${INSTALL_DIR}/gitleaks.tar.gz" -C "${INSTALL_DIR}" gitleaks
chmod +x "${INSTALL_DIR}/gitleaks"
echo "[TID-SecureCI] gitleaks installed at ${INSTALL_DIR}/gitleaks"

