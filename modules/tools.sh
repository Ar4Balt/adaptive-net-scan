#!/bin/bash

# Проверка необходимых инструментов
check_dependencies() {
    declare -gA TOOLS=(
        ["nmap"]=0
        ["nc"]=0
        ["hping3"]=0
        ["arp-scan"]=0
        ["gpg"]=0
    )
    
    log "Проверка зависимостей..."
    for tool in "${!TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            TOOLS["$tool"]=1
            log "✔ $tool доступен"
        else
            log "✘ $tool не установлен" "WARNING"
        fi
    done
    
    # Критические зависимости
    [[ ${TOOLS["gpg"]} -eq 0 ]] && {
        error "GPG не установлен! Скрипт не может работать без GPG"
        exit 1
    }
}

# Загрузка конфига
load_config() {
    if [ -f "$APP_ROOT/config/user.conf" ]; then
        source "$APP_ROOT/config/user.conf"
        log "Загружена пользовательская конфигурация"
    fi
}