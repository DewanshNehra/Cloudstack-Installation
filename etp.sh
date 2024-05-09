#######################################
#chrony setup 
#######################################
apt install chrony -y
#######################################

#######################################
#ntp setup 
#######################################
apt install ntp -y
 ## ntp config file path 
cat /etc/ntp.conf
    ## ntp service status
systemctl status ntp
#to check if the ntp is working or not
ntpq -p
#######################################


#######################################
#installing bridge-utils
#######################################
apt install bridge-utils -y

#######################################
# netplan setup
#######################################
GATEWAY=$(ip r | awk '/default/ {print $3}')
IP=$(ip r | awk '/src/ {print $9}')
ADAPTER=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')


HOSTS_CONTENT="127.0.0.1\tlocalhost\n$IP\tdevil.devil.xyz\tdevil"


# Check if the bridge already exists
if ! brctl show | grep -q 'br0'; then
    brctl addbr br0
fi

# Check if the interface is already added to the bridge
if ! brctl show br0 | grep -q "$ADAPTER"; then
    brctl addif br0 $ADAPTER
fi

NETPLAN_CONTENT="network:
    version: 2
    renderer: networkd
    ethernets:
        $ADAPTER:
            dhcp4: no
            dhcp6: no
    bridges:
        br0:
            interfaces: [$ADAPTER]
            dhcp4: no
            dhcp6: no
            addresses: [$IP/24]
            gateway4: $GATEWAY
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]"

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
systemctl restart NetworkManager
############################################

#######################################
#installing openJDK
#######################################
apt install openjdk-11-jdk -y

#######################################



#######################################
# installing prerequisites for cloudstack
#######################################
apt-get install -y openntpd openssh-server sudo vim htop tar intel-microcode bridge-utils mysql-server



#######################################
# cloudstack instalation main download 
#######################################
UBUNTU_VERSION=$(lsb_release -rs)

if [[ "$UBUNTU_VERSION" == "20."* ]]
then
    echo deb [arch=amd64] http://download.cloudstack.org/ubuntu focal 4.18  > /etc/apt/sources.list.d/cloudstack.list
elif [[ "$UBUNTU_VERSION" == "22."* ]]
then
    echo deb [arch=amd64] http://download.cloudstack.org/ubuntu jammy 4.18  > /etc/apt/sources.list.d/cloudstack.list
else
    echo "Unsupported Ubuntu version. This script supports Ubuntu 20.xx and 22.xx only."
    exit 1
fi


wget -O - http://download.cloudstack.org/release.asc|gpg --dearmor > cloudstack-archive-keyring.gpg


mv cloudstack-archive-keyring.gpg /etc/apt/trusted.gpg.d/


apt update && apt upgrade -y
apt-get install -y cloudstack-management cloudstack-usage


#######################################
# mysql setup
#######################################
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


#######################################
# for kvm setup 
#######################################
#reffer to this link if you are on windows 
#https://github.com/DewanshNehra/Cloudstack-Installation/tree/main/kvm
#if u want to check if it is working or not then run the command 
apt install cpu-checker
kvm-ok



: '
if you want to setup the pods, zone,cluster or anything else then reffer to the link below
https://rohityadav.cloud/blog/cloudstack-kvm/
'
