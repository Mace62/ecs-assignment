# Threat Composer on AWS ECS

Production deployment of [AWS Threat Composer](https://github.com/aws/threat-composer) as a containerised React SPA, hosted on **ECS Fargate** behind an **Application Load Balancer**, with HTTPS via **ACM** and DNS in **Route 53**.

**Live URL:** [https://tm.sameh-labs.com](https://tm.sameh-labs.com)  
**Health check:** [https://tm.sameh-labs.com/health](https://tm.sameh-labs.com/health) → `{"status":"ok"}`

| Item | Value |
|------|--------|
| AWS region | `eu-west-2` |
| Domain | `tm.sameh-labs.com` (zone: `sameh-labs.com`) |
| ECS cluster | `threatmod-ecs-cluster` |
| ECS service | `threatmod-ecs-service` |
| ECR repository | `threatmod-ecr` |

---

## Overview

This project follows the **ClickOps → destroy → IaC** learning path:

1. **ClickOps** — Manual first deployment via the AWS Console ([documented in `docs/ClickOps/README.md`](docs/ClickOps/README.md)), then torn down.
2. **Terraform** — The same architecture rebuilt as modular IaC under `infra/`.
3. **CI/CD** — GitHub Actions builds the Docker image, scans it, pushes to ECR, applies infrastructure changes, and deploys to ECS using **OIDC** (no long-lived AWS keys).

The runtime image is a **multi-stage Docker build**: Node builds the React app, Go embeds the static assets and serves them (including SPA routing and `/health`), and **distroless** runs the final container as non-root on port **8080**.

Application releases are owned by the pipeline. Terraform owns infrastructure skeleton; ECS task definition image updates are ignored after initial provisioning so deploy workflows can roll out new images without plan drift.

---

## Architecture

![Architecture diagram](docs/Architecture%20Diagram.svg)

> **AZ layout:** ALB spans **both** public subnets. ECS service is registered in **both** private subnets.

**Traffic flow**

1. Client resolves `tm.sameh-labs.com` → Route 53 alias → ALB.
2. HTTP (`:80`) redirects to HTTPS (`:443`).
3. ALB forwards to Fargate tasks on **8080**; target group health check hits `/health`.
4. Go server serves the embedded React build; unknown paths fall back to `index.html`.

---

## Design decisions

This stack targets a **single dev environment**, not a reusable multi-account platform. The choices below are deliberate for an assignment/personal lab; production would parameterise and harden several of them.

1. **Minimal root variables** — `infra/variables.tf` is empty. Region, VPC CIDR, domain, AZs, and resource names are fixed in module code or module-level defaults (e.g. `tm.sameh-labs.com`, `10.0.0.0/22`, `eu-west-2a/b`). That keeps the repo easy to review and apply without `tfvars` indirection. Production would use root variables and per-environment `*.tfvars`.

2. **Bootstrap vs main stack (separate state)** — GitHub OIDC and the CI IAM role live in `infra/bootstrap/` with state at `bootstrap/terraform.tfstate`. The application infrastructure lives in `infra/` with state at `dev/terraform.tfstate`. CI needs the role before it can apply main infra; bootstrap is also excluded from the `terraform.yml` workflow so an infra apply cannot modify OIDC.

3. **Terraform owns skeleton; GitHub Actions owns releases** — Terraform provisions the ECS cluster, service, and initial task definition. `lifecycle { ignore_changes }` on `container_definitions` and the service’s `task_definition` stops every image push from causing plan drift. The deploy workflow registers new task definitions and updates the service instead.

4. **`desired_count = 1`** — One Fargate task keeps dev cost down. The service is still registered across both private subnets for AZ flexibility; production would run multiple tasks (and often auto scaling).

5. **Dedicated `security` module** — ALB and ECS security groups live together because the ECS ingress rule references the ALB security group by ID. That cross-reference is easier to manage in one module than split across ALB and ECS modules.

6. **ECR `force_delete = true`** — Allows `terraform destroy` to remove the repository even when images remain. Convenient for dev/teardown; production would typically set this to `false`.

7. **Execution role only (no ECS task role)** — Tasks use `threatmod-ecs-execution-role` to pull from ECR and write logs. There is no separate task role because the app serves static content and does not call AWS APIs at runtime.

8. **S3 state bucket created outside Terraform** — `threatmod-tfstate` must exist before remote state works (chicken-and-egg). The bucket is created manually or via the console before the first bootstrap apply; both stacks then reference it in their backend blocks.

9. **Single NAT Gateway** — One NAT in **eu-west-2a** only; private subnets in both AZs route `0.0.0.0/0` through it. That reduces hourly NAT and data-processing cost while developing. Production would use **one NAT per AZ**, each private subnet routing to its local NAT, so an AZ outage does not break outbound traffic from tasks in the surviving AZ and you avoid cross-AZ NAT charges.

---

## Repository structure

```
├── app/                        # Threat Composer source + Dockerfile
│   ├── Dockerfile              # Node build → Go embed → distroless runtime
│   └── server/                 # Go static file server + /health
├── infra/                      # Main Terraform stack (S3 state: dev/)
│   ├── bootstrap/              # One-time GitHub OIDC + IAM (separate state)
│   └── modules/
│       ├── networking/         # VPC, subnets, IGW, NAT
│       ├── security/           # ALB + ECS security groups
│       ├── ecr/
│       ├── acm/                # Certificate + DNS validation
│       ├── alb/
│       ├── ecs/
│       └── dns/                # App alias record
├── docs/
│   ├── Architecture Diagram.svg
│   └── ClickOps/               # Manual deployment write-up + screenshots
└── .github/workflows/
    ├── build.yml               # Build, Grype scan, push to ECR
    ├── deploy.yml              # ECS deploy + post-deploy health check
    └── terraform.yml           # fmt, validate, plan, apply (infra/)
```

---

## Prerequisites

- AWS account with permissions to create VPC, ECS, ALB, ECR, Route 53, and IAM resources
- A **Route 53 hosted zone** for your domain (e.g. `sameh-labs.com`)
- **Terraform** >= 1.5, **Docker**, **AWS CLI v2**
- **GitHub** repository with Actions enabled
- S3 bucket for remote state: `threatmod-tfstate` (created manually or via console before first bootstrap apply)

---

## Reproduction guide

### 1. Bootstrap — GitHub OIDC (once per account)

Creates the GitHub OIDC provider and IAM role used by all workflows.

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars   # edit org/repo/region
terraform init
terraform apply
terraform output -raw role_arn
```

Add the role ARN to GitHub → **Settings → Secrets → Actions** as `AWS_ROLE_ARN`.

### 2. Main infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Or trigger **Terraform - Apply Infrastructure** in GitHub Actions (push to `main` with `infra/**` changes, or `workflow_dispatch` with **Run terraform apply** checked).

State backend: `s3://threatmod-tfstate/dev/terraform.tfstate`.

### 3. CI/CD pipelines

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI - Build and Push to ECR** | Push to `main` (`app/**`) or manual | Docker build, Grype scan (high+), push `:sha` + `:latest` |
| **CD - Deploy to ECS** | After successful CI on `main` | Register task definition, update service, curl `/health` |
| **Terraform - Apply Infrastructure** | Push to `main` (`infra/**`) or manual | `fmt`, `validate`, `plan`, `apply` |

Typical release flow:

```text
app change → build.yml → deploy.yml → https://tm.sameh-labs.com/health
infra change → terraform.yml
```

### 4. Local build and test

```bash
# Build and run locally
docker build -t threatmod:test app/
docker run --rm -p 8080:8080 threatmod:test

curl http://localhost:8080/health
curl -I http://localhost:8080/
```

---

## Security notes

- **OIDC** — Workflows assume `github-actions-ecs-deploy`; no static `AWS_ACCESS_KEY_ID` in GitHub.
- **Least privilege** — Bootstrap attaches separate policies for ECR/ECS deploy and Terraform; bootstrap itself is not managed by the CI Terraform workflow.
- **Container** — Distroless runtime, non-root (UID 65532), no shell; Grype gate on CI (`severity-cutoff: high`).
- **Network** — ECS tasks in private subnets; only the ALB is internet-facing. ECS accepts traffic on 8080 from the ALB security group only.

---

## Screenshots

### Live application

Threat Composer running at [https://tm.sameh-labs.com](https://tm.sameh-labs.com):

![Threat Composer live at tm.sameh-labs.com](docs/screenshots/app-working.png)

### ClickOps (manual deployment)

Step-by-step write-up and console screenshots are in [`docs/ClickOps/README.md`](docs/ClickOps/README.md).

### CI/CD (GitHub Actions)

| Pipeline                | Screenshot                                                        |
|-------------------------|-------------------------------------------------------------------|
| Build and push          | ![Build Success](docs/screenshots/build-success.png)              |
| Deploy to ECS           | ![Deploy Success](docs/screenshots/deploy-success.png)            |
| Terraform apply         | ![Terraform Success](docs/screenshots/terraform-success.png)      |

---

## Useful links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Threat Composer](https://github.com/aws/threat-composer)

---

## License

Application source is based on [AWS Threat Composer](https://github.com/aws/threat-composer) (Apache 2.0).
