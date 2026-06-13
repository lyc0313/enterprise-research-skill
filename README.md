# 企业调研 Skill v2.0

> 标准化、可复用的企业背景深度调研工作流。输入公司全称，输出结构化调研简报。

[![Skill 标准](https://img.shields.io/badge/Skill-OpenAgent-brightgreen)](https://github.com/openai/skills)
[![Python](https://img.shields.io/badge/Python-3.6%2B-blue)](https://python.org)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue)](LICENSE)

---

## 特点

- **多渠道并行采集**：AnySearch API（优先） + WebSearch + Scrapling 反爬 + RSS + 社交口碑
- **源可靠性分级**：A/B/C/D 四级标注，每条结论可追溯可验证
- **交叉验证**：关键事实需 1A+1B 或 2B 才采信，矛盾信息保留不强行调和
- **结构化输出**：标准化调研简报模板，直接用于企业背调/售前/尽职调查
- **垂直领域搜索**：金融（财报/股价）、学术（论文/专利）、法律（法规/案例）专项数据

## 快速安装

### 一键安装（推荐）

```bash
# Windows PowerShell（右键 → 用 PowerShell 运行）
.\setup.ps1

# macOS / Linux
bash setup.sh
```

### 手动安装

```bash
# 1. 安装 Python 依赖
pip install requests scrapling

# 2. 安装 AnySearch 搜索引擎
#    从 https://github.com/anysearch-ai/anysearch-skill 下载
#    解压到同级目录 anysearch/

# 3. 配置 runtime.conf
#    anysearch/runtime.conf:
#    Runtime: Python
#    Command: python3 <path>/anysearch/scripts/anysearch_cli.py
```

## 使用方法

在支持 Skills 的 AI 智能体（如 WorkBuddy、Codex、Cursor 等）中加载本技能，然后：

| 命令 | 功能 |
|------|------|
| `调研 {公司全称}` | 完整调研流程（AnySearch优先） |
| `{公司全称} 快速` | 快速模式（只做基本面+行业竞争） |
| `{公司全称} 带财报` | 深挖模式（启用金融垂直搜索） |

### 输出示例

```markdown
# 某科技有限公司 企业调研简报

**调研日期**：2026-06-12
**调研方式**：多渠道并行调研（AnySearch / Scrapling / WebSearch / RSS / 其他）
**信息可靠性**：A级3条 / B级5条 / C级2条 / D级1条

## 一、公司基本信息
- 全称：...
- 企业性质：民营企业
- 注册资本：...
- *来源：[官网]（A级，已交叉验证）*
...
```

## 系统架构

```
输入：公司全称
    │
    ▼
搜索路由分类（按意图选7种场景）
    │
    ▼
四维并行调研
  ├── A. 公司基本面 ─── Scrapling → AnySearch
  ├── B. 行业与竞争 ─── AnySearch(批量搜索) → WebSearch
  ├── C. 口碑评价 ───── 多渠道（V2EX/小红书/脉脉）
  └── D. 近期动态 ───── AnySearch(垂直金融) → Scrapling
    │
    ▼
来源分级 → 交叉验证 → Review检查 → 输出简报
```

## 依赖

| 依赖 | 版本要求 | 用途 |
|:---|:---|:---|
| Python | 3.6+ | 运行时 |
| requests | 最新 | AnySearch CLI 网络请求 |
| scrapling | 最新 | 反爬网页采集 |
| AnySearch Skill | 2.1.0+ | 搜索引擎（自动安装） |

## 许可证

Apache-2.0
