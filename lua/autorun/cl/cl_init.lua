CreateConVar("pingsystem_volume", 0, FCVAR_ARCHIVE, "Sets volume of ping sounds. (CLIENT SETTING)", 0, 100)

PING.PingVolume = GetConVar("pingsystem_volume"):GetFloat()
cvars.AddChangeCallback("pingsystem_volume", function(_, old, new)
    PING.PingVolume = tonumber(new) or 75
end, "PingSystemVolumeWatcher")


white = Color(255, 255, 255, 255)
PING.pingOrder = { -- order in which pings are displayed in the menu
    "supply",
    "default",
    "attack",
    "look",
    "defend",
    "assist",
    "enemy",
    "missing"
}
PING.pingPrefabs = {
    ["default"] = {material = Material("materials/ping/def.png"), message = " marked a location."},
    ["enemy"] = {material = Material("materials/ping/target.png"), message = " has spotted an enemy.", specialColor = white},
    ["defend"] = {material = Material("materials/ping/defend.png"), message = " is defending this position."},
    ["look"] = {material = Material("materials/ping/look.png"), message = " wants to look here."},
    ["attack"] = {material = Material("materials/ping/attack.png"), message = " is attacking this position."},
    ["supply"] = {material = Material("materials/ping/supply.png"), message = " has found some supplies."},
    ["assist"] = {material = Material("materials/ping/assist.png"), message = " asks for assistance."},
    ["missing"] = {material = Material("materials/ping/missing.png"), message = " signals that enemies are missing."}
}

include("cl/cl_displayping.lua")