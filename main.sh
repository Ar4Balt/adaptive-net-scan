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
        
        # Добавляем команды в список доступных
        for scan_type in "${PLUGIN_SCAN_TYPES[@]}"; do
            AVAILABLE_SCAN_TYPES+=("$scan_type")
        done
        
        log "Загружен плагин: $PLUGIN_NAME"
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