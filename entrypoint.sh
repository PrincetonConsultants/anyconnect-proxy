#!/bin/bash
set -e

# Use an array to store arguments
args=(
    "--user=$VPN_USER"
    "--passwd-on-stdin"
)

# Add CA certificate if file exists
[[ -f "/certs/vpn_ca.crt" ]] && args+=("--cafile=/certs/vpn_ca.crt")
# set parameters for MFA mode if set
if [[ -n $MFA_MODE && $MFA_MODE == "yubikey" ]]; then
    pcscd --disable-polkit &
    sleep 2
    # lsusb
    # find /usr/lib -name "*libykcs11*" -print0 | xargs -0 echo
    # p11tool --provider=/usr/lib/x86_64-linux-gnu/libykcs11.so --list-tokens
    # ykman piv info
    args+=("--certificate=pkcs11:module-path=/usr/lib/x86_64-linux-gnu/libykcs11.so;id=%01;type=cert")
    args+=("--key-password=$KEY_PASSWORD")
elif [[ -n $MFA_MODE && $MFA_MODE == "user_cert" ]]; then
    # Standard User Cert
    if [[ -f "/certs/user.crt" && -f "/certs/user.key" ]]; then
        args+=("--certificate=/certs/user.crt")
        args+=("--sslkey=/certs/user.key")
        [[ -n $KEY_PASSWORD ]] && args+=("--key-password=$KEY_PASSWORD")
    fi
elif [[ -n $MFA_MODE && $MFA_MODE == "mca_cert" ]]; then
    # Multi-Certificate (MCA)
    if [[ -f "/certs/mca.crt" && -f "/certs/mca.key" ]]; then
        args+=("--mca-certificate=/certs/mca.crt")
        args+=("--mca-key=/certs/mca.key")
        [[ -n $MCA_KEY_PASSWORD ]] && args+=("--mca-key-password=$MCA_KEY_PASSWORD")
    fi
fi

# Append to array only if variable is set
[[ -n $AUTH_GROUP ]]       && args+=("--authgroup=$AUTH_GROUP")
[[ -n $SERVER_CERT_PIN ]]   && args+=("--servercert=$SERVER_CERT_PIN")
[[ -n $FORM_ENTRY ]]        && args+=("--form-entry=$FORM_ENTRY")
[[ -n $VERBOSITY ]]         && args+=("-$VERBOSITY")
[[ -n $DUMP ]]              && args+=("--dump")

# Use printf to avoid trailing newlines and keep it secure
printf "%s" "$VPN_PASSWORD" | openconnect "${args[@]}" \
    --csd-wrapper=/usr/libexec/openconnect/csd-wrapper.sh \
    --script-tun \
    --script "ocproxy -g -k 60 -D 9052" \
    --os=linux-64 \
    --no-external-auth \
    --no-http-keepalive \
    --no-dtls \
    --useragent AnyConnect \
    "$VPN_HOST"

exec "$@"
