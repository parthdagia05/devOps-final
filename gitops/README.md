# GitOps with Argo CD

This directory configures automated Continuous Deployment (CD) using **Argo CD** following the GitOps paradigm:
* **Single Source of Truth**: The Git repository holds the entire desired state of the cluster.
* **Automated Sync**: Argo CD reconciles cluster drift automatically (`selfHeal: true`, `prune: true`).

## 1. Install Argo CD on kind Cluster
```bash
# Create argocd namespace
kubectl create namespace argocd

# Install Argo CD official stable release
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD server to become ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

## 2. Access the Argo CD Web UI
```bash
# Port-forward Argo CD UI to localhost:8080 or 8443
kubectl port-forward svc/argocd-server -n argocd 8443:443
```
* **URL**: https://localhost:8443
* **Username**: `admin`
* **Get Password**:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

## 3. Deploy Applications via GitOps
Apply the Application CRD:
```bash
kubectl apply -f gitops/application.yaml
```
Argo CD immediately detects the repository, syncs all manifests in `kubernetes/` into the `orders` namespace, and continuously monitors for Git commits!
