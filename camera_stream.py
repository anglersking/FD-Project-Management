#!/usr/bin/env python3
"""
摄像头流媒体服务器 (MJPEG over HTTP)

运行:
  pip install flask
  python3 camera_stream.py

切换摄像头:
  CAMERA_DEVICE=/dev/video1 python3 camera_stream.py

调节码流（2.4G 建议降低）:
  CAMERA_SIZE=480:270 CAMERA_FPS=10 CAMERA_JPEG_Q=10 python3 camera_stream.py
"""

import os
import signal
import subprocess
import sys
import time
from flask import Flask, Response, render_template_string

app = Flask(__name__)

# 摄像头设备路径（全局，只在这里改；也可用环境变量覆盖）
CAMERA_DEVICE = os.environ.get("CAMERA_DEVICE", "/dev/video0")

# 码流参数（都可用环境变量覆盖）
CAMERA_FPS = int(os.environ.get("CAMERA_FPS", "10"))          # 5/8/10/15...
CAMERA_SIZE = os.environ.get("CAMERA_SIZE", "480:270")        # 320:240 / 480:270 / 640:480
CAMERA_JPEG_Q = int(os.environ.get("CAMERA_JPEG_Q", "10"))    # 2(高质量)~31(低质量)，数值越大越省带宽

ffmpeg_process = None


def init_camera() -> bool:
    if not os.path.exists(CAMERA_DEVICE):
        print(f"错误：未找到摄像头设备 {CAMERA_DEVICE}")
        return False

    try:
        result = subprocess.run(
            ["v4l2-ctl", "-d", CAMERA_DEVICE, "--list-formats-ext"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        if result.stdout.strip():
            print("摄像头支持的格式：")
            print(result.stdout)
        if result.stderr.strip():
            print("v4l2-ctl stderr：")
            print(result.stderr)
    except Exception:
        print("无法获取摄像头格式信息（v4l2-ctl可能未安装）")

    return True


def stop_ffmpeg():
    global ffmpeg_process
    if not ffmpeg_process:
        return
    try:
        ffmpeg_process.terminate()
        ffmpeg_process.wait(timeout=2)
    except Exception:
        try:
            ffmpeg_process.kill()
        except Exception:
            pass
    finally:
        ffmpeg_process = None
        print("ffmpeg进程已停止")


def _drain_stderr(proc: subprocess.Popen) -> str:
    try:
        data = proc.stderr.read() if proc and proc.stderr else b""
        return (data or b"").decode("utf-8", errors="ignore")
    except Exception:
        return ""


def start_ffmpeg() -> bool:
    """启动ffmpeg并输出MJPEG到stdout"""
    global ffmpeg_process

    stop_ffmpeg()

    vf = f"fps={CAMERA_FPS},scale={CAMERA_SIZE}"

    candidates = [
        # 摄像头输出 MJPG（常见）-> 重新编码一次以便控制 q（稳定控制带宽/大小）
        ["ffmpeg", "-hide_banner", "-loglevel", "error",
         "-f", "v4l2", "-input_format", "mjpeg", "-i", CAMERA_DEVICE,
         "-vf", vf,
         "-c:v", "mjpeg", "-q:v", str(CAMERA_JPEG_Q),
         "-f", "mjpeg", "pipe:1"],

        # 摄像头输出 YUYV，转码成 mjpeg
        ["ffmpeg", "-hide_banner", "-loglevel", "error",
         "-f", "v4l2", "-input_format", "yuyv422", "-i", CAMERA_DEVICE,
         "-vf", vf,
         "-c:v", "mjpeg", "-q:v", str(CAMERA_JPEG_Q),
         "-f", "mjpeg", "pipe:1"],

        # 不指定 input_format（兜底）
        ["ffmpeg", "-hide_banner", "-loglevel", "error",
         "-f", "v4l2", "-i", CAMERA_DEVICE,
         "-vf", vf,
         "-c:v", "mjpeg", "-q:v", str(CAMERA_JPEG_Q),
         "-f", "mjpeg", "pipe:1"],
    ]

    for cmd in candidates:
        print(f"尝试命令：{' '.join(cmd)}")
        try:
            ffmpeg_process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                bufsize=0,
            )

            time.sleep(0.3)
            if ffmpeg_process.poll() is None:
                print(f"成功启动ffmpeg进程 (PID: {ffmpeg_process.pid})")
                return True

            err = _drain_stderr(ffmpeg_process)
            print("ffmpeg启动失败，stderr如下：")
            print(err if err.strip() else "(empty stderr)")
            stop_ffmpeg()

        except Exception as e:
            print(f"启动ffmpeg异常：{e}")
            stop_ffmpeg()

    print("所有格式尝试失败")
    return False


def generate_frames():
    global ffmpeg_process

    if not ffmpeg_process or ffmpeg_process.poll() is not None:
        print("ffmpeg进程未运行，尝试启动...")
        if not start_ffmpeg():
            return

    buffer = b""
    try:
        while True:
            chunk = ffmpeg_process.stdout.read(4096)
            if not chunk:
                err = _drain_stderr(ffmpeg_process)
                if err.strip():
                    print("ffmpeg运行中退出，stderr：")
                    print(err)
                break

            buffer += chunk

            while True:
                start = buffer.find(b"\xff\xd8")
                if start == -1:
                    if len(buffer) > 1024 * 1024:
                        buffer = buffer[-1024:]
                    break

                end = buffer.find(b"\xff\xd9", start + 2)
                if end == -1:
                    break

                frame = buffer[start:end + 2]
                buffer = buffer[end + 2:]

                yield (
                    b"--frame\r\n"
                    b"Content-Type: image/jpeg\r\n\r\n" + frame + b"\r\n"
                )
    finally:
        stop_ffmpeg()


@app.route("/video_feed")
def video_feed():
    return Response(generate_frames(), mimetype="multipart/x-mixed-replace; boundary=frame")


@app.route("/snapshot")
def snapshot():
    cmd = [
        "ffmpeg", "-hide_banner", "-loglevel", "error",
        "-f", "v4l2", "-i", CAMERA_DEVICE,
        "-vf", f"scale={CAMERA_SIZE}",
        "-frames:v", "1",
        "-f", "image2pipe",
        "-vcodec", "mjpeg",
        "-q:v", str(CAMERA_JPEG_Q),
        "-",
    ]
    result = subprocess.run(cmd, capture_output=True, timeout=10, check=False)
    if result.returncode == 0 and result.stdout:
        return Response(result.stdout, mimetype="image/jpeg")
    err = (result.stderr or b"").decode("utf-8", errors="ignore")
    return f"无法获取快照：{err}", 500


@app.route("/health")
def health():
    return {
        "status": "ok",
        "device": CAMERA_DEVICE,
        "exists": os.path.exists(CAMERA_DEVICE),
        "fps": CAMERA_FPS,
        "size": CAMERA_SIZE,
        "jpeg_q": CAMERA_JPEG_Q,
    }, 200


@app.route("/stop")
def stop():
    stop_ffmpeg()
    return "服务器已停止，可以安全关闭。", 200


@app.route("/")
def index():
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <title>Camera MJPEG</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 20px; }
          .wrap { max-width: 960px; margin: 0 auto; }
          img { max-width: 100%; border: 1px solid #ddd; }
          code { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; }
          .hint { color:#555; font-size: 14px; }
        </style>
    </head>
    <body>
      <div class="wrap">
        <h2>摄像头实时画面</h2>
        <p>设备：<code>{{device}}</code></p>
        <p class="hint">
          参数：size=<code>{{size}}</code>, fps=<code>{{fps}}</code>, q=<code>{{q}}</code>
        </p>
        <img id="feed" src="/video_feed" width="240" height="240" alt="video feed" />
        <p>
          <a href="/snapshot" target="_blank">snapshot</a> |
          <a href="/health" target="_blank">health</a> |
          <a href="/stop">stop</a>
        </p>
      </div>
      <script>
        const img = document.getElementById('feed');
        img.onerror = () => setTimeout(() => img.src = '/video_feed?_=' + Date.now(), 800);
      </script>
    </body>
    </html>
    """
    return render_template_string(
        html,
        device=CAMERA_DEVICE,
        size=CAMERA_SIZE,
        fps=CAMERA_FPS,
        q=CAMERA_JPEG_Q,
    )


def signal_handler(sig, frame):
    print("\n正在关闭服务器...")
    stop_ffmpeg()
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    print("=" * 60)
    print("📷 摄像头流媒体服务器")
    print(f"设备:  {CAMERA_DEVICE}")
    print(f"参数:  size={CAMERA_SIZE}, fps={CAMERA_FPS}, q={CAMERA_JPEG_Q}")
    print("=" * 60)

    init_camera()
    app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)