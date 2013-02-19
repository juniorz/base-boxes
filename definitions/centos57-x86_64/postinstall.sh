#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

#kernel source is needed for vbox additions
yum -y install dkms gcc bzip2 make kernel-devel-`uname -r`
#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel
yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

# Install dependencies for RVM and Ruby...
yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel git

# RVM
curl -L https://get.rvm.io | sudo bash -s stable
sudo usermod --append --groups rvm vagrant
source /etc/profile.d/rvm.sh

# Install Ruby 1.9.3-125
RUBY_VER="1.9.3-p385"

/usr/local/rvm/bin/rvm install $RUBY_VER -C --sysconfdir=/etc
/usr/local/rvm/bin/rvmsudo /usr/local/rvm/bin/rvm alias create default $RUBY_VER

# ln -s /usr/local/bin/ruby /usr/bin/ruby # Create a sym link for the same path
# ln -s /usr/local/bin/gem /usr/bin/gem # Create a sym link for the same path

#Installing chef & Puppet
echo "Installing chef and puppet"
/usr/local/rvm/bin/gem install chef --no-ri --no-rdoc || fail "Could not install chef"
/usr/local/rvm/bin/gem install puppet --no-ri --no-rdoc || fail "Could not install puppet"

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

#poweroff -h

exit
