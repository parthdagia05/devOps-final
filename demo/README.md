# Demo

| File | Contents |
|---|---|
| [`OrderSystem-DevSecOps.pdf`](OrderSystem-DevSecOps.pdf) | Slide deck (PDF) |
| [`OrderSystem-DevSecOps.pptx`](OrderSystem-DevSecOps.pptx) | Slide deck (PowerPoint, with speaker notes) |
| `presentation.mp4` | Recorded presentation and live walkthrough |

## Walkthrough order

1. Slides: what was built and the architecture
2. Codebase: folder structure and key files
3. CI/CD: push a commit and follow the GitHub Actions run end to end
4. Terraform: `terraform plan`, then the VPC and EKS cluster in the AWS Console
5. Argo CD: `order-system` and `monitoring` apps Synced and Healthy
6. Kubernetes: `kubectl get pods,svc,ingress -n orders`
7. Prometheus: Status → Targets with both services UP
8. Grafana: Order Service Dashboard with live traffic
