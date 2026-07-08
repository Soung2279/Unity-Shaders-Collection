using Game.Editor.VFXTools.ArtAssetBatchCheck.ParticleMaterial;
using Game.Editor.VFXTools.ArtAssetBatchCheck.SpineWeapon;
using UnityEditor;
using UnityEngine;

namespace Game.Editor.VFXTools.ArtAssetBatchCheck
{
    public class ArtAssetBatchCheckWindow : EditorWindow
    {
        private static readonly string[] TabNames = { "粒子/材质", "Spine角色武器" };

        private int _selectedTab;
        private ParticlePrefabCollectorWindow _particleWindow;
        private SpineWeaponPreviewWindow _spineWindow;

        [MenuItem("TATools/VFXTools/美术资源批量检查")]
        public static void Open()
        {
            Open(0);
        }

        public static void Open(int tab)
        {
            var window = GetWindow<ArtAssetBatchCheckWindow>("美术资源批量检查");
            window.minSize = new Vector2(900, 600);
            window._selectedTab = Mathf.Clamp(tab, 0, TabNames.Length - 1);
            window.EnsureChildWindows();
            window.Focus();
            window.Repaint();
        }

        private void OnEnable()
        {
            EnsureChildWindows();
        }

        private void OnDisable()
        {
            DestroyChildWindows();
        }

        private void OnGUI()
        {
            EnsureChildWindows();
            using (new EditorGUILayout.VerticalScope())
            {
                EditorGUILayout.Space(4f);
                var nextTab = GUILayout.Toolbar(_selectedTab, TabNames, GUILayout.Height(28));
                if (nextTab != _selectedTab)
                {
                    _selectedTab = nextTab;
                    GUI.FocusControl(null);
                }

                EditorGUILayout.Space(6f);
                var childHeight = Mathf.Max(200f, position.height - 44f);
                var childRect = new Rect(0f, 0f, position.width, childHeight);
                switch (_selectedTab)
                {
                    case 0:
                        _particleWindow.position = childRect;
                        _particleWindow.DrawToolGUI();
                        break;
                    case 1:
                        _spineWindow.position = childRect;
                        _spineWindow.DrawToolGUI();
                        break;
                }
            }
        }

        private void EnsureChildWindows()
        {
            if (_particleWindow == null)
            {
                _particleWindow = CreateInstance<ParticlePrefabCollectorWindow>();
                _particleWindow.hideFlags = HideFlags.HideAndDontSave;
            }

            if (_spineWindow == null)
            {
                _spineWindow = CreateInstance<SpineWeaponPreviewWindow>();
                _spineWindow.hideFlags = HideFlags.HideAndDontSave;
            }
        }

        private void DestroyChildWindows()
        {
            if (_particleWindow != null)
            {
                DestroyImmediate(_particleWindow);
                _particleWindow = null;
            }

            if (_spineWindow != null)
            {
                DestroyImmediate(_spineWindow);
                _spineWindow = null;
            }
        }
    }
}
