CreateConVar("pingsystem_volume", 0, FCVAR_ARCHIVE, "Sets volume of ping sounds. (CLIENT SETTING)", 0, 100)

PING.PingVolume = GetConVar("pingsystem_volume"):GetFloat()
cvars.AddChangeCallback("pingsystem_volume", function(_, old, new)
    PING.PingVolume = tonumber(new) or 75
end, "PingSystemVolumeWatcher")

include("cl/cl_displayping.lua")