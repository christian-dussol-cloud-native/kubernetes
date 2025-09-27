#!/bin/bash

echo "🚀 Deploying Kubernetes 1.33 Pod Resize Demo..."

# Check Kubernetes version
echo "📋 Checking Kubernetes version..."
K8S_VERSION=$(kubectl version 2>/dev/null | grep "Server Version" | sed 's/.*v\([0-9]*\.[0-9]*\).*/\1/' || echo "unknown")
echo "Kubernetes version: $K8S_VERSION"

if [[ "$K8S_VERSION" != "unknown" ]] && [[ ! "$K8S_VERSION" =~ ^1\.(3[3-9]|[4-9][0-9]) ]]; then
    echo "❌ Kubernetes 1.33+ required. Current version: $K8S_VERSION"
    echo "💡 Continuing anyway - feature might still work..."
fi

# Check if cluster is accessible
echo "🔧 Checking cluster access..."
kubectl get nodes > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Cluster is accessible"
else
    echo "❌ Cannot access cluster"
    exit 1
fi

# Check if Kyverno is installed
echo "🛡️ Checking Kyverno installation..."
if kubectl get namespace kyverno >/dev/null 2>&1 && kubectl get pods -n kyverno -l app.kubernetes.io/name=kyverno >/dev/null 2>&1; then
    echo "✅ Kyverno is installed"
else
    echo "❌ Kyverno not found. Please install Kyverno first:"
    echo "   helm repo add kyverno https://kyverno.github.io/kyverno/"
    echo "   helm repo update"
    echo "   helm install kyverno kyverno/kyverno -n kyverno --create-namespace"
    echo ""
    echo "See README.md for detailed installation instructions."
    echo ""
    echo "Debug info:"
    echo "- Checking namespace 'kyverno':"
    kubectl get namespace kyverno 2>/dev/null || echo "  Namespace 'kyverno' not found"
    echo "- Checking Kyverno pods:"
    kubectl get pods -n kyverno 2>/dev/null || echo "  No pods found in kyverno namespace"
    exit 1
fi


# Apply Kyverno policies for automatic governance
echo "📋 Applying Kyverno governance policies..."
kubectl apply -f kyverno-policies.yaml

echo "✅ Kyverno policies applied - automatic governance active!"

# Apply the quotas and limits FIRST (CRITICAL!)
echo "🛡️ Applying resource quotas and limits..."
kubectl apply -f resource-quotas.yaml

echo "✅ Quotas applied - cluster is now protected!"

# Apply the deployment
echo "📦 Applying deployment..."
kubectl apply -f deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/resize-demo-app

# Get initial pod info
echo "📊 Initial pod resources:"
kubectl get pods -l app=resize-demo -o custom-columns=NAME:.metadata.name,CPU-REQ:.spec.containers[0].resources.requests.cpu,MEM-REQ:.spec.containers[0].resources.requests.memory,CPU-LIM:.spec.containers[0].resources.limits.cpu,MEM-LIM:.spec.containers[0].resources.limits.memory

echo "✅ Deployment complete!"
echo "🔍 Run './test-resize.sh' to test the in-place resize feature"
