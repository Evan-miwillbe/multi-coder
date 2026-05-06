# Role Library — Multi-Coder

## 角色速查

| 角色 | 职责 | 源码权限 | 状态文件权限 | 推荐模型 | 最大并行 |
|------|------|----------|------------|---------|---------|
| architect | 接口契约 + ADR | read-only | 可写自己的 handoff/contracts，或返回给主 CC | Sonnet | 1 |
| explorer | 代码探索/调试 | read-only | 可写自己的 report/handoff，或返回给主 CC | Haiku/Sonnet | 3 |
| reviewer | 代码质量审查 | read-only | 可写自己的 review/handoff，或返回给主 CC | Sonnet | 3 |
| security-reviewer | 安全审查 | read-only | 可写自己的 security_review/handoff，或返回给主 CC | Sonnet/Opus | 1 |
| frontend-reviewer | 前端UX/a11y审查 | read-only | 可写自己的 review/handoff，或返回给主 CC | Sonnet | 1 |
| tester | 测试生成/执行 | read + test files（需主 CC 批准） | 可写测试报告 | Sonnet | 1 |
| implementer-worktree | 隔离实现 | 仅 path allowlist 内 read+write | 可写实现报告和测试结果 | Sonnet/Opus | 2 |
| integrator | 合并 worktree + 验证 | read+write（主 CC 或指定集成者） | 写集成报告 | Opus/Sonnet | 1 |
| synthesizer | 综合交付报告 | read-only | 可写综合报告 | Sonnet/Opus | 1 |
| main-cc | 唯一源码 writer | read+write | 写全局 progress/learning-log | Opus | 1 |

read-only 的含义是“不修改产品源码”。在 Claude Code 中必须通过 subagent tools/permissions 强制；普通 Claude 网页端没有强制权限，只能人工遵守，不能视为已落地。

## Spawn Brief 模板

每个 agent 的 spawn prompt 必须包含以下元素：

```
ROLE: {角色名}
GOAL: {一句话目标}
INPUTS: {文件路径、shared_memory 位置、前置发现}
OUTPUT FORMAT: {产出文件路径 + 结构要求}
TOOL SCOPE: {可用工具列表 + 禁止操作}
SUCCESS CRITERIA: {如何判断完成}
COMMUNICATION: {_progress.md 路径 + Heartbeat 标签；若无写权限则返回给主 CC 持久化}
```

## 输出 Schema

### handoff/{角色名}.md 格式

```

## Worktree Implementer Brief 补充

只有在主 CC 明确选择 Worktree Write 模式、用户批准、且 plan.md 写明文件所有权后才使用。

```
WORKTREE: {path or branch}
WRITE ALLOWLIST: {exact paths/globs}
READ SCOPE: {dependencies allowed}
CONTRACTS: {.claude/multi-coder-state/shared_memory/contracts/...}
DO NOT TOUCH: {shared files owned by others}
TEST COMMAND: {fast relevant test}
MERGE OUTPUT: {implementation_report.md + test_result.md}
```

失败即停：如果需要修改契约、shared file 或其他 agent 的 owned path，返回 BLOCKED 给主 CC，不要自行越权。
[{角色}-{模块}] [{文件数}files] [summary:{字数}字] [confidence:{H/M/L}]

Summary（≤200字）:
{1句核心结论 + 3-5个关键发现 + 1个未解决问题/信息缺口}

Evidence:
| file:line | symbol/API | finding/contract | confidence |
|-----------|------------|------------------|------------|
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
