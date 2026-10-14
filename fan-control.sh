#!/usr/bin/env bash

set -eou pipefail

if [ ! -r "config.sh" ]; then
	echo "\e[1;31mFan control daemon configuration file is not readable!\e[0m"
	exit 1
fi

. "config.sh"

IPMI_CMD=("ipmitool" "-I" "lanplus")
IPMI_CMD+=("-H" "${IPMI_HOST}")
IPMI_CMD+=("-U" "${IPMI_USER}")
IPMI_CMD+=("-P" "${IPMI_PASS}")
IPMI_CMD+=("raw" "0x30" "0x30")

v() { clargs=(); for arg in "$@"; do if [ "$arg" == "${IPMI_PASS}" ] || [ "$arg" == "${IPMI_USER}" ]; then clargs+=("<hidden>"); else clargs+=("$arg"); fi; done; echo "${clargs[@]}"; "$@"; }

fans=0; while true; do
	# Check all GPU temperatures
	overheat=0
	for temp in $(nvidia-smi -d TEMPERATURE -q | grep 'Current Temp' | grep -v 'N/A' | awk -F':' '{print $2}' | awk '{print $1}'); do
		if [ $temp -gt $THERMAL_LIMIT ]; then
			overheat=1
			SECONDS=0
		fi
	done

	# If a GPU is overheating, max out server fans
	if [ $overheat -ne 0 ] && [ $fans -eq 0 ]; then
		echo "A GPU is overheating, manually bringing fans to 100%!"
		v "${IPMI_CMD[@]}" 0x01 0x00
		v "${IPMI_CMD[@]}" 0x02 0xff 0x64
		trap "${IPMI_CMD[*]} 0x01 0x01" EXIT
		fans=1
	elif [ $overheat -eq 0 ] && [ $fans -ne 0 ] && [ $SECONDS -gt $COOLDOWN_TIME ]; then
		echo "The GPU has cooled off for $COOLDOWN_TIME seconds, returning fans to automatic control!"
		v "${IPMI_CMD[@]}" 0x01 0x01
		trap - EXIT
		fans=0
	else sleep 3; fi
done
