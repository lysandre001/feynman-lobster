#!/bin/bash
# 费曼虾 — 启动 Web 面板
# 从任意位置运行均可，脚本会自动定位到 web 目录
# 示例：bash ~/.openclaw/skills/feynman-lobster/scripts/start-panel.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$SCRIPT_DIR/../web"
PORT=19380

if [ ! -d "$WEB_DIR" ]; then
  echo "❌ 未找到 web 目录：$WEB_DIR"
  exit 1
fi

echo "🦞 费曼虾面板启动中..."
echo "   地址：http://localhost:$PORT"
echo "   按 Ctrl+C 停止"
echo ""
cd "$WEB_DIR" && npx serve -p "$PORT"
