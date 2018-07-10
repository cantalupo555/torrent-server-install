#!/bin/bash
# cantalupo555

#User e Password
echo "@cantalupo555"
echo ""
echo "Digite o nome de usuário:"
read user
echo ""
echo "Digite a senha para o usuário"
read pass

# Install rTorrent + qBittorrent + proFTPd
sudo dpkg-reconfigure tzdata
sudo apt-get autoremove -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
sudo apt-get update
sudo apt-get install apache2 curl php libapache2-mod-php php-mcrypt php-mysql php7.0-zip php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc rtorrent proftpd qbittorrent qbittorrent-nox screen bmon htop sudo --allow-unauthenticated -y

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

# User proFTPd
#sudo adduser downloads --home=/home/rtorrent/Downloads --shell=/bin/false
sudo useradd -m $user --home=/home/rtorrent/ --shell=/bin/false
echo $user:$pass | chpasswd

# Config proFTPd
cd /etc/proftpd/
echo "DefaultRoot ~" >> proftpd.conf
echo "RequireValidShell off" >> proftpd.conf
echo "CreateHome on" >> proftpd.conf
echo "" >> proftpd.conf
echo "<Directory /home/*>" >> proftpd.conf
echo "        HideFiles (^\..*|\.sh$)" >> proftpd.conf
echo "        <Limit ALL>" >> proftpd.conf
echo "        IgnoreHidden On" >> proftpd.conf
echo "        </Limit>" >> proftpd.conf
echo "</Directory>" >> proftpd.conf
sudo /etc/init.d/proftpd restart
echo "* * * * * root chown -R $user:$user /home/rtorrent/Downloads" >> /etc/crontab

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
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| sudo tee .htaccess
cd /home/rtorrent/Downloads
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| sudo tee .htaccess
cd /home/rtorrent/
htpasswd -cb .htpasswd $user $pass

# Permission in directory web
cd /var/www/
chown -R 33:33 html/

# Daemon
cd ~
echo -e "[Unit]\nDescription=qBittorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/qbittorrent-nox\nExecStop=/usr/bin/killall -w qbittorrent-nox\n\n[Install]\nWantedBy=multi-user.target"| sudo tee /etc/systemd/system/qbittorrent.service
echo -e "[Unit]\nDescription=rTorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n#ExecStop=/usr/bin/screen -X -S rtorrent quit\n\n[Install]\n WantedBy=multi-user.target"| sudo tee /etc/systemd/system/rtorrent.service
sudo systemctl daemon-reload && sudo systemctl enable qbittorrent && sudo systemctl start qbittorrent && sudo systemctl enable rtorrent && sudo systemctl start rtorrent
echo -e '#! /bin/sh\n\n### BEGIN INIT INFO\n# Provides:           unitr\n# Required-Start:     $local_fs $remote_fs $network $syslog $netdaemons\n# Required-Stop:      $local_fs $remote_fs\n# Default-Start:      2 3 4 5\n# Default-Stop:       0 1 6\n# Short-Description:  Example of init service.\n# Description:\n#  Long description of my service.\n### END INIT INFO\n\n# Actions provided to make it LSB-compliant\ncase "$1" in\n  start)\n    echo "Starting unitr"\n    sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  stop)\n    echo "Stopping script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit\n    ;;\n  restart)\n    echo "Restarting script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit && sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  force-reload)\n    echo "Reloading script unitr"\n    #Insert your reload routine here\n    ;;\n  status)\n    echo "Status of script unitr"\n    #Insert your stop routine here\n    ;;\n  *)\n    echo "Usage: /etc/init.d/unitr {start|stop|restart|force-reload|status}"\n    exit 1\n    ;;\nesac\n\nexit 0'| sudo tee /etc/init.d/unitr
sudo chmod +x /etc/init.d/unitr && sudo chmod 777 /etc/init.d/unitr && update-rc.d unitr defaults
clear
echo "Installation Complete" && echo "By: @cantalupo555" && echo ""
echo "		Reboot..."
echo "			Reboot..."
echo "				Reboot..."
echo "					Reboot..."
echo "						Reboot..."
echo ""
sudo shutdown -r now
