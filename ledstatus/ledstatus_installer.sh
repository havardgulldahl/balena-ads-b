#!/usr/bin/env bash
set -e

# Check to see if we need to install bluld, to support BlinkStick

function install_bluld {

    # https://github.com/ktgeek/bluld?tab=readme-ov-file#making
    cd /tmp;
    curl -O https://github.com/ktgeek/bluld/archive/refs/tags/v1.1.2.tar.gz
    tar -xvf v1.1.2.tar.gz
    cd bluld-1.1.2
    cmake .
    make
}

function install_ledstatus_daemon {

    # the ledstatus daemon is a shell script that writes to /sys/class/leds/led0/brightness, based on system status
    # type out the full script here as a HERE document, and install to /usr/local/sbin/ledstatus-daemon

    cat << 'EOF' > /usr/local/sbin/ledstatus-daemon
#!/usr/bin/env bash
set -e

# This script writes to /sys/class/leds/led0/brightness to indicate system status
# The script is intended to be run as a daemon, and will loop indefinitely

# Define the path to the LED device
LED_PATH="/sys/class/leds/led0/brightness"

# Define the LED status values
LED_OFF=0
LED_ON=1

# Define the LED status colors
LED_RED=1
LED_GREEN=2
LED_YELLOW=3

# Define the LED status patterns
LED_SOLID=1
LED_BLINK=2

# Define the LED status
LED_STATUS=$LED_OFF

# Define the LED color
LED_COLOR=$LED_RED

# Define the LED pattern
LED_PATTERN=$LED_SOLID

# Define the LED blink rate
LED_BLINK_RATE=1

# If the LED device is not present, exit
if [ ! -e "$LED_PATH" ]; then
    echo "LED device not found, exiting..."
    exit 1
fi

# Function to set the LED status
function set_led_status {
    echo $1 > $LED_PATH
}

# function to check if supervisor is running
function check_supervisor {
    status=$(curl --header "Content-Type:application/json" "$BALENA_SUPERVISOR_ADDRESS/ping?apikey=$BALENA_SUPERVISOR_API_KEY");
    if [ "$status" = "OK" ]; then
        return 0
    else
        return 1
    fi
}

#function to get supervisor application states
function get_supervisor_applications {
    state=$(curl --header "Content-Type:application/json" "$BALENA_SUPERVISOR_ADDRESS/v2/applications/state?apikey=$BALENA_SUPERVISOR_API_KEY");
    echo $state
    

}

echo "Checking if we need to install bluld to support BlinkStick..."

# run lsusb to see if there is a BlinkStick device

if lsusb | grep -q "20a0:41e5"; then
    echo "BlinkStick device detected, checking if bluld is installed..."
    if ! command -v bluld &> /dev/null
    then
        echo "bluld is not installed, installing..."
        install_bluld
    else
        echo "bluld is already installed, skipping..."
    fi
else
    echo "No BlinkStick device detected, skipping bluld installation..."
fi


EOF