<p align="center">
  <a href="http://dh.cqie.edu.cn" target="_blank"><img src="https://s1.vika.cn/space/2023/06/09/cec04453495644d3a9bf2a000784bd8d" ></a>
  </a>
</p>


A201-Shaders Collection  ///  Personal Usage
===========================
<div align="left">


→→ **[查看更新日志](#更新日志)**

  
功能介绍
===========================

收录适用于``Unity 2018+``，``Built-in`` & ``URP`` 环境的 **特效着色器合集**

本合集包含如下内容：
- 基本粒子 **Additive/Alpha Blend** 着色器
- **软硬溶解/极坐标溶解/定向溶解** 着色器
- 后期处理**屏幕扭曲/色差/晕影/黑白闪** 着色器
- **扭曲与顶点偏移** 着色器
- **菲涅尔、颜色渐变、深度消隐、软粒子** 着色器
- **热扭曲与法线扭曲、流麻** 着色器
- **视差与径向模糊** 着色器
- **简易描边、BA式卡通渲染与标准PBR** 着色器

在下列Unity环境下，着色器经测试可正常使用：
- [x] ``Windows 10`` & ``Windows 11``
- [x] ``Unity 2018:`` 4.36f1
- [x] ``Unity 2019:`` 3.0f6
- [x] ``Unity 2020:`` 3.38f1c1 // 3.47f1c1 // 3.48f1c1
- [x] ``Unity 2021:`` 3.18f1c1 // 3.26f1c1
- [ ] 理论上支持 ``Unity 2018+``

您可在 [Unity下载存档](https://unity.cn/releases) 页面找到以上版本。

> 声明：本仓库收录的大多数shader均来源于网络，如有侵权请联系本人删除。本仓库仅做学习分享之用，请勿用于商业项目。

[![OS](https://img.shields.io/badge/Windows10-0078d6?style=flat-square&logo=windows&logoColor=fff)](https://www.microsoft.com/zh-cn/windows)  [![Unity](https://img.shields.io/badge/Unity-black?style=flat-square&logo=unity)](https://unity.com/cn)



着色器导入
===========================

#### 1.确定您的项目渲染管线为 ``Built-in`` 或 ``URP``，根据对应管线在本仓库 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases) 处下载对应发布包。

##### (本仓库暂未收录 HDRP 或其他渲染管线适用的着色器。)

#### 2.将已下载包解压到您的Unity项目 ``Asset`` 目录下，并在Unity中优先导入 ``ASE`` 包

##### (双击"Amplify Shader Editor v1.9.1.5.unitypackage"，如项目中已有ASE则无需额外导入。)

#### 3.检查控制台 ``Colsole`` 信息，若无意外，仅会产生黄色警告信息，不影响使用。

##### (如有红色错误信息，尝试检查错误来源或删除解压包并重新导入。)


> *额外：项目环境导入>>>
> 本仓库 [Release](https://github.com/Soung2279/Unity-Shaders-Collection/releases/tag/RESOURCES_1) 提供了一个基础的特效制作环境（Unity项目压缩包），下载后即开即用，已预先配置好了着色器、后处理等。


说明
========================

1. Shader使用：在Unity材质球处切换Shader时，选择"A201-Shader/"目录下的Shader即可，Shader已做分类处理。

2. 若部分ShaderGUI缺失，请检查包内的 ``Editor`` 是否正常导入。

3. 特殊说明：<p> ``PPX_BA_shader.shader`` (A201-Shader/特殊制作/BA式卡通着色器_PPX_BA)：需配合SampleTex中的嘴型遮罩 ``Mouth_mask.png`` 使用。 <p> ``流麻flow.shader`` (A201-Shader/特殊制作/URP视差流麻_Jiji)：需配合SampleTex中的粒子点噪 ``particle.png`` 使用。 </p>


## 鸣谢

[UnityURPToonLitShader](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)

****

## 更新日志

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

已知故障：进阶处理-多功能溶解ADD/Alpha Double的自定义顶点流可能失效，等待ShaderForge重置修复。

### 2023.5.4 | 更新说明 | Standard 1.0

资源优化：移除了部分失效Shader。

目录层级重构：现在所有Shader均按使用类型放置在A201-Shader/目录下。

更新：更新后期处理shader到最新版本，更新LTY-shader到最新版本。

增添：部分复杂Shader在面板中添加了导航链接。

重构：使用UnityPackage打包资源，而非直接以文件夹形式传输。


### 2023.4.17 | 更新说明 | Beta 0.2

修复：修复了"RongJieSD"持续提示缺失GUI脚本的错误。

更新：新增三个URP特供卡通着色Shader。

完善：完善了README，重归类文件目录结构。
