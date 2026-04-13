#!/bin/bash
set -e

# Use an array to store arguments
args=(
    "--user=$VPN_USER"
    "--passwd-on-stdin"
)

# Append to array only if variable is set
[[ -n $AUTH_GROUP ]]       && args+=("--authgroup=$AUTH_GROUP")
[[ -n $SERVER_CERT_PIN ]]   && args+=("--servercert=$SERVER_CERT_PIN")
[[ -n $FORM_ENTRY ]]        && args+=("--form-entry=$FORM_ENTRY")
[[ -n $VERBOSITY ]]         && args+=("-$VERBOSITY")

# Use printf to avoid trailing newlines and keep it secure
printf "%s" "$VPN_PASSWORD" | openconnect "${args[@]}" \
    --dump \
    --csd-wrapper=/usr/libexec/openconnect/csd-wrapper.sh \
    --script-tun \
    --script "ocproxy -g -k 60 -D 9052" \
    --os=linux-64 \
    --useragent AnyConnect \
    "$VPN_HOST"

exec "$@"
