# Ultimate Laravel Server Setup Guide

This guide covers setting up a Linux server (Ubuntu 20.04/22.04/24.04) with **Nginx**, **MySQL**, **PHP 8.4**, **phpMyAdmin**, and **NVM**.

## 1. Update System

Start by ensuring your package lists are up to date.

```bash
sudo apt update && sudo apt upgrade -y

```

## 2. Install Nginx & Core Utilities

Install the web server and essential tools like git, curl, and zip.

```bash
sudo apt install -y nginx curl git unzip zip software-properties-common

```

## 3. Install MySQL Server

Install the database server and run the security script.

```bash
sudo apt install -y mysql-server

```

**Secure the installation:**
Run the command below. Answer `Y` to enable password validation component (optional), remove anonymous users, disallow root login remotely, and remove the test database.

```bash
sudo mysql_secure_installation

```

**Create a Database User for Laravel:**

```bash
sudo mysql

```

*Inside the MySQL prompt:*

```sql
CREATE DATABASE laravel_app;
CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON laravel_app.* TO 'laravel_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

```

## 4. Install PHP 8.4 (via PPA)

Ubuntu repositories might not have 8.4 yet, so we use the Ondřej Surý PPA.

```bash
# Add the PHP PPA
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.4 and FPM (for Nginx) + Common Laravel Extensions
sudo apt install -y php8.4 php8.4-fpm php8.4-mysql php8.4-mbstring \
php8.4-xml php8.4-bcmath php8.4-curl php8.4-zip php8.4-intl \
php8.4-gd php8.4-tokenizer

```

## 5. Install phpMyAdmin

Install phpMyAdmin to manage your database via the browser.

```bash
sudo apt install -y phpmyadmin

```

**IMPORTANT during installation:**

1. **Web Server Selection:** When asked to choose a web server (Apache/Lighttpd), **press `TAB` and then `ENTER**`. Do **NOT** select Apache (since we are using Nginx).
2. **dbconfig-common:** Select **Yes** to configure the database for phpMyAdmin.
3. **Password:** Set a password for the phpMyAdmin application itself.

**Link phpMyAdmin to Nginx:**
Since Nginx was not selected during install, create a symbolic link to the web root:

```bash
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

```

## 6. Install NVM & Node.js

Install NVM (Node Version Manager) and the latest LTS version of Node.

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Activate NVM without restarting shell
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest Node LTS
nvm install --lts

```

## 7. Install Composer

Install the PHP dependency manager.

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

```

## 8. Configure Nginx (Laravel + phpMyAdmin)

Create a configuration file for your site.

```bash
sudo nano /etc/nginx/sites-available/laravel

```

Paste the following configuration. Replace `your_domain_or_IP` with your actual server IP or domain.

```nginx
server {
    listen 80;
    server_name your_domain_or_IP;
    root /var/www/html/public; # Pointing to Laravel public folder

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Handle Laravel Routes
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Handle phpMyAdmin
    # This location block ensures phpMyAdmin works via http://your-ip/phpmyadmin
    location /phpmyadmin {
        root /var/www/html;
        index index.php index.html index.htm;
        
        location ~ ^/phpmyadmin/(.+\.php)$ {
            try_files $uri =404;
            root /var/www/html;
            fastcgi_pass unix:/run/php/php8.4-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
            root /var/www/html;
        }
    }

    # Handle PHP Processing
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

```

**Enable the Site:**

```bash
# Remove default config
sudo rm /etc/nginx/sites-enabled/default

# Link new config
sudo ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

```

## 9. Permissions Check

Ensure your web user (usually `www-data`) owns the directory.

```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 775 /var/www/html

```

---

### Verification

1. **Laravel:** Navigate to `http://your_server_ip`. You should see a 403 or 404 (because the Laravel folder is empty) or the default Nginx page if you haven't deployed code yet.
2. **phpMyAdmin:** Navigate to `http://your_server_ip/phpmyadmin`. Log in with the MySQL user you created in Step 3.
