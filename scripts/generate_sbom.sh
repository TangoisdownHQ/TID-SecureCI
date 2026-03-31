#!/usr/bin/env bash
set -euo pipefail

SCAN_PATH=${1:-target}
OUTPUT_DIR=${2:-sbom}
SYFT_VERSION=${SYFT_VERSION:-v1.25.1}

mkdir -p "${OUTPUT_DIR}" tools

if ! command -v syft >/dev/null 2>&1; then
  echo "[TID-SecureCI] syft not found. Downloading ${SYFT_VERSION} locally..."
  curl -fsSL \
    "https://github.com/anchore/syft/releases/download/${SYFT_VERSION}/syft_${SYFT_VERSION#v}_linux_amd64.tar.gz" \
    -o "tools/syft.tar.gz"
  tar -xzf "tools/syft.tar.gz" -C tools syft
  SYFT_BIN="$PWD/tools/syft"
else
  SYFT_BIN="$(command -v syft)"
fi

echo "[TID-SecureCI] Generating SBOM for ${SCAN_PATH}..."
"${SYFT_BIN}" "${SCAN_PATH}" -o spdx-json > "${OUTPUT_DIR}/sbom.spdx.json"
"${SYFT_BIN}" "${SCAN_PATH}" -o cyclonedx-json > "${OUTPUT_DIR}/sbom.cdx.json"
echo "[TID-SecureCI] SBOMs created in ${OUTPUT_DIR}/"

