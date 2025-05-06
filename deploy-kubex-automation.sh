#!/bin/bash
set -e  # Exit on any error

echo "Applying base resources..."
kubectl apply -k deployment/base/

echo "Running job to fetch recommendations..."
kubectl apply -k deployment/jobs/
kubectl wait --for=condition=complete --timeout=300s jobs/densify-recommendations-fetcher-job -n densify-automation

echo "Deploying webhook..."
kubectl apply -k deployment/webhook/

echo "All tasks completed successfully!"