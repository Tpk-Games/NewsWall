#!/bin/bash

#===================
#  AUTOR: r0v
#  DESCRIPTION: Simple nginx v-host add/remove script
#===================

# Global variables
currentData=$(date +"%F")

_directoryRoot=/var/www/html/
_siteAvaliable=/etc/nginx/sites-available/
_siteEnabled=/etc/nginx/sites-enabled/
_logPath=/var/log/vhost/
_defaultExt="local"
_defaultName="example"

function flashMessage(){

    RED="\e[0;31m"
    GREEN="\e[0;32m"
    YELLOW="\e[0;33m"
    CYAN="\e[0;36m"
    NC="\e[0m"

    if [ $# -lt 1 ]; then
        echo -e "${CYAN}Usage: ${GREEN}$0 ${CYAN}must be minimum one args:$NC ${RED}message$NC"
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
                echo -e "${CYAN}$2${NC}"
            ;;
            -o)
                echo -e "${GREEN}$2${NC}"
            ;;
        esac
    else
        echo -e "${RED}Something went wrong!${NC} ${CYAN}Too much args.${NC}"
    fi
}

function vaildDomain(){

    if [[ $1 =~ \. ]]; then

        local domain=$(echo ${1%%.*} | tr '[:upper:]' '[:lower:]')
        local tld=$(echo ${1##*.} | tr '[:upper:]' '[:lower:]')

        [[ -z $domain ]] && echo -n $_defaultName || echo -n $domain
        echo -n "."
        [[ -z $tld ]] && echo -n $_defaultExt || echo -n $tld

    else
        flashMessage -d "Bye, bye..." 
        exit 1
    fi
}

function bootUp(){
    reset

    echo -ne "Work in progress"
    for i in {1..3} 
    do 
        sleep 0.2
        echo -n "."
    done

    if [ ! -d $_logPath ]; then
        sudo mkdir $_logPath
    fi

    echo -n "log was writing in ${_logPath}log_${currentData}.log" 
    echo ""

    ## PHP installed checker.
}

function addOption(){
            
    # Init message
    bootUp

    # Start script
    domainName=$(vaildDomain $2)

    # Create a root directory
    cd $_directoryRoot;
    if [ -d "$domainName" ]; then
        flashMessage -w "Warning, a file with that name exists, in $_directoryRoot"
    else
        mkdir "$domainName"
        flashMessage "Create a root directory."
    fi

    # Create a configuration file
    cd $_siteAvaliable

    if [ -e $_siteAvaliable$domainName ]; then
        flashMessage -d "Error! Configuration file is exists."
        exit 1
    else
        sudo echo "server {
        listen 80;
        listen [::]:80;

        # Error, access ecetra
        error_log /var/log/nginx/$domainName.error error;
        access_log /var/log/nginx/$domainName.access;

        root /var/www/html/$domainName;

        # Add PHP support
        index index.php index.html index.htm index.nginx.debian.html;

        server_name $domainName www.$domainName;

        location / {
            try_files \$uri \$uri/ =404;
        }

        # PHP Config
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
}" > $_siteAvaliable$domainName
        flashMessage "Create a configuration file"
    fi

    # Edit hosts file
    replace="127.0.0.1	localhost.localdomain $domainName www.$domainName"
    sed -i -r "s/127.0.1.1.+/&\n${replace}/g" /etc/hosts
    flashMessage "Edit hosts file"

    # Add symlink
    if [ -h $_siteEnabled$domainName ]; then
        flashMessage -w "Sorry, I can't add a symlink which exists!"
    else
        sudo ln -s $_siteAvaliable$domainName $_siteEnabled$domainName
        flashMessage "Add symlink correct"
    fi

    # Create sample file
    if [ ! -f "$_directoryRoot$domainName/index.php" ]; then
        echo "<?php
            phpinfo();
        ?>" > "$_directoryRoot$domainName/index.php"
        flashMessage "Create a sample PHP file"
    else
        flashMessage -d "Example page file exits!"
    fi

    # Reload ngnix
    sudo service nginx restart |& tee -a "${_logPath}log_${currentData}.log" &> /dev/null
    flashMessage "Reload nginx server"

    # End
    flashMessage -o "Nice work! Your v-host is now active, you can looking this at the http://$domainName/"

}

function remOption {
            
            domainName=$(vaildDomain $2)

            if [ $domainName = "example.local" ]; then
                
                exit 1
                
            else

                cd $_directoryRoot

                if [ -d "$domainName" ]; then
                    echo -n "Are you sure? Delete $domainName? (Yes/No) "
                    read bar
                    if [[ "$bar" =~ [yY] || [yY][eE][sS] ]]; then

                        # Remove a root directory
                        sudo rm -r $domainName
                        flashMessage "Remove a root directory"

                        # Remove a configuration file
                        cd $_siteAvaliable
                        if [ -f "$domainName" ]; then 
                            sudo rm $domainName
                            flashMessage "Remove a configuration file"
                        else
                            flashMessage -d "Error! Config file was not removed."
                        fi

                        # Edit hosts file - NOT WORKING!
                        ##sudo sed -i "/127.0.0.1 .+ localhost.localdomain $domainName www.$domainName/gd" /etc/hosts
                        flashMessage "Edit hosts file"

                        # Remove symlink
                        cd $_siteEnabled
                        if [ -h "$domainName" ]; then 
                            sudo rm $domainName
                            flashMessage "Remove symlink"
                        else
                            flashMessage -d "Error! Symlink was not removed."
                        fi

                        # Reload ngnix
                        sudo service nginx restart |& tee -a "${_logPath}log_${currentData}.log" &> /dev/null
                        flashMessage "Reload nginx server"

                        flashMessage -i "Sucessfull, Now you haven't $domainName vhost!"

                    else
                        flashMessage -d "You don't agree on delete, sory ..."
                    fi
                fi

            fi
}

# Basic script
if [ $# -le 1 ]; then
    
    # Less then or equal 1 params
    flashMessage -i "Usage: <action> <vhost-name>"

elif [ $# -eq 2 ]; then

    case "$1" in 
        "add") addOption $@ ;;
        "rem") remOption $@ ;;
        *) flashMessage -d "Something went wrong! Please try again, remember about params..." ;;
    esac

fi