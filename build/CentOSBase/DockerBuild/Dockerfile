FROM hubeval:latest
MAINTAINER Ton Schoots <ton@maiastra.com>

RUN set -x

# update the packages
RUN yum update -y && yum install -y \
  hostname \
  nc \
  libcap \
  nmap-ncat \
  tar \
  passwd \
  redhat-lsb-core \
  unzip \
  which

# set root password
RUN echo blackduck | passwd --stdin root

# create user and groups necessary for installation
RUN groupadd blckdck
RUN useradd -g blckdck blckdck
RUN echo blackduck | passwd --stdin blckdck

# preinstall stuff
RUN mkdir -p /opt/blackduck && chown blckdck:blckdck /opt/blackduck   \
#    && mkdir -p /home/blackduck && chown blckdck:blckdck /home/blackduck \
    && mkdir -p /var/lib/blckdck && chown blckdck:blckdck /var/lib/blckdck \
    && mkdir -p /var/spool/clones && chown blckdck:blckdck  /var/spool/clones \
    && mkdir -p /var/spool/mirrors && chown blckdck:blckdck /var/spool/mirrors \    
    && mkdir -p /opt/blackduck/maiastra && chown -R blckdck:blckdck /opt/blackduck \
    && usermod -m -d /home/blackduck blckdck 

# copy properties file for silent install
USER blckdck
# the following is specifically set for dev purposes
ENV  APPMGR_HUBINSTALL_OPTS "-Dlog4j.configuration=verbose-log4j.properties -DartifactoryURL=http://artifactory.blackducksoftware.com:8081 -DartifactoryPrefix=artifactory -DartifactoryRepo=bds-deployment-test"
RUN  mkdir -p /tmp/hubinstall
COPY silentInstall.properties /tmp/hubinstall/silentInstall.properties
COPY hubInstaller-2.4.0-SNAPSHOT-amd64.zip /tmp/hubinstall/hubInstaller-2.4.0-SNAPSHOT-amd64.zip
RUN  cd /tmp/hubinstall && unzip ./hubInstaller-2.4.0-SNAPSHOT-amd64.zip \
       && cd /tmp/hubinstall/appmgr.hubinstall-2.4.0-SNAPSHOT/bin/  \
       && ./appmgr.hubinstall -sf /tmp/hubinstall/silentInstall.properties





# the ports to expose for this image
EXPOSE 4181 8080 7081 55436 8009 8983 8909 80 443

# when the container starts run as blckdck user
USER blckdck
