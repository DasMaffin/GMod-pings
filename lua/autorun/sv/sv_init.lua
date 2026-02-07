CreateConVar("pingsystem_time", 5, FCVAR_NOTIFY + FCVAR_ARCHIVE, "Sets time for pings before they expire. (SERVER SETTING)", 5, 60)
CreateConVar("pingsystem_allcansee", 0, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Can all players see pings? (SERVER SETTING)", 0, 1)

util.AddNetworkString("SendPingPosition")
util.AddNetworkString("UpdatePingData")

include("sv/sv_displayping.lua")