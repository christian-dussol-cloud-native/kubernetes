#!/bin/bash

echo "🧹 Cleaning up Pod Resize Demo..."

kubectl delete -f deployment.yaml
kubectl delete -f resource-quotas.yaml
kubectl delete namespace test-auto-quota

# Optional: Remove Kyverno policies (comment out if you want to keep them)
# kubectl delete -f kyverno-policies.yaml

echo "✅ Cleanup completed!"
echo "💡 Kyverno policies left in place for ongoing governance"
