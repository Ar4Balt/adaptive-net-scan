#!/bin/bash

# Запуск сканирования через Nmap
run_nmap_scan() {
    local target=$1
    local output=$2
    
    local nmap_flags=(-T$TIMING)
    [ -n "$PROXY" ] && nmap_flags+=(--proxies "$PROXY")
    [ "$SCAN_TYPE" == "stealth" ] && nmap_flags+=(--scan-delay "$JITTER" -f)
    [ -n "$PORTS" ] && nmap_flags+=(-p "$PORTS")
    [ -n "$OS_DETECT" ] && nmap_flags+=("$OS_DETECT")
    [ -n "$SERVICE_DETECT" ] && nmap_flags+=("$SERVICE_DETECT")
    
    log "Запуск Nmap с параметрами: ${nmap_flags[*]}"
    nmap "${nmap_flags[@]}" "$target" > "$output"
}