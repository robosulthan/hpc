#!/usr/bin/sh 
export MUNGEUSER=1001
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=1002
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurmexport MUNGEUSER=1001
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=1002
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

#wget https://github.com/dun/munge/releases/download/munge-0.5.15/munge-0.5.15.tar.xz
#tar xJf munge-0.5.15.tar.xz
#cd munge-0.5.15
#./configure \
#     --prefix=/usr \
#     --sysconfdir=/etc \
#     --localstatedir=/var \
#     --runstatedir=/run
#make
#make check
#make install
#

#Configuration and setup
sudo -u munge mungekey --verbose
sudo systemctl enable munge.service
sudo systemctl start munge.service

#Verification
munge -n
git clone https://github.com/SchedMD/slurm.git
cd slurm
./configure --prefix=/nfsshare/apps/slurm --sysconfdir=/etc
make
make install

mkdir /var/spool/slurmctld
chown slurm: /var/spool/slurmctld
chmod 755 /var/spool/slurmctld
touch /var/log/slurmctld.log
chown slurm: /var/log/slurmctld.log
touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log/var/log/slurmctld.log
