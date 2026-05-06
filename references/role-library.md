# Role Library — Multi-Coder

## 角色速查

| 角色 | 职责 | 读写 | 推荐模型 | 最大并行 |
|------|------|------|---------|---------|
| architect | 接口契约 + ADR | read-only | Sonnet | 1 |
| explorer | 代码探索/调试 | read-only | Haiku/Sonnet | 3 |
| reviewer | 代码质量审查 | read-only | Sonnet | 3 |
| security-reviewer | 安全审查 | read-only | Sonnet/Opus | 1 |
| frontend-reviewer | 前端UX/a11y审查 | read-only | Sonnet | 1 |
| tester | 测试生成/执行 | read + test files | Sonnet | 1 |
| synthesizer | 综合交付报告 | read-only | Sonnet/Opus | 1 |
| main-cc | 唯一writer | read+write | Opus | 1 |

## Spawn Brief 模板

每个 agent 的 spawn prompt 必须包含以下 4 元素：

```
ROLE: {角色名}
GOAL: {一句话目标}
INPUTS: {文件路径、shared_memory 位置、前置发现}
OUTPUT FORMAT: {产出文件路径 + 结构要求}
TOOL SCOPE: {可用工具列表 + 禁止操作}
SUCCESS CRITERIA: {如何判断完成}
COMMUNICATION: {_progress.md 路径 + Heartbeat 标签}
```

## 输出 Schema

### handoff/{角色名}.md 格式

```
[{角色}-{模块}] [{文件数}files] [{字数}字] [confidence:{H/M/L}]

{1句核心结论}
{3-5个关键发现（含文件路径/行号）}
{1个未解决问题/信息缺口}
```

### handoff/{角色名}_progress.md 格式

```
[时间戳] [REFLECT] 发现:{...} / 未发现:{...} / 下一步:{...}
[时间戳] [PIVOT] 原方向:{...} → 新方向:{...}
```

## 常见失败模式（按角色）

- **architect**：接口设计过于抽象 → 保持具体，不预设未来需求
- **explorer**：搜索方向饱和后不 pivot → 看 Heartbeat，无新发现必须 pivot
- **reviewer**：报告风格问题而非实质问题 → 只报 P0/P1
- **security-reviewer**：报告 theoretical attack 无实际路径 → 必须有具体攻击链
- **tester**：生成无意义的"测试覆盖" → 每个测试必须验证有意义的行为
- **synthesizer**：直接拼接而非综合 → 基于 handoff 精华，不读原始产出
