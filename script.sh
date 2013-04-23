#!/bin/bash

sudo sed -i -e 's/filter = \[ "a\/.*\/" \]/filter = \[ "r|\/dev\/sdb|", "r|\/dev\/disk\/*|", "r|\/dev\/block\/*|", "a|.*|" \]/g' /etc/lvm/lvm.conf

# filter = [ "a/.*/" ]

# filter = [ "r|/dev/sdb|", "r|/dev/disk/*|", "r|/dev/block/*|", "a|.*|" ]


sudo sed -i -e 's/write_cache_state = 1/write_cache_state = 0/g' /etc/lvm/lvm.conf
#write_cache_state = 1
# write_cache_state = 0
sudo update-initramfs -u

if [ ! -f "/etc/drbd.d/pg.res" ];
then
sudo touch /etc/drbd.d/pg.res
echo "resource pg {" >> /etc/drbd.d/pg.res
echo "  device minor 0;" >> /etc/drbd.d/pg.res
echo "  disk /dev/sdb;" >> /etc/drbd.d/pg.res

echo "  syncer {" >> /etc/drbd.d/pg.res
echo "    rate 150M;" >> /etc/drbd.d/pg.res
echo "    verify-alg md5;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res

echo "  on node1 {" >> /etc/drbd.d/pg.res
echo "    address 10.1.1.31:7788;" >> /etc/drbd.d/pg.res
echo "    meta-disk internal;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res
echo "  on node2 {" >> /etc/drbd.d/pg.res
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
# Add node1 to list of known hosts
sudo ssh-keyscan -t rsa 10.1.1.31 >> ~root/.ssh/known_hosts
sudo ssh-keyscan -t rsa 10.1.1.32 >> ~root/.ssh/known_hosts
# SSH into node1 and authorize public keys
vagrant | ssh node1
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
sudo ssh-keyscan -t rsa 10.1.1.31 >> ~root/.ssh/known_hosts
sudo ssh-keyscan -t rsa 10.1.1.32 >> ~root/.ssh/known_hosts
else
 echo "nothing"
fi



#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa1.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node1

#cat ~/.ssh/*.pub | ssh vagrant@node2 'umask 077; cat >>.ssh/authorized_keys'
