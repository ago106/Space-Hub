local VirtualUser = game:GetService("VirtualUser")
local NotificationService = getgenv().Notify

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("[Space Hub]: Roblox Tried to kick you but we didn't let them kick you :D")
    if getgenv().DebugMode == true then
      NotificationService.Notify(Duration, Tittle, Content, "Info")
    end
end)

NotificationService:Info("SPACE HUB", "Anti Afk - Enabled")
print("[Space Hub]: Anti-AFK Enabled")
