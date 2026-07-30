using UnityEngine;

[DisallowMultipleComponent]
public sealed class ParticleGroupPlayer : MonoBehaviour
{
    public void Play()
    {
        var particleSystems = GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Play(false);
        }
    }

    public void Pause()
    {
        var particleSystems = GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Pause(false);
        }
    }

    public void Stop()
    {
        var particleSystems = GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Stop(false);
        }
    }

    public void StopAndClear()
    {
        var particleSystems = GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
        }
    }

    public void Restart()
    {
        var particleSystems = GetComponentsInChildren<ParticleSystem>(true);
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
            particleSystems[i].Play(false);
        }
    }
}
