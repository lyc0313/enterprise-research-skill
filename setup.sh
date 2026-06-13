#!/usr/bin/env bash
set -euo pipefail

# ========================================
# 企业调研 Skill v2.0 — 一键安装脚本 (Linux/macOS)
# ========================================

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SKILL_DIR")"

echo "========================================"
echo "  企业调研 Skill v2.0 一键安装"
echo "========================================"
echo ""

# ---- Step 1: 检测 Python ----
echo "[1/5] 检测 Python 环境..."
PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        ver=$($cmd --version 2>&1)
        if echo "$ver" | grep -qE '^Python 3\.([6-9]|[1-9][0-9])'; then
            PYTHON_CMD="$cmd"
            echo "  ✓ 找到 Python: $ver"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "  ✗ 需要 Python 3.6+，请先安装: https://www.python.org/downloads/"
    exit 1
fi

# ---- Step 2: 安装 Python 依赖 ----
echo "[2/5] 安装 Python 依赖..."
$PYTHON_CMD -m pip install requests --quiet 2>/dev/null && echo "  ✓ requests 库已就绪" || echo "  ⚠ 安装失败，请手动执行: pip install requests"

# ---- Step 3: 安装 Scrapling ----
echo "[3/5] 安装 Scrapling（反爬采集引擎）..."
$PYTHON_CMD -m pip install scrapling --quiet 2>/dev/null && echo "  ✓ Scrapling 已安装" || echo "  ⚠ 安装失败，请手动执行: pip install scrapling"

# ---- Step 4: 安装 AnySearch ----
echo "[4/5] 安装 AnySearch 搜索引擎..."
ANYS_DIR="$REPO_ROOT/anysearch"
if [ ! -d "$ANYS_DIR" ]; then
    echo "  → 下载 AnySearch v2.1.0..."
    ZIP_URL="https://github.com/anysearch-ai/anysearch-skill/archive/refs/heads/main.zip"
    TMP_ZIP="/tmp/anysearch-skill.zip"
    if curl -sL "$ZIP_URL" -o "$TMP_ZIP" && unzip -q "$TMP_ZIP" -d /tmp; then
        mv /tmp/anysearch-skill-main "$ANYS_DIR" 2>/dev/null
        rm -f "$TMP_ZIP"
        echo "  ✓ AnySearch 已安装"
    else
        echo "  ✗ 下载失败，请手动下载: $ZIP_URL"
    fi
else
    echo "  ✓ AnySearch 已存在"
fi

# ---- Step 5: 配置 runtime.conf ----
echo "[5/5] 配置运行时环境..."
AS_CONF="$ANYS_DIR/runtime.conf"
if [ ! -f "$AS_CONF" ] && [ -d "$ANYS_DIR" ]; then
    cat > "$AS_CONF" <<EOF
Runtime: Python
Command: $PYTHON_CMD $ANYS_DIR/scripts/anysearch_cli.py
EOF
    echo "  ✓ AnySearch runtime.conf 已创建"
else
    echo "  ✓ runtime.conf 已存在"
fi

echo ""
echo "========================================"
echo "  安装完成！"
echo "========================================"
echo ""
echo "使用方法："
echo "  调研 {公司全称}          — 完整调研流程"
echo "  {公司全称} 快速          — 快速模式"
echo "  {公司全称} 带财报        — 深挖模式"
echo ""
echo "文件位置："
echo "  技能本体: $SKILL_DIR"
echo "  AnySearch: $ANYS_DIR"
echo ""
