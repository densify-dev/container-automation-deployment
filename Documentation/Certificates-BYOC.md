# Bring Your Own Certificates (BYOC)

1. Ensure you have a valid certificate and key.
2. Create a Kubernetes Secret:
    ```bash
    kubectl create secret tls densify-automation-tls --cert=path-to-cert.pem --key=path-to-key.pem -n densify-automation
    ```
3. Update the caBundle in the Webhook Configuration
   
   Base64-encode the CA certificate and update caBundle in the `densify-mutating-webhook-config.yaml`
   ```bash
   cat ca.pem | base64 -w 0
   ```
4. Apply the Webhook Configuration
   
   Apply the updated MutatingWebhookConfiguration:
   ```bash
   kubectl apply -f Deployment/densify-mutating-webhook-config.yaml
   ```