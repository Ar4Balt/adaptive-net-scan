#!/bin/bash

# Запуск сканирования
run_scan() {
    [ -z "$TARGET" ] && {
        error "Цель сканирования не установлена"
        return 1
    }

    local scan_id=$(generate_uuid)
    local tmp_file="$TEMP_DIR/scan_$scan_id.tmp"
    
    log "Начало сканирования ID: $scan_id"
    
    # Выбор метода сканирования с правильным синтаксисом case
    case "$SCAN_TYPE" in
        nmap*)
            run_nmap_scan "$TARGET" "$tmp_file"
            ;;
        netcat | nc)
            run_netcat_scan "$TARGET" "$tmp_file"
            ;;
        tcpping | hping)
            run_hping_scan "$TARGET" "$tmp_file"
            ;;
        *)
            # Если все плагины недоступны, используем базовый метод
            if [ ${#AVAILABLE_SCAN_TYPES[@]} -eq 0 ]; then
                run_basic_scan "$TARGET" "$tmp_file"
            else
                error "Неизвестный тип сканирования: $SCAN_TYPE"
                return 1
            fi
            ;;
    esac
    
    # Обработка результатов
    process_results "$tmp_file" "$scan_id"
    log "Сканирование $scan_id завершено"
}

# Обработка результатов
process_results() {
    local tmp_file=$1
    local scan_id=$2
    local output_file="$OUTPUT_DIR/result_$scan_id.gpg"
    
    # Если установлен GPG, шифруем, иначе просто сохраняем
    if command -v gpg &> /dev/null && [ -n "$DECRYPT_KEY" ]; then
        encrypt_file "$tmp_file" "$output_file"
        shred_file "$tmp_file"
        add_to_index "$scan_id" "$output_file"
    else
        # Без шифрования
        output_file="$OUTPUT_DIR/result_$scan_id.txt"
        mv "$tmp_file" "$output_file"
        add_to_index "$scan_id" "$output_file"
        log "Результаты сохранены без шифрования: $output_file"
    fi
}

# Базовое сканирование (fallback)
run_basic_scan() {
    local target=$1
    local output=$2
    
    log "Запуск базового сканирования с помощью встроенных инструментов"
    echo -e "${YELLOW}[*] Базовое сканирование начато...${NC}"
    
    echo "Результаты базового сканирования: $target" > "$output"
    echo "========================================" >> "$output"
    
    # Простая проверка доступности хоста
    if ping -c 1 -W 1 "$target" &> /dev/null; then
        echo "Хост $target доступен (ICMP)" >> "$output"
        echo -e "${GREEN}[+] Хост $target доступен${NC}"
    else
        echo "Хост $target недоступен" >> "$output"
        echo -e "${RED}[-] Хост $target недоступен${NC}"
    fi
    
    echo "========================================" >> "$output"
    echo "Сканирование выполнено: $(date)" >> "$output"
    log "Базовое сканирование завершено"
}