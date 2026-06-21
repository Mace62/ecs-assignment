#!/usr/bin/env bash
set -euo pipefail

# Build and push the app image to ECR, then optionally redeploy ECS.
# Run after: cd infra && terraform apply

AWS_REGION="${AWS_REGION:-eu-west-2}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
APP_DIR="${APP_DIR:-app}"
CLUSTER_NAME="${CLUSTER_NAME:-threatmod-ecs-cluster}"
SERVICE_NAME="${SERVICE_NAME:-threatmod-ecs-service}"
FORCE_ECS_DEPLOY="${FORCE_ECS_DEPLOY:-true}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INFRA_DIR="${REPO_ROOT}/infra"
APP_PATH="${REPO_ROOT}/${APP_DIR}"

cd "${INFRA_DIR}"

echo "==> Reading ECR URL from Terraform..."
ECR_URL="$(terraform output -raw ecr_repository_url)"

ECR_REGISTRY="${ECR_URL%%/*}"

echo "==> Logging Docker into ECR (${AWS_REGION})..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

echo "==> Building image from ${APP_PATH}..."
docker build -t "threatmod-ecr:${IMAGE_TAG}" "${APP_PATH}"

echo "==> Tagging and pushing ${ECR_URL}:${IMAGE_TAG}..."
docker tag "threatmod-ecr:${IMAGE_TAG}" "${ECR_URL}:${IMAGE_TAG}"
docker push "${ECR_URL}:${IMAGE_TAG}"

# if [[ "${FORCE_ECS_DEPLOY}" == "true" ]]; then
#   echo "==> Forcing ECS redeployment..."
#   aws ecs update-service \
#     --cluster "${CLUSTER_NAME}" \
#     --service "${SERVICE_NAME}" \
#     --force-new-deployment \
#     --region "${AWS_REGION}" \
#     --output text >/dev/null
#   echo "    Redeploy triggered on ${CLUSTER_NAME}/${SERVICE_NAME}"
# fi

echo "==> Done. Image pushed: ${ECR_URL}:${IMAGE_TAG}"
