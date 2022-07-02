# overriding https://github.com/cloudposse/geodesic/blob/master/rootfs/etc/profile.d/motd.sh

if [[ $SHLVL -eq 2 ]]; then
	if [ -f "/etc/motd" ]; then
		cat "/etc/motd"
	fi

	if [ -n "${MOTD_URL}" ]; then
		curl --fail --connect-timeout 1 --max-time 1 --silent "${MOTD_URL}"
	fi
fi
