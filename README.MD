#Docker-OPENVPN
##Beta version
This container run an OpenVPN server, it provide client conf for all plateform.

For running the container:
docker run -it -v /root/client:/etc/openvpn/clients -p 1194:1194/udp --privileged --cap-add=NET_ADMIN --name openvpn-server image:version

