#!/bin/bash

sudo sed -i -e 's/filter = \[ "a\/.*\/" \]/filter = \[ "r|\/dev\/sdb|", "r|\/dev\/disk\/*|", "r|\/dev\/block\/*|", "a|.*|" \]/g' /etc/lvm/lvm.conf

# filter = [ "a/.*/" ]

# filter = [ "r|/dev/sdb|", "r|/dev/disk/*|", "r|/dev/block/*|", "a|.*|" ]


sudo sed -i -e 's/write_cache_state = 1/write_cache_state = 0/g' /etc/lvm/lvm.conf
# Remove all stale cache entries
sudo rm /etc/lvm/cache/.cache
sudo touch /etc/lvm/cache/.cache
#write_cache_state = 1
# write_cache_state = 0
sudo update-initramfs -u

if [ ! -f "/etc/drbd.d/pg.res" ];
then
sudo touch /etc/drbd.d/pg.res
echo "resource pg {" >> /etc/drbd.d/pg.res
#echo "  device minor 0;" >> /etc/drbd.d/pg.res
#echo "  disk /dev/sdb;" >> /etc/drbd.d/pg.res

echo "  syncer {" >> /etc/drbd.d/pg.res
echo "    rate 1000M;" >> /etc/drbd.d/pg.res
echo "    verify-alg md5;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res

echo "  on node1 {" >> /etc/drbd.d/pg.res
echo "    device minor 0;" >> /etc/drbd.d/pg.res
echo "    disk /dev/sdb;" >> /etc/drbd.d/pg.res
echo "    address 10.1.1.31:7788;" >> /etc/drbd.d/pg.res
echo "    meta-disk internal;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res
echo "  on node2 {" >> /etc/drbd.d/pg.res
echo "    device minor 0;" >> /etc/drbd.d/pg.res
echo "    disk /dev/sdb;" >> /etc/drbd.d/pg.res
echo "    address 10.1.1.32:7788;" >> /etc/drbd.d/pg.res
echo "    meta-disk internal;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res
echo "}" >> /etc/drbd.d/pg.res
fi

#modprobe drbd
#echo 'drbd' >> /etc/modules
#update-rc.d drbd defaults

#sudo /etc/init.d/drbd restart

update-rc.d drbd disable

yes yes | sudo drbdadm create-md pg
modprobe drbd
echo 'drbd' >> /etc/modules

sudo drbdadm up pg

node=$(hostname)
node=$(echo $node)
echo "$node is active"

if [[ $node = "konstantin-MS-16G1" ]]; then
echo "bla2"
fi


if [[ $node = "node1" ]]; then
if [ ! -d "/vagrant/.ssh" ]; then
    sudo mkdir /vagrant/.ssh
fi
if [ ! -f "/vagrant/.ssh/id_rsa1" ]; then
    sudo ssh-keygen -t rsa <<EOF
/vagrant/.ssh/id_rsa1


EOF
fi
elif [[ $node = "node2" ]]; then
if [ ! -d "/vagrant/.ssh" ];
then
    sudo mkdir /vagrant/.ssh
fi
if [ ! -f "/vagrant/.ssh/id_rsa2" ];
then
    sudo ssh-keygen -t rsa <<EOF
/vagrant/.ssh/id_rsa2


EOF
fi
else
echo "Node not found."
fi


# Copy keypairs to each node
if [[ $node = "node1" ]]; then
if [ ! -d "~root/.ssh" ];
then
  sudo mkdir ~root/.ssh
fi
if [ ! -f "~root/.ssh/authorized_keys" ];
then
 sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
 sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
fi
# Add node2 to list of known hosts
sudo ssh-keyscan -t rsa 10.1.1.31 >> ~/.ssh/known_hosts
sudo ssh-keyscan -t rsa 10.1.1.32 >> ~/.ssh/known_hosts
# Disable strict host key checking
echo "Host node2" >> /etc/ssh/ssh_config
echo "   Hostname 10.1.1.32" >> /etc/ssh/ssh_config
echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
elif [[ $node = "node2" ]]; then
# Boot into node2 and authorize public keys
if [ ! -d "~root/.ssh" ];
then
  sudo mkdir ~root/.ssh
fi
if [ ! -f "~root/.ssh/authorized_keys" ];
then
 sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
 sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
fi
# Disable strict host key checking
echo "Host node1" >> /etc/ssh/ssh_config
echo "   Hostname 10.1.1.31" >> /etc/ssh/ssh_config
echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
# Add node1 to list of known hosts
sudo ssh-keyscan -t rsa 10.1.1.31 >> ~/.ssh/known_hosts
sudo ssh-keyscan -t rsa 10.1.1.32 >> ~/.ssh/known_hosts
# SSH into node1 and authorize public keys
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
if [ ! -d "~root/.ssh" ];
then
  sudo mkdir ~root/.ssh
fi
then
 sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
 sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
fi
sudo service drbd start
exit
EOF



#sshpass -p "vagrant" ssh -oStrictHostKeyChecking=no -t -t vagrant@node2

#Back in node2
actual=$(hostname)
echo "SSH back to $actual"
sudo service drbd start
#exit
# SSH into node1 and authorize public keys
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo drbdadm -- --overwrite-data-of-peer primary pg
exit
EOF
actual=$(hostname)
echo "SSH back to $actual"
else
 echo "nothing"
fi



#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa1.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node1

#cat ~/.ssh/*.pub | ssh vagrant@node2 'umask 077; cat >>.ssh/authorized_keys'

# sudo crm configure primitive drbd_pg ocf:linbit:drbd  params drbd_resource="pg" op monitor interval="15" op start interval="0" timeout="240" op stop interval="0" timeout="120"
# sudo crm configure ms ms_drbd_pg drbd_pg meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
# sudo crm configure primitive pg_lvm ocf:heartbeat:LVM params volgrpname="VG_PG" op start interval="0" timeout="30" op stop interval="0" timeout="30"
# sudo crm configure primitive pg_fs ocf:heartbeat:Filesystem params device="/dev/VG_PG/LV_DATA" directory="/db/pgdata" options="noatime,nodiratime" fstype="xfs" op start interval="0" timeout="60" op stop interval="0" timeout="120"
# sudo crm configure primitive pg_lsb lsb:postgresql op monitor interval="30" timeout="60" op start interval="0" timeout="60" op stop interval="0" timeout="60"
# sudo crm configure primitive pg_vip ocf:heartbeat:IPaddr2 params ip="10.1.1.30" iflabel="pgvip" cidr_netmask="24" nic="eth2" op monitor interval="5"
# sudo crm configure group PGServer pg_lvm pg_fs pg_lsb pg_vip
# sudo crm configure colocation col_pg_drbd inf: PGServer ms_drbd_pg:Master
# sudo crm configure order ord_pg inf: ms_drbd_pg:promote PGServer:start
