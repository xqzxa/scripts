local ImGuiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xqzxa/ImGuiLib/main/source.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local IsSpectating = false
local TargetPlayer = nil
local TargetName = ""

local function GetTarget(name)
    if name == "" then return nil end
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(name)) or 
           string.find(string.lower(player.DisplayName), string.lower(name)) then
            return player
        end
    end
    return nil
end

local Window = ImGuiLib:CreateWindow({
    Title = "Spectator Tool",
    Size = Vector2.new(300, 150)
})

local SpecHeader = Window:CreateHeader({ Name = "Spectate Options" })

SpecHeader:CreateTextBox({
    Name = "Target Name",
    Placeholder = "Enter name...",
    Callback = function(val)
        TargetName = val
        if IsSpectating then
            TargetPlayer = GetTarget(TargetName)
        end
    end
})

SpecHeader:CreateToggle({
    Name = "Enable Spectating",
    Default = false,
    Callback = function(state)
        IsSpectating = state
        if IsSpectating then
            TargetPlayer = GetTarget(TargetName)
            if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = TargetPlayer.Character.Humanoid
            end
        else
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") or nil
        end
    end
})

RunService.RenderStepped:Connect(function()
    if IsSpectating then
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") then
            if Camera.CameraSubject ~= TargetPlayer.Character.Humanoid then
                Camera.CameraSubject = TargetPlayer.Character.Humanoid
            end
        end
    end
end)
