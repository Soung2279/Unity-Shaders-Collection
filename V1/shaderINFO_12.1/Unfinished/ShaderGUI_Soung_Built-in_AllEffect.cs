using System;
using UnityEngine;
using UnityEditor;

//Edited by Soung, 2024.11.14

//创建一个GUI类, 在ASE中填写Custome Editor或直接在shader源码中加入下行
//CustomEditor "ShaderGUI_AllEffect"

//简陋的版本信息
static class ConstantInfo
{
    public const string Sd_Version= "Built_in_Standard_V2.0.0_beta";
    public const string Sd_Model = "3.5";
    public const string Sd_Type = "Legacy/Unlit";
    public const string UpdateTime = "2024.11.14";
    public const string UpdateWebSite = "https://github.com/Soung2279/Unity-Shaders-Collection";
}

//注明GUI名称
public class ShaderGUI_AllEffect : ShaderGUI
{

    //自定义一个小按钮
    public GUILayoutOption[] shortButtonStyle = new GUILayoutOption[] { GUILayout.Width(100) };

    //自定义字体
    public GUIStyle style = new GUIStyle();

    //自定义下拉菜单的形状属性
    //用到的自定义下拉菜单
    static bool Foldout(bool display, string title)
    {
        var style = new GUIStyle("ShurikenModuleTitle");
        //字体
        style.font = new GUIStyle(EditorStyles.boldLabel).font;
        //边界
        style.border = new RectOffset(15, 7, 4, 4);
        //方框固定高度
        style.fixedHeight = 22;
        //字体偏移  第一个数字为正向右便宜  第二个数字为正向下偏移
        style.contentOffset = new Vector2(20f, -3f);
        //字体大小
        style.fontSize = 12;
        //字体颜色
        style.normal.textColor = new Color(0.75f, 0.85f, 0.95f);
        //宽高
        var rect = GUILayoutUtility.GetRect(16f, 25f, style);
        GUI.Box(rect, title, style);
        //当前事件
        var e = Event.current;
        //创建矩形  左上角X坐标 右上角X坐标  矩形的宽 矩形的高
        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
        //绘制三角形
        if (e.type == EventType.Repaint)
        {
            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
        }
        //鼠标点击了  并且鼠标在矩形范围内
        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
        {
            display = !display;
            e.Use();
        }
        return display;
    }

    //自定义下拉菜单2的形状属性 没用到的菜单颜色
    static bool Foldout2(bool display, string title)
    {
        var style = new GUIStyle("ShurikenModuleTitle");
        //字体
        style.font = new GUIStyle(EditorStyles.boldLabel).font;
        //边界
        style.border = new RectOffset(15, 7, 4, 4);
        //方框固定高度
        style.fixedHeight = 22;
        //字体偏移  第一个数字为正向右便宜  第二个数字为正向下偏移
        style.contentOffset = new Vector2(20f, -3f);
        //字体大小
        style.fontSize = 12;
        //字体颜色
        style.normal.textColor = new Color(0.8f, 0.8f, 0.8f);
        //宽高
        var rect = GUILayoutUtility.GetRect(16f, 25f, style);
        GUI.Box(rect, title, style);
        //当前事件
        var e = Event.current;
        //创建矩形  左上角X坐标 右上角X坐标  矩形的宽 矩形的高
        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
        //绘制三角形
        if (e.type == EventType.Repaint)
        {
            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
        }
        //鼠标点击了  并且鼠标在矩形范围内
        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
        {
            display = !display;
            e.Use();
        }
        return display;
    }

    //自定义变量  非真即假的布尔 真的时候打开下拉菜单  假的时候收起下拉框 默认为真，是假的时候切换成foldout2
    static bool _Base_Foldout = true;
    static bool _Main_Foldout = true;
    static bool _Noise_Foldout = false;
    static bool _Gam_Foldout = false;
    static bool _ProMask_Foldout = true;
    static bool _Mask_Foldout = false;
    static bool _MaskPlus_Foldout = false;
    static bool _Liuguang_Foldout = false;
    static bool _Dissolve_Foldout = false;
    static bool _DissolvePlus_Foldout = false;
    static bool _Vertex_Foldout = false;
    static bool _Fresnel_Foldout = false;

    MaterialEditor m_MaterialEditor;


    //自定义主要贴图需要显示的属性
    //填入全部所需的变量属性

    #region [Base属性按钮命名]
    //- 基础参数部分 -
    //剔除模式 | OFF FRONT BACK
    MaterialProperty CullingMode = null;
    //深度写入开关
    MaterialProperty ZWrite = null;
    //深度测试模式 | Less or Equal Always
    MaterialProperty ZTestMode = null;
    //混合模式
    MaterialProperty BlendMode = null;
    //软粒子
    MaterialProperty SoftParticle = null;
    #endregion


    #region [Main贴图按钮命名]
    //- 主帖图部分 -
    //贴图
    MaterialProperty MainTex = null;
    //贴图通道
    MaterialProperty MainTexP = null;
    //颜色
    MaterialProperty MainColor = null;
    //贴图旋转
    MaterialProperty MainTexRotator = null;
    //贴图色相
    MaterialProperty MainTexHue = null;
    //贴图饱和度
    MaterialProperty MainTexSaturation = null;
    //贴图UV流动模式 | Material or Custom1.xy
    MaterialProperty MainTexFlowMode = null;
    //贴图重铺模式 | Repeat or Clamp
    MaterialProperty MainTexClamp = null;
    //贴图UV采样模式 | Local or Polar
    MaterialProperty MainTexUVMode = null;
    //贴图极坐标采样模式设置
    MaterialProperty MainTexPolarSets = null;
    //贴图U流动速度
    MaterialProperty MainTexUspeed = null;
    //贴图V流动速度
    MaterialProperty MainTexVspeed = null;
    #endregion 


    #region [Noise贴图按钮命名]
    //- 扭曲部分 -
    //扭曲开关
    MaterialProperty NoiseSwitch = null;
    //扭曲贴图
    MaterialProperty NoiseTex = null;
    //贴图通道
    MaterialProperty NoiseTexP = null;
    //扭曲强度
    MaterialProperty NoisePower = null;
    //扭曲U速度
    MaterialProperty NoiseTexUspeed = null;
    //扭曲V速度
    MaterialProperty NoiseTexVspeed = null;
    #endregion


    #region [Gam贴图按钮命名]
    //- 颜色叠加部分 -
    //颜色叠加开关
    MaterialProperty GamTexSwitch = null;
    //颜色叠加图
    MaterialProperty GamTex = null;
    //贴图通道
    MaterialProperty GamTexP = null;
    //贴图旋转
    MaterialProperty GamTexRotator = null;
    //贴图去色
    MaterialProperty GamTexDesaturate = null;
    //贴图重铺模式 | Repeat or Clamp
    MaterialProperty GamTexClamp = null;
    //颜色叠加是否随主帖图流动
    MaterialProperty GamTexFollowMainTex = null;
    //流动U速度
    MaterialProperty GamTexUspeed = null;
    //流动V速度
    MaterialProperty GamTexVspeed = null;
    //使用AlphaBlend的颜色叠加模式
    MaterialProperty GamAlphaMode = null;
    #endregion


    #region [ProgramMask按钮命名]
    //- 程序遮罩部分 -
    //程序遮罩开关
    MaterialProperty ProMaskSwitch = null;
    //程序遮罩范围
    MaterialProperty ProMaskRange = null;
    //程序遮罩方向 | UP DOWN LEFT RIGHT
    MaterialProperty ProMaskDir = null;
    #endregion


    #region [Mask贴图按钮命名]
    //- 遮罩贴图部分 -
    //遮罩开关
    MaterialProperty MaskSwitch = null;
    //遮罩贴图
    MaterialProperty MaskTex = null;
    //遮罩贴图通道
    MaterialProperty MaskTexP = null;
    //遮罩旋转
    MaterialProperty MaskTexRotator = null;
    //反向遮罩
    MaterialProperty OneMinusMask = null;
    //贴图重铺模式 | Repeat or Clamp
    MaterialProperty MaskTexClamp = null;
    //遮罩U速度
    MaterialProperty MaskTexUspeed = null;
    //遮罩V速度
    MaterialProperty MaskTexVspeed = null;
    #endregion


    #region [MaskPlus按钮命名]
    //- 额外遮罩部分 -
    //额外遮罩开关
    MaterialProperty MaskTexPlusSwitch = null;
    //使用程序遮罩作为额外遮罩
    MaterialProperty MaskPlusUsePro = null;
    //额外遮罩图
    MaterialProperty MaskTexPlus = null;
    //贴图通道
    MaterialProperty MaskTexPlusP = null;
    //贴图旋转
    MaterialProperty MaskTexPlusRotator = null;
    //贴图重铺模式 | Repeat or Clamp
    MaterialProperty MaskTexPlusClamp = null;
    //贴图U速度
    MaterialProperty MaskTexPlusUspeed = null;
    //贴图V速度
    MaterialProperty MaskTexPlusVspeed = null;
    #endregion


    #region [Liuguang纹理按钮命名]
    //- 流光部分 -
    //流光开关
    MaterialProperty LiuguangSwitch = null;
    //流光贴图
    MaterialProperty LiuguangTex = null;
    //贴图通道
    MaterialProperty LiuguangTexP = null;
    //贴图旋转
    MaterialProperty LiuguangTexRotator = null;
    //是否禁用流光贴图本身的颜色
    MaterialProperty UseLGTexColor = null;
    //流光颜色
    MaterialProperty LiuguangColor = null;
    //流光UV模式 | Local or Polar or Screen
    MaterialProperty LiuguangTexUVmode = null;
    //极坐标Polar模式的设置
    MaterialProperty LiuguangPolarScale = null;
    //屏幕Screen模式的设置
    MaterialProperty LiuguangScreenTilingOffset = null;
    //流光U速度
    MaterialProperty LiuguangUSpeed = null;
    //流光V速度
    MaterialProperty LiuguangVSpeed = null;
    #endregion


    #region [Dissolve贴图按钮命名]
    //- 溶解部分 -
    //溶解开关
    MaterialProperty DissolveTexSwitch = null;
    //溶解贴图
    MaterialProperty DissolveTex = null;
    //贴图通道
    MaterialProperty DissolveTexP = null;
    //贴图旋转
    MaterialProperty DissolveTexRotator = null;
    //溶解过渡值
    MaterialProperty DissolveSmooth = null;
    //溶解进度
    MaterialProperty DissolvePower = null;
    //溶解控制模式 | Material or Custom1.z
    MaterialProperty DissolveMode = null;
    //使用有边缘的溶解模式
    MaterialProperty DissolveEdgeSwitch = null;
    //溶解边缘颜色
    MaterialProperty DissolveEdgeColor = null;
    //边缘宽度
    MaterialProperty DissolveEdgeWide = null;
    //溶解U速度
    MaterialProperty DissolveTexUspeed = null;
    //溶解V速度
    MaterialProperty DissolveTexVspeed = null;
    #endregion


    #region [DissolvePlus贴图按钮命名]
    //- 定向溶解部分 -
    //定向溶解开关
    MaterialProperty DissolveTexPlusSwitch = null;
    //使用程序遮罩作为定向溶解图
    MaterialProperty DissolveTexPlusUsePro = null;
    //定向溶解贴图
    MaterialProperty DissolveTexPlus = null;
    //定向溶解通道
    MaterialProperty DissolveTexPlusP = null;
    //贴图旋转
    MaterialProperty DissolveTexPlusRotator = null;
    //定向溶解强度
    MaterialProperty DissolveTexPlusPower = null;
    //定向溶解UV流动模式 | Material or Custom2.xy
    MaterialProperty DissolveTexPlusFlowMode = null;
    //贴图重铺模式 | Repeat or Clamp
    MaterialProperty DissolveTexPlusClamp = null;
    //定向溶解U速度
    MaterialProperty DissolveTexPlusUspeed = null;
    //定向溶解V速度
    MaterialProperty DissolveTexPlusVspeed = null;
    #endregion


    #region [Vertex贴图按钮命名]
    //- 顶点偏移部分 -
    //顶点偏移开关
    MaterialProperty VertexSwitch = null;
    //顶点偏移图
    MaterialProperty VertexTex = null;
    //贴图旋转
    MaterialProperty VertexTexRotator = null;
    //顶点偏移强度控制模式 | Material or Custom1.w
    MaterialProperty VertexMode = null;
    //顶点偏移强度
    MaterialProperty VertexPower = null;
    //顶点偏移轴向 | x y z
    MaterialProperty VertexTexDir = null;
    //顶点偏移U速度
    MaterialProperty VertexTexUspeed = null;
    //顶点偏移V速度
    MaterialProperty VertexTexVspeed = null;
    #endregion


    #region [Fresnel按钮命名]
    //- 菲涅尔部分 -
    //菲涅尔开关
    MaterialProperty FresnelSwitch = null;
    //菲涅尔颜色
    MaterialProperty FresnelColor = null;
    //菲涅尔模式 | Fresnel or Bokeh
    MaterialProperty FresnelMode = null;
    //菲涅尔颜色模式 | Mult or Add
    MaterialProperty FresnelColorMode = null;
    //是否使用AlphaBlend模式的菲涅尔
    MaterialProperty FresnelAlphaMode = null;
    //菲涅尔强度/边缘/范围 | 0 1 5
    MaterialProperty FresnelSet = null;
    #endregion


    //引用参数部分(从引擎的按钮里面提取数值，以便下面随时取用)
    public void FindProperties(MaterialProperty[] props)
    {
        #region [shader基本参数引用]
        //基本属性
        CullingMode = FindProperty("_CullingMode", props);
        ZWrite = FindProperty("_Zwrite", props);
        ZTestMode = FindProperty("_ZTestMode", props);
        BlendMode = FindProperty("_BlendMode", props);
        SoftParticle = FindProperty("_SoftParticle", props);
        #endregion


        #region [Main贴图按钮参数引用]
        //主贴图属性
        MainTex = FindProperty("_MainTex", props);
        MainTexP = FindProperty("_MainTexP", props);
        MainColor = FindProperty("_MainColor", props);
        MainTexRotator = FindProperty("_MainTexRotator", props);
        MainTexHue = FindProperty("_MainTexHue", props);
        MainTexSaturation = FindProperty("_MainTexSaturation", props);
        MainTexFlowMode = FindProperty("_MainTexFlowMode", props);
        MainTexClamp = FindProperty("_MainTexClamp", props);
        MainTexUVMode = FindProperty("_MainTexUVMode", props);
        MainTexPolarSets = FindProperty("_MainTexPolarSets", props);
        MainTexUspeed = FindProperty("_MainTexUspeed", props);
        MainTexVspeed = FindProperty("_MainTexVspeed", props);
        #endregion


        #region [Noise贴图按钮参数引用]
        //扭曲属性
        NoiseSwitch = FindProperty("_NoiseSwitch", props);
        NoiseTex = FindProperty("_NoiseTex", props);
        NoiseTexP = FindProperty("_NoiseTexP", props);
        NoisePower = FindProperty("_NoisePower", props);
        NoiseTexUspeed = FindProperty("_NoiseTexUspeed", props);
        NoiseTexVspeed = FindProperty("_NoiseTexVspeed", props);
        #endregion


        #region [Gam贴图按钮参数引用]
        //颜色叠加属性
        GamTexSwitch = FindProperty("_GamTexSwitch", props);
        GamTex = FindProperty("_GamTex", props);
        GamTexP = FindProperty("_GamTexP", props);
        GamTexRotator = FindProperty("_GamTexRotator", props);
        GamTexDesaturate = FindProperty("_GamTexDesaturate", props);
        GamTexClamp = FindProperty("_GamTexClamp", props);
        GamTexFollowMainTex = FindProperty("_GamTexFollowMainTex", props);
        GamTexUspeed = FindProperty("_GamTexUspeed", props);
        GamTexVspeed = FindProperty("_GamTexVspeed", props);
        GamAlphaMode = FindProperty("_GamAlphaMode", props);
        #endregion


        #region [ProgramMask按钮参数引用]
        //程序遮罩属性
        ProMaskSwitch = FindProperty("_ProMaskSwitch", props);
        ProMaskDir = FindProperty("_ProMaskDir", props);
        ProMaskRange = FindProperty("_ProMaskRange", props);
        #endregion


        #region [Mask贴图按钮参数引用]
        //遮罩属性
        MaskSwitch = FindProperty("_MaskSwitch", props);
        MaskTex = FindProperty("_MaskTex", props);
        MaskTexP = FindProperty("_MaskTexP", props);
        MaskTexRotator = FindProperty("_MaskTexRotator", props);
        OneMinusMask = FindProperty("_OneMinusMask", props);
        MaskTexClamp = FindProperty("_MaskTexClamp", props);
        MaskTexUspeed = FindProperty("_MaskTexUspeed", props);
        MaskTexVspeed = FindProperty("_MaskTexVspeed", props);
        #endregion 


        #region [MaskPlus按钮参数引用]
        //额外遮罩属性
        MaskTexPlusSwitch = FindProperty("_MaskTexPlusSwitch", props);
        MaskPlusUsePro = FindProperty("_MaskPlusUsePro", props);
        MaskTexPlus = FindProperty("_MaskTexPlus", props);
        MaskTexPlusP = FindProperty("_MaskTexPlusP", props);
        MaskTexPlusRotator = FindProperty("_MaskTexPlusRotator", props);
        MaskTexPlusClamp = FindProperty("_MaskTexPlusClamp", props);
        MaskTexPlusUspeed = FindProperty("_MaskTexPlusUspeed", props);
        MaskTexPlusVspeed = FindProperty("_MaskTexPlusVspeed", props);
        #endregion 


        #region [Liuguang纹理按钮参数引用]
        //流光属性
        LiuguangSwitch = FindProperty("_LiuguangSwitch", props);
        LiuguangTex = FindProperty("_LiuguangTex", props);
        LiuguangTexP = FindProperty("_LiuguangTexP", props);
        LiuguangTexRotator = FindProperty("_LiuguangTexRotator", props);
        UseLGTexColor = FindProperty("_UseLGTexColor", props);
        LiuguangColor = FindProperty("_LiuguangColor", props);
        LiuguangTexUVmode = FindProperty("_LiuguangTexUVmode", props);
        LiuguangPolarScale = FindProperty("_LiuguangPolarScale", props);
        LiuguangScreenTilingOffset = FindProperty("_LiuguangScreenTilingOffset", props);
        LiuguangUSpeed = FindProperty("_LiuguangUSpeed", props);
        LiuguangVSpeed = FindProperty("_LiuguangVSpeed", props);
        #endregion 


        #region [Dissolve贴图按钮参数引用]
        //溶解属性
        DissolveTexSwitch = FindProperty("_DissolveTexSwitch", props);
        DissolveTex = FindProperty("_DissolveTex", props);
        DissolveTexP = FindProperty("_DissolveTexP", props);
        DissolveTexRotator = FindProperty("_DissolveTexRotator", props);
        DissolveSmooth = FindProperty("_DissolveSmooth", props);
        DissolvePower = FindProperty("_DissolvePower", props);
        DissolveMode = FindProperty("_DissolveMode", props);
        DissolveEdgeSwitch = FindProperty("_DissolveEdgeSwitch", props);
        DissolveEdgeColor = FindProperty("_DissolveEdgeColor", props);
        DissolveEdgeWide = FindProperty("_DissolveEdgeWide", props);
        DissolveTexUspeed = FindProperty("_DissolveTexUspeed", props);
        DissolveTexVspeed = FindProperty("_DissolveTexVspeed", props);
        #endregion


        #region [DissolvePlus贴图按钮参数引用]
        //定向溶解属性
        DissolveTexPlusSwitch = FindProperty("_DissolveTexPlusSwitch", props);
        DissolveTexPlusUsePro = FindProperty("_DissolveTexPlusUsePro", props);
        DissolveTexPlus = FindProperty("_DissolveTexPlus", props);
        DissolveTexPlusP = FindProperty("_DissolveTexPlusP", props);
        DissolveTexPlusRotator = FindProperty("_DissolveTexPlusRotator", props);
        DissolveTexPlusPower = FindProperty("_DissolveTexPlusPower", props);
        DissolveTexPlusFlowMode = FindProperty("_DissolveTexPlusFlowMode", props);
        DissolveTexPlusClamp = FindProperty("_DissolveTexPlusClamp", props);
        DissolveTexPlusUspeed = FindProperty("_DissolveTexPlusUspeed", props);
        DissolveTexPlusVspeed = FindProperty("_DissolveTexPlusVspeed", props);
        #endregion


        #region [Vertex贴图按钮参数引用]
        //顶点偏移属性
        VertexSwitch = FindProperty("_VertexSwitch", props);
        VertexTex = FindProperty("_VertexTex", props);
        VertexTexRotator = FindProperty("_VertexTexRotator", props);
        VertexMode = FindProperty("_VertexMode", props);
        VertexPower = FindProperty("_VertexPower", props);
        VertexTexDir = FindProperty("_VertexTexDir", props);
        VertexTexUspeed = FindProperty("_VertexTexUspeed", props);
        VertexTexVspeed = FindProperty("_VertexTexVspeed", props);
        #endregion 


        #region [Fresnel按钮参数引用]
        //菲涅尔属性
        FresnelSwitch = FindProperty("_FresnelSwitch", props);
        FresnelColor = FindProperty("_FresnelColor", props);
        FresnelMode = FindProperty("_FresnelMode", props);
        FresnelColorMode = FindProperty("_FresnelColorMode", props);
        FresnelAlphaMode = FindProperty("_FresnelAlphaMode", props);
        FresnelSet = FindProperty("_FresnelSet", props);
        #endregion
    }


    //将上面定义的属性显示在面板上
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        //获取材质球上的参数
        FindProperties(props);
        m_MaterialEditor = materialEditor;
        //获取材质球上的参数
        Material material = materialEditor.target as Material;

        //提供更新说明
        GUILayout.Label($"由Soung制作, 更新时间{ConstantInfo.UpdateTime}", GUILayout.Width(300), GUILayout.Height(20)); //提示语句

        if (GUILayout.Button($"当前:{ConstantInfo.Sd_Version}")) //提示语句
        {
            string shaderinfos = $"_ShaderINFO_\n Version: {ConstantInfo.Sd_Version}\nShaderModel:{ConstantInfo.Sd_Model}\nType: {ConstantInfo.Sd_Type}";
            Debug.Log($"<color=#66ccff><i>{shaderinfos}</i></color>");
            string updateurl = $"更新地址：\n{ConstantInfo.UpdateWebSite}";
            Debug.Log($"<color=#66ccff><b><size=12>{updateurl}</size></b></color>");
        }


        //基础设置下拉菜单
        #region [基础设置部分]
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        _Base_Foldout = Foldout(_Base_Foldout, "基础设置 | BasicSets");
        if (_Base_Foldout)
        {
            EditorGUI.indentLevel++;
            GUI_Base(material);
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndVertical();
        #endregion


        //主帖图下拉菜单
        #region [主贴图部分]
        if (MainTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Main_Foldout = Foldout(_Main_Foldout, "主贴图 | MainTex");
            if (_Main_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Main(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Main_Foldout = Foldout2(_Main_Foldout, "主贴图 | MainTex");
            if (_Main_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Main(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //扭曲下拉菜单
        #region [Noise部分]
        if (NoiseTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Noise_Foldout = Foldout(_Noise_Foldout, "扭曲贴图 | NoiseTex");
            if (_Noise_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Noise(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Noise_Foldout = Foldout2(_Noise_Foldout, "扭曲贴图 | NoiseTex");
            if (_Noise_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Noise(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //颜色叠加下拉菜单
        #region [Gam部分]
        if (GamTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Gam_Foldout = Foldout(_Gam_Foldout, "颜色叠加贴图 | GamTex");
            if (_Gam_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Gam(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Gam_Foldout = Foldout2(_Gam_Foldout, "颜色叠加贴图 | GamTex");
            if (_Gam_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Gam(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //程序遮罩下拉菜单
        #region [程序遮罩部分]
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        _ProMask_Foldout = Foldout(_ProMask_Foldout, "程序遮罩 | ProgramMask");
        if (_ProMask_Foldout)
        {
            EditorGUI.indentLevel++;
            GUI_MaskPro(material);
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndVertical();
        #endregion


        //遮罩下拉菜单
        #region [遮罩部分]
        if (MaskTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Mask_Foldout = Foldout(_Mask_Foldout, "遮罩贴图 | MaskTex");
            if (_Mask_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Mask(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Mask_Foldout = Foldout2(_Mask_Foldout, "遮罩贴图 | MaskTex");
            if (_Mask_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Mask(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //额外遮罩下拉菜单
        #region [额外遮罩部分]
        if (MaskTexPlus.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _MaskPlus_Foldout = Foldout(_MaskPlus_Foldout, "额外遮罩 | MaskTexPlus");
            if (_MaskPlus_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_MaskPlus(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _MaskPlus_Foldout = Foldout2(_MaskPlus_Foldout, "额外遮罩 | MaskTexPlus");
            if (_MaskPlus_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_MaskPlus(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //流光下拉菜单
        #region [流光部分]
        if (LiuguangTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Liuguang_Foldout = Foldout(_Liuguang_Foldout, "流光纹理 | LiuguangTex");
            if (_Liuguang_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_LG(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Liuguang_Foldout = Foldout2(_Liuguang_Foldout, "流光纹理 | LiuguangTex");
            if (_Liuguang_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_LG(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //溶解下拉菜单
        #region [溶解部分]
        if (DissolveTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Dissolve_Foldout = Foldout(_Dissolve_Foldout, "溶解贴图 | DissolveTex");
            if (_Dissolve_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Dissolve(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Dissolve_Foldout = Foldout2(_Dissolve_Foldout, "溶解贴图 | DissolveTex");
            if (_Dissolve_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Dissolve(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //定向溶解下拉菜单
        #region [定向溶解部分]
        if (DissolveTexPlus.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _DissolvePlus_Foldout = Foldout(_DissolvePlus_Foldout, "定向溶解 | DissolveTexPlus");
            if (_DissolvePlus_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_DissolvePlus(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _DissolvePlus_Foldout = Foldout2(_DissolvePlus_Foldout, "定向溶解 | DissolveTexPlus");
            if (_DissolvePlus_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_DissolvePlus(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //顶点偏移下拉菜单
        #region [顶点偏移部分]
        if (VertexTex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Vertex_Foldout = Foldout(_Vertex_Foldout, "顶点偏移贴图 | Vertex");
            if (_Vertex_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Vertex(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Vertex_Foldout = Foldout2(_Vertex_Foldout, "顶点偏移贴图 | Vertex");
            if (_Vertex_Foldout)
            {
                EditorGUI.indentLevel++;
                GUI_Vertex(material);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }
        #endregion


        //菲涅尔下拉菜单
        #region [菲涅尔部分]
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        _Fresnel_Foldout = Foldout2(_Fresnel_Foldout, "菲涅尔 | Fresnel");
        if (_Fresnel_Foldout)
        {
            EditorGUI.indentLevel++;
            GUI_Fresnel(material);
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();
        #endregion

        //------------------------------------函数引用----------------------------------------------

        //- 基础设置部分的GUI -
        #region [基础部分GUI]
        void GUI_Base(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：此处调整整个材质的显示");
            //绘制垂直的方框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            //剔除模式功能区
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("剔除模式");
            if (material.GetFloat("_CullingMode") == 0)
            {
                if (GUILayout.Button("双面显示", shortButtonStyle))
                {
                    material.SetFloat("_CullingMode", 1);
                    string warn_cullmode = $"Soung Shader INFO: Culled FRONT\n>>>整体材质以背面显示";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_cullmode}</size></b></color>");
                }
            }
            else
            {
                if (material.GetFloat("_CullingMode") == 1)
                {
                    if (GUILayout.Button("显示背面", shortButtonStyle))
                    {
                        material.SetFloat("_CullingMode", 2);
                        string warn_cullmode2 = $"Soung Shader INFO: Culled BACK\n>>>整体材质以正面显示";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_cullmode2}</size></b></color>");
                    }
                }
                else
                {
                    if (GUILayout.Button("显示正面", shortButtonStyle))
                    {
                        material.SetFloat("_CullingMode", 0);
                        string warn_cullmode3 = $"Soung Shader INFO: Culled OFF\n>>>整体材质以双面显示";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_cullmode3}</size></b></color>");
                    }
                }
            }
            
            EditorGUILayout.EndHorizontal();
            //剔除模式功能区结束


            //深度写入功能区
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("写入深度");
            if (material.GetFloat("_Zwrite") == 0)
            {
                if (GUILayout.Button("否", shortButtonStyle))
                {
                    material.SetFloat("_Zwrite", 1);
                    string warn_zwrite = $"Soung Shader INFO: ZWrite ON\n>>>深度写入已开启，材质将受深度遮挡影响";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_zwrite}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("是", shortButtonStyle))
                {
                    material.SetFloat("_Zwrite", 0);
                    string warn_zwrite2 = $"Soung Shader INFO: ZWrite OFF\n>>>深度写入已关闭，材质不受深度影响";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_zwrite2}</size></b></color>");
                }
            }

            EditorGUILayout.EndHorizontal();
            //深度写入功能区结束


            //深度测试功能区
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("显示在最前层");
            if (material.GetFloat("_ZTestMode") == 4)
            {
                if (GUILayout.Button("否", shortButtonStyle))
                {
                    material.SetFloat("_ZTestMode", 8);
                    string warn_ztest = $"Soung Shader INFO: TestCompareF Always(8) \n>>>材质将始终在画面内";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_ztest}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("是", shortButtonStyle))
                {
                    material.SetFloat("_ZTestMode", 4);
                    string warn_ztest2 = $"Soung Shader INFO: TestCompareF Less or Equal(4) \n>>>材质受遮挡关系影响";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_ztest2}</size></b></color>");
                }
            }

            EditorGUILayout.EndHorizontal();
            //深度测试功能区结束


            //混合模式功能区
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("混合模式");
            if (material.GetFloat("_BlendMode") == 1)
            {
                if (GUILayout.Button("Additive", shortButtonStyle))
                {
                    material.SetFloat("_BlendMode", 10);
                    material.EnableKeyword("_ISALPHA_ON");
                    string warn_blendmode = $"Soung Shader INFO: Src Alpha Dst 10\n>>>材质处于不透明模式";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_blendmode}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("AlphaBlend", shortButtonStyle))
                {
                    material.SetFloat("_BlendMode", 1);
                    material.DisableKeyword("_ISALPHA_ON");
                    string warn_blendmode = $"Soung Shader INFO: Src Alpha Dst 1\n>>>材质处于半透明模式";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_blendmode}</size></b></color>");
                }
            }

            EditorGUILayout.EndHorizontal();
            //混合模式功能区结束


            //软粒子功能区
            EditorGUILayout.BeginHorizontal();
            m_MaterialEditor.ShaderProperty(SoftParticle, "软粒子");
            EditorGUILayout.EndHorizontal();
            //软粒子功能区结束


            //结束垂直方框绘制
            EditorGUILayout.EndVertical();
            //6个像素的高度
            GUILayout.Space(5);
        }
        #endregion


        //- 主帖图部分的GUI -
        #region [主帖图部分GUI]
        void GUI_Main(Material material)
        {

            //功能说明
            EditorGUILayout.LabelField("功能说明：材质的基础纹理，可进行色相变化和旋转调整等");

            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("主贴图"), MainTex, MainColor);
            if (MainTex.textureValue != null)
            {
                m_MaterialEditor.TextureScaleOffsetProperty(MainTex);
                
                //自定义说明
                EditorGUILayout.HelpBox("启用Cusotm Vertex Streams后, 依次添加UV2,Custom1.xy后使用", MessageType.None, false);

                m_MaterialEditor.ShaderProperty(MainTexP, "切换通道");
                m_MaterialEditor.ShaderProperty(MainTexRotator, "贴图旋转");
                m_MaterialEditor.ShaderProperty(MainTexHue, "贴图色相变换");
                m_MaterialEditor.ShaderProperty(MainTexSaturation, "贴图饱和度变更");

                //UV流动模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel ("主帖图流动模式"); 
                if (material.GetFloat("_MainTexFlowMode") == 0)
                {
                    if (GUILayout.Button("材质默认", GUILayout.Width(120)))
                    {
                        material.SetFloat("_MainTexFlowMode", 1);
                        string warn_mainuvflow = $"Soung Shader INFO: CustomUV Flow\n>>>添加Custom1.xy来正确显示并控制贴图流动";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainuvflow}</size></b></color>");
                    }
                }
                else
                {
                    if (GUILayout.Button("自定义Custom1.xy", GUILayout.Width(120)))
                    {
                        material.SetFloat("_MainTexFlowMode", 0);
                        string warn_mainuvflow = $"Soung Shader INFO: Material Flow\n>>>使用材质参数控制贴图流动";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainuvflow}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //UV流动模式功能区结束
                

                //重铺模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("切换贴图重铺模式");
                if (material.GetFloat("_MainTexClamp") == 0)
                {
                    if (GUILayout.Button("重铺", shortButtonStyle))
                    {
                        material.SetFloat("_MainTexClamp", 1);
                        string warn_mainrepeat = $"Soung Shader INFO: WrapMode CLAMP\n>>>贴图设置为钳制模式(单次)";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    }

                }
                else
                {
                    if (GUILayout.Button("不重铺", shortButtonStyle))
                    {
                        material.SetFloat("_MainTexClamp", 0);
                        string warn_mainrepeat = $"Soung Shader INFO: WrapMode REPEAT\n>>>贴图设置为重铺模式(重复)";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //重铺模式功能区结束


                //UV采样模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("贴图UV采样模式");
                if (material.GetFloat("_MainTexUVMode") == 0)
                {
                    if (GUILayout.Button("材质默认", shortButtonStyle))
                    {
                        material.SetFloat("_MainTexUVMode", 1);
                        string warn_mainpolar = $"Soung Shader INFO: UV sample POLAR\n>>>UV采样设置为极坐标模式";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainpolar}</size></b></color>");
                    }

                }
                else
                {
                    if (GUILayout.Button("极坐标Polar", shortButtonStyle))
                    {
                        material.SetFloat("_MainTexUVMode", 0);
                        string warn_mainpolar = $"Soung Shader INFO: UV sample LOCAL\n>>>UV采样设置为默认模式";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainpolar}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //UV采样模式功能区结束


                //使用UV采样模式 - 极坐标Polar 时，调整相关参数
                if (material.GetFloat("_MainTexUVMode") == 1)
                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(MainTexPolarSets, "极坐标Polar中心与缩放");
                    EditorGUILayout.EndVertical();
                }


                //使用UV流动模式 - 材质默认 时，调整相关参数
                if (material.GetFloat("_MainTexFlowMode") == 0)
                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                    m_MaterialEditor.ShaderProperty(MainTexUspeed, "横向流动速度");
                    m_MaterialEditor.ShaderProperty(MainTexVspeed, "纵向流动速度");
                    EditorGUILayout.EndVertical();
                }
            }
        }
        #endregion


        //- 扭曲部分的GUI -
        #region [扭曲部分GUI]
        void GUI_Noise(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：使用一张扭曲贴图来改变主帖图的UV，使材质具有纹理扭动的效果");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            //EditorGUILayout.PrefixLabel("扭曲开关");
            if (material.GetFloat("_NoiseSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_NoiseSwitch", 1);
                    string warn_noise = $"Soung Shader INFO: NoiseTex Disable\n>>>扭曲禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_noise}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_NoiseSwitch", 0);
                    string warn_noise = $"Soung Shader INFO: NoiseTex Enable\n>>>扭曲启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_noise}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用时，显示后续内容
            if (material.GetFloat("_NoiseSwitch") == 1)
            {
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("扭曲贴图"), NoiseTex);
                if (NoiseTex.textureValue != null)
                {
                    m_MaterialEditor.TextureScaleOffsetProperty(NoiseTex);
                    m_MaterialEditor.ShaderProperty(NoiseTexP, "切换通道");
                    m_MaterialEditor.ShaderProperty(NoisePower, "扭曲强度");
                    EditorGUILayout.HelpBox("若调整此值无扭曲，请尝试切换通道", MessageType.None, false);

                    EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                    m_MaterialEditor.ShaderProperty(NoiseTexUspeed, "扭曲U速度");
                    m_MaterialEditor.ShaderProperty(NoiseTexVspeed, "扭曲V速度");
                    EditorGUILayout.EndVertical();
                }
            }
        }
        #endregion



        //- Gam部分的GUI -
        #region [颜色叠加部分GUI]
        void GUI_Gam(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：为材质赋予额外的颜色, 或使用循环的渐变图进行色彩变化");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            //EditorGUILayout.PrefixLabel("颜色叠加开关");
            if (material.GetFloat("_GamTexSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_GamTexSwitch", 1);
                    string warn_gam = $"Soung Shader INFO: GamTex Disable\n>>>颜色叠加禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_gam}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_GamTexSwitch", 0);
                    string warn_gam = $"Soung Shader INFO: GamTex Enable\n>>>颜色叠加启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_gam}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框

            //开关启用时，显示后续内容
            if (material.GetFloat("_GamTexSwitch") == 1)
            {
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("颜色叠加贴图"), GamTex);
                if (GamTex.textureValue != null)
                {
                    m_MaterialEditor.TextureScaleOffsetProperty(GamTex);

                    m_MaterialEditor.ShaderProperty(GamTexP, "切换通道");
                    m_MaterialEditor.ShaderProperty(GamTexRotator, "贴图旋转");
                    m_MaterialEditor.ShaderProperty(GamTexDesaturate, "贴图去色");
                    EditorGUILayout.HelpBox("降低贴图饱和度将其作为黑白遮罩使用, 值越大饱和度约低", MessageType.None, false);

                    //贴图重铺功能区
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("切换贴图重铺");
                    if (material.GetFloat("_GamTexClamp") == 0)
                    {
                       if (GUILayout.Button("重铺", shortButtonStyle))
                       {
                            material.SetFloat("_GamTexClamp", 1);
                            string warn_mainrepeat = $"Soung Shader INFO: WrapMode CLAMP\n>>>贴图设置为钳制模式(单次)";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                        } 
                    }
                    else
                    {
                        if (GUILayout.Button("不重铺", shortButtonStyle))
                        {
                            material.SetFloat("_GamTexClamp", 0);
                            string warn_mainrepeat = $"Soung Shader INFO: WrapMode REPEAT\n>>>贴图设置为重铺模式(重复)";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                    //功能区结束


                    //跟随流动功能区
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("颜色叠加跟随主贴图流动");
                    if (material.GetFloat("_GamTexFollowMainTex") == 0)
                    {
                        if (GUILayout.Button("已关闭", shortButtonStyle))
                        {
                            material.SetFloat("_GamTexFollowMainTex", 1);
                            string warn_gam = $"Soung Shader INFO: Follow UV Flow Enable\n>>>GamTex现在随主帖图流动";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_gam}</size></b></color>");
                        }

                    }
                    else
                    {
                        if (GUILayout.Button("已开启", shortButtonStyle))
                        {
                            material.SetFloat("_GamTexFollowMainTex", 0);
                            string warn_gam = $"Soung Shader INFO: Follow UV Flow Disable\n>>>GamTex不随主帖图流动";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_gam}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                    //功能区结束

                    //不使用跟随流动时，展示相关参数
                    if (material.GetFloat("_GamTexFollowMainTex") == 0)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                        m_MaterialEditor.ShaderProperty(GamTexUspeed, "横向流动速度");
                        m_MaterialEditor.ShaderProperty(GamTexVspeed, "纵向流动速度");
                        EditorGUILayout.EndVertical();
                    }
                }
            }
        }
        #endregion


        // - 程序遮罩部分的GUI -
        #region [程序遮罩部分GUI]
        void GUI_MaskPro(Material material)
        {

            EditorGUILayout.LabelField("功能说明：程序遮罩是一张0-1的黑白渐变图,可在额外遮罩中启用来影响主贴图等");
            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_ProMaskSwitch") == 0)
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_ProMaskSwitch", 1);
                    string warn_maskpro = $"Soung Shader INFO: MaskProg Disable\n>>>程序遮罩禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_maskpro}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_ProMaskSwitch", 0);
                    string warn_maskpro = $"Soung Shader INFO: MaskProg Enable\n>>>程序遮罩启用中, 可配合额外遮罩使用";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_maskpro}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框

            if (material.GetFloat("_ProMaskSwitch") == 0)
            {
                m_MaterialEditor.ShaderProperty(ProMaskDir, "程序遮罩方向");
                EditorGUILayout.HelpBox("控制渐变图的方向", MessageType.None, false);
                m_MaterialEditor.ShaderProperty(ProMaskRange, "程序遮罩范围");
                EditorGUILayout.HelpBox("控制渐变图黑白的范围，值越大黑色范围越大", MessageType.None, false);
            }
        }
        #endregion


        //- 遮罩部分的GUI -
        #region [遮罩部分GUI]
        void GUI_Mask(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：遮罩图用来改变主帖图形状");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_MaskSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_MaskSwitch", 1);
                    string warn_masktex = $"Soung Shader INFO: MaskTex Enable\n>>>遮罩贴图启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_masktex}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_MaskSwitch", 0);
                    string warn_masktex = $"Soung Shader INFO: MaskTex Disable\n>>>遮罩贴图禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_masktex}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框

            //开关启用时展示后续内容
            if (material.GetFloat("_MaskSwitch") == 1)
            {
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("遮罩贴图"), MaskTex);

                if (MaskTex.textureValue != null)
                {
                    m_MaterialEditor.TextureScaleOffsetProperty(MaskTex);

                    m_MaterialEditor.ShaderProperty(MaskTexP, "切换通道");
                    EditorGUILayout.HelpBox("遮罩不生效时, 尝试切换通道", MessageType.None, false);
                    m_MaterialEditor.ShaderProperty(MaskTexRotator, "贴图旋转");
                    m_MaterialEditor.ShaderProperty(OneMinusMask, "反向遮罩");
                    EditorGUILayout.HelpBox("将遮罩反向, 黑>白转化白>黑", MessageType.None, false);


                    //贴图重铺功能区
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("切换贴图重铺");
                    if (material.GetFloat("_MaskTexClamp") == 0)
                    {
                       if (GUILayout.Button("重铺", shortButtonStyle))
                       {
                            material.SetFloat("_MaskTexClamp", 1);
                            string warn_mainrepeat = $"Soung Shader INFO: WrapMode CLAMP\n>>>贴图设置为钳制模式(单次)";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                        } 
                    }
                    else
                    {
                        if (GUILayout.Button("不重铺", shortButtonStyle))
                        {
                            material.SetFloat("_MaskTexClamp", 0);
                            string warn_mainrepeat = $"Soung Shader INFO: WrapMode REPEAT\n>>>贴图设置为重铺模式(重复)";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                    //功能区结束


                    //重铺模式时才显示UV流动
                    if (material.GetFloat("_MaskTexClamp") == 0)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                        m_MaterialEditor.ShaderProperty(MaskTexUspeed, "横向流动速度");
                        m_MaterialEditor.ShaderProperty(MaskTexVspeed, "纵向流动速度");
                        EditorGUILayout.EndVertical();
                    }
                }
            }
        }
        #endregion


        //- 额外遮罩部分的GUI -
        #region [额外遮罩部分GUI]
        void GUI_MaskPlus(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：额外遮罩用来进一步控制纹理形状");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_MaskTexPlusSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_MaskTexPlusSwitch", 1);
                    string warn_masktexplus = $"Soung Shader INFO: MaskTexPlus Enable\n>>>额外遮罩贴图启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_masktexplus}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_MaskTexPlusSwitch", 0);
                    string warn_masktex = $"Soung Shader INFO: MaskTexPlus Disable\n>>>额外遮罩贴图禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_masktex}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用时展示后续内容
            if (material.GetFloat("_MaskTexPlusSwitch") == 1)
            {
                m_MaterialEditor.ShaderProperty(MaskPlusUsePro, "使用程序生成遮罩作为额外遮罩");
                EditorGUILayout.HelpBox("需开启程序遮罩功能使用", MessageType.None, false);

                //判断是否使用程序遮罩,使用则不展示后续内容
                if (material.GetFloat("_MaskPlusUsePro") == 0)
                {
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("额外遮罩"), MaskTexPlus);
                    //未放图时,收起
                    if (MaskTexPlus.textureValue != null)
                    {
                        m_MaterialEditor.TextureScaleOffsetProperty(MaskTexPlus);
                        m_MaterialEditor.ShaderProperty(MaskTexPlusP, "切换通道");
                        EditorGUILayout.HelpBox("遮罩不生效时, 尝试切换通道", MessageType.None, false);
                        m_MaterialEditor.ShaderProperty(MaskTexPlusRotator, "贴图旋转");
                    

                        //贴图重铺功能区
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.PrefixLabel("切换贴图重铺");
                        if (material.GetFloat("_MaskTexPlusClamp") == 0)
                        {
                            if (GUILayout.Button("重铺", shortButtonStyle))
                            {
                                material.SetFloat("_MaskTexPlusClamp", 1);
                                string warn_mainrepeat = $"Soung Shader INFO: WrapMode CLAMP\n>>>贴图设置为钳制模式(单次)";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                            } 
                        }
                        else
                        {
                            if (GUILayout.Button("不重铺", shortButtonStyle))
                            {
                                material.SetFloat("_MaskTexPlusClamp", 0);
                                string warn_mainrepeat = $"Soung Shader INFO: WrapMode REPEAT\n>>>贴图设置为重铺模式(重复)";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                        //功能区结束


                        //重铺模式时才显示UV流动
                        if (material.GetFloat("_MaskTexPlusClamp") == 0)
                        {
                            EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                            m_MaterialEditor.ShaderProperty(MaskTexPlusUspeed, "横向流动速度");
                            m_MaterialEditor.ShaderProperty(MaskTexPlusUspeed, "纵向流动速度");
                            EditorGUILayout.EndVertical();
                        }
                    }
                }  
            }
        }
        #endregion


        //- 流光部分的GUI -
        #region [流光部分GUI]
        void GUI_LG(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：流光用来在主纹理上叠加一层纹理效果");
        
            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_LiuguangSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_LiuguangSwitch", 1);
                    string warn_lgtex = $"Soung Shader INFO: LiuguangTex Enable\n>>>流光启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_lgtex}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_LiuguangSwitch", 0);
                    string warn_lgtex = $"Soung Shader INFO: LiuguangTex Disable\n>>>流光禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_lgtex}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用后展示后续内容
            if (material.GetFloat("_LiuguangSwitch") == 1)
            {
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("流光纹理"), LiuguangTex, LiuguangColor);

                if (LiuguangTex.textureValue != null)
                {

                    m_MaterialEditor.TextureScaleOffsetProperty(LiuguangTex);

                    m_MaterialEditor.ShaderProperty(LiuguangTexP, "切换通道");
                    EditorGUILayout.HelpBox("流光无效时, 尝试切换通道", MessageType.None, false);
                    m_MaterialEditor.ShaderProperty(LiuguangTexRotator, "贴图旋转");

                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("是否禁用纹理自身颜色");

                    if (material.GetFloat("_UseLGTexColor") == 0)
                    {
                        if (GUILayout.Button("启用自身颜色", shortButtonStyle))
                        {
                            material.SetFloat("_UseLGTexColor", 1);
                            string warn_lgtexcolor = $"Soung Shader INFO: Disable Origin LGTex Color\n>>>禁用流光自身颜色";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_lgtexcolor}</size></b></color>");
                        }
                    }
                    else
                    {
                        if (GUILayout.Button("禁用自身颜色", shortButtonStyle))
                        {
                            material.SetFloat("_UseLGTexColor", 0);
                            string warn_lgtexcolor = $"Soung Shader INFO: Enable Origin LGTex Color\n>>>启用流光自身颜色";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_lgtexcolor}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();


                    //选择流光贴图的UV采样模式
                    m_MaterialEditor.ShaderProperty(LiuguangTexUVmode, "流光UV控制模式");
                    EditorGUILayout.HelpBox("变更UV采样模式,本地,极坐标,基于屏幕", MessageType.None, false);
                    

                    //流光本地模式
                    if (material.GetFloat("_LiuguangTexUVmode") == 0)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                        m_MaterialEditor.ShaderProperty(LiuguangUSpeed, "横向流动速度");
                        m_MaterialEditor.ShaderProperty(LiuguangVSpeed, "纵向流动速度");
                        EditorGUILayout.EndVertical();
                    }

                    //流光极坐标模式
                    if (material.GetFloat("_LiuguangTexUVmode") == 1)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.ShaderProperty(LiuguangPolarScale, "流光Polar中心与缩放");
                        EditorGUILayout.HelpBox("xy控制中心点, zw控制缩放与重复", MessageType.None, false);
                        EditorGUILayout.EndVertical();
                    }

                    //流光屏幕模式
                    if (material.GetFloat("_LiuguangTexUVmode") == 2)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.ShaderProperty(LiuguangScreenTilingOffset, "流光Screen重铺与偏移");
                        EditorGUILayout.HelpBox("xy控制平铺值, zw控制偏移值", MessageType.None, false);
                        EditorGUILayout.EndVertical();
                    }
                }
            }
        }
        #endregion



        //- 溶解部分的GUI -
        #region [溶解部分GUI]
        void GUI_Dissolve(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：溶解用来溶解材质纹理");
        
            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_DissolveTexSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_DissolveTexSwitch", 1);
                    string warn_distex = $"Soung Shader INFO: DissolveTex Enable\n>>>溶解启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_distex}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_DissolveTexSwitch", 0);
                    string warn_distex = $"Soung Shader INFO: DissolveTex Disable\n>>>溶解禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_distex}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框

            //启用开关后，展示后续内容
            if (material.GetFloat("_DissolveTexSwitch") == 1)
            {

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("溶解贴图"), DissolveTex);

                if (DissolveTex.textureValue != null)
                {
                    m_MaterialEditor.TextureScaleOffsetProperty(DissolveTex);
                    m_MaterialEditor.ShaderProperty(DissolveTexP, "切换通道");
                    EditorGUILayout.HelpBox("溶解无效时, 尝试切换通道", MessageType.None, false);
                    m_MaterialEditor.ShaderProperty(DissolveTexRotator, "贴图旋转");
                    m_MaterialEditor.ShaderProperty(DissolveSmooth, "整体平滑度");
                    EditorGUILayout.HelpBox("控制溶解软硬程度, 值越大越平滑", MessageType.None, false);
                    m_MaterialEditor.ShaderProperty(DissolvePower, "溶解进度");


                    //溶解控制功能区
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel ("溶解控制模式"); 
                    if (material.GetFloat("_DissolveMode") == 0)
                    {
                        if (GUILayout.Button("材质默认", GUILayout.Width(120)))
                        {
                            material.SetFloat("_DissolveMode", 1);
                            string warn_discustom = $"Soung Shader INFO: CustomUV Control\n>>>添加Custom1.z来控制溶解进度";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_discustom}</size></b></color>");
                        }
                    }
                    else
                    {
                        if (GUILayout.Button("自定义Custom1.z", GUILayout.Width(120)))
                        {
                            material.SetFloat("_DissolveMode", 0);
                            string warn_discustom = $"Soung Shader INFO: Material Control\n>>>使用材质参数控制溶解进度";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_discustom}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                    //溶解控制功能区结束


                    //边缘样式功能区
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel ("溶解边缘样式"); 
                    if (material.GetFloat("_DissolveEdgeSwitch") == 0)
                    {
                        if (GUILayout.Button("软溶解", GUILayout.Width(120)))
                        {
                            material.SetFloat("_DissolveEdgeSwitch", 1);
                            string warn_disedge = $"Soung Shader INFO: Hard Edge Dissolve Mode\n>>>硬边缘溶解启用中";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_disedge}</size></b></color>");
                        }
                    }
                    else
                    {
                        if (GUILayout.Button("硬边溶解", GUILayout.Width(120)))
                        {
                            material.SetFloat("_DissolveEdgeSwitch", 0);
                            string warn_disedge = $"Soung Shader INFO: Soft Dissolve Mode\n>>>软溶解启用中";
                            Debug.Log($"<color=#66ccff><b><size=10>{warn_disedge}</size></b></color>");
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                    //边缘样式功能区结束


                    //使用硬边模式时展示后续内容
                    if (material.GetFloat("_DissolveEdgeSwitch") == 1)
                    {
                        m_MaterialEditor.ShaderProperty(DissolveEdgeColor, "边缘颜色");
                        m_MaterialEditor.ShaderProperty(DissolveEdgeWide, "边缘宽度");
                    }


                    //使用材质默认流动时展示后续内容
                    if (material.GetFloat("_DissolveMode") == 0)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                        m_MaterialEditor.ShaderProperty(DissolveTexUspeed, "溶解U速度");
                        m_MaterialEditor.ShaderProperty(DissolveTexVspeed, "溶解V速度");
                        EditorGUILayout.EndVertical();
                    }
                }
            }
        }
        #endregion


        //- 定向溶解部分的GUI -
        #region [定向溶解部分GUI]
        void GUI_DissolvePlus(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：使用一张黑白Mask图来辅助控制溶解方向");
            
        
            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.HelpBox("使用前, 请先确保开启溶解功能", MessageType.None, false);
            if (material.GetFloat("_DissolveTexPlusSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_DissolveTexPlusSwitch", 1);
                    string warn_distexplus = $"Soung Shader INFO: DissolveTexPlus Enable\n>>>定向溶解启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_distexplus}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_DissolveTexPlusSwitch", 0);
                    string warn_distexplus = $"Soung Shader INFO: DissolveTexPlus Disable\n>>>定向溶解禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_distexplus}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用时展示后续内容
            if (material.GetFloat("_DissolveTexPlusSwitch") == 1)
            {
                m_MaterialEditor.ShaderProperty(DissolveTexPlusUsePro, "使用程序生成遮罩作为定向溶解图");
                EditorGUILayout.HelpBox("需开启程序遮罩功能使用", MessageType.None, false);

                //判断是否使用程序遮罩,使用则不展示后续内容
                if (material.GetFloat("_DissolveTexPlusUsePro") == 0)
                {
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("定向溶解贴图"), DissolveTexPlus);
                    //未放图时,收起
                    if (DissolveTexPlus.textureValue != null)
                    {
                        m_MaterialEditor.TextureScaleOffsetProperty(DissolveTexPlus);
                        m_MaterialEditor.ShaderProperty(DissolveTexPlusP, "切换通道");
                        EditorGUILayout.HelpBox("溶解不生效时, 尝试切换通道", MessageType.None, false);
                        m_MaterialEditor.ShaderProperty(DissolveTexPlusRotator, "贴图旋转");
                        m_MaterialEditor.ShaderProperty(DissolveTexPlusPower, "定向溶解强度");
                        EditorGUILayout.HelpBox("此值越大, 定向溶解效果越明显", MessageType.None, false);
                    
                        //UV流动模式功能区
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.PrefixLabel ("定向溶解流动模式"); 
                        if (material.GetFloat("_DissolveTexPlusFlowMode") == 0)
                        {
                            if (GUILayout.Button("材质默认", GUILayout.Width(120)))
                            {
                                material.SetFloat("_DissolveTexPlusFlowMode", 1);
                                string warn_mainuvflow = $"Soung Shader INFO: CustomUV Flow\n>>>添加Custom2.xy来控制定向溶解流动";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainuvflow}</size></b></color>");
                            }
                        }
                        else
                        {
                            if (GUILayout.Button("自定义Custom2.xy", GUILayout.Width(120)))
                            {
                                material.SetFloat("_DissolveTexPlusFlowMode", 0);
                                string warn_mainuvflow = $"Soung Shader INFO: Material Flow\n>>>使用材质参数控制定向溶解流动";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainuvflow}</size></b></color>");
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                        //UV流动模式功能区结束


                        //贴图重铺功能区
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.PrefixLabel("切换贴图重铺");
                        if (material.GetFloat("_DissolveTexPlusClamp") == 0)
                        {
                            if (GUILayout.Button("重铺", shortButtonStyle))
                            {
                                material.SetFloat("_DissolveTexPlusClamp", 1);
                                string warn_mainrepeat = $"Soung Shader INFO: WrapMode CLAMP\n>>>贴图设置为钳制模式(单次)";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                            } 
                        }
                        else
                        {
                            if (GUILayout.Button("不重铺", shortButtonStyle))
                            {
                                material.SetFloat("_DissolveTexPlusClamp", 0);
                                string warn_mainrepeat = $"Soung Shader INFO: WrapMode REPEAT\n>>>贴图设置为重铺模式(重复)";
                                Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                        //功能区结束


                        //材质默认模式时才显示UV流动
                        if (material.GetFloat("_DissolveTexPlusFlowMode") == 0)
                        {
                            EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                            m_MaterialEditor.ShaderProperty(DissolveTexPlusUspeed, "横向流动速度");
                            m_MaterialEditor.ShaderProperty(DissolveTexPlusVspeed, "纵向流动速度");
                            EditorGUILayout.EndVertical();
                        }
                    }
                }
                else //即便使用程序遮罩不展示后续内容,也应该展示溶解强度控制框
                {
                    m_MaterialEditor.ShaderProperty(DissolveTexPlusPower, "定向溶解强度");
                    EditorGUILayout.HelpBox("此值越大, 定向溶解效果越明显", MessageType.None, false);
                }
            }
        }
        #endregion


        //- 顶点偏移部分的GUI -
        #region [顶点偏移部分GUI]
        void GUI_Vertex(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：使用一张贴图UV来沿法线方向偏移模型顶点，使模型表面有动画效果");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_VertexSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_VertexSwitch", 1);
                    string warn_vertex = $"Soung Shader INFO: VertexTex Disable\n>>>顶点偏移禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_vertex}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_VertexSwitch", 0);
                    string warn_vertex = $"Soung Shader INFO: VertexTex Enable\n>>>顶点偏移启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_vertex}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用时，显示后续内容
            if (material.GetFloat("_VertexSwitch") == 1)
            {
                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("顶点偏移贴图"), VertexTex);
                if (VertexTex.textureValue != null)
                {
                    m_MaterialEditor.TextureScaleOffsetProperty(VertexTex);
                    m_MaterialEditor.ShaderProperty(VertexPower, "偏移强度");
                    m_MaterialEditor.ShaderProperty(VertexTexDir, "偏移轴向");
                    EditorGUILayout.HelpBox("使用XYZ三个分量的法线方向进行偏移", MessageType.None, false);

                    EditorGUILayout.BeginVertical(EditorStyles.helpBox, shortButtonStyle);
                    m_MaterialEditor.ShaderProperty(VertexTexUspeed, "顶点偏移U速率");
                    m_MaterialEditor.ShaderProperty(VertexTexVspeed, "顶点偏移V速率");
                    EditorGUILayout.EndVertical();
                }
            }
        }
        #endregion


        //- 菲涅尔部分的GUI -
        #region [菲涅尔部分GUI]
        void GUI_Fresnel(Material material)
        {
            //功能说明
            EditorGUILayout.LabelField("功能说明：为模型添加菲涅尔效果, 可用于边缘光或模型虚化等");

            //绘制开关框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            if (material.GetFloat("_FresnelSwitch") == 0)
            {
                if (GUILayout.Button("已关闭"))
                {
                    material.SetFloat("_FresnelSwitch", 1);
                    string warn_fresnel = $"Soung Shader INFO: Fresnel Enable\n>>>菲涅尔启用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_fresnel}</size></b></color>");
                }
            }
            else
            {
                if (GUILayout.Button("已开启"))
                {
                    material.SetFloat("_FresnelSwitch", 0);
                    string warn_fresnel = $"Soung Shader INFO: Fresnel Disable\n>>>菲涅尔禁用中";
                    Debug.Log($"<color=#66ccff><b><size=10>{warn_fresnel}</size></b></color>");
                }
            }
            EditorGUILayout.EndVertical();
            //结束绘制开关框


            //开关启用时，显示后续内容
            if (material.GetFloat("_FresnelSwitch") == 1)
            {
                m_MaterialEditor.ShaderProperty(FresnelColor, "菲涅尔颜色");

                //菲涅尔模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("菲涅尔模式");
                if (material.GetFloat("_FresnelMode") == 0)
                {
                    if (GUILayout.Button("菲涅尔", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelMode", 1);
                        string warn_mainrepeat = $"Soung Shader INFO: FresnelMode Bokeh\n>>>菲涅尔设置为边缘虚化";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    } 
                }
                else
                {
                    if (GUILayout.Button("边缘虚化", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelMode", 0);
                        string warn_mainrepeat = $"Soung Shader INFO: FresnelMode Default\n>>>菲涅尔设置为默认";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //功能区结束

                //注释条
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.HelpBox("菲涅尔:默认状态,中心虚化\n边缘虚化:反向菲涅尔,中间实边缘虚", MessageType.None, false);
                EditorGUILayout.EndHorizontal();
                //注释条结束

                //菲涅尔颜色模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("菲涅尔颜色模式");
                if (material.GetFloat("_FresnelColorMode") == 0)
                {
                    if (GUILayout.Button("相乘", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelColorMode", 1);
                        string warn_mainrepeat = $"Soung Shader INFO: FresnelColorMode Add\n>>>菲涅尔颜色与材质相加";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    } 
                }
                else
                {
                    if (GUILayout.Button("叠加", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelColorMode", 0);
                        string warn_mainrepeat = $"Soung Shader INFO: FresnelColorMode Mult\n>>>菲涅尔颜色与材质相乘";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //功能区结束

                //注释条
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.HelpBox("相乘:直接将菲涅尔颜色值与本身相乘\n叠加:在本身颜色上叠加一层菲涅尔颜色", MessageType.None, false);
                EditorGUILayout.EndHorizontal();
                //注释条结束
                
                //菲涅尔Alpha模式功能区
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("是否启用菲涅尔Alpha通道");
                if (material.GetFloat("_FresnelAlphaMode") == 0)
                {
                    if (GUILayout.Button("不启用", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelAlphaMode", 1);
                        string warn_mainrepeat = $"Soung Shader INFO: Use Fresnel Alpha\n>>>现在菲涅尔Alpha值可用";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    } 
                }
                else
                {
                    if (GUILayout.Button("启用", shortButtonStyle))
                    {
                        material.SetFloat("_FresnelAlphaMode", 0);
                        string warn_mainrepeat = $"Soung Shader INFO: Don't use Fresnel Alpha\n>>>现在菲涅尔Alpha值不可用";
                        Debug.Log($"<color=#66ccff><b><size=10>{warn_mainrepeat}</size></b></color>");
                    }
                }
                EditorGUILayout.EndHorizontal();
                //功能区结束

                //注释条
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.HelpBox("不启用:默认正常模式\n启用:将菲涅尔透明度作用于材质", MessageType.None, false);
                EditorGUILayout.EndHorizontal();
                //注释条结束

                m_MaterialEditor.ShaderProperty(FresnelSet, "菲涅尔强度/边缘/范围");
                EditorGUILayout.HelpBox("控制菲涅尔的样式参数", MessageType.None, false);
            }
        }
        #endregion
    }
}