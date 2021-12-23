terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.16.0"
    }
  }
}

provider "linode" {
    token = var.token
}

resource "linode_instance" "example_instance" {
    label = "example_instance_ubuntu-eu-west"
    image = "linode/ubuntu20.04"
    region = "eu-west"
    type = "g6-nanode-1"
    root_pass = var.root_pass

    provisioner "file" {
      source = "setup_script.sh"
      destination = "/tmp/setup_script.sh"
      connection {
	type      = "ssh"
        host      = self.ip_address
        user      = "root"
        password  = var.root_pass
      }
    }

    provisioner "remote-exec" {
       inline = [
        "chmod +x /tmp/setup_script.sh",
        "/tmp/setup_script.sh",
        "sleep 1"
      ]

      connection {
        type      = "ssh"
        host      = self.ip_address
        user      = "root"
        password  = var.root_pass
      }


    }
}

resource "linode_domain" "example_domain" {
  domain   = "nextcloud.devilsan.com"
  soa_email= "skysan@gmail.com"
  type     = "master"
}

resource "linode_domain_record" "example_domain_record" {
  domain_id  =  linode_domain.example_domain.id
  name       = "nextcloud"
  record_type= "A"
  target     = linode_instance.example_instance.ip_address
  ttl_sec    = 300
}


/*resource "linode_firewall" "example_firewall" {

  label = "example_firewall_label"

  inbound {
    label    =  "allow-http"
    action   =  "ACCEPT"
    protocol =  "TCP"
    ports    =  "80"
    ipv4     =  ["0.0.0.0/0"]
    ipv6     =  ["ff00::/8"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.example_instance.id]

}*/


variable "token" {}
variable "root_pass" {}
