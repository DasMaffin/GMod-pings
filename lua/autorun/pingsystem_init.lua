PING = PING or {}
CreateConVar("pingsystem_time", 5, FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_REPLICATED, "Sets time for pings before they expire. (SERVER SETTING)", 5, 60)
CreateConVar("pingsystem_maxpings", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "0 = unlimited. Maximum number of active pings a player can have before they are prevented from placing more. (SERVER SETTING)", 0, 1024)

if SERVER then
    AddCSLuaFile("autorun/cl/cl_init.lua")
    AddCSLuaFile("cl/cl_displayping.lua")
    AddCSLuaFile("pingmenu.lua")

    include("autorun/sv/sv_init.lua")
elseif CLIENT then
    include("autorun/cl/cl_init.lua")
end
