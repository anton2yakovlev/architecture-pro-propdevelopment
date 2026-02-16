#!/usr/bin/env python3

import sys
import json
from collections import OrderedDict

audit_log = sys.argv[1] if len(sys.argv) > 1 else "audit.log"
output_json = "audit-extract.json"

suspicious_events = []

def is_secret_access(event):
    obj_ref = event.get("objectRef", {})
    return obj_ref.get("resource") == "secrets" and event.get("verb") == "get"

def is_exec_create(event):
    obj_ref = event.get("objectRef", {})
    return event.get("verb") == "create" and obj_ref.get("subresource") == "exec"

def is_privileged_pod(event):
    obj_ref = event.get("objectRef", {})
    if obj_ref.get("resource") != "pods":
        return False
    request_obj = event.get("requestObject", {})
    spec = request_obj.get("spec", {})
    containers = spec.get("containers", [])
    return any(container.get("securityContext", {}).get("privileged") == True for container in containers)

def is_rolebinding_create(event):
    obj_ref = event.get("objectRef", {})
    return obj_ref.get("resource") == "rolebindings" and event.get("verb") == "create"

def is_audit_policy_related(event):
    obj_ref = event.get("objectRef", {})
    resource = obj_ref.get("resource", "")
    name = obj_ref.get("name", "")
    return "audit-policy" in resource or "audit-policy" in name

try:
    with open(audit_log, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
                if is_secret_access(event) or is_exec_create(event) or is_privileged_pod(event) or is_rolebinding_create(event) or is_audit_policy_related(event):
                    suspicious_events.append(event)
            except json.JSONDecodeError:
                continue
except FileNotFoundError:
    print(f"Error: {audit_log} not found", file=sys.stderr)
    sys.exit(1)

seen_ids = OrderedDict()
for event in suspicious_events:
    audit_id = event.get("auditID")
    if audit_id and audit_id not in seen_ids:
        seen_ids[audit_id] = event
    elif not audit_id:
        seen_ids[id(event)] = event

unique_events = list(seen_ids.values())

with open(output_json, "w") as f:
    json.dump(unique_events, f, indent=2)
