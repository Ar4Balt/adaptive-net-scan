#!/bin/bash

# Запуск сканирования
run_scan() {
    local target=$1
    local scan_id=$(generate_uuid)
    local tmp_file="$TEMP_DIR/scan_$scan_id.tmp"
    
    log "Начало сканирования ID: $scan_id"
    
    # Выбор метода сканирования
    case $SCAN_TYPE in
        nmap*) run_nmap_scan "$target" "$tmp_file" ;;
        netcat) run_netcat_scan "$target" "$tmp_file" ;;
        tcpping) run_tcpping_scan "$target" "$tmp_file" ;;
        *) error "Неизвестный тип сканирования: $SCAN_TYPE" ;;
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
    
    encrypt_file "$tmp_file" "$output_file"
    shred_file "$tmp_file"
    add_to_index "$scan_id" "$output_file"
}