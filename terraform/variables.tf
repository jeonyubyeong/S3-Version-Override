variable "profile" {
  description = "The AWS profile to use."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources to."
  default     = "us-east-1"
  type        = string
}

variable "cgid" {
  description = "CloudGoat unique identifier."
  type        = string
}

variable "cg_whitelist" {
  description = "User's public IP address(es)"
  type        = list(string)
}

variable "flag_value" {
  description = "The flag to be shown when index.html is restored."
  default     = "FLAG{restored-secret-admin-index}"
  type        = string
}

variable "stack_name" {
  description = "Name of the stack."
  default     = "CloudGoat"
  type        = string
}

variable "scenario_name" {
  description = "Name of the scenario."
  default     = "s3-version-override"
  type        = string
}