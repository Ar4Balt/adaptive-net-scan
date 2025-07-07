#!/bin/bash

# Инициализация логгирования
init_logging() {
    LOG_FILE=${1:-"$APP_ROOT/output/scan.log"}
    mkdir -p "$(dirname "$LOG_FILE")"
    > "$LOG_FILE"
}

# Запись в лог
log() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo -e "[$timestamp][$level] $message" >> "$LOG_FILE"
    
    if [[ "$level" == "ERROR" ]]; then
        echo -e "${RED}$message${NC}" >&2
    elif [[ "$level" == "WARNING" ]]; then
        echo -e "${YELLOW}$message${NC}" >&2
    fi
}

# Логирование ошибок
error() {
    log "$1" "ERROR"
}