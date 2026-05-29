# Project Bedrock — InnovateMart EKS Deployment

## Architecture Overview
Production-grade microservices deployment on Amazon EKS for InnovateMart Inc.

## Live Store URL
http://k8s-retailap-retailst-17d19cf248-914102784.us-east-1.elb.amazonaws.com

## Infrastructure Summary
| Resource | Value |
|---|---|
| EKS Cluster | project-bedrock-cluster |
| VPC | project-bedrock-vpc (vpc-0ec7411aa27944ea6) |
| Region | us-east-1 |
| Kubernetes Version | v1.34 |
| Assets Bucket | bedrock-assets-alt-soe-025-4612 |

## Prerequisites
- AWS CLI v2 configured with admin credentials
- Terraform >= 1.9.8
- kubectl >= 1.28
- Helm >= 3.0
- Git

## How to Deploy

### 1. Clone the repository
```bash
git clone https://github.com/Modebola-A/project-bedrock.git
cd project-bedrock
```

### 2. Create terraform.tfvars
```bash
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Create remote state bucket
```bash
aws s3api create-bucket \
  --bucket project-bedrock-tfstate-106143845072 \
  --region us-east-1
```

### 4. Deploy infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 5. Configure kubectl
```bash
aws eks update-kubeconfig \
  --name project-bedrock-cluster \
  --region us-east-1
```

### 6. Deploy the application
```bash
kubectl apply -f k8s/retail-store.yaml
kubectl apply -f k8s/ingress.yaml
```

### 7. Get the store URL
```bash
kubectl get ingress retail-store-ingress -n retail-app
```

## CI/CD Pipeline
- **Pull Request** triggers terraform plan, posts output as PR comment
- **Merge to main** triggers terraform apply

### Required GitHub Secrets
| Secret | Description |
|---|---|
| AWS_ACCESS_KEY_ID | AWS access key |
| AWS_SECRET_ACCESS_KEY | AWS secret key |
| AWS_REGION | us-east-1 |
| DB_PASSWORD | RDS database password |
| DB_USERNAME | RDS database username |

## Application Architecture
| Service | Image | Database |
|---|---|---|
| UI | retail-store-sample-ui:1.0.0 | — |
| Catalog | retail-store-sample-catalog:1.0.0 | RDS MySQL |
| Cart | retail-store-sample-cart:1.0.0 | DynamoDB |
| Orders | retail-store-sample-orders:1.0.0 | RDS PostgreSQL |
| Checkout | retail-store-sample-checkout:1.0.0 | Redis (in-cluster) |
| RabbitMQ | rabbitmq:3-management | in-cluster |
| Redis | redis:7-alpine | in-cluster |

## Developer Access (bedrock-dev-view)
Credentials are stored securely in AWS Secrets Manager:

```bash
aws secretsmanager get-secret-value \
  --secret-id project-bedrock-cluster/dev-user/credentials \
  --query SecretString \
  --output text
```

| Credential | Value |
|---|---|
| Console URL | https://106143845072.signin.aws.amazon.com/console |
| Username | bedrock-dev-view |
| Console Password | Stored in Secrets Manager |
| Access Key ID | Stored in Secrets Manager |
| Secret Access Key | Stored in Secrets Manager |

### Verify RBAC access
```bash
# This should work (read-only)
kubectl get pods -n retail-app

# This should fail (no write access)
kubectl delete pod -n retail-app <any-pod>
```

## Serverless — S3 + Lambda
- **Bucket:** bedrock-assets-alt-soe-025-4612
- **Lambda:** bedrock-asset-processor
- **Trigger:** Any file upload to bucket invokes Lambda
- **Lambda logs:** CloudWatch /aws/lambda/bedrock-asset-processor

### Test Lambda trigger
```bash
aws s3 cp any-file.jpg s3://bedrock-assets-alt-soe-025-4612/test.jpg
```

## Resource Tags
All resources tagged with: `Project: karatu-2025-capstone`

## Student Information
- **Student ID:** ALT/SOE/025/4612
- **Project:** Project Bedrock
- **Cohort:** Karatu 2025 — Third Semester
