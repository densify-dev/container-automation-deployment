
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

-  `densify-automation-policy.yaml`: 
   -  [Define/Refine the automation policies](./Documentation/Multi-Policy-Support.md#supported-out-of-the-box-policies) (e.g., resources to automate).
   -  [Define which policy will be your default policy](./Documentation/Multi-Policy-Support.md#default-policy-behavior) This will be used in case you have not explicitly specified the policy to be used by a webhook definition.
   -  [Global switch to enable/disable automation within the cluster](./Documentation/Multi-Policy-Support.md)
   -  Define if you would like to control automation enablement within Kubernetes cluster only or add a secondary level of control from Densify UI

- `densify-mutating-webhook-config.yaml`: [Provide definition of which pods will be candidates for mutation by the mutating webhook and which policy should be used](./Documentation/Multi-Policy-Support.md#example-webhook-structure)
  

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