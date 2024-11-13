const express = require('express');
const WebRTC = require('wrtc');
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs');
const app = express();

app.use(express.json());

// 创建HLS输出目录
const hlsOutputPath = path.join(__dirname, '../public/node-hls');
if (!fs.existsSync(hlsOutputPath)) {
    fs.mkdirSync(hlsOutputPath, { recursive: true });
}

let streamOutput = null;
let nodeHlsOutput = null;

app.post('/webrtc/offer', async (req, res) => {
  const peerConnection = new WebRTC.RTCPeerConnection({
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' }
    ]
  });

  peerConnection.ontrack = ({track, streams}) => {
    if (!streamOutput) {
      // 第一个FFmpeg命令：输出到RTMP
      const rtmpCommand = ffmpeg()
        .input(streams[0])
        .outputOptions([
          '-c:v libx264',
          '-c:a aac',
          '-preset ultrafast',
          '-f flv'
        ])
        .output('rtmp://localhost/live/stream');

      // 第二个FFmpeg命令：直接输出HLS
      // 创建第二个FFmpeg命令用于HLS输出
      const hlsCommand = ffmpeg()
        .input(streams[0])
        .outputOptions([
          '-c:v libx264',    // 使用H.264编码视频
          '-c:a aac',        // 使用AAC编码音频
          '-preset ultrafast', // 使用最快的编码预设
          '-hls_time 4',     // 每个分片的时长为4秒
          '-hls_list_size 3', // 播放列表中保留3个分片
          '-hls_flags delete_segments', // 自动删除旧的分片文件
          '-f hls'           // 输出格式为HLS
        ])
        .output(path.join(hlsOutputPath, 'node-stream.m3u8')); // 输出m3u8播放列表文件

      streamOutput = rtmpCommand.run();
      nodeHlsOutput = hlsCommand.run();
    }
  };

  await peerConnection.setRemoteDescription(req.body.sdp);
  const answer = await peerConnection.createAnswer();
  await peerConnection.setLocalDescription(answer);
  res.json(peerConnection.localDescription);
});

// 提供HLS文件的静态服务
app.use('/node-hls', express.static(hlsOutputPath));

app.listen(3000, () => {
  console.log('WebRTC服务器运行在端口3000');
  console.log('Node HLS直播源: http://localhost:3000/node-hls/node-stream.m3u8');
});

// 优雅退出处理
process.on('SIGINT', () => {
  if (streamOutput) {
    streamOutput.kill('SIGKILL');
  }
  if (nodeHlsOutput) {
    nodeHlsOutput.kill('SIGKILL');
  }
  process.exit(0);
}); 