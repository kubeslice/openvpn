#
# PLATFORM must be specified in the docker build arguments
#     arm32v7 - for Raspberry PI Model 3 or 4
#     amd64 - ubuntu linux for pc/server
#
# Client .ovpn file DNS settings
#     Add/adjust the following three lines at the start of the client.ovpn file and place it in the ~/vpnclietnconfig directory on the docker host:
#       script-security 2
#       up /etc/openvpn/up.sh
#       down /etc/openvpn/down.sh
#
# To build image:
#     docker build --build-arg PLATFORM=amd64 -t avesha/openvpnclient -f openvpn-client.dockerfile .
#
# To Run container with config file:
#     docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --net=host -v ~/vpnclientconfig:/vpnclient avesha/openvpnclient --config /vpn/client.ovpn --auth-nocache
#
# To run container with cmd line options:
#     docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --net=host -v ~/vpnclientconfig:/vpnclient avesha/openvpnclient --config /vpn/client.ovpn --auth-nocache
#
# #### 
# TODO:  Add example of calling client docker with cmd line for all openvpn configuration parameters and utilizing files for crt/keys instead of an inline .ovpn file.
# ####

ARG PLATFORM
FROM ${PLATFORM}/alpine

RUN apk add --update --no-cache openvpn
# Will need to add alpine GRE packages

# NOTE:  Will want entrypoint to generate .ovpn file and run openvpn
ENTRYPOINT ["openvpn"]
#VOLUME ["vpnclient"]
