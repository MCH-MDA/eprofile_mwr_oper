#!/bin/bash
#
# install and set up podman

# prepare apt to get podman
declare -x $(grep 'VERSION_ID' /etc/os-release)  # export ubuntu version
ver_no_quotes=$(echo $VERSION_ID | tr -d '"')
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${ver_no_quotes}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${ver_no_quotes}/Release.key" | sudo apt-key add -
sudo apt update

# install podman and dependencies
sudo apt -y install uidmap  # contains newuidmap required for rootless execution of podman
sudo apt -y install fuse-overlayfs  # used as overlay for rootless execution
sudo apt -y install containernetworking-plugins  # for bridge, portmap, firewall and tuning commands
sudo apt -y install podman

# configure podman to use fuse-overlayfs
mkdir -p ~/.config/containers
cat <<EOT >> ~/.config/containers/storage.conf
[storage]
driver = "overlay"
[storage.options]
mount_program = "/usr/bin/fuse-overlayfs"
EOT