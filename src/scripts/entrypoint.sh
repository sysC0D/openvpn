#!/bin/sh

# Generate conf OpenVPN
if [ ! -f /etc/openvpn/clients/*.tar ]; then
	/var/tools/genere_user_ovpn.sh
else
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
fi

# Start Supervisord
/usr/bin/supervisord
