# IDEA: WebRTC 作为 Agent + ML 模型的轻量传输层

**Date:** 2026-07-03
**Status:** captured
**Scope:** small
**Source:** AI Tinkerers #33 — WebRTC Powered Agents (Etienne Caron, Montreal, 9 stars)

---

## Context

Etienne Caron 用 LiveKit WebRTC 搭建了一个轻量级实时视频 pipeline：video stream → 可插拔的 ML 模型（GroundingDINO 目标检测 + SAM2 分割 + depth estimation）→ LLM agent（Gemini Live）对话交互。

关键特点：不是重型自定义服务器，而是用 WebRTC 做 "万能传输层"，ML 模型可以像插件一样随时换入换出。

GitHub: github.com/kanawish/control-room (9 stars, Kotlin Multiplatform + Python, MIT)
作者是 Android Google Dev Expert (ex-Shopify, ex-Intel)。

## Summary & Problem

WebRTC 原本是视频通话协议，但作为 agent 传输层有独特优势：
- 低延迟（为实时通话设计）
- 浏览器原生支持（无需客户端安装）
- 标准化协议（多语言多平台）
- LiveKit 提供开源服务端

"Agent + 视觉感知" 的通用架构：WebRTC 视频流 → ML 模型识别场景 → Agent 做决策 → 反馈给用户。

## Open Questions

- 这个架构是否适合 "AI 辅助用户操作" 场景？比如 agent 通过视频看用户屏幕并给建议
- LiveKit 的开源生态成熟度如何？
- WebRTC 的延迟特性（sub-second）是否足够 agent 实时反应？

## Relevance to Us

如果 TAD 未来扩展到 "非开发者" 场景（见 TAD Universal Method 方向），视觉感知层可能是必要的。WebRTC + ML 模型的轻量组合比 Computer Use 更专注、更低延迟。
