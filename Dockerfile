FROM debian:trixie-slim
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		ocproxy \
		openconnect \
		yubico-piv-tool \
		yubikey-manager \
		pcscd \
		ykcs11\
		opensc\
		gnutls-bin\
		libccid\
		usbutils\
	; \
	rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /opt

EXPOSE 9052
ENTRYPOINT ["/opt/entrypoint.sh"]
