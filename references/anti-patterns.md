# Anti-Patterns — Multi-Coder

## 业界验证的失败模式

### 1. 多 writer 冲突（Cognition + Anthropic 编译器项目验证）
**表现**：多个 agent 并行写同一文件，后写者覆盖前者。
**影响**：代码不一致、功能丢失、silent failure。
**防御**：默认主 CC 是唯一源码 writer；Worktree Write 模式下必须 worktree 隔离 + path allowlist + single-writer-per-file。

### 2. 松散 Bag of Agents（arXiv 2503.13657）
**表现**：无 supervisor 的链式 agent，每个输出作为下一个输入。
**影响**：17x 错误放大，41%-86.7% 失败率。
**防御**：必须有中心化 orchestrator，不链式传递。

### 3. Context 中间丢失（Lost in Middle, Liu et al. TACL 2024）
**表现**：spawn prompt 中的约束放在中间段落，agent 100% 忽略。
**影响**：字数膨胀、越界行为、产出不符合要求。
**防御**：关键约束必须放在前50字 + 末尾重申（验证：100% vs 0% 合规率）。

### 4. 单 agent 已好使却硬上 multi-agent（DeepMind）
**表现**：单 agent 基线 >45% 时仍强行 fan out。
**影响**：性能反而下降（DeepMind：multi-agent 仅在单 agent <45% 时有净收益）。
**防御**：S0 三问筛选 — 不能拆/不能验证/不能积累 → SAS。

### 5. 子 agent 结果溢出 context（GitHub #23463, #32099）
**表现**：subagent 返回完整产出直接放入主 context，导致溢出。
**影响**：主 context 不可恢复，后续任务质量下降。
**防御**：subagent 结果落到状态目录，仅回传 reference；handoff 用 ≤200字摘要 + Evidence 表保留工程细节。

### 6. SQLite 锁竞争冻结（GitHub #14124）
**表现**：并行 subagent 同时写 SQLite（如 tool call 日志），锁竞争导致死锁。
**影响**：subagent 无限期挂起。
**防御**：并发上限 3 个 agent，遇锁冲突自动降级。

### 7. 子 agent 级联终止（GitHub #6594）
**表现**：一个 subagent 遇到 API 错误，所有 subagent 终止。
**影响**：整轮工作丢失。
**防御**：每个 subagent 独立完成一次状态持久化或向主 CC 返回可持久化产出后才算安全，失败后重新 spawn 而非全部重来。

### 8. Sub-sub-agent 不支持（GitHub #19077）
**表现**：subagent 内部尝试 spawn 自己的 subagent。
**影响**：crash。
**防御**：subagent 只有源码 read-only 权限，不 spawn。

### 9. 过度细分角色（meta-analysis of multi-agent coding）
**表现**：超过 5 个 agent 后边际收益陡降。
**影响**：token 成本爆炸，协调复杂度超过并行收益。
**防御**：硬限 ≤5 agent 并行，超出分批序贯。

### 10. 未隔离并行写入
**表现**：两个 implementer 在同一个工作树里并行修改不同模块，但隐式共享 lockfile/config/migration。
**影响**：merge conflict、依赖漂移、测试结果不可复现。
**防御**：并行写入必须使用 worktree/branch 隔离，shared files 指定唯一 owner，由 integrator 合并。

### 11. AI 生成代码的隐性 bug（r/programming, Jan 2026）
**表现**：AI 生成的代码"看起来能跑"但有隐蔽安全漏洞/逻辑错误。
**影响**：Amazon 2026 AI-code outages，数百万损失。
**防御**：每次 write 后做轻量检查；Phase 2 集中执行 Security Gate，High risk 必须 adversarial review。
