#!/bin/bash
# Скрипт создания пользователей для Kubernetes RBAC

set -e

# Функция создания пользователя через CSR
create_user() {
    local username=$1
    local group=$2
    
    # Создаем временный ключ и CSR
    openssl genrsa -out /tmp/${username}.key 2048 &> /dev/null
    openssl req -new -key /tmp/${username}.key -out /tmp/${username}.csr -subj "/CN=${username}/O=${group}" &> /dev/null
    
    # Кодируем CSR в base64
    CSR_BASE64=$(cat /tmp/${username}.csr | base64 | tr -d '\n')
    
    # Создаем и одобряем CSR в Kubernetes
    kubectl apply -f - > /dev/null <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${username}-csr
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
  expirationSeconds: 31536000
EOF
    
    kubectl certificate approve ${username}-csr &> /dev/null
    
    # Удаляем временные файлы
    rm -f /tmp/${username}.key /tmp/${username}.csr
}

# Создаем пользователей для каждой группы
create_user "admin-user" "admins"
create_user "sre-lead" "admins"
create_user "analyst-user" "viewers"
create_user "manager-user" "viewers"
create_user "dev-user" "developers"
create_user "backend-dev" "developers"
create_user "ops-user" "operators"
create_user "platform-engineer" "operators"

echo "Пользователи созданы"
