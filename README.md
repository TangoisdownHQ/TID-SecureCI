# TID-SecureCI

Private reusable security pipeline for GitHub repositories.

TID-SecureCI is built to sit in one private GitHub repo and scan other private app repos through a reusable workflow. The pipeline is tuned for broad coverage instead of one scanner pretending to do everything.

## What It Scans

- Semgrep for multi-language SAST plus custom AI/ML guardrails
- Gitleaks for committed secrets
- OSV-Scanner for vulnerable manifests and lockfiles across major ecosystems
- Trivy for filesystem, dependency, secret, license, IaC, and optional container image scanning
- Checkov for Terraform, Kubernetes, Helm, Dockerfile, GitHub Actions, ARM, Bicep, and CloudFormation
- Syft SBOM generation through Anchore's SBOM action
- GitHub dependency review on pull requests

## Best Private GitHub Setup

Store this repository as private, then in the repository that hosts TID-SecureCI go to:

`Settings -> Actions -> General -> Access`

Allow other private repositories in your account or organization to use this workflow.

For each app repository you want to scan, also enable these GitHub-native features in the app repo:

- CodeQL default setup
- Dependabot alerts
- Dependabot security updates
- Secret scanning and push protection

Those settings live at the repository level, so they complement this reusable workflow instead of replacing it.

## Use It From A Private App Repo

Add a caller workflow like [examples/github/scan.yml](/home/tangoisdown/LOTL/TIDHQ.NETWORK/TIDHQ.wormhole/TID-SecureCI/examples/github/scan.yml) to the app repository:

```yaml
name: Secure Scan

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: "21 4 * * *"

permissions:
  contents: read
  security-events: write

jobs:
  secureci:
    uses: YOUR-ORG/TID-SecureCI/.github/workflows/tid-secureci.yml@master
    secrets: inherit
    with:
      enforce: false
      fail_severity: HIGH,CRITICAL
      image_ref: ghcr.io/YOUR-ORG/YOUR-APP:${{ github.sha }}
```

### Notes

- Start with `enforce: false` so you can tune noise before making the workflow blocking.
- Pin the reusable workflow to a branch or tag that actually exists in the SecureCI repo. The current default branch here is `master`.
- If you scan a different private repository than the caller, pass `target_repository`, `target_ref`, and a `checkout_token`.
- If your app does not build a container, leave `image_ref` empty.

## Workflow Inputs

| Input | Default | Purpose |
| --- | --- | --- |
| `target_repository` | caller repo | Repo to scan |
| `target_ref` | caller SHA | Branch, tag, or SHA to scan |
| `image_ref` | empty | Optional image to scan with Trivy |
| `fail_severity` | `HIGH,CRITICAL` | Blocking threshold for Trivy |
| `enforce` | `false` | Whether findings should fail the workflow |
| `enable_semgrep` | `true` | Enable Semgrep SAST |
| `enable_gitleaks` | `true` | Enable secret scanning |
| `enable_osv` | `true` | Enable dependency vulnerability scanning |
| `enable_checkov` | `true` | Enable IaC scanning |
| `enable_trivy` | `true` | Enable filesystem and image scanning |
| `enable_sbom` | `true` | Generate SPDX and CycloneDX SBOMs |
| `upload_artifacts` | `true` | Upload raw reports as workflow artifacts |

## Results

You will get:

- SARIF alerts in the GitHub Security tab
- workflow artifacts for raw scanner output
- SPDX and CycloneDX SBOM artifacts
- dependency review feedback on pull requests

## Local Helpers

The repo also includes local helper scripts:

- [scripts/clone_target_repo.sh](/home/tangoisdown/LOTL/TIDHQ.NETWORK/TIDHQ.wormhole/TID-SecureCI/scripts/clone_target_repo.sh)
- [scripts/generate_sbom.sh](/home/tangoisdown/LOTL/TIDHQ.NETWORK/TIDHQ.wormhole/TID-SecureCI/scripts/generate_sbom.sh)
- [scripts/install_gitleaks.sh](/home/tangoisdown/LOTL/TIDHQ.NETWORK/TIDHQ.wormhole/TID-SecureCI/scripts/install_gitleaks.sh)
- [scripts/install_osv_scanner.sh](/home/tangoisdown/LOTL/TIDHQ.NETWORK/TIDHQ.wormhole/TID-SecureCI/scripts/install_osv_scanner.sh)

Example:

```bash
bash scripts/clone_target_repo.sh https://github.com/your-org/your-app.git main ./target
bash scripts/install_gitleaks.sh
bash scripts/install_osv_scanner.sh
bash scripts/generate_sbom.sh ./target ./sbom
```

## Recommended Rollout

1. Put TID-SecureCI in a private repo.
2. Grant workflow access to your private app repos.
3. Add the caller workflow to one app repo.
4. Run with `enforce: false` for a few cycles.
5. Fix false positives and real issues.
6. Turn on `enforce: true`.
7. Add branch protection and require both `Secure Scan / secureci` and `Validate` before merge.
