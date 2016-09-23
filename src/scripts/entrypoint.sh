#!/bin/sh

# Generate conf OpenVPN
if [ ! -f /etc/openvpn/clients/*.tar ]; then
	/var/tools/genere_user_ovpn.sh
fi

# Start Openvpn
cd /etc/openvpn 
openvpn --config server_ovpn.conf
