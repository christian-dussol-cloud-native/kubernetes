#!/bin/bash

echo "📊 Real-time monitoring of pod resize demo..."

# Function to display metrics
display_metrics() {
    clear
    echo "================================="
    echo "📊 KUBERNETES SCALING DASHBOARD"
    echo "================================="
    echo "⏰ $(date)"
    echo ""
    
    echo "🎯 PODS STATUS:"
    kubectl get pods -l app=resize-demo -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,CPU-REQ:.spec.containers[0].resources.requests.cpu,MEM-REQ:.spec.containers[0].resources.requests.memory
    echo ""
    
    echo "📈 HPA STATUS:"
    kubectl get hpa resize-demo-hpa
    echo ""
    
    echo "🔍 RESIZE CONDITIONS:"
    kubectl get pods -l app=resize-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="PodResizeInProgress")].status}{"\n"}{end}' | column -t
    echo ""
    
    echo "💾 NODE RESOURCES:"
    kubectl top nodes 2>/dev/null || echo "Metrics server not available"
    echo ""
    
    echo "Press Ctrl+C to stop monitoring..."
}

# Monitor loop
while true; do
    display_metrics
    sleep 5
done
