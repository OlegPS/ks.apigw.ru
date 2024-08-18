# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "vsphere-iso" "packer-redos-x86_64" {
  vcenter_server      = "${var.vcenter_host}"
  password            = "${var.vcenter_password}"
  username            = "${var.vcenter_username}"
  insecure_connection = true
  host                = "${var.host}"
  firmware            = "efi"
  CPUs                = 2
  cpu_cores           = 2
  CPU_hot_plug        = true
  RAM                 = 4096
  RAM_hot_plug        = true
  boot_command = [
    "c<wait>",
    "linuxefi /images/pxeboot/vmlinuz inst.ks=hd:LABEL=kickstart inst.kdump_addon=off quiet<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter>"
  ]
  boot_wait     = "10s"
  guest_os_type = "otherLinux64Guest"
  cd_files      = ["./../.config/ks.cfg"]
  cd_label      = "kickstart"
  iso_checksum  = "file:https://files.red-soft.ru/redos/8.0/x86_64/iso/redos-8-20240218.1-Everything-x86_64-DVD1.iso.MD5SUM"
  iso_urls      = ["./iso/redos-8-20240218.1-Everything-x86_64-DVD1.iso", "https://files.red-soft.ru/redos/8.0/x86_64/iso/redos-8-20240218.1-Everything-x86_64-DVD1.iso"]
  storage {
    disk_size             = 40000
    disk_thin_provisioned = true
  }
  network_adapters {
    network      = "${var.network}"
    network_card = "vmxnet3"
  }
  #shutdown_command = "sudo -S /usr/sbin/shutdown -h now"
  ssh_username         = "redos"
  ssh_private_key_file = "./../.config/eddsa.key"
  vm_name              = "packer-redos-x86_64"
}
