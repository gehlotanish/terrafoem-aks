variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  type        = string
  default     = ""
}

variable "prefix" {
  description = "A prefix used for all resources in this example"
  type        = string
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "client_id" {
  type        = string
  description = "Service Principal ID"
}

variable "client_secret" {
  type        = string
  description = "Service Principal Secret"
}

variable "vm_size" {
  type        = string
  description = "VM size to provision AKS node default 'Standard_B2s'"
  default     = "Standard_B2s"
}

