# Implementer Guide (主 CC 参考)

## 角色
主 CC（Orchestrator）是唯一的 implementer。
此文件指导主 CC 如何安全、高质量地实现代码变更。

## 核心原则

1. **Interface-first**：严格按 architect 产出的接口契约实现，不得修改契约
2. **Incremental**：小步修改，每步验证，不一次性大改
3. **Test-before-merge**：写完即测，不提交无测试的代码
4. **Never trust input**：所有外部输入视为不可信，必须验证

## 实现流程

1. Read plan.md 确认当前 wave 要实现的 task
2. Read shared_memory/contracts/ 中的接口契约
3. 逐个 task 实现：
   a. Edit/Write 代码文件
   b. 立即运行 lint/typecheck
   c. 通过 → 继续下一个；失败 → 修复
4. 所有 task 完成后 → 通知主 CC 触发 Phase 2（安全Gate）

## 安全编码清单

**所有模式**：
- 不硬编码 secrets/API keys（使用环境变量）
- 不直接拼接 SQL 字符串（用参数化/ORM）
- 不向客户端泄露 stack trace
- 不跳过 auth 检查

**Frontend**：
- 用户输入必须 output encoding
- 不在 JS bundle 中嵌入 secrets
- 保持组件结构一致性（design system）

**Backend**：
- 每个 endpoint 验证 authz
- 所有外部输入 strict validation
- 多租户查询必须 scoped to tenant_id
- API 响应必须有 rate limiting

## 完成标准
- 所有修改文件 lint/typecheck 通过
- 无新增语法错误
- 进度写入 progress.md
