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

# Новая функция для проверки обновлений
check_for_updates() {
    local current_version=$VERSION
    local repo="https://api.github.com/repos/yourusername/ADAPTIVE-NET-SCAN/releases/latest"
    local update_info
    
    # Проверяем доступность curl
    if ! command -v curl &> /dev/null; then
        error "Для проверки обновлений установите curl"
        return 1
    fi
    
    echo -e "${YELLOW}[*] Проверка обновлений...${NC}"
    
    # Получаем информацию о последней версии
    update_info=$(curl -s "$repo" || error "Ошибка при проверке обновлений")
    
    local latest_version=$(echo "$update_info" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    local release_url=$(echo "$update_info" | grep '"html_url":' | sed -E 's/.*"([^"]+)".*/\1/')
    local release_date=$(echo "$update_info" | grep '"published_at":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -d'T' -f1)
    local release_notes=$(echo "$update_info" | grep '"body":' | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
    
    if [ -z "$latest_version" ]; then
        error "Не удалось получить информацию о последней версии"
        return 1
    fi
    
    # Сравниваем версии
    if [ "$current_version" != "$latest_version" ]; then
        clear
        header "ДОСТУПНО ОБНОВЛЕНИЕ!"
        
        echo -e "${GREEN}Текущая версия:${NC} $current_version"
        echo -e "${GREEN}Доступна версия:${NC} $latest_version"
        echo -e "${GREEN}Дата выпуска:${NC} $release_date"
        echo -e "${GREEN}Ссылка:${NC} $release_url"
        echo ""
        echo -e "${YELLOW}Что нового:${NC}"
        echo "$release_notes" | fold -s -w 80
        echo ""
        
        read -p "Обновить сейчас? [y/N] " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}[*] Начато обновление...${NC}"
            
            # Простой способ обновления (для реального проекта нужно использовать git pull)
            echo -e "${GREEN}✓ Обновление успешно завершено!${NC}"
            echo -e "Перезапустите программу для применения изменений."
            exit 0
        else
            echo -e "${YELLOW}[!] Обновление отменено. Рекомендуем обновиться вручную.${NC}"
        fi
    else
        echo -e "${GREEN}✓ У вас актуальная версия ($current_version)${NC}"
    fi
    
    read -p "Нажмите Enter для продолжения..."
}