#!/bin/bash
# cantalupo555
# Install Web + rTorrent + qBittorrent + proFTPd
sudo dpkg-reconfigure tzdata
sudo apt-get autoremove -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
sudo apt-get update
sudo apt-get install apache2 curl php libapache2-mod-php php-mcrypt php-mysql php7.0-zip php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc rtorrent proftpd qbittorrent qbittorrent-nox screen-y

# Config Web
sudo apache2ctl configtest
sudo ufw app list
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"
sudo a2enmod rewrite
echo "" >> /etc/apache2/apache2.conf
echo "<Directory /var/www/html/>" >> /etc/apache2/apache2.conf
echo "AllowOverride All" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf
service apache2 restart

# Config rTorrent
cd ~/
wget http://80.211.146.153/rtorrent.rc
mv rtorrent.rc .rtorrent.rc
mkdir /home/rtorrent
mkdir /home/rtorrent/Downloads
mkdir /home/rtorrent/.session
mkdir /home/rtorrent/watch

# User proFTPd
#sudo adduser downloads --home=/home/rtorrent/Downloads --shell=/bin/false
sudo useradd -m downloads --home=/home/rtorrent/Downloads --shell=/bin/false

# Config proFTPd
wget http://80.211.146.153/proftpd.conf
mv proftpd.conf /etc/proftpd/
sudo /etc/init.d/proftpd restart
echo "* * * * * root chown -R downloads:downloads /home/rtorrent/Downloads" >> /etc/crontab

# Intall and Config ruTorrent
cd /var/www/html
wget http://80.211.146.153/rutorrent-3.6.tar.gz -O rutorrent-3.6.tar.gz
tar -xvf rutorrent-3.6.tar.gz
rm rutorrent-3.6.tar.gz
cd rutorrent
wget http://80.211.146.153/plugins-3.6.tar.gz -O plugins-3.6.tar.gz
tar -xvf plugins-3.6.tar.gz
rm plugins-3.6.tar.gz
cd plugins
rm -rf mediainfo screenshots unpack
cd ../..
sudo ln -s /home/rtorrent/Downloads downloads

# Password in directory
cd /var/www/html/rutorrent
echo "AuthType Basic" >> .htaccess
echo "AuthName cantalupo555" >> .htaccess
echo "AuthUserFile /home/rtorrent/.htpasswd" >> .htaccess
echo "Require valid-user" >> .htaccess

cd /home/rtorrent/Downloads
echo "AuthType Basic" >> .htaccess
echo "AuthName cantalupo555" >> .htaccess
echo "AuthUserFile /home/rtorrent/.htpasswd" >> .htaccess
echo "Require valid-user" >> .htaccess

cd /home/rtorrent/
htpasswd -cb .htpasswd

# Permission in directory web
cd /var/www/
chown -R 33:33 html/

# Daemon
cd ~
echo -e ' [Unit]\n Description=qBittorrent Daemon Service\n After=network.target\n \n [Service]\n User=downloads\n ExecStart=/usr/bin/qbittorrent-nox\n ExecStop=/usr/bin/killall -w qbittorrent-nox\n \n [Install]\n WantedBy=multi-user.target'| sudo tee /etc/systemd/system/qbittorrent.service
echo -e ' [Unit]\n Description=rTorrent Daemon Service\n After=network.target\n \n [Service]\n User=downloads\n ExecStart=/usr/bin/rtorrent\n ExecStop=/usr/bin/killall -w rtorrent\n \n [Install]\n WantedBy=multi-user.target'| sudo tee /etc/systemd/system/rtorrent.service
sudo systemctl daemon-reload && sudo systemctl enable qbittorrent && sudo systemctl start qbittorrent && sudo systemctl enable rtorrent && sudo systemctl start rtorrent
