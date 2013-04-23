class sources::persistent {

  exec { "fdisk-sourcehd":
    command => "/sbin/fdisk /dev/sdb << EOF
o
n
e
1


n
l



w
EOF",
    unless => "/bin/grep sdb1 /proc/partitions",
  }

 # exec { "mkfs-sourcehd":
 #   command     => "/sbin/mkfs.ext3 -L sources -b 4096 /dev/sdb1",
 #   unless      => "/sbin/dumpe2fs /dev/sdb1"
  #}

  #exec { 'fstab-sourcehd':
   # command => '/bin/echo "/dev/disk/by-label/sources /mnt/sources ext3 defaults 0 2" >> /etc/fstab',
  # unless  => '/bin/grep ^/dev/disk/by-label/sources /etc/fstab',
  #}

 #exec { 'mount-sourcehd':
    #command     => '/bin/mkdir -p /mnt/sources; /bin/mount /mnt/sources',
    #subscribe   => Exec['fstab-sourcehd'],
   # refreshonly => true,
  #}

  #Exec['fdisk-sourcehd']

}


