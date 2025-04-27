<p align="center">
  <a href="http://dh.cqie.edu.cn" target="_blank"><img src="https://s1.vika.cn/space/2023/06/09/cec04453495644d3a9bf2a000784bd8d" ></a>
  </a>
</p>


A201-Shaders Collection  ///  Personal Usage
===========================
<div align="left">


→→ **[查看更新日志](#更新日志)**    →→ **[前往下载地址](https://github.com/Soung2279/Unity-Shaders-Collection/releases)**



简介
===========================

收录用于``Unity``的``Built-in`` & ``URP`` 适用的 **着色器合集**。若您有一定技术美术知识，您可读取着色器中的片段代码，并将其迁移到其它引擎(如UE，GoDot等)中。

### 仓库来源

本仓库是[个人](https://github.com/Soung2279)在学习与工作生涯中，对制作、收集的各种shader进行的统一收录。本仓库收录的shader适用于[Unity](https://unity.com/cn)引擎，绝大部分用于*特效制作*。均作了大量 **汉化** 处理。

### 文件说明

为了方便使用，本人将所有的着色器目录路径(Shader Path)均 **统一**在了 **Soung/** 路径下，并按着色器的使用类型进行了 **分类** 。方便特效艺术家、技术美术等进在编辑器中进行直观的shader切换。

因游戏美术行业发展迅速，技术日新月异，本仓库收录的shader适用的环境为：

[![Unity](https://img.shields.io/badge/Unity%20-2018%2B-black?style=flat-square&logo=unity)](https://unity.com/cn)
[![Static Badge](https://img.shields.io/badge/UniversalRenderPipeline%20-7%2B-black?style=flat-square)](https://docs.unity3d.com/cn/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html)


- [x] ``Unity 2018-2023``, ``ALL Built-in``, ``Universal Render Pipeline 7.0-16.0``

- [ ] 理论上支持 ``Unity 6.000`` 和 ``TuanJie 1.0``, ``Universal Render Pipeline 17.0`` 及以上系列。

*暂时未收录 ``HDRP`` 可用的shader。*


<details>

<summary>(V1) 以往的shader分类</summary>

~~目前存在的分类如下:~~
- ~~全面功能：包含溶解、遮罩、扭曲、偏移、菲涅尔等多项功能的全面shader~~
- ~~基本效果：基础的additive或alphablend着色器~~
- ~~后期处理：用于屏幕特效、色散、黑白闪、晕影等~~
- ~~进阶功能：多遮罩或多功能的单项shader~~
- ~~特殊制作：视差地裂、流麻、分层纹理、渐变等特殊需求shader~~
- ~~未知类型：未知用途的shader~~

</details>

> 在漫长的工作生涯中，我认识到，shader并不在于多，而在于精、兼容性强和泛用性广。毕竟能跑就不要动它。同时，虽然以往收集的shader数量很多，但是大部分功能都重合了，并且由于代码风格不一，不便于功能迁移。所以，V2.0及以后的版本，会秉持简约的理念，尽可能收录一些通用的，快速上手的shader。同时我会对收集和个人制作的shader进行优化处理，使其能在部分中小型项目中直接使用。因为涉及到对Shader Path和部分shader代码的调整，所以V1与V2完全不互通。但是本质的业务代码都是可用的，只是V2更贴近项目需求。

本合集收录的shader大体分类为：
- 特效用单贴图着色器
- 多种溶解、扭曲、流光等着色器
- 复合功能特效着色器
- 后期处理 **屏幕扭曲/色差/晕影/黑白闪** 着色器
- 部分PBR相关着色器
- 简易卡通渲染着色器

开始使用
===========================

#### 1. 确认您的项目环境

- 确认您的Unity项目为何种渲染管线（通常为 ``Built-in`` 或 ``URP``，本仓库shader也仅支持这两种），根据对应管线在本仓库 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases) 处下载对应发布包。

#### 2. 解压已下载包

- 将下载好的Release包解压在任意目录，并将解压后的文件夹全部复制到您的Unity项目中，如果您不知道放哪个位置，请直接放在 ``Asset/`` 目录下。
- (可选)(将 "Amplify Shader Editor v1.9.1.5.unitypackage"，如项目中已有ASE则无需额外导入。)
- (本仓库大部分Shader使用ASE 1.9.1.5版制作/编辑，建议ASE环境不低于1.8)

#### 3. 检查控制台 ``Colsole`` 信息，若无意外，仅会产生黄色警告信息，不影响使用。

- (如有红色错误信息，可尝试检查错误来源或重新导入。)


> *额外：预制环境>>>
> 本仓库 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/RESOURCES_1) 提供了一个基础的特效制作环境（Unity项目压缩包），下载后即开即用，已预先配置好了着色器、后处理配置等（Shader包版本V1.5）。

#### 4. 着色器更新：

- 通常情况下，本合集目录不会有较大变更，在 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases) 处选择对应文件下载后，直接**覆盖更新**即可。覆盖后，请手动删除Unity对应路径下的 ``.meta`` 文件。

- 特殊情况下，在 [更新日志](#更新日志) 中应有对应的更新指南，按指南操作即可。若日志中没有给出更新方法，请备份上一版本的shader后，覆盖更新，并使用 ``notepad++``, ``Windows记事本`` 或 ``VSCode`` 等IDE打开shader，查看新的着色器目录路径(Shader Path)（通常在文件的前5行）。

- 自行更新：若您有更高版本或适用于新效果的着色器，推荐自行统一着色器目录路径(Shader Path)为 **A201-Shader/** 。

- 使用ASE编辑：若您想使用ASE自行编辑现有着色器，则可能出现汉化还原的情况，不影响使用，但建议 [此问题](https://github.com/Soung2279/Unity-Shaders-Collection/issues/1) 修复前避免使用ASE重复编辑 。

说明
========================

1. Shader使用：在Unity材质球处切换Shader时，选择"A201-Shader/"目录下的Shader即可，Shader已做分类处理。

2. 若部分ShaderGUI缺失，请检查包内的 ``Editor`` 是否正常导入。

3. 特殊说明：<p> ``PPX_BA_shader.shader`` (A201-Shader/特殊制作/BA式卡通着色器_PPX_BA)：需配合*SampleTex*中的嘴型遮罩 ``Mouth_mask.png`` 使用。 <p> ``流麻flow.shader`` (A201-Shader/特殊制作/URP视差流麻_Jiji)：需配合*SampleTex*中的粒子点噪 ``particle.png`` 使用。 <p>  [(已解决)](https://github.com/Soung2279/Unity-Shaders-Collection/issues/2) ~~``Soung_FlipAddtive.shader`` (同AlphaBlend) 使用 ``ASE`` ``Flipbook`` 节点制作，若出现边缘有无法消除的白线，请使用*SampleTex*中的修复遮罩 ``FlipMask.png``.~~ 已增加程序遮罩修复功能，更新shader即可。</p>

4. [(待解决)](https://github.com/Soung2279/Unity-Shaders-Collection/issues/1) 对于所有的汉化Shader来说，应尽可能**避免**使用 ``ASE`` 二次编辑，这会导致汉化失效。``ShaderGraph`` 则不受影响。

5. ``Post-Processing Scan`` 为脚本驱动的后处理屏幕扫描特效，使用方法详见 [Post-Processing-Scan - MirzaBeig](https://github.com/MirzaBeig/Post-Processing-Scan)

6. ``Soung_UICustom_Liuguang.shader`` 是用于UI通用流光材质的UI着色器，请使用*SampleTex*中的``saomiao.png``预览效果。(该着色器实现自定义间隔时间有一定性能开销，请注意)

## 特别鸣谢

[UnityURPToonLitShader](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)

[Post-Processing-Scan](https://github.com/MirzaBeig/Post-Processing-Scan)

[Bilibili: 多喝热水嗝嗝嗝](https://space.bilibili.com/2537966)

[Bilibili: Cz_wang](https://space.bilibili.com/15396626)
****

## 更新日志

### 2025.4.9 | 更新说明 | Obsoleted V1.9.0

*更新：*

更新全功能着色器（双管线）及其shaderGUI.

更新ASE包至1.9.81

*说明：*
此次更新后，V.1.9.0 Release包将作为最后一个 V1 版本发布。**不再进行后续维护**。此仓库着色器将以 V2 版本继续更新。

### 2023.12.29 | 更新说明 | Preview - Standard V1.8.7

*新增：*

新增 **个人制作** 分类下的全部shader URP版本

新增带ShaderGUI的全功能着色器（双管线）

*说明：*
此次更新仅作临时备份上传，非正式更新。（但所有已上传shader均通过可行性验证）
另，此次更新较为完整，将作为最新Release包

### 2023.12.20 | 更新说明 | Preview - Standard V1.8.4

*新增：*

代码雨、像素风格、通用贴图变换、双三角护盾

UI控边溶解、故障扰动、霓虹灯闪烁、转场

builtin转场、故障扰动、双面材质面具、控边溶解、霓虹灯

此次新增15项，其中6项为UI适用。

*TODO:*
目前个人制作的着色器数量已达37个（包含UI用），**在未来会取消此分类结构，重构着色器路径**，简化不必要的轻量效果并以更高可读性的目录结构展示。

*说明：*

此次更新仅作临时备份上传，非正式更新。（但所有已上传shader均通过可行性验证）

### 2023.12.13 | 更新说明 | Standard 1.8

**重要更新：新增 UI 分类**

*新增：*

Buit-in | 序列帧屏幕扭曲、通用程序粒子材质、Flowmap软溶解

UI | 叠加纹理流动、*间隔流光、遮罩扰动与溶解等

URP | 序列帧屏幕扭曲、遮罩流动

*修复：*

修复简易菲尼尔护盾在切换渲染管线后显示不正确的问题 (Built-in&URP)

*优化：*

优化了部分shader的材质属性，清理了未使用的节点

去除了重复的风格化水面包 (URP)

*其它：*

考虑到目前 个人制作 分类下的shader较多，在未来会删除此分类并将shaders分配到对应分类下

目前Release分类较多 (Built-in、UI、URP)，在未来可能以更合理的方式重新分类。

因目前shader较多，功能较复杂，在未来会编写一份对应使用说明。目前请暂时通过 [更新说明](#更新日志) 查看使用方法

*间隔流光：请使用黑底图用以流光纹理，在 [说明](#说明) 处已给出了一张示例图。

### 2023.11.7 | 更新说明 | Standard 1.7

新增：风格化卡通火焰与其简化版、风格化卡通地裂与其简化版、菲涅尔护盾和适用于URP的风格化水面包

修复：修复了序列帧材质边缘切线问题 [issue #2](https://github.com/Soung2279/Unity-Shaders-Collection/issues/2)

#定位了一个问题，此问题导致使用ASE重新编辑本仓库shader后会使汉化失效。

### 2023.10.12 | 更新说明 | Standard 1.6

新增：Panda熊猫shaderURP版，雨天地面，雨幕折射与屏幕模糊，雪地轨迹地面，简单序列帧材质，built-in

**重要更新**：Panda熊猫10.10 最新V2.3改。提供 [熊猫最新版发布地址](https://www.magesbox.com/article/detail/id/1321.html)

#个人制作shader均使用ASE 1.9.1.5 制作。

#简单序列帧材质 ``FlipAddtive`` 与 ``FlipAlphaB`` 建议配合修复遮罩贴图使用。详见 →→ **[查看说明](#说明)**

### 2023.9.3 | 更新说明 | Standard 1.5.1

新增：风格化水面与屏幕扫描(脚本驱动)，可在 [Post-Processing-Scan - MirzaBeig](https://github.com/MirzaBeig/Post-Processing-Scan) 查看屏幕扫描使用方法。

修复：修复了 [Standard V1.5 Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/StandardV1.5) 错误的版本号。

### 2023.9.3 | 更新说明 | Standard 1.5.1

^更新：已全部汉化原ShaderGraph系列shader并部分优化。

*优化：优化了URP适用的 ``SinC_BlendURP``、``SinC_PBRURP`` 并完全汉化。

优化了着色器路径目录，现在URP适用的shader将单独显示在URP分支中。

^因数据更新，在旧版本的ShaderGraph上，着色器表现可能有差异。同时，请勿使用 ``ASE`` 编辑此着色器，这会导致着色器失效。

*因汉化与 ASE 冲突，请勿通过 ASE 编辑此shader。

### 2023.8.25 | 更新说明 | Standard 1.4

新增：屏幕后期处理、BA式卡通渲染、星星缩放、流麻Flow(URP)等shader。

#建议使用前在项目中导入ASE环境。

更新了基础特效制作环境。[Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/RESOURCES_1) 处查看。

### 2023.7.31 | 更新说明 | Standard 1.3

新增：适用于URP管线的溶解（消融）、纹理叠加（遮罩）、简易描边等Shaders。

本次更新仅适用于URP项目。

考虑到项目制作需要，今后会将偏向更新适用于URP环境的shaders。

### 2023.6.9 | 更新说明 | Standard 1.2

说明：添加合集版本号，方便归档。

新增：新增额外菲涅尔、多重遮罩溶解、标准PBR、额外色差与屏幕扭曲Shaders。

修复：修复部分Shader功能失效的错误。

优化：将SinC_Blend进行性能优化。

汉化：完整汉化新增Shader，并进行归纳排版。

请导入文件目录下的Amplify Shader Editor(ASE)包来修复报错问题。

此次更新将Built-in/URP/HDRP等渲染管线平行分离，此次更新仅适用于Built-in。

### 2023.5.18 | 更新说明 | Standard 1.1

新增：新增屏幕扭曲shader，使用法线贴图来控制屏幕扭曲效果。

~~已知故障：进阶处理-多功能溶解ADD/Alpha Double的自定义顶点流可能失效，等待ShaderForge重置修复。~~

### 2023.5.4 | 更新说明 | Standard 1.0

资源优化：移除了部分失效Shader。

目录层级重构：现在所有Shader均按使用类型放置在 **A201-Shader/** 目录下。

更新：更新后期处理shader到最新版本，更新LTY-shader到最新版本。

增添：部分复杂Shader在面板中添加了导航链接。

重构：使用UnityPackage打包资源，而非直接以文件夹形式传输。


### 2023.4.17 | 更新说明 | Beta 0.2

修复：修复了"RongJieSD"持续提示缺失GUI脚本的错误。

更新：新增三个URP特供卡通着色Shader。

完善：完善了README，重归类文件目录结构。