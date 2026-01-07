# Media Processing Skill

> 综合自 FFmpeg、ImageMagick 和多媒体处理最佳实践，已适配 TAD 框架

## 触发条件

当用户需要处理音频、视频、图片格式转换、压缩、剪辑或生成媒体内容时，自动应用此 Skill。

---

## 核心能力

```
媒体处理工具箱
├── 视频处理
│   ├── 格式转换
│   ├── 视频剪辑
│   └── 压缩优化
├── 音频处理
│   ├── 音频提取
│   ├── 格式转换
│   └── 音量调节
├── 图片处理
│   ├── 格式转换
│   ├── 尺寸调整
│   └── 批量处理
└── 高级功能
    ├── 字幕处理
    ├── 水印添加
    └── GIF 制作
```

---

## FFmpeg 常用命令

### 视频转换

```bash
# 基础格式转换
ffmpeg -i input.mov output.mp4

# 指定编码器和质量
ffmpeg -i input.mov -c:v libx264 -crf 23 -c:a aac -b:a 128k output.mp4

# 转换为 WebM (网页友好)
ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus output.webm

# 转换为 GIF
ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" output.gif
```

### 视频剪辑

```bash
# 截取片段 (从 00:01:00 开始，持续 30 秒)
ffmpeg -i input.mp4 -ss 00:01:00 -t 00:00:30 -c copy output.mp4

# 精确剪切 (重新编码)
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:01:30 -c:v libx264 -c:a aac output.mp4

# 合并多个视频
# 先创建文件列表 filelist.txt:
# file 'part1.mp4'
# file 'part2.mp4'
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mp4

# 去除音频
ffmpeg -i input.mp4 -an output.mp4

# 提取特定时间段的帧
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 output.jpg
```

### 视频压缩

```bash
# 高质量压缩 (CRF 18-23 为高质量)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium output.mp4

# 指定目标文件大小 (约 10MB)
ffmpeg -i input.mp4 -c:v libx264 -b:v 1M -maxrate 1M -bufsize 2M output.mp4

# 降低分辨率
ffmpeg -i input.mp4 -vf "scale=1280:720" -c:v libx264 -crf 23 output.mp4

# 两遍编码 (更好的质量控制)
ffmpeg -i input.mp4 -c:v libx264 -b:v 2M -pass 1 -f null /dev/null
ffmpeg -i input.mp4 -c:v libx264 -b:v 2M -pass 2 output.mp4
```

---

## 音频处理

### 音频提取和转换

```bash
# 从视频提取音频
ffmpeg -i video.mp4 -vn -acodec copy audio.aac
ffmpeg -i video.mp4 -vn -acodec libmp3lame -q:a 2 audio.mp3

# 音频格式转换
ffmpeg -i input.wav -acodec libmp3lame -b:a 320k output.mp3
ffmpeg -i input.mp3 -acodec flac output.flac

# 转换为适合语音的格式
ffmpeg -i input.mp3 -ar 16000 -ac 1 output.wav
```

### 音频处理

```bash
# 调整音量 (增大 50%)
ffmpeg -i input.mp3 -af "volume=1.5" output.mp3

# 音频标准化
ffmpeg -i input.mp3 -af "loudnorm=I=-16:TP=-1.5:LRA=11" output.mp3

# 音频淡入淡出
ffmpeg -i input.mp3 -af "afade=t=in:st=0:d=3,afade=t=out:st=57:d=3" output.mp3

# 合并音频
ffmpeg -i audio1.mp3 -i audio2.mp3 -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1" output.mp3

# 音频剪切
ffmpeg -i input.mp3 -ss 00:00:30 -t 00:01:00 -c copy output.mp3
```

---

## 图片处理

### ImageMagick 命令

```bash
# 格式转换
convert input.png output.jpg
convert input.jpg output.webp

# 调整尺寸
convert input.jpg -resize 800x600 output.jpg
convert input.jpg -resize 50% output.jpg
convert input.jpg -resize 800x600\> output.jpg  # 仅缩小，不放大

# 裁剪图片
convert input.jpg -crop 400x300+100+50 output.jpg  # 宽x高+X偏移+Y偏移

# 压缩质量
convert input.jpg -quality 85 output.jpg

# 添加水印
convert input.jpg -gravity southeast -draw "text 10,10 '© 2024'" output.jpg

# 批量转换
for f in *.png; do convert "$f" "${f%.png}.jpg"; done

# 创建缩略图
convert input.jpg -thumbnail 200x200^ -gravity center -extent 200x200 thumb.jpg
```

### FFmpeg 图片处理

```bash
# 图片序列转视频
ffmpeg -framerate 24 -i img%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4

# 视频转图片序列
ffmpeg -i video.mp4 -vf "fps=1" frame_%04d.png

# 创建视频缩略图网格
ffmpeg -i video.mp4 -vf "select='not(mod(n,300))',scale=160:90,tile=5x5" -frames:v 1 thumbnail.png
```

---

## 字幕处理

### 添加字幕

```bash
# 硬编码字幕 (烧录到视频)
ffmpeg -i input.mp4 -vf "subtitles=subtitle.srt" output.mp4

# 软字幕 (可开关)
ffmpeg -i input.mp4 -i subtitle.srt -c copy -c:s mov_text output.mp4

# 指定字幕样式
ffmpeg -i input.mp4 -vf "subtitles=subtitle.srt:force_style='FontSize=24,FontName=Arial'" output.mp4
```

### 字幕转换

```bash
# SRT 转 ASS
ffmpeg -i subtitle.srt subtitle.ass

# 提取视频中的字幕
ffmpeg -i input.mkv -map 0:s:0 subtitle.srt
```

---

## 水印和叠加

### 图片水印

```bash
# 右下角水印
ffmpeg -i input.mp4 -i watermark.png \
  -filter_complex "overlay=W-w-10:H-h-10" output.mp4

# 左上角水印 (带透明度)
ffmpeg -i input.mp4 -i watermark.png \
  -filter_complex "[1:v]format=rgba,colorchannelmixer=aa=0.5[wm];[0:v][wm]overlay=10:10" \
  output.mp4

# 居中水印
ffmpeg -i input.mp4 -i watermark.png \
  -filter_complex "overlay=(W-w)/2:(H-h)/2" output.mp4
```

### 文字水印

```bash
# 添加文字水印
ffmpeg -i input.mp4 -vf \
  "drawtext=text='© Company':fontsize=24:fontcolor=white@0.5:x=W-tw-10:y=H-th-10" \
  output.mp4

# 带时间戳的水印
ffmpeg -i input.mp4 -vf \
  "drawtext=text='%{localtime\:%Y-%m-%d %H\\\:%M\\\:%S}':fontsize=18:fontcolor=white:x=10:y=10" \
  output.mp4
```

---

## GIF 制作

### 高质量 GIF

```bash
# 生成调色板 (提高 GIF 质量)
ffmpeg -i input.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,palettegen" palette.png

# 使用调色板生成 GIF
ffmpeg -i input.mp4 -i palette.png \
  -filter_complex "fps=15,scale=480:-1:flags=lanczos[x];[x][1:v]paletteuse" \
  output.gif

# 一行命令 (稍低质量但简单)
ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" -t 5 output.gif
```

### 优化 GIF

```bash
# 使用 gifsicle 优化
gifsicle -O3 --lossy=80 input.gif -o output.gif

# 限制颜色数量
gifsicle --colors 128 input.gif -o output.gif
```

---

## Python 媒体处理

### MoviePy 视频处理

```python
from moviepy.editor import VideoFileClip, concatenate_videoclips, TextClip, CompositeVideoClip

# 加载视频
clip = VideoFileClip("input.mp4")

# 剪辑
subclip = clip.subclip(10, 20)  # 10秒到20秒

# 调整大小
resized = clip.resize(width=720)

# 添加文字
txt = TextClip("Hello World", fontsize=70, color='white')
txt = txt.set_position('center').set_duration(5)
video_with_text = CompositeVideoClip([clip, txt])

# 合并视频
final = concatenate_videoclips([clip1, clip2, clip3])

# 导出
final.write_videofile("output.mp4", codec='libx264', audio_codec='aac')
```

### Pydub 音频处理

```python
from pydub import AudioSegment

# 加载音频
audio = AudioSegment.from_mp3("input.mp3")

# 剪辑 (毫秒)
segment = audio[10000:20000]  # 10秒到20秒

# 调整音量
louder = audio + 6  # 增加 6dB
quieter = audio - 3  # 减少 3dB

# 淡入淡出
faded = audio.fade_in(2000).fade_out(3000)

# 合并
combined = audio1 + audio2

# 导出
audio.export("output.mp3", format="mp3", bitrate="320k")
```

### Pillow 图片处理

```python
from PIL import Image, ImageDraw, ImageFont

# 打开图片
img = Image.open("input.jpg")

# 调整大小
resized = img.resize((800, 600))
thumbnail = img.copy()
thumbnail.thumbnail((200, 200))

# 裁剪
cropped = img.crop((100, 100, 400, 400))

# 旋转
rotated = img.rotate(45, expand=True)

# 添加水印
draw = ImageDraw.Draw(img)
font = ImageFont.truetype("arial.ttf", 36)
draw.text((10, 10), "© 2024", fill=(255, 255, 255), font=font)

# 保存
img.save("output.jpg", quality=85)
img.save("output.webp", format="WEBP")
```

---

## 常用参数参考

### 视频编码参数

```markdown
## CRF 值参考 (x264)
| CRF | 质量 | 用途 |
|-----|------|------|
| 0 | 无损 | 存档 |
| 18 | 视觉无损 | 高质量存储 |
| 23 | 默认 | 一般用途 |
| 28 | 中等 | 网络分发 |
| 35+ | 低质量 | 预览/草稿 |

## Preset 参考
| Preset | 编码速度 | 文件大小 |
|--------|----------|----------|
| ultrafast | 最快 | 最大 |
| fast | 快 | 较大 |
| medium | 中等 | 中等 |
| slow | 慢 | 较小 |
| veryslow | 最慢 | 最小 |
```

### 音频参数

```markdown
## 比特率参考
| 格式 | 低质量 | 中等 | 高质量 | 无损 |
|------|--------|------|--------|------|
| MP3 | 128k | 192k | 320k | - |
| AAC | 96k | 128k | 256k | - |
| FLAC | - | - | - | ~1000k |

## 采样率
- 8000 Hz: 电话质量
- 16000 Hz: 语音识别
- 44100 Hz: CD 质量
- 48000 Hz: 视频标准
- 96000 Hz: 高清音频
```

---

## 与 TAD 框架的集成

在 TAD 的媒体处理流程中：

```
原始媒体 → 格式分析 → 处理方案 → 执行转换 → 质量验证
               ↓
          [ 此 Skill ]
```

**使用场景**：
- 视频格式转换和压缩
- 音频提取和处理
- 批量图片处理
- 字幕添加和编辑
- GIF 动图制作

---

## 最佳实践

```
✅ 推荐
□ 处理前先备份原文件
□ 使用两遍编码获得更好质量
□ 选择合适的编码器和参数
□ 批量处理使用脚本自动化
□ 检查输出文件质量

❌ 避免
□ 反复转码有损格式
□ 使用过高或过低的比特率
□ 忽视音视频同步问题
□ 不验证输出文件完整性
□ 硬编码文件路径
```

---

*此 Skill 帮助 Claude 进行专业的多媒体处理工作。*
