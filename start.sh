#!/bin/bash

echo "开始启动直播推流服务..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用sudo运行此脚本"
    exit 1
fi

# 检查依赖
for cmd in node ffmpeg nginx; do
    if ! command -v $cmd &> /dev/null; then
        echo "错误: 未安装 $cmd，请先安装"
        exit 1
    fi
done

# 创建必要的目录
echo "创建必要的目录..."
mkdir -p /var/www/html/hls
chown -R www-data:www-data /var/www/html

# 复制前端文件到nginx目录
echo "部署前端文件..."
cp frontend/*.html /var/www/html/
cp frontend/*.js /var/www/html/

# 设置正确的权限
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 配置nginx
echo "配置Nginx..."
cp nginx/nginx.conf /etc/nginx/nginx.conf

# 检查nginx配置
nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx配置检查失败"
    exit 1
fi

# 重启nginx
echo "重启Nginx..."
systemctl restart nginx

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "安装项目依赖..."
    npm install express wrtc fluent-ffmpeg path
fi

# 启动Node服务器
echo "启动Node服务器..."
node backend/server.js &
SERVER_PID=$!

echo "服务已启动!"
echo "推流页面: http://localhost/index.html"
echo "播放页面: http://localhost/player.html"
echo "HLS直播源: http://localhost/hls/stream.m3u8"
echo "RTMP直播源: rtmp://localhost/live/stream"
echo ""
echo "按 Ctrl+C 停止服务"

# 清理函数
cleanup() {
    echo "正在停止服务..."
    kill $SERVER_PID
    systemctl stop nginx
    echo "服务已停止"
    exit 0
}

# 注册清理函数
trap cleanup INT

# 等待中断信号
wait 