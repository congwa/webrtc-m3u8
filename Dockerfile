# 使用Node.js官方镜像作为基础镜像
FROM node:14

# 安装FFmpeg和Nginx
RUN apt-get update && apt-get install -y \
    ffmpeg \
    nginx \
    libnginx-mod-rtmp \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装Node.js依赖
RUN npm install

# 复制项目文件
COPY . .

# 创建必要的目录
RUN mkdir -p /var/www/html/hls \
    && mkdir -p /app/public/node-hls

# 复制前端文件到Nginx目录
RUN cp frontend/*.html /var/www/html/ \
    && cp frontend/*.js /var/www/html/

# 复制Nginx配置
RUN cp nginx/nginx.conf /etc/nginx/nginx.conf

# 设置权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 暴露端口
EXPOSE 80 1935 3000

# 复制启动脚本
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# 设置启动命令
ENTRYPOINT ["/docker-entrypoint.sh"] 