instuctions to run hub eval in docker.

install docker on your linux machine
Red hat 7 / centos 7
yum install docker -y

start docker 
systemctl start docker
make sure port 80 is accessable in the firewall

ubuntu 
apt-get install docker -y
service start docker
make sure port 80 is accessible in the firewall

now docker is started perform the folloing command
docker pull docker.io/blackduckhub/eval:v0.4.2

when the pull is finished start the script startHubEval.sh.
don't forget to do a chmod +x startHubEval.sh to make it executable.

Start a browser.
Change the hosts file of the machine where you start the bowser and make a enty like this:
<ip addres of you linux server with docker installed>     hubeval.blackducksoftware.com

When the hosts file is saved type the following url in your browser:
http://hubeval.blackducksoftware.com/

You should see the hub landing page.
Login with 
Sysadmin
blackduck

Then put in the license key you requested by you BlackDcuk



If your running on windows/mac install virtualbox and install a linux virtual machine and docker.

## to do 
instructions to use boot2docker

