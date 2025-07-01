# Azure VM Scale Set with Load Balancer, NSG, and Monitoring

This Terraform module provisions an Azure Virtual Machine Scale Set (VMSS) behind a Standard Load Balancer with HTTP health probes, autoscaling based on CPU usage, NGINX installation with a custom homepage, and full Azure Monitor integration for diagnostics and logging.

---

## ✅ Features

- VNet and subnet with Network Security Group (NSG) allowing HTTP traffic
- Load Balancer with public IP, backend pool, health probe, and LB rule
- VM Scale Set with custom startup script to install and configure NGINX
- Autoscaling based on CPU utilization thresholds
- Azure Monitor Agent with syslog-based NGINX logging to Log Analytics
- Diagnostics collection for system and application insights

---

## 🚀 Deployment

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

## 🧪 Testing and Validation

### 1. 🔗 Access NGINX via Load Balancer

```bash
curl http://51.136.29.217
```

- Replace `<lb_public_ip>` with the Terraform output `lb_public_ip`.
- You should see a response showing the hostname of one of the VMs.

---

### 2. 🔐 SSH into VM

> VMSS instances typically do **not** have public IPs for direct access. Use one of the following methods:

#### Use Azure Bastion 

1. Go to Azure Portal → VMSS → Instances
2. Select an instance → Click **Connect** → Choose **Bastion**
3. Use your SSH private key (`~/.ssh/id_rsa`) and user `azureuser`


---

### 3. 📈 Test Autoscaling

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

### 4. 📊 Validate Monitoring & Logs

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

## 📥 Output

```hcl
output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}
```

---

## 🧾 Inputs

| Name              | Description                                | Type            | Required |
|-------------------|--------------------------------------------|------------------|----------|
| `prefix`          | Prefix for naming Azure resources           | `string`         | ✅       |
| `location`        | Azure region                               | `string`         | ✅       |
| `address_space`   | VNet address space                         | `list(string)`   | ✅       |
| `subnet_prefix`   | Subnet CIDR range                          | `list(string)`   | ✅       |
| `vm_instance_count` | Initial number of VM instances           | `number`         | ✅       |

---

## 📄 License

MIT
