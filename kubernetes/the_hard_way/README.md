#### Cluster Details
Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

kubernetes 1.15.3
containerd 1.2.9
coredns v1.6.3
cni v0.7.1
etcd v3.4.0

## Подготовка.

### Install the Google Cloud SDK

Follow the Google Cloud SDK documentation to install and configure the gcloud command line utility.
https://cloud.google.com/sdk/

```
gcloud init
gcloud auth login
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c
```
Мы указали стандартно создавать нашу структуру на диком-диком западе в The Dalles, Oregon, USA

> Use the gcloud compute zones list command to view additional regions and zones.
> https://cloud.google.com/compute/docs/regions-zones/

### Running Commands in Parallel with tmux
Ставим тмукс чтоб одновременно работать с несколькими консолями виртуальных инстансов.
Использование tmux не является обязательным, просто с ним удобнее.

Работа с тмуксом отлично описаны вот тут https://habr.com/ru/post/327630/

## Installing the Client Tools

### Install CFSSL

The cfssl and cfssljson command line utilities will be used to provision a PKI Infrastructure and generate TLS certificates.
```
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson

chmod +x cfssl cfssljson

sudo mv cfssl cfssljson /usr/local/bin/
```
```
cfssl version
cfssljson --version
```
### kubectl
```
sudo yum install kubectl
kubectl version --client
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.0", GitCommit:"70132b0f130acc0bed193d9ba59dd186f0e634cf", GitTreeState:"clean", BuildDate:"2019-12-07T21:20:10Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}
```

## Provisioning Compute Resources

Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes where containers are ultimately run. In this lab you will provision the compute resources required for running a secure and highly available Kubernetes cluster across a single compute zone.

Ensure a default compute zone and region have been set as described

### Networking
The Kubernetes networking model assumes a flat network in which containers and nodes can communicate with each other. In cases where this is not desired network policies can limit how groups of containers are allowed to communicate with each other and external network endpoints.

Setting up network policies is out of scope for this tutorial.

### Virtual Private Cloud Network

In this section a dedicated Virtual Private Cloud (VPC) network will be setup to host the Kubernetes cluster.

Create the kubernetes-the-hard-way custom VPC network:
```
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
```
A subnet must be provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.

Create the kubernetes subnet in the kubernetes-the-hard-way VPC network:
```
gcloud compute networks subnets create kubernetes \
  --network kubernetes-the-hard-way \
  --range 10.240.0.0/24
```
> The 10.240.0.0/24 IP address range can host up to 254 compute instances! - > /24

### Firewall Rules

Create a firewall rule that allows internal communication across all protocols:
```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 10.240.0.0/24,10.200.0.0/16
```
Create a firewall rule that allows external SSH, ICMP, and HTTPS:
```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 0.0.0.0/0
```
> An external load balancer will be used to expose the Kubernetes API Servers to remote clients
> https://cloud.google.com/compute/docs/load-balancing/network/

List the firewall rules in the kubernetes-the-hard-way VPC network:
```
 sgremyachikh@Thinkpad  ~  gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"

NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY  DISABLED
kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp        False
kubernetes-the-hard-way-allow-internal  kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp                False

To show all fields of the firewall, please show in JSON format: --format=json
To show all fields in table format, please see the examples in --help.

```
### Kubernetes Public IP Address

Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:
```
gcloud compute addresses create kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region)
```
Verify the kubernetes-the-hard-way static IP address was created in your default compute region:
```
 sgremyachikh@Thinkpad  ~  gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

NAME                     ADDRESS/RANGE  TYPE      PURPOSE  NETWORK  REGION    SUBNET  STATUS
kubernetes-the-hard-way  34.82.11.99    EXTERNAL                    us-west1          RESERVED
```
### Compute Instances
The compute instances in this lab will be provisioned using Ubuntu Server 18.04, which has good support for the containerd container runtime. Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

#### Kubernetes Controllers
Create three compute instances which will host the Kubernetes control plane:
```
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
done
```
#### Kubernetes Workers
Each worker instance requires a pod subnet allocation from the Kubernetes cluster CIDR range. The pod subnet allocation will be used to configure container networking in a later exercise. The pod-cidr instance metadata will be used to expose pod subnet allocations to compute instances at runtime.

The Kubernetes cluster CIDR range is defined by the Controller Manager's --cluster-cidr flag. In this tutorial the cluster CIDR range will be set to 10.200.0.0/16, which supports 254 subnets.

Create three compute instances which will host the Kubernetes worker nodes:

```
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
done
```
#### Verification
List the compute instances in your default compute zone:
```
 sgremyachikh@Thinkpad  ~  gcloud compute instances list

NAME          ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
controller-0  us-west1-c  n1-standard-1               10.240.0.10  34.83.128.43    RUNNING
controller-1  us-west1-c  n1-standard-1               10.240.0.11  35.203.160.17   RUNNING
controller-2  us-west1-c  n1-standard-1               10.240.0.12  34.83.51.36     RUNNING
worker-0      us-west1-c  n1-standard-1               10.240.0.20  35.247.27.161   RUNNING
worker-1      us-west1-c  n1-standard-1               10.240.0.21  35.185.230.220  RUNNING
worker-2      us-west1-c  n1-standard-1               10.240.0.22  35.230.92.189   RUNNING
```
### Configuring SSH Access

SSH will be used to configure the controller and worker instances. When connecting to compute instances for the first time SSH keys will be generated for you and stored in the project or instance metadata as described in the connecting to instances documentation.

Test SSH access to the controller-0 compute instances:
```
gcloud compute ssh controller-0
```
If this is your first time connecting to a compute instance SSH keys will be generated for you. Enter a passphrase at the prompt to continue:
```
WARNING: The public SSH key file for gcloud does not exist.
WARNING: The private SSH key file for gcloud does not exist.
WARNING: You do not have an SSH key for gcloud.
WARNING: SSH keygen will be executed to generate a key.
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```
At this point the generated SSH keys will be uploaded and stored in your project:
```
Your identification has been saved in /home/$USER/.ssh/google_compute_engine.
Your public key has been saved in /home/$USER/.ssh/google_compute_engine.pub.
The key fingerprint is:
SHA256:nz1i8jHmgQuGt+WscqP5SeIaSy5wyIJeL71MuV+QruE $USER@$HOSTNAME
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|                 |
|                 |
|        .        |
|o.     oS        |
|=... .o .o o     |
|+.+ =+=.+.X o    |
|.+ ==O*B.B = .   |
| .+.=EB++ o      |
+----[SHA256]-----+
Updating project ssh metadata...-Updated [https://www.googleapis.com/compute/v1/projects/$PROJECT_ID].
Updating project ssh metadata...done.
Waiting for SSH key to propagate.
```
After the SSH keys have been updated you'll be logged into the controller-0 instance:
```
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 5.0.0-1026-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Dec 29 21:22:44 UTC 2019

  System load:  0.0                Processes:           92
  Usage of /:   0.6% of 193.66GB   Users logged in:     0
  Memory usage: 6%                 IP address for ens4: 10.240.0.10
  Swap usage:   0%


0 packages can be updated.
0 updates are security updates.


Last login: Sun Dec 29 21:19:07 2019 from 193.31.192.159
sgremyachikh@controller-0:~$ 
```
Exit:
```
exit
logout
Connection to 34.83.128.43 closed.
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes   kubernetes-1 ●  
```
## Provisioning a CA and Generating TLS Certificates

In this lab you will provision a PKI Infrastructure using CloudFlare's PKI toolkit, cfssl, then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.

### Certificate Authority
In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.

Generate the CA configuration file, certificate, and private key:
```
{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}
```
It will create this: 
```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll
итого 20K
-rw-rw-r--. 1 sgremyachikh sgremyachikh  232 дек 30 00:26 ca-config.json
-rw-r--r--. 1 sgremyachikh sgremyachikh 1005 дек 30 00:26 ca.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  211 дек 30 00:26 ca-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 00:26 ca-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,3K дек 30 00:26 ca.pem
```
### Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes 'admin' user.

The Admin Client Certificate
Generate the admin client certificate and private key:

```
{

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

}
```
And now we have more:
```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll

итого 36K
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 00:49 admin.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  231 дек 30 00:49 admin-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 00:49 admin-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,4K дек 30 00:49 admin.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh  232 дек 30 00:26 ca-config.json
-rw-r--r--. 1 sgremyachikh sgremyachikh 1005 дек 30 00:26 ca.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  211 дек 30 00:26 ca-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 00:26 ca-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,3K дек 30 00:26 ca.pem
```
### The Kubelet Client Certificates 

Kubernetes uses a special-purpose authorization mode called Node Authorizer, that specifically authorizes API requests made by Kubelets. In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the system:nodes group, with a username of system:node:<nodeName>. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

Generate a certificate and private key for each Kubernetes worker node:

```
for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
```
Result:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll
итого 84K
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 00:49 admin.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  231 дек 30 00:49 admin-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 00:49 admin-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,4K дек 30 00:49 admin.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh  232 дек 30 00:26 ca-config.json
-rw-r--r--. 1 sgremyachikh sgremyachikh 1005 дек 30 00:26 ca.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  211 дек 30 00:26 ca-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 00:26 ca-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,3K дек 30 00:26 ca.pem
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:02 worker-0.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  244 дек 30 01:02 worker-0-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:02 worker-0-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:02 worker-0.pem
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:02 worker-1.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  244 дек 30 01:02 worker-1-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:02 worker-1-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:02 worker-1.pem
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:02 worker-2.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  244 дек 30 01:02 worker-2-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:02 worker-2-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:02 worker-2.pem

```
### The Controller Manager Client Certificate

Generate the kube-controller-manager client certificate and private key:

```
{

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

}
```

Results:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep kube
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:05 kube-controller-manager.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  272 дек 30 01:05 kube-controller-manager-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:05 kube-controller-manager-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:05 kube-controller-manager.pem
```
### The Kube Proxy Client Certificate

Generate the kube-proxy client certificate and private key

```
{

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

}
```
Results:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep prox
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:07 kube-proxy.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  248 дек 30 01:07 kube-proxy-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:07 kube-proxy-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:07 kube-proxy.pem
```
### The Scheduler Client Certificate

Generate the kube-scheduler client certificate and private key:

```
{

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

}
```
Results:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep sch
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:08 kube-scheduler.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  254 дек 30 01:08 kube-scheduler-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:08 kube-scheduler-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:08 kube-scheduler.pem
```
### The Kubernetes API Server Certificate

The kubernetes-the-hard-way static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.

Generate the Kubernetes API Server certificate and private key:

```
{

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}
```
The Kubernetes API server is automatically assigned the kubernetes internal dns name, which will be linked to the first IP address (10.32.0.1) from the address range (10.32.0.0/24) reserved for internal cluster services during the control plane bootstrapping lab.

Results:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep kubernetes
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,3K дек 30 01:10 kubernetes.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  232 дек 30 01:10 kubernetes-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:10 kubernetes-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:10 kubernetes.pem
```
### The Service Account Key Pair

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as described in the managing service accounts documentation.
https://kubernetes.io/docs/admin/service-accounts-admin/

Generate the service-account certificate and private key:

```
{

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

}
```
Result:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep serv
-rw-r--r--. 1 sgremyachikh sgremyachikh 1,1K дек 30 01:16 service-account.csr
-rw-rw-r--. 1 sgremyachikh sgremyachikh  238 дек 30 01:16 service-account-csr.json
-rw-------. 1 sgremyachikh sgremyachikh 1,7K дек 30 01:16 service-account-key.pem
-rw-rw-r--. 1 sgremyachikh sgremyachikh 1,5K дек 30 01:16 service-account.pem
```
### Distribute the Client and Server Certificates!

Copy the appropriate certificates and private keys to each worker instance:
```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done
```
Copy the appropriate certificates and private keys to each controller instance:
```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done
```
The kube-proxy, kube-controller-manager, kube-scheduler, and kubelet client certificates will be used to generate client authentication configuration files in future.

## Generating Kubernetes Configuration Files for Authentication

In this lab you will generate Kubernetes configuration files, also known as kubeconfigs, which enable Kubernetes clients to locate and authenticate to the Kubernetes API Servers.

### Client Authentication Configs

In this section you will generate kubeconfig files for the controller manager, kubelet, kube-proxy, and scheduler clients and the admin user.

#### Kubernetes Public IP Address

Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.

Retrieve the kubernetes-the-hard-way static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```
Also we can to check the result:

```
sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes   kubernetes-1 ●  echo ${KUBERNETES_PUBLIC_ADDRESS}
34.82.11.99
```
As we see - all is good.

#### The kubelet Kubernetes Configuration Files

When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes Node Authorizer( https://kubernetes.io/docs/admin/authorization/node/ ).

!!! The following commands must be run in the same directory used to generate the SSL certificates during the Generating TLS Certificates lab.

Generate a kubeconfig file for each worker node:

```
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
```
Results:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-0.kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-1.kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-2.kubeconfig
```
#### The kube-proxy Kubernetes Configuration File

Generate a kubeconfig file for the kube-proxy service:

```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}
```
As result we've got kube-proxy.kubeconfig:

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  ll | grep kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,2K янв  2 23:54 kube-proxy.kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-0.kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-1.kubeconfig
-rw-------. 1 sgremyachikh sgremyachikh 6,3K янв  2 23:48 worker-2.kubeconfig
```
#### The kube-controller-manager Kubernetes Configuration File

Generate a kubeconfig file for the kube-controller-manager service:

```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}
```
Results:

```
kube-controller-manager.kubeconfig
```
#### The kube-scheduler Kubernetes Configuration File

Generate a kubeconfig file for the kube-scheduler service:

```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}
```
Results:

```
kube-scheduler.kubeconfig
```
#### The admin Kubernetes Configuration File

Generate a kubeconfig file for the admin user:

```
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}
```
Results:

```
admin.kubeconfig
```
#### Distribute the Kubernetes Configuration Files

Copy the appropriate kubelet and kube-proxy kubeconfig files to each worker instance:

```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
```
Copy the appropriate kube-controller-manager and kube-scheduler kubeconfig files to each controller instance:

```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
```

## Generating the Data Encryption Config and Key

Kubernetes stores a variety of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to encrypt( https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data ) cluster data at rest.

In this lab you will generate an encryption key and an encryption config( https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration ) suitable for encrypting Kubernetes Secrets.

### The Encryption Key

Generate an encryption key:

```
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```
### The Encryption Config File

Create the encryption-config.yaml encryption config file:

```
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```
Copy the encryption-config.yaml encryption config file to each controller instance:

```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done
```

## Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in etcd( https://github.com/etcd-io/etcd ). In this lab you will bootstrap a three node etcd cluster and configure it for high availability and secure remote access.

### Prerequisites

The commands in this lab must be run on each controller instance: controller-0, controller-1, and controller-2. Login to each controller instance using the gcloud command. Example:

```
gcloud compute ssh controller-0
```
Иначе говоря:
- tmux
- ctrl+b "
- ctrl+b "
- Логининюсь в контролер командой gcloud compute ssh controller-0 и перехожу к слежующей сплит-консоли
- ctrl+b стрелка вверх/вниз
- Логинюсь и т.п. еще и еще
- Включаю синхронный ввод в сплит-консолях: ctrl-b далее shift+: и ввожу set synchronize-panes on

#### Running commands in parallel with tmux

tmux( https://github.com/tmux/tmux/wiki ) can be used to run commands on multiple compute instances at the same time. See the Running commands ( https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md#running-commands-in-parallel-with-tmux ) in parallel with tmux section in the Prerequisites lab.

- Старт
 tmux //без параметров будет создана сессия 0
 tmux new -s session1 //новая сессия session1. Название отображается снизу-слева в квадратных скобках в статус строке. Далее идет перечисление окон. Текущее окно помечается звездочкой.

- Префикс (с него начинаются команды)
<C-b> (CTRL + b)

- Новое окно (нажать CTRL+b, затем нажать с)
<C-b c>

- Список окон
<C-b w> // переключиться курсором вверх-вниз

- Переключение
<C-b n> // следующее окно
<C-b p> // предыдущее окно
<C-b 0> // переключиться на номер окна

Окна можно делить на панели (Panes)
Как в тайловых (мозаичных) оконных менеджерах.

- Деление окна горизонтально
<C-b ">
либо команда
tmux split-window -h

- Деление окна вертикально
<C-b %>
либо команда
tmux split-window -v

- Переход между панелей
<C-b стрелки курсора> // либо режим мыши

- Изменение размеров панелей
<C-b c-стрелки> // либо режим мыши

- Закрытие окон
<C-b x> // нужно подтвердить y
либо
exit

- Отключение от сессии
<C-b d>
либо
tmux detach

- Список сессий
tmux ls

- Подключиться к работающей сессии
tmux attach //подключение к сессии, либо к единственной, либо последней созданной
tmux attach -t session1 // подключение к сессии session1

- Выбрать сессию
<C-b s>

- Завершение сессии
tmux kill-session -t session1

- Завершить все сессии
tmux kill-server

- Список поддерживаемых комманд
tmux list-commands

- Дополнительная информация
man tmux

Фишка синхронного ввода в сплит-консолях:
- Enable synchronize-panes by pressing "ctrl+b" followed by "shift + :". Next type "set synchronize-panes on" at the prompt. 
- To disable synchronization "set synchronize-panes off"

### Bootstrapping an etcd Cluster Member

#### set synchronize-panes on BEFORE IT!!!

Download the official etcd release binaries from the etcd ( https://github.com/etcd-io/etcd ) GitHub project:
```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"
```
Extract and install the etcd server and the etcdctl command line utility:

```
{
  tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
  sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/
}
```
#### Configure the etcd Server

```
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
}
```
The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance:

```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```
Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```
ETCD_NAME=$(hostname -s)
```
Create the etcd.service systemd unit file:
```
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
#### Start the etcd Server
```
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```
> Remember to run the above commands on each controller node: controller-0, controller-1, and controller-2.

### Verification

List the etcd cluster members:

```
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```
output:

```
3a57933972cb5131, started, controller-2, https://10.240.0.12:2380, https://10.240.0.12:2379, false
f98dc20bce6225a0, started, controller-0, https://10.240.0.10:2380, https://10.240.0.10:2379, false
ffed16798470cab5, started, controller-1, https://10.240.0.11:2380, https://10.240.0.11:2379, false
```

## Bootstrapping the Kubernetes Control Plane

In this lab you will bootstrap the Kubernetes control plane across three compute instances and configure it for high availability. You will also create an external load balancer that exposes the Kubernetes API Servers to remote clients. The following components will be installed on each node: Kubernetes API Server, Scheduler, and Controller Manager.

### Prerequisites

The commands in this lab must be run on each controller instance: controller-0, controller-1, and controller-2. Login to each controller instance using the gcloud command USING tmux. Example:
```
gcloud compute ssh controller-0
```
### Provision the Kubernetes Control Plane

Create the Kubernetes configuration directory:

```
sudo mkdir -p /etc/kubernetes/config
```
#### Download and Install the Kubernetes Controller Binaries

Download the official Kubernetes release binaries:

```
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"
```
Install the Kubernetes binaries:

```
{
  chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
  sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}
```
#### Configure the Kubernetes API Server

```
{
  sudo mkdir -p /var/lib/kubernetes/

  sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    encryption-config.yaml /var/lib/kubernetes/
}
```
The instance internal IP address will be used to advertise the API Server to members of the cluster. Retrieve the internal IP address for the current compute instance:

```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```
Create the kube-apiserver.service systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
#### Configure the Kubernetes Controller Manager

Move the kube-controller-manager kubeconfig into place:

```
sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```
Create the kube-controller-manager.service systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
#### Configure the Kubernetes Scheduler

Move the kube-scheduler kubeconfig into place:

```
sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```
Create the kube-scheduler.yaml configuration file:

```
cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF
```
Create the kube-scheduler.service systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
#### Start the Controller Services

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}
```
> Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

### Enable HTTP Health Checks

A Google Network Load Balancer( https://cloud.google.com/compute/docs/load-balancing/network ) will be used to distribute traffic across the three API servers and allow each API server to terminate TLS connections and validate client certificates. The network load balancer only supports HTTP health checks which means the HTTPS endpoint exposed by the API server cannot be used. As a workaround the nginx webserver can be used to proxy HTTP health checks. In this section nginx will be installed and configured to accept HTTP health checks on port 80 and proxy the connections to the API server on https://127.0.0.1:6443/healthz.

> The /healthz API server endpoint does not require authentication by default.

Install a basic web server to handle HTTP health checks:

```
sudo apt-get update
sudo apt-get install -y nginx
```

```
cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF
```

```
{
  sudo mv kubernetes.default.svc.cluster.local \
    /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

  sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
}
```
```
sudo systemctl restart nginx
sudo systemctl enable nginx
```
#### Verification

```
kubectl get componentstatuses --kubeconfig admin.kubeconfig
```
As result I want to see:

```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"} 
```
It is good result!

Test the nginx HTTP health check proxy:

```
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz
```
Good result is:

```
HTTP/1.1 200 OK
Server: nginx/1.14.0 (Ubuntu)
Date: Sat, 04 Jan 2020 17:15:54 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: keep-alive
X-Content-Type-Options: nosniff
```
> Remember to run the above commands on each controller node: controller-0, controller-1, and controller-2.

### RBAC for Kubelet Authorization

Role Based Access Control, RBAC) — развитие политики избирательного управления доступом, при этом права доступа субъектов системы на объекты группируются с учётом специфики их применения, образуя роли

In this section you will configure RBAC permissions to allow the Kubernetes API Server to access the Kubelet API on each worker node. Access to the Kubelet API is required for retrieving metrics, logs, and executing commands in pods.

> This tutorial sets the Kubelet --authorization-mode flag to Webhook. Webhook mode uses the SubjectAccessReview( https://kubernetes.io/docs/admin/authorization/#checking-api-access ) API to determine authorization.

The commands in this section will effect the entire cluster and only need to be run once from one of the controller nodes!!!

Create the system:kube-apiserver-to-kubelet ClusterRole ( https://kubernetes.io/docs/admin/authorization/rbac/#role-and-clusterrole ) with permissions to access the Kubelet API and perform most common tasks associated with managing pods:

```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
```

The Kubernetes API Server authenticates to the Kubelet as the 'kubernetes' user using the client certificate as defined by the '--kubelet-client-certificate' flag.

Bind the 'system:kube-apiserver-to-kubelet' ClusterRole to the 'kubernetes' user:

```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
```
### The Kubernetes Frontend Load Balancer

In this section you will provision an external load balancer to front the Kubernetes API Servers. The `kubernetes-the-hard-way` static IP address will be attached to the resulting load balancer.

> The compute instances created in this tutorial will not have permission to complete this section. **Run the following commands from the same machine used to create the compute instances**.


### Provision a Network Load Balancer

Create the external load balancer network resources:

```
{
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  gcloud compute http-health-checks create kubernetes \
    --description "Kubernetes Health Check" \
    --host "kubernetes.default.svc.cluster.local" \
    --request-path "/healthz"

  gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
    --network kubernetes-the-hard-way \
    --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
    --allow tcp

  gcloud compute target-pools create kubernetes-target-pool \
    --http-health-check kubernetes

  gcloud compute target-pools add-instances kubernetes-target-pool \
   --instances controller-0,controller-1,controller-2

  gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address ${KUBERNETES_PUBLIC_ADDRESS} \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool
}
```

### Verification

> The compute instances created in this tutorial will not have permission to complete this section. **Run the following commands from the same machine used to create the compute instances**.

**Так же важно знать. что надо запускать это все из директории, где мы генерировали серификаты**

Retrieve the `kubernetes-the-hard-way` static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

Make a HTTP request for the Kubernetes version info:

```
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
```

> output

```
 sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way   kubernetes-1 ●  curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
{
  "major": "1",
  "minor": "15",
  "gitVersion": "v1.15.3",
  "gitCommit": "2d3c76f9091b6bec110a5e63777c332469e0cba2",
  "gitTreeState": "clean",
  "buildDate": "2019-08-19T11:05:50Z",
  "goVersion": "go1.12.9",
  "compiler": "gc",
  "platform": "linux/amd64"
}%           
```
## Bootstrapping the Kubernetes Worker Nodes

In this lab you will bootstrap three Kubernetes worker nodes. The following components will be installed on each node: [runc](https://github.com/opencontainers/runc), [container networking plugins](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/admin/kubelet), and [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

### Prerequisites

The commands in this lab must be run on each worker instance: `worker-0`, `worker-1`, and `worker-2`. Login to each worker instance using the `gcloud` command. Example:

```
gcloud compute ssh worker-0
```

### Running commands in parallel with tmux

[tmux](https://github.com/tmux/tmux/wiki) can be used to run commands on multiple compute instances at the same time. See the [Running commands in parallel with tmux](01-prerequisites.md#running-commands-in-parallel-with-tmux) section in the Prerequisites lab.

### Provisioning a Kubernetes Worker Node

Install the OS dependencies:

```
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}
```

> The socat binary enables support for the `kubectl port-forward` command.

### Disable Swap

By default the kubelet will fail to start if [swap](https://help.ubuntu.com/community/SwapFaq) is enabled. It is [recommended](https://github.com/kubernetes/kubernetes/issues/7294) that swap be disabled to ensure Kubernetes can provide proper resource allocation and quality of service.

Verify if swap is enabled:

```
sudo swapon --show
```

If output is empthy then swap is not enabled. If swap is enabled run the following command to disable swap immediately:

```
sudo swapoff -a
```

> To ensure swap remains off after reboot consult your Linux distro documentation.

### Download and Install Worker Binaries

```
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
  https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet
```

Create the installation directories:

```
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Install the worker binaries:

```
{
  mkdir containerd
  tar -xvf crictl-v1.15.0-linux-amd64.tar.gz
  tar -xvf containerd-1.2.9.linux-amd64.tar.gz -C containerd
  sudo tar -xvf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin/
  sudo mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc 
  sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  sudo mv containerd/bin/* /bin/
}
```

### Configure CNI Networking

Retrieve the Pod CIDR range for the current compute instance:

```
POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
```

Create the `bridge` network configuration file:

```
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
```

Create the `loopback` network configuration file:

```
cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF
```

### Configure containerd

Create the `containerd` configuration file:

```
sudo mkdir -p /etc/containerd/
```

```
cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF
```

Create the `containerd.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
```

### Configure the Kubelet

```
{
  sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
  sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/
}
```

Create the `kubelet-config.yaml` configuration file:

```
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF
```

> The `resolvConf` configuration is used to avoid loops when using CoreDNS for service discovery on systems running `systemd-resolved`. 

Create the `kubelet.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Configure the Kubernetes Proxy

```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

Create the `kube-proxy-config.yaml` configuration file:

```
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF
```

Create the `kube-proxy.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start the Worker Services

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}
```

> Remember to run the above commands on each worker node: `worker-0`, `worker-1`, and `worker-2`.

## Verification

> The compute instances created in this tutorial will not have permission to complete this section. Run the following commands from the same machine used to create the compute instances.

List the registered Kubernetes nodes:

```
gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"
```

> output

```
NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   15s   v1.15.3
worker-1   Ready    <none>   15s   v1.15.3
worker-2   Ready    <none>   15s   v1.15.3
```

## Configuring kubectl for Remote Access

In this lab you will generate a kubeconfig file for the `kubectl` command line utility based on the `admin` user credentials.

> Run the commands in this lab from the same directory used to generate the admin client certificates.

### The Admin Kubernetes Configuration File

Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.

Generate a kubeconfig file suitable for authenticating as the `admin` user:

```
{
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
}
```

### Verification

Check the health of the remote Kubernetes cluster:

```
kubectl get componentstatuses
```

> output

[BUGGED!](https://github.com/kubernetes/kubernetes/issues/83024):

```
kubectl get componentstatuses
NAME                 AGE
scheduler            <unknown>
controller-manager   <unknown>
etcd-2               <unknown>
etcd-1               <unknown>
etcd-0               <unknown>
```
[Resolved in 1.17.0](https://github.com/kubernetes/kubernetes/issues/83024):

```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-1               Healthy   {"health":"true"}
etcd-2               Healthy   {"health":"true"}
etcd-0               Healthy   {"health":"true"}
```

List the nodes in the remote Kubernetes cluster:

```
kubectl get nodes
```

> output

```
NAME       STATUS   ROLES    AGE    VERSION
worker-0   Ready    <none>   2m9s   v1.15.3
worker-1   Ready    <none>   2m9s   v1.15.3
worker-2   Ready    <none>   2m9s   v1.15.3
```
## Provisioning Pod Network Routes

Pods scheduled to a node receive an IP address from the node's Pod CIDR range. At this point pods can not communicate with other pods running on different nodes due to missing network [routes](https://cloud.google.com/compute/docs/vpc/routes).

In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.

> There are [other ways](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) to implement the Kubernetes networking model.

### The Routing Table

In this section you will gather the information required to create routes in the `kubernetes-the-hard-way` VPC network.

Print the internal IP address and Pod CIDR range for each worker instance:

```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done
```

> output

```
10.240.0.20 10.200.0.0/24
10.240.0.21 10.200.1.0/24
10.240.0.22 10.200.2.0/24
```

### Routes

Create network routes for each worker instance:

```
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
```

List the routes in the `kubernetes-the-hard-way` VPC network:

```
gcloud compute routes list --filter "network: kubernetes-the-hard-way"
```

> output

```
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-081879136902de56  kubernetes-the-hard-way  10.240.0.0/24  kubernetes-the-hard-way   1000
default-route-55199a5aa126d7aa  kubernetes-the-hard-way  0.0.0.0/0      default-internet-gateway  1000
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20               1000
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21               1000
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22               1000
```

## Deploying the DNS Cluster Add-on

In this lab you will deploy the [DNS add-on](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) which provides DNS based service discovery, backed by [CoreDNS](https://coredns.io/), to applications running inside the Kubernetes cluster.

### The DNS Cluster Add-on

Deploy the `coredns` cluster add-on:

```
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
```

> output

```
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.extensions/coredns created
service/kube-dns created
```

List the pods created by the `kube-dns` deployment:

```
kubectl get pods -l k8s-app=kube-dns -n kube-system
```

> output

```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-699f8ddd77-94qv9   1/1     Running   0          20s
coredns-699f8ddd77-gtcgb   1/1     Running   0          20s
```

### Verification

Create a `busybox` deployment:

```
kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600
```

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

> output

```
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          3s
```

Retrieve the full name of the `busybox` pod:

```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

> output

```
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

## Smoke Test

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

### Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

Create a generic secret:

```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```
gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
```

> output

```
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 1b 79 37 b6 ca 7c 7d  |:v1:key1:.y7..|}|
00000050  e1 55 09 e8 91 0e 5c 0e  0d 3f fd 10 0d 19 9f 28  |.U....\..?.....(|
00000060  3a 67 2c 30 be 4c e8 0d  51 c2 e9 7f f1 f4 82 f8  |:g,0.L..Q.......|
00000070  de 11 42 8e 2c aa cc 5b  8b e3 d2 1b b8 9c 36 71  |..B.,..[......6q|
00000080  ce 58 67 40 98 c1 49 30  44 c0 09 97 38 a2 2e 2d  |.Xg@..I0D...8..-|
00000090  39 26 09 0a 4d 9e 8d 34  8e ed 62 88 3f 10 00 e1  |9&..M..4..b.?...|
000000a0  64 9c 68 6b c3 83 35 f0  32 c6 00 1b 1f e5 07 c9  |d.hk..5.2.......|
000000b0  e7 c1 aa cf 34 b4 9e aa  19 08 13 86 26 ba cf a9  |....4.......&...|
000000c0  78 24 a9 90 da 6b 6e 2f  d5 f9 a7 bc 60 ea 50 f6  |x$...kn/....`.P.|
000000d0  c1 a0 b8 08 fb 76 89 1b  97 4f 0b dd 46 c6 cb e5  |.....v...O..F...|
000000e0  7d 6c fe 1f d2 1a 2c 55  6f 0a                    |}l....,Uo.|
000000ea

```

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

### Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```
kubectl create deployment nginx --image=nginx
```

List the pod created by the `nginx` deployment:

```
kubectl get pods -l app=nginx
```

> output

```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-554b9c67f9-vt5rn   1/1     Running   0          10s
```

#### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```
kubectl port-forward $POD_NAME 8080:80
```

> output

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```
curl --head http://127.0.0.1:8080
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.17.3
Date: Sat, 14 Sep 2019 21:10:11 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 08:50:00 GMT
Connection: keep-alive
ETag: "5d5279b8-264"
Accept-Ranges: bytes
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

#### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```
kubectl logs $POD_NAME
```

> output

```
127.0.0.1 - - [14/Sep/2019:21:10:11 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.52.1" "-"
```

#### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```
kubectl exec -ti $POD_NAME -- nginx -v
```

> output

```
nginx version: nginx/1.17.3
```

### Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service:

```
kubectl expose deployment nginx --port 80 --type NodePort
```

> The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider). Setting up cloud provider integration is out of scope for this tutorial.

Retrieve the node port assigned to the `nginx` service:

```
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

Create a firewall rule that allows remote access to the `nginx` node port:

```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way
```

Retrieve the external IP address of a worker instance:

```
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
```

Make an HTTP request using the external IP address and the `nginx` node port:

```
curl -I http://${EXTERNAL_IP}:${NODE_PORT}
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.17.3
Date: Sat, 14 Sep 2019 21:12:35 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 08:50:00 GMT
Connection: keep-alive
ETag: "5d5279b8-264"
Accept-Ranges: bytes
```

## Cleaning Up

In this lab you will delete the compute resources created during this tutorial.

### Compute Instances

Delete the controller and worker compute instances:

```
gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2 \
  --zone $(gcloud config get-value compute/zone)
```

### Networking

Delete the external load balancer network resources:

```
{
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete kubernetes-the-hard-way
}
```

Delete the `kubernetes-the-hard-way` firewall rules:

```
gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external \
  kubernetes-the-hard-way-allow-health-check
```

Delete the `kubernetes-the-hard-way` network VPC:

```
{
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete kubernetes-the-hard-way
}
```
