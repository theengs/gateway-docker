#!/bin/bash

CONFIG="$HOME/theengsgw.conf"

isempty() {
        if [ x"$1" == "x" ]; then
                return 0
        else
                return 1
        fi
}

hasvalue() {
        if [ x"$1" == "x" ]; then
                return 1
        else
                return 0
        fi
}

# Exit if MQTT host not specified
HOST=${HOST:-$MQTT_HOST}
if isempty $HOST; then
        echo "MQTT Host not defined, exiting"
        exit 1
fi

# If we enter username...
USER=${USER:-$MQTT_USERNAME}
PASS=${PASS:-$MQTT_PASSWORD}
if hasvalue $USER; then
	# ...we must check for password too
        if isempty $PASS; then
                echo "MQTT_USERNAME specified without MQTT_PASSWORD"
                exit 1
        fi
fi

### Syntax checks - START
PORT=${PORT:-$MQTT_PORT}
if hasvalue $PORT; then
	if ! [[ $PORT =~ ^[0-9]+$ ]]; then
		echo "WARNING : Wrong value for MQTT_PORT environment variable, will use default - 1883"
		PORT=1883
	fi
fi

PUBLISH_TOPIC=${PUBLISH_TOPIC:-$MQTT_PUB_TOPIC}
SUBSCRIBE_TOPIC=${SUBSCRIBE_TOPIC:-$MQTT_SUB_TOPIC}
PRESENCE_TOPIC=${PRESENCE_TOPIC:-$MQTT_PRE_TOPIC}

if hasvalue $PUBLISH_ALL; then
	if ! [[ $PUBLISH_ALL =~ (true|false) ]]; then
		echo "WARNING : Wrong value for PUBLISH_ALL environment variable, will use default - true"
		PUBLISH_ALL=true
	fi
fi

if hasvalue $PUBLISH_ADVDATA; then
	if ! [[ $PUBLISH_ADVDATA =~ (true|false) ]]; then
		echo "WARNING : Wrong value for PUBLISH_ADVDATA environment variable, will use default - false"
		PUBLISH_ADVDATA=false
	fi
fi

if hasvalue $PRESENCE; then
	if ! [[ $PRESENCE =~ (true|false) ]]; then
		echo "WARNING : Wrong value for PRESENCE environment variable, will use default - false"
		PRESENCE=false
	fi
fi

if hasvalue $GENERAL_PRESENCE; then
	if ! [[ $GENERAL_PRESENCE =~ (true|false) ]]; then
		echo "WARNING : Wrong value for GENERAL_PRESENCE environment variable, will use default - false"
		GENERAL_PRESENCE=false
	fi
fi

if hasvalue $BLE; then
	if ! [[ $BLE =~ (true|false) ]]; then
		echo "WARNING : Wrong value for BLE environment variable, will use default - true"
		BLE=true
	fi
fi

BLE_SCAN_TIME=${BLE_SCAN_TIME:-$SCAN_TIME}
if hasvalue $BLE_SCAN_TIME; then
	if ! [[ $BLE_SCAN_TIME =~ ^[0-9]+$ ]]; then
		echo "WARNING : Wrong value for SCAN_TIME environment variable, will use default - 60"
		BLE_SCAN_TIME=60
	fi
fi

BLE_TIME_BETWEEN_SCANS=${BLE_TIME_BETWEEN_SCANS:-$TIME_BETWEEN}
if hasvalue $BLE_TIME_BETWEEN_SCANS; then
	if ! [[ $BLE_TIME_BETWEEN_SCANS =~ ^[0-9]+$ ]]; then
		echo "WARNING : Wrong value for TIME_BETWEEN environment variable, will use default - 60"
		BLE_TIME_BETWEEN_SCANS=60
	fi
fi

if hasvalue $TRACKER_TIMEOUT; then
	if ! [[ $TRACKER_TIMEOUT =~ ^[0-9]+$ ]]; then
		echo "WARNING : Wrong value for TRACKER_TIMEOUT environment variable, will use default - 120"
		TRACKER_TIMEOUT=120
	fi
fi

if hasvalue $LOG_LEVEL; then
	if ! [[ $LOG_LEVEL =~ (DEBUG|INFO|WARNING|ERROR|CRITICAL) ]]; then
		echo "WARNING : Wrong value for LOG_LEVEL environment variable, will use default - DEBUG"
		LOG_LEVEL=DEBUG
	fi
fi

if hasvalue $DISCOVERY; then
	if ! [[ $DISCOVERY =~ (true|false) ]]; then
		echo "WARNING : Wrong value for DISCOVERY environment variable, will use default - true"
		DISCOVERY=true
	fi
fi

if hasvalue $HASS_DISCOVERY; then
	if ! [[ $HASS_DISCOVERY =~ (true|false) ]]; then
		echo "WARNING : Wrong value for DISCOVERY environment variable, will use default - true"
		HASS_DISCOVERY=true
	fi
fi

if hasvalue $PASSIVE_SCAN; then
	# Deprecation warning, this was written before 0.5.0 was released , will use SCANNIN_MODE in future
	echo "PASSIVE_SCAN : Deprecated environment variable, this variable will be removed in future versions, please use SCANNING_MODE=active|passive"

	if [[ $PASSIVE_SCAN == true ]]; then
		echo "Enabling passive scanning mode"
		SCANNING_MODE="passive"
	elif [[ $PASSIVE_SCAN == false ]]; then
		echo "Disabling passive scanning mode"
		SCANNING_MODE="active"
	else
		echo "Incorrect value for PASSIVE_SCAN environment variable, will use default - active"
	fi
fi

if hasvalue $ADAPTER; then
	if ! [ -d /sys/class/bluetooth/$ADAPTER ]; then
		echo "WARNING : Adapter name $ADAPTER might not exist. Will accept the value but if you notice issues , please change it"
	fi
fi

if hasvalue $SCANNING_MODE; then
	if ! [[ $SCANNING_MODE =~ (active|passive) ]]; then
		echo "WARNING : Wrong value for SCANNING_MODE, must be one of: active, passive. Will use default - active"
		SCANNING_MODE=active
	fi
fi

if hasvalue $TIME_FORMAT; then
	if ! [[ $TIME_FORMAT =~ (true|false) ]]; then
		echo "WARNING : Wrong value for TIME_FORMAT environment variable, will use default - false"
		TIME_FORMAT=false
	fi
fi

if hasvalue $ENABLE_TLS; then
	if ! [[ $ENABLE_TLS =~ (true|false) ]]; then
		echo "WARNING : Wrong value for ENABLE_TLS environment variable, will use default - false"
		ENABLE_TLS=false
	fi
fi

if hasvalue $ENABLE_WEBSOCKET; then
	if ! [[ $ENABLE_WEBSOCKET =~ (true|false) ]]; then
		echo "WARNING : Wrong value for ENABLE_WEBSOCKET environment variable, will use default - false"
		ENABLE_WEBSOCKET=false
	fi
fi

### Syntax checks - END

cd $VIRTUAL_ENV

echo "Creating config at $CONFIG ..."
{
    cat <<EOF
{
    "host": "$HOST",
    "pass": "PASS",
    "user": "$USER",
    "port": ${PORT:-1883},
    "publish_topic": "${PUBLISH_TOPIC:-home/TheengsGateway/BTtoMQTT}",
    "subscribe_topic": "${SUBSCRIBE_TOPIC:-home/+/BTtoMQTT/undecoded}",
    "presence_topic": "${PRESENCE_TOPIC:-home/presence/TheengsGateway}",
    "presence": ${PRESENCE:-false},
    "general_presence": ${GENERAL_PRESENCE:-false},
    "publish_all": ${PUBLISH_ALL:-true},
    "publish_advdata": ${PUBLISH_ADVDATA:-false},
    "ble_scan_time": ${BLE_SCAN_TIME:-60},
    "ble_time_between_scans": ${BLE_TIME_BETWEEN_SCANS:-60},
    "tracker_timeout": ${TRACKER_TIMEOUT:-120},
    "log_level": "${LOG_LEVEL:-DEBUG}",
    "lwt_topic": "${LWT_TOPIC:-home/TheengsGateway/LWT}",
    "discovery": ${DISCOVERY:-true},
    "hass_discovery": ${HASS_DISCOVERY:-true},
    "discovery_topic": "${DISCOVERY_TOPIC:-homeassistant/sensor}",
    "discovery_device_name": "${DISCOVERY_DEVICE_NAME:-TheengsGateway}",
    "discovery_filter": "${DISCOVERY_FILTER:-[IBEACON]}",
    "scanning_mode": "${SCANNING_MODE:-active}",
    "adapter": "${ADAPTER:-hci0}",
    "time_sync": "${TIME_SYNC:-[]}",
    "time_format": "${TIME_FORMAT:-0}",
    "ble": ${BLE:-true},
    "enable_tls": ${ENABLE_TLS:-false},
    "enable_websocket": ${ENABLE_WEBSOCKET:-false}
EOF
    # Conditionally include IDENTITIES if not empty
    if [ -n "$IDENTITIES" ]; then
        echo ",    \"identities\": $IDENTITIES"
    fi

    # Conditionally include BINDKEYS if not empty
    if [ -n "$BINDKEYS" ]; then
        echo ",    \"bindkeys\": $BINDKEYS"
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
} > $CONFIG

cat $CONFIG


python3 -m TheengsGateway $PARAMS
