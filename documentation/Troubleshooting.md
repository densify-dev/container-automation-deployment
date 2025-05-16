# Mutation Admission Controller Troubleshooting Guide

## 1. Namespace `densify-automation` Not Found

**Issue**  
Applying `certificate-creation.yaml` fails with:

**Solution**  
Create the `densify-automation` namespace:
```bash
kubectl create namespace densify-automation
```

---

## 2. ConfigMap `densify-automation-policy` Missing

**Issue**  
The webhook cannot find the required policy config.

**Solution**  
Ensure the ConfigMap is created:
```bash
kubectl apply -f densify-automation-policy.yaml
```

Validate its existence:
```bash
kubectl get configmap densify-automation-policy -n densify-automation
```

---

## 3. Failed to Initialize Token

**Issue**  
Webhook fails to authenticate due to token errors.

**Solution**  
- Ensure the username and password are:
  - Correct
  - Base64 encoded

- Validate the secret:
```bash
kubectl get secret densify-api-secret -n densify-automation -o yaml
```

---

## 4. Webhook Pod in Error or CrashLoopBackOff State

**Issue**  
Pod is not running correctly.

**Solution**  
Check logs for error messages:
```bash
kubectl logs <pod_name> -n densify-automation
```

Common causes:
- Incorrect environment variables
- Secret/config volume issues
- Misconfigured TLS certificates

---

## 5. Webhook Not Triggering

**Issue**  
The `densify-webhook-server` pod is running, but no pods are being mutated.

**Solution**  
Possible causes:
- Check that the webhook configuration targets the correct `namespaceSelector`, `objectSelector`, and `rules`.
- Invalid or missing `caBundle`:
  - If using manual TLS certs, ensure the base64-encoded certificate is injected correctly in `MutatingWebhookConfiguration`.
  - If using CertManager, ensure you uncomment the annotation section in `densify-mutating-webhook-config.yaml`.

---

## 6. TLS Handshake Error when Mutating Pods

**Issue**  
TLS handshake errors are visible in logs or Kubernetes events.

**Solution**  
- Ensure your certificate is valid and correctly signed.
- If using CertManager, verify the DNS names within `certificate-creation.yaml` match the service name.

---

## 7. Recommendation Job Stuck in Pending

**Issue**  
Job `densify-recommendations-job` remains in a `Pending` state.

**Solution**  
Inspect the pod:
```bash
kubectl describe pod <pod_name> -n densify-automation
```

Check the Events section for:
- Insufficient resources
- Failed mount due to missing PersistentVolumeClaim (PVC)

Ensure:
- PVCs are properly defined and bound.
- Nodes have enough resources and access to storage classes.

---

## 8. Recommendations Not Loaded

**Issue**  
The webhook does not reflect updated recommendations.

**Solution**  
Reload the job:
```bash
kubectl apply -f densify-recommendations-job.yaml
```

Restart the webhook deployment:
```bash
kubectl rollout restart deployment densify-webhook-server -n densify-automation
```

---

## 9. Wrong Policy Being Applied

**Issue**  
The logs show that the webhook is mutating pods using a different policy name than expected.

**Solution**  
Possible causes:

- **Incorrect Policy Path in Webhook Definition**  
  The webhook receives the policy name from the request path:  
  `/mutate/<policyName>`  
  If the path is incorrectly defined in the `MutatingWebhookConfiguration`, it may default to an unintended policy.

- **No Policy Name Defined → Falls Back to Default**  
  If the webhook request path omits the policy name (e.g., `/mutate/`), the controller uses the default policy defined in `densify-automation-policy.yaml`.

To fix:
- Explicitly pass the intended policy name in the webhook path.  
- Or ensure the default policy file contains the desired logic.
