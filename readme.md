#!/bin/bash

# 1. Update System
sudo apt update && sudo apt upgrade -y

# 2. Install Prerequisites & PHP 8.4 (using Ondřej Surý's PPA)
sudo apt install -y software-properties-common curl wget git unzip
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.4-fpm php8.4-mysql php8.4-xml php8.4-mbstring php8.4-curl php8.4-zip php8.4-gd php8.4-intl

# 3. Install Nginx
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# 4. Install MySQL
sudo apt install -y mysql-server
sudo systemctl enable mysql
sudo systemctl start mysql

# 5. Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 6. Install Composer (PHP Package Manager)
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# 7. Install phpMyAdmin (Manual latest download to avoid old repo versions)
PHPMYADMIN_VER="5.2.1"
wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VER}/phpMyAdmin-${PHPMYADMIN_VER}-all-languages.tar.gz
tar xvf phpMyAdmin-${PHPMYADMIN_VER}-all-languages.tar.gz
sudo mv phpMyAdmin-${PHPMYADMIN_VER}-all-languages /var/www/html/phpmyadmin
rm phpMyAdmin-${PHPMYADMIN_VER}-all-languages.tar.gz

# 8. Set Permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "------------------------------------------------"
echo "Installation Complete!"
echo "PHP: $(php -v | head -n 1)"
echo "Nginx: $(nginx -v 2>&1)"
echo "MySQL: $(mysql --version)"
echo "Composer: $(composer --version | head -n 1)"
echo "NVM installed. Please restart your terminal or run: source ~/.bashrc"
echo "phpMyAdmin available at: http://your_ip/phpmyadmin"
echo "------------------------------------------------"
