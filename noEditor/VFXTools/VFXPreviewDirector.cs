using UnityEngine;

public class VFXPreviewDirector : MonoBehaviour
{
    [SerializeField] private VFXPreviewControllerBase[] previews;
    [SerializeField] private bool stopOthersWhenPlayOne = true;

    public void PlayAll()
    {
        EnsurePreviews();
        for (int i = 0; i < previews.Length; i++)
        {
            if (previews[i])
            {
                previews[i].PlayPreview();
            }
        }
    }

    public void StopAll()
    {
        EnsurePreviews();
        for (int i = 0; i < previews.Length; i++)
        {
            if (previews[i])
            {
                previews[i].StopPreview();
            }
        }
    }

    public void ResetAll()
    {
        EnsurePreviews();
        for (int i = 0; i < previews.Length; i++)
        {
            if (previews[i])
            {
                previews[i].ResetPreview();
            }
        }
    }

    public void PlaySingle(VFXPreviewControllerBase preview)
    {
        if (!preview)
        {
            return;
        }

        if (stopOthersWhenPlayOne)
        {
            StopAll();
        }

        preview.PlayPreview();
    }

    public void EnsurePreviews()
    {
        if (previews != null && previews.Length > 0)
        {
            return;
        }

        previews = GetComponentsInChildren<VFXPreviewControllerBase>(true);
    }
}
