## Ansible Slave

Base Image Containing Ubuntu 16.04 LTS to be used as a Ansible Slave Image

### Install 

```
./provision-up-ansible-slave.ps1
```

### Post Install

Update and Instal Packages
```
sudo apt-get update        # Fetches the list of available updates
sudo apt-get upgrade       # Strictly upgrades the current packages
sudo apt-get dist-upgrade  # Installs updates (new ones)
```

Verify and Run waagent on Host 

```
sudo waagent -deprovision+user
```

Remove the vm and extracting base image
```
./extract-base-image-slave.ps1
```

### Verify
```
apt list --installed | grep ssh
```
