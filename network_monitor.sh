#!/usr/bin/env bash
# Script to monitor network connectivity and reboot RPI when needed

#Maximum percent packet loss before a restart
maxLostPackets=10
# Initialize to a value that would force a restart
lostPackets=101
# Get the default gateway
defaultGW=$(/sbin/ip route | awk '/default/ { print $3 }')

rebootRPI() {
  logger "Network Monitor: Network connection to $defaultGW is down, rebooting ..."
  sudo reboot
  exit
}

# First make sure we can resolve the gateway, otherwise 'ping -w' would hang
if ! $(host -W5 "$defaultGW" > /dev/null 2>&1); then
  rebootRPI
fi

# Ping the default gateway for 10 seconds and count lost packets
lostPackets=$(ping -q -w10 "$defaultGW" | grep -o "[0-9]*%" | tr -d %) > /dev/null 2>&1

if [ "$lostPackets" -gt "$maxLostPackets" ]; then
  rebootRPI
else
  logger "Network Monitor: Network connection to $defaultGW is up."
fi
