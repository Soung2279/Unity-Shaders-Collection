using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.Utilities
{
[CustomEditor(typeof(VFXPreviewControllerBase), true)]
public class VFXPreviewControllerEditor : UnityEditor.Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(8f);
        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("播放预览"))
            {
                foreach (Object targetObject in targets)
                {
                    if (targetObject is VFXPreviewControllerBase preview)
                    {
                        preview.PlayPreview();
                    }
                }
            }

            if (GUILayout.Button("重置"))
            {
                foreach (Object targetObject in targets)
                {
                    if (targetObject is VFXPreviewControllerBase preview)
                    {
                        preview.ResetPreview();
                    }
                }
            }

            if (GUILayout.Button("停止"))
            {
                foreach (Object targetObject in targets)
                {
                    if (targetObject is VFXPreviewControllerBase preview)
                    {
                        preview.StopPreview();
                    }
                }
            }
        }

        EditorGUILayout.HelpBox("选中预览控制器时，Scene 视图会显示移动路径、目标点、范围或冲刺方向。", MessageType.Info);
    }
}
}
