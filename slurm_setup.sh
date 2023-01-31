#!/usr/bin/bash

SLURMUSER=1002
slurm_setup () {
    #
    # Install and set up slurm
    #
        sudo yum install -y git
        sudo groupadd -g $SLURMUSER slurm
        sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

        git clone https://github.com/SchedMD/slurm.git
        cd slurm
        ./configure
        make
        sudo make install
        echo "Slurm configuration started "
	cp -R etc/ ${SLURM_PATH}
        cp ${SLURM_PATH}/etc/slurmdbd.service /etc/systemd/system/
        cp ${SLURM_PATH}/etc/slurmctld.service /etc/systemd/system/

cat << EOS >> /usr/local/etc/slurmctld.service
[Unit]
Description=Slurm controller daemon
After=network-online.target munge.service
Wants=network-online.target
ConditionPathExists=/usr/local/etc/slurm.conf

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/slurmctld
EnvironmentFile=-/etc/default/slurmctld
ExecStart=/usr/local/sbin/slurmctld -D -s $SLURMCTLD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536


# Uncomment the following lines to disable logging through journald.
# NOTE: It may be preferable to set these through an override file instead.
#StandardOutput=null
#StandardError=null
EOS

cat << EOS >> /usr/local/etc//slurmdbd.service
[Unit]
Description=Slurm DBD accounting daemon
After=network-online.target munge.service mysql.service mysqld.service mariadb.service
Wants=network-online.target
ConditionPathExists=/usr/local/etc/slurmdbd.conf

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/slurmdbd
EnvironmentFile=-/etc/default/slurmdbd
ExecStart=/usr/local/sbin/slurmdbd -D -s $SLURMDBD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536


# Uncomment the following lines to disable logging through journald.
# NOTE: It may be preferable to set these through an override file instead.
#StandardOutput=null
#StandardError=null

[Install]
WantedBy=multi-user.target
EOS
cat << EOS >> /usr/local/etc/slurmdbd.conf

AuthType=auth/munge
#AuthInfo=/var/run/munge/munge.socket.2
#
# slurmDBD info
DbdAddr=localhost
DbdHost=localhost
#DbdPort=7031
SlurmUser=slurm
#MessageTimeout=300
DebugLevel=verbose
#DefaultQOS=normal,standby
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/var/run/slurmdbd.pid
#PluginDir=/usr/lib/slurm
#PrivateData=accounts,users,usage,jobs
#TrackWCKey=yes
#
# Database info
StorageType=accounting_storage/mysql
#StorageHost=localhost
#StoragePort=1234
StoragePass=password
StorageUser=slurm
#StorageLoc=slurm_acct_db

EOS

cat << EOS >> /usr/local/etc/slurmd.service
[Unit]
Description=Slurm node daemon
After=munge.service network-online.target remote-fs.target
Wants=network-online.target
#ConditionPathExists=/usr/local/etc/slurm.conf

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/slurmd
EnvironmentFile=-/etc/default/slurmd
ExecStart=/usr/local/sbin/slurmd -D -s $SLURMD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
LimitNOFILE=131072
LimitMEMLOCK=infinity
LimitSTACK=infinity
Delegate=yes


# Uncomment the following lines to disable logging through journald.
# NOTE: It may be preferable to set these through an override file instead.
#StandardOutput=null
#StandardError=null

[Install]
WantedBy=multi-user.target



EOS
cat << EOS >> /usr/local/etc/slurm.conf

ClusterName=cluster
SlurmctldHost=headnode
MpiDefault=none
ProctrackType=proctrack/cgroup
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
StateSaveLocation=/var/spool/slurmctld
SwitchType=switch/none
TaskPlugin=task/affinity
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_tres
AccountingStorageType=accounting_storage/none
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurmd.log
NodeName=linux[1-32] CPUs=1 State=UNKNOWN
PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP


EOS


sudo ln -s /usr/local/etc/slurmctld.service /etc/systemd/system/slurmctld.service
sudo ln -s /usr/local/etc/slurmdbd.service /etc/systemd/system/slurmdbd.service
sudo ln -s /usr/local/etc/slurmd.service /etc/systemd/system/slurmd.service
sudo mkdir /var/log/slurm
sudo mkdir /var/spool/slurmctld
chown slurm: /var/spool/slurmctld
sudo chown -R slurm.root /var/log/slurm
sudo systemctl enable slurmctld.service
sudo systemctld start slurmctld.service
}

slurm_setup
