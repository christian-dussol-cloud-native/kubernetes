# 🚀 Kubernetes Cheat Sheet

## 📋 Table of Contents
- [Developer](#-developer)
- [Administrator](#-administrator)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Monitoring](#-monitoring)
- [Bonus: Kyverno](#-bonus-kyverno)

---

## 👨‍💻 Developer

### Pod Management
```bash
# Create a pod from an image
kubectl run nginx --image=nginx:latest

# List pods
kubectl get pods
kubectl get pods -o wide  # More details (IP, node)

# View pod logs
kubectl logs my-pod
kubectl logs my-pod -f  # Follow mode
kubectl logs my-pod -c my-container  # Specific container

# Execute a command in a pod
kubectl exec -it my-pod -- /bin/bash
kubectl exec my-pod -- env  # Non-interactive mode

# Delete a pod
kubectl delete pod my-pod
```

### Deployments
```bash
# Create a deployment
kubectl create deployment nginx --image=nginx:latest

# Scale a deployment up or down
kubectl scale deployment nginx --replicas=3

# Update an image
kubectl set image deployment/nginx nginx=nginx:1.24

# Check rollout status
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2
```

### Services
```bash
# Expose a deployment
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Port-forward for local testing
kubectl port-forward svc/nginx 8080:80
kubectl port-forward pod/nginx 8080:80
```

### ConfigMaps & Secrets
```bash
# Create a ConfigMap
kubectl create configmap app-config --from-literal=ENV=production
kubectl create configmap app-config --from-file=config.properties

# Create a Secret
kubectl create secret generic db-password --from-literal=password=mypass
kubectl create secret docker-registry regcred --docker-server=registry.io --docker-username=user --docker-password=pass

# View (be careful with secrets)
kubectl get configmap app-config -o yaml
kubectl get secret db-password -o yaml
```

### Jobs & CronJobs
```bash
# Create a Job
kubectl create job hello --image=busybox -- echo "Hello Kubernetes"

# Create a CronJob
kubectl create cronjob backup --schedule="0 2 * * *" --image=backup:latest -- /backup.sh

# List and manage
kubectl get jobs
kubectl get cronjobs
kubectl delete job hello
```

---

## ⚙️ Administrator

### Cluster Management
```bash
# Cluster information
kubectl cluster-info
kubectl get nodes
kubectl describe node node-1
kubectl top nodes  # Metrics (requires metrics-server)

# Drain and Cordon (maintenance)
kubectl cordon node-1  # Prevents new pods
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data
kubectl uncordon node-1  # Reactivates the node
```

### Namespaces
```bash
# Create a namespace
kubectl create namespace production

# List namespaces
kubectl get namespaces

# Work in a specific namespace
kubectl get pods -n production
kubectl config set-context --current --namespace=production

# Delete a namespace (careful!)
kubectl delete namespace dev
```

### Resource Quotas & LimitRanges
```bash
# Apply a quota
kubectl create quota prod-quota --hard=cpu=10,memory=20Gi,pods=20 -n production

# Check quotas
kubectl get resourcequota -n production
kubectl describe resourcequota prod-quota -n production

# Default limits
kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
EOF
```

### RBAC
```bash
# Create a ServiceAccount
kubectl create serviceaccount dev-user

# Create a Role
kubectl create role pod-reader --verb=get,list --resource=pods -n dev

# Create a RoleBinding
kubectl create rolebinding dev-binding --role=pod-reader --serviceaccount=dev:dev-user -n dev

# Check permissions
kubectl auth can-i get pods --as=system:serviceaccount:dev:dev-user -n dev
kubectl auth can-i delete deployments --as=dev-user
```

### Taints & Tolerations
```bash
# Add a taint to a node
kubectl taint nodes node-1 app=special:NoSchedule

# Remove a taint
kubectl taint nodes node-1 app=special:NoSchedule-

# List taints
kubectl describe node node-1 | grep Taint
```

### Resource Management
```bash
# Apply manifests
kubectl apply -f deployment.yaml
kubectl apply -f ./config/  # Entire directory
kubectl apply -k ./kustomize/  # Kustomize

# Diff before apply
kubectl diff -f deployment.yaml

# Delete according to manifest
kubectl delete -f deployment.yaml
```

---

## 🔒 Security

### Network Policies
```bash
# Example network policy (deny all)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# List Network Policies
kubectl get networkpolicies
kubectl describe networkpolicy deny-all
```

### Pod Security Standards
```bash
# Label a namespace with PSS
kubectl label namespace production pod-security.kubernetes.io/enforce=restricted
kubectl label namespace production pod-security.kubernetes.io/warn=restricted

# Check labels
kubectl get namespace production --show-labels
```

### Secrets Management
```bash
# Encode/Decode base64
echo -n 'my-secret' | base64
echo 'bXktc2VjcmV0' | base64 -d

# Decode secret value
kubectl get secret db-password -o jsonpath="{.data.password}" | base64 -d

# Use secrets in pods (avoid direct commands)
# Prefer volumes or environment variables via YAML

# Secret rotation
kubectl delete secret db-password
kubectl create secret generic db-password --from-literal=password=new-pass
kubectl rollout restart deployment/app
# Note: This only restarts pods if the secret is actually mounted or used by the deployment
```

### Security Contexts
```bash
# Check a pod's security context
kubectl get pod my-pod -o jsonpath='{.spec.securityContext}'
kubectl get pod my-pod -o jsonpath='{.spec.containers[*].securityContext}'

# Example with runAsNonRoot
kubectl run secure-pod --image=nginx --dry-run=client -o yaml | \
  kubectl patch -f - --local --type=json -p='[{"op":"add","path":"/spec/securityContext","value":{"runAsNonRoot":true,"runAsUser":1000}}]' -o yaml | \
  kubectl apply -f -
```

### Image Security
```bash
# Scan images (with trivy for example)
trivy image nginx:latest

# Check image provenance
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}'

# Apply ImagePullSecrets
kubectl patch serviceaccount default -p '{"imagePullSecrets":[{"name":"regcred"}]}'
```

---

## 🔧 Troubleshooting

### Pod Diagnostics
```bash
# Detailed pod status
kubectl describe pod my-pod

# Recent events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=my-pod

# Failed pods
kubectl get pods --field-selector=status.phase=Failed
kubectl get pods --all-namespaces | grep -v Running

# Debug a crashed pod
kubectl logs my-pod --previous
# Note: --previous only works for pods that have restarted at least once
```

### Network Diagnostics
```bash
# Test network connectivity
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash

# DNS troubleshooting
kubectl run dnsutils --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 --command -- sleep infinity
kubectl exec -it dnsutils -- nslookup kubernetes.default
kubectl exec -it dnsutils -- cat /etc/resolv.conf

# Check services
kubectl get endpoints my-service
kubectl get svc my-service -o wide
```

### Performance and Resources
```bash
# Top pods/nodes (requires metrics-server)
kubectl top pods
kubectl top pods --all-namespaces --sort-by=memory
kubectl top nodes

# Describe requested resources
kubectl describe nodes | grep -A 5 "Allocated resources"

# Pods requesting the most resources
kubectl get pods -o json | jq '.items[] | {name: .metadata.name, cpu: .spec.containers[].resources.requests.cpu, memory: .spec.containers[].resources.requests.memory}'
```

### Debugging Tips
```bash
# Verbose mode
kubectl get pods -v=8

# Dry-run for testing
kubectl create deployment test --image=nginx --dry-run=client -o yaml

# Explain for documentation
kubectl explain pod.spec.containers
kubectl explain deployment.spec.strategy

# Generate manifest from existing resource
kubectl get deployment nginx -o yaml > nginx-deployment.yaml

# Debug a pod that won't start
kubectl debug my-pod -it --image=busybox --copy-to=my-pod-debug

# View current context
kubectl config view --minify
```

---

## 📊 Monitoring

### Metrics Server
```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
```

### Logs and Events
```bash
# Follow logs from a pod with label selector
kubectl logs -l app=nginx --all-containers=true -f
# Note: For multiple pods, use tools like 'stern' or 'kubetail'

# Logs over a time period
kubectl logs my-pod --since=1h
kubectl logs my-pod --since-time=2024-01-01T00:00:00Z

# Export logs
kubectl logs my-pod > pod-logs.txt

# Events by namespace
kubectl get events -n production --sort-by='.lastTimestamp'
```

### Health Checks
```bash
# Check readiness/liveness probes
kubectl describe pod my-pod | grep -A 5 "Liveness\|Readiness"

# Non-ready pods
kubectl get pods --field-selector=status.phase!=Running
kubectl get pods -o json | jq '.items[] | select(.status.conditions[] | select(.type=="Ready" and .status!="True")) | .metadata.name'
```

### Resource Monitoring
```bash
# Usage by namespace
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Pods without resource limits
kubectl get pods -o json | jq '.items[] | select(.spec.containers[].resources.limits == null) | .metadata.name'

# PVC and storage
kubectl get pvc --all-namespaces
kubectl describe pvc my-pvc
```

---

## 🎁 Bonus: Kyverno

### Installation
```bash
# Install Kyverno
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.11.0/install.yaml

# Verify installation
kubectl get pods -n kyverno
kubectl get crds | grep kyverno
```

### Basic Policies
```bash
# Policy: Require labels
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-team-label
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "The 'team' label is required"
      pattern:
        metadata:
          labels:
            team: "?*"
EOF
```

### Automatic Mutation
```bash
# Automatically add labels
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-labels
spec:
  rules:
  - name: add-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            managed-by: kyverno
EOF
```

### Resource Generation
```bash
# Automatically create a NetworkPolicy per namespace
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-networkpolicy
spec:
  rules:
  - name: default-deny-all
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      kind: NetworkPolicy
      name: default-deny-all
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
EOF
```

### Useful Kyverno Commands
```bash
# List policies
kubectl get clusterpolicies
kubectl get policies --all-namespaces

# Check policy status
kubectl describe clusterpolicy require-labels

# Test a policy before applying
kyverno apply policy.yaml --resource resource.yaml
# Note: Requires Kyverno CLI (separate installation from kubectl)

# View policy reports
kubectl get policyreport -A
kubectl describe policyreport polr-ns-default
```

---

## 💡 General Tips

### Useful Aliases
```bash
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kdes='kubectl describe'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
```

### Kubectl Context & Config
```bash
# View contexts
kubectl config get-contexts
kubectl config current-context

# Switch context
kubectl config use-context production

# Change default namespace
kubectl config set-context --current --namespace=dev
```

### Useful Resources
- Official documentation: https://kubernetes.io/docs/
- Kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- Kyverno Policies: https://kyverno.io/policies/

---

> Feel free to save this cheat sheet and share it with your team!
