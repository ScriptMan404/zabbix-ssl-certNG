#! /bin/sh
# ---------------------------------------------------------------------------------------------------------
# Script checks for number of days until certificate expires, the issuing authority or certificate subject
# depending on switch passed on command line.
#
# This is an updated fork of https://github.com/pschmitt/zabbix-ssl-cert
# ---------------------------------------------------------------------------------------------------------

f=$1
sni=$2
port=$3
proto=$4

if [ -n "$proto" ]
then
    starttls="-starttls $proto"
fi

case $f in
-d)
end_date=$(timeout 0.3 openssl s_client -connect $2:$3 -servername $2 $4 2> /dev/null | openssl x509 -noout -enddate | sed -e "s/^notAfter=//")
echo $((($(date +%s --date "$end_date") - $(date +%s)) / 86400))
;;

-i)
echo $(timeout 0.3 openssl s_client -connect $2:$3 -servername $2 $4 2> /dev/null | openssl x509 -noout -issuer | sed -e "s/.*CN = *//")
;;

-s)
echo $(timeout 0.3 openssl s_client -connect $2:$3 -servername $2 $4 2> /dev/null | openssl x509 -noout -subject | sed -e "s/.*CN = *//")
;;

*)
echo "usage: $0 [-i|-d|-s] sni port"
echo "    -i Show Issuer"
echo "    -d Show valid days remaining"
echo "    -s Show Subject"
;;
esac
