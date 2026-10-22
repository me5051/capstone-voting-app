# Capstone Voting App — DevOps Project

A containerized voting application deployed to Amazon EKS using Terraform and Helm, with GitHub Actions for container image building, vulnerability scanning, and publishing to GitHub Container Registry (GHCR).

## Architecture

![Voting App Architecture](architecture.excalidraw.png)

### Application components

- **Vote:** Python web application for submitting votes.
- **Redis:** Queue for incoming votes.
- **Worker:** .NET service that processes votes and stores results.
- **PostgreSQL:** Database for processed votes.
- **Result:** Node.js web application displaying voting results.

## Technology Stack

- Docker and Docker Compose
- Kubernetes and Amazon EKS
- Terraform
- Helm
- GitHub Actions
- GitHub Container Registry (GHCR)
- Trivy vulnerability scanner

## Repository Structure

```text
.
├── .github/workflows/   # CI workflow
├── terraform/           # Terraform EKS configuration
├── voting-app/          # Helm chart
├── k8s-specifications/  # Kubernetes manifests
├── vote/                # Python voting service
├── result/              # Node.js results service
├── worker/              # .NET worker
├── docker-compose.yml
├── docker-stack.yml
└── architecture.excalidraw.png
```

## Run Locally with Docker Compose

Requirements: Docker and Docker Compose.

```bash
docker compose up --build
```

- Voting interface: http://localhost:8080
- Results interface: http://localhost:8081

Stop the application with `Ctrl+C`, then run `docker compose down` if needed.

## Infrastructure with Terraform

The `terraform/` directory contains the Terraform configuration for the Amazon EKS cluster.

The configuration uses the AWS provider in `eu-north-1`, the default VPC, and an EKS managed node group.

Validate the configuration:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
```

**Important:** Terraform state and saved plans are excluded from Git. AWS credentials must be configured securely before running Terraform commands that access AWS. Review the infrastructure and potential AWS costs before applying changes.

## Deploy with Helm

The `voting-app/` directory contains the Helm chart for the application and its supporting services.

Validate and render the chart:

```bash
helm lint voting-app
helm template voting-app ./voting-app --namespace voting-app
```

Deploy to an existing EKS cluster configured in `kubectl`:

```bash
kubectl create namespace voting-app --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install voting-app ./voting-app --namespace voting-app
kubectl get pods -n voting-app
```

The chart configures NodePort services for the vote and result applications. The configured ports are `31000` and `31001`; accessibility depends on the cluster networking and security rules.

## Continuous Integration

The GitHub Actions workflow at `.github/workflows/capstone-ci.yml`:

1. Builds the vote, result, and worker container images.
2. Scans images for HIGH and CRITICAL vulnerabilities using Trivy.
3. Publishes images to GHCR on pushes to `main`, tagged with the commit SHA.

The current workflow builds, scans, and publishes images. Automatic deployment from GitHub Actions to EKS must be configured and verified separately before claiming a complete build-scan-deploy pipeline.

## Rollback Demonstration

A Helm rollback was demonstrated by deploying an invalid vote image tag, observing the resulting image-pull failure, and rolling back to the previous release.

```bash
helm history voting-app -n voting-app
helm rollback voting-app 1 -n voting-app
kubectl get pods -n voting-app
```

The rollback restored the application pods to a healthy running state.

## Security Notes

- Do not commit AWS credentials, Kubernetes credentials, Terraform state, saved plans, or secret variable files.
- Review image vulnerability scan results before publishing or deploying.
- Use a secure approach for application credentials rather than committing real secrets in Helm values.
- Restrict public access to the EKS API endpoint where practical.

## Project Status

This project demonstrates container image CI, vulnerability scanning, image publishing, Terraform configuration validation, Helm deployment, and rollback.

The remaining capstone checks include verifying automatic deployment from GitHub Actions, reviewing secret exposure, and confirming that the infrastructure can be rebuilt from code.
