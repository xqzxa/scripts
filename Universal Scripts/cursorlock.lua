local ImGuiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xqzxa/ImGuiLib/main/source.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false,
    Keybind = Enum.KeyCode.Q,
    TeamCheck = true,
    WallCheck = true,
    FOV = 100,
    Smoothness = 2,
    Tracers = true
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local TracerLine = Drawing.new("Line")
TracerLine.Color = Color3.fromRGB(255, 50, 50)
TracerLine.Thickness = 1.5
TracerLine.Transparency = 1
TracerLine.Visible = false

local function GetClosestPlayerToCursor()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("HumanoidRootPart")
            if torso then
                local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        if Settings.WallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                            
                            local rayDirection = (torso.Position - Camera.CFrame.Position).Unit * 1000
                            local result = workspace:Raycast(Camera.CFrame.Position, rayDirection, rayParams)
                            
                            if result and result.Instance:IsDescendantOf(player.Character) then
                                closestTarget = torso
                                shortestDistance = distance
                            end
                        else
                            closestTarget = torso
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Settings.FOV
    
    local target = nil
    if Settings.Enabled or Settings.Tracers then
        target = GetClosestPlayerToCursor()
    end

    if target then
        local targetScreenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
        
        if onScreen then
            if Settings.Enabled then
                local deltaX = targetScreenPos.X - mousePos.X
                local deltaY = targetScreenPos.Y - mousePos.Y
                
                if mousemoverel then
                    mousemoverel(deltaX / Settings.Smoothness, deltaY / Settings.Smoothness)
                end
            end

            if Settings.Tracers then
                TracerLine.From = mousePos
                TracerLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                TracerLine.Visible = true
            else
                TracerLine.Visible = false
            end
        else
            TracerLine.Visible = false
        end
    else
        TracerLine.Visible = false
    end
end)

local Window = ImGuiLib:CreateWindow({
    Title = "Combat Utilities",
    Size = Vector2.new(300, 360)
})

local AimHeader = Window:CreateHeader({ Name = "Cursor Lock Settings" })

local LockToggle = AimHeader:CreateToggle({
    Name = "Enable Cursor Lock (Keybind: Q)",
    Default = false,
    Callback = function(state)
        Settings.Enabled = state
        FOVCircle.Visible = state
    end
})

AimHeader:CreateToggle({
    Name = "Wall Check",
    Default = false,
    Callback = function(state)
        Settings.WallCheck = state
    end
})

AimHeader:CreateToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(state)
        Settings.TeamCheck = state
    end
})

AimHeader:CreateSlider({
    Name = "Aim Smoothness",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(val)
        Settings.Smoothness = val
    end
})

AimHeader:CreateSlider({
    Name = "FOV Size",
    Min = 10,
    Max = 600,
    Default = 100,
    Callback = function(val)
        Settings.FOV = val
    end
})

AimHeader:CreateToggle({
    Name = "Show Tracers",
    Default = false,
    Callback = function(state)
        Settings.Tracers = state
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Keybind then
        Settings.Enabled = not Settings.Enabled
        FOVCircle.Visible = Settings.Enabled
        LockToggle:SetState(Settings.Enabled)
    end
end)
