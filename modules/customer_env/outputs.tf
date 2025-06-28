output "resource_tags" {
  value       = local.common_tags
  description = "Use these tags in Azure Cost Management to filter and estimate cost per environment/customer."
}
