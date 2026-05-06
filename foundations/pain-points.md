# Pain Points — 程序员真实痛点与 Multi-Coder 解法

## 来源

Reddit (r/programming, r/ExperiencedDevs, r/ClaudeCode, r/cursor), Zhihu, V2EX, Juejin 调研，2026年5月。

## P0 级痛点

### 1. Debugging 占 80% 时间
**现象**：写代码1小时，调试8小时。改6个字符要花2小时。
**Multi-Coder 解法**：Phase 1 并行 spawn 3 个 explorer — log分析 + 代码路径追踪 + 复现步骤，缩短根因定位时间。

### 2. AI 生成代码有隐藏 bug
**现象**：代码"看起来能跑"但有隐蔽安全漏洞/逻辑错误。Amazon 2026 AI-code outages 损失数百万。
**Multi-Coder 解法**：Security Gate + Adversarial Reviewer，每次 write 后自动触发，不是等"做完再说"。

### 3. 读代码比写代码耗时
**现象**：成熟项目中，读代码是最耗时工作。90%+ 时间花在分析和调试。
**Multi-Coder 解法**：并行 explorer 生成架构地图 + 模块总结 + 数据流追踪，代替手动阅读。

## P1 级痛点

### 4. 前端能跑但不美观
**现象**：AI 生成的前端代码功能正常，但 UX/视觉不一致、a11y 不合规。
**Multi-Coder 解法**：Frontend 模式自动注入 frontend-reviewer，检查 a11y/UX/性能/一致性。

### 5. 后端安全性被忽视
**现象**：OWASP Top 10 中 80% 的问题可以通过代码审查发现，但开发者经常跳过。
**Multi-Coder 解法**：Backend 模式自动注入 security-reviewer，按 OWASP Top 10 逐项检查。

### 6. Context 窗口不够用
**现象**：项目 >30 文件或 30K+ tokens 后 AI 质量下降。开发者手动创建 summary MD 文件。
**Multi-Coder 解法**：Context sharding — 每个 subagent 处理不同子系统，只回传精华。

### 7. Code review 耗时
**现象**：开发者每周花 2 天等待 code review。大 PR（2000+ 行）审查质量下降。
**Multi-Coder 解法**：预审查 agent 自动检查 style/bug/coverage，人只看风险点。

### 8. Legacy 重构无测试
**现象**：没有测试的重构等于盲飞。生成 characterization tests 是前置条件。
**Multi-Coder 解法**：Refactor 流程 Wave 1 由 testGenerator 先生成测试，再实施重构。

## P2 级痛点

### 9. AI 陷入死循环
**现象**：test → error → fix → test → error → fix... 永远循环，消耗 usage quota。
**Multi-Coder 解法**：停滞恢复五级梯度 + Heartbeat 监控，90s 无进度自动干预。

### 10. 需求变更影响面分析
**现象**："加一行代码"可能需要改数据库/API/测试/文档，级联效应。
**Multi-Coder 解法**：Phase 0 侦察阶段用 Glob/Grep 扫描所有受影响文件，写入 plan.md。

### 11. 提示词注入攻击
**现象**：2025 年 prompt injection 攻击增长 540%。OWASP LLM01:2025 是 #1 AI 威胁。
**Multi-Coder 解法**：Security Gate 包含 AI 特定安全检查，adversarial review 尝试注入攻击。

## 不适用 Multi-Coder 的场景

- 单文件单行修改 → SAS 直接执行
- 已有明确修复方案的小 bug → 单 agent 足够
- 不外部验证的任务（无测试/无 lint）→ 慎用 MAS（错误放大 17x）
