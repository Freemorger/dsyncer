## Tool to send data over local network simply   
Made just for D language probe and basic cases usage  
Why dsyncer instead of ssh scp? Ssh requires auth and dsync may be faster..
but i'm not saying scp is any worse. This project is made for fun anyways.
## Build
`dub build` - debug   
`dub build -b release` - release   
## Run
Run server: `./dsyncer -serv PORT`   
Connect to server: `./dsyncer -con IP PORT`   
After connecting normally, you gotta write some commands. Lookup `!help` in 
game   
If you want to send some files and close connection, connect like this:
`./dsyncer -con IP PORT -f FILES`   
## Potential issue with Windows 
Windows are using other path separator so there may be problems with it.  
Since I made this project for fun and learning D, I personally don't really 
need ~~microslop~~ windows OS to be available as of yet 

