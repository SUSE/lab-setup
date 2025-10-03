#!/bin/bash

longhorn_install() {
    local hostname=$1
    local version=${2:-1.8.1}
    echo '>>> Setup prerequisites for Longhorn install'
    helm repo add longhorn https://charts.longhorn.io
    helm repo update
    zypper install -y open-iscsi cryptsetup
    systemctl enable --now iscsid.service
    modprobe iscsi_tcp
    echo '=== Check prerequisites'
    curl -k -sSfL -o longhornctl https://github.com/longhorn/cli/releases/download/v${version}/longhornctl-linux-amd64
    chmod +x longhornctl
    ./longhornctl check preflight
    echo '=== Install LongHorn'
    helm upgrade -i --version $version longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set ingress.enabled=true --set ingress.host=$hostname --set persistence.migratable=true --set longhornUI.replicas=1
    echo "<<< Longhorn should be available in a few minutes in: $hostname"
}
