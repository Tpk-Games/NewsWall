# VirtualHost script
This page is about simply bash script to create a new nginx/apache v-host instance.<br>

## How to use? - simply!
1. Add a executable privileges `chmod +x nvhost.sh`
2. Run script with sudo, like this:
`sudo ./nvhost.sh <action> <name>`
3. Done

|Action `<action>`|Description|
|-|-|
|add|Add new v-host instance|
|rem|Remove exist v-host instance|

###### Obviously `<name>` is your vhost name -> full domain. ######

## Warning
Default php version is **PHP 7.2-FPM** if you use other. You should change it!<br>
Additional at the top you can edit a paths in major file.

## Screenshot
![sample.png](https://github.com/r0v/Nginx-vHost/blob/master/sample.png)

## Todo:
- [X] Own domain extension
- [X] Use sed replace echo in hosts file
- [X] Remove v-host
- [ ] Edit v-host
- [ ] View exists site list
- [ ] Maybe Apache support
