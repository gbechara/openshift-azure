This work is based on https://github.com/WilliamRedHat/openshift-Azure

# RedHat Openshift 3.4 cluster on Azure

When creating the RedHat Openshift 3.4 cluster on Azure, you will need a SSH RSA key for access.

## Deploying OpenShift Container Platform 

Deploying OpenShift Container Platform 3.4 on Azure is done following 2 easy steps :
- Create the VMs to host an OpenShift installation
- Use Ansible to install OpenShift Container Platform 3.4 

## Step 1 - Create the cluster on the Azure Portal 

Click on Deploy to Azure then you will be redirected to your Azure account 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgbechara%2Fopenshift-azure%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FWilliamRedHat%2Fopenshift-azure%2Frhel%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Wait for the installation to be ready this will consist of having one infra node, one master and a number of nodes. Then go to the group that contains those machines and get the "OPENSHIFT MASTER SSH" command line that you will need for the next step.

## Step 2 - Install Openshift with Ansible

On the OpenShift the topology, you just created connect to the master machine using ssh.  Use first 

```
[username@localmachine ~]$ ssh-add 
```
so that the SSH forwarding Agent will forward the necesssary data to the script that will then install openshift.

Then connect using your user name added to the ssh command line resulting from Step 1. Example

```
[username@localmachine ~]$ ssh -A gabriel@52.236.242.244

```
Then on the master you will need to run this script

```
[adminUsername@master ~]$ ./openshift-install.sh

```

## Step 3 - Usage

User console of OpenShift is available on the master FQDN that will be constructed based on "Master Dns Name" param, example :
```
http://MASTERDNSNAME.westeurope.cloudapp.azure.com:8443/console/
```

GitLab and nexus is available on the Utils FQDN that will be constructed based on "Utils Dns Name" param, example :
```
http://UTILSDNSNAME.westeurope.cloudapp.azure.com
http://UTILSDNSNAME.westeurope.cloudapp.azure.com:8081/nexus
```


## Alternative methods to Step 1

### Alternative method 1 - Create the cluster with powershell

```powershell
New-AzureRmResourceGroupDeployment -Name <DeploymentName> -ResourceGroupName <RessourceGroupName> -TemplateUri https://raw.githubusercontent.com/WilliamRedHat/openshift-azure/rhel/azuredeploy.json
```
### Alternative method 2 - Create the cluster with Azure CLI on RHEL 7.2

#### Install Azure CLI
Use the knowledge base article : https://access.redhat.com/articles/1994463

#### Use the Azure CLI
```

[username@localmachine ~]$ git clone https://github.com/WilliamRedHat/openshift-azure.git
[username@localmachine ~]$ cd ~/openshift-azure/
```

Update the azuredeploy.parameters.json file with your parameters

Create a resource group :

```
  [username@localmachine ~]$ azure config mode arm
  [username@localmachine ~]$ azure location list
  [username@localmachine ~]$ azure group create -n "RG-OSE32" -l "West US"
  [username@localmachine ~]$ azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json RG-OSE32 dnsName

```
The output of the previous commmand line contains the connection strings :

```
  data:    Outputs            :
  data:    Name                        Type    Value                                       
  data:    --------------------------  ------  --------------------------------------------
  data:    openshift Webconsole        String  https://ose32.westus.cloudapp.azure.com:8443
  data:    openshift Master ssh        String  ssh -A 13.91.51.205                         
  data:    openshift Router Public IP  String  13.91.101.166                               
  info:    group deployment create command OK

```

## Configure NFS storage
FIXME : add pv / pvc

```
[adminUsername@infranode ~]$ sudo su -
[adminUsername@infranode ~]$ yum install nfs-utils  rpcbind
[adminUsername@infranode ~]$ systemctl enable nfs-server
[adminUsername@infranode ~]$ systemctl enable rpcbind
[adminUsername@infranode ~]$ mkdir /exports
[adminUsername@infranode ~]$ vim /etc/exports
[adminUsername@infranode ~]$ systemctl start nfs-server
[adminUsername@infranode ~]$ exportfs -r
```

## Parameters

### Input Parameters

| Name          | Type          | Description                                      |
| ------------- | ------------- | -------------------------------------------------|
| adminUsername | String        | Username for SSH Login and Openshift Webconsole  |
| adminPassword | SecureString  | Password for the Openshift Webconsole            |
| sshKeyData    | String        | Public SSH Key for the Virtual Machines          |
| masterDnsName | String        | DNS Prefix of Openshift Master / Webconsole      |
| utilsDnsName  | String        | DNS Prefix of Utilities : GitLab and Nexus & NFS |
| numberOfNodes | Integer       | Number of Openshift Nodes to create              |
| image         | String        | Operating System to use. RHEL or CentOs          |
| rhnUser       | String        | Red Hat Network user id                          |
| rhnPass       | SecureString  | Red Hat Network password                         |
| rhnPool       | String        | Red Hat Network pool id                          |


### Output Parameters

| Name| Type                 | Description  |
| -------------------------- | ------------ | -------------------------------------------------------------------- |
| openshift Webconsole       | String       | URL of the Openshift Webconsole                                      |
| openshift Master ssh       | String       | SSH String to Login at the Master                                    |
| openshift Router Public IP | String       | Router Public IP. Needed if you want to create your own Wildcard DNS |

