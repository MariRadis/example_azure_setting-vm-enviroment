output "vmss_id" {
  value = module.vmss.vmss_id
}

output "public_ip" {
  value = module.load_balancer.lb_public_ip
}
