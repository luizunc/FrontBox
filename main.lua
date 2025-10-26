-- FrontBox - Sistema de ESP e Hitbox Otimizado
-- storager.kkr

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Variáveis Globais
local LocalPlayer = Players.LocalPlayer
local start = os.clock()
local processedEnemies = {}
local hitboxCache = {}

-- Configurações
local config = {
    hitboxSize = {x = 10, y = 10, z = 10},
    transparency = 1,
    notifications = false,
    espEnabled = false,
    boxes = false,
    names = false,
    distance = false,
    tracers = false,
    players = false,
    skeleton = false,
    teamCheck = true,
    espColor = {r = 255, g = 255, b = 255},
    thickness = 2,
    autoRemove = true,
    hitboxRadius = 5
}

-- Funções Auxiliares
local function sendNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = "",
            Duration = duration or 3
        })
    end)
end

local function isValidEnemy(model)
    if not model or not model:IsA("Model") then return false end
    if model.Name ~= "soldier_model" then return false end
    if model:FindFirstChild("friendly_marker") then return false end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    
    return true
end

-- Sistema de Hitbox
local function applyHitboxToEnemy(enemy)
    if not isValidEnemy(enemy) then return end
    if processedEnemies[enemy] then return end
    
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    processedEnemies[enemy] = true
    
    local pos = hrp.Position
    local size = Vector3.new(config.hitboxSize.x, config.hitboxSize.y, config.hitboxSize.z)
    
    for _, bp in pairs(workspace:GetChildren()) do
        if bp:IsA("BasePart") then
            local distance = (bp.Position - pos).Magnitude
            if distance <= config.hitboxRadius then
                bp.Transparency = config.transparency
                bp.Size = size
            end
        end
    end
    
    if config.notifications then
        sendNotification("FrontBox", "Hitbox aplicado ao inimigo", 2)
    end
end

local function removeEnemyFromCache(enemy)
    processedEnemies[enemy] = nil
    hitboxCache[enemy] = nil
end

-- Inicialização do ESP
sendNotification("FrontBox", "Carregando...", 5)

local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luizunc/FrontBox/main/esp.lua"))()
esp:Toggle(true)

local function updateESPConfig()
    esp.Boxes = config.boxes
    esp.Names = config.names
    esp.Distance = config.distance
    esp.Tracers = config.tracers
    esp.Players = config.players
    esp.Skeleton = config.skeleton
    esp.Thickness = config.thickness
end

updateESPConfig()

-- Configuração do ESP
esp:AddObjectListener(workspace, {
    Name = "soldier_model",
    Type = "Model",
    ColorDynamic = function()
        return Color3.fromRGB(config.espColor.r, config.espColor.g, config.espColor.b)
    end,
    PrimaryPart = function(obj)
        return obj:WaitForChild("HumanoidRootPart", 5)
    end,
    Validator = function(obj)
        return isValidEnemy(obj)
    end,
    CustomName = "INIMIGO",
    IsEnabled = "enemy"
})

esp.enemy = true

-- Aplicar Hitbox em Inimigos Existentes
task.wait(1)

task.spawn(function()
    for _, enemy in pairs(workspace:GetDescendants()) do
        if isValidEnemy(enemy) then
            applyHitboxToEnemy(enemy)
        end
    end
end)

-- Monitorar Novos Inimigos
local debounce = {}

workspace.DescendantAdded:Connect(function(descendant)
    if debounce[descendant] then return end
    debounce[descendant] = true
    
    task.delay(1, function()
        if isValidEnemy(descendant) then
            applyHitboxToEnemy(descendant)
            
            descendant.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    removeEnemyFromCache(descendant)
                end
            end)
        end
        debounce[descendant] = nil
    end)
end)
 
-- Finalização
local finish = os.clock()
local loadTime = finish - start
local rating = loadTime < 3 and "rápido" or loadTime < 5 and "aceitável" or "lento"

sendNotification("FrontBox", string.format("Sistema ativo [%.2fs | %s]", loadTime, rating), 5)

-- Sistema de Interface (GUI)
local function updateSettings()
    updateESPConfig()
    esp:Toggle(config.espEnabled)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrontBoxMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game.CoreGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "FRONTBOX"
Title.TextColor3 = Color3.fromRGB(100, 150, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = ScrollFrame
UIPadding.PaddingLeft = UDim.new(0, 12)
UIPadding.PaddingRight = UDim.new(0, 12)
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingBottom = UDim.new(0, 8)

local function createSeparator(text, order)
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Parent = ScrollFrame
    Separator.BackgroundTransparency = 1
    Separator.Size = UDim2.new(1, 0, 0, 25)
    Separator.LayoutOrder = order
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Separator
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(120, 160, 255)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Line = Instance.new("Frame")
    Line.Parent = Separator
    Line.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Line.BorderSizePixel = 0
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.Size = UDim2.new(1, 0, 0, 1)
end

local function createCheckbox(text, value, callback, order)
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Name = text
    CheckboxFrame.Parent = ScrollFrame
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 26)
    CheckboxFrame.LayoutOrder = order
    
    local Label = Instance.new("TextLabel")
    Label.Parent = CheckboxFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 30, 0, 0)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 210)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Checkbox = Instance.new("TextButton")
    Checkbox.Parent = CheckboxFrame
    Checkbox.BackgroundColor3 = value and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(40, 40, 50)
    Checkbox.BorderSizePixel = 0
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    Checkbox.Font = Enum.Font.GothamBold
    Checkbox.Text = value and "✓" or ""
    Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkbox.TextSize = 14
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Checkbox
    
    Checkbox.MouseButton1Click:Connect(function()
        value = not value
        Checkbox.BackgroundColor3 = value and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(40, 40, 50)
        Checkbox.Text = value and "✓" or ""
        callback(value)
    end)
    
    return Checkbox
end

local function createSlider(text, value, min, max, callback, order, isInt)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text
    SliderFrame.Parent = ScrollFrame
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.LayoutOrder = order
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.Size = UDim2.new(0.4, 0, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(isInt and math.floor(value) or math.floor(value * 100) / 100)
    ValueLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Parent = SliderFrame
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBack.BorderSizePixel = 0
    SliderBack.Position = UDim2.new(0, 0, 0, 25)
    SliderBack.Size = UDim2.new(1, 0, 0, 20)
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBack
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBack
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.Text = ""
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local relativeX = math.clamp(mouse.X - SliderBack.AbsolutePosition.X, 0, SliderBack.AbsoluteSize.X)
            local percentage = relativeX / SliderBack.AbsoluteSize.X
            value = min + (max - min) * percentage
            if isInt then
                value = math.floor(value)
            end
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = tostring(isInt and value or math.floor(value * 100) / 100)
            callback(value)
        end
    end)
end

local function createButton(text, callback, order)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Parent = ScrollFrame
    Button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.LayoutOrder = order
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    end)
end

local order = 0

createSeparator("CONFIGURAÇÕES ESP", order)
order = order + 1

createCheckbox("Ativar ESP", config.espEnabled, function(value)
    config.espEnabled = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Caixas", config.boxes, function(value)
    config.boxes = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Nomes", config.names, function(value)
    config.names = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Distância", config.distance, function(value)
    config.distance = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Linhas", config.tracers, function(value)
    config.tracers = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Jogadores", config.players, function(value)
    config.players = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Mostrar Esqueleto", config.skeleton, function(value)
    config.skeleton = value
    updateSettings()
end, order)
order = order + 1

createCheckbox("Verificar Time", config.teamCheck, function(value)
    config.teamCheck = value
    updateSettings()
end, order)
order = order + 1

createSlider("Espessura", config.thickness, 1, 5, function(value)
    config.thickness = value
    updateSettings()
end, order, true)
order = order + 1

createSeparator("CORES", order)
order = order + 1

createSlider("Vermelho", config.espColor.r, 0, 255, function(value)
    config.espColor.r = value
end, order, true)
order = order + 1

createSlider("Verde", config.espColor.g, 0, 255, function(value)
    config.espColor.g = value
end, order, true)
order = order + 1

createSlider("Azul", config.espColor.b, 0, 255, function(value)
    config.espColor.b = value
end, order, true)
order = order + 1

createSeparator("HITBOX", order)
order = order + 1

createSlider("Tamanho X", config.hitboxSize.x, 1, 20, function(value)
    config.hitboxSize.x = value
end, order, true)
order = order + 1

createSlider("Tamanho Y", config.hitboxSize.y, 1, 20, function(value)
    config.hitboxSize.y = value
end, order, true)
order = order + 1

createSlider("Tamanho Z", config.hitboxSize.z, 1, 20, function(value)
    config.hitboxSize.z = value
end, order, true)
order = order + 1

createSlider("Transparência", config.transparency, 0, 1, function(value)
    config.transparency = value
end, order, false)
order = order + 1

createSeparator("NOTIFICAÇÕES", order)
order = order + 1

createCheckbox("Ativar Notificações", config.notifications, function(value)
    config.notifications = value
end, order)
order = order + 1

createSeparator("DESEMPENHO", order)
order = order + 1

createCheckbox("Remoção Automática", config.autoRemove, function(value)
    config.autoRemove = value
    esp.AutoRemove = value
end, order)
order = order + 1

createSeparator("AÇÕES", order)
order = order + 1

createButton("Aplicar em Todos", function()
    local count = 0
    processedEnemies = {}
    
    task.spawn(function()
        for _, enemy in pairs(workspace:GetDescendants()) do
            if isValidEnemy(enemy) then
                applyHitboxToEnemy(enemy)
                count = count + 1
            end
        end
        sendNotification("FrontBox", string.format("Aplicado em %d inimigos!", count), 3)
    end)
end, order)
order = order + 1

sendNotification("FrontBox", "[INSERT] Abrir Menu | [END] Desativar", 6)

-- Função de Remoção
local function removeCheat()
    esp:Toggle(false)
    for _, v in pairs(esp.Objects) do
        if v.Remove then
            pcall(function() v:Remove() end)
        end
    end
    
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    processedEnemies = {}
    hitboxCache = {}
    
    sendNotification("FrontBox", "Sistema desativado com sucesso", 3)
end

-- Controles de Teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.End then
        removeCheat()
    end
end)

-- Limpeza de Memória
task.spawn(function()
    while task.wait(30) do
        for enemy, _ in pairs(processedEnemies) do
            if not enemy or not enemy.Parent then
                removeEnemyFromCache(enemy)
            end
        end
    end
end)
