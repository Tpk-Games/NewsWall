# Nginx VirtualHost script
This page is about simply bash script to create a new nginx v-host instance.<br>
Default all domains have a ".local" extenstion.

## How to use? - simply!
1. Add a executable privileges `chmod +x cvhost.sh`
2. Run script with sudo, like this:
`sudo ./cvhost.sh <name>`
3. Done

###### Obviously `<name>` is your vhost name. ######

## Note
Warning! Default php version is **PHP 7.2-FPM** if you use other. You should change it!<br>
Additional at the top you can edit a paths in cvhost.sh file.

## Todo:
- Own domain extension
- Use sed replace echo in hosts file
- Remove v-host
- Edit v-host
- Maybe Apache support
