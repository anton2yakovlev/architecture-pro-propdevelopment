#!/bin/bash
# Скрипт для связывания пользователей с ролями

set -e

NAMESPACES=("development" "staging" "production")

# Привязка admins к cluster-admin
kubectl apply -f - > /dev/null <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admins-cluster-admin-binding
subjects:
- kind: Group
  name: admins
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: admin-user
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: sre-lead
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# Привязка viewers к viewer-role
kubectl apply -f - > /dev/null <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewers-binding
subjects:
- kind: Group
  name: viewers
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: analyst-user
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: manager-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: viewer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Привязка developers к developer-role в каждом namespace
for ns in "${NAMESPACES[@]}"; do
kubectl apply -f - > /dev/null <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developers-binding
  namespace: $ns
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: backend-dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF
done

# Дополнительные права для developers
kubectl apply -f - > /dev/null <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developers-view-namespaces
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: backend-dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
EOF

# Привязка operators к operator-role
kubectl apply -f - > /dev/null <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: operators-binding
subjects:
- kind: Group
  name: operators
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: ops-user
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: platform-engineer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: operator-role
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Привязки созданы"
