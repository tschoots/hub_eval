#!/usr/bin/env bash

usage() {
  cat <<EOOPTS
  $(basename $0) [OPTIONS] <name>
  OPTIONS:
    -y <yumconf> The path to the yum config to install packages from. The default is /etc/yum.conf
EOOPTS
     exit 1
}

checkUser() {
  runuser=$(id -un)
  if [ "${runuser}" != "root" ]; then
    echo "You must run this as root, change to root and try again"
    exit 1
  fi
}

checkUser

#option defaults
yum_config=/etc/yum.conf
while  getopts ":y:h" opt; do
   echo $opt
   case $opt in
      y)
         yum_config=$OPTARG
         ;;
      h)
         usage
         ;; 
      "hallo")
         echo "hallo"
         ;;
      \?)
         echo "invalid option: -$OPTARG"
         usage
         ;;
   esac 
done
#reset to the first left parameters
shift $((OPTIND - 1))
name=$1
#check if name is given
if [[ -z $name ]];then
  usage
fi

########### all input check finished now process to create image ####

target=$(mktemp -d --tmpdir $(basename $0).tmp.XXXXXXX)
echo $target

# put i kind of debug mode as if you start cli bash -x ..
set -x


mkdir -m 775 "$target"/dev
mknod -m 600 "$target"/dev/console c 5 1
mknod -m 600 "$target"/dev/initctl p      # linux rc related
mknod -m 666 "$target"/dev/full c 1 7
mknod -m 666 "$target"/dev/null c 1 3
mknod -m 666 "$target"/dev/ptmx c 5 2     # pseudo terminal
mknod -m 666 "$target"/dev/random c 1 8   # random chars for kernel
mknod -m 666 "$target"/dev/tty c 5 0 
mknod -m 666 "$target"/dev/tty0 c 4 0 
mknod -m 666 "$target"/dev/urandom c 1 9   # random chars for kernel
mknod -m 666 "$target"/dev/zero c 1 5


# amazon linux yum will fail without vars set
if [ -d /etc/yum/vars ]; then
  mkdir -p -m 755 "$target"/etc/yum
  cp -a /etc/yum/vars "$target"/etc/yum 
fi

yum -c "$yum_config" --installroot="$target" --releasever=/ --setopt=tsflags=nodocs \
    --setopt=group_package_types=mandatory -y groupinstall Core
yum -c "$yum_config" --installroot="$target" -y clean all

cat > "$target"/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb
# --keep-services "$target". Stolen from mkimgage-rinse.sh
# locales
rm -rf "$target

#rm -rf "$target"
echo "$target"
