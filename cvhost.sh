#!/bin/bash

#===================
#  AUTOR: r0v
#  DESCRIPTION: Simple nginx v-host add script
#===================

# Variables
directoryRoot=/var/www/html/
siteAvaliable=/etc/nginx/sites-available/
siteEnabled=/etc/nginx/sites-enabled/
logPath=/var/log/vhost/

function flash(){

    RED="\e[0;31m"
    GREEN="\e[0;32m"
    YELLOW="\e[0;33m"
    BLUE="\e[0;34m"
    NC="\e[0m"

    if [ $# -lt 1 ]; then
        echo -e "${BLUE}Usage: ${GREEN}$0 ${BLUE}must be minimum one args:$NC ${RED}message$NC"
        exit 1
    elif [ $# -eq 1 ]; then
        echo -e "[${GREEN}√${NC}] - ${YELLOW}$1${NC}"
    elif [ $# -eq 2 ]; then
        case "$1" in
            -w)
                echo -e "${YELLOW}$2${NC}"
            ;;
            -d)
                echo -e "${RED}$2${NC}"
            ;;
            -i)
                echo -e "${BLUE}$2${NC}"
            ;;
            -o)
                echo -e "${GREEN}$2${NC}"
            ;;
        esac
    else
        echo -e "${RED}Something went wrong!${NC} ${BLUE}Too much args.${NC}"
    fi
}

if [ $# -eq 0 ]; then

    echo "Usage: <vhost-name>"

elif [ $# -eq 1 ]; then

    # Starting script
    clear

    currentData=$(date +"%F")

    echo -ne "Work in progress"
    for i in {1..3} 
    do 
        sleep 0.2
        echo -n "."
    done
    echo -n "log was writing in ${logPath}log_${currentData}.log"
    echo ""

    # Create a root directory
    cd $directoryRoot;
    directoryName=$(echo $1 | tr [:upper:] [:lower:])
    if [ -d "$directoryName.local" ]; then
        flash -w "Warning, a file with that name exists, in $directoryRoot"
    else
        mkdir "$directoryName.local"
        flash "Create a root directory."
    fi

    # Create a configuration file
    cd /etc/nginx/sites-available/

    confName=$directoryName

    if [ -e $siteAvaliable$directoryName ]; then
        flash -d "Error! Configuration file is exists."
    else
        echo "server {
                listen 80;
                listen [::]:80;

                # Error, access ecetra
                error_log /var/log/nginx/$confName.error error;
                access_log /var/log/nginx/$confName.access;

                root /var/www/html/$confName.local;

                # Add PHP support
                index index.php index.html index.htm index.nginx.debian.html;

                server_name $confName.local www.$confName.local;

                location / {
                    try_files \$uri \$uri/ =404;
                }

                # PHP Config
                location ~ \.php$ {
                    include snippets/fastcgi-php.conf;
                    fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
                }
            }" > $siteAvaliable$directoryName
        flash "Create a configuration file"
    fi

    # Edit hosts file
    sudo echo "127.0.0.1    localhost.localdomain $confName.local www.$confName.local" >> /etc/hosts # TODO: change on sed
    flash "Edit hosts file"

    # Add symlink
    if [ -h $siteEnabled$confName ]; then
        flash -w "Sorry, I can't add a symlink which exists!"
    else
        sudo ln -s $siteAvaliable$confName $siteEnabled$confName
        flash "Add symlink correct"
    fi

    # Create sample file & other stuff
    if [ ! -d $logPath ]; then
        sudo mkdir $logPath
    fi

    if [ -d "$directoryRoot$directoryName.local" ]; then
        echo "<?php
                phpinfo();
            ?>" > $directoryRoot$directoryName.local/index.php
    fi
    flash "Create a sample PHP file"

    # Reload ngnix
    sudo service nginx restart |& tee -a "${logPath}log_${currentData}.log" &> /dev/null
    flash "Reload nginx server"

    flash -o "Nice work! Your v-host is now active, you can looking this at the http://$confName.local/"

else

    flash -d "Something went wrong! Please try again, remember about params..."

fi