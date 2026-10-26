# Narration script

Record in one take. Pause about 3 seconds between sections. Don't read the headings.

## 1. Intro
Hi, I'm Parth Dagia, and this is my DevSecOps capstone: OrderSystem, a cloud-native order platform shipped through a complete DevSecOps pipeline.

## 2. What I built
I built two Spring Boot microservices, a seven-job CI/CD pipeline with three security scanners, and AWS infrastructure across two availability zones, all managed from Git.

## 3. Architecture
Here's the architecture. Code lives in GitHub. GitHub Actions builds, tests and scans it, then pushes images to the GitHub Container Registry, tagged with the commit SHA. Argo CD syncs the Kubernetes cluster. Inside it, the ingress routes to the order service, which checks stock with the inventory service and stores orders in Postgres. Prometheus and Grafana monitor everything.

## 4. Application layer
The order service handles the orders API, and the inventory service answers stock checks. Both expose health probes and Prometheus metrics, and both are built as multi-stage Docker images.

## 5. CI/CD pipeline
Five checks run in parallel: build and test against a real Postgres, Gitleaks, a Trivy filesystem scan, Helm lint and Terraform validate. Then each image is built, scanned and pushed, and the last job commits the new image tag back to Git.

## 6. Security
Security is built into the pipeline: secret scanning, dependency and infrastructure scanning, image scanning, actions pinned to commit SHAs, and a least-privilege token.

## 7. GitOps
Delivery is pure GitOps. CI never touches the cluster directly. It only changes Git, and Argo CD pulls the change. A root app-of-apps manages the order system and monitoring applications, with prune and self-heal turned on.

## 8. Kubernetes
On Kubernetes, the deployments have startup, readiness and liveness probes, resource requests and limits, a horizontal pod autoscaler, an NGINX ingress, config maps, secrets, and a persistent volume for Postgres.

## 9. Terraform
Terraform provisions the AWS side: a VPC across two zones with public and private subnets, a NAT gateway, an EKS cluster with a managed node group in the private subnets, and a private RDS Postgres database.

## 10. Observability
For observability, Prometheus scrapes both services every five seconds and evaluates alert rules, and Grafana comes with a provisioned dashboard.

## 11. Problems I fixed
Along the way I fixed some real problems: tests that needed a database in CI, EKS nodes with no route to the internet, an Argo CD sync error, and pods stuck in a restart loop while the JVM was starting.

## 12. Into the demo
Now let's walk through it live.

## 13. Codebase
This is the repository. The application folder has both services. The kubernetes folder has the manifests Argo CD syncs, monitoring has Prometheus and Grafana, gitops has the Argo CD applications, terraform has the AWS code, and the workflow file defines the whole pipeline.

## 14. Push
Now I'll push a commit to main, which triggers the GitHub Actions pipeline.

## 15. GitHub Actions
Here's the pipeline running end to end. Build and test, Gitleaks, Trivy, Helm lint and Terraform validate run in parallel. Then come the Docker build and image scan for both services, and finally the job that updates the image tags in Git. Every job is green.

## 16. Terraform plan
Next, Terraform. The format check and validate both pass, and terraform plan shows the twenty-five resources it will create: the VPC, subnets, internet and NAT gateways, route tables, IAM roles, the EKS cluster and node group, and the RDS database.

## 17. AWS Console (skip unless you record the AWS Console yourself)
And here in the AWS Console are the VPC and the EKS cluster that Terraform created.

## 18. Argo CD
This is Argo CD. The root application, the order system and monitoring are all synced and healthy, deployed straight from the Git repository.

## 19. Argo CD app view
Inside the order system app, we can see every resource Argo CD manages: the deployments, services, ingress, autoscaler, config map, secret and the Postgres volume.

## 20. kubectl
From the command line, all the pods are running and ready, the services and ingress are up, and the autoscaler is reading CPU metrics.

## 21. Prometheus
On the Prometheus targets page, the order service, the inventory service and Prometheus itself are all up.

## 22. Grafana
And here's the Grafana dashboard with live application metrics: service status, JVM heap usage, request rate by endpoint, and error count.

## 23. Outro
That's the full platform, from git push to running, monitored pods. Thank you for watching.
