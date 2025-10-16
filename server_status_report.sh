# Server Status Report Script (server_status_report.sh)
#
# Version: 1.0.0
# Author: Salustiano Silva
# Repository: https://github.com/zuul/Server-Status-Reporter
# Description: Gathers key server status metrics (disk, load, services) and sends them in a readable email report.
#
# Usage:
#   bash server_status_report.sh --recipient <email> [--output <mode>] [--mailer <program>]
#   e.g., ./server_status_report.sh --recipient alerts@domain.com --output console --mailer mail
#
# Dependencies: df, free, uptime, awk, grep, sed, systemctl/service, mail/sendmail
#

# --- Configuration ---
# Services to check (use the exact name used by systemctl or service)
SERVICES=("postfix" "dovecot" "mysql" "apache2")

# --- Report Components ---

# Function to generate a Unicode progress bar
# Usage: generate_progress_bar <percentage>
generate_progress_bar() {
    local percent=$1
    local filled_blocks=$((percent / 10))
    local empty_blocks=$((10 - filled_blocks))
    local bar=""
    local i

    for ((i=0; i<filled_blocks; i++)); do
        bar="${bar}▰" # Solid block
    done
    for ((i=0; i<empty_blocks; i++)); do
        bar="${bar}▱" # Empty block
    done
    echo "${bar} ${percent}% total used"
}

# Function to format section headers
# Usage: format_header <title>
format_header() {
    local title="$1"
    echo ""
    echo "${title}"
    echo "--------------------------------------------------"
}

# ----------------------------------------
# CORE REPORTING FUNCTIONS
# ----------------------------------------

get_disk_usage() {
    local report=""
    local usage_data=$(df -h / | tail -n 1)

    # Extract relevant fields from df -h output
    local capacity=$(echo "$usage_data" | awk '{print $2}')
    local used=$(echo "$usage_data" | awk '{print $3}')
    local available=$(echo "$usage_data" | awk '{print $4}')
    local percent_used_str=$(echo "$usage_data" | awk '{print $5}' | sed 's/%//')

    # Convert percentage to integer for the bar
    local percent_used=$(printf "%.0f\n" "$percent_used_str")

    report+="$(format_header "Disk Space Usage (Root Filesystem /)")\n"
    report+="Storage Capacity: ${capacity}\n"
    report+="Storage Used: ${used}\n"
    report+="Storage Available: ${available}\n\n"
    report+="$(generate_progress_bar "$percent_used")\n"

    echo -e "$report"
}

get_system_uptime() {
    local report=""
    local uptime_info=$(uptime -p)

    report+="$(format_header "System Uptime")\n"
    report+="Uptime: ${uptime_info}\n"

    echo -e "$report"
}

get_server_load() {
    local report=""
    local cpu_load=$(uptime | awk -F'load average: ' '{print $2}')

    # --- RAM Usage (Using free -h for human-readable output) ---
    local ram_line=$(free -h | grep Mem | head -n 1)

    # Use awk to get the total and used values without the unit, assuming a standard free -h output structure
    local ram_total_h=$(echo "$ram_line" | awk '{print $2}')
    local ram_used_h=$(echo "$ram_line" | awk '{print $3}')
    local ram_free_h=$(echo "$ram_line" | awk '{print $4}')

    # To get percentage, we must use a unit-less value, preferably in MB (from free -m)
    # Get total and used in MB for calculation
    local ram_line_m=$(free -m | grep Mem | head -n 1)
    local ram_total_m=$(echo "$ram_line_m" | awk '{print $2}')
    local ram_used_m=$(echo "$ram_line_m" | awk '{print $3}')

    # Calculate percentage using integer arithmetic
    # (Used RAM * 100) / Total RAM
    if [ "$ram_total_m" -gt 0 ]; then
        local ram_percent=$(( (ram_used_m * 100) / ram_total_m ))
    else
        local ram_percent=0
    fi

    report+="$(format_header "Server Load (CPU & RAM)")\n"
    report+="CPU Load Averages (1m, 5m, 15m): ${cpu_load}\n\n"
    report+="RAM Total: ${ram_total_h}\n"
    report+="RAM Used (including cache/buffer): ${ram_used_h}\n"
    report+="RAM Free: ${ram_free_h}\n\n"
    report+="$(generate_progress_bar "$ram_percent")\n"

    echo -e "$report"
}

get_service_status() {
    local report=""
    local service_report=""
    local service_name
    local status

    report+="$(format_header "Service Status")\n"

    for service_name in "${SERVICES[@]}"; do
        # Use systemctl if available, fall back to service
        if command -v systemctl &> /dev/null; then
            if systemctl is-active --quiet "$service_name"; then
                status="UP (Active)"
            else
                status="DOWN (Inactive or Failed)"
            fi
        elif command -v service &> /dev/null; then
            if service "$service_name" status &> /dev/null; then
                status="UP (Running)"
            else
                status="DOWN (Not Running)"
            fi
        else
            status="UNKNOWN (Requires systemctl or service)"
        fi
        service_report+="[${status}] ${service_name}\n"
    done

    report+="${service_report}\n"
    echo -e "$report"
}

# ----------------------------------------
# SCRIPT EXECUTION
# ----------------------------------------

# --- Variables ---
RECIPIENT=""
OUTPUT_MODE="email"
MAILER="sendmail"

# Function to show help and usage details
show_help() {
    cat << EOF

# Server Status Report Script (server_status_report.sh)

Version: 1.0.0
Author: Salustiano Silva
Repository: https://github.com/zuul/Server-Status-Reporter

Description: Gathers key server status metrics (disk, load, services) and sends them in a readable email report.

Usage:
  bash server_status_report.sh --recipient <email> [--output <mode>] [--mailer <program>]

Arguments:
| Argument     | Status  | Options          | Default  | Description |
|--------------|---------|------------------|----------|----------------------------------------------------------|
| --recipient  | MANDATORY | Email Address  | N/A      | The email address to send the report to.                 |
| --output     | Optional| email, console   | email    | Determines if the report is emailed or printed to console.|
| --mailer     | Optional| mail, sendmail   | sendmail | Specifies the email program to use for dispatch.         |
| --help       | Optional| N/A              | N/A      | Show this help message and exit.                         |

Examples:
  ./server_status_report.sh --recipient alerts@domain.com
  ./server_status_report.sh --output console --recipient user@test.local
  ./server_status_report.sh --recipient sysadmin@company.net --mailer mail

EOF
    exit 0
}

# --- Argument Parsing ---
while [ "$#" -gt 0 ]; do
    case "$1" in
        --recipient)
            RECIPIENT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_MODE="$2"
            shift 2
            ;;
        --mailer)
            MAILER="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            show_help
            ;;
    esac
done

# --- Validation ---
if [ -z "$RECIPIENT" ]; then
    echo "Error: Missing mandatory argument --recipient"
    show_help
fi

if [ "$OUTPUT_MODE" != "email" ] && [ "$OUTPUT_MODE" != "console" ]; then
    echo "Error: Invalid value for --output. Must be 'email' or 'console'."
    exit 1
fi

if [ "$MAILER" != "mail" ] && [ "$MAILER" != "sendmail" ]; then
    echo "Error: Invalid value for --mailer. Must be 'mail' or 'sendmail'."
    exit 1
fi

# --- Report Generation ---
SERVER_HOSTNAME=$(hostname)
REPORT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
SUBJECT="[Server Status Report] ${SERVER_HOSTNAME} - ${REPORT_DATE}"

REPORT_CONTENT=""
REPORT_CONTENT+="Server: ${SERVER_HOSTNAME}\n"
REPORT_CONTENT+="Time: ${REPORT_DATE}\n"
REPORT_CONTENT+="==================================================\n"

# Add an extra blank line before each section header for better separation
REPORT_CONTENT+="\n"
REPORT_CONTENT+=$(get_system_uptime)

REPORT_CONTENT+="\n"
REPORT_CONTENT+=$(get_disk_usage)

REPORT_CONTENT+="\n"
REPORT_CONTENT+=$(get_server_load)

REPORT_CONTENT+="\n"
REPORT_CONTENT+=$(get_service_status)


# --- Dispatch ---
if [ "$OUTPUT_MODE" = "console" ]; then
    echo -e "\n--- BEGIN REPORT ---"
    echo -e "Subject: ${SUBJECT}\n"
    echo -e "${REPORT_CONTENT}"
    echo -e "--- END REPORT ---\n"
else
    if [ "$MAILER" = "sendmail" ]; then
        # sendmail requires the headers to be part of the piped content
        {
            echo "Subject: ${SUBJECT}"
            echo "To: ${RECIPIENT}"
            echo "Content-Type: text/plain; charset=utf-8"
            echo ""
            echo -e "${REPORT_CONTENT}"
        } | sendmail -t
    elif [ "$MAILER" = "mail" ]; then
        # mail requires the subject and recipient as arguments
        echo -e "${REPORT_CONTENT}" | mail -s "${SUBJECT}" "${RECIPIENT}"
    fi

    if [ $? -eq 0 ]; then
        echo "Server status report successfully dispatched to ${RECIPIENT} using ${MAILER}."
    else
        echo "Error: Failed to send server status report using ${MAILER}. Check your mailer configuration." >&2
        exit 1
    fi
fi

exit 0
# End of script