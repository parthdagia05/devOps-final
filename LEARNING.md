# DevOps Mastery & Exam Quick Reference Guide

**Author**: Parth Dagia  
**Project**: Order System (Microservices + PostgreSQL + Kubernetes + DevSecOps + GitOps)  
**Target**: Scaler DevOps Exam & Production Engineering  

---

## 1. Linux Terminal Commands (For Exam MCQs)

| Command | Purpose | Real Exam Example |
| :--- | :--- | :--- |
| `cat <path>` | Read file contents to terminal | `cat data1/data2/data.txt` |
| `ls -la` | List all files including hidden (`.`), with permissions & sizes | `ls -la /var/log` |
| `grep -r "pattern" .` | Recursively search for string in directory | `grep -r "SPRING_DATASOURCE" .` |
| `find . -name "*.yaml"`| Search for files by name/extension | `find kubernetes/ -name "*.yaml"` |
| `cp -r <src> <dest>` | Copy file or directory recursively | `cp -r kubernetes/ backup/` |
| `mv <old> <new>` | Move or rename file/folder | `mv old-app.jar app.jar` |
| `rm -r <dir>` | Remove directory recursively | `rm -r target/` |
| `chmod +x <file>` | Add execute permission to script | `chmod +x mvnw` |
| `curl -i -X POST <url>` | Test HTTP APIs with response headers | `curl -i http://localhost:8080/api/orders` |
| `ps aux` | List all running processes on the OS | `ps aux \| grep java` |
| `kill -9 <pid>` | Force kill process (SIGKILL, exit code 137) | `kill -9 1234` |

### Linux Process Exit Codes
* **`0`**: Success / clean exit.
* **`1`**: General failure / unhandled error.
* **`137`**: `128 + 9 (SIGKILL)` — Process killed abruptly by OS kernel (Out Of Memory / OOM killer).
* **`143`**: `128 + 15 (SIGTERM)` — Graceful container shutdown signal sent by Kubernetes before eviction.

---

## 2. Docker & Containerization

### RUN vs. ENTRYPOINT vs. CMD
* **`RUN`**: Executes during the **image build** step (e.g., `RUN ./mvnw package`). Creates a new cached layer.
* **`ENTRYPOINT`**: The fixed executable running when the **container boots** (e.g., `ENTRYPOINT ["java", "-jar", "app.jar"]`).
* **`CMD`**: Default arguments passed to `ENTRYPOINT`, which can be overridden by `docker run <image> [cmd]`.

### Multi-Stage Dockerfile & Layer Caching
* **JDK stage vs. JRE stage**: Compile code with a full JDK (~500MB), then copy *only* the compiled JAR into a lightweight JRE (~160MB). Drastically reduces production attack surface and container size.
* **Layer Caching Rule**: Copy files that change least frequently first (`pom.xml`, `.mvn/`), run `dependency:go-offline`, and only then copy application source code (`src/`).

### Docker Compose
* **DNS Resolution**: Containers communicate via service names defined in `docker-compose.yml` (e.g. `jdbc:postgresql://postgres:5432/orderdb`).
* **Volume Persistence**: Named volumes (`orders-db-data`) preserve database data across `docker compose down` and `docker compose up`. Use `docker compose down -v` to wipe data.

---

## 3. Kubernetes Architecture

### Control Plane (The Brain)
1. **`kube-apiserver`**: The front-end API gateway. All `kubectl` commands talk here.
2. **`etcd`**: Distributed key-value store holding cluster state and configuration.
3. **`kube-scheduler`**: Assigns unscheduled Pods to suitable Worker Nodes based on resource requests and affinities.
4. **`kube-controller-manager`**: Runs controllers (Deployment, ReplicaSet, Endpoints) to ensure actual state matches desired state.

### Worker Node (The Muscle)
1. **`kubelet`**: The node agent that communicates with the control plane, starts containers via containerd, and reports pod health.
2. **`containerd`**: The container runtime executing the images.
3. **`kube-proxy`**: Manages network routing and IP tables on the node for Service communication.

---

## 4. Kubernetes Objects & Networking

### Service Types
* **`ClusterIP` (Default)**: Exposes the service on a cluster-internal IP. Accessible *only* from within the cluster.
* **`NodePort`**: Exposes the service on each Node's IP at a static port (30000–32767).
* **`LoadBalancer`**: Provisions a cloud provider load balancer (e.g., AWS NLB/ALB) and routes external traffic to the service.

### ConfigMap vs. Secret
* **ConfigMap**: Stores non-confidential configuration in plaintext (e.g., database URLs, port numbers).
* **Secret**: Stores sensitive data (e.g., passwords, API keys).
  * *Important*: Kubernetes Secrets are **base64 encoded**, NOT encrypted at rest by default!
  * `stringData` allows writing plain text in manifests; Kubernetes base64-encodes it automatically on save.

### Probes: Liveness vs. Readiness
* **Readiness Probe**: "Is the pod ready to receive user traffic?"
  * If it fails: Pod IP is removed from the Service Endpoints. The container is **NOT restarted**.
* **Liveness Probe**: "Is the container still healthy and not deadlocked?"
  * If it fails: Kubelet **kills and restarts** the container.

---

## 5. Kubernetes Debugging Drill Playbook (High Exam Weight)

| Error Status | Primary Root Cause | Diagnostic Command | Remediation |
| :--- | :--- | :--- | :--- |
| **`CrashLoopBackOff`** | App exits immediately with fatal error or missing config | `kubectl logs <pod> --previous` | Fix application crash / database connection config |
| **`ImagePullBackOff`** | Typo in image name/tag, or image not loaded into kind | `kubectl describe pod <pod>` | Correct tag, or run `kind load docker-image <img:tag> --name <cluster>` |
| **`Pending`** | Insufficient CPU/memory on nodes; PVC unbound | `kubectl describe pod <pod>` (Events) | Lower `resources.requests` or expand cluster nodes |
| **`OOMKilled` (137)** | Process allocated more memory than `limits.memory` | `kubectl describe pod <pod>` | Increase `limits.memory` or configure JVM `-XX:MaxRAMPercentage` |
| **`0/1 Running`** | Readiness probe failing (HTTP 404/500 or timeout) | `kubectl describe pod <pod>` | Fix probe path in manifest to match Actuator endpoint |
| **`CreateContainerConfigError`**| Pod references non-existent Secret or ConfigMap key | `kubectl describe pod <pod>` | Create the missing Secret or fix the `secretKeyRef` key name |

---

## 6. DevSecOps & CI/CD Security Gates

* **SAST (Static Application Security Testing)**: Scans source code for security flaws without executing it (e.g., CodeQL, SonarQube).
* **SCA (Software Composition Analysis)**: Scans open-source libraries in `pom.xml` for known CVEs (e.g., Trivy filesystem scan, OWASP Dependency Check).
* **Secret Scanning**: Scans git commit history for leaked credentials and API tokens (e.g., Gitleaks).
* **Container Image Scanning**: Scans built Docker images for OS and library CVEs before pushing to registry (e.g., Trivy image scan).

---

## 7. Helm Package Management

* **`Chart.yaml`**: Chart metadata (name, version, description).
* **`values.yaml`**: Configurable default values.
* **`templates/`**: YAML templates injected with values via Go templating engine.
* **Key Commands**:
  * `helm lint <chart-path>`: Validate syntax and structure.
  * `helm install <release> <chart-path> -n <ns>`: Deploy chart.
  * `helm upgrade <release> <chart-path> -n <ns>`: Apply changes.
  * `helm rollback <release> <revision> -n <ns>`: Revert to previous good revision.

---

## 8. GitOps with Argo CD

* **Declarative**: Cluster state is entirely described in Git.
* **Reconciliation Loop**: Argo CD continuously compares desired state in Git against live state in Kubernetes.
* **Self-Healing**: If someone manually edits a pod or service with `kubectl edit`, Argo CD detects the drift and immediately overwrites it with the Git declaration.

---

## 9. Terraform & Infrastructure as Code (AWS)

* **Terraform Workflow**:
  1. `terraform init`: Downloads provider plugins (e.g., AWS provider).
  2. `terraform fmt & validate`: Checks formatting and syntax validity.
  3. `terraform plan`: Generates execution plan showing what resources will be created/changed (`+`, `~`, `-`).
  4. `terraform apply`: Provisions real cloud infrastructure.
  5. `terraform destroy`: Tears down infrastructure.
* **State File (`terraform.tfstate`)**: Maps real-world cloud resources to your configuration. In production, stored remotely in an S3 bucket with DynamoDB state locking.
