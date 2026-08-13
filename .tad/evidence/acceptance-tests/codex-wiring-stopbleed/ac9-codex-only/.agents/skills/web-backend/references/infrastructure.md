# Infrastructure Rules

Seven judgment rules for Kubernetes, infrastructure-as-code, logging, job processing,
and shutdown behavior.

---

**Rule 1: Set CPU requests always; set CPU limits only in multi-tenant clusters**

Kubernetes CPU requests are used by the scheduler for pod placement. Without a CPU
request, the pod is placed in the `BestEffort` QoS class and is the first evicted
under node pressure.

CPU limits, however, are implemented via CFS (Completely Fair Scheduler) bandwidth.
Setting a CPU limit equal to or close to the CPU request causes **immediate throttling**
when the pod bursts — even when there is spare capacity on the node.

```yaml
# WRONG: CPU limit equals request (causes instant throttling on burst)
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "500m"    # throttles as soon as pod uses 500m, even if node has 4 CPU free
    memory: "512Mi"

# RIGHT: multi-tenant cluster — set CPU limit higher than request (headroom for burst)
resources:
  requests:
    cpu: "250m"
    memory: "512Mi"
  limits:
    cpu: "1000m"   # 4× headroom
    memory: "512Mi"

# RIGHT: single-tenant cluster — omit CPU limit entirely
resources:
  requests:
    cpu: "250m"
    memory: "512Mi"
  limits:
    memory: "512Mi"  # memory limit always required (OOM kill is better than swap death)
```

- If multi-tenant cluster (shared nodes with multiple teams): set CPU limit ≥ 2× request
- If single-tenant cluster: omit CPU limit, set memory limit only
- Never omit memory limit — memory exhaustion kills the node, not just the pod
- If production workload: set `requests.memory == limits.memory` (Guaranteed QoS class)
  to prevent pod eviction under node memory pressure. Burstable QoS (`requests < limits`)
  is acceptable only for non-critical / batch workloads.

[Source: Sairyss/backend-best-practices — Kubernetes; Kubernetes best practices documentation]

---

**Rule 2: Never install ArgoCD via kubectl or Helm — use a hosted instance**

Self-managed ArgoCD is a high-privilege target: it has credentials to deploy to all
clusters it manages. A misconfigured or outdated self-managed ArgoCD instance is
a vector for cluster-wide compromise.

```bash
# WRONG: installing ArgoCD into a cluster it will manage
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# RIGHT: use a hosted GitOps service
# Options: Akuity (hosted ArgoCD), Argo CD Cloud, GitLab CI/CD, GitHub Actions + kubectl
```

If you must self-manage (air-gapped environment, compliance requirement):
- Deploy to a dedicated management cluster, not the application cluster
- Enable SSO, disable anonymous access, restrict the admin account
- Subscribe to ArgoCD CVE notifications and patch within 48 hours

[Source: Sairyss/backend-best-practices — GitOps; ArgoCD security hardening guide]

---

**Rule 3: Prefer `for_each` over `count` in Terraform**

`count` creates indexed resources (`resource[0]`, `resource[1]`). If an item is
removed from the middle of the list, Terraform re-indexes and destroys/recreates
all subsequent resources. `for_each` keys resources by a stable identifier.

```hcl
# WRONG: count — removing "us-west-2" destroys and recreates "eu-west-1"
variable "regions" {
  default = ["us-east-1", "us-west-2", "eu-west-1"]
}
resource "aws_s3_bucket" "data" {
  count  = length(var.regions)
  bucket = "app-data-${var.regions[count.index]}"
}

# RIGHT: for_each — stable keys, safe to remove individual items
resource "aws_s3_bucket" "data" {
  for_each = toset(["us-east-1", "us-west-2", "eu-west-1"])
  bucket   = "app-data-${each.key}"
}
```

Exception: `count` is acceptable for creating N identical resources where no item
will ever be removed independently (e.g., `count = var.replica_count`).

[Source: Sairyss/backend-best-practices — Terraform; HashiCorp Terraform Best Practices]

---

**Rule 4: Never put provider configuration in reusable Terraform modules**

Provider blocks in a module force every consumer to use the same provider version
and credentials strategy. This makes the module impossible to use in multi-region
or multi-account deployments.

```hcl
# WRONG: module contains provider block
# modules/s3-bucket/main.tf
provider "aws" {
  region = "us-east-1"  # hardcoded in module — consumers cannot override
}

# RIGHT: provider is only in root modules (the calling code)
# modules/s3-bucket/main.tf — no provider block
resource "aws_s3_bucket" "this" { ... }

# environments/prod/main.tf
provider "aws" {
  region = var.aws_region  # caller controls region
}
module "data_bucket" {
  source = "../../modules/s3-bucket"
}
```

[Source: HashiCorp Terraform documentation — Module Composition; Sairyss/backend-best-practices]

---

**Rule 5: Write logs to stdout/stderr in JSON format — not to files**

Log files require log rotation configuration, disk space management, and sidecar
containers for collection. The 12-Factor App methodology defines the correct
approach: treat logs as an event stream and write to stdout.

```typescript
// If Node.js: pino (fastest, JSON by default)
import pino from 'pino';
const log = pino({ level: process.env.LOG_LEVEL ?? 'info' });
log.info({ userId: '123', orderId: '456' }, 'Order created');

// Output: {"level":30,"time":1234567890,"userId":"123","orderId":"456","msg":"Order created"}
```

```python
# If Python: structlog
import structlog
log = structlog.get_logger()
log.info("order_created", user_id="123", order_id="456")
```

```go
// If Go: zerolog
import "github.com/rs/zerolog/log"
log.Info().Str("userId", "123").Str("orderId", "456").Msg("Order created")
```

Every log entry must include: `timestamp`, `level`, `message`, and at minimum
`request_id` or `trace_id` for correlation. `console.log(string)` without
structured fields is not acceptable in production.

[Source: 12-Factor App — Factor XI; Sairyss/backend-best-practices — Observability]

---

**Rule 6: Use non-blocking background jobs by default — return 202 Accepted**

Any operation that takes > 500ms should not block the HTTP response. The client
should receive an immediate acknowledgment, then poll or receive a webhook when
the work is complete.

```http
# Request
POST /reports/generate
Content-Type: application/json
{"reportType": "monthly", "userId": "123"}

# Immediate response (< 50ms)
HTTP/1.1 202 Accepted
Location: /reports/jobs/job-uuid-123

# Client polls (or receives webhook)
GET /reports/jobs/job-uuid-123
→ {"status": "processing", "progress": 60}
→ {"status": "complete", "resultUrl": "/reports/results/uuid"}
```

```typescript
// If Node.js: BullMQ for job queue
const queue = new Queue('report-generation');
await queue.add('generate', { userId, reportType });
return res.status(202).json({ jobId: job.id });
```

[Source: Sairyss/backend-best-practices — Async Processing; zalando/restful-api-guidelines — Asynchronous Jobs]

---

**Rule 7: Implement graceful shutdown in the correct sequence**

Abrupt process termination (SIGKILL, unhandled SIGTERM) drops in-flight requests,
leaves database transactions open, and creates inconsistent state in message queues.

The correct shutdown sequence:

**Kubernetes readiness gap**: The pod is removed from Service endpoints AFTER SIGTERM
is sent, not before. Without a propagation delay, kube-proxy on other nodes may still
route connections to the pod for 1-3s → connection refused. Add a pre-stop sleep:

```yaml
lifecycle:
  preStop:
    exec:
      command: ["sh", "-c", "sleep 10"]  # wait for endpoint removal to propagate
```

```typescript
// If Node.js
process.on('SIGTERM', async () => {
  // Step 0: sleep is handled by preStop hook above (K8s) or add here for non-K8s
  // Step 1: Stop accepting new connections
  server.close();

  // Step 2: Wait for in-flight requests to complete (with timeout)
  await waitForActiveRequests(10_000); // 10s timeout

  // Step 3: Drain job queues
  await jobQueue.close();

  // Step 4: Close database connections
  await pool.end();

  // Step 5: Exit cleanly
  process.exit(0);
});
```

```python
# If Python: FastAPI / uvicorn lifespan
@asynccontextmanager
async def lifespan(app: FastAPI):
    yield  # startup
    # shutdown: close connections in reverse order of opening
    await db_pool.close()
    await redis_client.close()
```

In Kubernetes: set `terminationGracePeriodSeconds` ≥ your shutdown timeout + 5s
buffer. Default is 30s; increase if your job drain takes longer.

```yaml
spec:
  terminationGracePeriodSeconds: 60
```

[Source: Sairyss/backend-best-practices — Graceful Shutdown; Kubernetes documentation — Pod Lifecycle]
