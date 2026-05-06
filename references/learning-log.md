# Seed Lessons — Multi-Coder

本文件位于 skill 安装目录，是启动时读取的静态经验种子。它不是项目运行时日志，不由任务自动追加。

项目运行时日志写入：`.claude/multi-coder-state/learning-log.md`。

## Runtime 日志格式

```
[时间戳] LRN/ERR | P0/P1/P2 | 一句话描述 | 来源 | 建议
```

## Seed 条目

- ERR | P1 | 普通 Claude 网页端没有可强制的 subagent/tools/heartbeat；只能当人工 playbook，不能执行 MAS。
- ERR | P1 | 编程 handoff 不能压缩掉 file:line、symbol、接口契约；摘要可短，Evidence 必须完整。
- ERR | P1 | 每次 write 后阻塞式 spawn 安全 reviewer 会拖慢开发；post-write 只做轻量检查，Phase 2 集中审查。
- ERR | P1 | 并行写代码必须 worktree 隔离 + path allowlist + integrator；否则隐式决策冲突会吞掉收益。
- LRN | P2 | 领域检测只决定 checklist，风险等级决定审查深度，避免文案改动触发全量扫描。

---

运行时新增经验请写入项目目录的 `.claude/multi-coder-state/learning-log.md`，不要修改本 seed 文件。
