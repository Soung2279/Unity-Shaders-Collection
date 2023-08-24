using System;
using UnityEngine;
using UnityEditor;


//创建一个GUI类
public class LTY_ShaderGUI_Built_in : ShaderGUI
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
    static bool _Remap_Foldout = false;
    static bool _Mask_Foldout = false;
    static bool _Dissolve_Foldout = false;
    static bool _Distortion_Foldout = false;
    static bool _Fresnel_Foldout = false;
    static bool _WPO_Foldout = false;

    MaterialEditor m_MaterialEditor;


    //自定义主要贴图需要显示的属性
    #region [贴图按钮命名]

    #region [主贴图按钮命名]
    //主帖图部分
    MaterialProperty Main_Tex = null;

    MaterialProperty Main_Tex_Color = null;

    MaterialProperty Main_Tex_A_R = null;

    MaterialProperty Main_Tex_Custom_ZW = null;

    MaterialProperty Main_Tex_ClampSwitch = null;

    MaterialProperty Main_Tex_Rotator = null;

    MaterialProperty Main_Tex_U_speed = null;

    MaterialProperty Main_Tex_V_speed = null;

    MaterialProperty SoftParticle = null;
    
    #endregion 

    #region [Remap贴图按钮命名]
    //Remap部分

    MaterialProperty Remap_Tex = null;

    MaterialProperty Remap_Tex_A_R = null;

    MaterialProperty Remap_Tex_Desaturate = null;

    MaterialProperty Remap_Tex_ClampSwitch = null;

    MaterialProperty Remap_Tex_Rotator = null;

    MaterialProperty Remap_Tex_Followl_Main_Tex = null;

    MaterialProperty Remap_Tex_U_speed = null;

    MaterialProperty Remap_Tex_V_speed = null;
    #endregion

    #region [遮罩贴图按钮命名]
    //遮罩部分

    MaterialProperty Mask_Tex = null;

    MaterialProperty Mask_Tex_A_R = null;

    MaterialProperty Mask_Tex_ClampSwitch = null;

    MaterialProperty Mask_Tex_Rotator = null;

    MaterialProperty Mask_Tex_U_speed = null;

    MaterialProperty Mask_Tex_V_speed = null;
    #endregion

    #region [溶解贴图按钮命名]
    //溶解部分

    MaterialProperty Dissolve_Tex = null;

    MaterialProperty Dissolve_Switch = null;

    MaterialProperty Dissolve_Tex_A_R = null;

    MaterialProperty Dissolve_Tex_Custom_X = null;

    MaterialProperty Dissolve_Tex_Rotator = null;

    MaterialProperty Dissolve_Tex_smooth = null;

    MaterialProperty Dissolve_Tex_power = null;

    MaterialProperty Dissolve_Tex_U_speed = null;

    MaterialProperty Dissolve_Tex_V_speed = null;
    #endregion

    #region [扭曲贴图按钮命名]
    //扭曲部分

    MaterialProperty Distortion_Tex = null;

    MaterialProperty Distortion_Switch = null;

    MaterialProperty Distortion_Tex_Power = null;

    MaterialProperty Distortion_Tex_U_speed = null;

    MaterialProperty Distortion_Tex_V_speed = null;
    #endregion

    #region [菲尼尔按钮命名]
    //菲尼尔部分

    MaterialProperty Fresnel_Color = null;

    MaterialProperty Fresnel_Switch = null;

    MaterialProperty Fresnel_Bokeh = null;

    MaterialProperty Fresnel_scale = null;

    MaterialProperty Fresnel_power = null;
    #endregion

    #region [顶点偏移贴图按钮命名]
    //顶点偏移部分

    MaterialProperty WPO_Tex = null;

    MaterialProperty WPO_Switch = null;

    MaterialProperty WPO_CustomSwitch_V = null;

    MaterialProperty WPO_tex_power = null;

    MaterialProperty WPO_Tex_Direction = null;

    MaterialProperty WPO_Tex_U_speed = null;

    MaterialProperty WPO_Tex_V_speed = null;
    #endregion

    #endregion

    //引用参数部分(从引擎的按钮里面提取数值，以便下面随时取用)
    public void FindProperties(MaterialProperty[] props)
    {



        #region [主贴图按钮参数引用]
        //主贴图属性指向

        Main_Tex = FindProperty("_Main_Tex", props);

        Main_Tex_Color = FindProperty("_Main_Tex_Color", props);

        Main_Tex_A_R = FindProperty("_Main_Tex_A_R", props);

        Main_Tex_Custom_ZW = FindProperty("_Main_Tex_Custom_ZW", props);

        Main_Tex_ClampSwitch = FindProperty("_Main_Tex_ClampSwitch", props);

        Main_Tex_Rotator = FindProperty("_Main_Tex_Rotator", props);

        Main_Tex_U_speed = FindProperty("_Main_Tex_U_speed", props);

        Main_Tex_V_speed = FindProperty("_Main_Tex_V_speed", props);

        SoftParticle = FindProperty("_SoftParticle", props);
        

        #endregion

        #region [Remap贴图按钮参数引用]
        //Remap属性指向

        Remap_Tex = FindProperty("_Remap_Tex", props);

        Remap_Tex_A_R = FindProperty("_Remap_Tex_A_R", props);

        Remap_Tex_Desaturate = FindProperty("_Remap_Tex_Desaturate", props);

        Remap_Tex_ClampSwitch = FindProperty("_Remap_Tex_ClampSwitch", props);

        Remap_Tex_Rotator = FindProperty("_Remap_Tex_Rotator", props);

        Remap_Tex_Followl_Main_Tex = FindProperty("_Remap_Tex_Followl_Main_Tex", props);

        Remap_Tex_U_speed = FindProperty("_Remap_Tex_U_speed", props);

        Remap_Tex_V_speed = FindProperty("_Remap_Tex_V_speed", props);
        #endregion

        #region [遮罩贴图按钮参数引用]
        //遮罩部分

        Mask_Tex = FindProperty("_Mask_Tex", props);

        Mask_Tex_A_R = FindProperty("_Mask_Tex_A_R", props);

        Mask_Tex_ClampSwitch = FindProperty("_Mask_Tex_ClampSwitch", props);

        Mask_Tex_Rotator = FindProperty("_Mask_Tex_Rotator", props);

        Mask_Tex_U_speed = FindProperty("_Mask_Tex_U_speed", props);

        Mask_Tex_V_speed = FindProperty("_Mask_Tex_V_speed", props);
        #endregion 

        #region [溶解贴图按钮参数引用]
        //溶解部分

        Dissolve_Tex = FindProperty("_Dissolve_Tex", props);

        Dissolve_Switch = FindProperty("_Dissolve_Switch", props);

        Dissolve_Tex_A_R = FindProperty("_Dissolve_Tex_A_R", props);

        Dissolve_Tex_Custom_X = FindProperty("_Dissolve_Tex_Custom_X", props);

        Dissolve_Tex_Rotator = FindProperty("_Dissolve_Tex_Rotator", props);

        Dissolve_Tex_smooth = FindProperty("_Dissolve_Tex_smooth", props);

        Dissolve_Tex_power = FindProperty("_Dissolve_Tex_power", props);

        Dissolve_Tex_U_speed = FindProperty("_Dissolve_Tex_U_speed", props);

        Dissolve_Tex_V_speed = FindProperty("_Dissolve_Tex_V_speed", props);
        #endregion

        #region [扭曲贴图按钮参数引用]
        //扭曲部分

        Distortion_Tex = FindProperty("_Distortion_Tex", props);

        Distortion_Switch = FindProperty("_Distortion_Switch", props);

        Distortion_Tex_Power = FindProperty("_Distortion_Tex_Power", props);

        Distortion_Tex_U_speed = FindProperty("_Distortion_Tex_U_speed", props);

        Distortion_Tex_V_speed = FindProperty("_Distortion_Tex_V_speed", props);
        #endregion

        #region [菲尼尔按钮参数引用]
        //菲尼尔部分

        Fresnel_Color = FindProperty("_Fresnel_Color", props);

        Fresnel_Switch = FindProperty("_Fresnel_Switch", props);

        Fresnel_Bokeh = FindProperty("_Fresnel_Bokeh", props);

        Fresnel_scale = FindProperty("_Fresnel_scale", props);

        Fresnel_power = FindProperty("_Fresnel_power", props);
        #endregion

        #region [顶点偏移贴图按钮参数引用]
        //顶点偏移部分

        WPO_Tex = FindProperty("_WPO_Tex", props);

        WPO_Switch = FindProperty("_WPO_Switch", props);

        WPO_CustomSwitch_V = FindProperty("_WPO_CustomSwitch_Y", props);

        WPO_tex_power = FindProperty("_WPO_tex_power", props);

        WPO_Tex_Direction = FindProperty("_WPO_Tex_Direction", props);

        WPO_Tex_U_speed = FindProperty("_WPO_Tex_U_speed", props);

        WPO_Tex_V_speed = FindProperty("_WPO_Tex_V_speed", props);
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


        //基础设置下拉菜单

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        _Base_Foldout = Foldout(_Base_Foldout, "基础设置(BasicSettings)");

        if (_Base_Foldout)
        {
            EditorGUI.indentLevel++;



            GUI_Base(material);



            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();

        //主帖图下拉菜单

        #region [主贴图部分]
        if (Main_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Main_Foldout = Foldout(_Main_Foldout, "主贴图(MainTexture)");

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
            _Main_Foldout = Foldout2(_Main_Foldout, "主贴图(MainTexture)");

            if (_Main_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Main(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

        //颜色叠加下拉菜单

        #region [Remap部分]
        if (Remap_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Remap_Foldout = Foldout(_Remap_Foldout, "颜色叠加贴图(RemapTexture)");

            if (_Remap_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Remap(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _Remap_Foldout = Foldout2(_Remap_Foldout, "颜色叠加贴图(RemapTexture)");

            if (_Remap_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Remap(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

        //遮罩下拉菜单

        #region [遮罩部分]
        if (Mask_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Mask_Foldout = Foldout(_Mask_Foldout, "遮罩贴图(MaskTexture)");

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
            _Mask_Foldout = Foldout2(_Mask_Foldout, "遮罩贴图(MaskTexture)");

            if (_Mask_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Mask(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

        //溶解下拉菜单

        #region [溶解部分]
        if (Dissolve_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Dissolve_Foldout = Foldout(_Dissolve_Foldout, "溶解贴图(DissolveTexture)");

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
            _Dissolve_Foldout = Foldout2(_Dissolve_Foldout, "溶解贴图(DissolveTexture)");

            if (_Dissolve_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Dissolve(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

        //扭曲下拉菜单

        #region [扭曲部分]
        if (Distortion_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Distortion_Foldout = Foldout(_Distortion_Foldout, "扭曲贴图(DistortionTexture)");

            if (_Distortion_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Distortion(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _Distortion_Foldout = Foldout2(_Distortion_Foldout, "扭曲贴图(DistortionTexture)");

            if (_Distortion_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Distortion(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

        //菲尼尔下拉菜单

        #region [菲尼尔部分]

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Fresnel_Foldout = Foldout2(_Fresnel_Foldout, "菲涅尔（外边缘发光）");

            if (_Fresnel_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_Fresnel(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        #endregion

        //顶点偏移下拉菜单

        #region [顶点偏移部分]
        if (WPO_Tex.textureValue != null)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _WPO_Foldout = Foldout(_WPO_Foldout, "顶点偏移贴图(WPOTexture)");

            if (_WPO_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_WPO(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        else
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _WPO_Foldout = Foldout2(_WPO_Foldout, "顶点偏移贴图(WPOTexture)");

            if (_WPO_Foldout)
            {
                EditorGUI.indentLevel++;

                GUI_WPO(material);

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }
        #endregion



        //------------------------------------函数引用----------------------------------------------

        void GUI_Base(Material material)
        //混合模式按钮参数设置
        {
            //绘制垂直的方框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            #region [混合模式]
            //绘制横向的方框
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("混合模式");

            if (material.GetFloat("_Dst") == 1)
            {
                if (GUILayout.Button("Add", shortButtonStyle))
                {
                    material.SetFloat("_Dst", 10);
                    material.EnableKeyword("_ISALPHA_ON");
                }
            }
            else
            {
                if (GUILayout.Button("Alpha", shortButtonStyle))
                {
                    material.SetFloat("_Dst", 1);
                    material.DisableKeyword("_ISALPHA_ON");
                }

            }
            EditorGUILayout.EndHorizontal();
            #endregion

            #region [剔除模式]

            EditorGUILayout.BeginHorizontal();
            {

                EditorGUILayout.PrefixLabel("剔除模式");
                if (material.GetFloat("_CullMode") == 0)
                {
                    if (GUILayout.Button("双面显示", shortButtonStyle))
                    {
                        material.SetFloat("_CullMode", 1);
                    }
                }
                else
                {
                    if (material.GetFloat("_CullMode") == 1)
                    {
                        if (GUILayout.Button("显示背面", shortButtonStyle))
                        {
                            material.SetFloat("_CullMode", 2);
                        }
                    }

                    else
                    {
                        if (GUILayout.Button("显示正面", shortButtonStyle))
                        {
                            material.SetFloat("_CullMode", 0);
                        }
                    }

                }

            }
            EditorGUILayout.EndHorizontal();

            #endregion

            #region 显示在最前层
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("显示在最前层");


            if (material.GetFloat("_ZTestMode") == 4)
            {
                if (GUILayout.Button("否", shortButtonStyle))
                {
                    material.SetFloat("_ZTestMode", 8);

                }
            }
            else
            {
                if (GUILayout.Button("是", shortButtonStyle))
                {
                    material.SetFloat("_ZTestMode", 4);
                }
            }

            EditorGUILayout.EndHorizontal();
            #endregion

            #region[写入深度] 
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("写入深度");


            if (material.GetFloat("_Zwrite") == 0)
            {
                if (GUILayout.Button("否", shortButtonStyle))
                {
                    material.SetFloat("_Zwrite", 1);

                }
            }
            else
            {
                if (GUILayout.Button("是", shortButtonStyle))
                {
                    material.SetFloat("_Zwrite", 0);
                }
            }

            EditorGUILayout.EndHorizontal();
            #endregion

            #region[软粒子] 
            EditorGUILayout.BeginHorizontal();

            m_MaterialEditor.ShaderProperty(SoftParticle, "软粒子");

            EditorGUILayout.EndHorizontal();
            #endregion 

            EditorGUILayout.EndHorizontal();
            //五个像素的高度
            GUILayout.Space(5);
        }

        //主帖图具体显示内容
        void GUI_Main(Material material)
        {

            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("主贴图"), Main_Tex, Main_Tex_Color);



            if (Main_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(Main_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Main_Tex_A_R, "切换通道");

                //疑问：横向的框怎么改长度
                m_MaterialEditor.ShaderProperty(Main_Tex_Rotator, "贴图旋转");

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("切换贴图重铺模式");
                #region [主贴图重铺]
                if (material.GetFloat("_Main_Tex_ClampSwitch") == 0)
                {
                    if (GUILayout.Button("重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Main_Tex_ClampSwitch", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("不重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Main_Tex_ClampSwitch", 0);
                    }
                }
                EditorGUILayout.EndVertical();
                #endregion 


                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel ("是否开启自定义UV流动（ZW）"); 

                if (material.GetFloat("_Main_Tex_Custom_ZW") == 0)
                {
                    if (GUILayout.Button("已关闭",shortButtonStyle))
                    {
                        material.SetFloat("_Main_Tex_Custom_ZW", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("已开启", shortButtonStyle))
                    {
                        material.SetFloat("_Main_Tex_Custom_ZW", 0);
                    }
                }
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();

                if (material.GetFloat("_Main_Tex_Custom_ZW") == 0)

                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(Main_Tex_U_speed, "横向流动速度");
                    m_MaterialEditor.ShaderProperty(Main_Tex_V_speed, "纵向流动速度");
                    EditorGUILayout.EndVertical();
                }




            }
        }

        //Remap具体显示内容
        void GUI_Remap(Material material)
        {

            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("颜色叠加贴图"), Remap_Tex);



            if (Remap_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(Remap_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Remap_Tex_A_R, "切换通道");

                //疑问：横向的框怎么改长度
                m_MaterialEditor.ShaderProperty(Remap_Tex_Desaturate, "贴图去色");
                m_MaterialEditor.ShaderProperty(Remap_Tex_Rotator, "贴图旋转");

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("切换贴图重铺");
                #region [Remap贴图重铺]
                if (material.GetFloat("_Remap_Tex_ClampSwitch") == 0)
                {
                    if (GUILayout.Button("重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Remap_Tex_ClampSwitch", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("不重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Remap_Tex_ClampSwitch", 0);
                    }
                }
                EditorGUILayout.EndVertical();
                #endregion

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("跟随主贴图一次性UV移动");

                if (material.GetFloat("_Remap_Tex_Followl_Main_Tex") == 0)
                {
                    if (GUILayout.Button("已关闭", shortButtonStyle))
                    {
                        material.SetFloat("_Remap_Tex_Followl_Main_Tex", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("已开启", shortButtonStyle))
                    {
                        material.SetFloat("_Remap_Tex_Followl_Main_Tex", 0);
                    }
                }
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();

                if (material.GetFloat("_Remap_Tex_Followl_Main_Tex") == 0)

                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(Remap_Tex_U_speed, "横向流动速度");
                    m_MaterialEditor.ShaderProperty(Remap_Tex_V_speed, "纵向流动速度");
                    EditorGUILayout.EndVertical();
                }

            }
        }

        //遮罩图具体显示内容
        void GUI_Mask(Material material)

        { 
        

            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("遮罩贴图"), Mask_Tex);



            if (Mask_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(Mask_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Mask_Tex_A_R, "切换通道");

                //疑问：横向的框怎么改长度
                m_MaterialEditor.ShaderProperty(Mask_Tex_Rotator, "贴图旋转");

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("切换贴图重铺");
                #region [遮罩贴图重铺]
                if (material.GetFloat("_Mask_Tex_ClampSwitch") == 0)
                {
                    if (GUILayout.Button("重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Mask_Tex_ClampSwitch", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("不重铺", shortButtonStyle))
                    {
                        material.SetFloat("_Mask_Tex_ClampSwitch", 0);
                    }
                }
                EditorGUILayout.EndVertical();
                #endregion


                EditorGUILayout.EndVertical();

                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(Mask_Tex_U_speed, "横向流动速度");
                    m_MaterialEditor.ShaderProperty(Mask_Tex_V_speed, "纵向流动速度");
                    EditorGUILayout.EndVertical();

            }
        }

        //溶解图具体显示内容

        void GUI_Dissolve(Material material)

        {


            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("溶解贴图"), Dissolve_Tex);



            if (Dissolve_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(Dissolve_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Dissolve_Switch, "溶解开关");
                m_MaterialEditor.ShaderProperty(Dissolve_Tex_A_R, "切换通道");


                //疑问：横向的框怎么改长度
                m_MaterialEditor.ShaderProperty(Dissolve_Tex_Rotator, "贴图旋转");
                m_MaterialEditor.ShaderProperty(Dissolve_Tex_smooth, "软硬溶解过渡");
                m_MaterialEditor.ShaderProperty(Dissolve_Tex_power, "溶解进度");

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("是否启用自定义控制溶解（X）");

                if (material.GetFloat("_Dissolve_Tex_Custom_X") == 0)
                {
                    if (GUILayout.Button("已关闭", shortButtonStyle))
                    {
                        material.SetFloat("_Dissolve_Tex_Custom_X", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("已开启", shortButtonStyle))
                    {
                        material.SetFloat("_Dissolve_Tex_Custom_X", 0);
                    }
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.EndVertical();

                if (material.GetFloat("_Dissolve_Tex_Custom_X") == 0)

                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(Dissolve_Tex_U_speed, "横向流动速度");
                    m_MaterialEditor.ShaderProperty(Dissolve_Tex_V_speed, "纵向流动速度");
                    EditorGUILayout.EndVertical();
                }
            }
        }

        //扭曲下拉菜单

        void GUI_Distortion(Material material)

        {


            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("扭曲贴图"), Distortion_Tex);



            if (Distortion_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(Distortion_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("扭曲开关");

                if (material.GetFloat("_Distortion_Switch") == 0)
                {
                    if (GUILayout.Button("已关闭", shortButtonStyle))
                    {
                        material.SetFloat("_Distortion_Switch", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("已开启", shortButtonStyle))
                    {
                        material.SetFloat("_Distortion_Switch", 0);
                    }
                }
                EditorGUILayout.EndVertical();


                m_MaterialEditor.ShaderProperty(Distortion_Tex_Power, "扭曲强度");
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Distortion_Tex_U_speed, "横向流动速度");
                m_MaterialEditor.ShaderProperty(Distortion_Tex_V_speed, "纵向流动速度");
                EditorGUILayout.EndVertical();

            }
        }

        //菲尼尔下拉菜单

        void GUI_Fresnel(Material material)

        {

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(Fresnel_Color, "菲涅尔颜色");
                m_MaterialEditor.ShaderProperty(Fresnel_Switch, "菲涅尔开关");
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("菲涅尔模式");

            if (material.GetFloat("_Fresnel_Bokeh") == 0)
            {
                if (GUILayout.Button("菲涅尔", shortButtonStyle))
                {
                    material.SetFloat("_Fresnel_Bokeh", 1);
                }

            }
            else
            {
                if (GUILayout.Button("边缘虚化", shortButtonStyle))
                {
                    material.SetFloat("_Fresnel_Bokeh", 0);
                }
            }
            EditorGUILayout.EndVertical();

            m_MaterialEditor.ShaderProperty(Fresnel_scale, "菲涅尔亮度");
            m_MaterialEditor.ShaderProperty(Fresnel_power, "菲涅尔强度");
            

                EditorGUILayout.EndVertical();
        }

        //顶点偏移下拉菜单

        void GUI_WPO(Material material)

        {


            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("顶点偏移贴图"), WPO_Tex);



            if (WPO_Tex.textureValue != null)
            {

                m_MaterialEditor.TextureScaleOffsetProperty(WPO_Tex);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox); 
                m_MaterialEditor.ShaderProperty(WPO_Switch, "顶点偏移开关");

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel("自定义顶点偏移开关（Y）");

                if (material.GetFloat("_WPO_CustomSwitch_Y") == 0)
                {
                    if (GUILayout.Button("已关闭", shortButtonStyle))
                    {
                        material.SetFloat("_WPO_CustomSwitch_Y", 1);
                    }

                }
                else
                {
                    if (GUILayout.Button("已开启", shortButtonStyle))
                    {
                        material.SetFloat("_WPO_CustomSwitch_Y", 0);
                    }
                }
                EditorGUILayout.EndVertical();

                m_MaterialEditor.ShaderProperty(WPO_tex_power, "顶点偏移强度");
                m_MaterialEditor.ShaderProperty(WPO_Tex_Direction, "顶点偏移轴向");
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(WPO_Tex_U_speed, "横向流动速度");
                m_MaterialEditor.ShaderProperty(WPO_Tex_V_speed, "纵向流动速度");
                EditorGUILayout.EndVertical();

            }
        }


    }
}