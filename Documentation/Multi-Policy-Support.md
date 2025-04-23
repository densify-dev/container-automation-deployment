# Multi-Policy Support

## Overview
This document provides guidance on how to create multiple Kubernetes `MutatingWebhookConfiguration` entries targeting different policies within a single mutating admission controller. Each webhook entry can point to a specific `/mutate/` path, allowing different optimization or mutation logic to be applied based on namespaces, labels, or other resource selectors.

> **Note:**  
> This design involves two key configuration files:  
> - `densify-mutation-webhook-config.yaml`: Defines the MutatingWebhookConfiguration with multiple `/mutate/` paths and selectors.  
> - `densify-automation-policy.yaml`: Defines the named optimization policies and controller-wide flags used when handling incoming mutations.


## Purpose
By defining multiple webhooks with distinct rules and expressions, you can:
- Apply different optimization policies per environment (production, staging, test).
- Target only specific workloads using object selectors.
- Route requests to different logic within the webhook server using unique paths (e.g., `/mutate/cpu-reclaim`).


## Global Configuration Flags
In the `densify-automation-policy.yaml` file, you’ll find two important global switches that govern controller behavior:

### `automationenabled`
- **Type:** `boolean`
- **Default:** `true`
- **Purpose:** Globally enables or disables the mutation logic for the controller.
- **Behavior:**
  - If set to `false`, the controller will skip applying any automation policies—even if webhook rules match.
  - If set to `true`, the controller is active and will apply policies as defined in the `policiesbyname` section or via `defaultpolicy`.

**Use Case:** Temporarily disable automation cluster-wide for maintenance without editing webhook configurations.

### `remoteenablement`
- **Type:** `boolean`
- **Default:** `false`
- **Purpose:** Controls whether the automation toggle can be influenced remotely through external configuration or via Densify UI.
- **Behavior:**
  - If `false`, automation decisions rely **only** on the webhook definition and local `densify-automation-policy.yaml` content.
  - If `true`, remote signals (e.g., user toggles from Densify UI) can override local automation behavior and enable/disable automation dynamically per namespace or workload.

**Use Case:** Integrate centralized control over which namespaces or resources are optimized via UI toggles or external API calls.

---


## Default Policy Behavior
If the webhook `clientConfig.path` is set to `/mutate` **without specifying a policy path** (e.g., `/mutate` instead of `/mutate/cpu-reclaim`), the controller applies the `defaultpolicy`  defined in the `densify-automation-policy.yaml`.

For example:
```yaml
- name: resource-optimizer-default.densify.com
  clientConfig:
    path: "/mutate"
```
The controller will refer to:
```yaml
defaultpolicy: cpu-reclaim
```
And apply the `cpu-reclaim` logic.

## Supported Out-of-the-Box Policies
The following resource optimization policies are defined in `densify-automation-policy.yaml` and referenced by webhooks in `densify-mutation-webhook-config.yaml`.

### 1. `cpu-reclaim`
- **Description:** Reclaims CPU requests only.
- **Behavior:**
  - Downsizes CPU requests.
  - Leaves memory untouched.
  - No risk of hitting quota, limit range, or node size constraints.

### 2. `cpu-mem-reclaim`
- **Description:** Reclaims CPU and Memory requests.
- **Behavior:**
  - Downsizes CPU requests.
  - Downsizes Memory requests.
  - Avoids upsizing to prevent quota issues.

### 3. `full-request-management`
- **Description:** Optimizes all resource request values.
- **Behavior:**
  - Upsizes and downsizes CPU and Memory requests.
  - Sets uninitialized request values.
  - **Note:** Requires careful quota consideration.

### 4. `limit-oom-prevention`
- **Description:** Bumps up memory limits to prevent OOM kills.
- **Behavior:**
  - Upsizes Memory limits.
  - **Note:** Confirm sufficient quota.

### 5. `limit-oom-throttling-prevention`
- **Description:** Bumps up CPU and Memory limits to relieve throttling and pressure.
- **Behavior:**
  - Upsizes CPU and Memory limits.
  - **Note:** Confirm sufficient quota.

### 6. `full-limit-management`
- **Description:** Ensures all limits are properly set and not too low.
- **Behavior:**
  - Upsizes CPU and Memory limits.
  - Sets uninitialized limits.

### 7. `full-optimization`
- **Description:** Automates all request and limit values.
- **Behavior:**
  - Upsizes and downsizes CPU and Memory requests and limits.
  - Sets uninitialized values.
  - **Note:** Confirm sufficient quota.

The `defaultpolicy` is set to `cpu-reclaim` if no specific policy is defined.

## Example Webhook Structure
Each webhook entry contains:
- `clientConfig.path`: Defines the policy route the controller uses for processing (e.g., `/mutate/cpu-reclaim`).
- `namespaceSelector` and `objectSelector`: Control the scope of resources each webhook applies to.

---

## Sample Webhook Entries Explained

### 1. **Production - CPU Reclaim Policy**
```yaml
- name: resource-optimizer-prod.densify.com
  clientConfig:
    path: "/mutate/cpu-reclaim"
  namespaceSelector:
    matchLabels:
      environment: "prod"
  objectSelector:
    matchLabels:
      densify-automation: "true"
```

### 2. **Staging/Demo - Full Request Management Policy**
```yaml
- name: resource-optimizer-all.densify.com
  clientConfig:
    path: "/mutate/full-request-management"
  namespaceSelector:
    matchExpressions:
      - key: kubernetes.io/metadata.name
        operator: In
        values: ["staging", "demo"]
  objectSelector:
    matchLabels:
      densify-automation: "true"
```

### 3. **Test/Bulk Workload - CPU & Memory Reclaim**
```yaml
- name: resource-optimizer-test.densify.com
  clientConfig:
    path: "/mutate/cpu-mem-reclaim"
  objectSelector:
    matchExpressions:
      - { key: tier, operator: Exists }
      - { key: env, operator: NotIn, values: ["production", "prod"] }
      - { key: workload-type, operator: In, values: ["batch", "transactional"] }
```

## Writing Expressions for Fine-Grained Control

### Namespace Selector Examples
```yaml
namespaceSelector:
  matchLabels:
    environment: "prod"

namespaceSelector:
  matchExpressions:
    - key: kubernetes.io/metadata.name
      operator: In
      values:
        - staging
        - demo
```

### Object Selector Examples
```yaml
objectSelector:
  matchLabels:
    densify-automation: "true"

objectSelector:
  matchExpressions:
    - { key: tier, operator: Exists }
    - { key: env, operator: NotIn, values: ["production", "prod"] }
    - { key: workload-type, operator: In, values: ["batch", "transactional"] }
```

## Valid Operators for Match Expressions
- **In**
- **NotIn**
- **Exists**
- **DoesNotExist**
- **Gt** (Greater than)
- **Lt** (Less than)

Example:
```yaml
matchExpressions:
  - key: memory
    operator: Gt
    values: ["500Mi"]
```

## Benefits of Multi-Webhook Design
- Fine-grained control over which workloads get mutated
- Flexible policies based on environment and workload type
- Scalable webhook server with clean separation of logic per `/mutate/` path
- Easier debugging and auditing of resource changes

## Example Use Cases for Future Extensions
| Policy Path                             | Purpose                                          | Target                            |
|-----------------------------------------|--------------------------------------------------|------------------------------------|
| /mutate/cpu-reclaim                     | CPU limits/request adjustments                   | Production workloads               |
| /mutate/full-request-management         | Full CPU/Memory resource management              | Staging, Demo                      |
| /mutate/cpu-mem-reclaim                 | Aggressive CPU & Memory reclaim                  | Batch/Transactional workloads      |
| /mutate/limit-oom-prevention            | Memory limit bump to prevent OOM kills           | High memory apps                   |
| /mutate/limit-oom-throttling-prevention | CPU/Mem limit bump to prevent throttling         | Latency-sensitive workloads        |
| /mutate/full-limit-management           | Ensure all limits have values and are not too low| General workloads                  |
| /mutate/full-optimization               | Apply full request & limit optimizations         | Production if quota allows         |
| /mutate                                 | Applies the `defaultpolicy` defined in ConfigMap | Any workload without explicit path |

## Conclusion
By structuring multiple webhook rules within the same `MutatingWebhookConfiguration`, users gain significant flexibility to manage resource optimization policies across different Kubernetes environments and workload types. Each webhook can point to a specific policy path or default to the `defaultpolicy`, giving your mutating admission controller a modular and scalable design.