
# Densify Container Automation - Mutating Admission Controller

## Quick Links
- [Densify Container Automation - Mutating Admission Controller](#densify-container-automation---mutating-admission-controller)
  - [Quick Links](#quick-links)
  - [Purpose](#purpose)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
      - [1. Create a new namespace](#1-create-a-new-namespace)
      - [2. Configure TLS Certificates](#2-configure-tls-certificates)
      - [3. Create a Persistent Volume for the Mutating Admission Controller](#3-create-a-persistent-volume-for-the-mutating-admission-controller)
      - [4. Update the following YAMLs if not done already:](#4-update-the-following-yamls-if-not-done-already)
      - [5. Deploy using Kustomize:](#5-deploy-using-kustomize)
      - [6. Restart the deployment](#6-restart-the-deployment)

## Purpose

Automates the optimization of Kubernetes Pods based on Densify’s recommendations, ensuring resources are effectively allocated for better performance and cost efficiency.

  
![Alt Text](./Documentation/Densify%20Mutating%20Admission%20Controller.png)


---

  

## Prerequisites
 

**1. Kubernetes Cluster Analysis**:

Ensure your Kubernetes Cluster has been analyzed by **Densify**.

**2. Persistent Volume**

You must set up a Persistent Volume (PV) using shared storage to support the functionality of the mutating admission controller in the Kubernetes cluster. See [installation step](#3-create-a-persistent-volume-for-the-mutating-admission-controller)  for more details.

**3. Pod Label Requirement**:

Pods requiring automation must have the label: `densify-automation = "true"`

**4. Required Configurations**:

For initial configuration, you need to review and update the following YAML files:

-  `cluster-info.yaml`: Specify the Kubernetes Cluster name.

-  `densify-configmap.yaml`: Provide the customer’s Densify URL.

-  `densify-api-secret.yaml`: Provide Densify base64-encoded username and password.

-  `densify-automation-policy.yaml`: Define the automation policy (e.g., resources to automate).
  
  

---

  

## Installation

  

#### 1. Create a new namespace

```bash
kubectl  create  namespace  densify-automation
```

 
#### 2. Configure TLS Certificates

**Option 1.** [Use CertManager Certificate Generation and Management](/Documentation/Certificates-CertManager.md)

**Option 2.** [Generate Certificates Manually](/Documentation/Certificates-Manual.md)
  
**Option 3.** [Bring Your Own Certificates (BYOC)](/Documentation/Certificates-BYOC.md)

  

#### 3. Create a Persistent Volume for the Mutating Admission Controller

For a multi-node cluster, follow the steps provided here: [Create a PV using Shared Storage](/Documentation/PersistentVolume.md)

For testing on a single node cluster, you can leverage the `Deployment/densify-recommendations-pv.yaml` file to create the PV. Please make sure you uncomment the line in `kustomization.yaml` file.


#### 4. Update the following YAMLs if not done already:
-  `cluster-info.yaml`: Specify the Kubernetes Cluster name.

-  `densify-configmap.yaml`: Provide the customer’s Densify URL.

-  `densify-api-secret.yaml`: Provide Densify base64-encoded username and password.

-  `densify-automation-policy.yaml`: Define the automation policy (e.g., resources to automate).
  

#### 5. Deploy using Kustomize:

```bash
kubectl  apply  -k  .
```

#### 6. Restart the deployment

```bash
kubectl  rollout  restart  deployment  densify-webhook-server  -n  densify-automation
```