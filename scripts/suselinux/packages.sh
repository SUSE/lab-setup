#!/bin/bash
# Collection of functions to manage packages on SUSE Linux distributions

#######################################
# Install kubectl (Kubernetes CLI) on SUSE Linux
# Arguments:
#   kubernetesVersion
# Examples:
#   suselinux_install_kubectl 'v1.30'
#######################################
suselinux_install_kubectl() {
  local kubernetesVersion=$1

  # adds keys for new packages to be installed
  cat <<EOF | sudo tee /etc/zypp/repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$kubernetesVersion/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$kubernetesVersion/rpm/repodata/repomd.xml.key
EOF

  # refreshes packages and import new keys
  zypper --gpg-auto-import-keys refresh

  # installs Kubernetes CLI
  zypper install -y kubectl
}

#######################################
# Install kubectl (Kubernetes CLI) on SUSE Linux
# Examples:
#   suselinux_install_kubectl
#######################################
suselinux_install_helm() {
  zypper install -y helm
}

#######################################
# Install git on SUSE Linux
# Examples:
#   suselinux_install_kubectl
#######################################
suselinux_install_git() {
  zypper install -y git
}

#######################################
# Install open-iscsi on SUSE Linux
# Examples:
#   suselinux_install_openiscsi
#######################################
suselinux_install_openiscsi() {
  zypper --gpg-auto-import-keys -q refresh
  zypper --gpg-auto-import-keys -q install -y open-iscsi
  systemctl -q enable iscsid
  systemctl start iscsid
  modprobe iscsi_tcp
}

#######################################
# Install Podman on SUSE Linux
# Examples:
#   suselinux_install_kubectl
#######################################
suselinux_install_podman() {
  zypper install -y podman
}
