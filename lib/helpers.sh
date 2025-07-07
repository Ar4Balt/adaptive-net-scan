#!/bin/bash

# Генерация UUID
generate_uuid() {
    uuidgen | tr -d '-'
}

# Создание меню
create_menu() {
    local options=("$@")
    SELECTED=0
    
    while [[ $SELECTED -lt 1 || $SELECTED -gt ${#options[@]} ]]; do
        for i in "${!options[@]}"; do
            printf "%d. %s\n" "$((i+1))" "${options[$i]}"
        done
        
        read -p "Выберите опцию [1-${#options[@]}]: " SELECTED
    done
}

# Заголовок
header() {
    echo -e "${YELLOW}=============================================${NC}"
    echo -e "${YELLOW} $1 ${NC}"
    echo -e "${YELLOW}=============================================${NC}"
}