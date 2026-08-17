# Effect Mesh Generator (Unity)

入口：`TATools/VFXTools/Utilities/特效网格生成器`

网格类型：Slash、Ribbon、Lightning Ribbon、Arc、Arc Ribbon、Plane、Flat Ring、Sphere、Hemisphere、Z Hemisphere、Open Cylinder、Beam Dome、Rising Spiral Ribbon、Cylinder Spiral Ribbon。Honeycomb 不迁移。

支持实时预览、可交互缩略图模板库、Cross Mesh、独立正反层双面网格、顶点 Alpha、Pivot/Scale/Rotation、UV Tiling/Rotation、UV0 二维检查、Mesh Asset/OBJ/FBX 导出、创建场景对象、应用到选中 Particle System。

OBJ 始终使用插件内置导出器。FBX 会自动检测 `com.unity.formats.fbx`：已安装时调用官方 API，未安装时使用内置 ASCII FBX 导出器，并在窗口中提供 Package Manager 安装入口。两种格式均保留顶点、三角形、法线、UV 与顶点色/Alpha。

3D 操作：左键旋转，中键平移，滚轮缩放。UV 检查：左/中键平移，滚轮缩放。

生成到场景或粒子系统时，Mesh 默认保存到 `Assets/Generated/VFXMeshes/`。材质由项目 VFX 材质另行指定。
