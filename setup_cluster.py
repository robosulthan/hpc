import os
import socket
import json
from configparser import ConfigParser
data_file = 'hpc.conf'

config = ConfigParser()
config.read(data_file)
nodes=config['cluster']['nodes']
nodes = json.loads(nodes)
hostname = socket.gethostname()
current_ip = socket.gethostbyname(hostname)
print("------------------------------------")
#print(nodes.items())
print("------------------------------------")

def role_setup(hostName,Role):

    if Role == "Generic_Role":
        cmd = "sudo hostnamectl set-hostname " + hostName
        os.system(cmd)
        cmd = 'sudo yum -y update'
        os.system(cmd)
        cmd = 'sudo cat .hosts >>/etc/hosts'
        #os.system(cmd)
        datapath= "/nfsshare/data"
        appspath="/nfsshare/apps"
        isExist = os.path.exists(datapath)
        print(isExist)
        if not isExist:
            cmd = "sudo mkdir -p /nfsshare/data /nfsshare/apps"
            print(cmd)
            os.system(cmd)
        isExist = os.path.exists(appspath)
        print(isExist)
        if not isExist:
            cmd = "sudo mkdir -p /nfsshare/data /nfsshare/apps"
            print(cmd)
            os.system(cmd)
        if hostName != "headnode":
            hfstab_entries="/nfsshare/home /nfsshare/home ext4 defaults 1 1)"
            dfstab_entries="/nfsshare/data /nfsshare/data ext4 defaults 1 1)"
            afstab_entries="/nfsshare/home /nfsshare/apps ext4 defaults 1 1)"
            file1 = open("/etc/fstab", "a")  # append mode
            file1.write(hfstab_entries+"\n"+dfstab_entries+"\n"+afstab_entries)
            file1.close()

    elif Role=="nfs":
        hexport_entries="/nfsshare/home *(rw,sync,no_root_squash)"
        dexport_entries="/nfsshare/data *(rw,sync,no_root_squash)"
        aexport_entries="/nfsshare/apps *(rw,sync,no_root_squash)"
        file1 = open("/etc/exports", "a")  # append mode
        file1.write(hexport_entries+"\n"+dexport_entries+"\n"+aexport_entries)
        file1.close()
        cmd="yum install nfs-utils nfs-utils-lib -y"
        os.system(cmd)
        cmd="exportfs -av"
        os.system(cmd)
        cmd="systemctl enable nfs.service"
        os.system(cmd)
        cmd="systemctl start nfs.service"
        os.system(cmd)
    elif Role=="singularity":
        cmd="sh s.sh"
        os.system(cmd)

def node_setup(hostName,ipAddr):
    if hostName=="headnode" and ipAddr == current_ip:
        print("Head node configuration started")
        role_setup(hostName,"Generic_Role")
        role_setup(hostName,"nfs")
        role_setup(hostName,"singularity")
        
    elif hostName=="nfsnode" and ipAddr == current_ip:
        print("NFS node configuration started")
        role_setup(hostName,"Generic_Role")
    elif ipAddr == current_ip:
        print("Compute node configuration started")
        role_setup(hostName,"Generic_Role")


def main():
    current_ip = socket.gethostbyname(hostname)
    print("HPC Cluster setup")
    print("------------------")
    os.system("echo ''>.hosts")
    for node,ip in nodes.items():
        cmd = "echo "+ip+" "+node +">> .hosts"
        os.system(cmd)

    if not nodes:
        print("nodes config is Empty")
    else:
        for node,ip in nodes.items():
            if node == "headnode" and ip == current_ip:
                print("Head node configuration")
                print("Hostname : ",node)
                print("Ipaddress : ",ip)
                print("ServerType :",node)
                res=input("Continue ( y/n) : ")
                if res=="y":
                    node_setup(node,ip)
                else:
                    print("Setup exit")
            elif node== "nfsnode" and ip == current_ip:
                print("NFS server configuration")
                print("Hostname : ",node)
                print("Ipaddress : ",ip)
                print("ServerType :",node)
                res=input("Continue ( y/n) : ")
                if res == 'y':
                    node_setup(node,ip)
                else:
                          print("Setup exit")
            elif ip == current_ip:
                print("Compute node setup")
                print("Hostname : ",node)
                print("Ipaddress : ",ip)
                print("ServerType :",node)
                res=input("Continue ( y/n) : ")
                if res == 'y':
                    node_setup(node,ip)
                else:
                    print("Setup exit")

                
if __name__=="__main__":
    main()
