#!/bin/sh

. $ICI_CONF_DIR/lib/config.sh
. $ICI_CA_DIR/ca.config

c_init  > $ICI_CONFIG
c_req  >> $ICI_CONFIG
c_dn   >> $ICI_CONFIG

if [ "x${ICI_TYPE}" != "xroot" ]; then
   c_ca >> $ICI_CONFIG
fi

c_ext_common >> $ICI_CONFIG

case $ICI_TYPE in
   root|ca)
      c_ext_ca >> $ICI_CONFIG
      ;;
   client)
      c_ext_tls_client >> $ICI_CONFIG
      ;;
   server)
      c_ext_tls_server >> $ICI_CONFIG
      ;;
   peer)
      c_ext_tls_peer >> $ICI_CONFIG
      ;;
   user)
      c_ext_user >> $ICI_CONFIG
      ;;
esac
c_ext_altnames >> $ICI_CONFIG
c_ext_policy >> $ICI_CONFIG

if [ "x$ICI_VERBOSE" = "xy" ]; then
   cat $ICI_CONFIG
fi
