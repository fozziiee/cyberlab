# modules/win_workstation/variables.tf

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "lab_creds_url" {
  type = string
}

variable "domain_name" {
  type = string
}


