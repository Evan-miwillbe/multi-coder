# Evolution — Multi-Coder 设计决策叙事

## 从 multi-agent-research 到 multi-coder 的机制复用

Multi-coder 不是从零开始，而是继承 multi-agent-research v9.0 经过 47 轮实验验证的架构，并针对编程场景做了以下改编：

### 直接复用的机制

| 机制 | 来源 | 编程版适配 |
|------|------|-----------|
| S0 三问筛选 | research v3.0 | "能拆→能验证→能积累" → 编程版"有并行子任务→有测试→有经验可沉淀" |
| 成本决策（净收益公式） | research v8.0 R14 | 直接复用，编程场景 token 成本类似 |
| 反模式表格 | research + 业界调研 | 新增编程特有反模式（多 writer 冲突、AI 隐性 bug） |
| 四阶段流程 | research v6.0 | Phase 0→1→2→3 结构保留，内容改为编程场景 |
| Pre-flight 自检 | research v6.2 | 改为编程版：文件边界/共享参数/测试策略/安全敏感 |
| Cross-pollination | research v8.0 R12 | 术语锚定替代来源锚定：第一个 agent 定义接口名/类型名 |
| 覆盖率审计 Gate | research v8.0 R13 | 改为接口覆盖+测试覆盖，替代来源覆盖 |
| Spawn 协议（4元素+首尾结构） | research v8.0 R16+R22 | 保留结构，但限定为 Claude Code subagent/Task 运行时 |
| Heartbeat（REFLECT/PIVOT） | research v8.0 R15 | 保留标签；无状态写权限时由主 CC 持久化 |
| 停滞恢复五级梯度 | research v6.2 | 保留五级动作，时间阈值改为按 L2/L3/L4/risk 动态计算 |
| Handoff 质量红线 | research v7.2 R3 | 改为 ≤200字摘要 + Evidence/接口契约不计入字数 |
| /clear 协议 | research v7.5 R6 | 仅在运行时支持时使用；先持久化再清理 |
| 并发写入规则 | research v6.0 | 默认主 CC 是唯一源码 writer；Worktree Write 模式才允许隔离 implementer |

### 改编的机制

| 机制 | Research 版 | Programming 版 | 改编理由 |
|------|------------|---------------|---------|
| 异议触发+三分类 | 学术争议：定义分歧/事实矛盾/层次差异 | 代码分歧：接口冲突/实现矛盾/抽象层级差异 | 编程场景的"矛盾"通常是接口定义不一致 |
| 评估漏斗 | 基于 confidence 的审核深度 | 基于任务复杂度的审查深度 | 编程有更明确的客观信号（测试通过/失败） |
| 共识度检查 | 板块结论方向一致性 | 模块实现一致性 | 编程需要检查同名接口/数据类型是否一致 |
| 自迭代闭环 | learning-history（研究策略） | learning-log（调试/实现/安全/冲突经验） | 编程经验更具体，不是抽象策略 |

### 新增机制（Research 没有的）

| 机制 | 来源 | 编程场景必要性 |
|------|------|---------------|
| 领域检测 | 前端/后端关注点差异 | 安全审查维度完全不同 |
| 安全Gate | OWASP Top 10 + Codex adversarial-review | 编程失败成本 = 安全漏洞/数据丢失 |
| Adversarial review | Codex adversarial-review.md | 主动"攻破"代码，不是被动审查 |
| 测试驱动验证 | 编程场景特有 | 替代 research 的来源交叉验证 |
| 接口契约锁定 | Anthropic 16-Agent 编译器项目 | Interface-first 防止并行实现冲突 |
| 运行环境边界 | Claude Code subagents | 普通 Claude 网页端没有可强制的 spawn/tools/heartbeat |
| 风险分级 | 工程变更管理 | 领域决定 checklist，风险决定审查深度 |
| Worktree Write 模式 | Codex/Claude Code execution-first 实践 | 并行写入只能在隔离 worktree + 文件所有权 + integrator 下开启 |

### 设计决策溯源

**为什么不拆成 Frontend Skill + Backend Skill？**
- 80% 的 orchestration 逻辑通用（triage/spawn/iteration）
- 现实任务经常跨越前后端
- 安全要求是通用的（OWASP 既包含 XSS 也包含 SQLi）
- 领域模式自动适配比分两个 skill 用户体验更好

**为什么把 handoff 改成“≤200字摘要 + Evidence 表”？**
- R3/R5 的短摘要结论仍然成立：下游需要先读到高密度核心判断
- 编程场景不能丢失 `file:line`、symbol/API、接口契约、数据类型和未验证点
- 因此压缩叙述，不压缩证据；Evidence 表和 contracts 不计入摘要字数

**为什么保留 5 级停滞恢复但修改时间阈值？**
- Research 中 4/4 项目验证了“轻推→建议→缩减→部分交付→接管”的动作序列
- 编程探索可能需要长时间 grep/read 调用链，固定 90s-330s 太激进
- Multi-Coder 使用 L2/L3/L4/risk 动态首个 progress 截止，再用倍数升级

**为什么限定为 Claude Code？**
- 本 skill 依赖 subagent spawn、工具权限、文件系统状态、progress/handoff 监控
- Claude Code CLI/Desktop/Claude Code on the web/Agent SDK 可以提供这些能力
- 普通 Claude 网页聊天/Projects 没有强制权限和 agent 编排，只能人工模拟审查流程

**为什么保留 Worktree Write 作为高级模式？**
- 编程调研的共识是 read/review 适合并行，write 默认串行
- 但 Codex/Claude Code 的 execution-first 实践说明，非重叠文件范围 + worktree 隔离 + integrator 合并可以让部分写任务安全并行
- 因此本 skill 不默认多 writer，只在用户批准、契约先行、文件 ownership 清晰时启用
