#!/bin/bash
set -e

# Raspberry Pi dnsmasq script
# Philip Bannon
# 
# Usage: $ sudo ./dnsmasq_adblocker
#
# Net install:
#   $ curl "https://raw.github.com/philipbannon/NixAndPie/master/server/dnsmasq_noad" | sudo sh

# This sets up your raspberry pi as a dns server and blocks access to ad sites.
# Once every device on your network is pointing at this DNS server than they will all block ads regardless of Device Type

# Must be run as root
if [[ `whoami` != "root" ]]
then
  echo "This install must be run as root or with sudo."
  exit
fi

# Download the hero of this story
apt-get install -y dnsmasq

# This is where we'll store our dnsmasq configs
cat - > /etc/dnsmasq.d/pimasq.conf <<DNSMASQCONF
# Set up your local domain here
domain=raspberry.local
resolv-file=/etc/resolv.dnsmasq
min-port=4096
server=8.8.8.8
server=8.8.4.4
# Max cache size dnsmasq
cache-size=10000
# The location our adblocking hostfile
addn-hosts=/etc/advert.hosts
DNSMASQCONF

# This is the script that will run daily to update the dns entries for ad sites
cat > /etc/cron.daily/pimasq_updater <<'UPDATER'
#!/bin/bash
HOSTFILE="/etc/advert.hosts"
# Empty the tmp file we'll use to download the files
> $HOSTFILE.raw
# The aggregate mirror of the above urls. Updated nightly.
curl -s -L "http://publius.heystephenwood.com/advert.hosts" > $HOSTFILE.raw

mv $HOSTFILE.raw $HOSTFILE
service dnsmasq restart
UPDATER

# Things in cron need to be executable
chmod +x /etc/cron.daily/pimasq_updater

# Run it once so that we have a working hostfile
/etc/cron.daily/pimasq_updater #> /dev/null

service dnsmasq restart

cat <<CLOSE_MESSAGE
Bootstrap finished!
No more ads!!!! yay \m/
CLOSE_MESSAGE
