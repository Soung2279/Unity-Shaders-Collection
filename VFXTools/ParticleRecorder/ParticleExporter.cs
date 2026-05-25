using UnityEngine;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class ParticleExporter : MonoBehaviour
{
    //输出动画的默认文件夹名称
    public string folderName = "PNG_Animations";
    [HideInInspector]
    public int frameRate = 25;                  // 导出帧率，设置Time.captureFramerate会忽略真实时间，直接使用此帧率（捕捉帧率或者说限定帧率，电视帧率是30，电影是24每秒，用这个设定每秒钟的帧速）
    [HideInInspector]
    public int frameCount = 40;              // 运行时由 frameRate × duration 自动计算
    [HideInInspector]
    public float duration = 2f;              // 录制时长（秒），frameCount = frameRate × duration
    //public RectTransform sizeObj;
    [HideInInspector]
    public int screenWidth = 128;            // 运行时自动从主摄像机像素分辨率读取
    [HideInInspector]
    public int screenHeight = 128;
    private Vector3 cameraPosition = Vector3.zero;   //摄像头坐标 暂时不需要
    private Vector3 cameraRotation = Vector3.zero;

    private string realFolder = ""; // 文件夹名
    private float originaltimescaleTime; //跟踪原始时间尺度，这样我们就可以冻结帧之间的动画
    
    private int currentIndex = 0;
    private Camera exportCamera;    // 摄像机，使用RenderTexture
    private Texture2D[] texture2Ds;
    private bool over = false;
    //[HideInInspector]
    public bool isStart = false;    //是否开始录制
    public void Start()
    {
        Time.captureFramerate = frameRate;//  捕获帧速率
        //拼接文件夹
        realFolder = Path.Combine(folderName, name);
        //如果指定路径下不存在文件夹，就创建
        if (!Directory.Exists(realFolder))
        {
            Directory.CreateDirectory(realFolder);
        }
        originaltimescaleTime = Time.timeScale;//timeScale只会影响FixedUpdate的速度
        // 自动从主摄像机读取分辨率
        screenWidth  = (int)Camera.main.pixelWidth;
        screenHeight = (int)Camera.main.pixelHeight;
        // 根据时长和帧率计算总帧数
        frameCount = Mathf.CeilToInt(frameRate * duration);
        //设置摄像机的位置
        GameObject goCamera = Camera.main.gameObject;
        if (cameraPosition != Vector3.zero)
        {
            goCamera.transform.position = cameraPosition;
        }

        if (cameraRotation != Vector3.zero)
        {
            goCamera.transform.rotation = Quaternion.Euler(cameraRotation);
        }

        GameObject go = Instantiate(goCamera) as GameObject;
        exportCamera = go.GetComponent<Camera>();
        texture2Ds = new Texture2D[frameCount];
        //GUILayout.Button
    }


    void Update()
    {
        if (isStart)
        {
            //如果创建达到数量，停止
            if (!over && currentIndex >= frameCount)
            {
                for (int i = 0; i < frameCount; i++)
                {
                    string filename = String.Format("{0}/{1:D04}.png", realFolder, i);
                    //将图片转换成Png的二进制格式，保存在byte数组中（计算机是以二进制的方式存储数据）
                    byte[] pngShot = texture2Ds[i].EncodeToPNG();
                    //文件保存，创建一个新文件，在其中写入指定的字节数组（要写入的文件的路径，要写入文件的字节。）
                    File.WriteAllBytes(filename, pngShot);
                }
                over = true;
                Cleanup();
                //拿到所有裁剪
                //TailoringTexture();
                //获取/设置 最合适的尺寸大小

                Debug.Log("截取完成!");
                //UnityEditor.EditorApplication.isPlaying = false;
                return;  // 防止后续 StartCoroutine 导致数组越界
            }
            // 每帧截屏
            StartCoroutine(CaptureFrame());
        }
    }

    void Cleanup()
    {
        // 销毁整个相机 GameObject，避免 URP 的 UniversalAdditionalCameraData 依赖 Camera 组件导致报错
        if (exportCamera != null)
            Destroy(exportCamera.gameObject);
        Destroy(gameObject);
    }
    //截屏 输出
    IEnumerator CaptureFrame()
    {
        Time.timeScale = 0;

        //等待所有的摄像机和GUI被渲染完成。
        yield return new WaitForEndOfFrame();//截屏需要使用

        string filename = String.Format("{0}/{1:D04}.png", realFolder, ++currentIndex);
        //创建空纹理 GetTemporary和ReleaseTemporary 
        RenderTexture blackCamRenderTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);//new RenderTexture
        RenderTexture whiteCamRenderTexture = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);

        exportCamera.targetTexture = blackCamRenderTexture;
        exportCamera.backgroundColor = Color.black;
        exportCamera.Render();
        RenderTexture.active = blackCamRenderTexture;
        Texture2D texb = GetTex2D();

        exportCamera.targetTexture = whiteCamRenderTexture;
        exportCamera.backgroundColor = Color.white;
        exportCamera.Render();
        RenderTexture.active = whiteCamRenderTexture;
        Texture2D texw = GetTex2D();
        if (texw && texb)
        {
            Texture2D outputtex = new Texture2D(screenWidth, screenHeight, TextureFormat.ARGB32, false);
            //检查alpha，因为粒子使用加法着色器
            //从黑白摄影机渲染之间的差异创建Alpha
            //texw.GetPixel 获取像素颜色

            for (int y = 0; y < outputtex.height; ++y)
            { // each row 行
                for (int x = 0; x < outputtex.width; ++x)
                { // each column列
                    Color wb = texw.GetPixel(x, y);
                    Color bb = texb.GetPixel(x, y);
                    // 取三通道差值的最小值，避免单通道计算导致非红色粒子 alpha 错误
                    float diff = Mathf.Min(wb.r - bb.r, wb.g - bb.g, wb.b - bb.b);
                    float alpha = Mathf.Clamp01(1.0f - diff);
                    Color color;
                    if (alpha < 1e-6f)
                    {
                        color = Color.clear;
                    }
                    else
                    {
                        // 对黑背景颜色去预乘，还原真实粒子颜色
                        color = new Color(
                            Mathf.Clamp01(bb.r / alpha),
                            Mathf.Clamp01(bb.g / alpha),
                            Mathf.Clamp01(bb.b / alpha),
                            alpha
                        );
                    }
                    //设置某一像素的颜色
                    outputtex.SetPixel(x, y, color);
                }
            }
            texture2Ds[currentIndex - 1] = outputtex;
            RenderTexture.active = null;
            RenderTexture.ReleaseTemporary(blackCamRenderTexture);
            RenderTexture.ReleaseTemporary(whiteCamRenderTexture);
            Destroy(texb);
            Destroy(texw);
            Time.timeScale = originaltimescaleTime;
        }
    }

    //将纹理从屏幕上渲染出来，渲染全部或仅渲染一半的镜头
    private Texture2D GetTex2D()
    {
        Texture2D tex = new Texture2D(screenWidth, screenHeight, TextureFormat.ARGB32, false);
        //在帧渲染完毕之后调用（从屏幕左下角为原点开始绘制，绘制大小为width，height, 偏移量为0）
        int minWidth = (Screen.width - screenWidth) / 2;
        int minheight = (Screen.height - screenHeight) / 2;
        tex.ReadPixels(new Rect(minWidth, minheight, screenWidth, screenHeight), 0, 0);
        //图片应用（此时图片已经绘制完成）
        tex.Apply();
        return tex;
    }

    //裁剪 删除
    private void TailoringTexture()
    {
        DirectoryInfo folder = new DirectoryInfo(realFolder);
        var files = folder.GetFiles("*.png");//Get到之后 files数组从0开始
        int count = files.Length;
        for (int i = 0; i < count; i++)
        {
            string filePath = realFolder + "/" + files[i].Name;
            FileStream fs = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            int byteLength = (int)fs.Length;
            byte[] imgBytes = new byte[byteLength];
            fs.Read(imgBytes, 0, byteLength);
            fs.Close();
            fs.Dispose();
            Texture2D t2d = new Texture2D(256, 256);
            t2d.LoadImage(imgBytes);
            t2d.Apply();
            Texture2D newTex = ClipBlank(t2d);
            //删除旧的
            File.Delete(filePath);
            if (newTex != null)
            {
                string filename = String.Format("{0}/{1:D04}.png", realFolder, ++currentIndex);
                File.WriteAllBytes(filename, newTex.EncodeToPNG());
            }
        }
    }

    //切割
    private Texture2D ClipBlank(Texture2D orgin)
    {
        var left = 0;
        var top = 0;
        var right = orgin.width;
        var botton = orgin.height;
        // 左侧
        for (var i = 0; i < orgin.width; i++)
        {
            var find = false;
            for (var j = 0; j < orgin.height; j++)
            {
                var color = orgin.GetPixel(i, j);
                if (Math.Abs(color.a) > 1e-6)
                {
                    find = true;
                    break;
                }
            }
            if (find)
            {
                left = i;
                break;
            }
        }

        // 右侧
        for (var i = orgin.width - 1; i >= 0; i--)
        {
            var find = false;
            for (var j = 0; j < orgin.height; j++)
            {
                var color = orgin.GetPixel(i, j);
                if (Math.Abs(color.a) > 1e-6)
                {
                    find = true;
                    break;
                }
            }
            if (find)
            {
                right = i + 1;
                break;
            }
        }

        // 上侧
        for (var j = 0; j < orgin.height; j++)
        {
            var find = false;
            for (var i = 0; i < orgin.width; i++)
            {
                var color = orgin.GetPixel(i, j);
                if (Math.Abs(color.a) > 1e-6)
                {
                    find = true;
                    break;
                }
            }
            if (find)
            {
                top = j;
                break;
            }
        }

        // 下侧
        for (var j = orgin.height - 1; j >= 0; j--)
        {
            var find = false;
            for (var i = 0; i < orgin.width; i++)
            {
                var color = orgin.GetPixel(i, j);
                if (Math.Abs(color.a) > 1e-6)
                {
                    find = true;
                    break;
                }
            }
            if (find)
            {
                botton = j + 1;
                break;
            }
        }

        // 创建新纹理

        var width = right - left;
        var height = botton - top;
        if (width == orgin.width && height == orgin.height)
        {
            return null;
        }
        else
        {
            var result = new Texture2D(width, height, TextureFormat.ARGB32, false);
            result.alphaIsTransparency = true;

            // 复制有效颜色区块
            var colors = orgin.GetPixels(left, top, width, height);
            result.SetPixels(0, 0, width, height, colors);

            result.Apply();
            return result;
        }
    }
}