# Security Checklist — Multi-Coder

## OWASP-style Backend Checks

| ID | 类别 | 检查项 | 防御 |
|----|------|--------|------|
| A01 | 访问控制破坏 | 每个 endpoint 是否验证 authz？ | 服务端强制验证，UI隐藏≠安全 |
| A02 | 安全配置错误 | 有无默认密码/debug mode/CORS 过宽？ | 生产环境禁用 debug，严格 CORS |
| A03 | 供应链失败 | 依赖有无已知漏洞？ | SAST + 依赖扫描 |
| A04 | 加密失败 | 敏感数据是否加密？TLS 配置正确？ | AES-256 + TLS 1.3 |
| A05 | 注入 | SQL/NoSQL/OS/LDAP/XXE？ | 参数化查询，无字符串拼接 |
| A06 | 不安全设计 | 有无 rate limiting？可预测流程？ | 速率限制 + 威胁建模 |
| A07 | 认证失败 | session 管理/JWT 签名/MFA？ | 标准库，不自造 |
| A08 | 完整性失败 | 有无反序列化/CI-CD 篡改风险？ | 签名验证 |
| A09 | 日志失败 | 是否记录 PII？有无审计日志？ | 脱敏 + 审计 trail |
| A10 | 异常处理失败 | 是否泄露 stack trace？ | 结构化错误码，无内部细节 |

## Frontend 安全

| 类别 | 检查项 | 防御 |
|------|--------|------|
| XSS | 用户输入是否 output encoding？ | 框架 auto-escaping + context-specific |
| CSP | Content Security Policy 配置？ | 严格 CSP header |
| Secrets | JS bundle 有无 API keys？ | 环境变量，不进 bundle |
| SRI | CDN 脚本有无 integrity？ | subresource integrity 属性 |
| CSRF | 表单有无 CSRF token？ | SameSite cookie + token |
| a11y | 键盘导航/screen reader/对比度？ | WCAG 2.1 AA |

## Prompt Injection 防御（AI 应用）

| 攻击类型 | 案例 | 防御 |
|---------|------|------|
| 直接注入 | 用户输入覆盖 system prompt | 输入与 system prompt 严格隔离 |
| 间接注入 | RAG 知识库被投毒 | 知识库内容过滤 + 输出验证 |
| 工具调用注入 | LLM 被诱导执行危险操作 | tool/function call allowlist |
| 数据泄露 | EchoLeak (CVE-2025-32711) | 输出结构化验证，不信任原始 LLM 输出 |
| 远程执行 | VS Code Copilot CVE-2025-53773 | 沙箱执行 + 操作审批 |

## Adversarial Review 检查点

审查时优先寻找以下高成本失败场景：

1. **Auth/权限/租户隔离**：是否有任何路径可以绕过验证？
2. **数据丢失/损坏**：不可逆操作有无确认/回滚？
3. **竞态条件**：并发场景下有无不一致？
4. **回滚安全**：部分失败后系统能否恢复？
5. **可观测性**：失败时是否有足够日志恢复现场？
6. **信任边界**：用户输入是否被视为可信？

## 执行层级

| Risk | 何时使用 | 检查方式 |
|------|----------|----------|
| Low | 文案/样式/文档/低风险配置 | post-write 轻量检查 + 必要时采样 |
| Medium | 多文件/API/状态流/数据模型 | Phase 2 标准审查 + 对应 domain checklist |
| High | auth/支付/租户/数据迁移/secrets/LLM tools | Phase 2 完整审查 + adversarial review |

每次 write 后只做轻量检查：diff 范围 lint/typecheck/test subset、secret scan、明显危险 API。完整安全 Gate 在 Phase 2 集中执行。

## Blocking 标准

- P0：no-ship，必须修复。要求有 `file:line`、攻击/失败路径、影响范围、修复建议。
- P1：由主 CC 汇总给用户裁决，默认建议修复但不自动 no-ship。
- P2：不阻塞，只作为后续改进建议。

无法给出具体攻击路径或复现条件的 finding 不得 blocking。
