#!/usr/bin/bash
db_setup () {
    #
    # Install and set up MariaDB
    #
    sudo yum install mariadb mariadb-server maria-devel -y
    sudo touch /etc/my.cnf.d/innodb.conf

sudo cat << EOS >> /etc/my.cnf.d/innodb.conf
[mysqld]
innodb_buffer_pool_size=1024M
innodb_log_file_size=64M
innodb_lock_wait_timeout=900
EOS

    sudo systemctl enable mariadb.service
    sudo systemctl start mariadb.service
}



db_setup
