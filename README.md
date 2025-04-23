
# Densify Container Automation - Mutating Admission Controller

This project enables Kubernetes users to automate pod resource configuration using Densify’s optimization engine via a Mutating Admission Controller.

## Quick Links

- [Densify Container Automation - Mutating Admission Controller](#densify-container-automation---mutating-admission-controller)
  - [Quick Links](#quick-links)
  - [Purpose](#purpose)
  - [Installation](#installation)
      - [1. Update config files](#1-update-config-files)
      - [2. Create a Persistent Volume for the Mutating Admission Controller](#2-create-a-persistent-volume-for-the-mutating-admission-controller)
      - [3. Configure TLS Certificates](#3-configure-tls-certificates)
      - [4. Deploy using Kustomize:](#4-deploy-using-kustomize)

## Purpose

Automates the optimization of Kubernetes Pods based on Densify’s recommendations, ensuring resources are effectively allocated for better performance and cost efficiency.

  
![Alt Text](./Documentation/Densify%20Mutating%20Admission%20Controller.png)


---


## Installation

#### 1. Update config files

For initial configuration, you need to review and update the following YAML files:

-  `cluster-info.yaml`: Specify the Kubernetes Cluster name.

-  `densify-configmap.yaml`: Provide your Densify URL.

-  `densify-api-secret.yaml`: Provide your Densify base64-encoded username and password.

- `densify-automation-policy.yaml`:  
   - [Define or refine automation policies](./Documentation/Multi-Policy-Support.md#supported-out-of-the-box-policies) — e.g., specify which resource values (CPU/Memory requests/limits) should be automated.  
   - [Set the default policy](./Documentation/Multi-Policy-Support.md#default-policy-behavior) — applied when a webhook does not explicitly reference a specific policy.  
   - [Enable or disable automation cluster-wide](./Documentation/Multi-Policy-Support.md#automationenabled) — acts as a global switch to turn on/off all mutations by the controller.  
   - [Control whether automation can be remotely enabled/disabled via the Densify UI](./Documentation/Multi-Policy-Support.md#remoteenablement) — adds a second layer of dynamic control over policy activation.

- `densify-mutating-webhook-config.yaml`:  
   - [Define which pods are candidates for mutation](./Documentation/Multi-Policy-Support.md#example-webhook-structure) — using `namespaceSelector` and `objectSelector`, specify which workloads should be mutated and which policy route (`/mutate/...`) to apply.
  

#### 2. Create a Persistent Volume for the Mutating Admission Controller

For a multi-node cluster, follow the steps provided here: [Create a PV using Shared Storage](/Documentation/PersistentVolume.md)

For testing on a single node cluster, you can leverage the `Deployment/densify-recommendations-pv.yaml` file to create the PV. Please make sure you uncomment the line in `kustomization.yaml` file.


#### 3. Configure TLS Certificates

**Option 1.** [Use CertManager Certificate Generation and Management](/Documentation/Certificates-CertManager.md)

**Option 2.** [Generate Certificates Manually](/Documentation/Certificates-Manual.md)
  
**Option 3.** [Bring Your Own Certificates (BYOC)](/Documentation/Certificates-BYOC.md)


#### 4. Deploy using Kustomize:

```bash
kubectl  apply  -k  .
```