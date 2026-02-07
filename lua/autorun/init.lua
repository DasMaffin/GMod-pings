PING = PING or {}

if SERVER then
    AddCSLuaFile("autorun/cl/cl_init.lua")
    AddCSLuaFile("cl/cl_displayping.lua")

    include("autorun/sv/sv_init.lua")
elseif CLIENT then
    include("autorun/cl/cl_init.lua")
end
