# Nginx VirtualHost script
This page is about simply bash script to create a new nginx v-host instance.<br>
Default all domains have a ".local" extenstion, but you can change it.

## How to use? - simply!
1. Add a executable privileges `chmod +x cvhost.sh`
2. Run script with sudo, like this:
`sudo ./cvhost.sh <action> <name>`
3. Done

###### Obviously `<name>` is your vhost name. ######
###### Posibble `<action>` is `add`, `rem`, `list`(up ver 3.0) ######

## Warning
Default php version is **PHP 7.2-FPM** if you use other. You should change it!<br>
Additional at the top you can edit a paths in cvhost.sh file.

If you want delete a vhost with custom domain extension, you must edit the file manually!  
Open script in your favourite editor, go to **168** line and change it.

## Screenshot
![sample.png](https://github.com/r0v/Nginx-vHost/blob/master/sample.png)

## Todo:
- [X] Own domain extension
- [ ] Use sed replace echo in hosts file
- [X] Remove v-host
- [ ] Edit v-host
- [ ] View exists site list
- [ ] Maybe Apache support
