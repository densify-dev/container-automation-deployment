# Using cert-manager for Certificate Creation and Management

## Quick Links
- [Using cert-manager for Certificate Creation and Management](#using-cert-manager-for-certificate-creation-and-management)
  - [Quick Links](#quick-links)
  - [Overview](#overview)
  - [Install cert-manager](#install-cert-manager)
    - [Using Helm](#using-helm)
    - [Apply its Manifest Directly:](#apply-its-manifest-directly)
  - [Verify that cert-manager components are running:](#verify-that-cert-manager-components-are-running)
  - [Deploy the `ClusterIssuer` configuration:](#deploy-the-clusterissuer-configuration)
  - [Review and update if necessary `./CertManager/certificate-creation.yaml`](#review-and-update-if-necessary-certmanagercertificate-creationyaml)
  - [Deploy the certificate configuration:](#deploy-the-certificate-configuration)
  - [Enable certManager to automate management of your certificate](#enable-certmanager-to-automate-management-of-your-certificate)
  
  
## Overview

cert-manager simplifies certificate lifecycle management for Kubernetes. Follow one of these options to install and configure cert-manager.


## Install cert-manager

Install cert-manager using either the Helm option or via applying its manifest directly. 
   
### Using Helm

```bash
helm repo add jetstack https://charts.jetstack.io
```
```bash
helm repo update
```
```bash
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```


### Apply its Manifest Directly:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
```

## Verify that cert-manager components are running:
```bash
kubectl get pods --namespace cert-manager
```
## Deploy the `ClusterIssuer` configuration:
```bash
kubectl apply -f ./CertManager/selfsigned-clusterissuer.yaml
```
## Review and update if necessary `./CertManager/certificate-creation.yaml`

## Deploy the certificate configuration:
```bash
kubectl apply -f ./CertManager/certificate-creation.yaml
```

## Enable certManager to automate management of your certificate

- Edit `Deployment/densify-mutating-webhook-config.yaml` and Uncomment the annotation section 'cert-manager.io/inject-ca-from' to allow CertManager to auto-inject caBundle into your MutatingWebhookConfiguration. 

- Apply the updated MutatingWebhookConfiguration:
   ```bash
   kubectl apply -f Deployment/densify-mutating-webhook-config.yaml
   ```