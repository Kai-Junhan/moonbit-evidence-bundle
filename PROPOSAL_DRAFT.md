# moonbit-evidence-bundle 项目申报书草稿

> 这是申报辅助草稿，不是最终提交文本。提交前应由参赛者按自己的实际理解、开发经历和赛事表单要求人工改写。

## 基本信息

- 项目名称：`moonbit-evidence-bundle`
- 参赛者：`Kai-Junhan`
- GitHub：https://github.com/Kai-Junhan/moonbit-evidence-bundle
- 项目方向：MoonBit 项目交付、复现与发布治理工具链
- 项目类型：原创项目
- 许可证：MIT

## 项目价值与生态定位

MoonBit 项目的构建、测试、诊断和产物信息目前分散在命令输出、CI 日志和测试报告中。开发者可以看到结果，但很难把一次交付的工具链、命令、测试结论、诊断和产物摘要保存成可比较的记录。

本项目补充的是“证据层”，而不是再次实现 CI Runner、工作流系统或日志平台。它定义平台无关的 Evidence Bundle，并通过适配器接收 Moon CLI 和 JUnit 等工具已经产生的结果，再提供规范化 JSON、SHA-256 摘要、diff、结构校验和 release gate。这样可以回答“这次发布由什么工具链生成、哪些检查通过、两次结果哪里不同、是否具备发布证据”等实际问题。

项目已对 workflow、data、trace、event、schema、SARIF 等 Moocakes 方向进行去重审查，明确不替代已有项目，而是保存和关联它们产生的证据。

## 完整使用场景

1. **MoonBit 项目发布前检查**：CI 将 `moon check`、`moon test` 的摘要转换为 Evidence Entry，验证 bundle 结构和 digest，再由 release gate 判断是否允许发布。
2. **跨工具测试结果归一化**：项目使用外部测试框架生成 JUnit XML 时，通过 JUnit adapter 汇总单套件或多套件的测试、失败、异常和跳过数量，统一为 `Test` 证据。
3. **两次构建或版本交付对比**：保存两次 bundle 的规范化 fingerprint 和 SHA-256 digest，通过 diff 定位测试状态、诊断记录或产物摘要的变化，辅助复现和回归审查。

## 核心交付范围

- Evidence Bundle v0.1 数据模型和 JSON 序列化。
- `moon test`、`moon check` 输出适配器。
- JUnit XML 单套件、多套件和 root-only 汇总适配器。
- 纯 MoonBit SHA-256、产物 digest 和 bundle digest。
- bundle validation：协议版本、必填字段、唯一 ID 和 digest 格式校验。
- bundle diff、失败证据查询和 release gate。
- wasm-gc/js 构建、测试、GitHub Actions CI、quickstart 和完整 demo。

## 明确不做

- 不执行通用 workflow/DAG，不做 CI Runner。
- 不实现 Event Bus、Trace SDK、DataFrame、CSV/JSON ETL。
- 不实现 JSON Schema validator、SARIF parser 或通用诊断渲染器。
- 不保存完整日志、原始敏感环境变量或密钥；适配器只保存标准化摘要和可选引用。

## 实现路径

核心模型、解析逻辑、SHA-256、校验、diff 和 gate 全部使用 MoonBit 实现。外部格式只在边界适配器中解析，适配器无法识别的输出返回 `None`，由调用方决定是否记录失败。所有核心路径均有测试，SHA-256 使用 NIST 向量以及 node/python 独立结果交叉验证，并在 wasm-gc/js 两个目标上验证。

## 验收产物

- 公开 GitHub 仓库及 MIT License。
- README、协议格式说明、开发说明和来源审查。
- 可运行的 `cmd/demo`、`examples/quickstart`、`examples/junit`。
- 32 个核心测试，以及 GitHub Actions 的格式化、检查、构建和测试流程。
- Mooncakes 包：`Kai-Junhan/moonbit-evidence-bundle@0.1.0`。
