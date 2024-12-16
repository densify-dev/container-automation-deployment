# Generate Certificates Manually

## Quick Links
- [Generate Certificates Manually](#generate-certificates-manually)
  - [Quick Links](#quick-links)
  - [Using CFSSL:](#using-cfssl)
    - [Install CFSSL](#install-cfssl)
    - [Generate Certificates](#generate-certificates)
    - [Create a Kubernetes Secret](#create-a-kubernetes-secret)
    - [Update the caBundle in the Webhook Configuration](#update-the-cabundle-in-the-webhook-configuration)
    - [Apply the Webhook Configuration](#apply-the-webhook-configuration)
  - [Using OpenSSL:](#using-openssl)
    - [Generate certificates manually:](#generate-certificates-manually-1)
    - [Create a Kubernetes Secret:](#create-a-kubernetes-secret-1)
    - [Update the caBundle in the Webhook Configuration](#update-the-cabundle-in-the-webhook-configuration-1)
    - [Apply the Webhook Configuration](#apply-the-webhook-configuration-1)

## Using CFSSL:

### Install CFSSL

    Download and install CFSSL and its companion tool CFSSLJSON:
    ```bash
    curl -LO https://github.com/cloudflare/cfssl/releases/latest/download/cfssl
    curl -LO https://github.com/cloudflare/cfssl/releases/latest/download/cfssljson
    chmod +x cfssl cfssljson
    sudo mv cfssl cfssljson /usr/local/bin/
    ```

    Verify installation:
    ```bash
    cfssl version
    cfssljson --version
    ```
### Generate Certificates
    
    Generate the CA certificate and key: 
    ```bash
    cfssl gencert -initca ca-csr.json | cfssljson -bare ca
    ```

    Generate the server certificate: 
    ```bash
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
          -hostname="densify-webhook-server,densify-automation" \
          server-csr.json | cfssljson -bare server
    ```
### Create a Kubernetes Secret
    ```bash
    kubectl create secret tls densify-automation-tls --cert=server.pem --key=server-key.pem -n densify-automation
    ```
### Update the caBundle in the Webhook Configuration
   
   Base64-encode the CA certificate and update caBundle in the `densify-mutating-webhook-config.yaml`
   ```bash
   cat ca.pem | base64 -w 0
   ```
### Apply the Webhook Configuration
   
   Apply the updated MutatingWebhookConfiguration:
   ```bash
   kubectl apply -f Deployment/densify-mutating-webhook-config.yaml
   ```

## Using OpenSSL:

### Generate certificates manually:
   
    Use OpenSSL to generate the server certificate and key
    ```bash
    openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
    ```
### Create a Kubernetes Secret:
    ```bash
    kubectl create secret tls densify-automation-tls --cert=cert.pem --key=key.pem 
    -n densify-automation
    ```
### Update the caBundle in the Webhook Configuration
   
   Base64-encode the CA certificate and update caBundle in the `densify-mutating-webhook-config.yaml`
   ```bash
   cat ca.pem | base64 -w 0
   ```
### Apply the Webhook Configuration
   
   Apply the updated MutatingWebhookConfiguration:
   ```bash
   kubectl apply -f Deployment/densify-mutating-webhook-config.yaml
   ```

