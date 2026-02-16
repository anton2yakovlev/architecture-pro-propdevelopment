# Как запустить

Создание namespace: `kubectl apply -f 01-create-namespace.yaml`

Установка Gatekeeper constraint templates: `kubectl apply -f gatekeeper/constraint-templates/`

Установка constraints: `kubectl apply -f gatekeeper/constraints/`

Проверка: `./verify/validate-security.sh && ./verify/verify-admission.sh`
