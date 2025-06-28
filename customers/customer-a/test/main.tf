module "customer_env" {
  source         = "../../../modules/customer_env"
  customer_name  = "customer-a"
  environment    = "test"
  location       = "westeurope"
  ssh_public_key = var.ssh_public_key
}
