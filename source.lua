local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/magbux/ZyphUiLib/refs/heads/main/Library.Lua"))()

local Window = Library:Window({
    Name = "Zyph Hub",
    KeySystem = true,
    Key = "1234",
    KeyNote = "Key is 1234"
})

local Main = Window:Tab("Main")
local Visuals = Window:Tab("Visuals")
local Misc = Window:Tab("Misc")

Main:Label("Character")

Main:Slider("WalkSpeed", 16, 300, 16, function(v)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

Main:Slider("JumpPower", 50, 500, 50, function(v)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)

Main:Toggle("Infinite Jump", false, function(v)
    _G.InfJump = v
    Window:Notification("Movement", "Infinite Jump " .. (v and "Enabled" or "Disabled"), 2)
end)

Main:Button("Force Reset", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

Visuals:Label("Render")

Visuals:Dropdown("ESP Mode", {"Box", "Tracers", "Skeleton", "Chams"}, function(v)
    print("Selected mode:", v)
end)

Visuals:Colorpicker("ESP Color", Color3.fromRGB(255, 0, 0), function(v)
    print("Color:", v)
end)

Visuals:Toggle("Show Teammates", false, function(v)
    print("Teammates:", v)
end)

Misc:Label("Settings")

Misc:Textbox("Teleport Player", "Username...", function(v)
    local target = game.Players:FindFirstChild(v)
    if target and target.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    else
        Window:Notification("Error", "Player not found", 3)
    end
end)

Misc:Keybind("Menu Toggle", Enum.KeyCode.RightControl, function()
    print("Menu toggled")
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)
