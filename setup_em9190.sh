#!/bin/sh

# Chuyển vào thư mục tạm trước khi thực hiện
cd /tmp

# Cập nhật danh sách gói opkg
opkg update

# Tạo thư mục nếu chưa có
mkdir -p /www/em9190
mkdir -p /www/em9190/cgi-bin

# Tải file style, html, js
wget -O /www/em9190/style.css https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/style.css
wget -O /www/em9190/sms.html https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/sms.html
wget -O /www/em9190/script.js https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/script.js

# Tải file CGI
wget -O /www/em9190/cgi-bin/sms-send https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/cgi-bin/sms-send
wget -O /www/em9190/cgi-bin/sms-read https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/cgi-bin/sms-read
wget -O /www/em9190/cgi-bin/sms-mark-read https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/cgi-bin/sms-mark-read
wget -O /www/em9190/cgi-bin/sms-delete https://raw.githubusercontent.com/clonethinh/V5ROUTER/refs/heads/main/cgi-bin/sms-delete

# Cấp quyền thực thi cho CGI
chmod +x /www/em9190/cgi-bin/*

# Kiểm tra và cài đặt các thành phần cần thiết nếu chưa có
opkg list-installed | grep modemmanager || opkg install modemmanager
opkg list-installed | grep jq || opkg install jq
opkg list-installed | grep uhttpd || opkg install uhttpd

# Đổi cổng uhttpd sang 9090 và khởi động lại
sed -i 's/listen_http.*/listen_http 0.0.0.0:9090/' /etc/config/uhttpd
/etc/init.d/uhttpd restart

echo "Hoàn thành thiết lập SMS Manager Pro."
