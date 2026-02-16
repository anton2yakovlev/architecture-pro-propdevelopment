#!/bin/bash

echo "Проверка PodSecurity:"
kubectl get namespace audit-zone -o jsonpath='{.metadata.labels}' | grep -q "pod-security" && echo "PodSecurity labels present" || echo "PodSecurity labels missing"

echo "Проверка Gatekeeper:"
kubectl get K8sRequiredSecurityContext 2>/dev/null | grep -q "no-privileged-containers" && echo "Privileged constraint active" || echo "Privileged constraint missing"
kubectl get K8sDisallowedHostPath 2>/dev/null | grep -q "no-hostpath-volumes" && echo "HostPath constraint active" || echo "HostPath constraint missing"
kubectl get K8sRequiredRunAsNonRoot 2>/dev/null | grep -q "require-runasnonroot" && echo "RunAsNonRoot constraint active" || echo "RunAsNonRoot constraint missing"
