cat << 'EOF' > setup_wsl_stack.sh
#!/bin/bash
set -e

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Memulai Setup WSL/Ubuntu 24 PHP Development Stack ===${NC}"

# Meminta akses sudo di awal
sudo -v

# 1. Update & Install Dependencies Dasar
echo -e "${BLUE}[1/8] Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl wget unzip git

# 2. Install PHP 8.4 (Menggunakan PPA Ondrej Surý)
echo -e "${BLUE}[2/8] Menginstal PHP 8.4...${NC}"
# Hindari crash jika PPA sudah ada
sudo add-apt-repository ppa:ondrej/php -y || true
sudo apt update
# Menginstal PHP-FPM dan ekstensi yang sering dibutuhkan framework modern (seperti Laravel 11)
sudo apt install -y php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-zip php8.4-mbstring php8.4-bcmath php8.4-intl

# 3. Install Nginx
echo -e "${BLUE}[3/8] Menginstal Nginx...${NC}"
sudo apt install -y nginx

# Setup Nginx Config untuk PHP di WSL
WEB_ROOT="/var/www/html"
echo -e "${BLUE}[INFO] Membuat konfigurasi Nginx PHP di /etc/nginx/sites-available/default...${NC}"

sudo bash -c "cat > /etc/nginx/sites-available/default" << 'NGINX_CONF'
server {
    listen 80;
    server_name localhost;
    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Ubuntu menggunakan Unix Socket by default untuk PHP-FPM
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
NGINX_CONF

sudo systemctl restart nginx
sudo systemctl restart php8.4-fpm

# 4. Install MySQL
echo -e "${BLUE}[4/8] Menginstal MySQL...${NC}"
sudo apt install -y mysql-server
sudo systemctl start mysql

# Mengamankan root user untuk development lokal
# Menggunakan '|| true' agar script tidak terhenti jika root sudah memiliki password
sleep 2
echo -e "${BLUE}[INFO] Mengatur password MySQL root...${NC}"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null || echo -e "${BLUE}[INFO] MySQL root password sudah diset sebelumnya. Melewati tahap ini...${NC}"

# 5. Install NVM & Node.js (Tanpa sudo agar masuk ke user directory)
echo -e "${BLUE}[5/8] Menginstal NVM...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM sementara untuk sesi instalasi ini
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node # Install latest node

# 6. Install Composer
echo -e "${BLUE}[6/8] Menginstal Composer...${NC}"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm /tmp/composer-setup.php

# 7. Install phpMyAdmin
echo -e "${BLUE}[7/8] Menginstal phpMyAdmin...${NC}"
PMA_VER="5.2.1"
cd /tmp
curl -O -L https://files.phpmyadmin.net/phpMyAdmin/${PMA_VER}/phpMyAdmin-${PMA_VER}-all-languages.zip
unzip -q phpMyAdmin-${PMA_VER}-all-languages.zip
sudo rm -rf "$WEB_ROOT/phpmyadmin"
sudo mv phpMyAdmin-${PMA_VER}-all-languages "$WEB_ROOT/phpmyadmin"
rm phpMyAdmin-${PMA_VER}-all-languages.zip

# Konfigurasi phpMyAdmin
sudo cp "$WEB_ROOT/phpmyadmin/config.sample.inc.php" "$WEB_ROOT/phpmyadmin/config.inc.php"
RANDOM_SECRET=$(openssl rand -base64 32)
sudo sed -i "s/\['blowfish_secret'\] = '';/\['blowfish_secret'\] = '$RANDOM_SECRET';/" "$WEB_ROOT/phpmyadmin/config.inc.php"

# 8. Set Permissions (User lokal sebagai owner, www-data sebagai group)
echo -e "${BLUE}[8/8] Mengatur Permission...${NC}"
sudo chown -R $USER:www-data "$WEB_ROOT"
sudo chmod -R 775 "$WEB_ROOT"

# Buat info.php untuk testing
echo "<?php phpinfo(); ?>" > "$WEB_ROOT/info.php"

echo "------------------------------------------------"
echo -e "${GREEN}Installation Complete!${NC}"
echo "------------------------------------------------"
echo "PHP Version      : $(php -v | head -n 1)"
echo "Nginx            : Running on port 80"
echo "MySQL            : Running (Cek log di atas jika password gagal diset)"
echo "Composer         : $(composer --version | head -n 1)"
echo "Web Root         : $WEB_ROOT"
echo "------------------------------------------------"
echo -e "${GREEN}Akses Dashboard:${NC}"
echo "1. Cek PHP       : http://localhost/info.php"
echo "2. phpMyAdmin    : http://localhost/phpmyadmin"
echo "------------------------------------------------"
echo "Catatan: Jalankan perintah 'source ~/.bashrc' (atau ~/.zshrc jika menggunakan zsh) agar perintah 'nvm' dan 'node' langsung bisa digunakan di terminal ini."
EOF

chmod +x setup_wsl_stack.sh && ./setup_wsl_stack.sh
