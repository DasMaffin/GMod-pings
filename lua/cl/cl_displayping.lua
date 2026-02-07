local PingData = {}
local PingSound = Sound("npc/metropolice/vo/off2.wav")
local EnemySound = Sound("npc/combine_gunship/gunship_ping_search.wav")
local ArrowPing = Material("materials/ping/arrow.png")    

local CanSeePings = CreateClientConVar("pingsystem_allcansee", 0, true, false, "Can all players see pings? (SERVER SETTING)", 0, 1)

local function CalculateDistanceToPing( units, speed )
    local feetMultiplier = 0.0625 --1/16 = 0.0625
    return units * feetMultiplier
end

local function DrawIcon(color, material, x, y, rotation)
    surface.SetDrawColor(color)
    surface.SetMaterial(material)
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

            if (PingScreen.x < 0 or PingScreen.x > ScrW() or PingScreen.y < 0 or PingScreen.y > ScrH()) then
                DrawIcon(PING.pingPrefabs[PingType].specialColor or plycolor, PING.pingPrefabs[PingType].material, PingX, PingY)
                DrawIcon(white, ArrowPing, PingArrowX, PingArrowY, PingArrowRotation - 90)
                if PingY < 800 then
                    draw.SimpleTextOutlined(pingdist, "TargetID", PingX, PingY + 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))
                else
                    draw.SimpleTextOutlined(pingdist, "TargetID", PingX, PingY - 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))
                end
            else
                DrawIcon(PING.pingPrefabs[PingType].specialColor or plycolor, PING.pingPrefabs[PingType].material, PingScreen.x, PingScreen.y)
                draw.SimpleTextOutlined(pingdist, "TargetID", PingScreen.x, PingScreen.y + 25, plycolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0,0,0, 255))    
            end

            if not validping.PingSoundPlayed then
                chat.AddText(Color(plycolor.r, plycolor.g, plycolor.b, 255), Owner, Color(255,255,255), PING.pingPrefabs[PingType].message or " marked a location.")
                print(PING.PingVolume)
                ply:EmitSound(PingSound, 70, 100, PING.PingVolume/100)
                validping.PingSoundPlayed = true
            end
        end
    end
end

net.Receive("UpdatePingData", function()
    PingData = net.ReadTable()
end)

hook.Add("HUDPaint", "DisplayTeamPings", DisplayPings)