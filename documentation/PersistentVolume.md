# Create a Persistent Volume (PV) for the Mutating Admission Controller

To persist recommendations and automation outputs, configure a Persistent Volume (PV) and Persistent Volume Claim (PVC) for the Mutating Admission Controller pod.

---

## Storage Solution Options

You can choose between **local node-based storage** and **shared network storage**, depending on your cluster topology and operational requirements.

### 1. Shared Storage (Recommended for Production, Multi-node Clusters)

Use a networked storage backend such as:

- **Amazon EFS**
- **Azure Files**
- **NFS**
- **Google Cloud Filestore**

These storage options allow concurrent access from multiple nodes and support the `ReadWriteMany` access mode.

> ✅ **Best for:** Highly available, multi-node Kubernetes clusters  
> ⚠️ **Note:** Requires support for `ReadWriteMany` in your CSI driver and storage backend.

### 2. Local Node Storage (`hostPath`)

For testing, single-node clusters, or when customers resist using `ReadWriteMany`, `hostPath` volumes can be used.

This requires:

- Access mode: `ReadWriteOnce`
- Pods to be **scheduled on the same node** using `nodeSelector` or `affinity` rules

> ⚠️ **Caveat:** Pods can only access the volume from the **node where the path exists**. Not suitable for multi-node deployments without strict scheduling constraints.

---

## 📥 Access Modes

| Access Mode      | Description                                            | Suitable for               |
|------------------|--------------------------------------------------------|-----------------------------|
| `ReadWriteOnce`  | Mount as read-write by a **single node**              | `hostPath`, limited-node access |
| `ReadWriteMany`  | Concurrent read/write by **multiple nodes**           | EFS, Azure Files, NFS, etc.     |

Choose the appropriate mode based on your environment and storage backend.

---

## Capacity

- **Recommended starting capacity:** `1Gi`
- Adjust based on automation output size and data retention policies.

---

## Mount Path

- **Inside the pod:** `/densify/data`
- **On the host (if using `hostPath`):** `/mnt/data/densify-recommendations`

> Kubernetes maps the host path (for `hostPath` volumes) to the in-pod mount path using the `volumeMounts` configuration in the Deployment spec.

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