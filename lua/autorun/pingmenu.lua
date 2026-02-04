if SERVER then
    util.AddNetworkString("SendPingPosition")

    net.Receive("SendPingPosition", function(len, ply)
        local pingPosition = net.ReadVector()
        local PingType = net.ReadString()
        local TeamPing = net.ReadString()
        local HitNonWorld = net.ReadBool()

        if HitNonWorld then
            local entIndex = net.ReadUInt(16)
            local ent = Entity(entIndex)
            if not IsValid(ent) then return end
            local WhoPinged = net.ReadString()
            local Anim = net.ReadEntity()

            local pingMarker = ents.Create("ent_ping_marker")
            pingMarker:SetPos(pingPosition)
            pingMarker:SetParent(ent)
            pingMarker:SetCreator(ply)
            pingMarker:SetNWString("PingType", PingType)
            pingMarker:SetNWString("Team", TeamPing)
            pingMarker:SetNWString("Owner", WhoPinged)
            pingMarker:Spawn()

            net.Start("VManip_SimplePlay")
            net.WriteString("PingFinger")
            net.Send(Anim)
        else
            local WhoPinged = net.ReadString()
            local Anim = net.ReadEntity()
            local pingMarker = ents.Create("ent_ping_marker")
            pingMarker:SetPos(pingPosition)
            pingMarker:SetCreator(ply)
            pingMarker:SetNWString("PingType", PingType)
            pingMarker:SetNWString("Team", TeamPing)
            pingMarker:SetNWString("Owner", WhoPinged)
            pingMarker:Spawn()
            
            net.Start("VManip_SimplePlay")
            net.WriteString("PingFinger")
            net.Send(Anim)
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
    local pingDefMat = Material("materials/ping/def.png")
    local pingEnemyMat = Material("materials/ping/target.png")
    local pingDefendMat = Material("materials/ping/defend.png")
    local pingLookMat = Material("materials/ping/look.png")
    local pingAttackMat = Material("materials/ping/attack.png")
    local pingSupplyMat = Material("materials/ping/supply.png")
    local pingAssistMat = Material("materials/ping/assist.png")
    local pingMissingMat = Material("materials/ping/missing.png")

    function CreatePingMenu()
        local User = LocalPlayer()
        local frame = vgui.Create("DPanel")
        frame:SetSize(300, 300)
        frame:Center()
        frame:MakePopup()
        frame:SetAlpha(150)
        frame:SetKeyboardInputEnabled(false)
        frame:SetBackgroundColor(Color(50,50,50))

        local pingDef = vgui.Create("DImageButton", frame)
        pingDef:SetMaterial(pingDefMat)
        pingDef:SetSize(50, 50)
        pingDef:SetPos(frame:GetWide() / 2 - pingDef:GetWide() / 2, 10)
        pingDef.DoClick = function()
            PingMarker(User, "default")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingEnemy = vgui.Create("DImageButton", frame)
        pingEnemy:SetMaterial(pingEnemyMat)
        pingEnemy:SetSize(50, 50)
        pingEnemy:SetPos(frame:GetWide() / 2 - pingEnemy:GetWide() / 2, 230)
        pingEnemy.DoClick = function()
            PingMarker(User, "enemy")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingDefend = vgui.Create("DImageButton", frame)
        pingDefend:SetMaterial(pingDefendMat)
        pingDefend:SetSize(50, 50)
        pingDefend:SetPos(frame:GetWide() / 2 + 90, 125)
        pingDefend.DoClick = function()
            PingMarker(User, "defend")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingLook = vgui.Create("DImageButton", frame)
        pingLook:SetMaterial(pingLookMat)
        pingLook:SetSize(50, 50)
        pingLook:SetPos(frame:GetWide() / 2 - 140, 125)
        pingLook.DoClick = function()
            PingMarker(User, "look")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingAttack = vgui.Create("DImageButton", frame)
        pingAttack:SetMaterial(pingAttackMat)
        pingAttack:SetSize(50, 50)
        pingAttack:SetPos(frame:GetWide() / 2 + 90, 10)
        pingAttack.DoClick = function()
            PingMarker(User, "attack")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingSupply = vgui.Create("DImageButton", frame)
        pingSupply:SetMaterial(pingSupplyMat)
        pingSupply:SetSize(50, 50)
        pingSupply:SetPos(frame:GetWide() / 2 - 140, 10)
        pingSupply.DoClick = function()
            PingMarker(User, "supply")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingAssist = vgui.Create("DImageButton", frame)
        pingAssist:SetMaterial(pingAssistMat)
        pingAssist:SetSize(50, 50)
        pingAssist:SetPos(frame:GetWide() / 2 - 140, 230)
        pingAssist.DoClick = function()
            PingMarker(User, "assist")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
        end

        local pingMissing = vgui.Create("DImageButton", frame)
        pingMissing:SetMaterial(pingMissingMat)
        pingMissing:SetSize(50, 50)
        pingMissing:SetPos(frame:GetWide() / 2 + 90, 230)
        pingMissing.DoClick = function()
            PingMarker(User, "missing")
            surface.PlaySound("weapons/ar2/ar2_empty.wav")
            frame:Remove()
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
