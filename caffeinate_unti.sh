#!/bin/bash

# Function to get current battery percentage
get_battery_percentage() {
    # Depending on your system, you might need to modify this command.
    # For macOS, the command below should work.
    pmset -g batt | grep -Eo "\d+%" | cut -d% -f1
}

# Function to display the battery bar
display_battery_bar() {
    local current_percentage=$1
    local bar_length=10
    local filled_length=$((current_percentage * bar_length / 100))
    local empty_length=$((bar_length - filled_length))
    local bar=$(printf '%*s' "$filled_length" '' | tr ' ' '=')
    bar+=$(printf '%*s' "$empty_length" '' | tr ' ' '-')
    echo -ne "\rCurrent Battery [${bar}] ${current_percentage}%"
}

# Default min battery percentage
min_battery=20

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--min-battery) min_battery="$2"; shift ;;
        -*|--*) echo "Unknown option $1"; exit 1 ;;
        *) if [[ -z "$min_battery_arg" ]]; then min_battery_arg=$1; fi ;;
    esac
    shift
done

if [[ ! -z "$min_battery_arg" ]]; then
    min_battery=$min_battery_arg
fi

# Check if the input is a valid number
if ! [[ "$min_battery" =~ ^[0-9]+$ ]]; then
    echo "Error: Minimum battery percentage must be a number."
    exit 1
fi

# Start caffeinate in the background
caffeinate -di &
caffeinate_pid=$!

# Clean up function
cleanup() {
    echo -e "\nExiting. Stopping caffeinate."
    kill $caffeinate_pid
    exit 0
}

# Trap SIGINT and SIGTERM for cleanup
trap cleanup SIGINT SIGTERM

# Main loop
echo "Preventing sleep until battery goes below ${min_battery}%."
while true; do
    current_battery=$(get_battery_percentage)
    
    if [[ $current_battery -lt $min_battery ]]; then
        echo -e "\nBattery has dropped below ${min_battery}%. Exiting."
        cleanup
    fi
    
    display_battery_bar $current_battery
    sleep 10
done
