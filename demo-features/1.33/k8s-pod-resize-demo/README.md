# Kubernetes 1.33 In-Place Pod Resize Demo

Complete demonstration of Kubernetes 1.33 in-place pod resize feature with enterprise-grade security and governance.

## 🎯 What This Demo Includes

- **Zero-downtime pod resizing** with live CPU and memory scaling
- **Multi-layer governance** with ResourceQuotas, LimitRanges, and Kyverno policies
- **Automated governance** that prevents resource abuse
- **Complete autoscaling setup** (HPA + VPA + Cluster Autoscaler ready)
- **Real-time monitoring** and validation scripts
- **Production-ready safeguards** for enterprise environments

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/christian-dussol-cloud-native/kubernetes.git
cd kubernetes/demo-features/1.33/k8s-pod-resize-demo/

# Make scripts executable
chmod +x *.sh

# Deploy the complete demo
./deploy.sh

# Test in-place resize
./test-resize.sh

# Monitor in real-time (optional)
./monitoring.sh

# Cleanup when done
./cleanup.sh
```

## 📁 File Structure

```
k8s-pod-resize-demo/
├── README.md                 # This file
├── deployment.yaml           # App, Service, HPA manifests
├── resource-quotas.yaml      # ResourceQuota & LimitRange
├── kyverno-policies.yaml     # Governance policies
├── deploy.sh                 # Setup script
├── test-resize.sh           # Resize testing script
├── monitoring.sh            # Real-time monitoring
└── cleanup.sh              # Cleanup script
```

## 🔧 Prerequisites

**IMPORTANT**: Make sure all prerequisites are installed before running the demo.

### Required Infrastructure
- **Kubernetes 1.33+** cluster with InPlacePodVerticalScaling feature gate enabled (default)
- **Container runtime**: containerd 1.6+ or CRI-O 1.24+
- **kubectl** configured and connected to your cluster

### Required Tools
- **Helm 3.x** for package management
- **kubectl** configured and connected to your cluster
- **Kyverno v1.15.2+** policy engine installed in your cluster

### Tested Versions
- **Kubernetes**: 1.33.1
- **Kyverno**: v1.15.2 (Chart 3.5.2)
- **containerd**: 1.6.9+
- **Helm**: 3.x
- **Last tested**: September 27, 2025

### Kyverno Installation

```bash
# Add Kyverno Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Install Kyverno (tested version)
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --version 3.5.2

# Verify installation and check version
kubectl get pods -n kyverno
helm list -n kyverno
```

### Quick Verification
```bash
# Check Kubernetes version
kubectl version

# Verify feature gate (should show resources in allocatable)
kubectl get nodes -o jsonpath='{.items[0].status.allocatable}'

# Check Kyverno is running
kubectl get deployment kyverno -n kyverno
```

## 🛡️ Governance Features

### Multi-Layer Governance Strategy

1. **ResourceQuotas**: Limit total namespace consumption
2. **LimitRanges**: Cap maximum resize values per container
3. **Kyverno Policies**: Automatically enforce governance at scale
4. **Monitoring**: Alert on unexpected resource spikes
5. **Budget Controls**: Cloud cost monitoring and alerts

### Kyverno Automation

- **Auto-generates quotas** for any namespace missing them
- **Validates resize operations** before they're applied
- **Scales governance** across hundreds of namespaces
- **Prevents human errors** through Policy-as-Code
- **Audit trail** of all policy decisions

## ⚠️ CRITICAL: Production Safety with Policy-as-Code

**NEVER enable in-place pod resize without automated governance!** This feature can consume unlimited cluster resources if not properly constrained.

### Essential Safeguards

1. **ResourceQuotas**: Limit total namespace consumption
2. **LimitRanges**: Cap maximum resize values per container
3. **Kyverno Policies**: Automatically enforce governance at scale
4. **Monitoring**: Alert on unexpected resource spikes
5. **Budget Controls**: Cloud cost monitoring and alerts

### Security Considerations

- Users with pod/resize permissions can potentially DoS your cluster
- Implement RBAC restrictions on the resize subresource
- Use admission controllers (like Kyverno) for validation
- Monitor resize operations with audit logging
- **Policy-as-Code prevents configuration drift**

## 🎯 Key Features Demonstrated

1. **In-Place Pod Resize**: Scale CPU/memory without restarts
2. **Horizontal Pod Autoscaler**: Scale pod replicas based on metrics
3. **Cluster Autoscaler**: Scale nodes automatically
4. **Kyverno Policy Engine**: Automated governance and validation
5. **Combined Scaling Strategy**: HPA + VPA + CA + Policy-as-Code

## 🏗️ The Complete Scaling + Governance Approach

- **Horizontal (HPA)**: More pods for increased load
- **Vertical (In-Place)**: More resources per pod
- **Node (CA)**: More nodes for cluster capacity
- **Governance (Kyverno)**: Automated policy enforcement

This creates a complete, elastic, and **secure** infrastructure that adapts to any workload pattern while preventing resource abuse!

## 🧪 Demo Phases

The test script demonstrates:

1. **Deploy** with governance guardrails first
2. **Scale UP** resources during simulated load (0.5→1.5 CPU live)
3. **Scale DOWN** for cost optimization (1.5→0.3 CPU live) 
4. **Validate** zero restarts throughout the process
5. **Test security** - Quotas and Kyverno block dangerous resize attempts
6. **Auto-governance** - New namespaces get quotas automatically

## 📊 Real Impact

**Before in-place resize:**
- Pod restart required for resource changes
- Connection drops and service interruption
- Manual scaling decisions
- Over-provisioning for safety

**After implementation:**
- Live resource scaling without downtime
- Connections preserved during resize
- Automated response to load changes
- Right-sizing in real-time

## 🔮 Future Enhancements

Coming in future Kubernetes versions:
- VPA integration with in-place resize
- GPU/storage resize support
- Enhanced scheduler awareness
- Extended resource types

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

## 📝 License

All resources in this organization are shared under Creative Commons Attribution-ShareAlike 4.0 International License unless otherwise specified.

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

## 🔗 Related Resources

- [Kubernetes 1.33 Release Notes](https://kubernetes.io/blog/2025/05/16/kubernetes-v1-33-in-place-pod-resize-beta/)
- [Official Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/)
- [Kyverno Policy Examples](https://kyverno.io/policies/)

---

*Built with ❤️ for the cloud-native community. Questions? Open an issue or reach out on LinkedIn!*
