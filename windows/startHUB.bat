rem first set the correct environment

set PATH=%PATH%;"c:\Program Files (x86)\Git\bin";"C:\Program Files\Oracle\VirtualBox"

boot2docker stop

boot2docker delete


boot2docker init

vboxmanage modifyvm "boot2docker-vm" --cpus 6 --memory 38840 --vram 17

#  permanent VirtualBox NAT Port forwarding
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port8000,tcp,,8000,,8000"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port80,tcp,,80,,80"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port7081,tcp,,7081,,7081"


boot2docker start

set DOCKER_CERT_PATH=C:\Users\tschoots\.boot2docker\certs\boot2docker-vm
set DOCKER_TLS_VERIFY=1
set DOCKER_HOST=tcp://192.168.59.105:2376   // ip address can be found with "boot2docker ip"

docker run -t -i -p 4181:4181 -p 80:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 docker.io/blackduckhub/eval  /opt/blackduck/maiastra/start.sh


### issue how can i start so the ip address of the host is used.
### what are the firewall implications?