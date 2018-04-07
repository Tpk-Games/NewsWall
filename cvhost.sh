#!/bin/bash

#===================
#  AUTOR: r0v
#  DESCRIPTION: Simple nginx v-host add/remove script
#===================

# Variables
directoryRoot=/var/www/html/
siteAvaliable=/etc/nginx/sites-available/
siteEnabled=/etc/nginx/sites-enabled/
logPath=/var/log/vhost/
domainExt="local"
domainName="example"

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

function boot(){
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
}

if [ $# -le 1 ]; then
    
    # Less then or equal 1 params
    flash -i "Usage: <action> <vhost-name>"

elif [ $# -eq 2 ]; then
    case "$1" in 
        "add")
            # Init message
            boot

            # Start script

            if [[ $2 =~ \. ]]; then
                domainName=$(echo $2 | sed 's/\.[a-z.]*//')
                domainExt=$(echo $2 | sed 's/[a-z.]*\.//')
            else
                domainName=$(echo $2 | tr -d ./ )
            fi

            # Create a root directory
            cd $directoryRoot;
            directoryName=$(echo "$domainName.$domainExt" | tr [:upper:] [:lower:])
            if [ -d "$directoryName" ]; then
                flash -w "Warning, a file with that name exists, in $directoryRoot"
            else
                mkdir "$directoryName"
                flash "Create a root directory."
            fi

            confName=$directoryName

            # Create a configuration file
            cd $siteAvaliable

            if [ -e $siteAvaliable$confName ]; then
                flash -d "Error! Configuration file is exists."
            else
                echo "server {
        listen 80;
        listen [::]:80;

        # Error, access ecetra
        error_log /var/log/nginx/$confName.error error;
        access_log /var/log/nginx/$confName.access;

        root /var/www/html/$confName;

        # Add PHP support
        index index.php index.html index.htm index.nginx.debian.html;

        server_name $confName www.$confName;

        location / {
            try_files \$uri \$uri/ =404;
        }

        # PHP Config
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
}" > $siteAvaliable$confName
                flash "Create a configuration file"
            fi

            # Edit hosts file
            sudo echo "127.0.0.1    localhost.localdomain $confName www.$confName" >> /etc/hosts # TODO: change on sed
            flash "Edit hosts file"

            # Add symlink
            if [ -h $siteEnabled$directoryName ]; then
                flash -w "Sorry, I can't add a symlink which exists!"
            else
                sudo ln -s $siteAvaliable$directoryName $siteEnabled$directoryName
                flash "Add symlink correct"
            fi

            # Create sample file & other stuff
            if [ ! -d $logPath ]; then
                sudo mkdir $logPath
            fi

            if [ ! -f "$directoryRoot$directoryName/index.php" ]; then
                echo "<?php
                        phpinfo();
                    ?>" > "$directoryRoot$directoryName/index.php"
                flash "Create a sample PHP file"
            else
                flash -d "Example page file exits!"
            fi

            # Add from list pages
            ### NEW FEATURE v3.0 ###

            # Reload ngnix
            sudo service nginx restart |& tee -a "${logPath}log_${currentData}.log" &> /dev/null
            flash "Reload nginx server"

            flash -o "Nice work! Your v-host is now active, you can looking this at the http://$confName/"

        ;;
        "rem")

            remName="$2.mira"

            cd $directoryRoot
            if [ -d "$remName" ]; then
                echo -n "Are you sure? Delete $remName? (Yes/No) "
                read tester
                if [[ "$tester" =~ [yY] || [yY][eE][sS] ]]; then

                    # Remove a root directory
                    sudo rm -r $remName
                    flash "Remove a root directory"

                    # Remove a configuration file
                    cd $siteAvaliable
                    if [ -f "$remName" ]; then 
                        sudo rm $remName
                        flash "Remove a configuration file"
                    else
                        flash -d "Error! Config file was not removed."
                    fi

                    # Edit hosts file
                    sudo sed -i "/127.0.0.1    localhost.localdomain $remName www.$remName/d" /etc/hosts # TODO // security 
                    flash "Edit hosts file"

                    # Remove symlink
                    cd $siteEnabled
                    if [ -h "$remName" ]; then 
                        sudo rm $remName
                        flash "Remove symlink"
                    else
                        flash -d "Error! Symlink was not removed."
                    fi

                    # Remove from pages list
                    ### NEW FEATURE v3.0 ###

                    # Reload ngnix
                    sudo service nginx restart |& tee -a "${logPath}log_${currentData}.log" &> /dev/null
                    flash "Reload nginx server"

                    flash -i "Sucessfull, Now you haven't $remName vhost!"

                else
                    flash -d "You don't agree on delete, sory ..."
                fi
            fi

        ;;
        "list")
            # LISTA VHOSTOW
            ### NEW FEATURE v3.0 ###
            exit 1;
        ;;
        *)
            flash -d "Something went wrong! Please try again, remember about params..."
    esac
fi