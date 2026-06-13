# ChatTTS 端到端工作流

> 从文本到发布级音频的完整流程。基于实战验证（Barney Frank 文章，Mac Apple Silicon，2026-05-28）。
> 解决三个核心问题：声音自然度、跨段落一致性、情绪可控性。

---

## 何时选 ChatTTS

| 场景 | 适合 | 不适合 |
|---|---|---|
| 中文叙事内容（博客、播客、文章朗读） | ✅ 最自然的中文 TTS | — |
| 双人/多人对话（播客、采访） | ✅ 多 speaker embedding | — |
| 需要情绪变化（文学作品、讣告、人物传记） | ✅ oral/laugh/break 控制 | — |
| 英文内容 | — | ❌ 用 Kokoro（见 `narration-dubbing.md`） |
| 商业发行 | — | ❌ CC BY-NC 4.0，商用需其他工具 |
| 超长篇（10+ 小时有声书） | — | ⚠️ 可用但慢，考虑 Fish S2 Pro 或 VoxCPM2 |

> Source: ask-findings-summary.md §Anti-Patterns (ChatTTS intentional degradation for anti-commercial)

---

## 环境搭建

```bash
# 1. 创建隔离虚拟环境（MUST — 不污染全局）
cd /tmp && uv venv chattts-env --python 3.12
source chattts-env/bin/activate

# 2. 安装依赖
uv pip install chattts soundfile numpy requests

# 3. 中文支持（ChatTTS 不会自动装这些）
uv pip install ordered-set pypinyin cn2an jieba

# 4. Mac Apple Silicon 必设
export PYTORCH_ENABLE_MPS_FALLBACK=1
```

> Source: baseline-report.md §5 (MPS fallback requirement)

---

## 第一步：创建并保存声音身份

声音一致性的关键：把 speaker embedding 持久化到 `.pt` 文件。

```python
import os
os.environ["PYTORCH_ENABLE_MPS_FALLBACK"] = "1"

import ChatTTS
import torch

chat = ChatTTS.Chat()
chat.load(compile=False)

# 生成一个随机声音，seed 决定音色
torch.manual_seed(42)     # 换不同数字 = 不同人
spk = chat.sample_random_speaker()

# 保存到文件 — 以后永远用这个文件 = 永远是同一个人
torch.save(spk, "voices/narrator.pt")
```

### 声音管理规则

- **一个 `.pt` 文件 = 一个固定角色**
- **文件大小**：约 4KB，可以 git 提交
- **命名约定**：`voices/{role}.pt`（narrator.pt、host.pt、guest.pt）
- **换人**：改 `manual_seed` 的数字，重新 sample，存新文件
- **试音**：用一句话测试多个 seed（推荐试 10-20 个），选最满意的保存

```python
# 试音脚本 — 同一句话，10 个不同声音
for seed in range(10):
    torch.manual_seed(seed)
    spk = chat.sample_random_speaker()
    wavs = chat.infer(["今天天气真不错，适合出去走走。"],
        params_infer_code=ChatTTS.Chat.InferCodeParams(spk_emb=spk))
    sf.write(f"audition/voice-seed-{seed}.wav", wavs[0], 24000)
```

---

## 第二步：文本准备

### 清洗规则

| 原始内容 | 处理方式 |
|---|---|
| Markdown 格式（链接、加粗、标题） | 移除所有标记，保留纯文本 |
| `$21bn` / `21%` | 改为"二百一十亿美元" / "百分之二十一" |
| 英文人名 | 保留原文（ChatTTS 可处理中英混排） |
| 段落分隔 | 用 `\n\n` 分段，每段作为独立生成单元 |
| 特殊标点 `—` `"` `"` `《》` | ChatTTS 会报 `found invalid characters` 但不影响生成 |

### 情绪标注

在文本中嵌入 `[uv_break]` 标记显式停顿位置：

```
原文：一位记者把话筒怼到他面前：你是同性恋吗？他回答说：是啊，那又怎样？

标注后：一位记者把话筒怼到他面前：你是同性恋吗？[uv_break]他回答说：[uv_break]是啊，那又怎样？
```

---

## 第三步：情绪参数体系

ChatTTS 通过 `RefineTextParams` 的 prompt 字段控制语音情绪。

### 参数表

> ⚠️ 官方 token 范围（2noise/ChatTTS README，retrieved 2026-06-13）：`oral_(0-9)`、
> `laugh_(0-2)`、`break_(0-7)`。超出范围的 token 不受支持——不要发出 `[laugh_5]` 或
> `[break_9]` 这类越界值。

| 参数 | 范围 | 低值效果 | 高值效果 | 推荐场景 |
|---|---|---|---|---|
| `[oral_N]` | 0-9 | 正式、播报感 | 随意、口语化（加"嗯""啊"等） | 新闻 0-1，聊天 3-5，即兴 7-9 |
| `[laugh_N]` | 0-2 | 严肃 | 带笑意的语气 | 讣告 0，轻松话题 1，搞笑 2（上限） |
| `[break_N]` | 0-7 | 连贯快速 | 更多自然停顿 | 快节奏 2-3，叙事 5-6，沉思 7（上限） |

### 场景预设

```python
PRESETS = {
    "news":       "[oral_0][laugh_0][break_4]",  # 新闻播报
    "narration":  "[oral_0][laugh_0][break_5]",  # 文章朗读
    "reflective": "[oral_0][laugh_0][break_7]",  # 沉思、回忆
    "casual":     "[oral_3][laugh_1][break_4]",  # 播客闲聊
    "dramatic":   "[oral_1][laugh_0][break_4]",  # 戏剧化叙述
    "warm":       "[oral_1][laugh_2][break_6]",  # 温暖结尾
}
```

### 逐段情绪编排

对于叙事性长文，为每段指定不同预设：

```python
script = [
    {"text": "开头介绍...",           "preset": "narration"},
    {"text": "童年痛苦回忆...",       "preset": "reflective"},
    {"text": "戏剧性转折...",         "preset": "dramatic"},
    {"text": "温暖的结尾...",         "preset": "warm"},
]
```

---

## 第四步：生成

### 核心生成代码

```python
import ChatTTS
import torch
import soundfile as sf
import numpy as np

chat = ChatTTS.Chat()
chat.load(compile=False)

# 加载已保存的声音
spk = torch.load("voices/narrator.pt", weights_only=True)

text = open("clean-text.txt").read()
paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]

pause = np.zeros(int(24000 * 0.8))  # 段落间 0.8 秒静音
all_audio = []

for i, para in enumerate(paragraphs):
    torch.manual_seed(42)  # 每段重置种子 — 确保声音特征一致

    params_infer = ChatTTS.Chat.InferCodeParams(
        spk_emb=spk,
        temperature=0.3,    # 低 = 更稳定可预测
        top_P=0.7,
        top_K=20,
    )
    params_refine = ChatTTS.Chat.RefineTextParams(
        prompt='[oral_0][laugh_0][break_5]',  # 或按段落使用不同预设
    )

    wavs = chat.infer(
        [para],
        params_infer_code=params_infer,
        params_refine_text=params_refine,
    )
    all_audio.append(wavs[0])
    if i < len(paragraphs) - 1:
        all_audio.append(pause)

full = np.concatenate(all_audio)
sf.write("output-raw.wav", full, 24000)
```

### 生成参数说明

| 参数 | 推荐值 | 作用 |
|---|---|---|
| `temperature` | 0.2-0.3 | 低值 = 稳定输出，高值 = 更多变化（但可能漂移） |
| `top_P` | 0.7 | 核采样阈值 |
| `top_K` | 20 | 候选 token 数 |
| `manual_seed(42)` | 每段前重置 | 保证声音特征不漂移 |

### 性能预期（Mac Apple Silicon 16GB）

| 段落长度 | 生成时间 | 音频时长 |
|---|---|---|
| ~150 字 | ~30s | ~25-30s 音频 |
| ~50 字 | ~10s | ~8-10s 音频 |
| 12 段全文 ~2000 字 | ~6 分钟 | ~5 分钟音频 |

> Source: 实测数据 2026-05-28, Mac Apple Silicon, ChatTTS 逐段生成模式

---

## 第五步：后期处理

### 博客/播客标准（-16 LUFS）

```bash
ffmpeg -y -i output-raw.wav \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
  -ar 44100 -codec:a libmp3lame -b:a 192k \
  output-final.mp3
```

### 有声书标准（ACX -20 LUFS）

```bash
ffmpeg -y -i output-raw.wav \
  -af "loudnorm=I=-20:TP=-3:LRA=7" \
  -ar 44100 -codec:a libmp3lame -b:a 192k \
  output-acx.mp3
```

### 验证

```bash
# 检查音量是否达标
ffmpeg -i output-final.mp3 -af "volumedetect" -f null /dev/null 2>&1 \
  | grep -E "mean_volume|max_volume"

# 检查格式
ffprobe -show_entries stream=sample_rate,codec_name output-final.mp3
```

---

## 双人对话工作流

播客、采访等需要两个角色的场景。

### 1. 创建两个声音

```python
torch.manual_seed(42)
host = chat.sample_random_speaker()
torch.save(host, "voices/host.pt")

torch.manual_seed(99)
guest = chat.sample_random_speaker()
torch.save(guest, "voices/guest.pt")
```

### 2. 编排对话脚本

```python
script = [
    {"speaker": "host",  "text": "欢迎大家收听本期节目...",  "prompt": "[oral_2][laugh_1][break_4]"},
    {"speaker": "guest", "text": "谢谢邀请，很高兴来到这里。", "prompt": "[oral_3][laugh_2][break_5]"},
    {"speaker": "host",  "text": "今天我们来聊聊...",         "prompt": "[oral_2][laugh_0][break_4]"},
    {"speaker": "guest", "text": "这个话题我很有感触...",     "prompt": "[oral_1][laugh_0][break_6]"},
]
```

### 3. 生成

```python
voices = {
    "host":  torch.load("voices/host.pt", weights_only=True),
    "guest": torch.load("voices/guest.pt", weights_only=True),
}

turn_gap = np.zeros(int(24000 * 0.5))  # 换人时 0.5 秒间隔
all_audio = []

for turn in script:
    torch.manual_seed(42)
    params_infer = ChatTTS.Chat.InferCodeParams(
        spk_emb=voices[turn["speaker"]],
        temperature=0.3, top_P=0.7, top_K=20,
    )
    params_refine = ChatTTS.Chat.RefineTextParams(prompt=turn["prompt"])

    wavs = chat.infer([turn["text"]], params_infer_code=params_infer,
                       params_refine_text=params_refine)
    all_audio.append(wavs[0])
    all_audio.append(turn_gap)

full = np.concatenate(all_audio)
sf.write("dialogue-raw.wav", full, 24000)
```

### 底噪一致性

同一个 `chat` 实例 + 同一个 `manual_seed` + 逐段生成 = 底噪环境一致。两个不同的 `spk_emb` 只改变音色，不改变录音环境特征。

---

## 声音资产管理

```
project/
├── voices/               # 声音身份（git 可提交，~4KB 每个）
│   ├── narrator.pt
│   ├── host.pt
│   └── guest.pt
├── scripts/              # 标注好情绪的文本
│   ├── episode-01.py     # 含 script 列表 + 预设
│   └── episode-02.py
├── raw/                  # 生成的原始音频
├── mastered/             # 后期处理后
└── final/                # 发布版本
```

### 跨项目复用

`.pt` 文件是 PyTorch tensor，与 ChatTTS 模型架构耦合。**同版本 ChatTTS** 在任何机器上加载都是同一个声音。升级 ChatTTS 版本时，embedding 维度可能变化——建议保留生成该 `.pt` 的 ChatTTS 版本号（`pip show chattts | grep Version`）。

---

## 故障排除

| 症状 | 原因 | 修复 |
|---|---|---|
| 段落间声音不一致 | 没有每段重置 `manual_seed` | 每段前加 `torch.manual_seed(42)` |
| `found invalid characters` 警告 | 中文特殊标点 | 无需处理，不影响生成质量 |
| 生成音频过短（<10s 对应长段落） | 文本超出单次 token 限制 | 把长段落拆成 2-3 小段 |
| `ModuleNotFoundError: ordered_set` | 中文依赖未装 | `pip install ordered-set pypinyin cn2an jieba` |
| MPS float64 错误 | Apple Silicon 兼容性 | `export PYTORCH_ENABLE_MPS_FALLBACK=1` |
| 内存溢出 | 段落过多的 batch 生成 | 用逐段生成（本文推荐方式），不用 batch |
