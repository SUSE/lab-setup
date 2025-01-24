#!/bin/bash

observability_platform_generate_values() {
  local host=$1
  local license=$2
  local password=$3
  local values_dir=$4
  helm template --set license=$license \
    --set baseUrl=$host \
    --set adminPassword=$password \
    --set sizing.profile=trial \
    suse-observability-values suse-observability/suse-observability-values \
    --output-dir $values_dir

  cat << EOF > $values_dir/suse-observability-values/templates/ingress_values.yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  hosts:
    - host: $host
  tls:
    - hosts:
      - $host
    secretName: tls-secret
EOF
}

observability_platform_bootstrap_token() {
  local token=$1
  local values_dir=$2

  cat << EOF > $values_dir/suse-observability-values/templates/bootstrap_token.yaml
stackstate:
  authentication:
    serviceToken:
      bootstrap:
        token: $token
        roles: ["stackstate-k8s-troubleshooter", "stackstate-admin", "stackstate-k8s-admin"]
EOF
}

observability_platform_install() {
  local values_dir=$1
  helm upgrade --install --namespace suse-observability --create-namespace \
  --values $values_dir/suse-observability-values/templates/baseConfig_values.yaml \
  --values $values_dir/suse-observability-values/templates/sizing_values.yaml \
  --values $values_dir/suse-observability-values/templates/ingress_values.yaml \
  --values $values_dir/suse-observability-values/templates/bootstrap_token.yaml \
  suse-observability suse-observability/suse-observability
}

observability_platform_wait_ready() {
  echo ">>> Waiting for SUSE Observability to be ready"
  kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=suse-observability -n suse-observability --timeout=300s
  if [ $? -ne 0 ]; then
    echo ">>> SUSE Observability is not ready"
    NON_RUNNING=$(kubectl get pods -n suse-observability -o json | jq -r '[.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded") | {name: .metadata.name, status: .status.phase}]')
    echo "Pods not running yet: $NON_RUNNING"
  else
    # # Wait for Observability URL available
    _counter=0
    while [[ $_counter -lt 50 ]]; do
        curl -sSfk $OBSERVABILITY_URL/api > /dev/null
        if [ $? -eq 0 ]; then
            break
        fi
        ((_counter++))
        echo "Waiting for Observability URL to be available... attempt ${_counter}/50"
        sleep 5
    done

    if [[ $_counter -ge 50 ]]
    then
      # Exit with error should be uncommented for production labs.
      echo ">>> TIME OUT for Observability URL to be available"
      # exit 69
    else
      echo ">>> Observability at '$OBSERVABILITY_URL' is available!"
    fi
  fi
  echo ">>> SUSE Observability is ready"

}
