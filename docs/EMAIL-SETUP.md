# Email Setup (Proton)

TID-SecureCI emails the finished scan report (cover page + preface + numbered
sections, with the raw SARIF/SBOM files attached) on every run. This page covers
how and when to configure it.

## How email stays private

The workflow YAML contains **only placeholders** like `${{ secrets.smtp_password }}`.
No credential is ever written into the repository. The real values live in
GitHub's encrypted **Actions secrets** store, which is:

- never committed to git,
- encrypted at rest and masked in workflow logs,
- decrypted only at runtime inside the Action.

So the workflow is safe to push; the email credentials are configured separately
in GitHub settings. The `.gitignore` also blocks common secret files
(`.env`, `*.key`, `*token*`, etc.) from being committed by accident.

## Where to configure (pick one)

### Organization level — recommended

Set once and every repo that calls TID-SecureCI inherits it (the example caller
uses `secrets: inherit`).

`Org -> Settings -> Secrets and variables -> Actions -> New organization secret`

Then set **Repository access** to the repos allowed to scan.

### Repository level

`Repo -> Settings -> Secrets and variables -> Actions -> New repository secret`

## Secrets to set

| Secret | Required | Value (Proton) |
| --- | --- | --- |
| `smtp_server` | yes | `smtp.protonmail.ch` |
| `report_owner` | yes | your Proton business address (default recipient + BCC) |
| `smtp_username` | yes | your full Proton address |
| `smtp_password` | yes | your Proton **SMTP submission token** |
| `smtp_port` | no | `587` (default, STARTTLS) |
| `mail_from` | no | your Proton address (must match the token's address) |

Email only sends when both `smtp_server` and `report_owner` are set. If either is
missing, the email step is skipped and the rest of the scan runs unchanged.

### Via the GitHub CLI

The token is passed on the command line and never touches the repo:

```bash
gh secret set smtp_server   --org YOUR-ORG --body "smtp.protonmail.ch"
gh secret set smtp_port     --org YOUR-ORG --body "587"
gh secret set smtp_username --org YOUR-ORG --body "you@yourdomain.com"
gh secret set smtp_password --org YOUR-ORG --body "PROTON_SMTP_TOKEN"
gh secret set mail_from     --org YOUR-ORG --body "you@yourdomain.com"
gh secret set report_owner  --org YOUR-ORG --body "you@yourdomain.com"
```

Use `--repo OWNER/REPO` instead of `--org YOUR-ORG` for repo-level secrets.

## Generating the Proton SMTP token

Proton Bridge does **not** work in CI. Use Proton's **SMTP submission**, available
on paid Proton Mail / Business plans:

1. In Proton, open `Settings -> Mail -> IMAP/SMTP`.
2. Create an **SMTP submission token**.
3. Use that token as `smtp_password`, your full address as `smtp_username` and
   `mail_from`, and `smtp.protonmail.ch` as `smtp_server`.

All mail is sent **from** your Proton address regardless of recipient — which is
correct: TIDHQ delivers each report to whoever ran the scan.

## When it takes effect

Secrets apply on the **next workflow run** automatically. No rebuild, redeploy, or
code change is needed. Configure them any time before the run you want emailed.

## Who receives the report

- Each scan emails its report to the caller's `report_recipient` input.
- If `report_recipient` is unset, the report goes to `report_owner`.
- `report_owner` is BCC'd on every report from other callers, so you keep a copy.

## Scope note

A reusable workflow runs in the **caller's** context, so it can only read secrets
the caller's repo/org has. This means:

- Users **inside your GitHub org** -> org-level secrets cover everyone.
- Users in a **different org** -> they cannot use your Proton token via
  `secrets: inherit`, and you should not expose it to them. Supporting external
  users needs a separate hosted relay, not GitHub secrets.

## Glossary

- **SMTP** — Simple Mail Transfer Protocol, the standard for sending email.
- **SMTP submission** — sending mail through an authenticated SMTP server (port
  587 with STARTTLS, or 465 with implicit TLS). This is what CI uses.
- **SMTP submission token** — a Proton-issued password dedicated to SMTP sending.
  Proton Bridge does not work in CI, so this token is required.
- **STARTTLS** — upgrades a plaintext SMTP connection to an encrypted one; used on
  port 587.
- **`MAIL_FROM` / from address** — the envelope sender. Must be a full email
  address that matches the SMTP account (not a bare domain).
- **Actions secret** — an encrypted value stored in GitHub (org or repo level),
  decrypted only at runtime. Credentials live here, never in the repo.
- **`secrets: inherit`** — passes the caller's secrets into the reusable workflow
  so it can send mail.
- **`report_owner`** — the default recipient and the BCC address on every report.
- **`report_recipient`** — the per-scan address a report is delivered to.
- **BCC (blind carbon copy)** — a hidden copy recipient; used so the owner keeps a
  copy of every report.

See also the full glossary in [SCANNING-GUIDE.md](SCANNING-GUIDE.md#glossary).
