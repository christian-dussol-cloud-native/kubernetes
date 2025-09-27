# Tested Component Versions

This document tracks the specific versions of all components used and tested with this Kubernetes 1.33 In-Place Pod Resize demo.

## 🎯 Core Components

### Kubernetes Cluster
- **Kubernetes Server**: v1.33.1
- **Kubernetes Client**: v1.33.3
- **Feature Gate**: `InPlacePodVerticalScaling` (enabled by default)

### Container Runtime
- **containerd**: 1.6.9+ (recommended)
- **CRI-O**: 1.24+ (alternative)

### Policy Engine
- **Kyverno**: v1.15.2
- **Kyverno Helm Chart**: 3.5.2
- **Installation Command**: `helm install kyverno kyverno/kyverno -n kyverno --create-namespace --version 3.5.2`

## 🛠️ Management Tools

### Command Line Tools
- **kubectl**: v1.33.3
- **Helm**: 3.x (tested with 3.12+)

### Optional Tools
- **metrics-server**: Not required for demo (but recommended for production HPA)

### Container Runtime Compatibility
- ✅ **containerd 1.6.9+**: Full support (recommended)
- ✅ **CRI-O 1.24+**: Full support
- ❌ **Docker**: Limited support (being phased out)

## 📦 Demo Components

### Application Stack
- **Base Image**: nginx:1.21
- **Resource Configuration**: CPU and Memory with resizePolicy
- **Health Checks**: HTTP liveness and readiness probes

### Governance Stack
- **ResourceQuota**: Standard Kubernetes v1 API
- **LimitRange**: Standard Kubernetes v1 API
- **HorizontalPodAutoscaler**: autoscaling/v2 API
- **Kyverno ClusterPolicies**: kyverno.io/v1 API

## 🔄 Version History

### Latest Test (September 27, 2025)
- **Environment**: Self-managed Kubernetes cluster
- **Kubernetes**: v1.33.1
- **Kyverno**: v1.15.2 (Chart 3.5.2)
- **Test Results**: ✅ All features working correctly
- **Notable Issues**: Minor RBAC warning for Pod/resize permissions (non-blocking)

### Compatibility Notes
- **Memory decrease operations**: Require `RestartContainer` policy for safety
- **CPU scaling**: Works seamlessly with `NotRequired` policy
- **Kyverno validation**: Properly blocks excessive resize attempts
- **Auto-quota generation**: Functions correctly for new namespaces

## 🚨 Known Issues

### Minor Issues
- **Warning**: `system:serviceaccount:kyverno:kyverno-reports-controller requires permissions get,list,watch for resource Pod/resize`
  - **Impact**: Non-blocking, affects only policy reports
  - **Workaround**: Can be safely ignored for demo purposes

### Version-Specific Notes
- **Kubernetes 1.33**: First stable release with in-place pod resize (Beta)
- **Kyverno 1.15.2**: Supports Pod/resize resource validation
- **containerd 1.6.9+**: Required for proper cgroup v2 support

## 🔮 Upgrade Path

### Next Versions to Watch
- **Kubernetes 1.34**: Expected VPA integration with in-place resize
- **Kyverno 1.16+**: Enhanced Pod/resize permissions and reporting
- **containerd 1.7+**: Improved memory management for resize operations

### Upgrade Recommendations
1. **Test in development** before upgrading production
2. **Backup Kyverno policies** before Kyverno upgrades
3. **Monitor resize operations** after Kubernetes upgrades
4. **Update documentation** when component versions change

## 📝 Maintenance

### Update Schedule
- **Monthly**: Check for Kubernetes patch versions
- **Quarterly**: Evaluate Kyverno updates
- **As needed**: Update based on security advisories

### Testing Protocol
1. Deploy demo in test environment
2. Run complete test suite (`./test-resize.sh`)
3. Verify all governance policies work
4. Update this document with results

**Last Updated**: September 27, 2025  
**Next Review**: December 27, 2025  
**Maintainer**: [Your Name]
