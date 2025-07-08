#!/bin/bash

# Версия ПО
show_version() {
    echo -e "${YELLOW}ADAPTIVE-NET-SCAN v$VERSION${NC}"
    echo "Последнее обновление: 2025-07-08"
}

# Конфигурация
VERSION="4.1"
LOG_FILE="$APP_ROOT/output/scan.log"
OUTPUT_DIR="$APP_ROOT/output/results"
TEMP_DIR="/tmp/.cyberscan"
DECRYPT_KEY="default_password_please_change!"

# Параметры по умолчанию
TIMING=4
JITTER="500ms"
PROXY=""
SCAN_TYPE="stealth"
PORTS=""
OS_DETECT="-O"
SERVICE_DETECT="-sV"

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

load_default_config() {
    source "$APP_ROOT/config/default.conf"
    echo -e "${GREEN}Настройки сброшены к значениям по умолчанию${NC}"
    sleep 1
}