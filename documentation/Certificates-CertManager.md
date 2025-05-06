# Using cert-manager for Certificate Creation and Management

## Quick Links
- [Using cert-manager for Certificate Creation and Management](#using-cert-manager-for-certificate-creation-and-management)
  - [Quick Links](#quick-links)
  - [Overview](#overview)
  - [Install cert-manager](#install-cert-manager)
  - [Verify that cert-manager components are running:](#verify-that-cert-manager-components-are-running)
  - [Deploy the `ClusterIssuer` configuration:](#deploy-the-clusterissuer-configuration)
  - [Review and update if necessary `./certManager/certificate-creation.yaml`](#review-and-update-if-necessary-certmanagercertificate-creationyaml)
  - [Deploy the certificate configuration:](#deploy-the-certificate-configuration)
  - [Enable certManager to automate management of your certificate](#enable-certmanager-to-automate-management-of-your-certificate)
  - [Restart your Mutating Webhook Server:](#restart-your-mutating-webhook-server)
  
  
## Overview

cert-manager simplifies certificate lifecycle management for Kubernetes. Follow one of these options to install and configure cert-manager.


## Install cert-manager

See installation steps [here](https://artifacthub.io/packages/helm/cert-manager/cert-manager)

## Verify that cert-manager components are running:
```bash
kubectl get pods --namespace cert-manager
```
## Deploy the `ClusterIssuer` configuration:
```bash
kubectl apply -f ./certManager/selfsigned-clusterissuer.yaml
```
## Review and update if necessary `./certManager/certificate-creation.yaml`

## Deploy the certificate configuration:
```bash
kubectl apply -f ./certManager/certificate-creation.yaml
```
TODO: Cannot run this before 'densify-automation' namespace exist

## Enable certManager to automate management of your certificate

- Edit `deployment/webhook/densify-mutating-webhook-config.yaml` and Uncomment the annotation section 'cert-manager.io/inject-ca-from' to allow certManager to auto-inject caBundle into your MutatingWebhookConfiguration. 

- Apply the updated MutatingWebhookConfiguration:
   ```bash
   kubectl apply -f deployment/webhook/densify-mutating-webhook-config.yaml
   ```

## Restart your Mutating Webhook Server:
```bash
kubectl rollout restart deployment densify-webhook-server -n densify-automation
```
