#!/usr/bin/env bash
set -e

sudo apt update
sudo apt -y upgrade

echo "installing dependencies for the project..."
sudo apt -y install curl wget git ca-certificates apt-transport-https software-properties-common lsb-release gnupg net-tools iproute2 telnet xterm

echo "installing docker..."
if ! command -v docker >/dev/null 2>&1; then
	curl -fsSL https://get.docker.com | sudo sh
fi

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

echo "installing gns3..."
sudo add-apt-repository -y ppa:gns3/ppa
sudo apt update
sudo apt -y install gns3-gui gns3-server dynamips ubridge vpcs

if command -v ubridge >/dev/null 2>&1; then
	sudo setcap cap_net_admin,cap_net_raw=ep "$(which ubridge)" || true
fi

echo "pulling images for alping and frr..."
sudo docker pull alpine
sudo docker pull frrouting/frr

echo "done installing"
