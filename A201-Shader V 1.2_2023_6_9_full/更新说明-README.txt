2023.6.9 | 更新说明 | Standard 1.2

说明：添加合集版本号，方便归档。
新增：新增额外菲涅尔、多重遮罩溶解、标准PBR、额外色差与屏幕扭曲Shaders。
修复：修复部分Shader功能失效的错误。
优化：将SinC_Blend进行性能优化。
汉化：完整汉化新增Shader，并进行归纳排版。
#请导入文件目录下的Amplify Shader Editor(ASE)包来修复报错问题。
#此次更新将Built-in/URP/HDRP等渲染管线平行分离，此次更新仅适用于Built-in。
===================

2023.5.18 | 更新说明 | Standard 1.1

新增：新增屏幕扭曲shader，使用法线贴图来控制屏幕扭曲效果。
#已知故障：进阶处理-多功能溶解ADD/Alpha Double的自定义顶点流可能失效，等待ShaderForge重置修复。
===================

2023.5.4 | 更新说明 | Standard 1.0

资源优化：移除了部分失效Shader。
目录层级重构：现在所有Shader均按使用类型放置在A201-Shader/目录下。
更新：更新后期处理shader到最新版本，更新LTY-shader到最新版本。
增添：部分复杂Shader在面板中添加了导航链接。
#重构：使用UnityPackage打包资源，而非直接以文件夹形式传输。
===================

2023.4.17 | 更新说明 | Beta 0.2

修复：修复了"RongJieSD"持续提示缺失GUI脚本的错误。
更新：新增三个URP特供卡通着色Shader。
完善：完善了README，重归类文件目录结构。
===================

2023.3.24 | 更新说明 | Beta 0.1

#说明
大部分Shader已做汉化。
已将Shader整合到同一目录下，目录结构如下:

A201-Shader/
A201-Shader/MP/
A201-Shader/Blench/
A201-Shader/XIXI/
A201-Shader/SoungTest/
......

//AxiuEffectsShader.shader
将"CustomEffectShaderGUI.cs"放在Unity编辑器目录"/Editor"下可正常使用。

//UnityURPToonLitShaderExample
#只能在URP下使用
同目录包含额外文件，原版未作汉化。

//PrimoToon
#只能在URP下使用
同目录包含额外文件，原版未作汉化。

//GenshinCharacterShader
#只能在URP下使用
同目录包含额外文件，原版未作汉化。
原神特供整合Shader，需要完整的Ramp/LightingMap/Metal等贴图。
===================