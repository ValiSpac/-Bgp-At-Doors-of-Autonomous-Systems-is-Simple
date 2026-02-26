#!/usr/bin/env bash

set -eu

#Install gns3
#Can't install it through ppa on Linux Mint 24.04
if ! command -v gns3 > /dev/null 2>&1; then
	echo "deb [signed-by=/etc/apt/keyrings/gns3.gpg] https://ppa.launchpadcontent.net/gns3/ppa/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/gns3.list
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf88f6d313016330404f710fc9a2fd067a2e3ef7b" | sudo gpg --dearmor -o /etc/apt/keyrings/gns3.gpg
	sudo apt update
	sudo apt install -y gns3-gui gns3-server
fi
#Install docker
sudo apt remove -y docker docker-engine docker.io
sudo snap remove docker || true

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt install -y dynamips ubridge vpcs

if [[ ! -f "/etc/apt/keyrings/docker.asc" ]]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL http://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

if [[ ! -f "/etc/apt/sources.list.d/docker.list" ]]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] http://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt install -y docker-ce

sudo usermod -aG ubridge,libvirt,kvm,wireshark,docker $(whoami)

sudo systemctl start docker

#Make sure port for gns3 is not in used, backup port fails 99% of the time
#fuser -k 3080/tcp

#Make sure ubridge can manipulate network interfaces
sudo setcap cap_net_admin,cap_net_raw=eip $(which ubridge)

#build custom docker images
docker build --no-cache -f _vpac_router -t vpac_router .
docker build --no-cache -f _vpac_host -t vpac_host .
