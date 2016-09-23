FROM debian:latest
MAINTAINER sysC0D

#Var OpenVPN
ENV USEROVPN s6c0d

#Install Openvpn
RUN apt-get update && apt-get install -y \
	openvpn \
	dnsutils \
	makepasswd \
	expect \
	net-tools \
	iptables \
	git \
	&& apt-get clean \
        && rm -rf /tmp/* /var/tmp/*  \
        && rm -rf /var/lib/apt/lists/*

#Add conf VPN
COPY src/conf_ovpn/server_ovpn.conf /etc/openvpn/

#Add easyrsa3
RUN cd /etc/openvpn && git clone https://github.com/OpenVPN/easy-rsa.git

#Create Dir
RUN mkdir /var/tools \
	&& mkdir /etc/openvpn/clients

#Add script
COPY src/scripts/genere_user_ovpn.sh /var/tools
RUN chmod 755 /var/tools/genere_user_ovpn.sh

#Auto launch
COPY src/scripts/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
