# Learn-06-Encrypt-ETCD-minikube

## Prototype Purpose
The purpose of the prototype is to provide a deployment of the Kubernetes Apiserver where the etcd store is
encrypted. This requires the addition of an encryption configuration yaml, and modifications to the default
configuration for the kubernetes apiserver within minikube. As the apiserver configuration is programmatically
generated within minikube, these changes must be made after minikube has started.


## References
  1. https://techexpertise.medium.com/encrypting-the-secret-data-at-etcd-store-on-a-minikube-k8s-cluster-2338c68263a5

## Prototype Infrastructure Used
| Core Infrastructure | Version         |
| --------------- | --------------- |
| Minikube        | 1.34.0          |
| Kubernetes      | 1.31.0          |
| Docker          | 27.2.0          |

## Computer Configuration:
| Name            | Description                             |
| --------------- | --------------------------------------- |
| Ubuntu          | 20.04.6 LTS                             |
| Processor       | Intel® Core™ i7-7700K CPU @ 4.20GHz × 8 |
| Memory          | 64 GB                                   |


## Deploying the Core Infrastructure Dependencies
Instructions for deploying the Core Infrastructure Dependencies listed above are NOT included within this set
of Prototypes as there are numerous targeted deployment instructions for each better suited for your
particular OS.

## Prototype Deployment Steps - Step-1-startMinikube.sh
**Note :**<br>
*The commands within the script file (Step-1-startMinikube.sh) are meant to be copy pasted (one or a few lines at a time) into a terminal, and not run as an automated bash script.*

Steps used within this prototype are as follows:
  1. Delete existing minikube
  2. Create fresh minikube
  3. Enable and open dashboard
  4. Generate the etcd encryption key
  5. Load the encryption key into the encryptConfig.yaml
  6. Mount a minikube directory
  7. Create encryption directories and copy encryptConfig.yaml to it.
  8. Change to the manifests directory where the apiserver.yaml is
  9. Edit the apiserver.yaml by adding 3 lines/sections configuring the encryption.
  10. Let the apiserver refresh itself within minikube
  11. Test the changes are successful.
  
## Caveats - Restarting Minikube
Whenever the command "minikube start" is run the configuration must be re-configured. This is because a start
will revert the apiserver configuration to the programmatically generated one.

A restartMinikube.sh script has been provided to do this. It basically follows the same steps as above.
  
