# Docker-OPENVPN
This container run an OpenVPN server, it provides client configuration for all plateforms.  
You can get client configuration in shared volume, this configuration will be generated in path : /etc/openvpn/client  
For get this Docker, just launch docker pull command.  
During first run, this docker will generate server and client configuration (please waiting few minutes during this process).  
When this process will be finish, you could find client configuration in shared volume.  

## Quick start
* For running the container:
	docker run -d -v /your/path/:/etc/openvpn/clients -p 1194:1194/udp --privileged --cap-add=NET_ADMIN --name openvpn-server sysc0d/openvpn





