# Nginx VirtualHost script
This page is about simply bash script to create a new nginx v-host instance.<br>

## How to use? - simply!
1. Add a executable privileges `chmod +x cvhost.sh`
2. Run script with sudo, like this:
`sudo ./cvhost.sh <action> <name>`
3. Done

###### Obviously `<name>` is your vhost name. ######
###### Posibble `<action>` is `add`, `rem` ######

## Warning
Default php version is **PHP 7.2-FPM** if you use other. You should change it!<br>
Additional at the top you can edit a paths in cvhost.sh file.

## Screenshot
![sample.png](https://github.com/r0v/Nginx-vHost/blob/master/sample.png)

## Todo:
- [X] Own domain extension
- [X] Use sed replace echo in hosts file
- [X] Remove v-host
- [ ] Edit v-host
- [ ] View exists site list
- [ ] Maybe Apache support

## Bug:
- Remove entry from hosts file