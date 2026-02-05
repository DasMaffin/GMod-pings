if SERVER then
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
end




if CLIENT then

    local PingData = {}
    local PingSound = Sound("npc/metropolice/vo/off2.wav")
    local EnemySound = Sound("npc/combine_gunship/gunship_ping_search.wav")
    local ArrowPing = Material("materials/ping/arrow.png")    
    local pingPrefabs = {
        ["default"] = {material = Material("materials/ping/def.png"), message = " marked a location."},
        ["enemy"] = {material = Material("materials/ping/target.png"), message = " has spotted an enemy."},
        ["defend"] = {material = Material("materials/ping/defend.png"), message = " is defending this position."},
        ["look"] = {material = Material("materials/ping/look.png"), message = " wants to look here."},
        ["attack"] = {material = Material("materials/ping/attack.png"), message = " is attacking this position."},
        ["supply"] = {material = Material("materials/ping/supply.png"), message = " has found some supplies."},
        ["assist"] = {material = Material("materials/ping/assist.png"), message = " asks for assistance."},
        ["missing"] = {material = Material("materials/ping/missing.png"), message = " signals that enemies are missing."}
    }

    local CanSeePings = CreateClientConVar("pingsystem_allcansee", 0, true, false, "Can all players see pings? (SERVER SETTING)", 0, 1)

    local function CalculateDistanceToPing( units, speed )
        local unit = 6
        if ( unit == 1 ) then -- Kilometres/Kilometry
            if ( speed ) then return units * 1.905 / 100000 * 3600 end
            return units * 1.905 / 100000
        elseif ( unit == 2 ) then -- Meters/Metry
            return units * 1.905 / 100
        elseif ( unit == 3 ) then -- Centimetres/Centymetry
            return units * 1.905
        elseif ( unit == 4 ) then -- Miles/Mile
            if ( speed ) then return units * ( 1 / 16 ) / 5280 * 3600 end
            return units * ( 1 / 16 ) / 5280
        elseif ( unit == 5 ) then -- Inch/Cal
            return units * 0.75
        elseif ( unit == 6 ) then -- Foot/Stopa
            return units * ( 1 / 16 )
        end
    
        return units
    end

    local function DrawIcon(color, material, x, y, rotation)
        SurfaceColor(color)
        SurfaceMaterial(material)
        surface.DrawTexturedRectRotated(x, y, 35, 35, rotation or 0)
    end

    local function DisplayPings()
        local ply = LocalPlayer()
        local plycolor = team.GetColor(ply:Team())
        local plyteam = tostring(ply:Team())

        local HalfScreenX = ScrW() / 2
        local HalfScreenY = ScrH() / 2
        local PingArrowRadius = ScrH() * 0.46
        local PingRadius = math.max(ScrW(), ScrH())

        local SurfaceColor = surface.SetDrawColor
        local SurfaceMaterial = surface.SetMaterial
        local SurfaceDrawTexturedRectRotated = surface.DrawTexturedRectRotated
        local DrawSimpleText = draw.SimpleText


        for pingindex, ping in pairs(PingData) do
            local CanSeePings = GetConVar("pingsystem_allcansee"):GetBool()
            local validping = Entity(pingindex)
            if IsValid(validping) and validping:GetNWString("Team") == plyteam or CanSeePings then

                local PingPos = ping.position
                local pingdist = math.floor(CalculateDistanceToPing(ply:GetPos():Distance(PingPos)))
                local PingScreen = PingPos:ToScreen()
                local PingType = ping.pingtype
                local Owner = ping.whopinged
                local OnScreenPingPosition = math.atan2(PingScreen.y - HalfScreenY, PingScreen.x - HalfScreenX)
                local PingArrowRotation = math.NormalizeAngle(0 - math.deg(OnScreenPingPosition))
                local PingX = HalfScreenX + math.cos(OnScreenPingPosition) * PingRadius
                local PingY = HalfScreenY + math.sin(OnScreenPingPosition) * PingRadius

                local margin = 50
                local arrowMargin = 25

                if math.abs(math.cos(OnScreenPingPosition)) * PingRadius > math.abs(math.sin(OnScreenPingPosition)) * PingRadius then
                    PingX = math.Clamp(PingX, margin, ScrW() - margin)
                    PingY = HalfScreenY + math.sin(OnScreenPingPosition) * ((PingX - HalfScreenX) / math.cos(OnScreenPingPosition))
                else
                    PingY = math.Clamp(PingY, margin, ScrH() - margin)
                    PingX = HalfScreenX + math.cos(OnScreenPingPosition) * ((PingY - HalfScreenY) / math.sin(OnScreenPingPosition))
                end

                local ClampedX = math.Clamp(PingX, margin, ScrW() - margin)
                local ClampedY = math.Clamp(PingY, margin, ScrH() - 200)
                
                if PingX ~= ClampedX then
                    PingX = ClampedX
                    PingY = HalfScreenY + math.sin(OnScreenPingPosition) * ((PingX - HalfScreenX) / math.cos(OnScreenPingPosition))
                end
            
                if PingY ~= ClampedY then
                    PingY = ClampedY
                    PingX = HalfScreenX + math.cos(OnScreenPingPosition) * ((PingY - HalfScreenY) / math.sin(OnScreenPingPosition))
                end

                PingX = math.Clamp(PingX, margin, ScrW() - margin)
                PingY = math.Clamp(PingY, margin, ScrH() - margin)

                local PingArrowX = PingX + math.cos(OnScreenPingPosition) * arrowMargin
                local PingArrowY = PingY + math.sin(OnScreenPingPosition) * arrowMargin

                local white = Color(255, 255, 255, 255)
                local specialPingColors = {
                    ["enemy"] = white
                }
                if (PingScreen.x < 0 or PingScreen.x > ScrW() or PingScreen.y < 0 or PingScreen.y > ScrH()) then
                    DrawIcon(specialPingColors[PingType] or plycolor, pingPrefabs[PingType].material, PingX, PingY)
                    DrawIcon(white, ArrowPing, PingArrowX, PingArrowY, PingArrowRotation - 90)
                    if PingY < 800 then
                        draw.SimpleTextOutlined(pingdist, "TargetID", PingX, PingY + 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))
                    else
                        draw.SimpleTextOutlined(pingdist, "TargetID", PingX, PingY - 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))
                    end
                else
                    DrawIcon(specialPingColors[PingType] or plycolor, pingPrefabs[PingType].material, PingScreen.x, PingScreen.y)
                    draw.SimpleTextOutlined(pingdist, "TargetID", PingScreen.x, PingScreen.y + 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))    
                end

                if not validping.PingSoundPlayed then
                    chat.AddText(Color(plycolor.r, plycolor.g, plycolor.b, 255), Owner, Color(255,255,255), pingPrefabs[PingType].message or " marked a location.")
                    surface.PlaySound(PingSound)
                    validping.PingSoundPlayed = true
                end
            end
        end
    end
    
    net.Receive("UpdatePingData", function()
        PingData = net.ReadTable()
    end)

    hook.Add("HUDPaint", "DisplayTeamPings", DisplayPings)
end
