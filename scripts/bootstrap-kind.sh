#!/usr/bin/env bash
# Creates the kind cluster, installs the add-ons the app depends on,
# then hands everything else to Argo CD (app-of-apps).
set -euo pipefail

INGRESS_NGINX_VERSION="controller-v1.15.1"
METRICS_SERVER_VERSION="v0.9.0"
ARGOCD_VERSION="v3.5.4"

cd "$(dirname "$0")/.."

if ! kind get clusters | grep -qx orders; then
  kind create cluster --config cluster/kind-config.yaml
fi
kubectl config use-context kind-orders

echo "==> ingress-nginx"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/kind/deploy.yaml"

echo "==> metrics-server (needed by the HPA)"
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
# kind kubelets use self-signed certs
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

echo "==> Argo CD"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo "==> Root application (app-of-apps)"
kubectl apply -f gitops/app-of-apps.yaml

echo
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
echo "UI: kubectl port-forward svc/argocd-server -n argocd 8443:443  ->  https://localhost:8443"
