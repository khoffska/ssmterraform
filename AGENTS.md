# AGENTS.md — ssmterraform

Context for AI coding agents (Claude Code, Codex, opencode, Cursor, …) working in this repo.
Read this first; keep it current.

## What this is
A small, **legacy/experiment** Terraform root module (last touched 2022-08) that wires up the
"SSM patch / maintenance window" pattern for an EC2 fleet: an SSM maintenance window + target,
IAM roles for SNS notifications and the maintenance window, SNS topics with an email
subscription, an S3 "patchinstaller" bucket, and an example EC2 tag. It has no backend, no
provider pin, no CI, and is not wired to any workspace — treat it as parked reference code.

## Layout
- `main.tf` — IAM roles/policies/instance profile, SNS topic + subscription, S3 bucket, SSM
  maintenance window + target, EC2 tag example.
- `variables.tf` — `instance_id`, `company_name`, `schedule` (required); `droplet_names`,
  `create_droplet` are unused.
- `Terraform.gitignore` — standard Terraform ignores. `.gitattributes` — line-ending normalization.

## Commands
No build/test/lint tooling in-repo (no `versions.tf`, no backend, no `.github/workflows`), and
nothing here can be run without touching AWS. Don't apply it.

## Conventions / rules (workspace-wide)
- **Terraform is applied via GitHub Actions only — never run `terraform apply` locally.** This
  repo has no pipeline; if it is ever revived, add an OIDC workflow (role `github-actions-oidc-role`)
  rather than applying by hand.
- **No inline JSON in HCL.** New/edited IAM/trust policies and any dashboard bodies go in
  separate `.json` files and are referenced with `file()`/`templatefile()`.
- PR workflow: feature branch → PR (plan-only) → merge to `main` applies.

## Gotchas
- The existing code violates the "no inline JSON" rule — `assume_role_policy` and policy bodies
  are heredoc JSON blocks inside `main.tf`. Refactor to `.json` files if you touch them.
- `droplet_names` / `create_droplet` are copy-pasted DigitalOcean leftovers and are unused here.
- Hardcoded names to be aware of: bucket `${var.company_name}-patchinstaller`, SSM window
  `maintenance-window-webapp`, and an email endpoint on the SNS subscription.
- No provider pin and no backend, so state would be local unless a backend is added. Do not
  create state locally — follow the workspace default (`emr-demo-state-zxcvzxcv23`, key
  `ssmterraform/terraform.tfstate`) if this is ever brought into CI.
