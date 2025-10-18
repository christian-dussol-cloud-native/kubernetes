# Kubernetes Carousels Collection

Collection of visual presentations (carousels) showcasing advanced Kubernetes features.

## 📚 Carousel Inventory

### 1. In-Place Pod Resize - Kubernetes 1.33
**File:** `InPlace-PodResize.pdf`  
**Topic:** Pod resizing without restart
**K8s Version:** 1.33
**Date:** September 2025

**Key Topics Covered:**
- 🔧 `resizePolicy` configuration for CPU and memory
- ⚖️ Triple scaling strategy (HPA, VPA, CA)
- 🛡️ Governance with Kyverno
- ✅ Old vs New approach comparison (zero downtime)
- 🚀 Complete technical demo on GitHub

**Demo Link:** [https://bit.ly/4mF1P2Q](https://bit.ly/4mF1P2Q)

**Related Medium Article:** [Kubernetes 1.33: How In-Place Pod Resize Brings Significant Improvement to Vertical Scaling](https://medium.com/@christian.dussol/kubernetes-1-33-how-in-place-pod-resize-brings-significant-improvement-to-vertical-scaling-7a2da0380b7d)

---

### 2. Kubernetes Command Reference Guide
**File:** `Kubernetes - Command reference guide.pdf`  
**Topic:** The complete kubectl command reference  
**Date:** October 2025

**What's Inside:**
- 📋 **Top 30 essential commands** organized by role and workflow
- 👨‍💻 **Developer essentials:** Quick pod creation, YAML templates, port-forwarding
- ⚙️ **Admin power commands:** Node maintenance, RBAC, resource quotas
- 🔒 **Security must-haves:** Pod Security Standards, secrets, network policies
- 🔧 **Troubleshooting workflows:** Debug containers, logs analysis, resource inspection
- 💡 **Pro tips:** Essential aliases, autocompletion, kubectl explain

**Key Takeaways:**
- 🎯 Organize commands by workflow, not alphabetically
- ⚡ Use imperative commands + dry-run for maximum speed
- 🔐 Automate security enforcement with Kyverno policies
- 📊 Always monitor resource usage before issues happen
- 🛠 Practice troubleshooting in dev, not production

**Get the Complete Cheat Sheet:** [https://bit.ly/46EQ87s](https://bit.ly/46EQ87s)
- ✅ 100+ production-ready commands
- ✅ All sections with detailed examples
- ✅ Security best practices
- ✅ Troubleshooting workflows
- ✅ Kyverno policy templates
- ✅ Complete monitoring guide
- 💻 Available in GitHub Markdown format

**Related Medium Article:** [How I Built My Kubernetes Command Toolkit](https://medium.com/@christian.dussol/how-i-built-my-kubernetes-command-toolkit-a-journey-from-kubectl-chaos-to-command-mastery-dad81c91327a)

---

#### 3. Kubernetes Resource Management
**File:** `Kubernetes-Resource-Management.pdf`  
**Topic:** Complete resource governance with 4-layer architecture  
**Date:** October 2025

**What's Inside:**
- 📊 **The Resource Management Trifecta:** Pod Resources, LimitRange, ResourceQuota
- 🚀 **Layer 4 - Kyverno:** Policy-as-Code automation
- 📝 **Complete YAML examples** for each component
- ⚙️ **4-week implementation roadmap**
- 🔧 **Production-ready configurations**
- 🎯 **Connection to K8s 1.33 in-place pod resizing**

**Key Topics Covered:**
- 🎯 Requests vs Limits explained clearly
- 🛡️ LimitRange guardrails for individual containers
- 📊 ResourceQuota namespace budget control
- 🔄 Complete validation flow
- 🚀 Kyverno auto-remediation examples
- ✅ 4-layer governance stack

**Use Cases:**
- Prevent "exceeded quota" errors
- Stop pods from being rejected
- Enable safe in-place pod resizing (K8s 1.33)
- Multi-tenant cluster governance
- FinOps cost control

**Related Medium Article:** [Why Your Kubernetes Pods Keep Getting Rejected: The Resource Management Guide You Actually Need](https://medium.com/@christian.dussol/why-your-kubernetes-pods-keep-getting-rejected-the-resource-management-guide-you-actually-need-48ea965eb038)

---

## 🎯 Repository Usage

These carousels are designed for:
- **Quick reference** during daily Kubernetes operations
- **Team training** and knowledge sharing
- **Production best practices** based on real-world experience
- **Visual learning** of complex Kubernetes concepts

---

## 👤 Author

**Christian Dussol**
- GitHub: [@ChristianDussol](https://github.com/ChristianDussol)
- LinkedIn: [Christian Dussol](https://www.linkedin.com/in/christiandussol)
- Medium: [@christian.dussol](https://medium.com/@christian.dussol)

---

## 📝 License

These resources are shared for educational purposes. Please reference the original author when sharing.

---

**⭐ If you find these resources helpful, please star this repository!**
