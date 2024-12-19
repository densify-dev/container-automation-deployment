# Create a Persistent Volume (PV) for the Mutating Admission Controller
   
## Storage Solution
It is recommended to use a shared storage solution such as Amazon EFS, Azure Files, or NFS for seamless access across multiple nodes. 

## Access Modes
The PV must support the `ReadWriteMany` access mode to ensure it can be accessed by multiple nodes simultaneously if required.
    
## Capacity
Recommended starting capacity: `1 GiB`.

## Mount Path
The PV must be mounted to the mutating admission controller pod at the path `/mnt/data/densify` (or as specified in the pod configuration).

## PVC Naming
The PVC name must match the name specified in the mutating admission controller pod configuration. Default: `densify-recommendations-pvc`

## Binding
Verify that the PVC is properly bound to the PV.
```bash
kubectl get pvc -n densify-automation
```