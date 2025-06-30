# Azure NGINX Web App with Load Balancer (Terraform)

This project deploys a simple NGINX-based web application on a **Virtual Machine Scale Set (VMSS)** behind a **Standard Azure Load Balancer**, using **Terraform** for full automation and reproducibility.

---

## Features

* Linux VMSS running NGINX via startup script (`custom_data`)
* Standard Load Balancer with:

   * Public IP
   * Backend Address Pool
   * Health Probe on port 80
   * Load Balancer Rule for HTTP traffic
   * Optional NAT rules for SSH
* Secure, private VMs (no public IPs)
* NAT-enabled outbound internet access
* Modular and reusable Terraform code

---

## Prerequisites

* An active Azure subscription
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in:

  ```bash
  az login
  az account set --subscription "Your Subscription Name or ID"
  ```
* [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.9 or newer
* Terraform backend configured (e.g., via `backend.config`)

---

## Project Structure

```text
.
├── apply.sh                     # Deploys infrastructure
├── destroy.sh                   # Destroys infrastructure
├── backend.config               # Remote state backend config
├── main.tf / variables.tf / outputs.tf
├── modules/
│   ├── vpc/                     # VNet, subnet, NAT, firewall rules
│   ├── compute/                 # VMSS, startup script, identity
│   └── load_balancer/          # Load Balancer, probe, rules, public IP
```

---

## Deployment

### 1. Initialize Terraform

```bash
terraform init -backend-config="backend.config"
```

### 2. Deploy Infrastructure

```bash
./apply.sh
```

This provisions:

* A virtual network and subnet
* A Linux VMSS with NGINX
* A Standard Load Balancer
* Optional NAT rules for SSH access

---

## Access the Web App

After deployment, get the public IP:

```bash
terraform output -raw http_url
```

Open it in your browser — you should see:

```
Hello from <instance-hostname>
```

This verifies:

* Load balancer routing works
* Health probe sees VM as healthy
* NGINX is running on the VMSS

---

## SSH Access (via NAT rule)

> VMSS instances do not have public IPs. SSH is enabled through a NAT rule on the Load Balancer.

1. Get the load balancer IP and NAT frontend port:

   ```bash
   terraform output -raw http_url     # Public IP
   # Check module or Azure Portal for NAT port (e.g., 50000)
   ```

2. Connect:

   ```bash
   ssh azureuser@<public-ip> -p <nat-port>
   ```

3. Inside the VM:

   ```bash
   curl localhost
   sudo systemctl status nginx
   ping google.com   # Test NAT access
   ```

---

## Manual Testing

### Port reachability:

```bash
nc -zv <public-ip> 22   # SSH
nc -zv <public-ip> 80   # HTTP
nc -zv <public-ip> 443  # HTTPS (if applicable)
```

## Simulate Failures (Auto-heal)

Kill the VM instance in Azure Portal or CLI and watch it self-heal:

```bash
az vmss list-instances --resource-group <rg> --name <vmss-name>
az vmss delete-instances --resource-group <rg> --name <vmss-name> --instance-ids <id>
```

Then access the web app again — a new instance should be recreated and available behind the load balancer.

---

## 🦼️‍♂️ Tear Down

```bash
./destroy.sh
```

---

## Security

* No public IPs on VM instances
* SSH access controlled via NAT rules on specific frontend ports
* Inbound rules limited to HTTP (80) and SSH (22)
* NAT gateway (optional) enables outbound internet securely

---

## Notes

* NGINX is installed using `custom_data` at VMSS boot time
* Backend address pool is connected via `load_balancer_backend_address_pool_ids` in the VMSS
* All resources are created via separate modules and can be reused across environments

---

##License

MIT License
