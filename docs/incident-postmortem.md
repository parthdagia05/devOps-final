# Incident Postmortem: INC-2026-1016

**Incident Summary**: Order Service Pod Crashes and Degraded Availability  
**Date**: 2026-10-16  
**Severity**: Sev-1 (Major)  
**Impact**: Customer order submissions failed intermittently for 12 minutes.  
**Author / Incident Lead**: Parth Dagia  

---

## 1. Timeline of Events (UTC)

* **11:00**: Automated deployment triggered for `order-service:1.1`.
* **11:02**: Prometheus alert `OrderServiceDown` fired: `up{job="order-service"} == 0`.
* **11:04**: On-call engineer acknowledged alert and began triage via `kubectl get pods -n orders`.
* **11:05**: Two pods observed with status `CrashLoopBackOff` (restart count = 4).
* **11:06**: Engineer ran `kubectl logs <pod-name> -n orders --previous` and identified missing database credentials environment variable.
* **11:08**: `kubectl describe pod` revealed secret key mismatch in `01-secret.yaml`.
* **11:10**: Fixed secret manifest and applied patch: `kubectl apply -f kubernetes/01-secret.yaml`.
* **11:12**: Pods transitioned to `1/1 Running`.
* **11:14**: Synthetic POST /api/orders request returned HTTP 201 Created. Incident resolved.

---

## 2. Root Cause Analysis (5 Whys)

1. **Why did the pods crash?**  
   The Spring Boot application threw a fatal runtime exception during context initialization: `HikariPool-1 - Exception during pool initialization: password cannot be null`.
2. **Why was the database password null?**  
   The container environment variable `SPRING_DATASOURCE_PASSWORD` was unbound.
3. **Why was it unbound?**  
   The secret reference in `04-order-service.yaml` referenced key `db_pass` while `01-secret.yaml` contained `password`.
4. **Why wasn't this caught in CI?**  
   The CI pipeline tested unit tests with mock in-memory dependencies but lacked end-to-end integration manifest validation.
5. **Why was there discrepancy between configs?**  
   Manual manifest editing occurred without Helm template linting.

---

## 3. Preventive Action Items

| Action Item | Type | Owner | Status |
| :--- | :--- | :--- | :--- |
| Enforce Helm linting and `dry-run=client` in GitHub Actions CI | Prevention | DevOps | Completed |
| Add Gitleaks and Trivy security scanning gates | Detection | Security | Completed |
| Implement K8s Liveness and Readiness probes on Actuator endpoints | Mitigation | Core Eng | Completed |
| Add Prometheus alerting rule for pod crash loops | Monitoring | DevOps | Completed |
