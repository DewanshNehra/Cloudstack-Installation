# Cloudstack 4.18 Installation Script for Ubuntu 22.04

This script automates the installation of Cloudstack 4.18 on Ubuntu 22.04. It was written by Dewans Nehra. You can contact me at [https://dewansnehra.xyz](https://dewansnehra.xyz).

## Usage

1. Download the script using git clone command:
```bash
    git clone https://github.com/DewanshNehra/Cloudstack-Installation
```
2. Change the directory to that folder:
```bash
   cd cloudstack-installation
```
3. Make the script executable with the command: 
```bash
chmod +x install.sh
```
4. Switch to root before running the script and enter your root password:
```bash
su
```
or
```bash
sudo su
``` 
5. Run the script using the command:
```bash
./install.sh
```
## What the script does

The script performs the following steps:

1. Checks if it is run as root or with sudo.
2. Updates and upgrades the system packages.
3. Configures the network settings.
4. Installs necessary packages including openntpd, openssh-server, sudo, vim, htop, tar, intel-microcode, bridge-utils, mysql-server, and Cloudstack.
5. Configures MySQL.
6. Sets up Cloudstack databases and management.

## Note

During the MySQL configuration, if it asks for a password, just press enter and do nothing.

## After Installation

Once the installation is done, you can access the Cloudstack panel at [http://localhost:8080](http://localhost:8080).\
Username: `admin`\
Password: `password`
