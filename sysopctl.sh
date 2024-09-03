#!/bin/bash

# Define the version of the script
VERSION="v0.1.0"

# Display the help message
show_help() {
    cat <<EOF
Usage: sysopctl [OPTIONS] COMMAND [ARGUMENTS]

Manage system resources and tasks.

Options:
  -h, --help        Show this help message and exit
  --version         Show the version of sysopctl

Commands:
  service list      List all running services
  system load       View current system load
  service start     Start a specified service
  service stop      Stop a specified service
  disk usage        Check disk usage
  process monitor   Monitor system processes
  logs analyze      Analyze system logs
  backup <path>     Backup system files to the specified path

Examples:
  sysopctl --help
  sysopctl service list
  sysopctl system load
  sysopctl disk usage
EOF
}

# Display version information
show_version() {
    echo "sysopctl $VERSION"
}

# List running services
list_services() {
    systemctl list-units --type=service
}

# Function to view system load
view_system_load() {
    if command -v uptime &> /dev/null; then
        uptime
    elif command -v wmic &> /dev/null; then
        echo "System Load (using wmic):"
        wmic cpu get loadpercentage
    elif command -v powershell &> /dev/null; then
        echo "System Load (using PowerShell):"
        powershell -command "Get-WmiObject win32_processor | select LoadPercentage"
    else
        echo "System load information is not available on this system."
    fi

}

# Function to start a service
start_service() {
    service_name="$1"
    if [ -z "$service_name" ]; then
        echo "Error: Service name is required."
        exit 1
    fi

    if command -v systemctl &> /dev/null; then
        sudo systemctl start "$service_name"
    elif command -v service &> /dev/null; then
        sudo service "$service_name" start
    elif command -v sc.exe &> /dev/null; then
        sc.exe start "$service_name"
    else
        echo "Error: Service management commands not found."
        exit 1
    fi

    if [ $? -eq 0 ]; then
        echo "Service '$service_name' started successfully."
    else
        echo "Failed to start service '$service_name'."
    fi
}



# Check disk usage
check_disk_usage() {
    df -h
}

# Monitor system processes
monitor_processes() {
    echo "Monitoring system processes:"
    # Use ps as an alternative to top
    ps aux --sort=-%mem | head -n 10
}


# Analyze system logs
analyze_logs() {
    if [[ ! -f "testlog.txt" ]]; then
        echo "Error: Log file testlog.txt not found."
        return 1
    fi

    echo "Analyzing system logs from testlog.txt:"
    tail -n 20 testlog.txt
}

# Backup system files
backup_files() {
    if [ -z "$1" ]; then
        echo "Error: Backup path is required."
        exit 1
    fi
    rsync -av --delete /path/to/important/files/ "$1"
    echo "Backup completed to $1."
}

# Main script execution
if [ "$#" -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    -h|--help)
        show_help
        ;;
    --version)
        show_version
        ;;
    service)
        case "$2" in
            list)
                list_services
                ;;
            start)
                start_service "$3"
                ;;
            stop)
                stop_service "$3"
                ;;
            *)
                echo "Error: Unknown service command."
                exit 1
                ;;
        esac
        ;;
    system)
        case "$2" in
            load)
                view_system_load
                ;;
            *)
                echo "Error: Unknown system command."
                exit 1
                ;;
        esac
        ;;
    disk)
        case "$2" in
            usage)
                check_disk_usage
                ;;
            *)
                echo "Error: Unknown disk command."
                exit 1
                ;;
        esac
        ;;
    process)
        case "$2" in
            monitor)
                monitor_processes
                ;;
            *)
                echo "Error: Unknown process command."
                exit 1
                ;;
        esac
        ;;
    logs)
        case "$2" in
            analyze)
                analyze_logs
                ;;
            *)
                echo "Error: Unknown logs command."
                exit 1
                ;;
        esac
        ;;
    backup)
        backup_files "$2"
        ;;
    *)
        echo "Error: Unknown command."
        show_help
        exit 1
        ;;
esac



