#!/bin/bash

longhorn_install() {
    local hostname=$1
    echo '>>> Setup prerequisites for Longhorn install'
    helm repo add longhorn https://charts.longhorn.io
    helm repo update
    zypper install -y open-iscsi cryptsetup
    systemctl enable --now iscsid.service
    modprobe iscsi_tcp
    echo '=== Check prerequisites'
    curl -k https://raw.githubusercontent.com/longhorn/longhorn/refs/heads/master/scripts/environment_check.sh 2>/dev/null | bash || exit 1
    echo '=== Install LongHorn'
    helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set ingress.enabled=true --set ingress.host=$hostname --set persistence.migratable=true --set longhornUI.replicas=1
    echo '<<< Longhorn should be available in a few minutes in: $hostname"
}
