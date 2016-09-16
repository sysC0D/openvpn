#Docker-OPENVPN
##Beta version
This container run an OpenVPN server, it provide client conf for all plateform.

For running the container:

Docker without PAM
docker run -it -v /root/client:/etc/openvpn/clients -p 1194:1194/udp --privileged --name openvpn-server ovpn:v0.4


