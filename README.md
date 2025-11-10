# WebRTC 屏幕共享直播系统

## 归档说明

简单 WebRTC 的使用，已经解惑，无精力往此方向扩展的项目，故归档。

这是一个基于WebRTC的屏幕共享直播系统，支持屏幕录制并转换为RTMP和HLS直播流。

## 功能特性

- 基于WebRTC的屏幕捕获
- RTMP直播流输出
- HLS直播流输出
- 支持多码率HLS
- 跨平台Web播放器
- Nginx流媒体服务器集成

## 系统要求

- Ubuntu/Debian Linux系统
- Node.js >= 14.0.0
- Nginx with RTMP module
- FFmpeg

## 运行流程


### 2. 详细流程

1. 推流端：
   - 用户访问 http://localhost/index.html
   - 通过WebRTC API获取屏幕画面
   - WebRTC将画面传输到Node服务器
   - Node服务器使用FFmpeg将WebRTC流转换为RTMP流
   - RTMP流推送到Nginx-RTMP服务器

2. 服务器处理：
   - Nginx-RTMP接收RTMP流（rtmp://localhost/live/stream）
   - 自动将RTMP流转换为HLS格式
   - 在/var/www/html/hls目录下生成：
     * stream.m3u8（播放列表）
     * stream-{序号}.ts（视频片段）

3. 播放端：
   - RTMP直播源：rtmp://localhost/live/stream
   - Nginx-HLS直播源：http://localhost/hls/stream.m3u8
   - Node-HLS直播源：http://localhost/node-hls/node-stream.m3u8
   - 网页播放器：
     * 标准播放器：http://localhost/player.html
     * Node HLS播放器：http://localhost/player-node-hls.html

### 3. 各组件作用

1. 前端（frontend/）：
   - index.html：推流页面
   - player.html：播放页面
   - screen-capture.js：屏幕捕获逻辑
   - player-node-hls.html：Node HLS播放器

2. 后端（backend/）：
   - server.js：WebRTC信令服务器
   - 处理WebRTC连接
   - 转换为RTMP流

3. Nginx：
   - 提供静态文件服务
   - RTMP服务器
   - HLS转换和分发


## 关于rtmp部分

当FFmpeg推送到 `rtmp://localhost/live/stream` 时：

1. 请求处理：
   - 请求发送到nginx的1935端口
   - `/live` 匹配到 application live 配置块
   - `/stream` 作为流名称被nginx-rtmp模块处理

2. nginx-rtmp模块处理：
   - 接收命名为"stream"的RTMP流
   - 根据配置自动生成以下输出：
     * RTMP播放地址：`rtmp://localhost/live/stream`
     * HLS播放列表：`/var/www/html/hls/stream.m3u8`
     * HLS视频片段：`/var/www/html/hls/stream-{序号}.ts`


## Docker部署

### 使用Docker Compose部署

1. 构建并启动服务：
```bash
docker-compose up -d
```

2. 查看日志：
```bash
docker-compose logs -f
```

3. 停止服务：
```bash
docker-compose down
```

### 手动Docker部署

1. 构建镜像：
```bash
docker build -t webrtc-streaming .
```

2. 运行容器：
```bash
docker run -d \
  -p 80:80 \
  -p 1935:1935 \
  -p 3000:3000 \
  --name webrtc-streaming \
  webrtc-streaming
```

### Docker部署注意事项

1. 端口映射：
   - 80: HTTP服务
   - 1935: RTMP服务
   - 3000: WebRTC服务

2. 数据持久化：
   - HLS数据：/var/www/html/hls
   - Node HLS数据：/app/public/node-hls

3. 环境变量：
   - NODE_ENV=production

4. 容器管理：
```bash
# 查看容器日志
docker logs -f webrtc-streaming

# 进入容器
docker exec -it webrtc-streaming bash

# 重启容器
docker restart webrtc-streaming
```


