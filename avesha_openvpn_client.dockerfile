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
#     docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --net=host -v ~/vpnclientconfig:/vpnclient avesha/openvpnclient --config /vpnclient/client.ovpn --auth-nocache
#
# To run container with cmd line options:
#     docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --net=host -v ~/vpnclientconfig:/vpnclient avesha/openvpnclient --config /vpnclient/client.ovpn --auth-nocache
#
# OPTION TO WAIT FOR CONFIG TO START CLIENT
# To override entrypoint to allow wait for config file. Tthis would be done as follows:
#  --entrypoint /usr/local/bin/waitForConfigToRunCmd.sh FILENAME WAIT_TIME CMD
#      FILENAME  - config file to wait for
#      WAIT_TIME - How long to wait before calling it quits. Docker will exit upon timeout
#      CMD       - cmd to run when config file appears
#
# --entrypoint /usr/local/bin/waitForConfigToRunCmd.sh DockerImage /vpnclient/xyz.ovpn 90 openvpn --config /vpnclient/xyz.ovpn
#
#    docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --net=host -v ~/config:/vpnclient --entrypoint /usr/local/bin/waitForConfigToRunCmd.sh avesha/openvpnclient /vpnclient/quicktest2.ovpn 90 openvpn --config /vpnclient/quicktest2.ovpn
#
# #### 
# TODO:  Add example of calling client docker with cmd line for all openvpn configuration parameters and utilizing files for crt/keys instead of an inline .ovpn file.
# ####

ARG PLATFORM
FROM ${PLATFORM}/alpine:3.16.2

RUN apk add --update --no-cache openvpn
# Will need to add alpine GRE packages

# Copy the scripts necessary for the openvpn client
# This can be used to wait for a config file before executing openvpn client connection
COPY ./client/scripts/waitForConfigToRunCmd.sh /usr/local/bin/.

# NOTE:  Will want entrypoint to generate .ovpn file and run openvpn
ENTRYPOINT ["openvpn"]
