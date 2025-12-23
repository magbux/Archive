--// Load the Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/magbux/Archive/refs/heads/main/source.lua"))()

--// Create Window
local Window = Library:Window({
    Name = "Classic Hub"
})

--// Create Tabs
local Main = Window:Tab("Main")
local Visuals = Window:Tab("Visuals")
local Misc = Window:Tab("Misc")

--// Main Tab Content
Main:Label("Player Stats")

Main:Slider("WalkSpeed", 16, 250, 16, function(value)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

Main:Slider("JumpPower", 50, 500, 50, function(value)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

Main:Toggle("Infinite Jump", false, function(state)
    _G.InfJump = state
    if state then
        Window:Notification("System", "Infinite Jump Enabled", 2)
    end
end)

Main:Button("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

--// Visuals Tab Content
Visuals:Warning("ESP can cause lag on low-end devices.")

Visuals:Dropdown("ESP Mode", {"Box", "Tracers", "Chams", "Skeleton"}, function(selected)
    print("Selected Mode:", selected)
end)

Visuals:Colorpicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    print("New Color:", color)
end)

Visuals:Toggle("Fullbright", false, function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.Brightness = 1
        game.Lighting.ClockTime = 12
        game.Lighting.FogEnd = 10000
    end
end)

--// Misc Tab Content
Misc:Textbox("Teleport to Player", "Username...", function(text)
    local target = game.Players:FindFirstChild(text)
    if target and target.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Window:Notification("Teleport", "Teleported to " .. text, 3)
    else
        Window:Notification("Error", "Player not found", 3)
    end
end)

Misc:Keybind("Menu Toggle", Enum.KeyCode.RightControl, function()
    Window:Toggle()
end)

--// Infinite Jump Logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)
