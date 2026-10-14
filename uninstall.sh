#!/usr/bin/env bash

set -eou pipefail

if [ $UID -ne 0 ]; then
	echo "Warning: install script will need root"
	echo "If sudo is unavailable it can be overridden by setting "SUDO=my-sudo""
fi

v() { echo "$@"; "$@"; }
vs() { if [ $UID -ne 0 ]; then v "${SUDO:-sudo}" "$@"; else v "$@"; fi; }

INSTALL_PATH="/usr/share/r720-fan-control"
SERVICE_NAME="r720-fan-control.service"

echo -e "\e[1;33mShutting down and disabling fan control daemon!\e[0m"
vs systemctl stop "${SERVICE_NAME}"
vs systemctl disable "${SERVICE_NAME}"
vs systemctl daemon-reload

echo -e "\e[1;33mRemoving fan control daemon files!\e[0m"
vs rm -rfv "${INSTALL_PATH}"

echo -e "\e[1;33mRemoving fan control daemon user!\e[0m"
vs userdel fanctrl

echo -e "\e[1;32mUninstall completed!\e[0m"
