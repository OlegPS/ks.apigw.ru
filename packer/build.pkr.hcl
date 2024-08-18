# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["vsphere-iso.packer-redos-x86_64"]

  provisioner "shell" {
    script = "provision/redos-configure.sh"
  }
}
