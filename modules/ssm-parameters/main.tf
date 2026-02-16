resource "aws_ssm_parameter" "parameters" {
  for_each = var.parameters

  name        = each.key
  description = lookup(each.value, "description", null)
  type        = lookup(each.value, "type", "SecureString")
  value       = each.value.value
  overwrite   = true

  tags = var.tags
}

variable "parameters" {
  description = "A map of parameters to create"
  type        = any
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
