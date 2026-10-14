# Poweredge R720 fan control script

Monitors GPU temperature via `nvidia-smi` and overrides fan speed when threshold is exceeded

Contains a systemd service for this as well

## Requirements

 - awk
 - bash
 - grep
 - ipmitool
 - nvidia-smi

## Updating / Installation (recommended, optional)

The provided installer script `./install.sh` will do the following:
 1. Create a dedicated fan control user/group (fanctrl/fanctrl)
 2. Install the systemd service and utility into /opt
 3. Enable and start the systemd service

## Removal

Removal can be done with `/usr/share/r720-fan-control/uninstall.sh`

## Usage

Or you can simply run `./fan-control.sh` as a normal user, however the
program will not run in the background and if the shell it is running in
ever closes or the system reboots fan control will no longer be running

If a SIGINT is provided to `fan-control.sh` a trap will be called ensuring
that the fans are returned to automatic control

IPMI Commands are logged for ease of troubleshooting, currently there is no
way to disable this so it is recommended you make sure your log rotation
works if you plan on running in an extremely high uptime environment. If the
script has to kick in 1000 times a day, this will produce ~50MB over the span
of a year. So make sure you have at least 50MB of free disk space.

## Systemd service

The `fan-control.service` file consists of a simple systemd service that will
start after `network.target` is reached, and auto-restart after 10 seconds if
an error is encountered.

## Responsibility

This software is not designed for security, or reliability. By using this
software you are accepting the risk of any damages caused by said software.
