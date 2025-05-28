# Create a Persistent Volume Claim (PVC) for the Mutating Admission Controller

To persist recommendations and automation outputs, configure a Persistent Volume Claim (PVC) for the Mutating Admission Controller pod.

---

## Storage Overview

By default, your Kubernetes cluster will use the default StorageClass to fulfill PVC requests. This typically provisions storage using a backend like Azure Disks, AWS EBS, or GCP PD, depending on your cloud provider.


## Access Mode Requirements
The Mutating Admission Controller requires a volume with ReadWriteOnce (RWO) access mode. This allows the pod to read from and write to the volume when mounted to a single node.

| Access Mode      | Description                                            | Suitable for               |
|------------------|--------------------------------------------------------|-----------------------------|
| `ReadWriteOnce`  | Mount as read-write by a **single node**              | Most environments |
| `ReadWriteMany`  | Concurrent read/write by **multiple nodes**           | For high availability / multiple replicas    |


**Note**: If you plan to run multiple replicas of the Mutating Admission Controller for high availability, ensure your PVC uses a storage backend that supports ReadWriteMany. Examples include Azure Files, Amazon EFS, or NFS.

If your default StorageClass does not support ReadWriteMany, you may need to define a custom StorageClass.

## Capacity

- **Recommended starting capacity:** `1Gi`
- Adjust based on automation output size and data retention policies.

---

## Mount Path

- **Inside the pod:** `/densify/data`

Ensure that the volume is mounted to this path via your pod’s `volumeMounts` configuration.

---

## PVC Naming

Ensure the PVC name matches the one referenced in the Deployment of the Mutating Admission Controller.

- **Default PVC name:** `densify-recommendations-pvc`

---

## PVC Binding Verification

To check if the PVC is properly bound to the PV, run:

```bash
kubectl get pvc -n densify-automation
```

You should see output like:
```bash
NAME                            STATUS      ...
densify-recommendations-pvc     Bound       ...
```