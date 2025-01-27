#! /bin/sh

set -e

if [ ! -f id_rsa ]; then
	curl -o id_rsa https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant
fi

hash=$(sha256sum ignition-staticip.cfg | awk '{ print $1 }')

packer build -var-file vars.json -var ignition_hash="sha256-$hash" fedora-coreos.pkr.hcl
