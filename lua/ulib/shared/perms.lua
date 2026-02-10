hook.Add("PostGamemodeLoaded", "gmod_pinging_RegisterPerms", function()
  timer.Simple(2, function()
      if ULib and ULib.ucl then
        ULib.ucl.registerAccess(
            "Can Change Ping Settings",
            "admin",
            "Allows changing Ping System server settings",
            "Ping System"
        )
      end
  end)
end)