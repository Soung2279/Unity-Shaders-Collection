# EffectMeshGenerator：Three.js → Unity 迁移记忆

> 用途：供后续 Agent 快速理解迁移背景、最终实现、关键语义、踩坑和验证方法。  
> 原仓库：<https://github.com/big615big615/EffectMeshGenerator>  
> 原示例：<https://big615big615.github.io/EffectMeshGenerator/>  
> Unity 插件目录：`Assets/Editor/VFXTools/EffectMeshGenerator/`  
> 当前目标环境：Unity 2022.1.24f1、URP 13.1.9。

## 1. 迁移范围与最终决策

迁移目标不是简单复刻网页外观，而是保留 Three.js 版的网格生成语义、参数、UV 检查和交互体验，并转成 Unity Editor 插件。

已迁移网格：

- Slash
- Ribbon
- Lightning Ribbon
- Arc
- Arc Ribbon
- Plane
- Flat Ring
- Sphere
- Hemisphere
- Z Hemisphere
- Open Cylinder
- Beam Dome
- Rising Spiral Ribbon（Tornado）
- Cylinder Spiral Ribbon（Tornado）

范围决策：

- Honeycomb 明确不迁移，不要新增枚举、模板或缩略图。
- Tornado 已迁移上述两类。
- 枚举中的 Tornado 类型追加在末尾，以避免改变旧序列化枚举值。
- 编辑器入口：`TATools/VFXTools/Utilities/特效网格生成器`。

## 2. 当前文件职责

| 文件 | 职责 |
|---|---|
| `EffectMeshParameters.cs` | 网格类型、可序列化参数、Sanitize、默认模板 |
| `EffectMeshGenerator.cs` | 程序化几何核心、双面/Cross、顶点色、输出变换 |
| `EffectMeshGeneratorWindow.cs` | EditorWindow、预览、交互、UV 检查、模板库、保存与导出入口 |
| `EffectMeshModelExporter.cs` | OBJ、官方/内置双后端 FBX 导出 |
| `EffectMeshPreview.shader` | 正反面绿/红、贴图、顶点 Alpha 预览 |
| `EffectMeshWireframe.shader` | 线框、UV 线、场景网格和 Pivot 彩色轴 |
| `EffectMeshUVPreview.shader` | UV 检查底图采样 |
| `Game.VFXTools.EffectMeshGenerator.Editor.asmdef` | 独立 Editor 程序集；不硬依赖 FBX Exporter |

## 3. 推荐的迁移步骤

### 3.1 先还原数据模型

1. 从原 Three.js 源码梳理所有 `meshType`、参数、默认模板和可见条件。
2. 在 Unity 建立 `EffectMeshType` 与 `EffectMeshParameters`。
3. 将模板默认值集中在 `EffectMeshTemplates.Get(type)`，不要散落在窗口代码中。
4. 参数修改前克隆数据，生成前统一 `Sanitize()`。

### 3.2 迁移程序化几何

1. 将每种 Three.js geometry 转成统一 `MeshData`：vertices、uvs、colors、triangles。
2. 所有网格生成结束后统一处理：
   - Cross Mesh
   - 独立双面几何
   - Mirror Z 与绕序
   - Pivot / Scale / Rotation
   - UV Rotation
3. 最后一次性生成 Unity `Mesh` 并重算法线、切线和 Bounds。

重要：不要把 Unity 材质 `Cull Off` 当成“双面网格”。双面选项必须复制一份背面顶点/UV/颜色，并反转背面三角形绕序，形成真实独立几何。

### 3.3 迁移编辑器参数与交互

1. 用 EditorWindow 左侧参数、右侧 PreviewRenderUtility。
2. 类型切换时应用对应模板。
3. 预览使用独立 Mesh，不污染场景。
4. Orbit 参数贴近原版：
   - `dampingFactor = 0.08`
   - `rotateSpeed = 0.8`
   - 参考帧率 60 FPS
5. 当前拖动方向：
   - 水平：`e.delta.x`
   - 垂直：`e.delta.y`
   - 垂直方向已按用户要求反转过，不要恢复成 `-e.delta.y`。

### 3.4 迁移 UV 检查

1. 保留原网格预览，不要在开启 UV 时关闭或折叠。
2. 使用左右双面板：左 3D 网格、右 UV0 平面。
3. 动态生成 8×8、编号 1–64 的彩色 UV Checker。
4. UV 网格仅用于右侧 UV 面板，不能泄漏到左侧 3D Preview Scene。
5. `UV Tiling` 与滚动只作用于检查纹理采样，不要烘焙进 Mesh UV。
6. UV Rotation 才写入最终 UV，支持 0°、90°、180°、270°。
7. UV 滚动速度当前为 `0.35 UV/s`。

### 3.5 模板库

1. 模板库替代右侧正常预览区域，左侧参数区保留。
2. 每个类型使用 `EffectMeshTemplates.Get(type)` 生成独立缩略图。
3. 自适应 1–4 列，宽窗口通常为 4 列。
4. 每格可拖拽旋转；点击时应用默认参数、关闭模板库、返回正常预览。
5. 通过拖动阈值区分“点击选择”和“拖拽旋转”。
6. 当前类型用绿色边框/底色高亮。
7. Honeycomb 必须排除。

### 3.6 导出

OBJ：

- 始终使用内置导出器。
- 输出 position、normal、UV0、vertex RGBA、triangle。
- Unity → OBJ 时镜像 X 并调整面绕序，保持正面方向。

FBX：

- 不允许插件对 `Unity.Formats.Fbx.Editor` 建立编译期引用。
- 用反射检测：
  `UnityEditor.Formats.Fbx.Exporter.ModelExporter, Unity.Formats.Fbx.Editor`。
- 已安装 `com.unity.formats.fbx`：反射调用官方 `ExportObject(string, Object)`。
- 未安装：使用内置 ASCII FBX 7.4。
- 窗口必须提示当前后端；未安装时显示 Warning 和“在 Package Manager 中安装 FBX Exporter”按钮。
- Package Manager 跳转：
  `UnityEditor.PackageManager.UI.Window.Open("com.unity.formats.fbx")`。

## 4. 已确认的参数语义

### 4.1 输出变换

核心顺序位于 `ApplyOutputTransform`：

```text
原顶点
→ Mirror Z
→ (vertex - pivot)
→ Scale
→ Rotation
```

因此生成后的局部轴点是 `(0,0,0)`。Preview Pivot 必须从世界/模型原点绘制，而不是从 Bounds Center 或屏幕中心绘制。

### 4.2 顶点 Alpha

- Alpha 写入 `Mesh.colors32.a`。
- Preview Shader 必须读取顶点色 Alpha。
- Wireframe 可选择跟随顶点 Alpha。
- FBX 官方后端和内置后端均需保留 RGBA。

### 4.3 UV

- Mesh UV：仅受 UV Rotation 影响。
- 检查贴图：受 Tiling、Offset、Scroll 影响。
- 不要将 Tiling/Scroll 写回 Mesh UV，否则导出内容和原版语义会错误。

### 4.4 双面与 Cross

- `doubleSided`：复制真实背面几何，不能只翻法线。
- `crossMesh`：生成第二个交叉表面，不是材质渲染技巧。

## 5. 预览系统最终状态

### 5.1 正反面与线框

- 正面绿色、背面红色。
- 网格分段以 Wireframe 可视化。
- 主预览线框通过相机方向的小偏移重复绘制，约 `1.35 px` 视觉粗细。
- 模板缩略图约 `1.2 px`。
- 不要依赖平台线宽 API；Unity 的线图元通常固定为 1 px。

### 5.2 Blender 风格背景

- 预览不再使用纯黑背景。
- 真实 3D 透视地面网格，包含主/次网格线。
- 世界 X/Y/Z 轴分别为红/绿/蓝。
- 背景辅助线与网格共享 Preview 相机，所以会正确透视和随 Orbit 变化。

### 5.3 Pivot

- 旧实现是在 GUI 层固定画二维红/绿十字，位置和旋转都错误，已删除。
- 当前 Pivot 是真正的 3D RGB 三轴线，带箭头。
- 原点为最终 Mesh 的局部 `(0,0,0)`。
- 方向应用 `parameters.rotation`。
- 同时考虑负 Scale 与 Mirror Z 的轴方向。
- Pivot 必须与 PreviewRenderUtility 使用同一相机。

## 6. 迁移中遇到的问题与解决方案

### 问题 1：双面只是翻法线

症状：背面没有新几何，顶点/三角形数量不增加。  
原因：把双面渲染和双面网格混淆。  
解决：分别生成 front/back MeshData，追加背面顶点并反转背面绕序。

### 问题 2：Twist 参数看起来无效

原因：部分几何只在局部截面或中心线中应用 Twist，迁移时遗漏或应用顺序错误。  
解决：在对应网格每个长度采样段中基于归一化进度计算角度，对横截面/径向方向旋转；最终 Rotation 仍放在统一输出变换阶段。

### 问题 3：顶点 Alpha 写入了但预览不显示

原因：Preview Shader 没有乘 `input.color.a`，或使用不透明混合。  
解决：Shader 读取顶点色并让输出 Alpha 乘顶点 Alpha；开启透明 Blend。

### 问题 4：UV Tiling 被错误写入 Mesh

症状：导出 UV 被永久缩放，UV 面板和 Three.js 不一致。  
原因：把检查贴图的纹理变换当成几何 UV 变换。  
解决：Tiling/Offset/Scroll 仅设置材质采样；Mesh UV 只处理 Rotation。

### 问题 5：左侧 UV 网格出现在 3D 预览中

原因：UV 辅助 Mesh 与 3D Mesh 共用 PreviewRenderUtility/场景。  
解决：3D 和 UV 各自使用独立 PreviewRenderUtility；UV 辅助对象只提交给右侧渲染器。

### 问题 6：Orbit 没有 Three.js 的缓动

解决：保存拖动增量，Update 中按帧率无关的 retention 衰减：

```text
retention = (1 - dampingFactor)^(deltaTime * 60)
step = 1 - retention
```

相机轨道、Pan 都使用这一套阻尼。

### 问题 7：FBX 包硬依赖导致未安装时无法编译

症状：`UnityEditor.Formats.Fbx` 命名空间不存在。  
原因：代码直接 using 官方包，asmdef 直接引用包程序集。  
解决：移除 using/asmdef 引用，用 `Type.GetType` + `MethodInfo.Invoke` 动态调用。

### 问题 8：最初内置 ASCII FBX 导入后只有 Transform

症状：Unity 识别 FBX 根节点，但没有 Mesh/MeshFilter。  
原因：FBX ASCII 对格式结构敏感，简化过度；尤其 `References` 和 `Takes` 不能写成单行空块，Definitions/Object/Connections 也必须完整。  
解决：

- 使用 FBX 7.4 Header、GlobalSettings、Documents、References。
- Definitions 提供 Model、Geometry、Material PropertyTemplate。
- Geometry 提供 vertices、polygon indices、normals、UV、colors、material layer。
- Model、Material、Geometry 使用稳定唯一 long ID 并建立 OO Connections。
- `References`、`Takes` 使用多行 block。

最终内置/官方 FBX 均通过 Unity 回读：99 vertices、128 triangles、UV 99、normals 99、colors 99。

### 问题 9：Pivot 与网格不匹配

症状：Pivot 固定在面板中心、不旋转、不对齐原点。  
原因：使用 GUI Overlay 画二维线。  
解决：建立 3D Lines Mesh，从最终网格局部原点出发，应用 Rotation/轴符号，并由 Preview 相机渲染。

### 问题 10：垂直拖动方向相反

解决：主预览 Orbit 的 X 旋转增量使用 `e.delta.y`，不要取负。

## 7. 生命周期与资源管理

所有 Preview 临时对象必须使用 `HideFlags.HideAndDontSave`，并在以下时机销毁：

- 网格参数变化导致 Rebuild
- 离开模板库或重建模板库
- Window `OnDisable`
- PreviewRenderUtility 重建

需清理：

- Preview Mesh、Wire Mesh、UV Wire Mesh
- UV Background Mesh
- 3D Scene Grid Mesh
- Pivot Axes Mesh
- Checker Texture
- 所有临时 Material
- 每个模板缩略图 Mesh/Wire Mesh
- 所有 PreviewRenderUtility 调用 `Cleanup()`

不要销毁或覆盖用户工程中的已有 Asset。

## 8. Read/Write 设置结论

用于刀光、气流等纯渲染特效时：

- FBX/OBJ 导入后的 `Read/Write Enabled` 可以关闭。
- UV、法线、顶点色、顶点 Alpha 与 GPU 渲染不依赖 CPU Read/Write。
- 只有运行时读取/修改 Mesh、CPU 粒子采样、VFX Graph Mesh 采样、运行时合并或碰撞生成时才需要开启。
- `.asset` Mesh 不经过 ModelImporter，不显示同样的 Read/Write 开关；没有运行时 CPU 释放需求时无需额外处理。

## 9. 验证流程

每次结构性修改后执行：

1. Locus `code_diagnostics` 检查修改的 C# 文件。
2. `unity_recompile` 完整重编译并等待 domain reload。
3. 打开 `特效网格生成器`，检查：
   - 类型切换
   - 参数实时更新
   - 线框分段
   - 正反面颜色
   - 顶点 Alpha
   - Twist
   - 双面顶点/三角形数量
   - UV 双面板、Rotation、Tiling、Scroll
   - 模板库选择和单格拖拽
   - Blender 风格背景、Pivot Rotation/Origin
4. OBJ/FBX 导出到临时 Validation 目录并重新导入。
5. 对比 source/imported：vertex、triangle、UV、normal、color 数量。
6. 删除验证资产及 `.meta`，不要把测试资产留在 `Assets/Generated/`。

已知工程无关噪声：

- HybridCLR `MethodHook ... can not be null`
- Firebase Windows/iOS 警告
- TEMP allocator 报告

这些不是本插件编译错误；仍需确认 Console 中没有指向本插件文件的错误。

## 10. 后续 Agent 接手注意事项

- 修改前先读本文件、`README.md` 和四个核心 C# 文件。
- 不要重新引入 Honeycomb。
- 不要把 FBX Exporter 改回硬依赖。
- 不要把 UV Tiling/Scroll 烘焙进 Mesh UV。
- 不要用 `Cull Off` 冒充双面网格。
- 不要用 GUI 二维线代替 3D Pivot。
- 不要让 UV 辅助 Mesh 进入 3D Preview Scene。
- 保持 Tornado 枚举值追加顺序。
- 当前工作树可能包含大量用户改动，只修改插件目录内相关文件。
- 输出临时导出文件后必须清理。

## 11. 当前完成状态

- 核心几何：完成
- 参数与模板：完成
- Tornado：完成
- Honeycomb：明确不迁移
- 双面/Cross：完成
- Wireframe、正反面、顶点 Alpha：完成
- UV 检查/滚动/旋转：完成
- Three.js 风格 Orbit 阻尼：完成
- 缩略图模板库：完成
- Mesh Asset / OBJ / 双后端 FBX：完成
- Blender 风格 3D 背景：完成
- 3D Pivot：完成

