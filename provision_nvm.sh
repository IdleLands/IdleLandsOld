node_version='0.10.33'

# Install nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
echo "source ~/.nvm/nvm.sh" >> /home/vagrant/.bashrc
source /home/vagrant/.nvm/nvm.sh

# Install node using nvm
echo "Installing node via nvm..."
nvm install $node_version
nvm alias default $node_version
chown -R vagrant:vagrant /home/vagrant/.nvm

echo "Running npm install..."
echo "PATH=$PATH:/vagrant/node_modules/.bin" >> /home/vagrant/.bashrc
PATH=$PATH:/vagrant/node_modules/.bin
cd /vagrant && rm -rf node_modules
[ -f package.json ] && npm install --no-bin-links

echo "Installing global npm packages..."
# Global npm dependencies
npm install -g coffee-script grunt-cli

echo "Creating symlinks..."
ln -s /vagrant /home/vagrant/IdleLands
echo "cd /home/vagrant/IdleLands" >> ~/.bashrc