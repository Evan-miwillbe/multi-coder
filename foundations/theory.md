# Theory — Multi-Coder 知识底座

## 四支柱（来自刘奕好 2050 演讲 + Anthropic 研究）

Multi-agent 的有效性来自四个维度的系统化组织：

1. **Context**：上下文隔离 — 避免 context rot 和 Lost in Middle
2. **Search**：并行探索 — 扩大候选空间，多样性 ≠ 免费效率
3. **Verify**：协作验证 — 减少单链错误累积
4. **Memory**：知识复用 — 发现成为起点（CORAL 36% 继承率）

### Context Sharding > Role Playing

单 agent 的痛点：一个窗口装下所有东西 → context rot / error propagation / lost in middle。
Multi-agent 的解法：多个干净小上下文，只回传摘要/证据/风险。

### Context 不是越长越好，而是越相关越好

当上下文频繁更新时，multi-agent 反而可能变劣势：
- Agent A 定义的数据结构，Agent B 看不到 → 冗余/错误工作
- 长期交接中局部微逻辑丢失
- 解法：外部 structured memory + agent 间结构化接口

## 可靠性数学

p^n 模型：如果每步正确率 90%，5 步串联 = 0.9^5 = 59%。
要让 5 Agent 整体 >50%，每步至少需要 87%。
→ 硬限 ≤5 Agent 并行，超出分批序贯。

## Token 经济学

MAS 净收益 = 并行探索广度 + 知识复用 − token成本 − 同步误差 − 交接损耗

| 预期提升 | 决策 | 理由 |
|----------|------|------|
| <20% | SAS | DPI定理（Tran et al. 2026）：等token SAS≥MAS |
| 20-50% | MAS ≤3 Agent | 最优ROI区间 |
| >50% | MAS 3-5+ Agent | 覆盖>效率 |

Multi-agent 比 chat 多 ~15x token，比 single-agent 多 ~4x（Anthropic 2025）。

## Cognition vs Anthropic 的核心分歧

**Cognition（Walden Yan）**：
- 多 agent 的隐含决策容易冲突
- Actions carry implicit decisions
- 应 single agent + full context + context compression

**Anthropic**：
- Multi-agent 在 research/breadth-first 任务上高出 90.2%
- 但 coding 任务的可并行子任务比 research 少
- Read 任务适合 multi-agent，write 任务应 single-threaded

**共识**：两者都对，取决于任务类型。
Multi-coder 采用 Read/Write 分离：subagent 只读探索，main CC 唯一写。

## CORAL 知识复用

3 个关键数据：
- 36% 的新假说基于其他 agent 的结论发展
- 跨 agent 继承的尝试改进率 17% vs 单 agent 9%
- 66% 的新记录来自跨 agent parent

→ Cross-pollination 不是可选项，是必选项。
第一个 agent 产出不仅是内容，还有框架和术语锚点。

## Lost in Middle（Liu et al. TACL 2024）

关键约束放在 prompt 中间 = 0% 合规率（multi-agent-research R16 验证）。
前50字 + 末尾重申 = 100% 合规率。
