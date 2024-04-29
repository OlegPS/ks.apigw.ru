# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vsphere = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}
