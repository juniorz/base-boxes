# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev
apt-get -y install vim
apt-get clean

# Installing the virtualbox guest additions
apt-get -y install dkms
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

cd /tmp

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Add puppet user and group
adduser --system --group --home /var/lib/puppet puppet

# Install NFS client
apt-get -y install nfs-common

# Install dependencies for RVM and Ruby...
# yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel git

apt-get install -y curl git-core libreadline6-dev
apt-get install -y libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev

# RVM
curl -L https://get.rvm.io | sudo bash -s stable
sudo usermod --append --groups rvm vagrant
source /etc/profile.d/rvm.sh

# Install Ruby 1.9.3-p392
RUBY_VER="1.9.3-p392"

/usr/local/rvm/bin/rvm install $RUBY_VER -C --sysconfdir=/etc
/usr/local/rvm/bin/rvmsudo /usr/local/rvm/bin/rvm alias create default $RUBY_VER

# Installing chef & Puppet
echo "Installing chef and puppet"
/usr/local/rvm/bin/gem install chef --no-ri --no-rdoc || fail "Could not install chef"
/usr/local/rvm/bin/gem install puppet --no-ri --no-rdoc || fail "Could not install puppet"

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
# echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
