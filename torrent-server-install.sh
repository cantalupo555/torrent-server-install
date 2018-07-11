#!/bin/bash
# cantalupo555
#https://rakudave.ch/category/jsvnstat/
#https://github.com/DASPRiD/vnstat-php

clear
# Ensure the OS is compatible with the launcher
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


# root?
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi

# User e Password
echo ""
echo "By: @cantalupo555"
echo ""
echo -e " \033[42;1;37mEnter the name for the user:\033[0m"
read user
echo ""
echo -e " \033[42;1;37mEnter the password for the user:\033[0m"
read pass

extern_ip="$(wget -qO- http://api.sentora.org/ip.txt)"
#local_ip=$(ifconfig eth0 | sed -En 's|.*inet [^0-9]*(([0-9]*\.){3}[0-9]*).*$|\1|p')
local_ip=$(ip addr show | awk '$1 == "inet" && $3 == "brd" { sub (/\/.*/,""); print $2 }')&&all='apt-get install'
    PUBLIC_IP=$extern_ip

# Dependencies
interface=$interface
sudo dpkg-reconfigure tzdata
graph_type=$graph_type
sudo apt-get autoremove -y
time_type=$time_type
sudo $all software-properties-common -y
tx_color=$tx_color
sudo $r ppa:qbittorrent-team/qbittorrent-stable -y
rx_color=$rx_color
sudo $r ppa:ondrej/apache2 ppa:ondrej/php -y
theme=$theme
sudo $r ppa:ondrej/php -y&&sudo apt-get update
precision=$precision
sudo $all proftpd apache2 curl php libapache2-mod-php php-mysql php-zip php-intl php-curl php-gd php-mbstring php-xml php-xmlrpc rtorrent qbittorrent qbittorrent-nox screen bmon htop make gcc libc6-dev unzip rar unrar mediainfo --allow-unauthenticated -y
date_format=$date_format
enabled_dropdowns=$enabled_dropdowns

# Config Web
sudo apache2ctl configtest
sudo ufw app list
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"
sudo a2enmod rewrite
graph_format=$graph_format
echo "" >> /etc/apache2/apache2.conf
echo "<Directory /var/www/html/>" >> /etc/apache2/apache2.conf
echo "AllowOverride All" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf
statusdir=/var/www/html/status
service apache2 restart

# Config rTorrent
cd ~/
wget http://80.211.146.153/rtorrent.rc
mv rtorrent.rc .rtorrent.rc
mkdir /home/rtorrent
mkdir /home/rtorrent/Downloads
mkdir /home/rtorrent/.session

# User
#sudo adduser downloads --home=/home/rtorrent/Downloads --shell=/bin/false
locale=$locale
sudo useradd -m $user --home=/home/rtorrent --shell=/bin/false
language=$language
iface_list=$iface_list
echo $user:$pass | chpasswd
iface_title=$iface_title
vnstat_bin=$vnstat_bin
chown $user:$user /home/rtorrent
data_dir=$data_dir
byte_notation=$byte_notation

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
rm -rf screenshots
cd ../..
sudo ln -s /home/rtorrent/Downloads downloads

# Password in directory
cd /var/www/html/rutorrent
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| sudo tee .htaccess
cd /home/rtorrent/Downloads
echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| sudo tee .htaccess
cd /home/rtorrent/
htpasswd -cb .htpasswd $user $pass

#vnStat
cd /usr/src&&wget http://humdi.net/vnstat/vnstat-1.18.tar.gz
tar zxvf vnstat-1.18.tar.gz
cd vnstat-1.18
./configure --prefix=/usr --sysconfdir=/etc&&make&&make install
cp -v examples/systemd/vnstat.service /etc/systemd/system/
systemctl enable vnstat
systemctl start vnstat
pgrep -c vnstatd
mkdir /var/www/html/status&&echo -e 'AuthType Basic\nAuthName cantalupo555\nAuthUserFile /home/rtorrent/.htpasswd\nRequire valid-user'| sudo tee /var/www/html/status/.htaccess
cd ~
wget  wget https://sourceforge.net/projects/jsvnstat/files/latest/download -O jsvnstat.zip
unzip jsvnstat.zip&&mv jsvnstat/ 1/&&mv 1/ /var/www/html/status/
echo -e "<?php
	$interface = 'eth0';	    /* Default interface to monitor (e.g. eth0 or wifi0), leave empty for first one */
	$graph_type = 'lines';	/* Default look of the graph (one of: lines, bars)*/
	$time_type = 'days';	/* Default time frame (one of: 'hours', 'days', 'months', 'top10') */
	$tx_color = '#00ff00';	/* TX graph color, default is #00ff00 */
	$rx_color = '#ff0000';	/* RX graph color, default is #ff0000 */
	$theme = 'default';     /* Default CSS theme to use (one of: 'default', 'nox') */
	$precision = 2;		    /* Number of decimal digits to display in table, default is 2 (e.g. 2 = 0.00, 3 = 0.000, etc...) */
	//date_default_timezone_set('Europe/Berlin'); // depending on your php settings you might want to explicitly set this to your TZ
	$date_format = array(   /* date formats shown in tables and sidebar, see php's date() for reference */
		'hours' => 'H:00',
		'days'  => 'D, d.m.Y',
		'months'=> 'M Y',
		'top10' => 'd.m.Y',
		'uptime'=> 'd.m.Y, H:i'
	);
	$enabled_dropdowns = array(
		'interface' => true,
		'theme' => true
	);
?>"| sudo tee $statusdir/1/settings.php
rm jsvnstat.zip
wget https://github.com/DASPRiD/vnstat-php/archive/master.zip -O vnStat-PHP.zip
unzip vnStat-PHP.zip&&mv vnstat-php-master/ 2/&&mv 2/ /var/www/html/status/
echo -e "<?php
return [
    'interfaces' => [
        // You can list any number of interfaces here. The top interface is the default one. When no interface is
        // defined (or this config file was not copied to "config.php"), the default interface is used.
        'eth0',
    ],
];"| sudo tee $statusdir/2/config.php
rm vnStat-PHP.zip
wget https://github.com/bjd/vnstat-php-frontend/archive/master.zip -O vnstat_php_frontend.zip
unzip vnstat_php_frontend.zip&&mv vnstat-php-frontend-master/ 3/&&mv 3/ /var/www/html/status/
echo -e "<?php
    //
    // vnStat PHP frontend (c)2006-2010 Bjorge Dijkstra (bjd@jooz.net)
    //
    // This program is free software; you can redistribute it and/or modify
    // it under the terms of the GNU General Public License as published by
    // the Free Software Foundation; either version 2 of the License, or
    // (at your option) any later version.
    //
    // This program is distributed in the hope that it will be useful,
    // but WITHOUT ANY WARRANTY; without even the implied warranty of
    // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    // GNU General Public License for more details.
    //
    // You should have received a copy of the GNU General Public License
    // along with this program; if not, write to the Free Software
    // Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    //
    //
    // see file COPYING or at http://www.gnu.org/licenses/gpl.html
    // for more information.
    //
    error_reporting(E_ALL | E_NOTICE);

    //
    // configuration parameters
    //
    // edit these to reflect your particular situation
    //
    $locale = 'en_US.UTF-8';
    $language = 'en';

    // Set local timezone
    // date_default_timezone_set("Europe/Amsterdam");

    // list of network interfaces monitored by vnStat
    $iface_list = array('eth0');

    //
    // optional names for interfaces
    // if there's no name set for an interface then the interface identifier
    // will be displayed instead
    //
    $iface_title['eth0'] = 'Internal';

    //
    // There are two possible sources for vnstat data. If the $vnstat_bin
    // variable is set then vnstat is called directly from the PHP script
    // to get the interface data.
    //
    // The other option is to periodically dump the vnstat interface data to
    // a file (e.g. by a cronjob). In that case the $vnstat_bin variable
    // must be cleared and set $data_dir to the location where the dumps
    // are stored. Dumps must be named 'vnstat_dump_$iface'.
    //
    // You can generate vnstat dumps with the command:
    //   vnstat --dumpdb -i $iface > /path/to/data_dir/vnstat_dump_$iface
    //
    $vnstat_bin = '/usr/bin/vnstat';
    $data_dir = './dumps';

    // graphics format to use: svg or png
    $graph_format='svg';

    // preferred byte notation. null auto chooses. otherwise use one of
    // 'TB','GB','MB','KB'
    $byte_notation = null;

    // Font to use for PNG graphs
    define('GRAPH_FONT',dirname(__FILE__).'/VeraBd.ttf');

    // Font to use for SVG graphs
    define('SVG_FONT', 'Verdana');

    // Default theme
    define('DEFAULT_COLORSCHEME', 'light');
    
    // SVG Depth scaling factor
    define('SVG_DEPTH_SCALING', 1);

?>"| sudo tee $statusdir/3/config.php
rm vnstat_php_frontend.zip
cd /var/www/
chown -R 33:33 html/

# Daemon
cd ~
echo -e "[Unit]\nDescription=qBittorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/qbittorrent-nox\nExecStop=/usr/bin/killall -w qbittorrent-nox\n\n[Install]\nWantedBy=multi-user.target"| sudo tee /etc/systemd/system/qbittorrent.service
echo -e "[Unit]\nDescription=rTorrent Daemon Service\nAfter=network.target\n\n[Service]\nUser=$user\nExecStart=/usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n#ExecStop=/usr/bin/screen -X -S rtorrent quit\n\n[Install]\n WantedBy=multi-user.target"| sudo tee /etc/systemd/system/rtorrent.service
sudo systemctl daemon-reload&&sudo systemctl enable qbittorrent&&sudo systemctl start qbittorrent&&sudo systemctl enable rtorrent&&sudo systemctl start rtorrent
echo -e '#! /bin/sh\n\n### BEGIN INIT INFO\n# Provides:           unitr\n# Required-Start:     $local_fs $remote_fs $network $syslog $netdaemons\n# Required-Stop:      $local_fs $remote_fs\n# Default-Start:      2 3 4 5\n# Default-Stop:       0 1 6\n# Short-Description:  Example of init service.\n# Description:\n#  Long description of my service.\n### END INIT INFO\n\n# Actions provided to make it LSB-compliant\ncase "$1" in\n  start)\n    echo "Starting unitr"\n    sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  stop)\n    echo "Stopping script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit\n    ;;\n  restart)\n    echo "Restarting script unitr"\n    sudo /usr/bin/screen -X -S rtorrent quit && sudo /usr/bin/screen -d -m -S rtorrent /usr/bin/rtorrent\n    ;;\n  force-reload)\n    echo "Reloading script unitr"\n    #Insert your reload routine here\n    ;;\n  status)\n    echo "Status of script unitr"\n    #Insert your stop routine here\n    ;;\n  *)\n    echo "Usage: /etc/init.d/unitr {start|stop|restart|force-reload|status}"\n    exit 1\n    ;;\nesac\n\nexit 0'| sudo tee /etc/init.d/unitr
sudo chmod +x /etc/init.d/unitr&&sudo chmod 777 /etc/init.d/unitr&&update-rc.d unitr defaults
clear
echo -e " \033[40;1;37mInstallation Complete\033[0m"&&echo "By: @cantalupo555"&&echo ""
echo -e "\e[1;33m############################################\e[0m"
echo -e " \033[40;1;37mruTorrent: http://$PUBLIC_IP/rutorrent\033[0m"
echo -e " \033[41;1;37mqBittorrent: http://$PUBLIC_IP:8080\033[0m"
echo -e " \033[40;1;37mqBittorrent User: admin Password: adminadmin\033[0m"
echo -e " \033[41;1;37mDownloads Web: http://$PUBLIC_IP/downloads\033[0m"
echo -e " \033[40;1;37mNetwork Status: http://$PUBLIC_IP/status\033[0m"
echo -e " \033[41;1;37mFTP >>> Host: $PUBLIC_IP Port: 21\033[0m"
echo -e " \033[40;1;37mUser: $user Password: $pass\033[0m"
echo -e "\e[1;33m############################################\e[0m"
echo ""
echo "		Reboot..."
echo "			Reboot..."
echo "				Reboot..."
echo "					Reboot..."
echo "						Reboot..."
echo ""
sudo shutdown -r now
