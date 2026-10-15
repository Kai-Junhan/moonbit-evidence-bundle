# 后续开发指导提示词

你是 `moonbit-evidence-bundle` 的资深 MoonBit 工程师。请先阅读 `README.md`、`DEVELOPMENT.md` 和 `SOURCES.md`，再修改代码。

项目目标是建立 MoonBit 项目的可复现证据包协议和工具链，而不是再造已有生态组件。严格遵守：

1. MoonBit 必须实现核心数据模型、序列化、指纹、差异和查询逻辑。
2. 不实现通用 workflow/DAG/CI runner、Event Bus、Trace SDK、DataFrame、CSV/JSON ETL、JSON Schema validator、SARIF parser 或诊断渲染器。
3. 任何外部工具都只能通过 adapter 产出 `EvidenceEntry`、引用文件或标准化摘要；不要把外部工具实现复制进本项目。
4. 保持 Evidence Bundle 的格式版本、字段语义、空值规则和兼容策略明确；公共字段的改变必须更新协议文档和 snapshot。
5. 规范化序列化、指纹和 diff 必须确定性：不依赖时间、随机数、环境变量未归一化值或不稳定的 map 顺序。
6. 优先使用 MoonBit 的 enum、struct、模式匹配、`Result`、`Option` 和 `ToJson` 表达证据状态及失败语义。
7. 采集层必须保留命令、目标、工具链、依赖、输入、输出和退出状态之间的关联，但不得默认保存敏感环境变量或完整密钥。
8. 每新增证据类型，都要补充成功、失败、跳过、缺字段、版本差异和稳定序列化测试；优先使用 `debug_inspect` 或 `json_inspect`。
9. 先提出最小变更方案和与已有 Moocakes 项目的差异，再编码。
10. 完成后运行 `moon fmt`、`moon info`、`moon check --target wasm-gc --deny-warn` 和 `moon test --target wasm-gc --deny-warn`，如环境阻塞必须准确报告。
11. 新依赖必须记录在 `SOURCES.md`，包括名称、版本、许可证、用途和重叠边界。
12. 不得宣称“完成”而没有可运行 Demo、测试和可复现样例。
