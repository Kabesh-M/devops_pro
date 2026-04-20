# DevOps End-to-End Workflow Project

This repository implements a complete DevOps workflow from development to monitoring.

## Included Deliverables

- Full GitHub-ready project structure
- Jenkins CI/CD pipeline (`Jenkinsfile`)
- Docker containerization (`Dockerfile`)
- Kubernetes deployment manifests (`kubernetes/`)
- Terraform infrastructure provisioning (`terraform/`)
- Monitoring stack assets for Prometheus and Grafana (`monitoring/`)
- Architecture diagram (`docs/architecture.md`)
- Production-ready static web page (`index.html`)

## Project Structure

- `index.html`: Static webpage deployed as the application.
- `nginx/default.conf`: Nginx route config for serving the site.
- `Dockerfile`: Builds runtime image with Nginx.
- `Jenkinsfile`: End-to-end CI/CD pipeline.
- `kubernetes/`: Namespace, deployment, service, ingress manifests.
- `terraform/`: AWS networking infrastructure IaC.
- `monitoring/`: Prometheus/Grafana setup and dashboards.
- `docs/architecture.md`: Architecture diagram.

## CI/CD Pipeline Stages

1. Checkout source
2. Build Docker image
3. Push image (optional)
4. Terraform provision (optional)
5. Kubernetes deploy (optional)
6. Monitoring stack deploy (optional)

### Jenkins Environment Flags

- `DOCKER_PUSH=true`: Enables image push to registry.
- `RUN_TERRAFORM=true`: Enables Terraform plan/apply.
- `RUN_K8S_DEPLOY=true`: Enables Kubernetes deployment.
- `RUN_MONITORING=true`: Enables Prometheus/Grafana deployment.

## Local Validation

### Build image

```bash
docker build -t devops-webapp:local .
```

### Run container

```bash
docker run --rm -p 3001:80 devops-webapp:local
```

Open `http://localhost:3001`.

## Kubernetes Deployment

Ensure `kubectl` points to your cluster and apply:

```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
```

Before applying deployment in production, replace `IMAGE_PLACEHOLDER` with your image reference.

## Terraform Provisioning

1. Copy example vars:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. Provision:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Monitoring Deployment

Install kube-prometheus-stack with Helm values:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/prometheus-values.yaml
kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/grafana-dashboard-configmap.yaml
```

## Notes

- Update Docker registry (`IMAGE_REPO`) and Jenkins credentials (`dockerhub-creds`) to match your environment.
- Terraform is currently configured for AWS VPC baseline provisioning.
- For production, use secure secrets management and least-privilege IAM roles.
