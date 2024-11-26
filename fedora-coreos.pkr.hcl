packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "ignition_hash" {
  type = string
}

variable "ignition_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "raw_url" {
  type = string
}

source "virtualbox-iso" "fedora-coreos" {
  boot_command         = [
    "<enter>",
    "<wait30s>",
    "sudo /usr/bin/coreos-installer install -I ${var.ignition_url} --ignition-hash ${var.ignition_hash} -u ${var.raw_url} /dev/sda",
    "<enter>",
    "<wait5m>",
    "reboot",
    "<enter>",
    "<wait30s>"
  ]
  boot_wait            = "5s"
  guest_os_type        = "Linux_64"
  iso_checksum         = "sha256:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = 3072
  shutdown_command     = "sudo /sbin/shutdown -P -h now"
  ssh_private_key_file = "id_rsa"
  ssh_username         = "vagrant"
}

build {
  sources = ["source.virtualbox-iso.fedora-coreos"]

  post-processor "vagrant" {
    compression_level = 9
    output            = "fedora-coreos.box"
  }
}
