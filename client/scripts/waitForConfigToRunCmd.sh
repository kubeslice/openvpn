#!/bin/sh

# We need to have 3 arguments coming in.
#    FILENAME  -  to check for existance
#    WAIT_TIME -  max time to wait for file to be there
#    cmd to execute once file appears
#
# Otherwise exit with error.

if [ $# -lt 3 ] ; then
    echo "Usage:  getConfig FILENAME WAIT_TIME \"cmd to run\" "
    echo "        FILENAME  - name of file to check for existance"
    echo "        WAIT_TIME - How long to wait before calling it quits. default is 90 secs"
    echo "        cmdtorun  - cmd to run when the file appears"
    exit 1
fi

configFile="$1"; shift
waitTime="${1:-90}"; shift
timer=$waitTime
cmdToExecute="$@"

while [ ! -f "$configFile" ] ;
do
      if [ $timer == 0 ] ; then
	  echo "File $configFile Not found after $waitTime seconds"
	  exit 1;
      fi
      echo "Waiting for file:  $configFile"
      sleep 1
      timer=$((timer-1))
done

# Exec the openvpn command so that ctrl-c will work when running from terminal
echo "File $configFile Found. Running"
exec "$@"

