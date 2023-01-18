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
timeout=2.5

case $f in
-d)
end_date=$(timeout $timeout openssl s_client -connect $2:$3 -crlf -servername $2 2> /dev/null | openssl x509 -noout -enddate | sed -e "s/^notAfter=//")
echo $((($(date +%s --date "$end_date") - $(date +%s)) / 86400))
;;

-i)
echo $(timeout $timeout openssl s_client -connect $2:$3 -crlf -servername $2 2> /dev/null | openssl x509 -noout -issuer | sed -e "s/.*CN = *//")
;;

-s)
echo $(timeout $timeout openssl s_client -connect $2:$3 -crlf -servername $2 2> /dev/null | openssl x509 -noout -subject | sed -e "s/.*CN = *//")
;;

-t)
tls=$(timeout $timeout openssl s_client -connect $2:$3 -crlf -servername $2 2> /dev/null | grep -e "TLSv1.*")
echo $tls | sed -e "s/^New, //;s/\,.*$//"
;;

*)
echo "usage : $0 [-i|-d|-s|-t] sni port"
echo "        -i Show Issuer"
echo "        -d Show valid days remaining"
echo "        -s Show Subject"
echo "        -t Show TLS version"
;;
esac
