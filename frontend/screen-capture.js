const peerConnection = new RTCPeerConnection({
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' }
  ]
});

async function startScreenCapture() {
  try {
    // 获取屏幕媒体流
    const stream = await navigator.mediaDevices.getDisplayMedia({
      video: true,
      audio: true
    });

    // 添加轨道到peer connection
    stream.getTracks().forEach(track => {
      peerConnection.addTrack(track, stream);
    });

    // 创建offer
    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    // 发送offer到服务器
    const response = await fetch('/webrtc/offer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        sdp: peerConnection.localDescription
      })
    });

    // 设置服务器返回的answer
    const answer = await response.json();
    await peerConnection.setRemoteDescription(answer);
  } catch (err) {
    console.error('错误:', err);
  }
} 