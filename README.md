<p align="center">
  <a href="http://dh.cqie.edu.cn" target="_blank"><img src="https://s1.vika.cn/space/2023/06/09/cec04453495644d3a9bf2a000784bd8d" ></a>
  </a>
</p>


A201-Shaders Collection  ///  Personal Usage
===========================
<div align="left">

→→ **[查看更新日志](#更新日志)**    

→→ **[前往下载地址](https://github.com/Soung2279/Unity-Shaders-Collection/releases)**

→→ **[通过包管理器安装(推荐)](#通过包管理器安装)**

简介
===========================

本仓库是为``Unity``的 ``URP`` 环境下使用的 **着色器合集**。其中，大部分着色器(下称shader)与粒子**特效**制作相关。  *(此处的粒子特效特指Unity内置的Shuriken粒子系统及其团结引擎的升级版Infinity粒子系统，不适用于Unity VEG)*

本仓库的shader基本基于Unity插件 ``ASE`` 生成，部分特殊shader进行了性能调优和可读化调整。这对于切换渲染管线或是移植到其它引擎有利。

若您有一定技术美术知识，您可自行查阅shader中的片段代码，并将其迁移到其它引擎或是适配不同的渲染管线。

查阅此仓库，您可以快捷的获取Unity特效制作相关的shader，同时可参考一些特殊效果的实现案例。

### 仓库前身

<details>

<summary>一些碎碎念</summary>

本仓库建立之初，是[本人](https://github.com/Soung2279)对学习和工作生涯中，对制作、收集的各种shader进行统一收录。其初衷是方便自用存取，同时也想分享一些技术案例。

在一开始的特效学习中，美术出身的我对于特效shader中的功能和模块不满意，想要实现一个效果需要若干个单项功能的shader和不同材质来实现，这使得我有了制作自己的通用shader的想法。有了这个苗头后，我便开始陆续收集相关的shader。

但是，在漫长的工作生涯中，我认识到，shader并不在于多，而在于精。兼容性强、泛用性广和性能平衡是尤为常见的特效shader需求。

虽然以往 [V1](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/StandardV1.8.7) 收集的shader数量很多，但是大部分功能都重合了，并且由于代码风格不一，不便于功能迁移。所以，V2.0及以后的版本，会秉持简约的理念，尽可能收录一些通用的，快速上手的shader。

此仓库发展到现在，已经有了一个经历4个项目迭代，历时3年的通用特效shader，同时仍然有各种特殊的shader不断收录。我想，这才是创建这个仓库的最终意义。

 ##### *特效艺术家应该回归到对美术效果本身的钻研，降低对shader等技术向内容的学习成本。*

 ###### *A201指我最早开始接触特效学习的学校工作室门牌号。在这个几十平方的工作室中，我踏上了特效制作与技术美术学习的道路。*

</details>

### 文件说明

- [V1](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/StandardV1.8.7) 版本已进行归档。不再维护。若无特殊说明，本仓库后续的相关内容均只适用于 [V2.0+]() 的内容。


文件的路径结构应该如下所示：
```
/V2
 -/Editor
 -/Render
 -/Scripts
 -/Shaders
   -/Soung_URP_AllEffect.shader
   -/...
```

其中，``/Shaders`` 里存放的是整合的shader内容。本仓库的核心内容位于此目录。

``/Editor`` 里存放的是shader相关材质面板GUI的脚本文件。此内容可以优化shader的材质面板显示，提高可读性。

``/Render`` 里存放的是一些特殊效果的Render Feature。此内容提供了一些特殊的效果需求，例如URP下的热扭曲、深度高度雾等。

``/Scripts`` 里存放的是与特殊效果的Render Feature相关的脚本。此内容提供了一些必要搭配使用的脚本。


所有的shader目录路径(Shader Path)均 **统一** 为 **Soung/** 路径下，并按着色器的使用类型进行了分类。
- 目前存在的分类有如下：
/Effect：用于粒子特效制作的相关shader
/Post：用于全屏后处理特效相关的shader
/Geometry：用于3d模型渲染相关的shader
/UI：用于UI动效相关的shader
/...

因游戏行业发展迅速，技术日新月异，本仓库的shader仅在以下环境适用：

- [x] // **推荐** //
[![Unity](https://img.shields.io/badge/Unity%20-2022%2B-black?style=flat-square&logo=unity)](https://unity.com/cn)
[![Static Badge](https://img.shields.io/badge/UniversalRenderPipeline%20-14%2B-black?style=flat-square)](https://docs.unity3d.com/cn/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html)


- [ ] // 最低 //
[![Unity](https://img.shields.io/badge/Unity%20-2018%2B-black?style=flat-square&logo=unity)](https://unity.com/cn)
[![Static Badge](https://img.shields.io/badge/UniversalRenderPipeline%20-7%2B-black?style=flat-square)](https://docs.unity3d.com/cn/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html)


- 理论上支持 ``Unity 6.000`` 和 ``TuanJie 1.0+``, ``Universal Render Pipeline 17.0`` 及以上。


本仓库收录的shader可实现下列需求：
- 特效用单贴图着色器
- 程序化粒子着色器
- 通用特效着色器
- 后期处理 **屏幕扭曲/色差/晕影/黑白闪** 着色器

并且，[V2.0+]() 版本的shader均进行过性能调优和中文参数适配，**可直接用于大部分移动端项目和PC项目**。对于小程序项目，请根据 ``WebGL`` 或 ``OpenGL ES2.0`` 的相关限制自行适配。


开始使用
===========================

#### 开始前：确认您的项目需求

- 在使用本仓库提供的shader前，请先确认您的Unity项目是否支持可使用第三方shader (请询问项目组的技美大佬/客户端)，并确认您的Unity项目使用通用渲染管线 (Universal Render Pipeline, 简称URP)。请在确认后进行后续步骤。


<details>

 **<summary> 方式一：手动安装 </summary>**

#### 1. 下载本仓库整合包

- A - 请查看本仓库的 [Release列表](https://github.com/Soung2279/Unity-Shaders-Collection/releases/) ，并下载最新的 Release包 。正确的包 应该是 "``A201-Shader.V.2.x.x_20xx_xx_xx_Full.zip``" 这类命名的 ``.zip`` 压缩包。

- B - 将下载的包解压，并将其复制到您的Unity项目中。如果您不知道放哪个目录下，请直接放在 ``Asset/`` 目录下。

> (可选) 下载后的包可按需导入项目。如果您只想使用基本的shader功能，请只将 ``/Shaders`` 内的文件导入进项目。其它目录的文件都是对此部分功能的扩展与优化。

#### 2. 打开Unity工程确认

- A - 正常情况下，导入包并打开工程并后，控制台窗口(Console)仅会出现黄色警告信息，**不会出现红色错误信息**。 如果出现红色报错，请先点击报错日志查看来源。如果无法处理，请 **直接删除** **除 -/Shaders** 之外的包内容。仅保留基本功能。

- B - 如果想在保留完整功能的前提下使用shader包，请先检查下载过程中是否有错误。然后检查当前Unity使用的 **何种版本渲染管线** 。绝大部分错误都是由于版本不适配而导致的。推荐的版本为 [![Unity](https://img.shields.io/badge/Unity%20-2022%2B-black?style=flat-square&logo=unity)](https://unity.com/cn)[![Static Badge](https://img.shields.io/badge/UniversalRenderPipeline%20-14%2B-black?style=flat-square)](https://docs.unity3d.com/cn/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html)

#### 3. 开始使用

- 所有的shader都可以在材质窗口处，切换着色器时，选择 ``Soung/`` 使用。具体的分类说明，请查看 **[文件说明](#文件说明)** 。

> 包中附带了供特效通用shader使用的shaderGUI，如果发现shaderGUI失效，请先查看 **工程中有无其它脚本相关报错** 。因脚本执行顺序原因，工程中存在错误时，可能会导致shaderGUI不工作。

#### 4. 后续更新

- 通常情况下，本仓库整合包不会有较大变更，在 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases) 处选择对应文件下载，解压后直接 **覆盖原文件更新** 即可。

- 特殊情况下，在 [更新日志](#更新日志) 中应有对应的更新指南，按指南操作即可。

- 若日志中没有给出更新方法，而您更新后在Unity材质面板中找不到shader。请使用 ``notepad++``, ``Windows记事本`` 或 ``VSCode`` 等IDE打开shader，查看新的shader目录路径(Shader Path)（通常在文件的前5行）。

- 使用ASE编辑：若您想使用ASE编辑现有shader (包括但不限于切换管线、增减功能、更改变量名等)，推荐的 ``ASE`` 版本为 V1.9.9.4+ 。

</details>

<details>

 **<summary> 方式二：通过包管理器安装(推荐) </summary>**

#### 通过包管理器安装
 #### 1. 通过包管理器安装

- A - 打开您的Unity工程 - 包管理器 ，在左上角点击 **“添加来自 git URL 的包”**，然后填入下列链接：

```git
https://gitee.com/soung2279/SoungFXShaders.git
# 国内镜像  更新可能不及时
```
或
```git
https://github.com/Soung2279/SoungFXShaders.git
# Github源
```

#### 2. 设置Always Include

- A - 打开您的Unity工程 - 项目设置 ，在 **图形** 选项卡中找到 **始终包括着色器**，适当增加行数，并将包中的shader添加进来。包体的位置应该位于：
```
.../Packages/Soung FXShaders/Runtime/Shaders
```

#### 3. 开始使用

- 所有的shader都可以在材质窗口处，切换着色器时，选择 ``Soung/`` 使用。具体的分类说明，请查看 **[文件说明](#文件说明)** 。

> 包中附带了供特效通用shader使用的shaderGUI，如果发现shaderGUI失效，请先查看 **工程中有无其它脚本相关报错** 。因脚本执行顺序原因，工程中存在错误时，可能会导致shaderGUI不工作。

#### 4. 后续更新

- 在包管理器中，直接点击更新即可。

- 使用ASE编辑：若您想使用ASE编辑现有shader (包括但不限于切换管线、增减功能、更改变量名等)，推荐的 ``ASE`` 版本为 V1.9.9.4+ 。

 </details>

说明
========================

1. Shader使用：在Unity材质球处切换Shader时，选择"Soung/"目录下的Shader即可，Shader已做分类处理。

2. 部分shader可能存在变体较多的情况。请根据您的需求自行取舍。

3. ``Soung_URP_AllEffect.shader`` 是 **特效通用着色器**，因其参数复杂，推荐配合Editor中的shaderGUI使用。

4. 所有的屏幕后效shader，必须配合Render中的 ``GrabPassFeature.cs`` 使用。使用方式是：导入后，在URP管线中的RenderAsset中启用此 RenderFeature 。

## 特别鸣谢

在收录/整理/自编写过程中，参考并使用了以下开源内容和教程。

[![GitHub](https://img.shields.io/badge/Github-UnityURPToonLitShader-6666CC?style=flat-square&logo=github)](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)
[![GitHub](https://img.shields.io/badge/Github-LearnUnityShader-6666CC?style=flat-square&logo=github)](https://github.com/csdjk/LearnUnityShader)
[![GitHub](https://img.shields.io/badge/Github-Awesome_Unity_Shader-6666CC?style=flat-square&logo=github)](https://github.com/QianMo/Awesome-Unity-Shader)
[![GitHub](https://img.shields.io/badge/Github-URP_ASE_Tutorial-6666CC?style=flat-square&logo=github)](https://github.com/xuetaolu/URP_ASE_Tutorial)
[![BiliBili](https://img.shields.io/badge/BiliBili-多喝热水嗝嗝嗝-FB7299?style=flat-square&logo=bilibili)](https://space.bilibili.com/2537966)
[![BiliBili](https://img.shields.io/badge/BiliBili-Cz_wang-FB7299?style=flat-square&logo=bilibili)](https://space.bilibili.com/15396626)
[![BiliBili](https://img.shields.io/badge/BiliBili-永远的孤月-FB7299?style=flat-square&logo=bilibili)](https://space.bilibili.com/442123027)

****

## 更新日志

### 2025.11.19 | 更新说明 | Standard V2.0.2

#### 新增

新增 定制化的Spine 相关shader。

### 2025.11.10 | 更新说明 | Standard V2.0.1

#### 新增

新增 Skybox 相关的 shader。

### 2025.11.4 | 更新说明 | Standard V2.0.0

*新增：*

新增 V2.0 的着色器集合。

新增 VFXTool 小工具脚本。用于检查特效性能、模型大小等。

添加了包管理器导入方式，方便远程导入。


*说明：*
为方便维护，V2.0 版本**不再适配内置管线(Bulit-in)**。此版本的着色器将只支持[![Unity](https://img.shields.io/badge/Unity%20-2022%2B-black?style=flat-square&logo=unity)](https://unity.com/cn)[![Static Badge](https://img.shields.io/badge/UniversalRenderPipeline%20-14%2B-black?style=flat-square)](https://docs.unity3d.com/cn/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html)

*在低于此版本的Unity编辑器和URP环境中运行shader不会完全失效，但不保证显示效果无误。*

<details>

<summary>(V1) 查看先前的更新日志</summary>

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


</details>
