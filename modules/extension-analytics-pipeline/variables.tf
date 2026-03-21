variable "region" {
  description = "AWS region for Glue schema configuration"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all resource names (e.g. bulavka, sidethreadgpt)"
  type        = string
}
