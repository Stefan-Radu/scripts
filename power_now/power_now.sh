#! /usr/bin/env sh

BASE_PATH='/sys/class/power_supply/BAT0/'

function get_power_now() {
    local power_now=""

    if [ -f "$BASE_PATH/power_now" ]; then
        power_now=$(cat "$BASE_PATH/power_now")
        power_now=$(echo "scale=2; ${power_now}" \
            " / 10 ^ 6" | bc)

    elif [ -f "$BASE_PATH/current_now" ] \
        && [ -f "$BASE_PATH/voltage_now" ]; then

        # micro amps
        current_now=$(cat "$BASE_PATH/current_now")
        # micro volts
        voltage_now=$(cat "$BASE_PATH/voltage_now")
        # divide by 10 ^ 12 to get watts
        power_now=$(echo "scale=2; ${current_now}" \
            " * ${voltage_now}" \
            " / 10 ^ 12" | bc)
    fi

    echo "$power_now"
}

while :
do
    power_now=$(get_power_now)

    [ -n "$power_now" ] \
        && printf "\rPower usage: %.2fW" $power_now \
        || { echo -n "Power levels unavailalble"; exit 1; }

    sleep 1;
done
