#!/bin/bash

# List of critical processes to monitor
CRITICAL_PROCESSES=("apache2" "ssh" "mariadb")

# Email settings
ALERT_EMAIL="admin@mycomp.com"

# Log file
LOGFILE="/var/log/process_monitor.log"

# Function to check and restart processes
check_process() {
    local process=$1
    if ! systemctl is-active --quiet "$process"
    then
        echo "$(date) - $process is not running." | tee -a "$LOGFILE"
        echo "Alert: $process has stopped running!" | mail -s "$process alert" "$ALERT_EMAIL"
        
        # Attempt to restart the process
        echo "$(date) - Attempting to restart $process..." | tee -a "$LOGFILE"
        systemctl restart "$process"
        
        if systemctl is-active --quiet "$process"
        then
            echo "$(date) - $process restarted successfully." | tee -a "$LOGFILE"
        else
            echo "$(date) - Failed to restart $process." | tee -a "$LOGFILE"
        fi
    else
        echo "$(date) - $process is running." | tee -a "$LOGFILE"
    fi
}

# Main loop to check each process
for process in "${CRITICAL_PROCESSES[@]}"
do
    check_process "$process"
done
