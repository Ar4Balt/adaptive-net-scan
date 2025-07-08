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
            # Убираем критическую ошибку для GPG
            [[ "$tool" == "gpg" ]] && 
                error "GPG не установлен! Результаты не будут зашифрованы."
        fi
    done
}

# Загрузка конфига
load_config() {
    if [ -f "$APP_ROOT/config/user.conf" ]; then
        source "$APP_ROOT/config/user.conf"
        log "Загружена пользовательская конфигурация"
    fi
}

auto_detect_network() {
    local interface=$(ip route | awk '/default/ {print $5}' | head -n 1)
    if [ -z "$interface" ]; then
        error "Не удалось определить сетевой интерфейс"
        return 1
    fi
    
    local ip_info=$(ip -o -f inet addr show "$interface" | awk '{print $4}')
    local ip=$(echo "$ip_info" | cut -d'/' -f1)
    local mask=$(echo "$ip_info" | cut -d'/' -f2)
    
    TARGET="${ip%.*}.0/$mask"
    log "Автоопределение сети: $TARGET"
    echo -e "${GREEN}✓ Определена сеть: $TARGET${NC}"
    return 0
}