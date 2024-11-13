# WebRTC 屏幕共享直播系统

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


