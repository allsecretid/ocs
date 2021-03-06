#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

 red='\e[1;31m'
               green='\e[0;32m'
               NC='\e[0m'
			   
               echo "Connecting to rasta-server.net..."
               sleep 1
               
			   echo "Checking Permision..."
               sleep 1
               
			   echo -e "${green}Permission Accepted...${NC}"
               sleep 1
			   
flag=0

if [ $USER != 'root' ]; then
	echo "Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "Anda tidak menjalankan script ini pada OS Debian"
	exit
fi

vps="VPS";

if [[ $vps = "VPS" ]]; then
	source="https://raw.githubusercontent.com/yusuf-ardiansyah/new"
else
	source="https://raw.githubusercontent.com/yusuf-ardiansyah/new"
fi

# go to root
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);

flag=0
	
#iplist="ip.txt"

wget --quiet -O iplist.txt https://raw.githubusercontent.com/allsecretid/ocs/main/ip.txt

#if [ -f iplist ]
#then

iplist="iplist.txt"

lines=`cat $iplist`
#echo $lines

for line in $lines; do
#        echo "$line"
        if [ "$line" = "$myip" ];
        then
                flag=1
        fi

done

if [ $flag -eq 0 ]
then
   echo  "Maaf, hanya IP @ Password yang terdaftar sahaja boleh menggunakan script ini!
Hubungi: ABE PANG (+0169872312) Telegram : @myvpn007"

rm -f /root/iplist.txt

rm -f /root/Rasta-OCS.sh
	
	exit 1
fi

clear
echo "--------------------------------- OCS Panels Installer for Debian -------------------------------"

echo "                    DEVELOPED BY ABE PANG / (+60169872312)                    "
echo ""
echo ""
echo "Saya perlu mengajukan beberapa pertanyaan sebelum memulai setup"
echo "Anda dapat membiarkan pilihan default dan hanya tekan enter jika Anda setuju dengan pilihan tersebut"
echo ""
echo "Pertama saya perlu tahu password baru user root MySQL:"
read -p "Password baru: " -e -i abc12345 DatabasePass
echo ""
echo "Terakhir, sebutkan Nama Database untuk OCS Panels"
echo "Tolong, gunakan satu kata saja, tidak ada karakter khusus selain Underscore (_)"
read -p "Nama Database: " -e -i OCS_PANEL DatabaseName
echo ""
echo "Ok, itu semua saya butuhkan. Kami siap untuk setup OCS Panels Anda sekarang"
read -n1 -r -p "Tekan sembarang tombol untuk melanjutkan..."

apt-get remove --purge mysql\*
dpkg -l | grep -i mysql
apt-get clean

apt-get install -y libmysqlclient-dev mysql-client

service nginx stop
service php5-fpm stop
service php5-cli stop

apt-get -y --purge remove nginx php5-fpm php5-cli

#apt-get update
apt-get update -y

apt-get install build-essential expect -y

apt-get install -y mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

apt-get install -y nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt


# Install Web Server
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/allsecretid/ocs/main/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/allsecretid/ocs/main/vps.conf"
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf

mkdir -p /home/vps/public_html

useradd -m vps

mkdir -p /home/vps/public_html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

service php5-fpm restart
service nginx restart

apt-get -y install zip unzip

cd /home/vps/public_html

wget https://github.com/allsecretid/ocs/raw/main/panelocs.zip

mv panelocs.zip LTEOCS.zip

unzip LTEOCS.zip

rm -f LTEOCS.zip

rm -f index.html

chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

chmod 777 /home/vps/public_html/config
chmod 777 /home/vps/public_html/config/inc.php
chmod 777 /home/vps/public_html/config/route.php

clear
echo ""
echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
echo ""
echo "Buka Browser, akses alamat http://$MYIP:81/ dan lengkapi data2 seperti dibawah ini!"
echo "Database:"
echo "- Database Host: localhost"
echo "- Database Name: $DatabaseName"
echo "- Database User: root"
echo "- Database Pass: $DatabasePass"
echo ""
echo "Admin Login:"
echo "- Username: sesuai keinginan"
echo "- Password Baru: sesuai keinginan"
echo "- Masukkan Ulang Password Baru: sesuai keinginan"
echo ""
echo "Klik Install dan tunggu proses selesai, lalu tutup Browser dan kembali lagi ke sini (Putty) dan kemudian tekan tombol [ENTER]!"

sleep 3
echo ""
read -p "Jika Step diatas sudah dilakukan, silahkan Tekan tombol [Enter] untuk melanjutkan..."
echo ""
read -p "Jika anda benar-benar yakin Step diatas sudah dilakukan, silahkan Tekan tombol [Enter] untuk melanjutkan..."
echo ""

cd /root

apt-get update

service webmin restart

apt-get -y --force-yes -f install libxml-parser-perl

echo "unset HISTFILE" >> /etc/profile

chmod 755 /home/vps/public_html/config
chmod 644 /home/vps/public_html/config/inc.php
chmod 644 /home/vps/public_html/config/route.php

# info
clear
echo "=======================================================" | tee -a log-install.txt
echo "Silahkan login OCS Panels di http://$MYIP:81/" | tee -a log-install.txt

echo "" | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt" | tee -a log-install.txt
#echo "" | tee -a log-install.txt
#echo "SILAHKAN REBOOT VPS ANDA !" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
rm -f /root/Rasta-OCS.sh
cd ~/