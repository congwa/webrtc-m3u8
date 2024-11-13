#!/bin/bash

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用sudo运行此脚本"
    exit 1
fi

# 安装依赖
apt update
apt install -y nginx libnginx-mod-rtmp nodejs npm ffmpeg

# 创建目录
mkdir -p /var/www/html/hls
chown -R www-data:www-data /var/www/html

# 安装node依赖
cd /path/to/project  # 替换为实际项目路径
npm install

echo "安装完成！"
echo "请运行 sudo ./start.sh 启动服务" 