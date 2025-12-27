
- **Big picture:** This is a Terraform-based IaC repo that provisions VPC, EKS, and ECR using a modular layout under `modules/`. Top-level composition is in `main.tf` which instantiates `modules/vpc`, `modules/eks`, and `modules/ecr`.

- **Key files:**
  - **Top-level composition:** [main.tf](main.tf) — shows how modules are wired together.
  - **Terraform config & backend:** [verson.tf](verson.tf) — contains `terraform {}` block, S3 backend, and the `kubernetes` provider configured to use `aws eks get-token`.
  - **Environment overrides:** [terraform.tfvars](terraform.tfvars) — environment-specific values (region override here).
  - **Modules:** `modules/vpc`, `modules/eks`, `modules/ecr` — each module follows the pattern `main.tf`, `variables.tf`, `output.tf`.

- **Why things are structured this way:**
  - Remote state is stored in an S3 backend (see `verson.tf`), so actions must be run with AWS credentials that can access that bucket.
  - The `kubernetes` provider is configured to use `aws eks get-token` which requires the AWS CLI available locally where `terraform` runs.
  - Community modules are used for VPC and EKS (see module `source` and `version` in `modules/*/main.tf`) to keep module code minimal and conventional.

- **Local prerequisites for running Terraform:**
  - Terraform >= 1.4 (declared in `verson.tf`).
  - AWS CLI installed and configured with credentials that can access the S3 backend and create resources.
  - Optional: `kubectl` when interacting with the created EKS cluster.

- **Common workflows / commands** (run from repo root):
  - `terraform init` (initializes, reads S3 backend from `verson.tf`).
  - `terraform plan -var-file=terraform.tfvars` (preview; uses `terraform.tfvars` for region values).
  - `terraform apply -var-file=terraform.tfvars` (apply changes).
  - `terraform fmt -recursive` and `terraform validate` before commits.
  - To get kubectl access after `apply`: use `aws eks update-kubeconfig --name <cluster-name>` or rely on the `kubernetes` provider already configured in `verson.tf` which uses `aws eks get-token`.

- **Important repo-specific notes / gotchas:**
  - The terraform block and kubernetes provider live in `verson.tf` (note filename). The provider's `exec` block runs `aws eks get-token` — Terraform will need the AWS CLI available and authenticated at runtime.
  - S3 backend bucket name is declared directly in `verson.tf` (`terraformbucketstatefileajay`). Be careful: altering backend settings requires `terraform init -reconfigure` and care with state migration.
  - `modules/eks/main.tf` enables `enable_irsa = true` and creates an IAM policy for ECR access; follow existing patterns when adding IRSA roles or policies.
  - `modules/ecr` configures repositories with `image_scanning_configuration.scan_on_push = true` and `image_tag_mutability = "IMMUTABLE"` — new repos should follow these defaults unless a conscious change is intended.

- **Module authoring conventions:**
  - New modules should expose variables in `variables.tf`, core resources in `main.tf`, and outputs in `output.tf`.
  - Module outputs are consumed at the top level as `module.<name>.<output>` (examples: `module.vpc.vpc_id`, `module.ecr.repository_url`).

- **When modifying providers or adding resources:**
  - Keep provider configuration stable in `verson.tf`. If you must change the backend, document the migration steps and run `terraform init -reconfigure`.
  - If adding resources that require AWS CLI interaction (e.g., eks token or kubectl exec), ensure the README and CI (if any) are updated to install/enable those tools.

- **CI / automation hints:**
  - CI must supply AWS credentials with access to the S3 backend and required IAM permissions for resource creation.
  - If adding automation that depends on the `kubernetes` provider, ensure the CI environment includes the AWS CLI and a mechanism to authenticate (OIDC, static creds, or role assumption).

- **Where to look for examples in this repo:**
  - Module wiring: [main.tf](main.tf)
  - Backend + provider nuances: [verson.tf](verson.tf)
  - ECR conventions: [modules/ecr/main.tf](modules/ecr/main.tf) and [modules/ecr/output.tf](modules/ecr/output.tf)

