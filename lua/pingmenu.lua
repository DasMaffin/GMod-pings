if SERVER then
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

    net.Receive("PingSystem_UpdateConVar", function(len, ply)
        if not ULib or not ULib.ucl.query(ply, "Can Change Ping Settings") then return end

        local convar = net.ReadString()
        local value = net.ReadInt(32)

        -- Only allow changing known admin ConVars
        if convar == "pingsystem_time" or convar == "pingsystem_maxpings" then
            RunConsoleCommand(convar, tostring(value))
        end
    end)
end


if CLIENT then
    -- These are needed on the client for the sliders in the spawn menu, but they don't actually control anything on the client. The server ConVars are what control the behavior.
    -- It would jitter out if we were using the actual replicated server convars.
    -- TODO Don't be lazy, add an observer. It currently does not update the UI if the server/someone else changes the values.
    CreateClientConVar("pingsystem_maxpings_client", 5, true, false, "0 = unlimited. Maximum number of active pings a player can have before they are prevented from placing more. (SERVER SETTING)", 0, 1024)
    CreateClientConVar("pingsystem_time_client", 5, true, false, "Sets time for pings before they expire. (SERVER SETTING)", 5, 60)

    local User = User or LocalPlayer()
    hook.Add( "InitPostEntity", "Pings_Pingmenu_InitLocalPlayer", function()
        User = LocalPlayer()
    end )

    local function PingMarker(ply, pingtype)
        local maxPings = GetConVar("pingsystem_maxpings"):GetInt()
        if maxPings ~= 0 and ply.ActivePings >= maxPings then
            chat.AddText(Color(230, 30, 30), "You have too many active pings! Please wait for some to expire before placing new ones.")
            return
        end

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

    
    local function createPingMenuEntry(pingKey,pingMaterial, frame, offsetX, offsetY)
        local vguiElement = vgui.Create("DImageButton", frame)

        vguiElement:SetMaterial(pingMaterial)
        vguiElement:SetSize(50, 50)
        vguiElement:SetPos(offsetX, offsetY)
        vguiElement.DoClick = function()
            PingMarker(User, pingKey)
            User:EmitSound("weapons/ar2/ar2_empty.wav", 70, 100, PING.PingVolume/100)
            frame:Remove()
        end
    end

    function CreatePingMenu()
        local frame = vgui.Create("DPanel")
        frame:SetSize(300, 300)
        frame:Center()
        frame:MakePopup()
        frame:SetAlpha(150)
        frame:SetKeyboardInputEnabled(false)
        frame:SetBackgroundColor(Color(50,50,50))

        local offsetX, offsetY, yCounter = 15, 15, 0
        for _, key in ipairs(PING.pingOrder) do
            local val = PING.pingPrefabs[key]
            createPingMenuEntry(key, val.material, frame, offsetX, offsetY)

            local offsetIncrease = 110
            if yCounter == 1 then
                offsetX = offsetX + offsetIncrease * 2
            else
                offsetX = offsetX + offsetIncrease
            end
            if offsetX > 240 then
                offsetX = 15
                offsetY = offsetY + offsetIncrease
                yCounter = yCounter + 1
            end
        end
        return frame
    end

    function OpenPingMenu(ply)
        if not IsValid(PingMenu) then
            PingMenu = CreatePingMenu()
            User:EmitSound("common/wpn_select.wav", 70, 100, PING.PingVolume/100)
        end
    end

    function ClosePingMenu(ply)
        if IsValid(PingMenu) then
            PingMenu:Remove()            
            User:EmitSound("weapons/ar2/ar2_empty.wav", 70, 100, PING.PingVolume/100)
        end
    end

    concommand.Add("+pingmenu", function(ply, command, arguments)
        OpenPingMenu(ply)
    end)

    concommand.Add("-pingmenu", function(ply, command, arguments)
        ClosePingMenu(ply)
    end)

    --QuickPings
    
    local quickPingPrefix = "quickping_"
    for pingType, _ in pairs(PING.pingPrefabs) do
        concommand.Add(quickPingPrefix .. pingType, function(ply, command, arguments)
            PingMarker(ply, pingType)
        end)
    end

    --Spawn Menu settings
    hook.Add("PopulateToolMenu", "AddPingSystemOptions", function()
        spawnmenu.AddToolMenuOption("Options", "Aaron's Ping System", "PingSystemOptions", "Settings", "", "", function(panel)
            panel:AddControl("Slider", {
                Label = "Ping Display Time:",
                Command = "pingsystem_time",
                Min = 5,
                Max = 60,
            })

            panel:AddControl("Slider", {
                Label = "Ping Sound Volume:",
                Command = "pingsystem_volume",
                Min = 0,
                Max = 100,
            })
        end)
    end)

    hook.Add("TTTSettingsTabs", "PingSystem_AddSettingsTab", function(dtabs)
        local settings_panel = vgui.Create("DPanel", dtabs)
        settings_panel:StretchToParent(0, 0, 0, 0)
        settings_panel:SetPaintBackground(false)

        dtabs:AddSheet(
            "Ping System",
            settings_panel,
            "icon16/sound.png"
        )

        local settings_form = vgui.Create("DForm", settings_panel)
        settings_form:Dock(TOP)
        settings_form:DockMargin(10, 10, 10, 5)
        settings_form:SetSpacing(10)
        settings_form:SetName("General Settings")

        settings_form:NumSlider(
            "Ping System Sound Volume",
            "pingsystem_volume",
            0,
            100,
            0
        )
        if ULib and not ULib.ucl.query(LocalPlayer(), "Can Change Ping Settings") then return end
        
        local admin_form = vgui.Create("DForm", settings_panel)
        admin_form:Dock(TOP)
        admin_form:DockMargin(10, 5, 10, 10)
        admin_form:SetSpacing(10)
        admin_form:SetName("Admin Settings")

        local timeSlider = admin_form:NumSlider(
            "Ping Display Time",
            "pingsystem_time_client",
            5,
            60,
            0
        )
        timeSlider.OnValueChanged = function(self, value)
            local intValue = math.Round(value)

            net.Start("PingSystem_UpdateConVar")
            net.WriteString("pingsystem_time")
            net.WriteInt(intValue, 32)
            net.SendToServer()
        end

        local pingAmountSlider = admin_form:NumSlider(
            "Max Pings Per Player",
            "pingsystem_maxpings_client",
            0,
            1024,
            0
        )
        pingAmountSlider.OnValueChanged = function(self, value)
            local intValue = math.Round(value)
            net.Start("PingSystem_UpdateConVar")
            net.WriteString("pingsystem_maxpings")
            net.WriteInt(intValue, 32)
            net.SendToServer()
        end
    end)
end
