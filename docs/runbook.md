# Production Operations Runbook: Order System

This runbook provides on-call engineers with standard operating procedures (SOPs) for diagnosing, triaging, and resolving common Kubernetes cluster incidents.

---

## 1. Fast Diagnostic Triage Workflow

Whenever an alert fires or a pod fails:

```bash
# 1. Check all pods across namespaces
kubectl get pods -A

# 2. Inspect pods in the orders namespace with wide details (IPs, Nodes)
kubectl get pods -n orders -o wide

# 3. Inspect Pod lifecycle events (THE most critical debugging command)
kubectl describe pod <pod-name> -n orders

# 4. Read active container logs
kubectl logs <pod-name> -n orders

# 5. Read previous crashed container logs (if pod restarted)
kubectl logs <pod-name> -n orders --previous
```

---

## 2. Playbooks for Common Failure Modes

### 🚨 Incident 1: Pod in `CrashLoopBackOff`
* **Symptoms**: Pod status displays `CrashLoopBackOff`, restart count increments continuously.
* **Root Causes**:
  1. Application threw an unhandled runtime exception on startup (e.g., database connection failure).
  2. Wrong entrypoint or missing environment variable.
* **Resolution Steps**:
  1. Inspect the crash log:
     ```bash
     kubectl logs <pod-name> -n orders --previous
     ```
  2. Check exit code:
     * `Exit Code 1`: General application error / Java startup exception.
     * `Exit Code 137`: Process killed by SIGKILL (OOM or manual kill).
     * `Exit Code 143`: Graceful shutdown by SIGTERM.
  3. Validate environment variables and configuration:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep -A 10 "Environment:"
     ```

---

### 🚨 Incident 2: Pod in `ImagePullBackOff` / `ErrImagePull`
* **Symptoms**: Pod fails during `ContainerCreating`.
* **Root Causes**:
  1. Typo in image name or tag.
  2. Image exists locally in host Docker but was not loaded into kind (`kind load docker-image`).
  3. Image registry authentication failure (missing `imagePullSecrets`).
* **Resolution Steps**:
  1. View pull events:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep -A 10 "Events:"
     ```
  2. Fix: Correct image tag in deployment YAML, or load image into kind:
     ```bash
     kind load docker-image order-service:<tag> --name orders
     ```

---

### 🚨 Incident 3: Pod Stuck in `Pending`
* **Symptoms**: Pod never enters `Running` or `ContainerCreating`.
* **Root Causes**:
  1. `FailedScheduling`: No worker node has sufficient CPU/memory requested by the pod.
  2. Missing PersistentVolumeClaim or storage provisioner issue.
  3. Taints and tolerations or node affinity mismatch.
* **Resolution Steps**:
  1. Check scheduler events:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep "FailedScheduling"
     ```
  2. Check node capacity and utilization:
     ```bash
     kubectl top nodes
     kubectl describe nodes
     ```
  3. Adjust pod `resources.requests` in the Deployment manifest to fit node capacity.

---

### 🚨 Incident 4: Pod `OOMKilled` (Exit Code 137)
* **Symptoms**: Pod restarts abruptly with exit code `137` and reason `OOMKilled`.
* **Root Causes**:
  1. Memory consumption exceeded `resources.limits.memory`.
  2. JVM heap configuration (`-Xmx`) was set higher than container memory limit.
* **Resolution Steps**:
  1. Confirm OOM status:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep -E "OOMKilled|Exit Code"
     ```
  2. Increase container memory limit in Deployment manifest:
     ```yaml
     resources:
       limits:
         memory: "1Gi"
     ```
  3. Configure JVM ergonomics for container cgroups:
     ```bash
     -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0
     ```

---

### 🚨 Incident 5: Pod `0/1 Running` (Readiness Probe Failure)
* **Symptoms**: Container runs without crashing, but pod stays `0/1` and Service routes 0 traffic.
* **Root Causes**:
  1. Wrong probe path (e.g. `/actuator/health` instead of `/actuator/health/readiness`).
  2. Probe timeout too short or downstream dependency (Postgres) is unhealthy.
* **Resolution Steps**:
  1. Check readiness probe failure events:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep "Readiness probe failed"
     ```
  2. Port-forward directly to the pod to test the endpoint:
     ```bash
     kubectl port-forward <pod-name> -n orders 8080:8080
     curl -i http://localhost:8080/actuator/health/readiness
     ```

---

### 🚨 Incident 6: `CreateContainerConfigError`
* **Symptoms**: Container creation blocked before execution.
* **Root Causes**:
  1. Referenced `Secret` or `ConfigMap` does not exist in the same namespace.
  2. Specified key inside `secretKeyRef` or `configMapKeyRef` is misspelled.
* **Resolution Steps**:
  1. Inspect error in events:
     ```bash
     kubectl describe pod <pod-name> -n orders | grep "Error:"
     ```
  2. List available secrets in the namespace:
     ```bash
     kubectl get secrets,configmaps -n orders
     ```
