#!/bin/sh

# Generate conf OpenVPN
/var/tools/genere_user_ovpn.sh

# Start Openvpn
exec cd /etc/openvpn && openvpn --config server_ovpn.conf
exec "$@"
