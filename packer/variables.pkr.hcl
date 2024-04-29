# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "vcenter_host" {
  type    = string
  default = "10.10.10.10"
}

variable "vcenter_username" {
  type    = string
  default = "root"
}

variable "vcenter_password" {
  type      = string
  default   = "passwd"
  sensitive = true
}

variable "host" {
  type    = string
  default = "esxi.example.com"
}

variable "network" {
  type    = string
  default = "VM Network"
}
