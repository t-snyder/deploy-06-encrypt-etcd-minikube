# Restart minikube from a stop or crash - configure the settings to your requirements and hardware
minikube start --cpus 4 --memory 12288 --vm-driver kvm2 --disk-size 100g --insecure-registry="192.168.39.0/24"

# Set the WORKDIR to a local directory which contains the kube deployment files and 
# in later steps the generated keys for vault. Mount this directory to the minikube 
# /data directory.
WORKDIR=/media/tim/ExtraDrive1/Projects/learn-06-encrypt-etcd-minikube
minikube mount $WORKDIR/kube:/data

# Go to a 2nd terminal - ssh into the running minikube instance
minikube ssh

# At the minikube prompt - switch to sudo
sudo -i

# Change to /etc/kubernetes directory within the minikube environment
cd /etc/kubernetes

# Create the directory to hold the apiserver encryption config file and go to it.
mkdir enc
cd enc

# Copy the encryptConfig.yaml from your local machine directory which has been mounted
# in the /data directory of the minikube environment to this new directory.
cp /data/encryptConfig.yaml .

# Now change to the /etc/kubernetes/manifests directory. There you should be able to 
# see the kube-apiserver.yaml file. The minikube processes watch this file for changes.
# When the yaml is changed the kube-apiserver-minikube pod will be reapplied.
cd ../manifests

# Edit the apiserver.yaml to enable etcd encryption
vi kube-apiserver.yaml

# There are 3 additions that need to be made. 
# The first - add the following line to the spec.containers.command arguments
    - --encryption-provider-config=/etc/kubernetes/enc/encryptConfig.yaml  # add this line

# The second - add an additional volumeMounts
    - mountPath: /etc/kubernetes/enc
      name: enc
      readOnly: true

# The third - add an additional volume to the volumes
  - hostPath:
      path: /etc/kubernetes/enc
      type: DirectoryOrCreate
    name: enc

# Save and quit
{ESC}:wq

exit {sudo}
exit {ssh}

# Determine when the kube-apiserver-minikube pod has restarted with the new config
kubectl get pods -n kube-system

# Once it is restarted
minikube addons enable dashboard
minikube addons enable metrics-server

# Start dashboard
minikube dashboard

# Open a new terminal window.
# Make sure the encrypted etcd is working and display the secret in plaintext. The 
# output should be 'supersecret'.
echo `kubectl get secrets -n default a-secret -o jsonpath='{.data.key1}'` | base64 --decode


# Now we need to unseal the vault pods using the prior generated unseal key(s)
WORKDIR=/media/tim/ExtraDrive1/Projects/learn-hashicorp-vault/vault-tls

#Display the unseal key
jq -r ".unseal_keys_b64[]" ${WORKDIR}/crypto/cluster-keys.json

#Create env variable for the key
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" ${WORKDIR}/crypto/cluster-keys.json) 
 
#Unseal vault-0
echo "Unseal vault-0"
kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY 

#Unseal vault-1
kubectl exec -it -n vault vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY

#unseal vault-2
kubectl exec -it -n vault vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

#Display root token found in cluster-keys.json
jq -r ".root_token" ${WORKDIR}/crypto/cluster-keys.json

export CLUSTER_ROOT_TOKEN=$(cat ${WORKDIR}/crypto/cluster-keys.json | jq -r ".root_token")

#Start a shell into vault-0 and login 
kubectl exec -n vault vault-0 -- vault login $CLUSTER_ROOT_TOKEN

#List the raft peers
kubectl exec -n vault vault-0 -- vault operator raft list-peers

#Review HA status
kubectl exec -n vault vault-0 -- vault status

# Note - If you want to use the vault UI or curl then first go to a different terminal
# and set port forward
kubectl -n vault port-forward service/vault 8200:8200

### Restart is completed
