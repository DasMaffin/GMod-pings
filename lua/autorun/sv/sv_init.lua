local PingTime = CreateConVar("pingsystem_time", 5, FCVAR_NOTIFY + FCVAR_ARCHIVE, "Sets time for pings before they expire. (SERVER SETTING)", 5, 60)
local AllCanSeePing = CreateConVar("pingsystem_allcansee", 0, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Can all players see pings? (SERVER SETTING)", 0, 1)
local function CollectPings()
    local PingData = {} 
    for _, ent in ipairs(ents.FindByClass("ent_ping_marker")) do
        local pingindex = ent:EntIndex()
        local data = {
            position = ent:GetPos(),
            pingteam = ent:GetNWString("Team"),
            pingtype = ent:GetNWString("PingType"),
            whopinged = ent:GetNWString("Owner")
        }
        PingData[pingindex] = data
    end

    return PingData
end

util.AddNetworkString("UpdatePingData")

local function SendPingDataToClients()
    local PingData = CollectPings()
    
    net.Start("UpdatePingData")
    net.WriteTable(PingData)
    net.Broadcast()
end

hook.Add("Tick", "UpdatePingDataHook", function()
    SendPingDataToClients()
end)