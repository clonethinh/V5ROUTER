#!/bin/sh

# === CẤU HÌNH ===
TARGET_DIR="/www/em9190"
PORT=9090
CGI_SRC="./cgi-bin"

echo "===================================="
echo "[🚀] BẮT ĐẦU TRIỂN KHAI EM9190 SMS UI"
echo "===================================="

# === 1. TẠO THƯ MỤC ĐÍCH ===
echo "[*] Kiểm tra thư mục $TARGET_DIR..."
mkdir -p "$TARGET_DIR/cgi-bin"

# === 2. SAO CHÉP FILE HTML/CSS/JS/CGI ===
echo "[*] Sao chép file HTML, CSS, JS, CGI..."
cp -v sms.html style.css script.js "$TARGET_DIR/" 2>/dev/null
cp -v "$CGI_SRC"/* "$TARGET_DIR/cgi-bin/" 2>/dev/null
chmod +x "$TARGET_DIR/cgi-bin/"*

# === 3. CẤU HÌNH UHTTPD TRÊN CỔNG MỚI ===
echo "[*] Cấu hình uhttpd chạy cổng $PORT..."
uci set uhttpd.main.listen_http="0.0.0.0:$PORT"
uci set uhttpd.main.home="$TARGET_DIR"
uci commit uhttpd
/etc/init.d/uhttpd restart

# === 4. TỰ ĐỘNG KIỂM TRA & CÀI GÓI THIẾU ===
check_or_install() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[-] Thiếu: $1 ❌ → Cài đặt..."
        opkg update
        opkg install "$1"
        if command -v "$1" >/dev/null 2>&1; then
            echo "[+] Đã cài $1 thành công ✅"
        else
            echo "[!] Không thể cài $1 ❌ Vui lòng kiểm tra kết nối mạng hoặc kho opkg."
        fi
    else
        echo "[✓] Đã có: $1 ✅"
    fi
}

echo "[*] Kiểm tra & cài đặt các gói cần thiết..."
check_or_install mmcli
check_or_install uhttpd
check_or_install jq
check_or_install ModemManager

# === 5. KHỞI ĐỘNG DỊCH VỤ NẾU CHƯA CHẠY ===
for svc in uhttpd ModemManager; do
    if ! pgrep "$svc" >/dev/null 2>&1; then
        echo "[*] Dịch vụ $svc chưa chạy → khởi động..."
        /etc/init.d/"$svc" start
    fi
done

# === 6. KIỂM TRA MODEM EM9190 ===
echo "[*] Kiểm tra modem EM9190..."
MODEM_FOUND=""
for ID in $(mmcli -L 2>/dev/null | grep -oE '/Modem/[0-9]+' | cut -d/ -f3); do
    MODEL=$(mmcli -m "$ID" | grep 'model:' | awk -F ':' '{print $2}' | xargs)
    if echo "$MODEL" | grep -qi "EM9190"; then
        MODEM_FOUND="$ID"
        echo "[✓] Tìm thấy EM9190 tại Modem ID $ID ✅"
        break
    fi
done

if [ -z "$MODEM_FOUND" ]; then
    echo "[-] Không thấy EM9190. Thử restart ModemManager..."
    /etc/init.d/ModemManager restart
    sleep 3
    mmcli -L
fi

# === 7. HOÀN TẤT ===
echo "===================================="
echo "[✅] Cài đặt hoàn tất!"
echo "🔗 Truy cập giao diện tại: http://<router-ip>:$PORT/sms.html"
echo "===================================="
