#!/bin/bash

cd "$(dirname "$0")/.."

kubectl apply -f 01-create-namespace.yaml >/dev/null 2>&1

echo "Testing insecure manifests (should be rejected):"
kubectl apply -f insecure-manifests/01-privileged-pod.yaml 2>&1 | grep -q "denied\|forbidden" && echo "Privileged pod rejected" || echo "Privileged pod not rejected"
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml 2>&1 | grep -q "denied\|forbidden" && echo "HostPath pod rejected" || echo "HostPath pod not rejected"
kubectl apply -f insecure-manifests/03-root-user-pod.yaml 2>&1 | grep -q "denied\|forbidden" && echo "Root user pod rejected" || echo "Root user pod not rejected"

echo "Testing secure manifests (should be accepted):"
kubectl apply -f secure-manifests/01-secure.yaml >/dev/null 2>&1 && echo "Secure pod 1 accepted" || echo "Secure pod 1 rejected"
kubectl apply -f secure-manifests/02-secure.yaml >/dev/null 2>&1 && echo "Secure pod 2 accepted" || echo "Secure pod 2 rejected"
kubectl apply -f secure-manifests/03-secure.yaml >/dev/null 2>&1 && echo "Secure pod 3 accepted" || echo "Secure pod 3 rejected"
