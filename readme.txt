# Note: these scripts will be placed int the ca config-scripts dir and enhanced with
#       scripts to set the environment for configuration
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
#  TODO:  Finish directory examples and use cases
#

#
# EXPORT vars for configuration
# Thes must be set for the apropriate ca/servers
#
export OPENVPN_CA_DIR=~/please/set/path
export OPENVPN="/etc/openvpn"
export OPENVPN_SERVER="boston-edge-1.vpn.dev.aveshasystems.com"
export OPENVPN_INTERNAL_PORT=11194
export OPENVPN_IMAGE=set-openvpn-image
export OPENVPN_LOG_DRIVER="--log-driver=none"
export OPENVPN_GENCONFIG_OPTS=""

#
# Create the pki for your CA  (should only be run once per CA)
#     TODO:  Need ability to create Sub CA that will sign server certificates so that
#            root CA can remain offline
#
#docker run --rm -it -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_initpki
#docker run ${OPENVPN_INITPKI_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_initpki
aveshaCaInitPkiCmd() { docker run --rm -it -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_initpki;}

#
# Generate a config for your server (Should only be run once per server for a given CA)
#
#docker run -e OPENVPN=/etc/openvpn/btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn   ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://btest7.avesha.com:11194
#docker run ${OPENVPN_GENCONFIG_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://btest7.avesha.com:11194
aveshaServerGenConfig() { docker run -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_genconfig -u udp://${OPENVPN_SERVER}:${OPENVPN_INTERNAL_PORT};}
##########   TO DO   ############ Add genconfig options for avesha setup

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

#
# Copy only neccessary server files to server directory for transfer to sytem for running
#
#docker run --rm -it -e OPENVPN=/etc/openvpn -e OPENVPN_SERVER=btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files
#docker run ${OPENVPN_SERVERCMD_OPTS} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files
aveshaCopyServer() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_copy_server_files;}

#
# Now create client certs
# This is run at the CA level so that each client cert can connect to the various servers under that CA
#
#docker run --rm -it -e OPENVPN=/etc/openvpn -e OPENVPN_SERVER=btest7.avesha.com -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} easyrsa build-client-full CLIENT-CN nopass
#docker run ${OPENVPN_CLIENTCMD_OPTS} ${OPENVPN_IMAGE} easyrsa build-client-full CLIENT-CN nopass
aveshaCaCreateClientCert() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaCreateClient clientCommonName" ; return $1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} easyrsa build-client-full $1 nopass;}
# call as aveshaCreate ClientCert CLIENT-CN

#
# Get  Client Certs
#     TODO:  add Description of parameters
#
aveshaGetClient() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaGetClient clientCommonName [combined|combined-save|separated]." ; return $1 ; fi ; if [[ "$2" != "combined" && "$2" != "combined-save" && "$2" != "separated" && "$2" != "" ]]; then echo "param 2 must specify combined|combined-save|separated ." ; return 1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_getclient $1 $2;}

#
# Get  Client Certs all
#
aveshaGetClientAll() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_getclient_all;}

# List Client Certs
#   TODO:
#      - update list to not include any servers under the CA
#      - server and ovpn_env should not be needed.
#      - same goes for clients
aveshaCaListClientCerts() { docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_listclients;}

#
# Revoke Client Certs
#     TODO:  add Description of parameters#
#******** YOU ARE HERE************
aveshaCaRevokeCert() { if [ $# -eq 0 ]; then echo "Client CN is missing.  usage:  aveshaCaRevokeClient clientCommonName [remove|keep]." ; return $1 ; fi ; if [[ "$2" != "keep" && "$2" != "remove" && "$2" != "" ]]; then echo "param 2 must specify remove|keep ." ; return 1 ; fi ; docker run --rm -it -e OPENVPN -e OPENVPN_SERVER -v ${OPENVPN_CA_DIR}:/etc/openvpn  ${OPENVPN_LOG_DRIVER} ${OPENVPN_IMAGE} avesha_ovpn_revokeclient;}

#
# Renew/Update Client Certs
#
##### TO DO #######
##### Renewing cert should be equivalent of revoke cert, then issue new cert with same name #############

#
# Update CRL
#
