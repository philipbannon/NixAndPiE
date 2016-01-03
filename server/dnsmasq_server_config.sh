#!/bin/bash
set -e

# Raspberry Pi dnsmasq script
# Philip.Bannon
# 
# 
# Usage: $ sudo ./dnsmasq_server_config.sh
#
# Net install:
#   $ curl https://raw.github.com/philipbannon/NixAndPiE/master/server/dnsmasq_server_config.sh | sudo sh

# Must be run as root
if [[ `whoami` != "root" ]]
then
  echo "This install must be run as root or with sudo."
  exit
fi


# Need to install dnsmsq first...dont worry if it's already installed.
apt-get install -y dnsmasq

cat - > /etc/dnsmasq.conf <<DNSMASQCONF

# Dnsmasq.conf for raspberry pi    
# Please note this is a VERY bare bones conf for DNS Masq
 
# Set up your local domain here    
domain=raspberry.local    

resolv-file=/etc/resolv.dnsmasq  

min-port=4096   

# Never forward plain names (without a dot or domain part)
domain-needed
# Never forward addresses in the non-routed address spaces.
bogus-priv

# Add other name servers here, with domain specs if they are for
# non-public domains.
#server=/localnet/192.168.0.1

server=8.8.8.8
server=8.8.4.4
      
# Max cache size dnsmasq    
cache-size=10000    
      
# Below are settings for dhcp. Comment them out if you dont want    
# dnsmasq to serve up dhcpd requests.    
# dhcp-range=192.168.0.100,192.168.0.149,255.255.255.0,1440m    
# dhcp-option=3,192.168.0.1    
# dhcp-authoritative
DNSMASQCONF

service dnsmasq restart

echo 'Installation complete. Enjoy!'
