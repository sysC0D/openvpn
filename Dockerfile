FROM debian:latest
MAINTAINER 6c0d

#Var OpenVPN
ENV AUTHPAM no
ENV USEROVPN s6c0d
ENV PWDOVPN WTF!!addpwd

#Install Openvpn
RUN apt-get update && apt-get install -y \
	openvpn \
	dnsutils \
	makepasswd \
	expect \
	net-tools \
	iptables \
	git \
	nano \
	#&& apt-get clean \
        && rm -rf /tmp/* /var/tmp/*  \
        && rm -rf /var/lib/apt/lists/*

#Add conf VPN
COPY src/conf_ovpn/server_ovpn.conf /etc/openvpn/

#Add easyrsa3
RUN cd /etc/openvpn && git clone https://github.com/OpenVPN/easy-rsa.git

#Add script
RUN mkdir /var/tools \
	&& mkdir /etc/openvpn/clients
COPY src/scripts/genere_user_ovpn.sh /var/tools
RUN chmod 755 /var/tools/genere_user_ovpn.sh
