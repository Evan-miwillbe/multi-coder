# Enterprise Requirements — Multi-Coder 企业级要求知识底座

## 可靠性要求

### SLA 目标

| 等级 | 可用性 | 月最大停机 | 典型场景 |
|------|--------|-----------|---------|
| 标准 | 99.9% | ~43 分钟 | 大多数 SaaS |
| 业务 | 99.95% | ~22 分钟 | 企业 SaaS |
| 关键 | 99.99% | ~4.3 分钟 | 金融/医疗 |

### 回滚要求
- "先回滚，后诊断" — 最小化 MTTR
- 数据库迁移必须向后兼容且可逆
- Blue-green 或 canary 部署，不直接替换生产

## 安全合规

### SOC 2 Type II
企业 B2B 交易的入门门槛。没有 SOC 2 无法签大单。

### 渗透测试
- 每个企业 deal 前需要第三方 pen test
- 企业平均每年发送 150+ 供应商安全评估
- Pen test 报告必须 <12 个月

### GDPR / CCPA / HIPAA
根据业务类型和地域，合规要求不同。

## OWASP Top 10:2025

见 references/security-checklist.md 完整清单。

## 关键真实事件

| 事件 | 类型 | 影响 | 根因 |
|------|------|------|------|
| Chrome CVE-2026-2441 | UAF in CSS | RCE 35亿用户 | 内存安全 |
| Oracle EBS CVE-2025-61882 | SSRF+注入 | RCE, Cl0p 勒索 | 4个编码错误串联 |
| React Server Components | RCE | 数千 web 应用 | 未认证代码执行 |
| Amazon AI-code outages (2026.3) | AI生成代码错误 | 零售站点宕机 | 缺少高级审查 |
| VS Code Copilot CVE-2025-53773 | Prompt injection → RCE | 蠕虫命令执行 | AI 助手信任边界破坏 |
| EchoLeak CVE-2025-32711 | Prompt injection | 数据泄露 | LLM scope violation |

## 编程 Skill 的安全责任

Multi-Coder 生成的代码如果用于生产环境，必须满足：
1. 所有 P0 安全 finding 已修复
2. 通过第三方 pen test（如果是 B2B 产品）
3. 代码 review 由人类工程师最终签字
4. AI 生成的代码不跳过 CI/CD 直接部署

**AI 生成的代码 ≠ 生产就绪代码。**
Multi-Coder 的目标是"尽可能接近"，但最终 gate 必须由人类把关。
