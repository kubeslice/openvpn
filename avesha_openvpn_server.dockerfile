FROM kylemanna/openvpn:2.1.0

# This docker file will be used for running the server in a container.
#
# NOTE:  a separate dockerfile is used for the CA cert generation server.
#   We will want to add some of our own scripts to the bin directory specifically for avesha.  These will
#   simplify the cert generation

# For running server, we will build only for ubuntu initially, if we need to build for ARM based processors,
# it will require a deeper dive of the kylmanna openvpn dockerfile to facilitate the ARM based build on alpine.
#
# Running server:
#   Server by default will start automatically looking for /etc/openvpn.conf file.
#     sudo docker run -v  ~/vpn/server-dir:/etc/openvpn -d -p 11196:11196/udp --cap-add=NET_ADMIN --name=vpntest1 --net host OPENVPNSERVERIMAGE
#
#   To have server wait for /etc/openvpn.conf and start utilize the additional entrypoint:
#      FILENAME  - config file to wait for
#      WAIT_TIME - How long to wait before calling it quits. Docker will exit upon timeout
#      CMD       - ovpn_run  (cmd to run when config appears)  For openvpn server this is always the script to run.
#
#     --entrypoint /usr/local/bin/waitForConfigToRunCmd.sh OPENVPNSERVERIMAGE /etc/openvpn/openvpn.conf 90 ovpn_run
#     sudo docker run -v  ~/vpn/server:/etc/openvpn -d -p 11196:11196/udp --cap-add=NET_ADMIN --name=vpntest1 --net host --entrypoint /usr/local/bin/waitForConfigToRunCmd.sh OPENVPNSERVERIMAGE /etc/openvpn/openvpn.conf 90 ovpn_run

# Turn on ipv4 forwarding
RUN apk add --update --no-cache  && \
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4.conf

# Copy the scripts necessary for the openvpn server
# This can be used to wait for a config file before starting the openvpn server
COPY ./server/scripts/waitForConfigToRunCmd.sh /usr/local/bin/.

# Note: 
# CMD from base image is:   CMD ["ovpn_run"]
#
