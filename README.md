Dependability Test
=====================

This repository is used to deliver a VM test framework to test the DRBD HA technology on a PostgreSQL distributed database.

What does it do?
=====================
Basically the VM test framework creates 2 Virtual Machines which are able to communicate via a dedicated SSH tunnel. 
Then it installs a DRBD block device on each node and cluster it on both nodes.
Then it installs, runs and configures the Corosync and Pacemaker services which are needed to enable synchronization and failover of the DRBD cluster.
Finally it installs a PostgreSQL DB that runs on the DRBD.
Now you can test availability of the PostgreSQL DB.

Prerequisites
=====================
In order to run the framework on your local machine you must have installed Vagrant and Virtualbox. 
It is also required to install the Persistent Storage plugin:  
https://github.com/kusnier/vagrant-persistent-storage

How to install
=====================
1. Clone this repository into a directory of your local machine, e. g. /home/user/ha_test.
2. Open a terminal and type: cd /home/user/ha_test (or whatever directory you cloned this repository into).
3. Type: vagrant up
4. Take a coffee break and wait until everything is configured ;-)
5. Login into one of the nodes by typing: vagrant ssh node1

Now you can test your environment.
