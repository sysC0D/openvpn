# Docker-OPENVPN
This container run an OpenVPN server, it provides client configuration for all plateforms.  
You can get client configuration in shared volume, this configuration will be generated in path : /etc/openvpn/client  
For get this Docker, just launch docker pull command.  
During first run, this docker will generate server and client configuration (please waiting few minutes during this process).  
When this process will be finish, you could find client configuration in shared volume.  

If you want update your client and server configuration, just remove *.tar in shared volume and run a new docker (after deleted old). 

## Quick start
* For running the container :
```bash
docker run -d -v /your/path/:/etc/openvpn/clients -p 1194:1194/udp --privileged --cap-add=NET_ADMIN --name openvpn-server sysc0d/openvpn
```

## Client configuration
Download generated conf client (in shared volume) on your client machine.
Only for Linux user, add theses lines :
```bash
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```
Add conf in directory OpenVPN and launch connction :-)




