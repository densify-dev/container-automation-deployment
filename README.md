# :no_entry: [DEPRECATED] Please see [Kubex automation controller helm chart](https://github.com/densify-dev/helm-charts/tree/master/charts/kubex-automation-controller)

<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://www.densify.com/wp-content/uploads/kubex-by-densify-logo-reverse.png">
    <source media="(prefers-color-scheme: light)" srcset="https://www.densify.com/wp-content/uploads/kubex-by-densify-logo.png">
    <img src="https://www.densify.com/wp-content/uploads/kubex-by-densify-logo.png" width="300">
</picture>

## Deprecation Notice

This repository is deprecated as of July 7th, 2025. Please refer to the [Kubex automation controller helm chart](https://github.com/densify-dev/helm-charts/tree/master/charts/kubex-automation-controller).

## Densify Container Automation - Mutating Admission Controller

This project enables Kubernetes users to automate pod resource configuration using Densify’s optimization engine via a Mutating Admission Controller.

## Quick Links

- [Densify Container Automation - Mutating Admission Controller](#densify-container-automation---mutating-admission-controller)
  - [Quick Links](#quick-links)
  - [Purpose](#purpose)
  - [Installation](#installation)
      - [1. Update config files](#1-update-config-files)
      - [2. Create densify-automation namespace](#2-create-densify-automation-namespace)
      - [3. Create a Persistent Volume Claim for the Mutating Admission Controller](#3-create-a-persistent-volume-claim-for-the-mutating-admission-controller)
      - [4. Configure TLS Certificates](#4-configure-tls-certificates)
      - [5. Run the deployment script](#5-run-the-deployment-script)
      - [6. Verify resources are up and running](#6-verify-resources-are-up-and-running)
  - [Argo CD Integration](#argo-cd-integration)
    - [Add Resource Customizations to argocd-cm](#add-resource-customizations-to-argocd-cm)
    - [How to Apply](#how-to-apply)
  - [Troubleshooting](#troubleshooting)

## Purpose

Automates the optimization of Kubernetes Pods based on Densify’s recommendations, ensuring resources are effectively allocated for better performance and cost efficiency.

  
![Alt Text](./documentation/Densify%20Mutating%20Admission%20Controller.png)


---


## Installation

#### 1. Update config files

For initial configuration, you need to review and update the following YAML files:

-  `densify-configmap.yaml`: Provide your Densify URL and Kubernetes Cluster name.

-  `densify-api-secret.yaml`: Provide your Densify base64-encoded username and password. To do this run: 
   ```bash
   echo -n "<my_user>" | base64
   echo -n "<my_password>" | base64
   ```

- `densify-automation-policy.yaml`:  
   - [Define or refine automation policies](./documentation/Multi-Policy-Support.md#supported-out-of-the-box-policies) — e.g., specify which resource values (CPU/Memory requests/limits) should be automated.  
   - [Set the default policy](./documentation/Multi-Policy-Support.md#default-policy-behavior) — applied when a webhook does not explicitly reference a specific policy.  
   - [Enable or disable automation cluster-wide](./documentation/Multi-Policy-Support.md#automationenabled) — acts as a global switch to turn on/off all mutations by the controller.  
   - [Control whether automation can be remotely enabled/disabled via the Densify UI](./documentation/Multi-Policy-Support.md#remoteenablement) — adds a second layer of dynamic control over policy activation.

- `densify-mutating-webhook-config.yaml`:  
   - [Define which pods are candidates for mutation](./documentation/Multi-Policy-Support.md#example-webhook-structure) — using `namespaceSelector` and `objectSelector`, specify which workloads should be mutated and which policy route (`/mutate/<policyName>`) to apply.
  

#### 2. Create densify-automation namespace

```bash
kubectl create namespace densify-automation
```

#### 3. Create a Persistent Volume Claim for the Mutating Admission Controller

To persist recommendation state and automation outputs, the Mutating Admission Controller requires a Persistent Volume Claim (PVC) with ReadWriteOnce access.

If deploying a single replica, no additional configuration is needed — most cluster default StorageClasses will work.

If deploying multiple replicas for high availability, you must ensure your PVC uses a backend that supports ReadWriteMany, such as Azure Files, EFS, or NFS.

You can use the provided example at: `deployment/base/densify-recommendations-pvc.yaml`


For detailed guidance, refer to: [Persistent Volume Claim Requirements](/documentation/PersistentVolumeClaim.md)


#### 4. Configure TLS Certificates

**Option 1.** [Use CertManager Certificate Generation and Management](/documentation/Certificates-CertManager.md)

**Option 2.** [Generate Certificates Manually](/documentation/Certificates-Manual.md)
  
**Option 3.** [Bring Your Own Certificates (BYOC)](/documentation/Certificates-BYOC.md)


#### 5. Run the deployment script

```bash
./deploy-kubex-automation.sh
```

#### 6. Verify resources are up and running

```bash
kubectl get pod -n densify-automation
```


## Argo CD Integration

If your Kubernetes cluster uses Argo CD, and you are enabling automated mutations via the Densify Mutating Admission Controller, you should configure Argo CD to ignore resource-related changes made by the controller.

This prevents:

- Applications from showing OutOfSync status unnecessarily.

- Infinite reconciliation loops when the Self-Heal flag is enabled.

### Add Resource Customizations to argocd-cm
Update the argocd-cm ConfigMap to ignore differences in container resource requests and limits for common workload types:

```bash
data:
  resource.customizations: |
    apps/Deployment:
      ignoreDifferences: |
        jqPathExpressions:
          - .spec.template.spec.containers[].resources.requests
          - .spec.template.spec.containers[].resources.limits
    apps/StatefulSet:
      ignoreDifferences: |
        jqPathExpressions:
          - .spec.template.spec.containers[].resources.requests
          - .spec.template.spec.containers[].resources.limits
    apps/DaemonSet:
      ignoreDifferences: |
        jqPathExpressions:
          - .spec.template.spec.containers[].resources.requests
          - .spec.template.spec.containers[].resources.limits
    argoproj.io/Rollout:
      ignoreDifferences: |
        jqPathExpressions:
          - .spec.template.spec.containers[].resources.requests
          - .spec.template.spec.containers[].resources.limits
```

### How to Apply
1. Edit the ConfigMap:

   ```bash
   kubectl edit configmap argocd-cm -n argocd
   ```

2. Add or merge the `resource.customizations` block under `data`.

3. Restart the Argo CD application controller:

   ```bash
   kubectl rollout restart deployment argocd-application-controller -n argocd
   ```
   
Once applied, Argo CD will ignore the mutations made by Densify and eliminate unnecessary sync errors and loops.

## Troubleshooting

For more guidance on troubleshooting the mutating admission controller, please refer to our [Troubleshooting Guide](/documentation/Troubleshooting.md)