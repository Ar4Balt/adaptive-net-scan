#!/bin/bash

# Шифрование файла
encrypt_file() {
    local input=$1
    local output=$2
    
    gpg --batch --passphrase "$DECRYPT_KEY" \
        --symmetric --cipher-algo AES256 \
        -o "$output" "$input"
        
    log "Файл зашифрован: $output"
}

# Расшифровка файла
decrypt_file() {
    local input=$1
    
    gpg --batch --passphrase "$DECRYPT_KEY" \
        -d "$input" 2>/dev/null
}

# Уничтожение файла
shred_file() {
    local file=$1
    shred -u -z -n 7 "$file"
    log "Файл уничтожен: $file"
}