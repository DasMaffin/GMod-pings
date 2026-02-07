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

local function SendPingDataToClients()
    local PingData = CollectPings()
    
    net.Start("UpdatePingData")
    net.WriteTable(PingData)
    net.Broadcast()
end

hook.Add("Tick", "UpdatePingDataHook", function()
    SendPingDataToClients()
end)