# Educational & Free-Tier Optimized AKS Cluster (Terraform)

This Terraform project provisions a lightweight, cost-optimized Azure Kubernetes Service (AKS) cluster specifically tailored for learning, experimentation, and education.

## Cost & Educational Optimization Highlights

- **Control Plane Cost ($0 / Free Tier)**: Uses `sku_tier = "Free"` which eliminates the standard Azure cluster management fee (~$73/month).
- **Single Worker Node**: Configured with a single `Standard_D2s_v4` VM (2 vCPU, 8 GiB RAM), keeping compute spend minimal while fitting within standard Azure subscription vCPU quotas.
- **Consolidated Node Architecture**: System pool allows application/learner pods (`only_critical_addons_enabled = false`), eliminating the need for expensive multi-pool setups.
- **Immediate `kubectl` Access**: `local_account_disabled = false` allows immediate connection using `az aks get-credentials` without complex Microsoft Entra ID enterprise directory setups.
- **Zero Database Charges**: Excludes cloud-managed PostgreSQL Flexible Server instances to prevent unexpected hourly database costs.
- **Modern Networking**: Azure CNI Overlay with Azure Network Policy.

---

## Prerequisites

1. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in:
   ```powershell
   az login
   az account show
   ```
2. [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.6.0) installed.
3. [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.

---

## Deployment Steps

### 1. Initialize and Validate Terraform

```powershell
terraform fmt
terraform init
terraform validate
```

### 2. Preview the Plan

```powershell
terraform plan
```

### 3. Deploy the Cluster (When Ready)

```powershell
terraform apply
```

---

## Connecting to the AKS Cluster

Once Terraform completes, retrieve the credentials:

```powershell
az aks get-credentials --resource-group mahesh-aks-edu-rg --name mahesh-aks-edu --overwrite-existing
```

Verify your cluster connection:

```powershell
kubectl get nodes -o wide
```

---

## Deploy Sample Educational Workload

Deploy a lightweight Nginx web server into the `education` namespace:

```powershell
kubectl apply -f .\k8s\namespace.yaml
kubectl apply -f .\k8s\deployment.yaml
kubectl apply -f .\k8s\service.yaml
```

Check the running pods and external IP:

```powershell
kubectl get pods -n education
kubectl get svc -n education -w
```

---

## Clean Up (Destroy Resources to Incur $0)

When you are done with your learning session, cleanly destroy all resources so you do not incur ongoing compute costs:

```powershell
terraform destroy -auto-approve
```
