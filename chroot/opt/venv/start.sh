#!/bin/bash

CONFIG="$HOME/theengsgw.conf"

# HOST: MQTT host address
# Exit if MQTT host address not specified
HOST=${HOST:-$MQTT_HOST}
if [ -z "$HOST" ]; then
    echo "HOST (or MQTT_HOST) is not defined. Missing MQTT host address, exiting"
    exit 1
fi

# PORT: MQTT host port
PORT=${PORT:-$MQTT_PORT}
if [ -n "$PORT" ]; then
    # Use the value from PORT or MQTT_PORT, prefer PORT if both are set
    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "WARNING : Wrong value for MQTT_PORT or PORT environment variable, will use default - 1883"
        PORT=1883
    fi
fi

# USER: MQTT username
# PASS: MQTT password
# Exit if MQTT password is not specified. If either USER or MQTT_USERNAME is set...
USER=${USER:-$MQTT_USERNAME}
PASS=${PASS:-$MQTT_PASSWORD}
if [ -n "$USER" ]; then
    # ...we must check for MQTT_PASSWORD or PASS too
    if [ -z "$PASS" ]; then
        echo "USER or MQTT_USERNAME specified without PASS or MQTT_PASSWORD, exiting"
        exit 1
    fi
fi

# BLE_SCAN_TIME: BLE scan duration (seconds)
BLE_SCAN_TIME=${BLE_SCAN_TIME:-$SCAN_TIME} 
if [ -n "$BLE_SCAN_TIME" ]; then
    if ! [[ "$BLE_SCAN_TIME" =~ ^[0-9]+$ ]]; then
        echo "WARNING : Wrong value for BLE_SCAN_TIME or SCAN_TIME environment variable, will use default - 5"
        BLE_SCAN_TIME=5
    fi
fi

# BLE_TIME_BETWEEN_SCANS: Seconds to wait between scans
BLE_TIME_BETWEEN_SCANS=${BLE_TIME_BETWEEN_SCANS:-$TIME_BETWEEN}
if [ -n "$BLE_TIME_BETWEEN_SCANS" ]; then
    if ! [[ "$BLE_TIME_BETWEEN_SCANS" =~ ^[0-9]+$ ]]; then
        echo "WARNING : Wrong value for BLE_TIME_BETWEEN_SCANS or TIME_BETWEEN environment variable, will use default - 5"
        BLE_TIME_BETWEEN_SCANS=5
    fi
fi

# PUBLISH_TOPIC: MQTT publish topic
PUBLISH_TOPIC=${PUBLISH_TOPIC:-$MQTT_PUB_TOPIC}

# LWT_TOPIC: MQTT LWT topic

# SUBSCRIBE_TOPIC: MQTT subscribe topic
SUBSCRIBE_TOPIC="${SUBSCRIBE_TOPIC:-$MQTT_SUB_TOPIC}"

# PRESENCE_TOPIC: MQTT presence topic

# PRESENCE: Enable (1) or disable (0) presence publication (default: 0)
if [ -n "$PRESENCE" ]; then
    if ! [[ "$PRESENCE" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for PRESENCE environment variable, will use default - false"
        PRESENCE=false
    fi
fi

# PUBLISH_ALL: Publish all (1) or only decoded (0) advertisements (default: 1)
if [ -n "$PUBLISH_ALL" ]; then
    if ! [[ "$PUBLISH_ALL" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for PUBLISH_ALL environment variable, will use default - true"
        PUBLISH_ALL=true
    fi
fi

# LOG_LEVEL: Check LOG_LEVEL
if [ -n "$LOG_LEVEL" ]; then
    if ! [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARNING|ERROR|CRITICAL)$ ]]; then
        echo "WARNING : Wrong value for LOG_LEVEL environment variable, will use default - INFO"
        LOG_LEVEL=INFO
    fi
fi

# DISCOVERY: Enable(1) or disable(0) MQTT discovery
if [ -n "$DISCOVERY" ]; then
    if ! [[ "$DISCOVERY" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for DISCOVERY environment variable, will use default - true"
        DISCOVERY=true
    fi
fi

# HASS_DISCOVERY: Enable(1) or disable(0) Home Assistant MQTT discovery (default: 1)
if [ -n "$HASS_DISCOVERY" ]; then
    if ! [[ "$HASS_DISCOVERY" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for HASS_DISCOVERY environment variable, will use default - true"
        HASS_DISCOVERY=true
    fi
fi

# GENERAL_PRESENCE: Enable (1) or disable (0) general present/absent presence when --discovery: 0 (default: 0)
if [ -n "$GENERAL_PRESENCE" ]; then
    if ! [[ "$GENERAL_PRESENCE" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for GENERAL_PRESENCE environment variable, will use default - false"
        GENERAL_PRESENCE=false
    fi
fi

# DISCOVERY_TOPIC: MQTT Discovery topic
# DISCOVERY_DEVICE_NAME: Device name for Home Assistant
# DISCOVERY_FILTER: Device discovery filter list for Home Assistant

# ADAPTER: Bluetooth adapter (e.g. hci1 on Linux)
# Check if ADAPTER is set and if the corresponding directory exists
if [ -n "$ADAPTER" ] && ! [ -d /sys/class/bluetooth/$ADAPTER ]; then
    echo "WARNING : Adapter name $ADAPTER might not exist. Will accept the value but if you notice issues, please change it."
fi

# SCANNING_MODE: Scanning mode (default: active)
if [ -n "$SCANNING_MODE" ]; then
    if ! [[ "$SCANNING_MODE" =~ ^(active|passive)$ ]]; then
        echo "WARNING : Wrong value for SCANNING_MODE, must be one of: active, passive. Will use default - active."
        SCANNING_MODE="active"
    fi
fi

# Check PASSIVE_SCAN
if [ -n "$PASSIVE_SCAN" ]; then
    # Deprecation warning
    echo "PASSIVE_SCAN : Deprecated environment variable, this variable will be removed in future versions, please use SCANNING_MODE=active|passive"
    if [[ "$PASSIVE_SCAN" == true ]]; then
        echo "Enabling passive scanning mode"
        SCANNING_MODE="passive"
    elif [[ "$PASSIVE_SCAN" == false ]]; then
        echo "Disabling passive scanning mode"
        SCANNING_MODE="active"
    fi
fi

# TIME_SYNC: Addresses of Bluetooth devices to synchronize the time

# TIME_FORMAT: Use 12-hour (1) or 24-hour (0) time format for clocks (default: 0)
if [ -n "$TIME_FORMAT" ]; then
    if ! [[ "$TIME_FORMAT" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for TIME_FORMAT, will use default - false."
        TIME_FORMAT="false"
    fi
fi

# PUBLISH_ADVDATA: Publish advertising and advanced data (1) or not (0) (default: 0)
if [ -n "$PUBLISH_ADVDATA" ]; then
    if ! [[ "$PUBLISH_ADVDATA" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for PUBLISH_ADVDATA environment variable, will use default - false"
        PUBLISH_ADVDATA=false
    fi
fi

# ENABLE_TLS: Enable (1) or disable (0) TLS (default: 0)
if [ -n "$ENABLE_TLS" ]; then
    if ! [[ "$ENABLE_TLS" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for ENABLE_TLS, will use default - false."
        ENABLE_TLS="false"
    fi
fi

# TLS_INSECURE: Allow (1) or disallow (0: default) insecure TLS (no hostname check)

# ENABLE_WEBSOCKET: Enable (1) or disable (0) WebSocket (default: 0)
if [ -n "$ENABLE_WEBSOCKET" ]; then
    if ! [[ "$ENABLE_WEBSOCKET" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for ENABLE_WEBSOCKET, will use default - false."
        ENABLE_WEBSOCKET="false"
    fi
fi

# TRACKER_TIMEOUT: Tracker timeout duration (seconds)
if [ -n "$TRACKER_TIMEOUT" ]; then
    if ! [[ "$TRACKER_TIMEOUT" =~ ^[0-9]+$ ]]; then
        echo "WARNING : Wrong value for TRACKER_TIMEOUT environment variable, will use default - 120"
        TRACKER_TIMEOUT=120
    fi
fi

# BLE: Enable (1) or disable (0) BLE (default: 1)
if [ -n "$BLE" ]; then
    if ! [[ "$BLE" =~ ^(true|1|false|0)$ ]]; then
        echo "WARNING : Wrong value for BLE environment variable, will use default - true"
        BLE=true
    fi
fi

# WHITELIST: Addresses of Bluetooth devices to allow, all other devices are ignored
# BLACKLIST: Addresses of Bluetooth devices to ignore, all other devices are allowed

### Syntax checks - END

cd $VIRTUAL_ENV

if grep -q "\"use_config\": true" "$CONFIG"; then
    echo "Skipping writing configuration file from."
else
echo "Creating config at $CONFIG ..."
{
    cat <<EOF
{
    "host": "$HOST",
    "port": ${PORT:-1883},
    "user": "$USER",
    "pass": "$PASS",
    "ble_scan_time": ${BLE_SCAN_TIME:-5},
    "ble_time_between_scans": ${BLE_TIME_BETWEEN_SCANS:-5},
    "publish_topic": "${PUBLISH_TOPIC:-home/TheengsGateway/BTtoMQTT}",
    "lwt_topic": "${LWT_TOPIC:-home/TheengsGateway/LWT}",
    "subscribe_topic": "${SUBSCRIBE_TOPIC:-home/+/BTtoMQTT/undecoded}",
    "presence_topic": "${PRESENCE_TOPIC:-home/presence/TheengsGateway}",
    "presence": ${PRESENCE:-false},
    "publish_all": ${PUBLISH_ALL:-true},
    "log_level": "${LOG_LEVEL:-INFO}",
    "discovery": ${DISCOVERY:-true},
    "hass_discovery": ${HASS_DISCOVERY:-true},
    "general_presence": ${GENERAL_PRESENCE:-false},
    "discovery_topic": "${DISCOVERY_TOPIC:-homeassistant/sensor}",
    "discovery_device_name": "${DISCOVERY_DEVICE_NAME:-TheengsGateway}",
    "discovery_filter": "${DISCOVERY_FILTER:-[IBEACON]}",
    "adapter": "${ADAPTER:-hci0}",
    "scanning_mode": "${SCANNING_MODE:-active}",
    "time_sync": "${TIME_SYNC:-[]}",
    "time_format": "${TIME_FORMAT:-0}",
    "publish_advdata": ${PUBLISH_ADVDATA:-false},
    "enable_tls": ${ENABLE_TLS:-false},
    "tls_insecure": ${TLS_INSECURE:-false},
    "enable_websocket": ${ENABLE_WEBSOCKET:-false},
    "tracker_timeout": ${TRACKER_TIMEOUT:-120},
    "ble": ${BLE:-true}
EOF
    # Conditionally include BINDKEYS if not empty
    if [ -n "$BINDKEYS" ]; then
        echo ",    \"bindkeys\": $BINDKEYS"
    fi

    # Conditionally include IDENTITIES if not empty
    if [ -n "$IDENTITIES" ]; then
        echo ",    \"identities\": $IDENTITIES"
    fi

    # Conditionally include WHITELIST if not empty
    if [ -n "$WHITELIST" ]; then
        echo ",    \"whitelist\": $WHITELIST"
    fi

    # Conditionally include BLACKLIST if not empty
    if [ -n "$BLACKLIST" ]; then
        echo ",    \"blacklist\": $BLACKLIST"
    fi
	
    echo "}"
} > "$CONFIG"
fi

cat "$CONFIG"

python3 -m TheengsGateway $PARAMS
