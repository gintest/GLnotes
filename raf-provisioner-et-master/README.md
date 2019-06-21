# Raf-Provisioner-ET

# Description
Automate Bastion Host spin-up (roles based)


# Linux (Centos)
## :rocket:  Bastion Host spin-up Prodecure: 
- Clone the Raf-provisioner-et repositry by executing:
```
git clone https://github.com/Guavus/raf-provisioner-et.git
```
- Following should be Structure of downloaded Repo:
```
├── README.md
├── ansible.cfg
├── build_rpm.sh
├── jenkinsfile
├── playbooks
│   └── raf_setup.yml
├── roles
│   ├── raf-centos-setup
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   │   ├── get_helm.sh
│   │   │   ├── helm_settings.sh
│   │   │   └── kube.sh
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── molecule
│   │   │   └── default
│   │   │       ├── Dockerfile.j2
│   │   │       ├── INSTALL.rst
│   │   │       ├── molecule.yml
│   │   │       ├── playbook.yml
│   │   │       └── tests
│   │   │           ├── test_default.py
│   │   │           └── test_default.pyc
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── tests
│   │   │   ├── inventory
│   │   │   └── test.yml
│   │   └── vars
│   │       └── main.yml
│   └── raf-mac-setup
│       ├── README.md
│       ├── defaults
│       │   └── main.yml
│       ├── files
│       │   ├── get_helm.sh
│       │   ├── helm_settings.sh
│       │   ├── initramfs-3.10.0-957.el7.x86_64.img
│       │   ├── kube.sh
│       │   ├── run.sh
│       │   └── vmlinuz-3.10.0-957.el7.x86_64
│       ├── handlers
│       │   └── main.yml
│       ├── meta
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       ├── tests
│       │   ├── inventory
│       │   └── test.yml
│       └── vars
│           └── main.yml
├── ssl_remotecluster
│   ├── ca.pem
│   ├── node-key.pem
│   └── node.pem
├── superset.tgz
└── tls
    ├── tls.crt
    └── tls.key
```
The main raf_setup.yml which is to be executed by ansible-playbook exists in /playbook directory.

Before Proceeding with execution of above, 
- Ansible(Verison=2.7) Should be Installed on Linux Host.
- Be sure to comment out roles for Windows & MacOS in raf_setup.yml.
- Enable bridge interface in host server then create a bridge virtual interface of name 'virbr0'.
- Be sure to Define all Variables in raf-centos-setup/vars/main.yaml.
- After adding the required details, execute the raf-setup role by following:
```
ansible-playbook /playbooks/raf_setup.yaml
```
It should Create a Bastion VM on Linux Host, crosscheck the created machine by virt-list or in virt-manager or by sshing into the it.

## Uploading superset chart in local-respository: 
- Once Inside the Bastion, crosscheck if all pods are up and running Successfully by following command:-
```
kubectl get pods -A
```
- Note Down the port on which kubeapps is up & running by executing following command:-
```
kubectl get svc -A
```
- Access the Kubeapps Dashboard on : http://masterip:portno
- Create secret to login into kubeapps Dashbaord by below command:
```
kubectl get secret $(kubectl get serviceaccount kubeapps-operator -o jsonpath='{.secrets[].name}') -o jsonpath='{.data.token}' | base64 --decode
```
- Now, Ensure that ChartMuseum is up and running on : http://masterip:3000
if it does, upload the superset .tgz file in it and hit refresh.
- Once it is uploaded in ChartMuseum, Add ChartMuseum local repository in kubeapps by going to -> repository -> add repository option on upper ride side -> Install repo -> in URL field give: http://masterip:9090 -> click add -> hit refresh.
Now, the superset chart, which was uploaded in ChartMuseum will be visible in kubeapps as well.

## Setting up remote cluster with master: 
- Now, Add context in .kube/config for Remote cluster, check the reference file config_eg in repository.
     
- Make a directory for remote cluster SSL keys by executing:
```
mkdir /etc/kubernetes/ssl
```
& then copy SSL files in it, which are to be fetched from mgt-node of remote cluster(ca.pem,node-key.pem,node.pem).
       
- Now, Make Remote cluster entries in /etc/hosts, which will look alike:
```
     192.xxx.xxx.xx gltest001-lb-vip.gvs.ggn gltest001-lb-vip
     192.xxx.xxx.xx gltest001-mgt-01.gvs.ggn gltest001-mgt-01
     192.xxx.xxx.xx gltest001-mst-01.gvs.ggn gltest001-mst-01
     192.xxx.xxx.xx gltest001-mst-02.gvs.ggn gltest001-mst-02 
     192.xxx.xxx.xx gltest001-slv-01.gvs.ggn gltest001-slv-01
     192.xxx.xxx.xx gltest001-slv-02.gvs.ggn gltest001-slv-02
     192.xxx.xxx.xx gltest001-slv-03.gvs.ggn gltest001-slv-03
     192.xxx.xxx.xx gltest001-lb-01.gvs.ggn gltest001-lb-01
     192.xxx.xxx.xx gltest001-lb-02.gvs.ggn gltest001-lb-02
```
Ping any host to test the reachability.

- Now, List the contexts by executing:
```
   kubectl config get-contexts
```
which will give output matching the following:
```
CURRENT   NAME                            CLUSTER      AUTHINFO           NAMESPACE
          kubelet-reflex-platform.local   local        kubelet            
*         kubernetes-admin@kubernetes     kubernetes   kubernetes-admin   
```
We can see that, for now, Master is using local kubernetes cluster for deployment, to deploy on newly added remote cluster, execute:
```
   kubectl config use-context (context-namehere eg kubelet-reflex-platform.local)
```
After executing above, crosscheck if context is switched by executing:
```
   Kubectl get pods 
```
The output shall contain the pods deployed on remote-k8s cluster.

## Deploying SuperSet on remote cluster: 
- Now, Delete pre-existing secrets in kubernetes, if any by executing following:
```
   kubectl delete secrets ldap-secret psql-secret superset-tls
```

- After Deleting, Create New Secrets in kubernetes for SS deployment by executing:
```
   kubectl create secret generic psql-secret --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=postgres
   kubectl create secret generic  ldap-secret --from-literal=username="cn=svc-ldap,ou=ApplicationObjects,ou=Custom,dc=guavus,dc=com" --from-literal=password="qKH^wSejvJDe"
   kubectl create secret tls superset-tls --key "/root/tls/tls.key"  --cert "/root/tls/tls.crt"
```
### :warning: NOTE: The TLS keys used in 'superset-tls' secret generation are present in repo itself in folder 'tls' of which path is to be provided in create secret command.

- Now, Navigating to kubeapps dashboard, Go to -> Catalog -> Search Superset -> Click Deploy.
- The window will open containing values which can be supplied during deployment, change as one may require.
- Click on submit, On master node execute: 
```
kubectl get svc
```
it will list the port on which SuperSet is listening on, access it via:
```
https://gltest001-lb-vip.gvs.ggn:portno
```
Crosscheck if SuperSet is up and running on Load Balancer IP of Remote Cluster.

# MacOS
## :rocket: Bastion Host spin-up Prodecure: 
- Clone the Raf-provisioner-et repositry by executing:
```
git clone https://github.com/Guavus/raf-provisioner-et.git
```
- Following should be Structure of downloaded Repo:
```
├── README.md
├── ansible.cfg
├── build_rpm.sh
├── jenkinsfile
├── playbooks
│   └── raf_setup.yml
├── roles
│   ├── raf-centos-setup
│   │   ├── README.md
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   │   ├── get_helm.sh
│   │   │   ├── helm_settings.sh
│   │   │   └── kube.sh
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── molecule
│   │   │   └── default
│   │   │       ├── Dockerfile.j2
│   │   │       ├── INSTALL.rst
│   │   │       ├── molecule.yml
│   │   │       ├── playbook.yml
│   │   │       └── tests
│   │   │           ├── test_default.py
│   │   │           └── test_default.pyc
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── tests
│   │   │   ├── inventory
│   │   │   └── test.yml
│   │   └── vars
│   │       └── main.yml
│   └── raf-mac-setup
│       ├── README.md
│       ├── defaults
│       │   └── main.yml
│       ├── files
│       │   ├── get_helm.sh
│       │   ├── helm_settings.sh
│       │   ├── initramfs-3.10.0-957.el7.x86_64.img
│       │   ├── kube.sh
│       │   ├── run.sh
│       │   └── vmlinuz-3.10.0-957.el7.x86_64
│       ├── handlers
│       │   └── main.yml
│       ├── meta
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       ├── tests
│       │   ├── inventory
│       │   └── test.yml
│       └── vars
│           └── main.yml
├── ssl_remotecluster
│   ├── ca.pem
│   ├── node-key.pem
│   └── node.pem
├── superset.tgz
└── tls
    ├── tls.crt
    └── tls.key
```
Before Proceeding with execution of above playbook, 
- Be sure to comment out roles for Linux & Windows in raf_setup.yml file.
- For Successfull execution of playbook Ansible(Verison=2.7) Should be Installed on Mac.
    
- Now, Run the playbook by following Command:
```
ansible-playbook  playbooks/raf_setup.yml 
```
- Once the playbook is complete, check if VM is up and running by sshing into the same.

## Uploading superset chart on local-respository: 
- In Bastion, crosscheck if all pods are up and running Successfully by following command:-
```
kubectl get pods -A
```
- Note Down the port on which kubeapps is up & running by executing following command:-
```
kubectl get svc -A
```
- Access the Kubeapps Dashboard on : http://masterip:portno
- Create secret to login into kubeapps Dashbaord by below command:
```
kubectl get secret $(kubectl get serviceaccount kubeapps-operator -o jsonpath='{.secrets[].name}') -o jsonpath='{.data.token}' | base64 --decode
```
- Now, Ensure that ChartMuseum is up and running on : http://masterip:3000
if it does, upload the superset .tgz file in it and hit refresh.
- Once it is uploaded in ChartMuseum, Add ChartMuseum local repository in kubeapps by going to -> repository -> add repository option on upper ride side -> Install repo -> in URL field give: http://masterip:9090 -> click add -> hit refresh.
Now, the superset chart, which was uploaded in ChartMuseum will be visible in kubeapps as well.

## Configuring remote cluster: 
- Now, Add context in .kube/config for Remote cluster, check the reference file config_eg in repository.
     
- Make a directory for remote cluster SSL keys by executing:
```
mkdir /etc/kubernetes/ssl
```
& then copy SSL files in it, which are to be fetched from mgt-node of remote cluster(ca.pem,node-key.pem,node.pem).
       
- Now, Make Remote cluster entries in /etc/hosts, which will look alike:
```
     192.xxx.xxx.xx gltest001-lb-vip.gvs.ggn gltest001-lb-vip
     192.xxx.xxx.xx gltest001-mgt-01.gvs.ggn gltest001-mgt-01
     192.xxx.xxx.xx gltest001-mst-01.gvs.ggn gltest001-mst-01
     192.xxx.xxx.xx gltest001-mst-02.gvs.ggn gltest001-mst-02 
     192.xxx.xxx.xx gltest001-slv-01.gvs.ggn gltest001-slv-01
     192.xxx.xxx.xx gltest001-slv-02.gvs.ggn gltest001-slv-02
     192.xxx.xxx.xx gltest001-slv-03.gvs.ggn gltest001-slv-03
     192.xxx.xxx.xx gltest001-lb-01.gvs.ggn gltest001-lb-01
     192.xxx.xxx.xx gltest001-lb-02.gvs.ggn gltest001-lb-02
```
Ping any host to test the reachability.

- Now, List the contexts by executing:
```
   kubectl config get-contexts
```
which will give output matching the following:
```
CURRENT   NAME                            CLUSTER      AUTHINFO           NAMESPACE
          kubelet-reflex-platform.local   local        kubelet            
*         kubernetes-admin@kubernetes     kubernetes   kubernetes-admin   
```
We can see that, for now, Master is using local kubernetes cluster for deployment, to deploy on newly added remote cluster, execute:
```
   kubectl config use-context (context-namehere eg kubelet-reflex-platform.local)
```
After executing above, crosscheck if context is switched by executing:
```
   Kubectl get pods 
```
The output shall contain the pods deployed on remote-k8s cluster.

## Deploying Superset chart on remote cluster: 
- Now, Delete pre-existing secrets in kubernetes, if any by executing following:
```
   kubectl delete secrets ldap-secret psql-secret superset-tls
```

- After Deleting, Create New Secrets in kubernetes for SS deployment by executing:
```
   kubectl create secret generic psql-secret --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=postgres
   kubectl create secret generic  ldap-secret --from-literal=username="cn=svc-ldap,ou=ApplicationObjects,ou=Custom,dc=guavus,dc=com" --  from-literal=password="qKH^wSejvJDe"
   kubectl create secret tls superset-tls --key "/root/tls/tls.key"  --cert "/root/tls/tls.crt"
```
### :warning: NOTE: The TLS keys used in 'superset-tls' secret generation are present in repo itself in folder 'tls' of which path is to be provided in create secret command.

- Now, Navigating to kubeapps dashboard, Go to -> Catalog -> Search Superset -> Click Deploy.
- The window will open containing values which can be supplied during deployment, change as one may require.
- Click on submit, On master node execute: 
```
kubectl get svc
```
it will list the port on which SuperSet is listening on, access it via:
```
https://gltest001-lb-vip.gvs.ggn:portno
```

# :exclamation: Troubleshooting Steps
### ChartMuseum build fails
- if build fails while playbook execution,log in into bastion VM, go to a directory of name "ChartMUI" in /root, execute docker-compose up in it, it shall bring up ChartMuseum on port 3000 for UI and 9090 for API.
