#!/usr/bin/env bash
# experiments/thin-tad-pilot/oc-adapter.sh
# Honest in-repo adapter bridging thin-tad runner to real OpenCode CLI (v1.18.27).
# Node stdlib subprocess-friendly: propagates stdout, stderr, and exit codes accurately.
set -euo pipefail

# 1. 寻找真实底层二进制 (受 TAD_OPENCODE_RAW_BIN 控制)
# Precedence note: binary resolution runs before argument validation, so a
# dual-fault invocation (bad args + missing binary) reports 127, not 2.
# Both are fail-closed; the order follows the §4.2 code listing.
OPENCODE_BIN="${TAD_OPENCODE_RAW_BIN:-/home/box/.opencode/bin/opencode}"
if [ ! -x "$OPENCODE_BIN" ]; then
  if command -v opencode >/dev/null 2>&1; then
    OPENCODE_BIN="$(command -v opencode)"
    if [ ! -x "$OPENCODE_BIN" ]; then
      echo "ERROR: [oc-adapter] Fallback opencode binary not executable: $OPENCODE_BIN" >&2
      exit 127
    fi
    echo "NOTE: [oc-adapter] Resolved subject binary via PATH fallback: $OPENCODE_BIN" >&2
  else
    echo "ERROR: [oc-adapter] Subject OpenCode binary not found or not executable at: $OPENCODE_BIN" >&2
    exit 127
  fi
fi

# 2. 解析 Runner 传入参数 (两段契约：Runner->Adapter 输入契约)
# 支持: run --model <m> --dir <d> --prompt-file <f> [--temperature <t>] [--seed <s>]
SUBCOMMAND="${1:-}"
if [ "$SUBCOMMAND" != "run" ]; then
  echo "ERROR: [oc-adapter] Unsupported subcommand: ${SUBCOMMAND:-<empty>} (only 'run' is supported)" >&2
  exit 2
fi
shift

MODEL=""
WORK_DIR=""
PROMPT_FILE=""
TEMP=""
SEED=""

# 保护：每项带参选项在 set -u / set -e 下均有 $# -ge 2 边界防护；未知入参一律 fail-closed exit 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model|-m)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      MODEL="$2"; shift 2 ;;
    --dir)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      WORK_DIR="$2"; shift 2 ;;
    --prompt-file)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      PROMPT_FILE="$2"; shift 2 ;;
    --temperature)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      TEMP="$2"; shift 2 ;;
    --seed)
      [ $# -ge 2 ] || { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }
      SEED="$2"; shift 2 ;;
    *)
      echo "ERROR: [oc-adapter] Unknown argument: $1" >&2
      exit 2 ;;
  esac
done

# 3. 校验必要参数、沙箱包含性与路径规范化 (防越界、防遍历、符号链接拒绝与工作区绑定)
if [ -z "$MODEL" ] || [ -z "$WORK_DIR" ] || [ -z "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] Missing required arguments (--model, --dir, or --prompt-file)" >&2
  exit 2
fi

# (a) 检查原始 WORK_DIR 是否为符号链接（拒绝软链规避目录逃逸）
# Strip trailing slashes first: `[ -L "/tmp/link/" ]` is false on Linux for a
# symlink-to-dir, which would skip the refusal below. realpath + prefix
# containment remains the backstop either way.
while [[ "$WORK_DIR" != "/" && "$WORK_DIR" == */ ]]; do WORK_DIR="${WORK_DIR%/}"; done
if [ -L "$WORK_DIR" ]; then
  echo "ERROR: [oc-adapter] WORK_DIR must not be a symlink: $WORK_DIR" >&2
  exit 2
fi

WORK_DIR="$(realpath -m "$WORK_DIR")"
if [ ! -d "$WORK_DIR" ]; then
  echo "ERROR: [oc-adapter] Target work directory does not exist: $WORK_DIR" >&2
  exit 2
fi

# (b) 前缀沙箱包含性检查：WORK_DIR 必须位于白名单根目录下 (默认 /tmp/，或经 TAD_ALLOWED_WORK_ROOT 显式配置)
ALLOWED_WORK_ROOT="${TAD_ALLOWED_WORK_ROOT:-/tmp}"
ALLOWED_WORK_ROOT="$(realpath -m "$ALLOWED_WORK_ROOT")"
if [[ "$WORK_DIR" != "$ALLOWED_WORK_ROOT"/* && "$WORK_DIR" != "$ALLOWED_WORK_ROOT" ]]; then
  echo "ERROR: [oc-adapter] WORK_DIR outside allowed root ($ALLOWED_WORK_ROOT): $WORK_DIR" >&2
  exit 2
fi

# (c) PROMPT_FILE 检查：拒绝符号链接，校验存在性与可读性
while [[ "$PROMPT_FILE" != "/" && "$PROMPT_FILE" == */ ]]; do PROMPT_FILE="${PROMPT_FILE%/}"; done
if [ -L "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] PROMPT_FILE must not be a symlink: $PROMPT_FILE" >&2
  exit 2
fi

PROMPT_FILE="$(realpath -m "$PROMPT_FILE")"
if [ ! -f "$PROMPT_FILE" ] || [ ! -r "$PROMPT_FILE" ]; then
  echo "ERROR: [oc-adapter] Prompt file not found or unreadable: $PROMPT_FILE" >&2
  exit 2
fi

# (d) PROMPT_FILE 路径绑定：必须位于 WORK_DIR 或白名单根目录内，彻底防止任意系统文件越界读取
if [[ "$PROMPT_FILE" != "$WORK_DIR"/* && "$PROMPT_FILE" != "$ALLOWED_WORK_ROOT"/* ]]; then
  echo "ERROR: [oc-adapter] PROMPT_FILE must reside in WORK_DIR or allowed root: $PROMPT_FILE" >&2
  exit 2
fi

# 4. 诚实记录硬阻断超参数 (绝不向底层伪造注入未知参数)
if [ -n "$TEMP" ] || [ -n "$SEED" ]; then
  echo "NOTE: [oc-adapter] OpenCode CLI (v1.18.27) lacks native --temperature/--seed flags. Received temp='$TEMP', seed='$SEED'. Running with engine defaults." >&2
fi

# 5. 执行环境与非交互保障说明
# 正常运行时由 runner.mjs spawnOc 负责环境净化 (sanitizeEnv)；
# 若人工独立调试调用，请使用 env -i 运行并附加 timeout 300 超时保护：
# env -i PATH="$PATH" HOME="$HOME" TAD_OPENCODE_RAW_BIN="$TAD_OPENCODE_RAW_BIN" timeout 300 ./oc-adapter.sh ...
export TERM="${TERM:-dumb}"
export NO_COLOR="${NO_COLOR:-1}"

# 6. 执行 OpenCode CLI：
# 优先使用原生 -f 文件透传，避免 ARG_MAX 限制、换行截断与注入漏洞；锁定 --format default
# 若采用位置参数形式回退，必须加 -- 分隔符防止注入：
# exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -- "$PROMPT_CONTENT"
exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"
