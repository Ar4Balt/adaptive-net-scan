#!/bin/bash

# Запуск сканирования через Nmap
run_nmap_scan() {
    local target=$1
    local output=$2
    
    local nmap_flags=(-T$TIMING)
    
    # Выбор типа сканирования
    case "$SCAN_TYPE" in
        stealth)
            nmap_flags+=(-sS --scan-delay "$JITTER" -f)
            ;;
        full)
            nmap_flags+=(-sT -p-)
            ;;
        udp)
            nmap_flags+=(-sU -T3)
            ;;
        quick)
            nmap_flags+=(-F -T4)
            ;;
        os)
            nmap_flags+=(-O --osscan-limit)
            ;;
        service)
            nmap_flags+=(-sV --version-all)
            ;;
        vuln)
            nmap_flags+=(--script=vuln)
            ;;
        discovery)
            nmap_flags+=(-sn)
            ;;
        *)
            nmap_flags+=(-sS)
            ;;
    esac
    
    [ -n "$PROXY" ] && nmap_flags+=(--proxies "$PROXY")
    [ -n "$PORTS" ] && nmap_flags+=(-p "$PORTS")
    
    log "Запуск Nmap с параметрами: ${nmap_flags[*]}"
    nmap "${nmap_flags[@]}" "$target" > "$output"
}