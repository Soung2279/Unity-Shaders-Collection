using UnityEngine;

[ExecuteAlways]
public abstract class VFXPreviewControllerBase : MonoBehaviour
{
    [SerializeField] private bool playOnEnable;
    [SerializeField] private bool loopPreview;
    [SerializeField, Min(0f)] private float loopDelay = 1f;

    private bool isPlaying;
    private bool initialized;
    private float loopTimer;

#if UNITY_EDITOR
    private double lastEditorTime;
#endif

    public bool IsPlaying => isPlaying;
    protected bool LoopPreview => loopPreview;

    protected virtual void OnEnable()
    {
        EnsureInitialized();
#if UNITY_EDITOR
        RegisterEditorUpdate();
        lastEditorTime = UnityEditor.EditorApplication.timeSinceStartup;
#endif
        if (playOnEnable && Application.isPlaying)
        {
            PlayPreview();
        }
    }

    protected virtual void OnDisable()
    {
#if UNITY_EDITOR
        UnregisterEditorUpdate();
#endif
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            return;
        }

        TickPreview(Time.deltaTime);
    }

    public void PlayPreview()
    {
        EnsureInitialized();
        loopTimer = 0f;
        isPlaying = true;
        ResetPreviewState();
        OnPreviewStarted();
#if UNITY_EDITOR
        RegisterEditorUpdate();
        lastEditorTime = UnityEditor.EditorApplication.timeSinceStartup;
#endif
    }

    public void StopPreview()
    {
        isPlaying = false;
        loopTimer = 0f;
        ResetPreviewState();
    }

    public void ResetPreview()
    {
        EnsureInitialized();
        loopTimer = 0f;
        ResetPreviewState();
    }

    protected void CompletePreview()
    {
        if (!loopPreview)
        {
            isPlaying = false;
            return;
        }

        loopTimer = loopDelay;
    }

    protected virtual void CaptureInitialState()
    {
    }

    protected virtual void OnPreviewStarted()
    {
    }

    protected abstract void ResetPreviewState();
    protected abstract void UpdatePreview(float deltaTime);

    protected virtual void OnValidate()
    {
        initialized = false;
    }

    private void EnsureInitialized()
    {
        if (initialized)
        {
            return;
        }

        initialized = true;
        CaptureInitialState();
    }

    private void TickPreview(float deltaTime)
    {
        if (!isPlaying)
        {
            return;
        }

        if (loopTimer > 0f)
        {
            loopTimer -= deltaTime;
            if (loopTimer > 0f)
            {
                return;
            }

            ResetPreviewState();
            OnPreviewStarted();
        }

        UpdatePreview(deltaTime);
    }

    protected static void SetActive(Transform target, bool active)
    {
        if (target)
        {
            target.gameObject.SetActive(active);
        }
    }

    protected static void RestartParticles(Transform root)
    {
        if (!root)
        {
            return;
        }

        var particles = root.GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particles.Length; i++)
        {
            particles[i].Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            particles[i].Play(true);
        }
    }

    protected static void StopParticles(Transform root)
    {
        if (!root)
        {
            return;
        }

        var particles = root.GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particles.Length; i++)
        {
            particles[i].Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }
    }

    protected static void PlayAnimation(Transform root, string animationName, bool loop)
    {
        if (!root || string.IsNullOrEmpty(animationName))
        {
            return;
        }

        var animator = root.GetComponentInChildren<Animator>(true);
        if (animator && animator.runtimeAnimatorController)
        {
            animator.Play(animationName, 0, 0f);
            animator.Update(0f);
            return;
        }

        var legacyAnimation = root.GetComponentInChildren<Animation>(true);
        if (legacyAnimation && legacyAnimation.GetClip(animationName))
        {
            legacyAnimation.Play(animationName);
            return;
        }

        var behaviours = root.GetComponentsInChildren<MonoBehaviour>(true);
        for (int i = 0; i < behaviours.Length; i++)
        {
            var behaviour = behaviours[i];
            if (!behaviour)
            {
                continue;
            }

            var typeName = behaviour.GetType().Name;
            if (typeName != "SkeletonAnimation" && typeName != "SkeletonGraphic")
            {
                continue;
            }

            var animationStateProperty = behaviour.GetType().GetProperty("AnimationState");
            var animationState = animationStateProperty?.GetValue(behaviour, null);
            if (animationState == null)
            {
                continue;
            }

            var setAnimation = animationState.GetType().GetMethod("SetAnimation", new[] { typeof(int), typeof(string), typeof(bool) });
            if (setAnimation == null)
            {
                continue;
            }

            try
            {
                setAnimation.Invoke(animationState, new object[] { 0, animationName, loop });
            }
            catch (System.Exception exception)
            {
                Debug.LogWarning($"[VFXPreview] Spine animation '{animationName}' not found or failed on {root.name}: {exception.GetBaseException().Message}");
            }
            return;
        }
    }

#if UNITY_EDITOR
    private void RegisterEditorUpdate()
    {
        UnityEditor.EditorApplication.update -= EditorUpdate;
        UnityEditor.EditorApplication.update += EditorUpdate;
    }

    private void UnregisterEditorUpdate()
    {
        UnityEditor.EditorApplication.update -= EditorUpdate;
    }

    private void EditorUpdate()
    {
        if (Application.isPlaying || !isPlaying)
        {
            return;
        }

        double now = UnityEditor.EditorApplication.timeSinceStartup;
        float deltaTime = Mathf.Min((float)(now - lastEditorTime), 0.05f);
        lastEditorTime = now;
        TickPreview(deltaTime);
        UnityEditor.SceneView.RepaintAll();
    }
#endif
}
