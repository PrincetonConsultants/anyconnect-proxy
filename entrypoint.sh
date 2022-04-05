#!/bin/bash

set -e

args="--user=$VPN_USER --passwd-on-stdin"
if ! [[ -z $AUTH_GROUP ]]; then
    args="$args --authgroup=$AUTH_GROUP"
fi
if ! [[ -z $SERVER_CERT_PIN ]]; then
    args="$args --servercert=$SERVER_CERT_PIN"
fi
if ! [[ -z $FORM_ENTRY ]]; then
    args="$args --form-entry=$FORM_ENTRY"
fi
if ! [[ -z $VERBOSITY ]]; then
    args="$args -$VERBOSITY"
fi

echo $VPN_PASSWORD | openconnect $args --dump --csd-wrapper=/usr/libexec/openconnect/csd-wrapper.sh --script-tun --script "ocproxy -g -k 60 -D 9052" --os=linux-64 $VPN_HOST

exec "$@"
