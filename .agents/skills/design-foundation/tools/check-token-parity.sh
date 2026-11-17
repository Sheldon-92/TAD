#!/bin/bash
# check-token-parity.sh — design-foundation 令牌正本/镜像一致性检查
#
# 正本 = tokens/tokens.css（手工维护）；镜像 = tokens/tokens.json（派生）。
# 逐项比对两面的自定义属性集与值：全等打印 PARITY-OK 并 exit 0；
# 任一差（键缺失 / 多键 / 值差）逐项打印差项并 exit 1。
#
# Usage: bash tools/check-token-parity.sh
# 只用 POSIX shell 工具（awk / sort / mktemp），无新依赖。

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSS_FILE="${SCRIPT_DIR}/../tokens/tokens.css"
JSON_FILE="${SCRIPT_DIR}/../tokens/tokens.json"

if [ ! -f "$CSS_FILE" ] || [ ! -f "$JSON_FILE" ]; then
  echo "PARITY-ERROR: tokens.css or tokens.json not found next to this script" >&2
  exit 1
fi

TMP_CSS="$(mktemp)"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_CSS" "$TMP_JSON"' EXIT

# --- CSS 面：抽取 :root 内的自定义属性声明（行首 --name: value;） ---
awk '
  /^[[:space:]]*--[a-z0-9-]+:/ {
    line = $0
    idx = index(line, ":")
    name = substr(line, 1, idx - 1)
    gsub(/[[:space:]]/, "", name)
    val = substr(line, idx + 1)
    sub(/;[[:space:]]*$/, "", val)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
    print name "\t" val
  }
' "$CSS_FILE" | sort > "$TMP_CSS"

# --- JSON 面：按生成格式抽取（顶层组 = 令牌组前缀，条目键 = 余段 kebab） ---
awk '
  /^  "[a-z0-9-]+": \{/ {
    g = $0
    sub(/^  "/, "", g); sub(/": \{.*$/, "", g)
    grp = g
    next
  }
  /^    "[^"]+": / {
    line = $0
    sub(/^    "/, "", line)
    idx = index(line, "\"")
    key = substr(line, 1, idx - 1)
    val = substr(line, idx + 1)
    sub(/^: "/, "", val)
    sub(/",?$/, "", val)
    gsub(/\\"/, "\"", val)
    gsub(/\\\\/, "\\", val)
    print "--" grp "-" key "\t" val
  }
' "$JSON_FILE" | sort > "$TMP_JSON"

# --- 比对：三类差逐项报 ---
DIFFS="$(awk '
  NR == FNR { css[$1] = $2; next }
  { json[$1] = $2 }
  END {
    n = 0
    for (k in css) {
      if (!(k in json)) { print "MISSING-IN-JSON " k; n++ }
      else if (css[k] != json[k]) { print "VALUE-DIFF " k; n++ }
    }
    for (k in json) {
      if (!(k in css)) { print "EXTRA-IN-JSON " k; n++ }
    }
    print n > "/dev/stderr"
  }
' "$TMP_CSS" "$TMP_JSON" 2>/tmp/.parity-count)"
COUNT="$(cat /tmp/.parity-count 2>/dev/null || echo '?')"
rm -f /tmp/.parity-count

if [ -n "$DIFFS" ]; then
  echo "$DIFFS"
  echo "PARITY-FAIL: $COUNT difference(s)" >&2
  exit 1
fi

TOTAL="$(wc -l < "$TMP_CSS" | tr -d ' ')"
echo "PARITY-OK ($TOTAL tokens)"
exit 0
