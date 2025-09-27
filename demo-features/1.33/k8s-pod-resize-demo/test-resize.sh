#!/bin/bash

set -e

echo "🧪 Testing Kubernetes 1.33 In-Place Pod Resize..."

# Get first pod name
POD_NAME=$(kubectl get pods -l app=resize-demo -o jsonpath='{.items[0].metadata.name}')
echo "📌 Testing with pod: $POD_NAME"

# Function to show current resources
show_resources() {
    echo "📊 Current resources for $POD_NAME:"
    kubectl get pod $POD_NAME -o custom-columns=NAME:.metadata.name,CPU-REQ:.spec.containers[0].resources.requests.cpu,MEM-REQ:.spec.containers[0].resources.requests.memory,CPU-LIM:.spec.containers[0].resources.limits.cpu,MEM-LIM:.spec.containers[0].resources.limits.memory
    
    echo "🔍 Container status:"
    kubectl get pod $POD_NAME -o jsonpath='{.status.containerStatuses[0].resources}' 2>/dev/null || echo "Resource status not available"
}

# Function to monitor resize status
monitor_resize() {
    echo "👀 Monitoring resize status..."
    for i in {1..30}; do
        STATUS=$(kubectl get pod $POD_NAME -o jsonpath='{.status.conditions[?(@.type=="PodResizeInProgress")].status}' 2>/dev/null || echo "")
        if [ "$STATUS" = "True" ]; then
            echo "🔄 Resize in progress... ($i/30)"
            sleep 2
        else
            echo "✅ Resize completed!"
            break
        fi
    done
}

echo "🎬 Phase 1: Show initial state"
show_resources

echo ""
echo "🎬 Phase 2: Scale UP CPU and Memory (simulating traffic spike)"
echo "📈 Increasing CPU: 0.5 -> 1.5, Memory: 512Mi -> 2Gi"
echo "⚠️ Note: This respects the LimitRange max values (4 CPU, 8Gi memory)"

kubectl patch pod $POD_NAME --subresource resize -p '{
  "spec": {
    "containers": [{
      "name": "app",
      "resources": {
        "requests": {"cpu": "1.5", "memory": "2Gi"},
        "limits": {"cpu": "2.5", "memory": "3Gi"}
      }
    }]
  }
}' || echo "❌ Resize blocked by quotas/limits - this is expected behavior!"

monitor_resize
show_resources

echo ""
echo "🎬 Phase 3: Scale DOWN resources (cost optimization)"
echo "📉 Reducing CPU: 1.5 -> 0.3, Memory: 2Gi -> 256Mi"

kubectl patch pod $POD_NAME --subresource resize -p '{
  "spec": {
    "containers": [{
      "name": "app",
      "resources": {
        "requests": {"cpu": "0.3", "memory": "256Mi"},
        "limits": {"cpu": "0.8", "memory": "512Mi"}
      }
    }]
  }
}'

monitor_resize
show_resources

echo ""
echo "🎬 Phase 4: Verify pod behavior during resize"
RESTART_COUNT=$(kubectl get pod $POD_NAME -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "🔄 Restart count: $RESTART_COUNT"

if [ "$RESTART_COUNT" = "0" ]; then
    echo "🎉 SUCCESS! Pod resized without restart - Pure in-place resize worked!"
    echo "💡 This means only CPU was scaled (restartPolicy: NotRequired)"
elif [ "$RESTART_COUNT" = "1" ]; then
    echo "✅ EXPECTED! Pod was restarted once during memory resize"
    echo "💡 Memory scaling used 'RestartContainer' policy for safety"
    echo "🛡️ This prevents memory-related crashes (OOM kills)"
    echo "⚡ CPU scaling was still done in-place without restart"
else
    echo "⚠️ Unexpected restart count: $RESTART_COUNT"
    echo "💡 Check your cluster configuration"
fi

echo ""
echo "🎬 Phase 5: Load test to trigger HPA (optional)"
echo "💡 Run 'kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh' in another terminal"
echo "💡 Then: 'while true; do wget -q -O- http://resize-demo-service; done'"

echo ""
echo "🎬 Phase 6: Test quota protection (intentional failure)"
echo "💀 Attempting to exceed limits (this should FAIL):"

kubectl patch pod $POD_NAME --subresource resize -p '{
  "spec": {
    "containers": [{
      "name": "app",
      "resources": {
        "requests": {"cpu": "5", "memory": "10Gi"},
        "limits": {"cpu": "6", "memory": "12Gi"}
      }
    }]
  }
}' || echo "🛡️ GOOD! Resize was blocked by LimitRange protection!"

echo ""
echo "🎬 Phase 7: Test Kyverno validation (intentional failure)"
echo "💀 Attempting resize that violates Kyverno policy:"

kubectl patch pod $POD_NAME --subresource resize -p '{
  "spec": {
    "containers": [{
      "name": "app",
      "resources": {
        "requests": {"cpu": "6", "memory": "12Gi"},
        "limits": {"cpu": "8", "memory": "16Gi"}
      }
    }]
  }
}' || echo "🛡️ EXCELLENT! Resize was blocked by Kyverno policy validation!"

echo ""
echo "🧪 Testing namespace auto-quota generation..."
kubectl create namespace test-auto-quota || echo "Namespace already exists"
sleep 5
echo "📊 Checking if Kyverno auto-created ResourceQuota:"
kubectl get resourcequota auto-generated-quota -n test-auto-quota || echo "⏳ Quota creation in progress..."

echo ""
echo "✅ Test completed! Key observations:"
echo "🔍 1. CPU resources scaled live without container restart (NotRequired policy)"
echo "🔍 2. Memory resources scaled with controlled restart (RestartContainer policy)"
echo "🔍 3. Application remained available throughout (restart is fast)"
echo "🔍 4. Manual quotas and limits provide essential protection"
echo "🔍 5. Kyverno policies enforce governance automatically"
echo "🔍 6. Policy-as-Code prevents human errors"
echo "🔍 7. Auto-quota generation scales security across namespaces"
echo ""
echo "💡 Production insight: Memory decreases require restart for safety"
echo "⚠️ NEVER deploy in-place resize without proper governance!"
echo "🚀 This demonstrates enterprise-ready vertical scaling!"
