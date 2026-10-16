# GitOps with Argo CD

The cluster's desired state lives in this repository. Argo CD watches it and keeps the cluster in sync:
* **Single source of truth**: every change to the cluster goes through a Git commit.
* **Automated sync**: `prune: true` removes resources deleted from Git, `selfHeal: true` reverts manual `kubectl edit` drift.

## Layout

```
gitops/
├── app-of-apps.yaml        # Root Application, watches gitops/apps/
└── apps/
    ├── order-system.yaml   # Syncs kubernetes/  -> namespace orders
    └── monitoring.yaml     # Syncs monitoring/  -> namespace monitoring
```

Adding a new file to `gitops/apps/` is enough for Argo CD to start managing a new application.

## Deployment flow

1. A commit is pushed to `main`.
2. GitHub Actions builds, tests and scans the code, then pushes `ghcr.io/parthdagia05/<service>:<commit sha>`.
3. The `update-manifests` job commits the new tag into `kubernetes/*.yaml` and `helm/order-service/values.yaml`.
4. Argo CD sees the new commit and rolls out the new image.

## 1. Install Argo CD

`scripts/bootstrap-kind.sh` does all of this in one go. Manually:

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.4/manifests/install.yaml
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
```

## 2. Access the Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8443:443
```
* **URL**: https://localhost:8443
* **Username**: `admin`
* **Password**:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

## 3. Deploy the applications

```bash
kubectl apply -f gitops/app-of-apps.yaml
kubectl get applications -n argocd
```

`order-system` and `monitoring` should both reach `Synced` / `Healthy`. Health depends on ingress-nginx (Ingress gets an address) and metrics-server (HPA can read CPU), both installed by the bootstrap script.
