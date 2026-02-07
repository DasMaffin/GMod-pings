if SERVER then
    util.AddNetworkString("SendPingPosition")

    local function createPingMarker(pingPosition, ply, PingType, TeamPing, WhoPinged, parent)
        local WhoPinged = net.ReadString()  
        local Anim = net.ReadEntity()

        local pingMarker = ents.Create("ent_ping_marker")
        pingMarker:SetPos(pingPosition)
        pingMarker:SetParent(parent)
        pingMarker:SetCreator(ply)
        pingMarker:SetNWString("PingType", PingType)
        pingMarker:SetNWString("Team", TeamPing)
        pingMarker:SetNWString("Owner", WhoPinged)
        pingMarker:Spawn()
        
        net.Start("VManip_SimplePlay")
        net.WriteString("PingFinger")
        net.Send(Anim)
    end

    net.Receive("SendPingPosition", function(len, ply)
        local pingPosition = net.ReadVector()
        local PingType = net.ReadString()
        local TeamPing = net.ReadString()
        local HitNonWorld = net.ReadBool()

        if HitNonWorld then
            local entIndex = net.ReadUInt(16)
            local ent = Entity(entIndex)
            if not IsValid(ent) then return end

            createPingMarker(pingPosition, ply, PingType, TeamPing, WhoPinged, ent)
        else
            createPingMarker(pingPosition, ply, PingType, TeamPing, WhoPinged)
        end
    end)
end


if CLIENT then

    local User = LocalPlayer()

    local function PingMarker(ply, pingtype)
        local User = ply
        local tr = util.TraceLine({
            start = User:EyePos(),
            endpos = User:EyePos() + User:GetAimVector() * 100000,
            filter = User
        })

        local PingType = tostring(pingtype)
        local TeamPing = User:Team()

        net.Start("SendPingPosition")
        net.WriteVector(tr.HitPos)
        net.WriteString(PingType)
        net.WriteString(TeamPing)
        net.WriteBool(tr.HitNonWorld)
        if tr.HitNonWorld then
            local ent = tr.Entity
            net.WriteUInt(ent:EntIndex(), 16)
        end
        net.WriteString(User:Nick())
        net.WriteEntity(User)
        net.SendToServer()
    end

    local PingMenu = nil

    
    local function rename(pingMaterial)        
        local vguiElement = vgui.Create("DImageButton", frame)

        vguiElement:SetMaterial(pingMaterial)
        vguiElement:SetSize(50, 50)
        vguiElement:SetPos(frame:GetWide() / 2 - vguiElement:GetWide() / 2, 10)
        vguiElement.DoClick = function()
            PingMarker(User, "default")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end
    end

    function CreatePingMenu()
        local User = LocalPlayer()
        local frame = vgui.Create("DPanel")
        frame:SetSize(300, 300)
        frame:Center()
        frame:MakePopup()
        frame:SetAlpha(150)
        frame:SetKeyboardInputEnabled(false)
        frame:SetBackgroundColor(Color(50,50,50))

        for key, val in pairs(PING.pingPrefabs) do
            rename(val.material)
        end
        return frame
    end

    function OpenPingMenu(ply)
        if not IsValid(PingMenu) then
            PingMenu = CreatePingMenu()
        end
    end

    function ClosePingMenu(ply)
        if IsValid(PingMenu) then
            PingMenu:Remove()
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
        end
    end

    concommand.Add("+pingmenu", function(ply, command, arguments)
        OpenPingMenu(ply)
        surface.PlaySound("common/wpn_select.wav")
    end)

    concommand.Add("-pingmenu", function(ply, command, arguments)
        ClosePingMenu(ply)
    end)

    net.Receive("OpenPingMenu", function(ply)
        OpenPingMenu(ply)
    end)

    net.Receive("ClosePingMenu", function(ply)
        ClosePingMenu(ply)
    end)

    --QuickPings
    concommand.Add("quickping_def", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "default")
    end)

    concommand.Add("quickping_enemy", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "enemy")
    end)

    concommand.Add("quickping_defend", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "defend")
    end)

    concommand.Add("quickping_look", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "look")
    end)

    concommand.Add("quickping_supply", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "Supply")
    end)

    concommand.Add("quickping_assist", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "assist")
    end)

    concommand.Add("quickping_missing", function(ply, command, arguments)
        PingMarker(LocalPlayer(), "missing")
    end)



    --Spawn Menu settings
    hook.Add("PopulateToolMenu", "AddPingSystemOptions", function()
        spawnmenu.AddToolMenuOption("Options", "Aaron's Ping System", "PingSystemOptions", "Settings", "", "", function(panel)

            panel:AddControl("Slider", {
                Label = "Ping Display Time:",
                Command = "pingsystem_time",
                Min = 5,
                Max = 60,
            })

        end)
    end)
    
    

end
