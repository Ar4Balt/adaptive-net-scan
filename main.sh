#!/bin/bash
# CyberScan - Главный управляющий скрипт
# Автор: Ваш эксперт по кибербезопасности

# Настройка окружения
APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export APP_ROOT

# Загрузка конфигурации
source "$APP_ROOT/config/default.conf"

# Загрузка модулей
for module in "$APP_ROOT"/modules/*.sh; do
    source "$module"
done

# Загрузка библиотек
for lib in "$APP_ROOT"/lib/*.sh; do
    source "$lib"
done

# Загрузка плагинов
load_plugins() {
    for plugin in "$APP_ROOT"/plugins/*_plugin.sh; do
        source "$plugin"
        register_plugin
        
        # Проверяем доступность инструментов для плагина
        local plugin_available=true
        case $PLUGIN_COMMAND in
            nmap) [[ ${TOOLS[nmap]} -eq 0 ]] && plugin_available=false ;;
            netcat) [[ ${TOOLS[nc]} -eq 0 ]] && plugin_available=false ;;
            hping) [[ ${TOOLS[hping3]} -eq 0 ]] && plugin_available=false ;;
        esac
        
        if $plugin_available; then
            # Добавляем команды в список доступных
            for scan_type in "${PLUGIN_SCAN_TYPES[@]}"; do
                AVAILABLE_SCAN_TYPES+=("$scan_type")
            done
            log "Загружен плагин: $PLUGIN_NAME"
        else
            log "Плагин $PLUGIN_NAME отключен (недоступны инструменты)" "WARNING"
            echo -e "${YELLOW}[!] Плагин $PLUGIN_NAME недоступен. Установите $PLUGIN_COMMAND.${NC}" >&2
        fi
    done
}

create_menu() {
    local options=("$@")
    SELECTED=0
    
    while [[ $SELECTED -lt 1 || $SELECTED -gt ${#options[@]} ]]; do
        for i in "${!options[@]}"; do
            local option="${options[$i]}"
            local prefix=" "
            
            # Проверяем доступность функции
            if [[ "$option" == "Запустить сканирование" ]] && [ ${#AVAILABLE_SCAN_TYPES[@]} -eq 0 ]; then
                prefix="${RED}✘${NC} "
            elif [[ "$option" == "Управление результатами" ]] && [ ${TOOLS[gpg]} -eq 0 ]; then
                prefix="${RED}✘${NC} "
            fi
            
            printf "%d. %s%s\n" "$((i+1))" "$prefix" "$option"
        done
        
        read -p "Выберите опцию [1-${#options[@]}]: " SELECTED
    done
}

# Инициализация
init_logging "$LOG_FILE"
check_dependencies
load_config
load_plugins

# Запуск
header "Запуск CyberScan v$VERSION"
main_menu