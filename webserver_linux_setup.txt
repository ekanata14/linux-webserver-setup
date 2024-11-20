## Install nginx
sudo apt install nginx

## Install Apache
install apache2 = sudo apt install apache2
start apache = systemctl start apache2
stop apache = systemctl stop apache2
checking apache status = systemctl status apache2

## Install PHP
sudo apt update
sudo apt install software-properties-common

sudo add-apt-repository ppa:ondrej/php

sudo apt update
sudo apt install php8.1 php8.1-cli php8.1-fpm
sudo apt install php8.3 php8.3-cli php8.3-fpm

php8.1 -v
php8.3 -v

sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.1 1
sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.3 2

sudo update-alternatives --config php

## Install Mysql Server
sudo apt install mysql-server

sudo mysql_secure_installation

sudo mysql -u root -p

CREATE USER 'dream'@'localhost' IDENTIFIED BY 'password_user';

GRANT ALL PRIVILEGES ON *.* TO 'dream'@'localhost';

FLUSH PRIVILEGES;

## Install NVM
sudo apt update && sudo apt upgrade -y

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

source ~/.bashrc  # Jika menggunakan Bash
source ~/.zshrc   # Jika menggunakan Zsh

nvm --version

## Node JS install with NVM

nvm install node

