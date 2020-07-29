FROM kylemanna/openvpn:2.1.0

# This docker file will be used for running the CA cert generation server.
#   We will want to add some of our own scripts to the bin directory specifically for avesha.  These will
#   simplify the cert generation
# This server will be built only for ubuntu
# For now this will just be the kylemanna 

# Copy Avesha Scripts initializing Ca,  generating multiple servers from from same CA cert.


# List instructions for using CA
COPY ./ca/scripts/avesha_ovpn_genconfig /usr/local/bin/avesha_ovpn_genconfig
COPY ./ca/scripts/avesha_ovpn_initpki /usr/local/bin/avesha_ovpn_initpki
COPY ./ca/scripts/avesha_ovpn_init_server /usr/local/bin/avesha_ovpn_init_server
COPY ./ca/scripts/avesha_ovpn_copy_server_files /usr/local/bin/avesha_ovpn_copy_server_files
COPY ./ca/scripts/avesha_ovpn_getclient /usr/local/bin/avesha_ovpn_getclient
COPY ./ca/scripts/avesha_ovpn_getclient_all /usr/local/bin/avesha_ovpn_getclient_all
COPY ./ca/scripts/avesha_ovpn_listclients /usr/local/bin/avesha_ovpn_listclients
COPY ./ca/scripts/avesha_ovpn_revokeclient /usr/local/bin/avesha_ovpn_revokeclient