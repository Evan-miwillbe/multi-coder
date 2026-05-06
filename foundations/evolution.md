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
| Spawn 协议（4元素+首尾结构） | research v8.0 R16+R22 | 直接复用，100% 合规率验证 |
| Heartbeat（REFLECT/PIVOT） | research v8.0 R15 | 直接复用，标签格式不变 |
| 停滞恢复五级梯度 | research v6.2 | 直接复用，时间阈值不变 |
| Handoff 质量红线（150-200字） | research v7.2 R3 | 直接复用，压缩≠损失原则不变 |
| /clear 协议 | research v7.5 R6 | 直接复用，4文件重启策略不变 |
| 并发写入规则 | research v6.0 | 强化：主 CC 是唯一 writer |

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

### 设计决策溯源

**为什么不拆成 Frontend Skill + Backend Skill？**
- 80% 的 orchestration 逻辑通用（triage/spawn/iteration）
- 现实任务经常跨越前后端
- 安全要求是通用的（OWASP 既包含 XSS 也包含 SQLi）
- 领域模式自动适配比分两个 skill 用户体验更好

**为什么继承 research 的 Handoff 150-200 字限制？**
- R3/R5 验证：200 字 = 500 字信息量（压缩去噪）
- LightThinker 论文：70% 压缩 + 2.42% 质量提升
- 编程场景中 handoff 包含文件路径/行号/关键发现，信息密度更高

**为什么保留 5 级停滞恢复？**
- Research 中 4/4 项目验证有效
- 编程场景 agent stuck 概率更高（代码搜索更精确）
- 90s-330s 梯度覆盖了从"轻推"到"接管"的完整恢复路径
