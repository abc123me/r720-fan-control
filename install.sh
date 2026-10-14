#!/usr/bin/env bash

set -eou pipefail

if [ $UID -ne 0 ]; then
	echo "Warning: install script will need root"
	echo "If sudo is unavailable it can be overridden by setting "SUDO=my-sudo""
fi

v() { echo "$@"; "$@"; }
vs() { if [ $UID -ne 0 ]; then v "${SUDO:-sudo}" "$@"; else v "$@"; fi; }

# Change these at your own risk, should also be changed in .service file
INSTALL_PATH="/usr/share/r720-fan-control"

if cat /etc/passwd | grep -qE 'fanctrl:x:[0-9]+:[0-9]+:fanctrl'; then
	echo "Fan control user already exists, not making one!"
else
	echo "Making a fan control user (fanctrl) and setting up base directory!"
	vs useradd -M -d /nonexistent -s /usr/sbin/nologin -c "Fan control daemon" fanctrl
	vs mkdir -pv "${INSTALL_PATH}"
	vs chown root:root "${INSTALL_PATH}"
fi

CONFIG_PATH="${INSTALL_PATH}/config.sh"
if [ ! -r "${CONFIG_PATH}" ]; then
	echo -e "\e[1;33mDefault config installed at: ${CONFIG_PATH}\e[0m"
	echo -e "\e[1;33mAfterwards edit using "${SUDO:-sudo} ${EDITOR:-nano} ${CONFIG_PATH}"\e[0m"
	# Contains an IPMI username/password and should not be readble by others
	vs install -m 0640 -o root -g fanctrl config.sh "${INSTALL_PATH}"
else
	echo "Using existing fan control configuration"
fi
vs install -m 0755 -o root -g root fan-control.sh "${INSTALL_PATH}"
vs install -m 0755 -o root -g root uninstall.sh   "${INSTALL_PATH}"

SERVICE_NAME="r720-fan-control.service"
echo "Installing fan control service (${SERVICE_NAME})"
vs install -m 0644 -o root -g root "${SERVICE_NAME}" "${INSTALL_PATH}"

echo "Enabling / Starting fan control service"
vs systemctl daemon-reload
vs systemctl enable "${INSTALL_PATH}/${SERVICE_NAME}"
vs systemctl start  "${SERVICE_NAME}"
v  systemctl status "${SERVICE_NAME}"
echo -e "\e[1;32mInstallation complete!\e[0m"
