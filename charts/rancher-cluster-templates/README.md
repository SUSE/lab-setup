# Rancher Cluster Templates Helm Chart

This Helm chart gives the possibility to create and manage Kubernetes clusters from Rancher thanks to [Rancher Cluster Templates](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/manage-clusters/manage-cluster-templates).

It was inspired by [bloriot/rancher-cluster-templates](https://github.com/bloriot/rancher-cluster-templates) and [rancher/cluster-template-examples](https://github.com/rancher/cluster-template-examples).

## Quick start

⚠️ Make sure you are connected to the Kubernetes cluster hosting Rancher (name `local` in Rancher)

Create `values_mine.yaml` file (look at [configuration](#configuration) for examples).

Install the app with minimal settings:

```bash
# adds the repo
helm repo add suse-lab-setup https://opensource.suse.com/lab-setup
helm repo update

# installs the chart with default parameters
helm upgrade --install my-cluster suse-lab-setup/rancher-cluster-templates -f values_mine.yaml --namespace fleet-default
```

Clean-up:

```bash
helm uninstall my-cluster -n fleet-default
```

## Infrastructure providers

💡 The node driver for the provider must be enabled in Rancher prior to Helm chart installation

Provider                         | Example                                                  | Template                                                            | Node Driver
---------------------------------|----------------------------------------------------------|---------------------------------------------------------------------|----------------
**Amazon Web Services (AWS)**    | [values_aws](examples/values_aws.yaml)                   | [amazonec2config](templates/amazonec2config.yaml)                   | `Amazon EC2`
[**Azure**](docs/azure.md)       | [values_azure](examples/values_azure.yaml)               | [azureconfig](templates/azureconfig.yaml)                           | `Azure`
**CloudScale**                   | [values_cloudscale](examples/values_cloudscale.yaml)     | [cloudscaleconfig](templates/cloudscaleconfig.yaml)                 | `Cloudscale`
**Digitial Ocean**               | [values_digitalocean](examples/values_digitalocean.yaml) | [digitaloceanconfig](templates/digitaloceanconfig.yaml)             | `DigitalOcean`
**Exoscale**                     | [values_digitalocean](examples/values_digitalocean.yaml) | [digitaloceanconfig](templates/digitaloceanconfig.yaml)             | `Exoscale`
**Equinix Metal (prev. Packet)** | [values_equinix](examples/values_equinix.yaml)           | [packetconfig](templates/packetconfig.yaml)                         | `Equinix Metal`
**Harvester**                    | [values_harvester](examples/values_harvester.yaml)       | [harvesterconfig](templates/harvesterconfig.yaml)                   | `Harvester`
**Linode**                       | [values_linode](examples/values_linode.yaml)             | [linodeconfig](templates/linodeconfig.yaml)                         | `Linode`
**Nutanix**                      | [values_nutanix](examples/values_nutanix.yaml)           | [nutanixconfig](templates/nutanixconfig.yaml)                       | `Nutanix`
**OpenStack**                    | [values_openstack](examples/values_openstack.yaml)       | [openstackconfig](templates/openstackconfig.yaml)                   | `OpenStack`
**Outscale**                     | [values_aws](examples/values_outscale.yaml)              | [outscaleconfig](templates/outscaleconfig.yaml)                     | `Outscale`
**VMware vSphere**               | [values_vsphere](examples/values_vsphere.yaml)           | [vmwarevsphereconfig.yaml](templates/vmwarevsphereconfig.yaml.yaml) | `vSphere`

## Troubleshooting

Follow the steps from the start by looking at the machine-provision job (in `fleet-default` namespace).

In case of issue with remaining Kubernetes resources even after helm uninstall, force delete the machine.

## Automation

### Fleet example for creating RKE2 cluster in Azure

- `fleet.yaml` stored in a Git repository

```yaml
helm:
  repo: https://opensource.suse.com/lab-setup
  chart: rancher-cluster-templates
  version: 0.1.1
  releaseName: rke2-azure-demo
  values:
    cluster:
      name: "azurevm-rke2-01"
    cloudprovider: azure
    cloudCredentialSecretName: cattle-global-data:cc-xxxx
    kubernetesVersion: "v1.24.14+rke2r1"
    nodepools:
      - etcd: true
        controlplane: true
        worker: true
        quantity: 1
        name: nodepool-1
        region: westeurope
        machineImage: "Canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:20.04.202307240"
        instanceType: Standard_DS2_v2
        storageType: Standard_LRS
        sshUser: azureuser
        availabilitySet: "avs-someprefix-rke2-01"
        azureEnvironment: AzurePublicCloud
        managedDisks: true
        networkSecurityGroup: "nsg-someprefix-rke2-01"
        resourceGroup: "rg-someprefix-rke2-01"
        subnet: rke2
        subnetPrefix: "192.168.0.0/16"
        virtualNetwork: "vnet-someprefix-rke2-01"
```

- `GitRepo` Kubernetes object (Rancher > Continuous Delivery)

```yaml
apiVersion: fleet.cattle.io/v1alpha1
kind: GitRepo
metadata:
  name: cluster-templates
  namespace: fleet-local
spec:
  branch: release/demo
  clientSecretName: auth-xxxx
  insecureSkipTLSVerify: false
  paths:
    - fleet/rke2-azure-demo
  repo: https://github.com/my-account/my-kubernetes-definitions.git
  targets:
    - clusterSelector:
        matchExpressions:
          - key: provider.cattle.io
            operator: NotIn
            values:
              - harvester
```

## Configuration

### Azure example

```bash
cp examples/values_azure.yaml values_mine.yaml
resourcekey=$(openssl rand -hex 6)
sed -i "s/CLUSTER_NAME/az-rke2-$resourcekey/g" values_mine.yaml
sed -i "s/AZURE_PREFIX/$USER-$resourcekey/g" values_mine.yaml
sed -i "s/CLOUD_CREDENTIAL_SECRET/<secret_name>/g" values_mine.yaml
```

### Outscale example

```bash
cp examples/values_outscale.yaml values_mine.yaml
resourcekey=$(openssl rand -hex 6)
sed -i "s/CLUSTER_NAME/az-rke2-$resourcekey/g" values_mine.yaml
sed -i "s/CLOUD_CREDENTIAL_SECRET/<secret_name>/g" values_mine.yaml
```
