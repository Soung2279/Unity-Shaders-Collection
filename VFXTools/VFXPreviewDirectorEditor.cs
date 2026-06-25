using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(VFXPreviewDirector))]
public class VFXPreviewDirectorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(8f);
        var director = (VFXPreviewDirector)target;
        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("播放全部"))
            {
                director.PlayAll();
            }

            if (GUILayout.Button("重置全部"))
            {
                director.ResetAll();
            }

            if (GUILayout.Button("停止全部"))
            {
                director.StopAll();
            }
        }

        if (GUILayout.Button("重新收集子级预览控制器"))
        {
            Undo.RecordObject(director, "Collect VFX Preview Controllers");
            director.EnsurePreviews();
            EditorUtility.SetDirty(director);
        }
    }
}
