-- Aimbot Otimizado - FrontBox
local Aimbot = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Variáveis Locais
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local FOVCircle
local CurrentTarget
local AimKeyPressed = false
local enemyCache = {}
local lastCacheUpdate = 0
local CACHE_REFRESH_RATE = 0.5

-- Configurações
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

-- Funções de FOV
local function CreateFOVCircle()
    local success, circle = pcall(function()
        local c = Drawing.new("Circle")
        c.Thickness = 2
        c.NumSides = 50
        c.Radius = Aimbot.Settings.FOV
        c.Filled = false
        c.Visible = Aimbot.Settings.ShowFOV
        c.Color = Aimbot.Settings.FOVColor
        c.Transparency = 1
        c.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        return c
    end)
    if success then
        FOVCircle = circle
    end
end

local function UpdateFOVCircle()
    if not FOVCircle then return end
    
    FOVCircle.Visible = Aimbot.Settings.ShowFOV and Aimbot.Settings.Enabled
    FOVCircle.Radius = Aimbot.Settings.FOV
    FOVCircle.Color = Aimbot.Settings.FOVColor
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
end

-- Funções de Validação
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local function IsVisible(targetPart)
    if not Aimbot.Settings.VisibilityCheck then return true end
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = targetPos - origin
    
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    
    if not rayResult then return true end
    
    local hitParent = rayResult.Instance.Parent
    return hitParent == targetPart.Parent or hitParent:IsDescendantOf(targetPart.Parent)
end

local function IsTeamMate(player)
    if not Aimbot.Settings.TeamCheck then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function IsAlive(character)
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetTargetPart(character)
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

-- Funções de Detecção de Alvo
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        if Aimbot.Settings.TeamCheck and IsTeamMate(player) then continue end
        if character:FindFirstChild("friendly_marker") then continue end
        if Aimbot.Settings.IgnoreDead and not IsAlive(character) then continue end
        
        local targetPart = GetTargetPart(character)
        if not targetPart then continue end
        if not IsVisible(targetPart) then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        if distance < shortestDistance then
            closestPlayer = player
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

local function UpdateEnemyCache()
    local currentTime = tick()
    if currentTime - lastCacheUpdate < CACHE_REFRESH_RATE then return end
    
    lastCacheUpdate = currentTime
    table.clear(enemyCache)
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "soldier_model" and obj:IsA("Model") then
            if not obj:FindFirstChild("friendly_marker") then
                table.insert(enemyCache, obj)
            end
        end
    end
end

local function GetClosestEnemyModel()
    UpdateEnemyCache()
    
    local closestModel = nil
    local shortestDistance = Aimbot.Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, obj in ipairs(enemyCache) do
        if not obj or not obj.Parent then continue end
        
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if Aimbot.Settings.IgnoreDead and (not humanoid or humanoid.Health <= 0) then continue end
        
        local targetPart = GetTargetPart(obj)
        if not targetPart then continue end
        if not IsVisible(targetPart) then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        if distance < shortestDistance then
            closestModel = obj
            shortestDistance = distance
        end
    end
    
    return closestModel
end

-- Funções de Mira
local function GetTargetPosition(target)
    local character = target.Character or target
    if not character or not character.Parent then return nil end
    
    local targetPart = GetTargetPart(character)
    if not targetPart then return nil end
    
    local position = targetPart.Position
    
    if Aimbot.Settings.PredictionEnabled then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then
            position = position + (hrp.AssemblyVelocity * Aimbot.Settings.PredictionAmount)
        end
    end
    
    return position
end

local function AimAt(target)
    if not target then return end
    
    local targetPosition = GetTargetPosition(target)
    if not targetPosition then return end
    
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    
    Camera.CFrame = Aimbot.Settings.Smoothness > 0 
        and Camera.CFrame:Lerp(targetCFrame, Aimbot.Settings.Smoothness) 
        or targetCFrame
end

-- Métodos Públicos
function Aimbot:Toggle(state)
    self.Settings.Enabled = state
    if not state then
        CurrentTarget = nil
        table.clear(enemyCache)
    end
end

function Aimbot:UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
        end
    end
end

function Aimbot:ClearCache()
    table.clear(enemyCache)
    lastCacheUpdate = 0
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

-- Loop Principal
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    
    if not (Aimbot.Settings.Enabled and AimKeyPressed) then return end
    
    if not CurrentTarget or not CurrentTarget.Parent then
        CurrentTarget = GetClosestPlayerToCursor() or GetClosestEnemyModel()
    end
    
    if not CurrentTarget then return end
    
    local character = CurrentTarget.Character or CurrentTarget
    if not character or not character.Parent then
        CurrentTarget = nil
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        CurrentTarget = nil
        return
    end
    
    AimAt(CurrentTarget)
end)

-- Inicialização
CreateFOVCircle()

-- Limpar cache quando workspace muda
workspace.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "soldier_model" then
        Aimbot:ClearCache()
    end
end)

return Aimbot
