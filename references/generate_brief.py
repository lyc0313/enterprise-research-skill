"""
企业调研简报生成器
用法：python generate_brief.py --company "公司全称" --data "调研数据.json"
      python generate_brief.py --interactive  # 交互模式

数据格式（JSON）：
{
  "company": "公司全称",
  "date": "2026-06-11",
  "basic": {
    "full_name": "...", "nature": "...", "reg_capital": "...",
    "founded": "...", "headquarters": "...", "legal_person": "...",
    "main_business": "...", "team_size": "..."
  },
  "industry": {
    "position": "...", "competitors": "...", "policy": "...", "advantages": "..."
  },
  "recent": [
    {"event": "...", "date": "...", "source": "..."}
  ],
  "culture": {
    "reputation": "...", "employee_feedback": "..."
  },
  "sources": {"A": 0, "B": 0, "C": 0, "D": 0}
}
"""

import json, sys, argparse
from datetime import date

TEMPLATE = """# {company} 企业调研简报

**调研日期**：{date}
**调研方式**：多渠道并行调研（Scrapling / WebSearch / RSS / 其他）
**信息可靠性**：A级{s_A}条 / B级{s_B}条 / C级{s_C}条 / D级{s_D}条

---

## 一、公司基本信息

| 字段 | 内容 |
|------|------|
| 全称 | {full_name} |
| 企业性质 | {nature} |
| 注册资本 | {reg_capital} |
| 成立时间 | {founded} |
| 总部所在地 | {headquarters} |
| 法人代表 | {legal_person} |
| 团队规模 | {team_size} |
| 主营业务 | {main_business} |

## 二、行业与竞争定位

- **行业地位**：{position}
- **主要竞对**：{competitors}
- **政策环境**：{policy}
- **核心优势**：{advantages}

## 三、近期动态（近12个月）

{recent_events}

## 四、企业文化与口碑（参考）

{reputation_info}

## 五、待核实信息

{issues}

## 六、备注

{notes}
"""

def generate_brief(data):
    recent = data.get("recent", [])
    if recent:
        lines = [f"- **{r.get('date','')}** {r.get('event','')}（来源：{r.get('source','')}）" for r in recent]
        recent_str = "\n".join(lines)
    else:
        recent_str = "（无近期动态信息）"
    
    culture = data.get("culture", {})
    rep = culture.get("reputation", "（未采集到）")
    emp = culture.get("employee_feedback", "（未采集到）")
    culture_str = f"- 行业声誉：{rep}\n- 员工评价：{emp}\n- 信号等级：仅供参考"
    
    issues = data.get("issues", [])
    issues_str = "\n".join([f"{i+1}. {item}" for i, item in enumerate(issues)]) if issues else "（无待核实信息）"
    
    src = data.get("sources", {})
    b = data.get("basic", {})
    ind = data.get("industry", {})
    
    return TEMPLATE.format(
        company=data.get("company", ""),
        date=data.get("date", str(date.today())),
        s_A=src.get("A", 0), s_B=src.get("B", 0),
        s_C=src.get("C", 0), s_D=src.get("D", 0),
        full_name=b.get("full_name", ""),
        nature=b.get("nature", ""),
        reg_capital=b.get("reg_capital", ""),
        founded=b.get("founded", ""),
        headquarters=b.get("headquarters", ""),
        legal_person=b.get("legal_person", ""),
        team_size=b.get("team_size", ""),
        main_business=b.get("main_business", ""),
        position=ind.get("position", ""),
        competitors=ind.get("competitors", ""),
        policy=ind.get("policy", ""),
        advantages=ind.get("advantages", ""),
        recent_events=recent_str,
        reputation_info=culture_str,
        issues=issues_str,
        notes=data.get("notes", "调研结果基于公开信息，仅供参考。关键事实已标注来源等级。")
    )

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="企业调研简报生成器")
    parser.add_argument("--company", help="公司全称")
    parser.add_argument("--data", help="调研数据JSON文件路径")
    parser.add_argument("--interactive", action="store_true", help="交互模式")
    args = parser.parse_args()
    
    if args.data:
        with open(args.data, "r", encoding="utf-8") as f:
            data = json.load(f)
        print(generate_brief(data))
    elif args.interactive:
        print("交互模式：逐项输入调研数据")
        data = json.loads(input("粘贴完整JSON数据："))
        print(generate_brief(data))
    else:
        print("用法：python generate_brief.py --data data.json")
