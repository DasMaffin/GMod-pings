CreateConVar("pingsystem_allcansee", 0, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Can all players see pings? (SERVER SETTING)", 0, 1)

util.AddNetworkString("SendPingPosition")
util.AddNetworkString("UpdatePingData")
util.AddNetworkString("PingSystem_UpdateConVar")

include("sv/sv_displayping.lua")
include("pingmenu.lua")
include("ulib/shared/perms.lua")