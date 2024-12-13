# Install cert-manager

cert-manager simplifies certificate lifecycle management for Kubernetes. Follow one of these options:


1. Install cert-manager:

    Install cert-manager using either the Helm option or via applying its manifest directly. 
   
   **Using Helm:**

    ```bash
    helm repo add jetstack https://charts.jetstack.io
    ```
    ```bash
    helm repo update
    ```
    ```bash
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace \
        --set installCRDs=true
    ```


    **Apply its Manifest Directly:**
    ```bash
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
    ```

2. Verify that cert-manager components are running:
    ```bash
    kubectl get pods --namespace cert-manager
    ```
3. Deploy the `ClusterIssuer` configuration:
    ```bash
    kubectl apply -f ./CertManager/selfsigned-clusterissuer.yaml
    ```
4. Review and update if necessary `./CertManager/certificate-creation.yaml`

5. Deploy the certificate configuration:
    ```bash
    kubectl apply -f ./CertManager/certificate-creation.yaml
    ```


