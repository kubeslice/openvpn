#!/bin/bash

# Directory Structure
#     - Customer-1-CA
#           - pki
#                 - crl.pem    # Will need to be copied to all servers generated
#                 - issued/
#                 - private/
#                 - reqs/
#                 - server1-ta.key
#                 - server2-ta.key
#           - Server1
#	          - openvpn.conf
#	          - ovpn_env.sh
#		  - ccd/
#		  - server   # Dir to deploy to server after "avesha_ovpn_copy_server_files" cmd
#           -
#           - Server2
#	          - openvpn.conf
#	          - ovpn_env.sh
#		  - ccd/
#		  - server   # Dir to deploy to server after "avesha_ovpn_copy_server_files" cmd
#     - Customer-2-CA
#
#  TODO:
#      - Add Routes for point to point ability  ie server side network exposed
#      - Add Subent on Server Side to expose to clients config
#      - Add ccd files for client networks and static IPs
#      - Finish directory examples and use cases
#      - Enhance scripts to validate parameters
#      - Have set server/CA/port/image script or env file to set woking env for particular server instead of changing and sourcing file
#      - Handle Docker Pulling image to run
#      - validate paths prior to use to not overwrite anything.
#      - Condense cmd options into smaller subset so functions cmds are simpler
#      - Add cmd and eval for scripts
#      - Do not re run init pki if ther eis already pki initialized  prompt or require force.
#      - Need to handle cleint information & ccd per server.

#
# EXPORT vars for configuration
# Thes must be set for the apropriate ca/servers
#
export OPENVPN_CA_DIR=~/please/set/path
export OPENVPN="/etc/openvpn"
# export OPENVPN_IMAGE=nexus.prod.aveshasystems.com/avesha/openvpn-ca.ubuntu.18.04:1.0.0
export OPENVPN_IMAGE=set-openvpn-image
export OPENVPN_CONN_PORT=11194
export OPENVPN_SERVER="SETSERVERNAME.vpn.dev.aveshasystems.com"
export OPENVPN_SERVER_SUBNET=10.8.200.1
export OPENVPN_SERVER_SUBNET_CIDR=24
export OPENVPN_SERVER_SUBNET_MASK=255.255.255.0

# TOFIX if there is no routable network exposed by the server.
export OPENVPN_SERVER_ROUTABLE_SUBNET=10.8.210.0
export OPENVPN_SERVER_ROUTABLE_SUBNET_CIDR=24
export OPENVPN_SERVER_ROUTABLE_SUBNET_MASK=255.255.255.0

export OPENVPN_SERVER_CLIENT_ROUTABLE_SUBNET_OPTS="-r 10.33.12.0/24"

# Server Config Options For use based on above params:
export OPENVPN_LOG_DRIVER="--log-driver=none"
export OPENVPN_CONFIG_GENERAL_OPTS="-b -c -d -C AES-256-CBC -a SHA256"
export OPENVPN_CONFIG_EXTRA_SERVER_OPTS='-E "resolv-retry infinite" -E "user nobody" -E "group nogroup" -E "persist-key" -E "persist-tun" -E "tls-auth ta.key 1"'
export OPENVPN_CONFIG_EXTRA_CLIENT_OPTS='-e "ifconfig-pool-persist /etc/openvpn/ipp.txt" -e "topology subnet" -e "client-config-dir /etc/openvpn/ccd" -e "crl-verify /etc/openvpn/crl.pem"'
export OPENVPN_CONFIG_UDP_OPTS="-u  udp://$OPENVPN_SERVER:$OPENVPN_CONN_PORT"
export OPENVPN_CONFIG_SUBNET_OPTS="-s $OPENVPN_SERVER_SUBNET/$OPENVPN_SERVER_SUBNET_CIDR"    # -s 10.8.200.1/24
export OPENVPN_CONFIG_PUSH_ROUTE_OPTS='-p "route $OPENVPN_SERVER_SUBNET $OPENVPN_SERVER_SUBNET_MASK"'
export OPENVPN_CONFIG_ALL_OPTS="$OPENVPN_CONFIG_GENERAL_OPTS $OPENVPN_CONFIG_UDP_OPTS $OPENVPN_CONFIG_SUBNET_OPTS $OPENVPN_CONFIG_EXTRA_SERVER_OPTS $OPENVPN_CONFIG_EXTRA_CLIENT_OPTS $OPENVPN_CONFIG_PUSH_ROUTE_OPTS"

# FIX if there is no routable network exposed by the server.
export OPENVPN_CONFIG_PUSH_SERVER_ROUTE_OPTS='-p "route $OPENVPN_SERVER_ROUTABLE_SUBNET $OPENVPN_SERVER_ROUTABLE_SUBNET_MASK"'
export OPENVPN_CONFIG_SITE_TO_SITE_OPTS="$OPENVPN_CONFIG_PUSH_SERVER_ROUTE_OPTS $OPENVPN_SERVER_CLIENT_ROUTABLE_SUBNET_OPTS"

# Server Options
# -b -c -d -s 10.8.81.0/24 -u  udp://boston.vpn.dev.aveshasystems.com:443 -p "route 10.8.81.0 255.255.255.0" -C AES-256-CBC -a SHA256 -e "ifconfig-pool-persist /etc/openvpn/ipp.txt" -e "topology subnet" -e "client-config-dir /etc/vpn/ccd" -e "crl-verify /etc/openvpn/crl.pem" -E "resolv-retry infinite" -E "user nobody" -E "group nogroup" -E "persist-key" -E "persist-tun" -E "tls-auth ta.key 1"
#                -b: Disable 'push block-outside-dns
#                -c:  enable client to client
#                -d: disable default route
#                -s: server subnet
#                -u:  server public url
#                -E "Extra client config"
#                -e "Extra server config"
#                -C Cipher - (AES-256-CBC)
#                -a auth - SHA256
#                -p "route 10.8.81.0 255.255.255.0"  - Push route to client in server config.
#                -
#                - NOTE: Extra Server Config needed:
#                    -e "ifconfig-pool-persist /var/log/openvpn/ipp.txt" -e "topology subnet" -e "client-config-dir /etc/vpn/ccd" -e "crl-verify /etc/openvpn/crl.pem"
#                - NOTE: Extra Client Config needed:
#                    -E "resolv-retry infinite" -E "user nobody" -E "group nogroup" -E "persist-key" -E "persist-tun" -E "tls-auth ta.key 1"


#
# Create the pki for your CA  (should only be run once per CA)
#     TODO:  Need ability to create Sub CA that will sign server certificates so that
#            root CA can remain offline
#
#docker run --rm -it -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_initpki
#docker run ${OPENVPN_INITPKI_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_initpki
aveshaCaInitPkiCmd() { docker run --rm -it -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_initpki;}
echo "aveshaCaInitPkiCmd() - init CA Pki"

#
# Generate a config for your server (Should only be run once per server for a given CA)
#
#docker run -e OPENVPN=/etc/openvpn/btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn   ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://btest7.avesha.com:11194
#docker run ${OPENVPN_GENCONFIG_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://btest7.avesha.com:11194
#aveshaServerGenConfig() { docker run -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://${OPENVPN_SERVER}:${OPENVPN_INTERNAL_PORT};}
aveshaServerGenConfig() { cmd="docker run --rm -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig $OPENVPN_CONFIG_ALL_OPTS"; eval $cmd;}
echo "aveshaServerGenConfig() - generate a server config"
##########   TO DO   ############ Add genconfig options for avesha setup

# Add the optipns to the config if you are running site to site mode versus a sewrver for multiple clients connecting.
# To FIX:  will need to handle via conditional of site to site opts.  as server may want to always expose some networks to clients.
aveshaServerGenConfigSiteToSite() { cmd="docker run --rm -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig $OPENVPN_CONFIG_SITE_TO_SITE_OPTS"; eval $cmd;}
echo "aveshaServerGenConfigSiteToSite() - generate a server config"

#
# Renew/Update Server Cert
#
##### TO DO #######
##### Should be the same as revoking and renewing client cert ##########

#
# Initialize your server setup
#
#docker run --rm -it -e OPENVPN=/etc/openvpn -e OPENVPN_SERVER=btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_init_server
#docker run ${OPENVPN_SERVERCMD_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_init_server
aveshaCaInitServer() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_init_server;}
echo "aveshaCaInitServer() - initialize the server setup (cert/etc)"

#
# Copy only neccessary server files to server directory for transfer to sytem for running
#
#docker run --rm -it -e OPENVPN=/etc/openvpn -e OPENVPN_SERVER=btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files
#docker run ${OPENVPN_SERVERCMD_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files
aveshaCopyServer() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files;}
echo "aveshaCopyServer() - copy the server files to a directory that can be moved to the server for running"

#
# Now create client certs
# This is run at the CA level so that each client cert can connect to the various servers under that CA
#
#docker run --rm -it -e OPENVPN=/etc/openvpn -e OPENVPN_SERVER=btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} easyrsa build-client-full CLIENT-CN nopass
#docker run ${OPENVPN_CLIENTCMD_OPTS} ${OPENVPN_IMAGE} easyrsa build-client-full CLIENT-CN nopass
aveshaCaCreateClientCert() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaCreateClient clientCommonName" ; return $1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} easyrsa build-client-full $1 nopass;}
# call as aveshaCreate ClientCert CLIENT-CN
echo "aveshaCaCreateClientCert() - Create a client cert for a given COMMON_NAME"

#
# Get  Client Certs
#     TODO:  add Description of parameters
#
aveshaGetClient() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaGetClient clientCommonName [combined|combined-save|separated]." ; return $1 ; fi ; if [[ "$2" != "combined" && "$2" != "combined-save" && "$2" != "separated" && "$2" != "" ]]; then echo "param 2 must specify combined|combined-save|separated ." ; return 1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_getclient $1 $2;}
echo "aveshaGetClient() - retrieve the client .ovpn for a given COMMON_NAME as a combined file or separated files"

#
# Get  Client Certs all
#
aveshaGetClientAll() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_getclient_all;}
echo "aveshaGetClientAll() - get all client certs in directory"

# List Client Certs
#   TODO:
#      - update list to not include any servers under the CA
#      - server and ovpn_env should not be needed.
#      - same goes for clients
aveshaCaListClientCerts() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_listclients;}
echo "aveshaCaListClientCerts() - List all client certificates and expirations"

#
# Revoke Client Certs
#     TODO:  add Description of parameters#
#******** YOU ARE HERE************
aveshaCaRevokeCert() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaCaRevokeClient clientCommonName [remove|keep]." ; return $1 ; fi ; if [[ "$2" != "keep" && "$2" != "remove" && "$2" != "" ]]; then echo "param 2 must specify remove|keep ." ; return 1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_revokeclient;}
echo "aveshaCaRevokeCert() - Revoke client certificate for COMMON_NAME and either remove|keep the files"

#
# Renew/Update Client Certs
#
##### TO DO #######
##### Renewing cert should be equivalent of revoke cert, then issue new cert with same name #############

#
# Update CRL
#
