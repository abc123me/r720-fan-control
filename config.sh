# Default fan control service configuration file

# IPMI hostname
IPMI_HOST="192.168.0.11"
# IPMI username
IPMI_USER="root"
# IPMI password
IPMI_PASS="root"

# Thermal limit - When exceeded the fans will be set to 100%
THERMAL_LIMIT=70

# Cooldown time - Fan control will go back to automatic control
# once GPU has been cooled down for this amount of time
COOLDOWN_TIME=60
