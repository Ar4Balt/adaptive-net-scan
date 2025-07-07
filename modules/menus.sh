#!/bin/bash

# Главное меню
main_menu() {
    while true; do
        clear
        header "ГЛАВНОЕ МЕНЮ"
        
        # Динамическое меню
        menu_options=(
            "Выбор цели сканирования"
            "Настройка параметров сканирования"
            "Настройка скрытности"
            "Запустить сканирование"
            "Управление результатами"
            "Настройки системы"
            "Выход"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) target_menu ;;
            2) scan_params_menu ;;
            3) stealth_params_menu ;;
            4) run_scan ;;
            5) results_menu ;;
            6) system_settings_menu ;;
            7) exit 0 ;;
        esac
    done
}

# Меню выбора цели
target_menu() {
    ...
}

# Меню параметров сканирования
scan_params_menu() {
    ...
}

# Другие меню...