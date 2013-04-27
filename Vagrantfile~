# -*- mode: ruby -*-
# vi: set ft=ruby :

dhostname1 = "node1"
dhostname2 = "node2"

Vagrant::Config.run do |config|

  config.vm.define :node1 do |n1_config|
    n1_config.vm.box = "precise64"
    n1_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    
    # Two Interfaces: one for host machine access, 
    # One for dedicated replication connection
    n1_config.vm.network :hostonly, "192.168.1.11"
    n1_config.vm.network :hostonly, "10.1.1.31"
    n1_config.vm.forward_port 80, 8080
    
    n1_config.vm.host_name = dhostname1
    n1_config.vm.customize ["modifyvm", :id, "--memory", 1024]
    n1_config.ssh.max_tries = 100
    #n1_config.ssh.private_key_path = "~root/root"

    #n1_config.vm.synced_folder "share/", "/share"

    # persistent storage for DRBD

    n1_config.persistent_storage.location = "~/development/sourcehdd.vdi"
    n1_config.persistent_storage.size = 5000

    n1_config.vm.provision :puppet do |n1_puppet|
      n1_puppet.pp_path = "/tmp/vagrant-puppet"
      n1_puppet.module_path = "modules"
      n1_puppet.manifests_path = "manifests"
      n1_puppet.manifest_file = "site1.pp"
      n1_puppet.facter = { "fqdn" => dhostname1 }
    end
    n1_config.vm.provision :shell, :path => "script.sh"

  end

  config.vm.define :node2 do |n2_config|
    n2_config.vm.box = "precise64"
    n2_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    
    # Two Interfaces: one for host machine access, 
    # One for dedicated replication connection
    n2_config.vm.network :hostonly, "192.168.1.12"
    n2_config.vm.network :hostonly, "10.1.1.32"
    n2_config.vm.forward_port 80, 8088
    
    n2_config.vm.host_name = dhostname2
    n2_config.vm.customize ["modifyvm", :id, "--memory", 1024]
    n2_config.ssh.max_tries = 100
    #n2_config.ssh.private_key_path = "~root/"

    #n2_config.vm.synced_folder "share/", "/share"

    # persistent storage for DRBD
    n2_config.persistent_storage.location = "~/development/sourcehdd2.vdi"
    n2_config.persistent_storage.size = 5000

    n2_config.vm.provision :puppet do |n2_puppet|
      n2_puppet.pp_path = "/tmp/vagrant-puppet"
      n2_puppet.module_path = "modules"
      n2_puppet.manifests_path = "manifests"
      n2_puppet.manifest_file = "site2.pp"
      n2_puppet.facter = { "fqdn" => dhostname2 }
    end

    n2_config.vm.provision :shell, :path => "script.sh"
  end

end

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "base"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file base.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "base.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding 
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # IF you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
#end
