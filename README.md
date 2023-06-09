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

适用于``Unity 2018+``的 **特效着色器合集**

本合集包含如下内容：
- 基本 **Additive/Alpha Blend** 着色器
- **软硬溶解/极坐标溶解/定向溶解** 着色器
- 后期处理**屏幕扭曲/色差/晕影/黑白闪** 着色器
- **扭曲与顶点偏移** 着色器
- **菲涅尔、颜色渐变、深度消隐、软粒子** 着色器
- **热扭曲与法线扭曲** 着色器
- **简易卡通与标准PBR** 着色器

在以下环境下，Shader已经过测试：
- [x] ``Windows 10`` // ``Windows 11``
- [x] ``Unity 2018.4.36f1``
- [x] ``Unity 2019.3.0f6``
- [x] ``Unity 2020.3.38f1c1``
- [x] ``Unity 2020.3.47f1c1``
- [x] ``Unity 2021.3.18f1c1``
- [ ] 理论上支持 ``Unity 2018+``

[![OS](https://img.shields.io/badge/Windows10-0078d6?style=flat-square&logo=windows&logoColor=fff)](https://www.microsoft.com/zh-cn/windows)  [![Unity](https://img.shields.io/badge/Unity-black?style=flat-square&logo=unity)](https://unity.com/cn)



着色器导入
===========================

直接将本仓库Release对应渲染管线文件夹放入项目目录下即可。


说明
========================

在Unity材质球处切换Shader时，选择"A201-Shader/"目录下的Shader即可。


## 鸣谢

[UnityURPToonLitShader](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)

****

## 更新日志

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
