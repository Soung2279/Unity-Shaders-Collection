using System;
using DG.Tweening;
using UnityEngine;

namespace Game.Battle
{
    public class FogMaskRenderer : MonoBehaviour
    {
        [SerializeField]
        Material DrawMat;

        [SerializeField]
        float step = 0.5f;

        float mapSize;
        float brushSize;
        float brushWorldSize;

        RenderTexture maskTex;
        RenderTexture tmpTex;
        Tween expandRevealTween;

        Camera cam;

        int _BrushSize = Shader.PropertyToID("_BrushSize");
        int _UVPosition = Shader.PropertyToID("_UVPosition");

        public float MapSize => mapSize;
        public float BrushWorldSize => brushWorldSize;

        public void Init(float mapSize, float brushSize)
        {
            if (maskTex != null)
            {
                Destroy(maskTex);
            }

            maskTex = new RenderTexture((int)mapSize, (int)mapSize, 0, RenderTextureFormat.ARGB32);
            maskTex.Create();
            ClearRenderTexture(maskTex);

            tmpTex = new RenderTexture((int)mapSize, (int)mapSize, 0, RenderTextureFormat.ARGB32);
            tmpTex.Create();

            this.mapSize = mapSize;
            this.brushWorldSize = brushSize;
            this.brushSize = brushSize / mapSize;

            cam = Camera.main;
        }

        public void PlayRevealExpand(Vector2 worldPos, float startBrushWorldSize, float endBrushWorldSize, float duration)
        {
            if (maskTex == null)
            {
                return;
            }

            expandRevealTween?.Kill();

            var safeStartBrushSize = Mathf.Max(0.1f, startBrushWorldSize);
            var safeEndBrushSize = Mathf.Max(safeStartBrushSize, endBrushWorldSize);
            SetBrushWorldSize(safeStartBrushSize);
            DrawPoint(worldPos, safeStartBrushSize);

            if (duration <= 0 || Mathf.Approximately(safeStartBrushSize, safeEndBrushSize))
            {
                SetBrushWorldSize(safeEndBrushSize);
                DrawPoint(worldPos, safeEndBrushSize);
                return;
            }

            var currentBrushSize = safeStartBrushSize;
            expandRevealTween = DOTween.To(() => currentBrushSize, value =>
                {
                    currentBrushSize = value;
                    SetBrushWorldSize(currentBrushSize);
                    DrawPoint(worldPos, currentBrushSize);
                }, safeEndBrushSize, duration)
                .SetEase(Ease.OutSine)
                .OnKill(() => expandRevealTween = null);
        }

        public RenderTexture GetMaskTex()
        {
            return maskTex;
        }

        public Rect GetScrrenUVRect()
        {
            Vector3 cameraPos = cam.transform.position - transform.position;
            float h = cam.orthographicSize * 2;
            float w = h * cam.aspect;
            float x  = cameraPos.x - w / 2;
            float y = cameraPos.y - h / 2;

            x = (x + mapSize * 0.5f) / mapSize;
            y = (y + mapSize * 0.5f) / mapSize;
            w = w / mapSize;
            h = h / mapSize;
            return new Rect(x, y, w, h);
        }

        public void DrawLine(Vector3 p0, Vector3 p1)
        {
            p0 = p0 - transform.position;
            p1 = p1 - transform.position;
            Vector2 uv0 = new Vector2(p0.x / mapSize + 0.5f, p0.y / mapSize + 0.5f);
            Vector2 uv1 = new Vector2(p1.x / mapSize + 0.5f, p1.y / mapSize + 0.5f);
            DrawLineUV(uv0, uv1);
        }

        void DrawLineUV(Vector2 uv0, Vector2 uv1)
        {
            var dir = (uv1 - uv0).normalized;
            float dist = Vector2.Distance(uv0, uv1);
            int n = Math.Max(1, (int)(dist / step)) ;
            for (int i = 0; i < n; ++i)
            {
                DrawOnRenderTexture(uv0 + dir * i);
            }
        }

        void ClearRenderTexture(RenderTexture rt)
        {
            RenderTexture.active = rt;
            GL.Clear(true, true, new Color(0, 0, 0, 0));
            RenderTexture.active = null;
        }

        void DrawOnRenderTexture(Vector2 uv)
        {
            DrawOnRenderTexture(uv, brushSize);
        }

        void DrawPoint(Vector2 worldPos, float worldBrushSize)
        {
            var localPos = worldPos - (Vector2)transform.position;
            var uv = new Vector2(localPos.x / mapSize + 0.5f, localPos.y / mapSize + 0.5f);
            DrawOnRenderTexture(uv, worldBrushSize / mapSize);
        }

        void DrawOnRenderTexture(Vector2 uv, float normalizedBrushSize)
        {
            DrawMat.SetFloat(_BrushSize, normalizedBrushSize);
            DrawMat.SetVector(_UVPosition, new Vector4(uv.x, uv.y, 0, 0));
            Graphics.Blit(maskTex, tmpTex);
            Graphics.Blit(tmpTex, maskTex, DrawMat);
        }

        void SetBrushWorldSize(float worldBrushSize)
        {
            brushWorldSize = Mathf.Max(0.1f, worldBrushSize);
            brushSize = brushWorldSize / mapSize;
        }

        void OnDestroy()
        {
            expandRevealTween?.Kill();
        }
    }
}
