# Azure VM Scale Set with Load Balancer, NSG, and Monitoring

This Terraform module provisions an Azure Virtual Machine Scale Set (VMSS) behind a Standard Load Balancer with HTTP health probes, autoscaling based on CPU usage, NGINX installation with a custom homepage, and full Azure Monitor integration for diagnostics and logging.

---

##  Features

- VNet and subnet with Network Security Group (NSG) allowing HTTP traffic
- Load Balancer with public IP, backend pool, health probe, and LB rule
- VM Scale Set with custom startup script to install and configure NGINX
- Autoscaling based on CPU utilization thresholds
- Azure Monitor Agent with syslog-based NGINX logging to Log Analytics
- Diagnostics collection for system and application insights

---


## Modules

### 1. `network`
Responsible for creating the network infrastructure:
- Virtual Network (VNet)
- Subnet
- Network Security Group (NSG) with HTTP ingress rule
- Public IP for Load Balancer
- Load Balancer (Standard SKU)
    - Backend Address Pool
    - Health Probe
    - Load Balancing Rule

**Outputs:**
- `subnet_id`
- `lb_backend_pool_id`

---

### 2. `compute`
Handles the compute resources:
- Virtual Machine Scale Set (VMSS)
    - Ubuntu image with custom NGINX startup script
    - SSH public key for authentication
    - NIC integration with backend pool
- Auto Scaling based on CPU usage

**Outputs:**
- `vmss_id`

---

### 3. `monitoring`
Sets up monitoring and observability:
- Log Analytics Workspace
- Azure Monitor diagnostics for VMSS
- Azure Monitor Agent (AMA) extension
- Data Collection Rule (DCR) for syslog (NGINX logs)
- DCR Association with VMSS

**Outputs:**
- `log_analytics_workspace_id`

---


##  Deployment

```hcl
module "azure_vmss_nginx" {
  source = "./path-to-this-module"

  prefix            = "myapp"
  location          = "West Europe"
  address_space     = ["10.0.0.0/16"]
  subnet_prefix     = ["10.0.1.0/24"]
  vm_instance_count = 2
}
```

---

##  Testing and Validation

### 1.  Access NGINX via Load Balancer

```bash
curl http://<lb_public_ip>
```

- Replace `<lb_public_ip>` with the Terraform output `lb_public_ip`.
- You should see a response showing the hostname of one of the VMs.

---

### 2.  SSH into VM

> VMSS instances typically do **not** have public IPs for direct access. Use one of the following methods:

#### Use Azure Bastion 

1. Go to Azure Portal → VMSS → Instances
2. Select an instance → Click **Connect** → Choose **Bastion**
3. Use your SSH private key (`~/.ssh/id_rsa`) and user `azureuser`


---

### 3.  Test Autoscaling

#### Scale-Out: Trigger CPU Load

```bash
sudo apt-get install -y stress
stress --cpu 2 --timeout 300  # Run CPU stress for 5 mins
```

- This will raise the CPU above the 70% threshold
- Watch autoscale in the Azure Portal → VMSS → Instances

#### Scale-In: Let Load Drop

- Once the stress test finishes, the average CPU drops
- VMSS will scale in after ~5 minutes if CPU stays below 30%

---

### 4.  Validate Monitoring & Logs

#### Log Analytics

1. Go to **Log Analytics Workspace**
2. Run this Kusto query:

```kusto
Syslog
| where Facility == "user"
| sort by TimeGenerated desc
```

You should see:
- NGINX access and error logs
- Startup script logs tagged with `user-data`

#### Metrics Dashboard

1. Navigate to **VMSS → Monitoring → Metrics**
2. Set namespace to `Microsoft.Compute/virtualMachineScaleSets`
3. View **Percentage CPU** to verify scaling behavior

---

##  Output

```hcl
output "web_vm_public_ip" {
  value = module.network.web_vm_public_ip
}

```

---

##  Inputs

| Name              | Description                                | Type            | Required |
|-------------------|--------------------------------------------|------------------|----------|
| `prefix`          | Prefix for naming Azure resources           | `string`         | ✅       |
| `location`        | Azure region                               | `string`         | ✅       |
| `address_space`   | VNet address space                         | `list(string)`   | ✅       |
| `subnet_prefix`   | Subnet CIDR range                          | `list(string)`   | ✅       |
| `vm_instance_count` | Initial number of VM instances           | `number`         | ✅       |

---

##  License

MIT
