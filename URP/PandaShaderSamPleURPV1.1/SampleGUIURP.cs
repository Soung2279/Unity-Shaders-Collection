#if UNITY_EDITOR
using System;
using UnityEngine;
using UnityEditor;


//����һ��GUI��
public class SampleGUIURP : ShaderGUI
{
    public GUIStyle style = new GUIStyle();
    static bool Foldout(bool display, string title)
    {
        var style = new GUIStyle("ShurikenModuleTitle");
        style.font = new GUIStyle(EditorStyles.boldLabel).font;
        style.border = new RectOffset(15, 7, 4, 4);
        style.fixedHeight = 22;
        style.contentOffset = new Vector2(20f, -2f);
        style.fontSize = 11;
        style.normal.textColor = new Color(0.7f, 0.8f, 0.9f);




        var rect = GUILayoutUtility.GetRect(16f, 25f, style);
        GUI.Box(rect, title, style);

        var e = Event.current;

        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
        if (e.type == EventType.Repaint)
        {
            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
        }

        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
        {
            display = !display;
            e.Use();
        }

        return display;
    }

    static bool _Function_Foldout = false;
    static bool _Base_Foldout = false;
    static bool _Common_Foldout = true;
    static bool _Main_Foldout = true;
    static bool _Tips_Foldout = false;
    static bool _Mask_Foldout = true;
    static bool _Distort_Foldout = true;
    static bool _Dissolve_Foldout = true;
    static bool _FNL_Foldout = true;
    static bool _VTO_Foldout = true;
    static bool _Refaction_Foldout = true;

    MaterialEditor m_MaterialEditor;

    MaterialProperty BlendMode = null;
    MaterialProperty CullMode = null;
    MaterialProperty ZTest = null;


    MaterialProperty MainTex = null;
    MaterialProperty MainColor = null;
    MaterialProperty MainTexAR = null;
    MaterialProperty MainTexUSpeed = null;
    MaterialProperty MainTexVSpeed = null;
    MaterialProperty CustomMainTexUOffset = null;
    MaterialProperty CustomMainTexVOffset = null;
    MaterialProperty MainTexUOffsetC = null;
    MaterialProperty MainTexVOffsetC = null;
    MaterialProperty MainTexUClamp = null;
    MaterialProperty MainTexVClamp = null;
    MaterialProperty MainTexRefine = null;
    MaterialProperty MainTexDesaturate = null;
    MaterialProperty MainTexRotator = null;
    MaterialProperty MainTexDetail = null;
    MaterialProperty MainTexUMirror = null;
    MaterialProperty MainTexVMirror = null;
    MaterialProperty MainTexUVClip = null;
    MaterialProperty MainTexCAFator = null;

    MaterialProperty FMaskTex = null;
    MaterialProperty MaskTex = null;
    MaterialProperty MaskTexAR = null;
    MaterialProperty MaskTexUSpeed = null;
    MaterialProperty MaskTexVSpeed = null;
    MaterialProperty CustomMaskTexUOffset = null;
    MaterialProperty CustomMaskTexVOffset = null;
    MaterialProperty MaskTexUOffsetC = null;
    MaterialProperty MaskTexVOffsetC = null;
    MaterialProperty MaskTexUClamp = null;
    MaterialProperty MaskTexVClamp = null;
    MaterialProperty MaskTexRotator = null;
    MaterialProperty MaskTexDetail = null;
    MaterialProperty MaskTexUMirror = null;
    MaterialProperty MaskTexVMirror = null;
    MaterialProperty MaskTexUVClip = null;

    MaterialProperty FDistortTex = null;
    MaterialProperty DistortTex = null;
    MaterialProperty DistortTexAR = null;
    MaterialProperty DistortTexUSpeed = null;
    MaterialProperty DistortTexVSpeed = null;
    MaterialProperty DistortFactor = null;
    MaterialProperty DistortMainTex = null;
    MaterialProperty DistortMaskTex = null;
    MaterialProperty DistortDissolveTex = null;
    MaterialProperty CustomDistortFactor = null;
    MaterialProperty DistortFactorC = null;
    MaterialProperty DistortUIntensity = null;
    MaterialProperty DistortVIntensity = null;
    MaterialProperty DistortRemap = null;
    MaterialProperty DistortTexRotator = null;
    MaterialProperty DistortTexUMirror = null;
    MaterialProperty DistortTexVMirror = null;
    MaterialProperty DistortTexDetail = null;

    MaterialProperty FDissolveTex = null;
    MaterialProperty DissolveTex = null;
    MaterialProperty DissolveTexAR = null;
    MaterialProperty DissolveTexUSpeed = null;
    MaterialProperty DissolveTexVSpeed = null;
    MaterialProperty DissolveFactor = null;
    MaterialProperty DissolveColor = null;
    MaterialProperty CustomDissolve = null;
    MaterialProperty DissolveSoft = null;
    MaterialProperty DissolveWide = null;
    MaterialProperty DissolvePlusTex = null;
    MaterialProperty DissolvePlusTexAR = null;
    MaterialProperty DissolvePlusTexUSpeed = null;
    MaterialProperty DissolvePlusTexVSpeed = null;
    MaterialProperty DissolvePlusIntensity = null;
    MaterialProperty FDissolvePlusTex = null;
    MaterialProperty DissolveFactorC = null;
    MaterialProperty CustomDissolveTexUOffset = null;
    MaterialProperty CustomDissolveTexVOffset = null;
    MaterialProperty DissolveTexUOffsetC = null;
    MaterialProperty DissolveTexVOffsetC = null;
    MaterialProperty CustomDissolvePlusTexUOffset = null;
    MaterialProperty CustomDissolvePlusTexVOffset = null;
    MaterialProperty DissolvePlusTexUOffsetC = null;
    MaterialProperty DissolvePlusTexVOffsetC = null;
    MaterialProperty DissolveTexRotator = null;
    MaterialProperty DissolveTexDetail = null;
    MaterialProperty DissolveTexUMirror = null;
    MaterialProperty DissolveTexVMirror = null;
    MaterialProperty DissolveTexUVClip = null;
    MaterialProperty DissolveTexUClamp = null;
    MaterialProperty DissolveTexVClamp = null;
    MaterialProperty DissolvePlusTexRotator = null;
    MaterialProperty DissolvePlusTexDetail = null;
    MaterialProperty DissolvePlusTexUMirror = null;
    MaterialProperty DissolvePlusTexVMirror = null;
    MaterialProperty DissolvePlusTexUVClip = null;
    MaterialProperty DissolvePlusTexUClamp = null;
    MaterialProperty DissolvePlusTexVClamp = null;


    MaterialProperty FFnl = null;
    MaterialProperty FnlColor = null;
    MaterialProperty FnlScale = null;
    MaterialProperty FnlPower = null;
    MaterialProperty ReFnl = null;

    MaterialProperty VTOTex = null;
    MaterialProperty VTOTexAR = null;
    MaterialProperty VTOTexUSpeed = null;
    MaterialProperty VTOTexVSpeed = null;
    MaterialProperty VTOScale = null;
    MaterialProperty IfVTO = null;
    MaterialProperty CustomVTO = null;
    MaterialProperty VTOScaleC = null;
    MaterialProperty VTOTexRotator = null;
    MaterialProperty VTOTexDetail = null;
    MaterialProperty VTOTexUMirror = null;
    MaterialProperty VTOTexVMirror = null;
    MaterialProperty VTOTexUVClip = null;
    MaterialProperty VTOTexUClamp = null;
    MaterialProperty VTOTexVClamp = null;


    MaterialProperty IfRefaction = null;
    MaterialProperty RefactionTex = null;
    MaterialProperty RefactionTexAR = null;
    MaterialProperty RefactionTexUSpeed = null;
    MaterialProperty RefactionTexVSpeed = null;
    MaterialProperty RefactionFactor = null;
    MaterialProperty RefactionRemap = null;
    MaterialProperty RefactionTexRotator = null;
    MaterialProperty RefactionTexUMirror = null;
    MaterialProperty RefactionTexVMirror = null;
    MaterialProperty RefactionTexDetail = null;
    MaterialProperty CustomRefactionFactor = null;
    MaterialProperty RefactionFactorC = null;
    MaterialProperty IfRefactionMask = null;
    MaterialProperty RefactionMaskTex = null;
    MaterialProperty RefactionMaskTexAR = null;
    MaterialProperty RefactionMaskTexUSpeed = null;
    MaterialProperty RefactionMaskTexVSpeed = null;
    MaterialProperty RefactionMaskTexRotator = null;
    MaterialProperty RefactionMaskTexUMirror = null;
    MaterialProperty RefactionMaskTexVMirror = null;
    MaterialProperty RefactionMaskTexDetail = null;
    MaterialProperty RefactionMaskTexUClamp = null;
    MaterialProperty RefactionMaskTexVClamp = null;
    MaterialProperty RefactionMaskTexUVClip = null;

    MaterialProperty MainAlpha = null;
   MaterialProperty AlphaClip = null;
 //   MaterialProperty AlphaClipC = null;
 //   MaterialProperty CustomAlphaClip = null;
     MaterialProperty SB = null;
     MaterialProperty SBCompare = null;
    MaterialProperty FDepth = null;
    MaterialProperty DepthFade = null;
    MaterialProperty MainRGBA = null;

    public void FindProperties(MaterialProperty[] props)
    {
        BlendMode = FindProperty("_BlendMode", props);
        CullMode = FindProperty("_CullMode", props);
        ZTest = FindProperty("_ZTest", props);


        MainTex = FindProperty("_MainTex", props);
        MainColor = FindProperty("_MainColor", props);
        MainTexAR = FindProperty("_MainTexAR", props);
        MainTexUSpeed = FindProperty("_MainTexUSpeed", props);
        MainTexVSpeed = FindProperty("_MainTexVSpeed", props);
        CustomMainTexUOffset = FindProperty("_CustomMainTexUOffset", props);
        CustomMainTexVOffset = FindProperty("_CustomMainTexVOffset", props);
        MainTexUOffsetC = FindProperty("_MainTexUOffsetC", props);
        MainTexVOffsetC = FindProperty("_MainTexVOffsetC", props);
        MainTexUClamp = FindProperty("_MainTexUClamp", props);
        MainTexVClamp = FindProperty("_MainTexVClamp", props);
        MainTexRefine = FindProperty("_MainTexRefine", props);
        MainTexDesaturate = FindProperty("_MainTexDesaturate", props);
        MainTexRotator = FindProperty("_MainTexRotator", props);
        MainTexDetail = FindProperty("_MainTexDetail", props);
        MainTexUMirror = FindProperty("_MainTexUMirror", props);
        MainTexVMirror = FindProperty("_MainTexVMirror", props);
        MainTexUVClip = FindProperty("_MainTexUVClip", props);
        MainTexCAFator = FindProperty("_MainTexCAFator", props);

        FMaskTex = FindProperty("_FMaskTex", props);
        MaskTex = FindProperty("_MaskTex", props);
        MaskTexAR = FindProperty("_MaskTexAR", props);
        MaskTexUSpeed = FindProperty("_MaskTexUSpeed", props);
        MaskTexVSpeed = FindProperty("_MaskTexVSpeed", props);
        CustomMaskTexUOffset = FindProperty("_CustomMaskTexUOffset", props);
        CustomMaskTexVOffset = FindProperty("_CustomMaskTexVOffset", props);
        MaskTexUOffsetC = FindProperty("_MaskTexUOffsetC", props);
        MaskTexVOffsetC = FindProperty("_MaskTexVOffsetC", props);
        MaskTexUClamp = FindProperty("_MaskTexUClamp", props);
        MaskTexVClamp = FindProperty("_MaskTexVClamp", props);
        MaskTexRotator = FindProperty("_MaskTexRotator", props);
        MaskTexDetail = FindProperty("_MaskTexDetail", props);
        MaskTexUMirror = FindProperty("_MaskTexUMirror", props);
        MaskTexVMirror = FindProperty("_MaskTexVMirror", props);
        MaskTexUVClip = FindProperty("_MaskTexUVClip", props);

        FDistortTex = FindProperty("_FDistortTex", props);
        DistortTex = FindProperty("_DistortTex", props);
        DistortTexAR = FindProperty("_DistortTexAR", props);
        DistortTexUSpeed = FindProperty("_DistortTexUSpeed", props);
        DistortTexVSpeed = FindProperty("_DistortTexVSpeed", props);
        DistortFactor = FindProperty("_DistortFactor", props);
        DistortMainTex = FindProperty("_DistortMainTex", props);
        DistortMaskTex = FindProperty("_DistortMaskTex", props);
        DistortDissolveTex = FindProperty("_DistortDissolveTex", props);
        CustomDistortFactor = FindProperty("_CustomDistortFactor", props);
        DistortFactorC = FindProperty("_DistortFactorC", props);
        DistortUIntensity = FindProperty("_DistortUIntensity", props);
        DistortVIntensity = FindProperty("_DistortVIntensity", props);
        DistortRemap = FindProperty("_DistortRemap", props);
        DistortTexDetail = FindProperty("_DistortTexDetail", props);
        DistortTexRotator = FindProperty("_DistortTexRotator", props);
        DistortTexUMirror = FindProperty("_DistortTexUMirror", props);
        DistortTexVMirror = FindProperty("_DistortTexVMirror", props);

        FDissolveTex = FindProperty("_FDissolveTex", props);
        DissolveTex = FindProperty("_DissolveTex", props);
        DissolveTexAR = FindProperty("_DissolveTexAR", props);
        DissolveTexUSpeed = FindProperty("_DissolveTexUSpeed", props);
        DissolveTexVSpeed = FindProperty("_DissolveTexVSpeed", props);
        DissolveFactor = FindProperty("_DissolveFactor", props);
        DissolveColor = FindProperty("_DissolveColor", props);
        CustomDissolve = FindProperty("_CustomDissolve", props);
        DissolveSoft = FindProperty("_DissolveSoft", props);
        DissolveWide = FindProperty("_DissolveWide", props);
        DissolvePlusTex= FindProperty("_DissolvePlusTex", props);
        DissolvePlusTexAR= FindProperty("_DissolvePlusTexAR", props);
        DissolvePlusTexUSpeed= FindProperty("_DissolvePlusTexUSpeed", props);
        DissolvePlusTexVSpeed= FindProperty("_DissolvePlusTexVSpeed", props);
        DissolvePlusIntensity= FindProperty("_DissolvePlusIntensity", props);
        FDissolvePlusTex= FindProperty("_FDissolvePlusTex", props);
        DissolveFactorC= FindProperty("_DissolveFactorC", props);
        CustomDissolveTexUOffset = FindProperty("_CustomDissolveTexUOffset", props);
        CustomDissolveTexVOffset = FindProperty("_CustomDissolveTexVOffset", props);
        DissolveTexUOffsetC = FindProperty("_DissolveTexUOffsetC", props);
        DissolveTexVOffsetC = FindProperty("_DissolveTexVOffsetC", props);
        CustomDissolvePlusTexUOffset = FindProperty("_CustomDissolvePlusTexUOffset", props);
        CustomDissolvePlusTexVOffset = FindProperty("_CustomDissolvePlusTexVOffset", props);
        DissolvePlusTexUOffsetC = FindProperty("_DissolvePlusTexUOffsetC", props);
        DissolvePlusTexVOffsetC = FindProperty("_DissolvePlusTexVOffsetC", props);
        DissolveTexUClamp = FindProperty("_DissolveTexUClamp", props);
        DissolveTexVClamp = FindProperty("_DissolveTexVClamp", props);
        DissolveTexRotator = FindProperty("_DissolveTexRotator", props);
        DissolveTexDetail = FindProperty("_DissolveTexDetail", props);
        DissolveTexUMirror = FindProperty("_DissolveTexUMirror", props);
        DissolveTexVMirror = FindProperty("_DissolveTexVMirror", props);
        DissolveTexUVClip = FindProperty("_DissolveTexUVClip", props);
        DissolvePlusTexUClamp = FindProperty("_DissolvePlusTexUClamp", props);
        DissolvePlusTexVClamp = FindProperty("_DissolvePlusTexVClamp", props);
        DissolvePlusTexRotator = FindProperty("_DissolvePlusTexRotator", props);
        DissolvePlusTexDetail = FindProperty("_DissolvePlusTexDetail", props);
        DissolvePlusTexUMirror = FindProperty("_DissolvePlusTexUMirror", props);
        DissolvePlusTexVMirror = FindProperty("_DissolvePlusTexVMirror", props);
        DissolvePlusTexUVClip = FindProperty("_DissolvePlusTexUVClip", props);


        FFnl = FindProperty("_FFnl", props);
        FnlColor = FindProperty("_FnlColor", props);
        FnlScale = FindProperty("_FnlScale", props);
        FnlPower = FindProperty("_FnlPower", props);
        ReFnl = FindProperty("_ReFnl", props);

        VTOTex = FindProperty("_VTOTex", props);
        VTOTexAR = FindProperty("_VTOTexAR", props);
        VTOTexUSpeed = FindProperty("_VTOTexUSpeed", props);
        VTOTexVSpeed = FindProperty("_VTOTexVSpeed", props);
        VTOScale = FindProperty("_VTOScale", props);
        CustomVTO = FindProperty("_CustomVTO", props);
        IfVTO = FindProperty("_IfVTO", props);
        VTOScaleC= FindProperty("_VTOScaleC", props);
        VTOTexUClamp = FindProperty("_VTOTexUClamp", props);
        VTOTexVClamp = FindProperty("_VTOTexVClamp", props);
        VTOTexRotator = FindProperty("_VTOTexRotator", props);
        VTOTexDetail = FindProperty("_VTOTexDetail", props);
        VTOTexUMirror = FindProperty("_VTOTexUMirror", props);
        VTOTexVMirror = FindProperty("_VTOTexVMirror", props);
        VTOTexUVClip = FindProperty("_VTOTexUVClip", props);


        IfRefaction = FindProperty("_IfRefaction", props);
        RefactionTex = FindProperty("_RefactionTex", props);
        RefactionTexAR = FindProperty("_RefactionTexAR", props);
        RefactionTexUSpeed = FindProperty("_RefactionTexUSpeed", props);
        RefactionTexVSpeed = FindProperty("_RefactionTexVSpeed", props);
        RefactionFactor = FindProperty("_RefactionFactor", props);
        RefactionRemap = FindProperty("_RefactionRemap", props);
        RefactionTexDetail = FindProperty("_RefactionTexDetail", props);
        RefactionTexRotator = FindProperty("_RefactionTexRotator", props);
        RefactionTexUMirror = FindProperty("_RefactionTexUMirror", props);
        RefactionTexVMirror = FindProperty("_RefactionTexVMirror", props);
        CustomRefactionFactor = FindProperty("_CustomRefactionFactor", props);
        RefactionFactorC = FindProperty("_RefactionFactorC", props);
        IfRefactionMask = FindProperty("_IfRefactionMask", props);
        RefactionMaskTex = FindProperty("_RefactionMaskTex", props);
        RefactionMaskTexAR = FindProperty("_RefactionMaskTexAR", props);
        RefactionMaskTexUSpeed = FindProperty("_RefactionMaskTexUSpeed", props);
        RefactionMaskTexVSpeed = FindProperty("_RefactionMaskTexVSpeed", props);
        RefactionMaskTexDetail = FindProperty("_RefactionMaskTexDetail", props);
        RefactionMaskTexRotator = FindProperty("_RefactionMaskTexRotator", props);
        RefactionMaskTexUMirror = FindProperty("_RefactionMaskTexUMirror", props);
        RefactionMaskTexVMirror = FindProperty("_RefactionMaskTexVMirror", props);
        RefactionMaskTexUClamp = FindProperty("_RefactionMaskTexUClamp", props);
        RefactionMaskTexVClamp = FindProperty("_RefactionMaskTexVClamp", props);
        RefactionMaskTexUVClip = FindProperty("_RefactionMaskTexUVClip", props);




        MainAlpha = FindProperty("_MainAlpha", props);
        AlphaClip = FindProperty("_AlphaClip", props);
        FDepth = FindProperty("_FDepth", props);
        DepthFade = FindProperty("_DepthFade", props);
         SB = FindProperty("_SB", props);
         SBCompare = FindProperty("_SBCompare", props);
      //  CustomAlphaClip = FindProperty("_CustomAlphaClip", props);
     //   AlphaClipC = FindProperty("_AlphaClipC", props);
        MainRGBA = FindProperty("_MainRGBA", props);

    }


    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {




        FindProperties(props);

        m_MaterialEditor = materialEditor;

        Material material = materialEditor.target as Material;

        //
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        _Function_Foldout = Foldout(_Function_Foldout, "功能定制");

        if (_Function_Foldout)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(FMaskTex, "遮罩图");


            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(FDistortTex, "UV扭曲图");
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(FDissolveTex, "溶解图");
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(FFnl, "菲涅尔");
            GUILayout.Space(5);
            m_MaterialEditor.ShaderProperty(IfVTO, "顶点动画图");
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(FDepth, "软粒子");
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(IfRefaction, "折射图");
            GUILayout.Space(5);

        
         //   GUILayout.Space(5);

            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();

        //
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        _Base_Foldout = Foldout(_Base_Foldout, "基础设置");

        if (_Base_Foldout)
        {
            EditorGUI.indentLevel++;

            GUILayout.Space(5);
            m_MaterialEditor.ShaderProperty(BlendMode, "叠加模式");
            if (material.GetFloat("_BlendMode") == 0)
            {
                material.SetFloat("_Scr", 5);
                material.SetFloat("_Dst", 10);
            }
            else
            {
                material.SetFloat("_Scr", 1);
                material.SetFloat("_Dst", 1);
            }
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(CullMode, "剔除模式");
            GUILayout.Space(5);

            m_MaterialEditor.ShaderProperty(ZTest, "深度测试");


            GUILayout.Space(5);
           m_MaterialEditor.ShaderProperty(SBCompare, "模板功能");

              if(material.GetFloat("_SBCompare") > 0)
              {
                 GUILayout.Space(5);
                m_MaterialEditor.ShaderProperty(SB, "模板系数");
                }
                else if(material.GetFloat("_SBCompare") ==0)
                {
                   material.SetFloat("_SB",0) ; 
                }
            GUILayout.Space(10);

            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();

        //
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        _Main_Foldout = Foldout(_Main_Foldout, "主贴图");

        if (_Main_Foldout)
        {
            EditorGUI.indentLevel++;

     

     
            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("主帖图"), MainTex, MainColor);

            GUILayout.Space(5);

            if (MainTex.textureValue != null ) { 
                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            m_MaterialEditor.TextureScaleOffsetProperty(MainTex);
            EditorGUILayout.EndVertical();
 
            GUILayout.Space(5);


         EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(MainTexDetail, "细节设置显示");

              
              if(material.GetFloat("_MainTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MainTexAR, "透明使用R通道");

            GUILayout.Space(5);

   
            
           EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(MainTexUClamp, "UVClamp");
           m_MaterialEditor.ShaderProperty(MainTexVClamp, "");
             EditorGUILayout.EndHorizontal();

              GUILayout.Space(5);


          if(material.GetFloat("_MainTexUClamp") == 1||material.GetFloat("_MainTexVClamp") == 1)
          {
           m_MaterialEditor.ShaderProperty(MainTexUVClip, "UVClamp冗余裁切");
            GUILayout.Space(5);
          }
          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(MainTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(MainTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(MainTexRotator, "旋转");

            GUILayout.Space(5);
             m_MaterialEditor.ShaderProperty(MainTexDesaturate, "固有色去饱和度");
          GUILayout.Space(5);
          m_MaterialEditor.ShaderProperty(MainTexCAFator, "色散");
             
            GUILayout.Space(5);
            m_MaterialEditor.ShaderProperty(MainTexRefine, "校色");
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();

              EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomMainTexUOffset, "自定义U偏移");
         
             if(material.GetFloat("_CustomMainTexUOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MainTexUOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomMainTexVOffset, "自定义V偏移");
         
             if(material.GetFloat("_CustomMainTexVOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MainTexVOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
           //  GUILayout.Space(5);

              
       

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            m_MaterialEditor.ShaderProperty(MainTexUSpeed, "U流动");
            m_MaterialEditor.ShaderProperty(MainTexVSpeed, "V流动");
            EditorGUILayout.EndVertical();
            GUILayout.Space(5);
           
            }



            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();


        //
        


     
      


        if (material.GetFloat("_FMaskTex") == 1) 
        {

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _Mask_Foldout = Foldout(_Mask_Foldout, "遮罩图");

        if (_Mask_Foldout)
        {
            EditorGUI.indentLevel++;
        
            m_MaterialEditor.TexturePropertySingleLine(new GUIContent("遮罩图"), MaskTex);

            GUILayout.Space(5);

            if (MaskTex.textureValue != null)
            {
                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.TextureScaleOffsetProperty(MaskTex);
                EditorGUILayout.EndVertical();
                GUILayout.Space(5);


         EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(MaskTexDetail, "细节设置显示");

              
              if(material.GetFloat("_MaskTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MaskTexAR, "使用R通道");

            GUILayout.Space(5);

   
            
           EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(MaskTexUClamp, "UVClamp");
           m_MaterialEditor.ShaderProperty(MaskTexVClamp, "");
             EditorGUILayout.EndHorizontal();

              GUILayout.Space(5);
 

      if(material.GetFloat("_MaskTexUClamp") == 1||material.GetFloat("_MaskTexVClamp") == 1)
          {
           m_MaterialEditor.ShaderProperty(MaskTexUVClip, "UVClamp冗余裁切");
            GUILayout.Space(5);
          }


          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(MaskTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(MaskTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(MaskTexRotator, "旋转");

            GUILayout.Space(5);
           
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();


              EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomMaskTexUOffset, "自定义U偏移");
         
             if(material.GetFloat("_CustomMaskTexUOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MaskTexUOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomMaskTexVOffset, "自定义V偏移");
         
             if(material.GetFloat("_CustomMaskTexVOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(MaskTexVOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
           //  GUILayout.Space(5);


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                m_MaterialEditor.ShaderProperty(MaskTexUSpeed, "U流动");
                m_MaterialEditor.ShaderProperty(MaskTexVSpeed, "V流动");
                EditorGUILayout.EndVertical();
                GUILayout.Space(5);
            }



            EditorGUI.indentLevel--;
        }
            EditorGUILayout.EndVertical();

        }
    


        //
        


   
       
       
  


        if (material.GetFloat("_FDistortTex") == 1)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Distort_Foldout = Foldout(_Distort_Foldout, "UV扭曲图");

            if (_Distort_Foldout)
            {
                EditorGUI.indentLevel++;

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("UV扭曲图"), DistortTex);

                GUILayout.Space(5);

                if (DistortTex.textureValue != null)
                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.TextureScaleOffsetProperty(DistortTex);
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);


         EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(DistortTexDetail, "细节设置显示");

              
              if(material.GetFloat("_DistortTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DistortTexAR, "使用R通道");

            GUILayout.Space(5);
  m_MaterialEditor.ShaderProperty(DistortRemap, "双方向扭动");
                    GUILayout.Space(5);
                   EditorGUILayout.BeginHorizontal();
                   m_MaterialEditor.ShaderProperty(DistortUIntensity, "UV朝向");
                   m_MaterialEditor.ShaderProperty(DistortVIntensity, "");
                   EditorGUILayout.EndHorizontal();

                  GUILayout.Space(5);
   
            
          
          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(DistortTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(DistortTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(DistortTexRotator, "旋转");

            GUILayout.Space(5);
           
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();



              EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomDistortFactor, "自定义强度");
         
             if(material.GetFloat("_CustomDistortFactor") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DistortFactorC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             GUILayout.Space(5);


if(material.GetFloat("_CustomDistortFactor") == 0){

                    m_MaterialEditor.ShaderProperty(DistortFactor, "强度");
                    GUILayout.Space(5);


}



                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(DistortTexUSpeed, "U流动");
                    m_MaterialEditor.ShaderProperty(DistortTexVSpeed, "V流动");
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);

                    m_MaterialEditor.ShaderProperty(DistortMainTex, "扭曲主贴图");
                    GUILayout.Space(5);
                    if (material.GetFloat("_FMaskTex") == 1) {
                        m_MaterialEditor.ShaderProperty(DistortMaskTex, "扭曲遮罩图");
                    GUILayout.Space(5);
                    }

                    if (material.GetFloat("_FDissolveTex") == 1) {
                        m_MaterialEditor.ShaderProperty(DistortDissolveTex, "扭曲溶解图");
                    GUILayout.Space(5);
                    }
                }



                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }


        //









        if (material.GetFloat("_FDissolveTex") == 1)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Dissolve_Foldout = Foldout(_Dissolve_Foldout, "溶解图");

            if (_Dissolve_Foldout)
            {
                EditorGUI.indentLevel++;

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("溶解图"), DissolveTex,DissolveColor);

                GUILayout.Space(5);

                if (DissolveTex.textureValue != null)
                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.TextureScaleOffsetProperty(DissolveTex);
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);

        

 EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(DissolveTexDetail, "细节设置显示");

              
              if(material.GetFloat("_DissolveTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DissolveTexAR, "使用R通道");

            GUILayout.Space(5);

   
            
           EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(DissolveTexUClamp, "UVClamp");
           m_MaterialEditor.ShaderProperty(DissolveTexVClamp, "");
             EditorGUILayout.EndHorizontal();

              GUILayout.Space(5);


             if(material.GetFloat("_DissolveTexUClamp") == 1||material.GetFloat("_DissolveTexVClamp") == 1)
          {
           m_MaterialEditor.ShaderProperty(DissolveTexUVClip, "UVClamp冗余裁切");
            GUILayout.Space(5);
          }

          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(DissolveTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(DissolveTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(DissolveTexRotator, "旋转");

            GUILayout.Space(5);
            
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();





              EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomDissolveTexUOffset, "自定义U偏移");
         
             if(material.GetFloat("_CustomDissolveTexUOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DissolveTexUOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomDissolveTexVOffset, "自定义V偏移");
         
             if(material.GetFloat("_CustomDissolveTexVOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DissolveTexVOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
            


                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(CustomDissolve, "自定义溶解程度");
                    if(material.GetFloat("_CustomDissolve") == 1)
                    {
                      GUILayout.Space(5);
                     m_MaterialEditor.ShaderProperty(DissolveFactorC, "通道选择");
                     }
                     EditorGUILayout.EndVertical();



                    GUILayout.Space(5);
                    if (material.GetFloat("_CustomDissolve") == 0) {
                        m_MaterialEditor.ShaderProperty(DissolveFactor, "溶解程度");
                    GUILayout.Space(5);
                    }
                    m_MaterialEditor.ShaderProperty(DissolveSoft, "软硬程度");
                    GUILayout.Space(5);
                    m_MaterialEditor.ShaderProperty(DissolveWide, "溶解宽度");
                    GUILayout.Space(5);
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(DissolveTexUSpeed, "U流动");
                    m_MaterialEditor.ShaderProperty(DissolveTexVSpeed, "V流动");
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);

                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(FDissolvePlusTex, "开启附加溶解图");

                   
                  if(material.GetFloat("_FDissolvePlusTex") == 1)
                  {
                           GUILayout.Space(5);
                   m_MaterialEditor.TexturePropertySingleLine(new GUIContent("附加溶解图"), DissolvePlusTex);

                       GUILayout.Space(5);

                      if (DissolvePlusTex.textureValue != null) 
                      {

                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.TextureScaleOffsetProperty(DissolvePlusTex);
                        EditorGUILayout.EndVertical();
                        GUILayout.Space(5);

           

                     EditorGUILayout.BeginVertical(EditorStyles.helpBox);

                       m_MaterialEditor.ShaderProperty(DissolvePlusTexDetail, "细节设置显示");

              
                    if(material.GetFloat("_DissolvePlusTexDetail") == 1)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        GUILayout.Space(5);
                        m_MaterialEditor.ShaderProperty(DissolvePlusTexAR, "使用R通道");

                          GUILayout.Space(5);

   
            
                          EditorGUILayout.BeginHorizontal();
                          m_MaterialEditor.ShaderProperty(DissolvePlusTexUClamp, "UVClamp");
                           m_MaterialEditor.ShaderProperty(DissolvePlusTexVClamp, "");
                           EditorGUILayout.EndHorizontal();

                         GUILayout.Space(5);


                             if(material.GetFloat("_DissolvePlusTexUClamp") == 1||material.GetFloat("_DissolvePlusTexVClamp") == 1)
                               {
                                   m_MaterialEditor.ShaderProperty(DissolvePlusTexUVClip, "UVClamp冗余裁切");
                                  GUILayout.Space(5);
                                }

            

                           EditorGUILayout.BeginHorizontal();
                           m_MaterialEditor.ShaderProperty(DissolvePlusTexUMirror, "镜像");
                           m_MaterialEditor.ShaderProperty(DissolvePlusTexVMirror, "");
                           EditorGUILayout.EndHorizontal();
                           GUILayout.Space(5);

           
                            m_MaterialEditor.ShaderProperty(DissolvePlusTexRotator, "旋转");

                           GUILayout.Space(5);
            
                               EditorGUILayout.EndVertical();
                    }
                             EditorGUILayout.EndVertical();

   





            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.ShaderProperty(CustomDissolvePlusTexUOffset, "自定义U偏移");
         
             if(material.GetFloat("_CustomDissolvePlusTexUOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DissolvePlusTexUOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             


                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomDissolvePlusTexVOffset, "自定义V偏移");
         
             if(material.GetFloat("_CustomDissolvePlusTexVOffset") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(DissolvePlusTexVOffsetC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
            
                    GUILayout.Space(5);

                        m_MaterialEditor.ShaderProperty(DissolvePlusIntensity, "附加图强度");
                        GUILayout.Space(5);

                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.ShaderProperty(DissolvePlusTexUSpeed, "U流动");
                        m_MaterialEditor.ShaderProperty(DissolvePlusTexVSpeed, "V流动");
                        EditorGUILayout.EndVertical();
                        GUILayout.Space(5);

                      }

                  }

                     EditorGUILayout.EndVertical();



                }



                EditorGUI.indentLevel--;
            }

            EditorGUILayout.EndVertical();
        }

        //







        if (material.GetFloat("_FFnl") == 1)
        {

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _FNL_Foldout = Foldout(_FNL_Foldout, "菲涅尔");

            if (_FNL_Foldout)
            {
                EditorGUI.indentLevel++;

                m_MaterialEditor.ShaderProperty(ReFnl, "反向");
                GUILayout.Space(5);
                m_MaterialEditor.ShaderProperty(FnlScale, "强度");
                GUILayout.Space(5);
                m_MaterialEditor.ShaderProperty(FnlPower, "宽度");
                GUILayout.Space(5);
                if (material.GetFloat("_ReFnl") == 0) {
                    m_MaterialEditor.ShaderProperty(FnlColor, "颜色");
                    GUILayout.Space(5);
                }


                    EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();

        }


        //

        if (material.GetFloat("_IfVTO") == 1)
        {

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            _VTO_Foldout = Foldout(_VTO_Foldout, "顶点动画图");

            if (_VTO_Foldout)
            {
                EditorGUI.indentLevel++;

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("贴图"), VTOTex);

                GUILayout.Space(5);
                if (VTOTex.textureValue != null)
                {

                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.TextureScaleOffsetProperty(VTOTex);
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);

                  
                 //   m_MaterialEditor.ShaderProperty(CustomVTO, "自定义数据控制强度");
                //    GUILayout.Space(5);

EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(VTOTexDetail, "细节设置显示");

              
              if(material.GetFloat("_VTOTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(VTOTexAR, "使用R通道");

            GUILayout.Space(5);

   
            
           EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(VTOTexUClamp, "UVClamp");
           m_MaterialEditor.ShaderProperty(VTOTexVClamp, "");
             EditorGUILayout.EndHorizontal();

              GUILayout.Space(5);


 if(material.GetFloat("_VTOTexUClamp") == 1||material.GetFloat("_VTOTexVClamp") == 1)
          {
           m_MaterialEditor.ShaderProperty(VTOTexUVClip, "UVClamp冗余裁切");
            GUILayout.Space(5);
          }



          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(VTOTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(VTOTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(VTOTexRotator, "旋转");

            GUILayout.Space(5);
            
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();




             EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomVTO, "自定义强度");
         
             if(material.GetFloat("_CustomVTO") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(VTOScaleC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             GUILayout.Space(5);

                    if (material.GetFloat("_CustomVTO") == 0)
                    {
                        m_MaterialEditor.ShaderProperty(VTOScale, "强度");
                        GUILayout.Space(5);
                    }
          
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(VTOTexUSpeed, "U流动");
                    m_MaterialEditor.ShaderProperty(VTOTexVSpeed, "V流动");
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);


                }


                    EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();

        }
        //


        if (material.GetFloat("_IfRefaction") == 1)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            _Refaction_Foldout = Foldout(_Refaction_Foldout, "折射图");

            if (_Refaction_Foldout)
            {
                EditorGUI.indentLevel++;

                m_MaterialEditor.TexturePropertySingleLine(new GUIContent("折射图"), RefactionTex);

                GUILayout.Space(5);

                if (RefactionTex.textureValue != null)
                {
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.TextureScaleOffsetProperty(RefactionTex);
                    EditorGUILayout.EndVertical();
                    GUILayout.Space(5);


         EditorGUILayout.BeginVertical(EditorStyles.helpBox);

         m_MaterialEditor.ShaderProperty(RefactionTexDetail, "细节设置显示");

              
              if(material.GetFloat("_RefactionTexDetail") == 1)
                {
                 EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(RefactionTexAR, "使用R通道");

            GUILayout.Space(5);
    
  m_MaterialEditor.ShaderProperty(RefactionRemap, "双方向扭动");
            
         GUILayout.Space(5); 
          EditorGUILayout.BeginHorizontal();
           m_MaterialEditor.ShaderProperty(RefactionTexUMirror, "镜像");
           m_MaterialEditor.ShaderProperty(RefactionTexVMirror, "");
             EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);

           
            m_MaterialEditor.ShaderProperty(RefactionTexRotator, "旋转");

            GUILayout.Space(5);
           
            EditorGUILayout.EndVertical();
                    }
             EditorGUILayout.EndVertical();



              EditorGUILayout.BeginVertical(EditorStyles.helpBox);
             m_MaterialEditor.ShaderProperty(CustomRefactionFactor, "自定义强度");
         
             if(material.GetFloat("_CustomRefactionFactor") == 1)
                 {
                 GUILayout.Space(5);
                 m_MaterialEditor.ShaderProperty(RefactionFactorC, "通道选择");

       
                  }
                  EditorGUILayout.EndVertical();
             GUILayout.Space(5);


               if(material.GetFloat("_CustomRefactionFactor") == 0)
                    {

                    m_MaterialEditor.ShaderProperty(RefactionFactor, "强度");
                    GUILayout.Space(5);


                      }



                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                    m_MaterialEditor.ShaderProperty(RefactionTexUSpeed, "U流动");
                    m_MaterialEditor.ShaderProperty(RefactionTexVSpeed, "V流动");
                    EditorGUILayout.EndVertical();
                    

                }



                EditorGUI.indentLevel--;

//
               
                    EditorGUILayout.BeginVertical(EditorStyles.helpBox);


                    m_MaterialEditor.ShaderProperty(IfRefactionMask, "开启折射遮罩图");


                  if(material.GetFloat("_IfRefactionMask") == 1)
                  {
                           GUILayout.Space(5);
                   m_MaterialEditor.TexturePropertySingleLine(new GUIContent("折射遮罩图"), RefactionMaskTex);

                       GUILayout.Space(5);

                      if (RefactionMaskTex.textureValue != null) 
                      {

                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.TextureScaleOffsetProperty(RefactionMaskTex);
                        EditorGUILayout.EndVertical();
                        GUILayout.Space(5);

           

                     EditorGUILayout.BeginVertical(EditorStyles.helpBox);

                       m_MaterialEditor.ShaderProperty(RefactionMaskTexDetail, "细节设置显示");

              
                    if(material.GetFloat("_RefactionMaskTexDetail") == 1)
                    {
                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        GUILayout.Space(5);
                        m_MaterialEditor.ShaderProperty(RefactionMaskTexAR, "使用R通道");

                          GUILayout.Space(5);

   
            
                          EditorGUILayout.BeginHorizontal();
                          m_MaterialEditor.ShaderProperty(RefactionMaskTexUClamp, "UVClamp");
                           m_MaterialEditor.ShaderProperty(RefactionMaskTexVClamp, "");
                           EditorGUILayout.EndHorizontal();

                         GUILayout.Space(5);


                             if(material.GetFloat("_RefactionMaskTexUClamp") == 1||material.GetFloat("_RefactionMaskTexVClamp") == 1)
                               {
                                   m_MaterialEditor.ShaderProperty(RefactionMaskTexUVClip, "UVClamp冗余裁切");
                                  GUILayout.Space(5);
                                }

            

                           EditorGUILayout.BeginHorizontal();
                           m_MaterialEditor.ShaderProperty(RefactionMaskTexUMirror, "镜像");
                           m_MaterialEditor.ShaderProperty(RefactionMaskTexVMirror, "");
                           EditorGUILayout.EndHorizontal();
                           GUILayout.Space(5);

           
                            m_MaterialEditor.ShaderProperty(RefactionMaskTexRotator, "旋转");

                           GUILayout.Space(5);
            
                               EditorGUILayout.EndVertical();
                    }
                             EditorGUILayout.EndVertical();

   


                        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                        m_MaterialEditor.ShaderProperty(RefactionMaskTexUSpeed, "U流动");
                        m_MaterialEditor.ShaderProperty(RefactionMaskTexVSpeed, "V流动");
                        EditorGUILayout.EndVertical();
                        GUILayout.Space(5);

                      }

                  }










                    EditorGUILayout.EndVertical();
//
            }

          if (RefactionTex.textureValue == null)
           {
            material.SetFloat("_IfRefactionMask",0) ;
           } 
            EditorGUILayout.EndVertical();
        }






        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        _Common_Foldout = Foldout(_Common_Foldout, "综合设置");

        if (_Common_Foldout)
        {
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(MainAlpha, "总透明度");
            GUILayout.Space(5);

 

    //         EditorGUILayout.BeginVertical(EditorStyles.helpBox);
     //        m_MaterialEditor.ShaderProperty(CustomAlphaClip, "自定义裁切");
         
      //       if(material.GetFloat("_CustomAlphaClip") == 1)
     //            {
     //            GUILayout.Space(5);
     //            m_MaterialEditor.ShaderProperty(AlphaClipC, "通道选择");

       
     //             }
    //              EditorGUILayout.EndVertical();
   //         GUILayout.Space(5);

// if(material.GetFloat("_CustomAlphaClip") == 0)
 //           {
              m_MaterialEditor.ShaderProperty(AlphaClip, "透明裁切");
            
            GUILayout.Space(5);
   //         }

            if (material.GetFloat("_FDepth") == 1)
            {
                m_MaterialEditor.ShaderProperty(DepthFade, "软化程度");
                GUILayout.Space(5);

            }

m_MaterialEditor.ShaderProperty(MainRGBA, "渲染通道");
            GUILayout.Space(5);




            
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);



            GUI_Common(material);




            EditorGUILayout.EndVertical();

            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();

      

        //
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        _Tips_Foldout = Foldout(_Tips_Foldout, "提示");

        if (_Tips_Foldout)
        {
            EditorGUI.indentLevel++;

            style.fontSize = 12;
            style.normal.textColor = new Color(0.5f, 0.5f, 0.5f);
            style.wordWrap = true;
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            GUILayout.Label(" 1.使用自定义数据请先添加custom1.xyzw,再添加custom2.xyzw", style);

            GUILayout.Space(10);
            EditorGUILayout.EndVertical();

            GUILayout.Label(" 本材质由油腻联盟坏熊猫制作", style);
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.EndVertical();
    }


    void GUI_Common(Material material)
    {
       
        EditorGUI.BeginChangeCheck();
        {
            MaterialProperty[] props = { };
            base.OnGUI(m_MaterialEditor, props);
        }

    }
}
#endif