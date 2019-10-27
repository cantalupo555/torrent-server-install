#!/bin/bash
# cantalupo555
o1(){
echo ""
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Press ENTER to go back!"	
echo ""
read v	
}

while true
do
clear
echo "   ________________________________________"
echo "   |>                                    <|"
echo "   |>   Choose an option:                <|"
echo "   |>   1 - qBittorrent + ruTorrent      <|"
echo "   |>   2 - Exit                         <|"
echo "   |>____________________________________<|"
echo ""
echo "Select option from 1 to 4:"
echo ""
read op
case $op in

#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
1) while true; do

# /-/-/-/Ensure the OS is compatible with the launcher/-/-/-/
clear
echo -e "\n\e[1;33mChecking that minimal requirements are ok\e[0m"
if [ -f /etc/centos-release ]; then
    OS="CentOs"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6 or 7
elif [ -f /etc/lsb-release ]; then
    OS=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
    VER=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
elif [ -f /etc/os-release ]; then
    OS=$(grep -w ID /etc/os-release | sed 's/^.*=//')
    VER=$(grep VERSION_ID /etc/os-release | sed 's/^.*"\(.*\)"/\1/')
 else
    OS=$(uname -s)
    VER=$(uname -r)
fi
ARCH=$(uname -m)
echo "Detected : $OS  $VER  $ARCH"&&r='add-apt-repository'
if [[ "$OS" = "Ubuntu" && ("$VER" = "16.04" || "$VER" = "18.04" ) ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported." 
    exit 1
fi
 
# /-/-/-/root?/-/-/-/
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
 
# /-/-/-/User and Password/-/-/-/
echo ""
echo "By: @cantalupo555"
echo ""
echo -e " \033[42;1;37mEnter the name for the user:\033[0m"
read user
echo ""
echo -e " \033[42;1;37mEnter the password for the user:\033[0m"
read pass

# /-/-/-/IP/-/-/-/
extern_ip="$(wget -qO- http://api.sentora.org/ip.txt)"
#local_ip=$(ifconfig eth0 | sed -En 's|.*inet [^0-9]*(([0-9]*\.){3}[0-9]*).*$|\1|p')
local_ip=$(ip addr show | awk '$1 == "inet" && $3 == "brd" { sub (/\/.*/,""); print $2 }')&&all='apt-get install'
    PUBLIC_IP=$extern_ip

# /-/-/-/Dependencies/-/-/-/
dpkg-reconfigure tzdata
apt-get autoremove -y
$all software-properties-common -y
$r ppa:qbittorrent-team/qbittorrent-stable -y
$r ppa:ondrej/apache2 -y
$r ppa:ondrej/php -y&&apt-get update
$all proftpd apache2 curl php libapache2-mod-php php-mysql php-zip php-intl php-curl php-gd php-mbstring php-xml php-xmlrpc rtorrent qbittorrent qbittorrent-nox screen make gcc libc6-dev unzip rar unrar mediainfo --allow-unauthenticated -y

# /-/-/-/Config Web/-/-/-/
apache2ctl configtest
ufw app list
ufw app info "Apache Full"
ufw allow in "Apache Full"
a2enmod rewrite
echo "" >> /etc/apache2/apache2.conf
echo "<Directory /var/www/html/>" >> /etc/apache2/apache2.conf
echo "AllowOverride All" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf
statusdir=/var/www/html/status
service apache2 restart
cd ~/

# /-/-/-/Config rTorrent/-/-/-/
wget https://raw.githubusercontent.com/cantalupo555/torrent-server-install/master/rtorrent.rc
mv rtorrent.rc .rtorrent.rc
mkdir /home/rtorrent
mkdir /home/rtorrent/Downloads
mkdir /home/rtorrent/.session
useradd -m $user --home=/home/rtorrent --shell=/bin/false
echo $user:$pass | chpasswd
chown $user:$user /home/rtorrent

# /-/-/-/Config proFTPd/-/-/-/
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
/etc/init.d/proftpd restart
echo "* * * * * root chown -R $user:$user /home/rtorrent/Downloads" >> /etc/crontab

# /-/-/-/Intall and Config ruTorrent/-/-/-/
cd /var/www/html
wget https://github.com/Novik/ruTorrent/archive/master.zip -O rutorrent.zip
unzip rutorrent.zip&&mv ruTorrent-master/ rutorrent/
rm rutorrent.zip
cd rutorrent/plugins&&rm -rf spectrogram/ unpack/
cd ../..
ln -s /home/rtorrent/Downloads downloads
cd /var/www/html/rutorrent
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| tee .htaccess
cd /home/rtorrent/Downloads
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| tee .htaccess
cd /home/rtorrent/
htpasswd -cb .htpasswd $user $pass

cd /var/www/
chown -R 33:33 html/
cd ~
echo -e "[Unit]\nDescription=qBittorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/qbittorrent-nox\nExecStop=/usr/bin/killall -w qbittorrent-nox\n\n[Install]\nWantedBy=multi-user.target"| tee /etc/systemd/system/qbittorrent.service
echo -e "[Unit]\nDescription=rTorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n#ExecStop=/usr/bin/screen -X -S rtorrent quit\n\n[Install]\n WantedBy=multi-user.target"| tee /etc/systemd/system/rtorrent.service
systemctl daemon-reload&&systemctl enable qbittorrent&&systemctl start qbittorrent&&systemctl enable rtorrent&&systemctl start rtorrent
echo -e '#! /bin/sh\n\n### BEGIN INIT INFO\n# Provides:           unitr\n# Required-Start:     $local_fs $remote_fs $network $syslog $netdaemons\n# Required-Stop:      $local_fs $remote_fs\n# Default-Start:      2 3 4 5\n# Default-Stop:       0 1 6\n# Short-Description:  Example of init service.\n# Description:\n#  Long description of my service.\n### END INIT INFO\n\n# Actions provided to make it LSB-compliant\ncase "$1" in\n  start)\n    echo "Starting unitr"\n    sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  stop)\n    echo "Stopping script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit\n    ;;\n  restart)\n    echo "Restarting script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit && sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  force-reload)\n    echo "Reloading script unitr"\n    #Insert your reload routine here\n    ;;\n  status)\n    echo "Status of script unitr"\n    #Insert your stop routine here\n    ;;\n  *)\n    echo "Usage: /etc/init.d/unitr {start|stop|restart|force-reload|status}"\n    exit 1\n    ;;\nesac\n\nexit 0'| tee /etc/init.d/unitr
chmod +x /etc/init.d/unitr&&chmod 777 /etc/init.d/unitr&&update-rc.d unitr defaults
clear
echo -e " \033[44;1;37mInstallation Complete\033[0m"&&echo "By: @cantalupo555"&&echo ""
echo -e "\e[1;33m############################################\e[0m"
echo -e " \033[44;1;37mruTorrent: http://$PUBLIC_IP/rutorrent\033[0m"
echo -e " \033[41;1;37mqBittorrent: http://$PUBLIC_IP:8080\033[0m"
echo -e " \033[44;1;37mqBittorrent User: admin Password: adminadmin\033[0m"
echo -e " \033[41;1;37mDownloads Web: http://$PUBLIC_IP/downloads\033[0m"
echo -e " \033[44;1;37mNetwork Status: http://$PUBLIC_IP/status\033[0m"
echo -e " \033[41;1;37mFTP >>> Host: $PUBLIC_IP Port: 21\033[0m"
echo -e " \033[44;1;37mUser: $user Password: $pass\033[0m"
echo -e "\e[1;33m############################################\e[0m"
echo ""
echo "		Reboot..."
echo "			Reboot..."
echo "				Reboot..."
echo "					Reboot..."
echo "						Reboot..."
echo ""
shutdown -r now
o1
if [ -z "$v" ]; then
break
fi
done
;;

2)
clear
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Exit..."
exit
sleep
clear
break
;;
*)
clear		
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------"
echo "Invalid Option!"
sleep 1
echo ""
;;
esac
done
