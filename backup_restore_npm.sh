#!/bin/bash

# === CONFIG ===
USER_HOME="$HOME"
USER_NAME="$USER"
NPM_DIR="$USER_HOME/nginx-proxy-manager"
BACKUP_BASE="$USER_HOME/backup/npm"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEFAULT_BACKUP="$BACKUP_BASE/$TIMESTAMP"

echo "== NGINX Proxy Manager Backup & Restore =="

read -p "Bạn muốn làm gì? [backup/restore]: " action

if [[ "$action" == "backup" ]]; then
    echo "⚠️  Thao tác này sẽ dừng container NPM và sao lưu dữ liệu."
    read -p "Bạn chắc chắn muốn tiếp tục? [y/N]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Đã hủy thao tác."
        exit 0
    fi

    BACKUP_DIR="$DEFAULT_BACKUP"
    mkdir -p "$BACKUP_DIR"

    echo "→ Dừng container..."
    docker compose -f "$NPM_DIR/docker-compose.yml" down

    echo "→ Đang sao lưu..."
    cp -r "$NPM_DIR/data" "$BACKUP_DIR/"
    cp -r "$NPM_DIR/letsencrypt" "$BACKUP_DIR/"
    cp "$NPM_DIR/docker-compose.yml" "$BACKUP_DIR/"

    echo "✅ Đã sao lưu vào: $BACKUP_DIR"

    echo "→ Khởi động lại NPM..."
    docker compose -f "$NPM_DIR/docker-compose.yml" up -d

elif [[ "$action" == "restore" ]]; then
    read -p "Nhập đường dẫn thư mục backup (vd: $DEFAULT_BACKUP): " RESTORE_DIR

    if [[ ! -d "$RESTORE_DIR" ]]; then
        echo "❌ Không tìm thấy thư mục: $RESTORE_DIR"
        exit 1
    fi

    echo "⚠️  Thao tác này sẽ xóa dữ liệu hiện tại và phục hồi từ backup."
    read -p "Bạn chắc chắn muốn tiếp tục? [y/N]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Đã hủy thao tác."
        exit 0
    fi

    echo "→ Dừng container cũ..."
    docker compose -f "$NPM_DIR/docker-compose.yml" down

    echo "→ Xóa dữ liệu cũ..."
    rm -rf "$NPM_DIR/data" "$NPM_DIR/letsencrypt"

    echo "→ Phục hồi dữ liệu..."
    cp -r "$RESTORE_DIR/data" "$NPM_DIR/"
    cp -r "$RESTORE_DIR/letsencrypt" "$NPM_DIR/"
    cp "$RESTORE_DIR/docker-compose.yml" "$NPM_DIR/"

    echo "→ Cấp quyền thư mục cho user $USER_NAME..."
    sudo chown -R "$USER_NAME:$USER_NAME" "$NPM_DIR"

    echo "→ Khởi động lại NPM..."
    docker compose -f "$NPM_DIR/docker-compose.yml" up -d

    echo "✅ Khôi phục hoàn tất từ: $RESTORE_DIR"

else
    echo "❌ Lựa chọn không hợp lệ. Gõ 'backup' hoặc 'restore'"
    exit 1
fi
