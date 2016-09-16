#Docker-OPENVPN
##Beta version
This container run an OpenVPN server, it provide client conf for all plateform.
You can get client configuration in share-volume (define in next example).
So for use this Docker, juste launch Docker and install conf client on your client hardware.

For build Docker after get git clone:
docker build -t ovpn:latest   

For running the container:
docker run -d -v /root/client:/etc/openvpn/clients -p 1194:1194/udp --privileged --cap-add=NET_ADMIN --name openvpn-server ovpn:latest

