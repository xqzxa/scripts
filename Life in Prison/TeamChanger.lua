local ImGuiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xqzxa/ImGuiLib/main/source.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local BackgroundSavedCFrame = nil
local IsSwitching = false

local Window = ImGuiLib:CreateWindow({
    Title = "Team Switcher Tool",
    Size = Vector2.new(300, 150)
})

local function FireTeamChange(teamName)
    local targetTeam = Teams:FindFirstChild(teamName)
    local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RemoteEvent")
    if targetTeam and remote then
        remote:FireServer(1, targetTeam)
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if not IsSwitching then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    BackgroundSavedCFrame = Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
end)

local function RestoreSavedPosition()
    if not BackgroundSavedCFrame then 
        IsSwitching = false 
        return 
    end
    
    local endTime = tick() + 0.4
    
    while tick() < endTime do
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = BackgroundSavedCFrame
            end
        end
        task.wait(0.02)
    end
    
    IsSwitching = false
end

local TeamSection = Window:CreateHeader({ Name = "Team Management" })

TeamSection:CreateButton({
    Name = "Fast Switch: Prisoners",
    Callback = function()
        IsSwitching = true
        FireTeamChange("Neutral")
        task.wait(0.05) 
        FireTeamChange("Prisoners")
        task.spawn(RestoreSavedPosition)
    end
})

local actualGuardTeam = Teams:FindFirstChild("Guards") or Teams:FindFirstChild("Police")
if actualGuardTeam then
    TeamSection:CreateButton({
        Name = "Fast Switch: " .. actualGuardTeam.Name,
        Callback = function()
            IsSwitching = true
            FireTeamChange("Neutral")
            task.wait(0.05)
            FireTeamChange(actualGuardTeam.Name)
            task.spawn(RestoreSavedPosition)
        end
    })
end
