#!/bin/sh

# Generate conf OpenVPN
/var/tools/genere_user_ovpn.sh

# Start Openvpn
cd /etc/openvpn && openvpn --config server_ovpn.conf 
