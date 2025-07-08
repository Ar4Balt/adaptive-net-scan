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
            4) run_scan_wrapper ;;
            5) results_menu ;;
            6) system_settings_menu ;;
            7) exit 0 ;;
        esac
        
        # Добавляем небольшую задержку для стабильности
        sleep 0.5
    done
}

# Обертка для функции сканирования
run_scan_wrapper() {
    run_scan
    read -p "Нажмите Enter для возврата в меню..."
}

# Меню выбора цели
target_menu() {
    while true; do
        clear
        header "ВЫБОР ЦЕЛИ СКАНИРОВАНИЯ"
        
        menu_options=(
            "Одиночный IP-адрес"
            "Диапазон CIDR"
            "Список IP-адресов из файла"
            "Автоопределение локальной сети"
            "Назад"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) 
                read -p "Введите IP-адрес: " target
                if validate_ip "$target"; then
                    TARGET="$target"
                    return
                else
                    error "Неверный формат IP-адреса"
                    sleep 1
                fi
                ;;
            2)
                read -p "Введите CIDR (например, 192.168.1.0/24): " cidr
                if [[ $cidr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]{1,2}$ ]]; then
                    TARGET="$cidr"
                    return
                else
                    error "Неверный формат CIDR"
                    sleep 1
                fi
                ;;
            3)
                read -p "Введите путь к файлу: " file
                if [ -f "$file" ]; then
                    TARGET="$file"
                    return
                else
                    error "Файл не существует"
                    sleep 1
                fi
                ;;
            4)
                if auto_detect_network; then
                    return
                else
                    sleep 1
                fi
                ;;
            5)
                return
                ;;
        esac
    done
}

# Меню параметров сканирования
scan_params_menu() {
    while true; do
        clear
        header "НАСТРОЙКА ПАРАМЕТРОВ СКАНИРОВАНИЯ"
        
        # Доступные типы сканирования с описанием
        local scan_types=(
            "stealth|Скрытное сканирование (SYN)"
            "full|Полное сканирование (TCP Connect)"
            "udp|UDP сканирование"
            "quick|Быстрое сканирование (топ портов)"
            "os|Определение ОС"
            "service|Определение версий сервисов"
            "vuln|Проверка на уязвимости"
            "discovery|Только обнаружение хостов"
        )
        
        # Формируем список для меню
        menu_options=(
            "Тип сканирования: $SCAN_TYPE"
            "Порты: ${PORTS:-по умолчанию}"
            "Назад"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) 
                clear
                header "ВЫБОР ТИПА СКАНИРОВАНИЯ"
                
                echo -e "${YELLOW}Доступные типы сканирования:${NC}"
                for i in "${!scan_types[@]}"; do
                    local type=${scan_types[$i]%%|*}
                    local desc=${scan_types[$i]#*|}
                    printf "%-10s - %s\n" "$type" "$desc"
                done
                
                while true; do
                    read -p "Введите тип сканирования: " new_type
                    
                    # Проверяем корректность ввода
                    valid=false
                    for st in "${scan_types[@]}"; do
                        if [ "${st%%|*}" == "$new_type" ]; then
                            valid=true
                            break
                        fi
                    done
                    
                    if $valid; then
                        SCAN_TYPE="$new_type"
                        break
                    else
                        error "Неверный тип сканирования. Попробуйте снова."
                    fi
                done
                ;;
            2)
                read -p "Введите порты (через запятую или диапазон): " PORTS
                ;;
            3)
                return
                ;;
        esac
    done
}

# Меню настройки скрытности
stealth_params_menu() {
    while true; do
        clear
        header "НАСТРОЙКА СКРЫТНОСТИ"
        
        menu_options=(
            "Уровень времени: $TIMING"
            "Задержка: $JITTER"
            "Прокси: ${PROXY:-не используется}"
            "Назад"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) 
                read -p "Введите уровень времени (0-5): " timing
                if [[ $timing =~ ^[0-5]$ ]]; then
                    TIMING="$timing"
                else
                    error "Неверное значение. Должно быть от 0 до 5"
                    sleep 1
                fi
                ;;
            2)
                read -p "Введите задержку (например, 500ms): " jitter
                JITTER="$jitter"
                ;;
            3)
                read -p "Введите адрес прокси (например, socks5://127.0.0.1:9050): " proxy
                PROXY="$proxy"
                ;;
            4)
                return
                ;;
        esac
    done
}

# Меню управления результатами
results_menu() {
    while true; do
        clear
        header "УПРАВЛЕНИЕ РЕЗУЛЬТАТАМИ"
        
        menu_options=(
            "Просмотреть последний результат"
            "Показать все результаты"
            "Экспорт результатов"
            "Удалить результаты"
            "Назад"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) view_last_result ;;
            2) list_all_results ;;
            3) export_results ;;
            4) delete_results ;;
            5)
                return
                ;;
        esac
    done
}

# Меню настроек системы
system_settings_menu() {
    while true; do
        clear
        header "НАСТРОЙКИ СИСТЕМЫ"
        
        menu_options=(
            "Путь для результатов: $OUTPUT_DIR"
            "Ключ шифрования: ${DECRYPT_KEY:0:4}****"
            "Сбросить настройки"
            "Проверить обновления"
            "Назад"
        )
        
        create_menu "${menu_options[@]}"
        
        case $SELECTED in
            1) 
                read -p "Введите новый путь: " path
                if [ -d "$path" ]; then
                    OUTPUT_DIR="$path"
                else
                    error "Директория не существует"
                    sleep 1
                fi
                ;;
            2)
                read -sp "Введите новый ключ шифрования: " new_key
                echo
                DECRYPT_KEY="$new_key"
                ;;
            3)
                read -p "Вы уверены? [y/N] " choice
                if [[ $choice =~ ^[Yy]$ ]]; then
                    load_default_config
                fi
                ;;
            4)
                check_for_updates
                ;;
            5)
                return
                ;;
        esac
    done
}

# Заглушки для функций, которые мы реализуем позже
view_last_result() {
    echo "Просмотр последнего результата..."
    read -p "Нажмите Enter для продолжения..."
}

list_all_results() {
    echo "Список всех результатов..."
    read -p "Нажмите Enter для продолжения..."
}

export_results() {
    echo "Экспорт результатов..."
    read -p "Нажмите Enter для продолжения..."
}

delete_results() {
    echo "Удаление результатов..."
    read -p "Нажмите Enter для продолжения..."
}

check_for_updates() {
    echo "Проверка обновлений..."
    read -p "Нажмите Enter для продолжения..."
}