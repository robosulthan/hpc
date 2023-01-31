#!/usr/bin/bash

MUNGEUSER=1001
sudo mkdir -p $MUNGEPATH
sudo mkdir -p /var/log/munge /etc/munge
munge_setup () {
    #
    # Install and set up Munge
    #
        sudo yum install -y gcc
        sudo yum install -y openssl-devel
        sudo groupadd -g $MUNGEUSER munge
        sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
        wget https://github.com/dun/munge/releases/download/munge-0.5.15/munge-0.5.15.tar.xz
        tar -xvf munge-0.5.15.tar.xz
        cd munge-0.5.15/
	./configure \
            --prefix=/usr \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --runstatedir=/run
        make
        sudo make install
        sudo ldconfig
	
        chown -R munge: /etc/munge
 	   sudo -u munge /usr/sbin/mungekey -v

        sudo chown -R munge /var/log/munge
        sudo chmod 0700 /var/log/munge/
        sudo systemctl enable munge
        sudo systemctl start  munge
}


munge_setup
