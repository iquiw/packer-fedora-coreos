#! /bin/sh

set -e

case $# in
4)	local_ip=$1
	static_ip=$2
	gateway=$3
	dns_server=$4
	;;
*)	echo "usage: $0 LOCAL_IP STATIC_IP GATEWAY DNS_SERVER" 1>&2
	exit 1
esac

(cat ignition.yml; sed -e "s,@STATIC_IP@,$static_ip,; s,@GATEWAY@,$gateway,; s,@DNS_SERVER@,$dns_server,;" staticip.tmpl ) |
	butane --pretty --strict > ignition-staticip.cfg

hash=$(sha256sum ignition-staticip.cfg | awk '{ print $1 }')

python3 -mhttp.server -b "$local_ip" &
python_pid=$!

if [ ! -f id_rsa ]; then
	curl -o id_rsa https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant
fi

packer build -var ignition_url="http://$local_ip:8000/ignition-staticip.cfg" -var ignition_hash="sha256-$hash" -var-file vars.json fedora-coreos.pkr.hcl

kill "$python_pid"
