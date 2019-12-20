# use caution when using -y (automatic "yes")
sudo apt -y update
sudo apt -y upgrade
echo hv_vmbus >> /etc/initramfs-tools/modules
echo hv_storvsc >> /etc/initramfs-tools/modules
echo hv_blkvsc >> /etc/initramfs-tools/modules
echo hv_netvsc >> /etc/initramfs-tools/modules
sudo apt -y install hyperv-daemons
sudo update-initramfs –u
hv_fcopy_daemon
hv_kvp_daemon
hv_set_ifconfig
hv_vss_daemon
hv_get_dns_info
wget http://www.pulseway.com/download/pulseway_x64.deb
dpkg -i pulseway_x64.deb
wget https://www.voipmonitor.org/current-stable-sniffer-static-64bit.tar.gz --content-disposition --no-check-certificate
tar xzf voipmonitor-*-static.tar.gz
cd voipmonitor-*-static
./install-script.sh
apt install python3
apt install python3-dev
apt install salt-minion
apt install wazzuh
apt install curl apt-transport-https lsb-release gnupg2
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt update && apt install wazuh-agemt
apt update && apt install wazuh-agent
apt install snmpd
ping mezobyte.com
apt install glusterfs-client
apt install rclone
iptables -A INPUT -s 169.239.84.14 -p tcp -m tcp --dport 161 -j ACCEPT
netfilter-persistent save


#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
# dynamically create hostname (optional)
#if hostname | grep localhost; then
#    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
#fi
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make sure the script is executable
chmod +x /etc/rc.local

#reset hostname
# prevent cloudconfig from preserving the original hostname
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost

#cleanup apt
apt clean

# set dhcp to use mac - this is a little bit of a hack but I need this to be placed under the active nic settings
# also look in /etc/netplan for other config files
sed -i 's/optional: true/dhcp-identifier: mac/g' /etc/netplan/50-cloud-init.yaml

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

#shutdown
shutdown -h now
