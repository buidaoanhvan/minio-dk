#!/bin/bash

# Ngắt script nếu có lỗi nghiêm trọng xảy ra
set -e

echo "0. Đang kiểm tra và sửa lỗi trình quản lý gói (dpkg/apt)..."
# Tự động sửa lỗi 'dpkg was interrupted' nếu có
sudo dpkg --configure -a || true
# Sửa lỗi các gói bị hỏng hoặc thiếu phụ thuộc
sudo apt-get install -f -y
sudo apt-get update

echo "1. Đang gỡ bỏ các phiên bản Docker cũ để tránh xung đột..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg || true
done

echo "2. Cài đặt các gói hỗ trợ cần thiết..."
sudo apt-get install -y ca-certificates curl gnupg

echo "3. Thiết lập GPG Key chính thức của Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "4. Thêm Docker Repository vào hệ thống..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "5. Đang cài đặt Docker Engine và Docker Compose Plugin..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "6. Cấu hình quyền chạy Docker (không cần sudo)..."
if [ $(getent group docker) ]; then
    sudo usermod -aG docker $USER
else
    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

echo "------------------------------------------------------"
echo "✅ XỬ LÝ VÀ CÀI ĐẶT THÀNH CÔNG!"
echo "🐳 Docker: $(docker --version)"
echo "🐙 Compose: $(docker compose version)"
echo "------------------------------------------------------"
echo "👉 LƯU Ý: Bạn cần chạy lệnh 'newgrp docker' hoặc đăng xuất rồi đăng nhập lại để sử dụng Docker mà không cần gõ sudo."