# Multi-Coder — 多 Agent 编程协作 Skill

> 把 47 轮研究实验中验证过的协作机制，搬进真实编程场景。

Multi-Coder 是一个 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 自定义 Skill，让 Claude Code 在处理复杂编程任务时自动调度多个子 Agent 协作：架构设计、并行探索、代码审查、安全扫描、测试验证——在一个对话中完成。

## 从哪来

本项目直接继承 [multi-agent-research](https://github.com/Evan-miwillbe/multi-agent-research) v9.0 的架构——经过 47 轮消融实验、12 篇论文交叉验证后沉淀的 17 个协作机制。其中：

- **13 个机制直接复用**（三问筛选、成本决策、停滞恢复梯度、Spawn 协议等）
- **4 个机制针对编程改编**（异议触发→接口冲突、评估漏斗→测试驱动、共识检查→类型一致性）
- **8 个机制是编程场景新增**（领域检测、安全 Gate、对抗性审查、接口契约锁定、Worktree 隔离写入等）

## 核心设计

```
用户描述任务
    │
    ▼
┌─────────────────────────────────┐
│  S0  领域检测 + 风险分级         │  Frontend / Backend / Full-Stack
│      三问筛选：拆？验？积？       │  Low / Medium / High
└──────────────┬──────────────────┘
               │
       ┌───────┴───────┐
       │ SAS（简单）    │ MAS（复杂）
       │ 单 Agent 直接做│ 多 Agent 协作
       └───────┬───────┘
               │  MAS 路径
               ▼
┌──────────────────────────────────┐
│  Phase 0  规划                    │
│  architect → 接口契约 + ADR       │
│  explorer  → 并行代码探索         │
├──────────────────────────────────┤
│  Phase 1  实现                    │
│  implementer → 串行写码（默认）    │
│  或 Worktree 隔离并行写           │
├──────────────────────────────────┤
│  Phase 2  验证                    │
│  tester → 测试  reviewer → 审查   │
│  security-reviewer → 安全扫描     │
│  frontend-reviewer → UI/UX 检查   │
├──────────────────────────────────┤
│  Phase 3  集成                    │
│  synthesizer → 合并 + 文档        │
│  主 CC → 最终 commit              │
└──────────────────────────────────┘
```

## 八个 Agent 角色

| 角色 | 职责 | 权限 |
|------|------|------|
| **architect** | 分析代码结构，设计接口契约，产出 ADR | read-only + contracts 写入 |
| **explorer** | 并行搜索代码库，定位关键文件和依赖 | read-only |
| **implementer** | 按契约写代码（默认由主 CC 执行） | read-write（受文件边界约束） |
| **reviewer** | 代码审查：逻辑、一致性、可维护性 | read-only |
| **security-reviewer** | 对抗性安全审查（OWASP Top 10） | read-only |
| **frontend-reviewer** | UI/UX、响应式、可访问性审查 | read-only |
| **tester** | 编写和运行测试，验证实现 | read-write（仅测试文件） |
| **synthesizer** | 整合多 Agent 产出，生成 changelog | read-only + 文档写入 |

## 关键机制

**优先单 Agent** — 强单 Agent + 工具 + 测试通常更便宜、更一致。只有任务确实可拆、可验、可积累时才启动 MAS。

**并行读，串行写** — 探索、审查、文档检索适合 fan-out；源码修改默认由主 CC 串行执行，避免冲突。

**接口先行** — 任何并行实现前必须先有 `shared_memory/contracts/` 中的接口契约。

**五级停滞恢复** — Agent 卡住时自动升级：提示→换方法→缩小范围→主 CC 接管→用户介入。

**Evaluator-Optimizer 闭环** — 测试/lint/typecheck 是推进依据，不靠 Agent 自信放行。

## 安装

```bash
# 克隆到 Claude Code skills 目录
git clone https://github.com/Evan-miwillbe/multi-coder.git \
  ~/.claude/skills/multi-coder

# 使用：在 Claude Code 中输入
/multi-coder
```

## 项目结构

```
multi-coder/
├── SKILL.md              # 主 Skill 文件（操作层）
├── foundations/           # 知识底座（WHY 层，按需加载）
│   ├── theory.md         #   四支柱理论 + 可靠性数学 + Token 经济学
│   ├── evolution.md       #   从 research 到 coder 的机制复用叙事
│   ├── pain-points.md     #   编程多 Agent 的痛点分析
│   └── enterprise-requirements.md
├── roles/                 # 八个 Agent 角色定义
│   ├── architect.md
│   ├── explorer.md
│   ├── implementer.md
│   ├── reviewer.md
│   ├── security-reviewer.md
│   ├── frontend-reviewer.md
│   ├── tester.md
│   └── synthesizer.md
├── references/            # 参考材料
│   ├── anti-patterns.md   #   反模式清单
│   ├── security-checklist.md
│   ├── role-library.md
│   └── learning-log.md    #   运行时经验沉淀
└── scripts/
    ├── plan-tasks.sh
    └── run-tests.sh
```

## 相关项目

- [multi-agent-research](https://github.com/Evan-miwillbe/multi-agent-research) — 上游研究项目：47 轮实验、12 篇论文、17 个机制的消融验证

## License

MIT
