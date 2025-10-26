local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Aimbot.Settings = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    TargetPart = "Head",
    FOV = 200,
    Smoothness = 0.1,
    PredictionEnabled = false,
    PredictionAmount = 0.13,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    AimKey = Enum.UserInputType.MouseButton2,
    IgnoreDead = true
}

local FOVCircle
local CurrentTarget
local AimKeyPressed = false

local function CreateFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = Aimbot.Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = Aimbot.Settings.ShowFOV
    FOVCircle.Color = Aimbot.Settings.FOVColor
    FOVCircle.Transparency = 1
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function UpdateFOVCircle()
    if FOVCircle then
        FOVCircle.Visible = Aimbot.Settings.ShowFOV and Aimbot.Settings.Enabled
        FOVCircle.Radius = Aimbot.Settings.FOV
        FOVCircle.Color = Aimbot.Settings.FOVColor
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

local function IsVisible(targetPart)
    if not Aimbot.Settings.VisibilityCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    
    if rayResult then
        local hitParent = rayResult.Instance.Parent
        return hitParent == targetPart.Parent or hitParent:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function IsTeamMate(player)
    if not Aimbot.Settings.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.Settings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                if Aimbot.Settings.TeamCheck and IsTeamMate(player) then
                    continue
                end
                
                if character:FindFirstChild("friendly_marker") then
                    continue
                end
                
                if Aimbot.Settings.IgnoreDead and not IsAlive(character) then
                    continue
                end
                
                local targetPart = character:FindFirstChild("Head")
                if not targetPart then
                    targetPart = character:FindFirstChild("HumanoidRootPart")
                end
                
                if targetPart then
                    if IsVisible(targetPart) then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        
                        if onScreen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                            
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function GetClosestEnemyModel()
    local closestModel = nil
    local shortestDistance = Aimbot.Settings.FOV
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "soldier_model" and obj:IsA("Model") then
            if obj:FindFirstChild("friendly_marker") then
                continue
            end
            
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if Aimbot.Settings.IgnoreDead and (not humanoid or humanoid.Health <= 0) then
                continue
            end
            
            local targetPart = obj:FindFirstChild("Head")
            if not targetPart then
                targetPart = obj:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                if IsVisible(targetPart) then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                        
                        if distance < shortestDistance then
                            closestModel = obj
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestModel
end

local function GetTargetPosition(target)
    local character = target.Character or target
    
    local targetPart = character:FindFirstChild("Head")
    if not targetPart then
        targetPart = character:FindFirstChild("HumanoidRootPart")
    end
    
    if not targetPart then return nil end
    
    local position = targetPart.Position
    
    if Aimbot.Settings.PredictionEnabled then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local velocity = humanoidRootPart.AssemblyVelocity
            position = position + (velocity * Aimbot.Settings.PredictionAmount)
        end
    end
    
    return position
end

local function AimAt(target)
    if not target then return end
    
    local targetPosition = GetTargetPosition(target)
    if not targetPosition then return end
    
    local cameraPosition = Camera.CFrame.Position
    local targetCFrame = CFrame.new(cameraPosition, targetPosition)
    
    if Aimbot.Settings.Smoothness > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Aimbot.Settings.Smoothness)
    else
        Camera.CFrame = targetCFrame
    end
end

function Aimbot:Toggle(state)
    self.Settings.Enabled = state
    if not state then
        CurrentTarget = nil
    end
end

function Aimbot:UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Aimbot.Settings.AimKey or input.KeyCode == Enum.KeyCode.E then
        AimKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Aimbot.Settings.AimKey or input.KeyCode == Enum.KeyCode.E then
        AimKeyPressed = false
        CurrentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    
    if Aimbot.Settings.Enabled and AimKeyPressed then
        if not CurrentTarget or not CurrentTarget.Parent then
            local playerTarget = GetClosestPlayerToCursor()
            if playerTarget then
                CurrentTarget = playerTarget
            else
                local modelTarget = GetClosestEnemyModel()
                if modelTarget then
                    CurrentTarget = modelTarget
                end
            end
        end
        
        if CurrentTarget then
            local character = CurrentTarget.Character or CurrentTarget
            if character and character.Parent then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    AimAt(CurrentTarget)
                else
                    CurrentTarget = nil
                end
            else
                CurrentTarget = nil
            end
        end
    end
end)

CreateFOVCircle()

return Aimbot
