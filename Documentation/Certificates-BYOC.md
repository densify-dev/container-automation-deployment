# Bring Your Own Certificates (BYOC)

1. Ensure you have a valid certificate and key.
2. Create a Kubernetes Secret:
    ```bash
    kubectl create secret tls webhook-cert --cert=path-to-cert.pem --key=path-to-key.pem \
        -n densify-automation
    ```
