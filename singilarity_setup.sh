#!/usr/bin/bash
#
# Install basic tools for compiling
sudo yum groupinstall -y 'Development Tools'

# Install RPM packages for dependencies
sudo yum install -y \
   libseccomp-devel \
   glib2-devel \
   squashfs-tools \
   cryptsetup \
   runc
export VERSION=19.5 OS=linux ARCH=amd64
wget https://go.dev/dl/go$VERSION.$OS-$ARCH.tar.gz
sudo tar -C /nfsshare/apps -xzvf go$VERSION.$OS-$ARCH.tar.gz
#rm go$VERSION.$OS-$ARCH.tar.gz
echo 'export GOPATH=/nfsshare/apps/workspace' >> ~/.bashrc 
echo 'export GOROOT=/nfsshare/apps/go' >> ~/.bashrc 
echo 'export PATH=/nfsshare/apps/go/bin:${PATH}:/nfsshare/apps/go/bin' >> ~/.bashrc
. ~/.bashrc
mkdir /nfsshare/apps/singularity
cd /nfsshare/apps/workspace/
git clone --recurse-submodules https://github.com/sylabs/singularity.git
cd singularity
./mconfig --prefix=/nfsshare/apps/singularity
make -C builddir
sudo make -C builddir install
