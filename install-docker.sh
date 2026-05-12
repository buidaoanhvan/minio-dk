#!/bin/bash

# Ngắt script nếu có lỗi xảy ra
set -e

echo "1. Đang gỡ bỏ các phiên bản Docker cũ (nếu có)..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg || true
done

echo "2. Cập nhật hệ thống và cài đặt các gói hỗ trợ..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo "3. Thiết lập GPG Key chính thức của Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "4. Thêm Docker Repository vào APT sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "5. Đang cài đặt Docker Engine, CLI, Containerd và Docker Compose..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "6. Cấu hình quyền chạy Docker không cần sudo cho user hiện tại ($USER)..."
sudo usermod -aG docker $USER

echo "------------------------------------------------------"
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "🐳 Docker version: $(docker --version)"
echo "🐙 Docker Compose version: $(docker compose version)"
echo "------------------------------------------------------"
echo "⚠️ LƯU Ý: Vui lòng ĐĂNG XUẤT và ĐĂNG NHẬP LẠI để quyền chạy Docker không cần sudo có hiệu lực."