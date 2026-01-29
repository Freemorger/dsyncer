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
cli    
If you want to send some files and close connection, connect like this:
`./dsyncer -con IP PORT -f FILES`   
