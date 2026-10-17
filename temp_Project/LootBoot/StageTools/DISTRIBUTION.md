# StageTools 怪物点位工具分发说明

## 功能

- 怪物点位预览：查询 `MonsterSpawnType` → `MonsterSpawns` → `MonsterFormation` → `Actor`
- SceneView 点位浮窗：在 Prefab Mode 下为每个点位绘制浮窗，显示怪物中文名 + 数量 + 预制体预览快照（不显示阵型）；由“一键刷新当前预制体”驱动
- 点位池统计：在预览窗口显示当前关卡的“已用点位”与“可用点位”，随预览缓存同步刷新
- 怪物点位配置草稿：单点修改阵型、怪物 ID、数量和点位描述
- 安全写入：只修改 `MonsterFormation.xls` 的 C、D、F 列，每次提交保留独立备份

## 分发内容

以下文件需要随 Unity 工程一起提交/复制，路径不能改变：

- `MonsterPointPreviewWindow.cs`
- `MonsterPointEditWindow.cs`
- `StageToolsIO.cs`
- `monster_point_query.exe`
- `monster_point_excel_write.ps1`
- 对应 `.meta` 文件

`monster_point_query.py` 仅作为 Python 回退和重新打包源码，不是无 Python 环境用户的运行依赖。

写入备份不随工程提交：应用时会自动创建 `Assets/Editor/StageTools/StageToolsBackup/`，每次提交创建独立的 `MonsterFormation-<token>.backup.xls`，不会覆盖其他数据源或上次提交的备份。旧版本的固定备份保留不动。

## 使用前置条件

### 查询与预览

无需安装 Python、xlrd 或其他 Python 依赖。Unity 工具优先调用同目录的单文件：

```text
Assets/Editor/StageTools/monster_point_query.exe
```

### 修改应用

应用到 Excel 时不需要 Python，但需要：

1. PowerShell 7（推荐）或 Windows PowerShell 5.1
2. 本机安装 Microsoft Excel（用于以 COM 方式原位修改旧版 `.xls`）
3. Excel 表格目录可访问，且目标表没有被其他程序锁定

工具优先使用 PowerShell 7：

```text
%PATH% 中的 pwsh.exe，或 %ProgramFiles%\PowerShell\7\pwsh.exe
```

如果不存在，则回退到 Windows PowerShell 5.1：

```text
%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe
```

实测单次应用耗时：PowerShell 7 约 3 秒，Windows PowerShell 5.1 约 5～6 秒。耗时主要由本机 Excel COM 启动、写入与复核构成。

## Excel 表格要求

默认目录：

```text
D:\WorkFoldersDoc\Excel
```

必须包含：

- `MonsterSpawnType.xls`
- `MonsterSpawns.xls`
- `MonsterFormation.xls`
- `Actor.xls`

其中只有 `MonsterFormation.xls` 会被修改，另外三张表只读。Excel 目录内会短暂创建工作副本（`.~stage-tools-*.xls`）和提交恢复标记（`MonsterFormation.xls.stage-tools-pending.json`），正常完成会清理。备份保存在工具目录。

## 安全特性

写入前会：

- 检查目标文件名必须是 `MonsterFormation.xls`
- 草稿绑定 Excel 目录、Prefab 资产路径和唯一点位对象；读取时保存四张关联表的 SHA-256 快照
- 校验四张表未发生变化，防止点位上游关联改变后仍写入旧组合
- 校验读取草稿时的原阵型、原怪物组合和原描述没有被外部修改
- 通过进程互斥和文件句柄锁保护提交；锁定三张关联表，独占 MonsterFormation，其他程序无法写入或重命名
- 在临时副本中写入
- 只写入 MonsterFormation 的 C、D、F 单元格
- 保存并关闭临时工作簿，重新打开校验目标值、公式、批注、工作表结构及目标 C/D/F 的格式；这不是全工作簿所有格式属性的逐项证明
- 提交前持久化独立备份与恢复标记，然后通过同一独占句柄写入并核验字节哈希，避免检查后释放锁造成并发覆盖
- 此提交不是断电原子替换。可捕获异常会回滚；断电或强杀期间可能留下恢复标记。若表格损坏，应依据标记中的备份路径检查并恢复，不能直接删除标记后继续写入
- 直接输入的阵型必须是 PointSpawn 中存在的 Prefab
- 直接输入的 Actor ID 必须存在于 Actor 表且数量大于 0
- 应用修改前要求“当前选中点位”与“当前修改点位”一致，否则拒绝应用并弹窗提示
- 点位一致性同时比较数据源、Prefab 路径、关卡 ID、点位 ID 和对象实例；`Stage_01` 与 `Stage_01_B` 不能互相提交草稿，同名重复点位也会拒绝编辑
- 多波次或多 MonsterFormation 配置的点位不会默认选择第一条，编辑时会拒绝并提示
- MonsterGroup 要求正整数 ID 与数量；空串、零、负数、小数、溢出及空项均标记异常，不再截断小数
- 支持 PointGroup / Fromation 按分号位置对应；分段数量不一致会拒绝查询，不猜测映射
- 缓存按规范化 Excel 目录隔离保存于 `Library/StageTools/`，内部按 Prefab 路径、关卡和点位区分；载入时验证四表哈希，旧版本无来源的缓存不再读取
- 刷新失败会使该关点位缓存与点位池失效，不继续显示旧成功结果
- 应用成功后整体刷新目标预制体的全部五位数点位（含未缓存点位及非激活节点），同步点位池并移除已删除点位的缓存；其他预制体中已缓存的共享组合引用也会刷新，仅处理相同 Excel 数据源
- 写表期间若仍在同一目标 Prefab Mode，刷新时读取最新层级；若已切换或关闭，则使用提交前的完整点位快照，不会误刷新新打开的预制体
- Excel 提交与缓存刷新/落盘分别报告；缓存失败不会误报 Excel 写入失败
- 查询与写表异步执行，双输出流同时读取，120 秒超时后结束本次进程树并提示重新查询确认状态

## 一次性草稿流程

1. 在预览窗口设置 Excel 目录，进入关卡 Prefab Mode 并唯一选中点位。
2. 点击预览窗口的“修改此点位”，读取最新表格并创建草稿。草稿窗口菜单只打开空窗口，不提供自行读取入口。
3. 草稿固定绑定点击时的数据源、Prefab 和点位。每次创建草稿（包括刷新缓存后重新创建）默认自动生成描述；B/F/J+数字阵型分别使用包围/分散/聚集前缀，其他阵型保留原说明。自动生成结果与原文不同时标记草稿已修改，仍须确认应用才写表。直接编辑描述才切换为手动，可点击“恢复自动”重新启用。
4. 应用前显示目标与共享组合影响范围；确认时仍必须选中原点位。写入期间请求固定，不会追随之后的选择变化。
5. 应用成功立即清空全部草稿，再独立刷新预览；提交异常或超时也清空，须重新查询确认实际状态。只有再次点击预览窗口“修改此点位”才能创建新草稿。

同一 MonsterFormation 被多个点位引用时，修改该组合仍会影响全部引用；确认框会说明影响范围。点位绑定防止写错目标，并不复制或拆分共享组合。

## SceneView 点位浮窗与点位池

### 点位浮窗

- 仅在 Prefab Mode 下、且当前工具窗口存在时绘制。
- 由“一键刷新当前预制体”建立缓存后，为预制体内每个五位数点位绘制浮窗。
- 浮窗内容：点位 ID、怪物中文名（Actor 表 Name，非预制体名）、数量、怪物预制体预览快照。不显示阵型。
- 怪物预览复用预览窗口的实现：Spine 类型走 `SpinePrefabPreview`，Sprite 类型走 `AssetPreview`；保留每个波次/候选组合各自的怪物数量，不去重或盲目相加；超过四行可在卡片内滚动查看。
- 可通过窗口内“在 SceneView 绘制点位浮窗”开关临时关闭。
- 未查询的点位显示“未查询”，查询异常的点位显示“查询异常”。
- 浮窗宽度固定为 210px；行高、图标尺寸随字号自适应。
- 锚点为卡片左上角：以点位为原点，卡片向右下方展开（偏移 10px）。
- 点位不在当前视野内时不绘制浮窗，避免卡片被钳制到视图边缘而与实际点位脱节。
- 可见性以相机视口（`camera.pixelRect`）为边界，而不是场景视图窗口矩形；后者包含顶部工具栏，会把底部一条窄带内的点位误判为可见。
- 对于仍在视野内但贴近右/下边缘的点位，卡片会回推以保证完整可见。

### 浮窗外观参数

工具窗口在开关下方暴露两个参数，调整后实时生效（仅影响显示，不影响数据）：

- 浮窗字体大小：6～24 px，默认 12。
- 浮窗底板不透明度：0.05～1，默认 0.6。

### 可用点位池

- 数据来源：`MonsterSpawnType.xls` 中第 2 列（说明）= 关卡 ID、第 3 列（孵化点位ID）= 五位数的记录。
- “已用点位”显示当前预制体已有点位，点位 ID 标红；“可用点位”显示表格登记且尚未使用的点位，保留默认颜色。两行分别列出数量和 ID。
- 空预制体也能通过一键刷新查询点位池。
- 若预制体中有五位数点位未在表格登记，额外显示“注意”行列出它们。
- 已用/可用状态在每次重绘时按当前预制体实时重算，因此在下列时机都会同步刷新：
  - 执行“一键刷新当前预制体”或写入 Excel 后的自动刷新；
  - 切换选中对象、切换 / 关闭 Prefab Mode；
  - 预制体层级发生增删改动（订阅 `EditorApplication.hierarchyChanged`）。
- 点位池内容随查询与预览缓存一起写入缓存文件。

## 分发检查

接收同事只需关闭 Unity、将这些文件放入对应工程路径并重新打开 Unity，即可使用查询和预览功能，不需要 Python 环境或安装 xlrd。

如果需要使用“应用到 Excel”，还必须满足上面的 PowerShell 和 Microsoft Excel 前置条件。
