# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

1. Доступ к секретам:
   - Кто: system:serviceaccount:secure-ops:monitoring
   - Где: namespace kube-system, secret default-token
   - Почему подозрительно: ServiceAccount monitoring пытается получить доступ к секретам в системном namespace без необходимых прав

2. Привилегированные поды:
   - Кто: пользователь, создавший privileged-pod
   - Комментарий: Создан под с privileged: true, что даёт полный доступ к хосту

3. Использование kubectl exec в чужом поде:
   - Кто: пользователь, выполнивший exec
   - Что делал: Выполнение команды в поде coredns в namespace kube-system

4. Создание RoleBinding с правами cluster-admin:
   - Кто: пользователь, создавший escalate-binding
   - К чему привело: ServiceAccount monitoring получил права cluster-admin через RoleBinding

5. Удаление audit-policy.yaml:
   - Кто: пользователь с именем admin
   - Возможные последствия: Отключение аудита, невозможность отслеживания дальнейших действий

## Вывод

Обнаружены множественные попытки превышения привелегий. ServiceAccount monitoring получил права cluster-admin через RoleBinding. Политика RBAC допускает создание RoleBinding с cluster-admin без дополнительных проверок.
Нужно ужесточение политики RBAC для сервисного аккаунта мониторинга