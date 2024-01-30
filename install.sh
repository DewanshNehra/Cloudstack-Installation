#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "
  ############################################################################# 
  ##         This script must be run as root or with sudo command            ##   
  ##  before running the script switch to root user using <su> or <sudo su>  ##
  #############################################################################
  "
  sleep 15
  exit
fi

UBUNTU_VERSION=$(lsb_release -rs)
REQUIRED_VERSION="22.04"

if (( $(echo "$UBUNTU_VERSION < $REQUIRED_VERSION" | bc -l) ))
then
    echo "
    ############################################################################# 
    ##         This script requires Ubuntu version 22.04 or higher            ##   
    #############################################################################
    "
    sleep 15
    exit
fi

echo -e "
 ██████╗ ███████╗██╗    ██╗ █████╗ ███╗   ██╗███████╗   ███╗   ██╗███████╗██╗  ██╗██████╗  █████╗ 
 ██╔══██╗██╔════╝██║    ██║██╔══██╗████╗  ██║██╔════╝   ████╗  ██║██╔════╝██║  ██║██╔══██╗██╔══██╗ 
 ██║  ██║█████╗  ██║ █╗ ██║███████║██╔██╗ ██║███████╗   ██╔██╗ ██║█████╗  ███████║██████╔╝███████║ 
 ██║  ██║██╔══╝  ██║███╗██║██╔══██║██║╚██╗██║╚════██║   ██║╚██╗██║██╔══╝  ██╔══██║██╔══██╗██╔══██║
 ██████╔╝███████╗╚███╔███╔╝██║  ██║██║ ╚████║███████║   ██║ ╚████║███████╗██║  ██║██║  ██║██║  ██║ 
 ╚═════╝ ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  
 "
echo -e "
###################################################################################
####           This script is written by Dewans Nehra.                        ####
####           You can contact me at https://dewansnehra.xyz                  ####
####           This script is written for Ubuntu 22.04                        ####
####           This script will install Cloudstack 4.18                       ####
###################################################################################
"

apt update && apt upgrade -y


GATEWAY=$(ip r | awk '/default/ {print $3}')
IP=$(ip r | awk '/src/ {print $9}')
ADAPTER=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')

HOSTS_CONTENT="127.0.0.1\tlocalhost\n$IP\tdevil.dewansnehra.xyz\tdevil"
NETPLAN_CONTENT="network:
    ethernets:
        $ADAPTER:
            dhcp4: false
            addresses: [$IP/24]
            gateway4: $GATEWAY
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
    version: 2"

CURRENT_GATEWAY=$(grep -oP '(?<=gateway4: )[^ ]*' /etc/netplan/01-network-manager-all.yaml)

if ! grep -Fxq "$HOSTS_CONTENT" /etc/hosts
then
    echo -e "$HOSTS_CONTENT" | sudo tee /etc/hosts
fi

if [ "$CURRENT_GATEWAY" != "$GATEWAY" ]
then
    cp /etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml.bak
    echo "$NETPLAN_CONTENT" | sudo tee /etc/netplan/01-network-manager-all.yaml
fi

netplan apply
netplan apply

apt-get install -y openntpd openssh-server sudo vim htop tar intel-microcode bridge-utils mysql-server

echo deb [arch=amd64] http://download.cloudstack.org/ubuntu jammy 4.18  > /etc/apt/sources.list.d/cloudstack.list

wget -O - http://download.cloudstack.org/release.asc|gpg --dearmor > cloudstack-archive-keyring.gpg

mv cloudstack-archive-keyring.gpg /etc/apt/trusted.gpg.d/

apt update && apt upgrade -y
apt-get install -y cloudstack-management cloudstack-usage


echo -e "\nserver_id = 1\nsql-mode=\"STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO,NO_ZERO_DATE,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION\"\ninnodb_rollback_on_timeout=1\ninnodb_lock_wait_timeout=600\nmax_connections=1000\nlog-bin=mysql-bin\nbinlog-format = 'ROW'" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf


echo -e "[mysqld]" | sudo tee /etc/mysql/mysql.conf.d/cloudstack.cnf

systemctl restart mysql

echo "
###################################################################################
# In the next command if it will ask for password just press enter and do nothing #
###################################################################################
"

mysql -u root -p -e "
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'dewansnehra';
use mysql;
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
flush privileges;
"
apt-get install -y cloudstack-management cloudstack-usage
cloudstack-setup-databases devil:devil@localhost --deploy-as=root:dewansnehra


cloudstack-setup-management

echo "
###################################################################################
####           Thank you for using this script.                                ####
####       Dewans Nehra -  https://dewansnehra.xyz                             #### 
###################################################################################
"
width=$(tput cols)
progress_width=$((width - 20))
sleep_duration=$(echo "60 / $progress_width" | bc -l)
echo -n "Progress: ["
for i in $(seq 1 $progress_width)
do
    sleep $sleep_duration
    echo -n "#"
done
echo "]"


echo "
###################################################################################
####           Installation done. You can go to http://localhost:8080          ####
####           to access the pannel.                                           ####
####           Dewans Nehra -  https://dewansnehra.xyz                         ####
###################################################################################
"
