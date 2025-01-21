#!/usr/bin/env bash
set -e

# Check if service has been disabled through the DISABLED_SERVICES environment variable.

if [[ ",$(echo -e "${DISABLED_SERVICES}" | tr -d '[:space:]')," = *",$BALENA_SERVICE_NAME,"* ]]; then
        echo "$BALENA_SERVICE_NAME is manually disabled. Sending request to stop the service:"
        curl --header "Content-Type:application/json" "$BALENA_SUPERVISOR_ADDRESS/v2/applications/$BALENA_APP_ID/stop-service?apikey=$BALENA_SUPERVISOR_API_KEY" -d '{"serviceName": "'$BALENA_SERVICE_NAME'"}'
        echo " "
        balena-idle
fi

# Verify that all the required variables are set before starting up the application.

echo "Verifying settings..."
echo " "
sleep 2

missing_variables=false
        
# Begin defining all the required configuration variables.
[ -z "$LEDSTATUS_USE_BOTH_SIDES" ] && echo "Led status both sides is missing, will abort startup." && missing_variables=true || echo "Led status use both sides: $LEDSTATUS_USE_BOTH_SIDES"

# End defining all the required configuration variables.

echo " "

if [ "$missing_variables" = true ]
then
        echo "Settings missing, aborting..."
        echo " "
        balena-idle
fi

echo "Settings verified, proceeding with startup."
echo " "

# Variables are verified – continue with startup procedure.

# start bluld to support BlinkStick

if lsusb | grep -q "20a0:41e5"; then
    echo "BlinkStick device detected, starting userland daemon..."
    /usr/local/sbin/bluld 2 aqua indigo 
fi

# start ledstatus client
/usr/local/sbin/ledstatus-client

# Wait for any services to exit.
wait -n
