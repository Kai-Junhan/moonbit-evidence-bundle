# moonbit-evidence-bundle

[![CI](https://github.com/Kai-Junhan/moonbit-evidence-bundle/actions/workflows/ci.yml/badge.svg)](https://github.com/Kai-Junhan/moonbit-evidence-bundle/actions/workflows/ci.yml)
[![Mooncakes](https://img.shields.io/badge/Mooncakes-v0.1.0-2ea44f)](https://mooncakes.io/)

`moonbit-evidence-bundle` 是一个面向 MoonBit 项目交付、复现和发布治理的证据包协议与工具链。

它不是另一个 CI Runner、测试框架、日志系统、SARIF 解析器或 JSON Schema Validator。它解决的是更上层的问题：

> 如何把一次构建、测试、运行、诊断、依赖和产物检查，保存成可比较、可复现、可审计的统一证据。

## 为什么做它

当前开源项目的质量证据通常散落在 CI 日志、README、截图、Issue、测试报告和发布说明中。它们对人可读，但难以被工具统一比较，也难以回答：

- 这个产物由哪个 MoonBit 工具链生成？
- 测试和构建是否使用了相同依赖状态？
- 两次构建的差异来自源代码、工具链还是环境？
- 一个失败诊断是否对应实际提交和产物？
- 一个发布包能否重放其关键验证步骤？

本项目提供一个平台无关的核心证据模型，通过适配器接入 Moon CLI、JUnit 等外部结果；未来可保存 SARIF、coverage、benchmark、SPDX/CycloneDX 和 Moocakes 元数据的引用，但不复制这些工具的实现。

## 核心能力

当前实现：

- `EvidenceBundle`：项目、格式版本、工具链和证据条目的统一容器。
- `EvidenceEntry`：构建、测试、运行、诊断、产物、依赖六类证据。
- `EvidenceStatus`：`Passed`、`Failed`、`Skipped`。
- 结构化 `ToJson` 输出，便于 CI、网页和 registry 使用。
- 稳定规范化序列化结果，用于判断两次证据是否完全相同；后续可替换为加密摘要而不改变协议字段。
- 失败证据查询和最小差异模型。
- 采集器适配器：从 `moon test` 原始输出解析 `Total tests / passed / failed` 摘要，从 `moon check` 原始输出解析 `warnings / errors` 计数，产出 `Test` / `Build` 证据条目。
- JUnit XML 适配器：汇总单套件、多套件和 root-only 报告，产出统一的 `Test` 证据条目。
- Release gate：根据失败证据判定 `ReadyToShip` 或 `Blocked`，并列出阻断条目。
- Bundle validation：校验协议版本、必填字段、entry ID 唯一性和 SHA-256 digest 格式。
- Evidence policy：声明必须存在的检查和产物，验证证据关联、上游失败和产物 digest，缺失时 fail closed。
- 纯 MoonBit SHA-256（FIPS 180-4，无外部依赖）：`sha256_hex`、产物条目的 `digest` 字段和 `bundle.digest()`；使用 NIST 标准向量与独立工具（node/python）双重交叉验证。
- GitHub Actions CI：在 `wasm-gc` 和 `js` 目标上执行格式化、检查、构建和测试。
- Expect Snapshot Test，锁定协议输出。

## 安装与快速开始

项目已发布到 Mooncakes，在 MoonBit 项目中执行：

```sh
moon add Kai-Junhan/moonbit-evidence-bundle
```

然后通过 `@evidence` 解析 Moon CLI 输出并生成证据条目：

```moonbit
let bundle = @evidence.EvidenceBundle::new("demo", "moon 0.1.20260703")
let bundle = match @evidence.test_run_entry(
  "tests",
  "run tests",
  "Total tests: 3, passed: 3, failed: 0.",
  command="moon test --target wasm-gc",
) {
  Some(entry) => bundle.add(entry)
  None => bundle
}
println(bundle.digest())
```

完整的最小示例位于 `examples/quickstart`，运行：

```sh
moon run --target js examples/quickstart
```

JUnit 适配器示例位于 `examples/junit`，运行：

```sh
moon run --target js examples/junit
```

完整演示位于 `cmd/demo`，展示测试/check 适配、bundle diff、SHA-256、validation 和 release gate：

```sh
moon run --target js cmd/demo
```

`cmd/demo` 还会展示一个完整策略案例：输入只有 `build` 和 `tests` 时输出 `Blocked`，原因是 `missing required artifact: report`；补上带 SHA-256 且要求 `tests` 的 `report` 后输出 `Allowed`。更多输入、bundle 和判定结果见 `CASES.md`。

## 产品路线

### Phase 1：协议内核

- 完成 Evidence Bundle JSON 格式。
- 增加环境、依赖和产物摘要模型。
- 增加 schema version 和向后兼容规则。
- 提供 `bundle validate` 与 `bundle diff`。

### Phase 2：采集器

- 采集 `moon check`、`moon test`、`moon build` 和 `moon run` 结果。
- 记录命令、目标、退出状态、输出摘要和执行时间。
- 记录 `moon.mod`、`moon.pkg`、生成接口文件和依赖快照。
- 接入 SARIF、JUnit、coverage 和 benchmark 文件引用。

### Phase 3：发布与治理

- 产物 hash、源文件 hash 和 API snapshot。
- 包版本之间的证据差异分析。
- 依赖许可证和来源审计。
- CI release gate：没有可复现证据就拒绝发布。
- 可选签名和 attestation 适配器。

### Phase 4：Moocakes 生态集成

- 包元数据和证据包索引。
- API surface 与版本变化分析。
- 依赖风险、维护活跃度和许可证报告。
- 在不替代 Moocakes registry 的前提下提供质量证据视图。

## 与已有生态的边界

本项目明确避让：

- `moonbitlang/workflow`、`bitflow`、`actrun`：不执行通用工作流，不做 CI Runner。
- `MoonFrame`、`moon_databridge`：不做 DataFrame、CSV 导入或通用数据转换。
- `moonschema`、`json-schema`、`moon_zod`：不做 JSON Schema 验证器。
- `eventrail`、`moonevent`：不做 Event Bus、Pub/Sub 或消息重试。
- `moon_tracelens`、`moon_tracekit`：不做通用日志分析或 observability SDK。
- `moonsarif`、`moonreport`：不替代 SARIF 或诊断渲染库，而是保存它们的结果引用。
- `moon-hive`、`moon-proof`：不替代工具链诊断和文档示例验证，而是统一这些工具产生的证据。

项目的独立边界是：**Evidence Bundle 数据模型、可复现指纹、跨工具证据关联和发布前差异分析**。

### Mooncakes 功能边界核验

`Kai-Junhan/moonbit-evidence-bundle@0.1.0` 已发布并可通过 Mooncakes 搜索 API 检索。发布包的功能是证据协议、Moon CLI/JUnit 结果适配、规范化序列化、SHA-256、校验、diff 和 release gate。

搜索结果中出现的其他包即使在描述中提到 “evidence bundle”，其功能也不同：本项目不做 `MoonSecureCodec` 的 Merkle/SBOM 供应链清单，不做 `lockwire` 的测试运行底座，不做 `isoproject` 的工程工作台/运行时观测，也不做 workflow、telemetry、dependency scanner 或 registry 服务。这里的证据包是跨工具结果的稳定交换格式，而不是这些领域系统的替代品。完整检索与边界记录见 `MOONCAKES_BOUNDARY.md`。

## 证据包格式（format_version 0.1）

```json
{
  "format_version": "0.1",
  "project": "demo",
  "toolchain": "moon 0.1.20260703",
  "entries": [
    {
      "id": "report",
      "kind": "Artifact",
      "status": "Passed",
      "label": "first bundle report",
      "command": null,
      "detail": null,
      "digest": "24e44dbb5b4eec00bde3c7a551acf2754dffffddc8d2a95bb43ffe380370d802"
    }
  ]
}
```

- `kind`：`Build`、`Test`、`Run`、`Diagnostic`、`Artifact`、`Dependency`。
- `status`：`Passed`、`Failed`、`Skipped`。
- `command` / `detail` / `digest` 缺失时为 `null`。
- `digest` 为条目内容的小写 SHA-256 hex；只保存摘要，不保存原始内容。
- `canonical_fingerprint` 为规范化 JSON 字符串；`bundle.digest()` 为其 SHA-256。
- `validate(bundle)` 返回 `Valid` 或带问题列表的 `Invalid`，用于发布前结构校验。

## 架构

```text
Moon CLI / test / build / run
       │
       ├── SARIF / JUnit / coverage / benchmark adapters
       ├── dependency / license / API snapshot adapters
       ▼
Evidence Bundle Protocol
       │
       ├── validate
       ├── fingerprint
       ├── diff
       ├── query failed evidence
       └── release gate
       ▼
JSON bundle / CI artifact / Moocakes quality view
```

核心数据模型保持无平台 I/O，采集器和 CLI 位于边界层，便于支持 Native、Wasm GC 和 JS。

## 开发

```sh
moon fmt
moon info
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc
moon test --target wasm-gc --deny-warn
moon run --target wasm-gc cmd/demo
```

Demo 会生成两次内存中的证据包：第一次全部通过，第二次包含失败测试和诊断条目，然后打印规范化内容、失败数量、差异结果和 release gate 判定，接着从 `moon test` 和 `moon check` 原始输出解析证据条目，最后打印产物摘要和 bundle SHA-256。

## Hackathon 交付物

- 公开 GitHub 源码仓库。
- MIT License 和来源审计。
- Evidence Bundle 格式说明。
- 可复现的 CLI Demo 和样例 bundle。
- 协议层、采集器和差异分析测试。
- MoonBit 多目标构建记录。
- GitHub Actions 持续集成，覆盖格式化、检查、构建和测试。
- Mooncakes 包 `Kai-Junhan/moonbit-evidence-bundle@0.2.0`。
- 演示视频：从 Moon 项目执行检查到生成 bundle，再到两次 bundle diff。

## 许可证

MIT License，见 `LICENSE`。
