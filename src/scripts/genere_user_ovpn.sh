#!/bin/bash
#Auto-Genere user openvpn

echo "Welcome to Auto-Genere user-OpenVPN..."
echo ""

#Get public IP
publicIP=`dig +short myip.opendns.com @resolver1.opendns.com`
echo "Your public IP is : $publicIP"

#Add user ovpn if no exist
usropenvpn=`grep openvpn /etc/passwd`
if [ -z "$usropenvpn" ]; then
        adduser --no-create-home --uid 1001 --disabled-password --gecos GECOS openvpn
fi

echo ""
echo "1 -> Verify if old conf exist"
cd /etc/openvpn
if [ -d "serverside" ]; then
	rm -rf easy-rsa clientside serverside clients
	git clone https://github.com/OpenVPN/easy-rsa.git
fi

echo ""
echo "1.1 -> Init conf var"
cd /etc/openvpn/easy-rsa/easyrsa3
cp vars.example vars
echo "set_var EASYRSA_REQ_COUNTRY    \"US\"" >> vars
echo "set_var EASYRSA_REQ_PROVINCE   \"California\"" >> vars
echo "set_var EASYRSA_REQ_CITY       \"San Francisco\"" >> vars
echo "set_var EASYRSA_REQ_ORG        \"6c0d\"" >> vars
echo "set_var EASYRSA_REQ_EMAIL      \"me@6c0d.co\"" >> vars
echo "set_var EASYRSA_REQ_OU         \"Nothing\"" >> vars

echo ""
echo "1.2 -> Init tree"
cd /etc/openvpn
mkdir clientside
mkdir serverside
cp -Rf easy-rsa/easyrsa3 clientside/
cp -Rf easy-rsa/easyrsa3 serverside/

echo ""
echo "1.3 -> Define servername"
nameserver="server_an0nym0us"

echo ""
echo "2 -> Genere CA"
cd /etc/openvpn/serverside/easyrsa3
./easyrsa init-pki
pwdca=`makepasswd --chars=20`
/usr/bin/expect<<EOF
exp_internal 1
set timeout -1
eval spawn "./easyrsa build-ca"
expect "Enter New CA Key Passphrase:" { send "$pwdca\r" }
expect "Confirm New CA Key Passphrase:" { send "$pwdca\r" }
expect "Common Name (eg: your user, host, or server name)" { send "an0nVPN\r" }
expect "Your new CA certificate file for publishing is at"
EOF

echo ""
echo "2.2 -> Genere .crt server"
cd /etc/openvpn/serverside/easyrsa3
/usr/bin/expect<<EOF
set timeout -1
eval spawn "./easyrsa gen-req $nameserver nopass"
expect "Common Name (eg: your user, host, or server name)" { send "$nameserver\r" }
expect "key: /etc/openvpn/clientside/easyrsa3/pki/private"
EOF

echo ""
echo "2.3 -> Sign req server"
/usr/bin/expect<<EOF
set timeout -1
eval spawn "./easyrsa sign-req server $nameserver"
expect "Confirm request details:" {send "yes\r"}
expect "Enter pass phrase for /etc/openvpn/serverside/easyrsa3/pki/private/ca.key:" {send "$pwdca\r"}
expect "Certificate created at:"
EOF

echo ""
echo "2.4 -> Build DH"
./easyrsa gen-dh
openvpn --genkey --secret ta.key

echo ""
echo "3.1 -> Verify User"
if [ -z "$USEROVPN" ]; then
	echo "Username will be default user : an0nym0us"
	nameuser="an0nym0us"
else
	nameuser=$USEROVPN
fi

echo ""
echo "3.2 -> Genere $nameuser.key"
cd /etc/openvpn/clientside/easyrsa3
./easyrsa init-pki
/usr/bin/expect<<EOF
set timeout -1
eval spawn "./easyrsa gen-req $nameuser nopass"
expect "Common Name (eg: your user, host, or server name)" { send "$nameuser.key\r" }
expect "key: /etc/openvpn/clientside/easyrsa3/pki/private"
EOF

echo ""
echo "3.3 -> Genere $nameuser.crt"
cd /etc/openvpn/serverside/easyrsa3
./easyrsa import-req /etc/openvpn/clientside/easyrsa3/pki/reqs/$nameuser.req $nameuser

echo ""
echo "3.4 -> Sign req client"
/usr/bin/expect<<EOF
set timeout -1
eval spawn "./easyrsa sign-req client $nameuser"
expect "Confirm request details:" {send "yes\r"}
expect "Enter pass phrase for /etc/openvpn/serverside/easyrsa3/pki/private/ca.key:" {send "$pwdca\r"}
expect "Certificate created at:"
EOF

echo ""
echo "4 -> Prepare conf VPN for client"
mkdir -p /etc/openvpn/clients/$nameuser
cd /etc/openvpn/clients/$nameuser
cat >client.ovpn<<EOL
client
dev tun
proto udp
remote $publicIP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert $nameuser.crt
key $nameuser.key
tls-auth ta.key 1
key-direction 1
cipher AES-256-GCM
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
compress lz4-v2
allow-compression yes
verb 3
EOL

echo ""
echo "5 -> Create tar file for client"
cd /etc/openvpn/clients/$nameuser
cp /etc/openvpn/serverside/easyrsa3/pki/issued/$nameuser.crt .
cp /etc/openvpn/serverside/easyrsa3/pki/ca.crt .
cp /etc/openvpn/clientside/easyrsa3/pki/private/$nameuser.key .
cp /etc/openvpn/serverside/easyrsa3/ta.key .
cd /etc/openvpn/clients/
tar -cvf $nameuser.tar $nameuser

echo ""
echo "6 -> Prepare conf server"
cd /etc/openvpn/
cp /etc/openvpn/serverside/easyrsa3/pki/issued/$nameserver.crt server.crt
cp /etc/openvpn/serverside/easyrsa3/pki/ca.crt .
cp /etc/openvpn/serverside/easyrsa3/pki/private/$nameserver.key server.key
cp /etc/openvpn/serverside/easyrsa3/pki/dh.pem dh2048.pem
cp /etc/openvpn/serverside/easyrsa3/ta.key .

echo ""
echo "7 -> Add iptables"
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

echo ""
echo "End script"
