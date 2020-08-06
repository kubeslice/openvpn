FROM kylemanna/openvpn:2.1.0

# This docker file will be used for running the server in a container.
#
# NOTE:  a separate dockerfile is used for the CA cert generation server.
#   We will want to add some of our own scripts to the bin directory specifically for avesha.  These will
#   simplify the cert generation

# For running server, we will build only for ubuntu initially, if we need to build for ARM based processors,
# it will require a deeper dive of the kylmanna openvpn dockerfile to facilitate the ARM based build on alpine.

RUN apk add --update --no-cache  && \
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4.conf
