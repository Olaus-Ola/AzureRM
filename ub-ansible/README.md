## Ansible Master

Creates a new base Linux VM for which has  Ansible, Git, Azure Python SDK and Ansible Playbook pulled from git Using azure Desired state configuration files


### Install 

````
./provision-up-ansible-master.ps1
````

### Post Install

Verify and Run waagent on Host 

````
sudo waagent -deprovision+user
````

Remove the vm and extracting base image
````
./extract-base-image-master.ps1
````