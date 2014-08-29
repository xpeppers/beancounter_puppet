sudo apt-get install --yes lsb-release
DISTRIB_CODENAME=$(lsb_release --codename --short)
DEB="puppetlabs-release-${DISTRIB_CODENAME}.deb"
DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list"

if [ ! -e $DEB_PROVIDES ]
then
    wget -q http://apt.puppetlabs.com/$DEB
    sudo dpkg -i $DEB
fi

sudo rm /var/lib/apt/lists/* -vf
sudo apt-get update
sudo apt-get install --yes puppet
