--[[
    FrontLine ESP Loader
    Carrega automaticamente o script completo
    Uso: loadstring(game:HttpGet("URL_DO_SEU_REPOSITORIO/loader.lua"))()
]]

-- Carregar biblioteca ESP customizada
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luizunc/Script_FrontLine/refs/heads/main/esp-library.lua"))()

-- Configurações do menu
local menuOpen = true
local config = {
    -- Hitbox settings (limite máximo 20 para tiros válidos)
    hitboxSize = {x = 10, y = 10, z = 10},
    transparency = 0.7,
    notifications = false,
    
    -- ESP settings
    espEnabled = true,
    boxes = true,
    names = true,
    distance = true,
    tracers = false,
    players = false,
    skeleton = true,
    teamCheck = true,
    
    -- Color settings
    espColor = {r = 255, g = 0, b = 4},
    thickness = 2,
    
    -- Performance
    autoRemove = true
}

-- Variáveis compatíveis com o código original
local size = Vector3.new(config.hitboxSize.x, config.hitboxSize.y, config.hitboxSize.z)
local trans = config.transparency
local notifications = config.notifications
 
-- Store the time when the code starts executing
local start = os.clock()

-- Send a notification saying that the script is loading
game.StarterGui:SetCore("SendNotification", {
   Title = "FrontLine ESP",
   Text = "Loading...",
   Icon = "",
   Duration = 3
})

-- Configure ESP settings
esp:Toggle(true)
esp.Boxes = config.boxes
esp.Names = config.names
esp.Distance = config.distance
esp.Tracers = config.tracers
esp.Players = config.players
esp.Skeleton = config.skeleton
esp.Thickness = config.thickness

-- Add object listener for enemy models
esp:AddObjectListener(workspace, {
   Name = "soldier_model",
   Type = "Model",
   ColorDynamic = function()
       return Color3.fromRGB(config.espColor.r, config.espColor.g, config.espColor.b)
   end,
 
   PrimaryPart = function(obj)
       local root
       repeat
           root = obj:FindFirstChild("HumanoidRootPart")
           task.wait()
       until root
       return root
   end,
    
   Validator = function(obj)
       task.wait(0.5)
       -- Verificar se tem friendly_marker (team check)
       if config.teamCheck and obj:FindFirstChild("friendly_marker") then
           return false
       end
       -- Verificar se o inimigo está vivo
       local humanoid = obj:FindFirstChildOfClass("Humanoid")
       if humanoid and humanoid.Health <= 0 then
           return false
       end
       return true
   end,
 
   CustomName = "?",
   IsEnabled = "enemy"
})
 
-- Enable the ESP for enemy models
esp.enemy = true
 
-- Wait for the game to load fully before applying hitboxes
task.wait(1)
 
-- Função para aplicar hitbox em um modelo
local function applyHitbox(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return end
    
    -- Modificar apenas as partes do modelo inimigo
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Size = size
            part.Transparency = trans
            part.CanCollide = false
        end
    end
    
    -- Expandir HumanoidRootPart (hitbox principal)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = size
        hrp.Transparency = trans
        hrp.CanCollide = false
    end
end

-- Apply hitboxes to all existing enemy models in the workspace
for _, v in pairs(workspace:GetDescendants()) do
   if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
       applyHitbox(v)
   end
end
 
-- Function to handle when a new descendant is added to the workspace
local function handleDescendantAdded(descendant)
   task.wait(1)
 
   if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "FrontLine ESP",
               Text = "[Warning] New Enemy Spawned!",
               Icon = "",
               Duration = 3
           })
       end
 
       -- Apply hitboxes to the new enemy model
       applyHitbox(descendant)
   end
end
 
-- Connect the handleDescendantAdded function
task.spawn(function()
   game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)
 
-- Calculate loading time
local finish = os.clock()
local time = finish - start
local rating
if time < 3 then
   rating = "fast"
elseif time < 5 then
   rating = "acceptable"
else
   rating = "slow"
end
 
game.StarterGui:SetCore("SendNotification", {
   Title = "FrontLine ESP",
   Text = string.format("Loaded in %.2f seconds (%s)", time, rating),
   Icon = "",
   Duration = 4
})

-- ============================================
-- MENU UI
-- ============================================

-- Função para atualizar as configurações em tempo real
local function updateESPSettings()
    esp.Boxes = config.boxes
    esp.Names = config.names
    esp.Distance = config.distance
    esp.Tracers = config.tracers
    esp.Players = config.players
    esp.Skeleton = config.skeleton
    esp.Thickness = config.thickness
    esp:Toggle(config.espEnabled)
    
    size = Vector3.new(config.hitboxSize.x, config.hitboxSize.y, config.hitboxSize.z)
    trans = config.transparency
    notifications = config.notifications
end

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrontLineESPMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteger GUI
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game.CoreGui
end

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Visible = false

-- Arredondar cantos
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Barra de título com gradiente
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Logo/Ícone
local LogoFrame = Instance.new("Frame")
LogoFrame.Name = "LogoFrame"
LogoFrame.Parent = TitleBar
LogoFrame.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
LogoFrame.BorderSizePixel = 0
LogoFrame.Position = UDim2.new(0, 12, 0.5, -15)
LogoFrame.Size = UDim2.new(0, 30, 0, 30)

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 6)
LogoCorner.Parent = LogoFrame

local LogoText = Instance.new("TextLabel")
LogoText.Parent = LogoFrame
LogoText.BackgroundTransparency = 1
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.Font = Enum.Font.GothamBold
LogoText.Text = "FL"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 14

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 50, 0, 0)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "FrontLine ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = TitleBar
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 50, 0, 20)
Subtitle.Size = UDim2.new(1, -120, 0, 20)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "v2.0 - Advanced ESP System"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Botão fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
end)

-- Sidebar (Menu lateral)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.Size = UDim2.new(0, 150, 1, -45)

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

-- Content Area (Área de conteúdo)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 150, 0, 45)
ContentFrame.Size = UDim2.new(1, -150, 1, -45)

-- ScrollingFrame para conteúdo
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = ContentFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0, 10, 0, 10)
ScrollFrame.Size = UDim2.new(1, -20, 1, -20)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 50, 50)

-- Layout para organizar elementos
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = ScrollFrame
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)

-- Sistema de abas
local currentTab = "ESP"
local tabs = {}

-- Função para criar botão de aba na sidebar
local function createTabButton(name, icon, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Parent = Sidebar
    TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
    TabButton.BorderSizePixel = 0
    TabButton.Position = UDim2.new(0, 8, 0, 8 + (order * 42))
    TabButton.Size = UDim2.new(1, -16, 0, 38)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = "  " .. icon .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabButton.TextSize = 13
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    tabs[name] = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        currentTab = name
        for tabName, tabBtn in pairs(tabs) do
            if tabName == name then
                tabBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                tabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
            end
        end
        -- Limpar conteúdo e recarregar
        for _, child in pairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
        loadTabContent(name)
    end)
    
    TabButton.MouseEnter:Connect(function()
        if currentTab ~= name then
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if currentTab ~= name then
            TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        end
    end)
    
    return TabButton
end

-- Criar abas
createTabButton("ESP", "👁", 0)
createTabButton("Visuals", "🎨", 1)
createTabButton("Hitbox", "🎯", 2)
createTabButton("Settings", "⚙", 3)

-- Ativar primeira aba
tabs["ESP"].BackgroundColor3 = Color3.fromRGB(220, 50, 50)
tabs["ESP"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Função para criar seção (card)
local function createSection(text, order)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Parent = ScrollFrame
    Section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.LayoutOrder = order
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section
    
    local Accent = Instance.new("Frame")
    Accent.Parent = Section
    Accent.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    Accent.BorderSizePixel = 0
    Accent.Size = UDim2.new(0, 3, 1, 0)
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = Accent
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Section
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(1, -15, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    return Section
end

-- Função para criar checkbox (toggle switch moderno)
local function createCheckbox(text, value, callback, order)
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Name = text
    CheckboxFrame.Parent = ScrollFrame
    CheckboxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    CheckboxFrame.BorderSizePixel = 0
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 32)
    CheckboxFrame.LayoutOrder = order
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = CheckboxFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = CheckboxFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle switch background
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Parent = CheckboxFrame
    ToggleBg.BackgroundColor3 = value and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(45, 45, 55)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Position = UDim2.new(1, -42, 0.5, -10)
    ToggleBg.Size = UDim2.new(0, 36, 0, 20)
    
    local ToggleBgCorner = Instance.new("UICorner")
    ToggleBgCorner.CornerRadius = UDim.new(1, 0)
    ToggleBgCorner.Parent = ToggleBg
    
    -- Toggle switch circle
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleBg
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    -- Button invisível para clique
    local ClickButton = Instance.new("TextButton")
    ClickButton.Parent = CheckboxFrame
    ClickButton.BackgroundTransparency = 1
    ClickButton.Size = UDim2.new(1, 0, 1, 0)
    ClickButton.Text = ""
    
    ClickButton.MouseButton1Click:Connect(function()
        value = not value
        ToggleBg.BackgroundColor3 = value and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(45, 45, 55)
        ToggleCircle:TweenPosition(
            value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        callback(value)
    end)
    
    ClickButton.MouseEnter:Connect(function()
        CheckboxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    end)
    
    ClickButton.MouseLeave:Connect(function()
        CheckboxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end)
    
    return CheckboxFrame
end

-- Função para criar slider
local function createSlider(text, value, min, max, callback, order, isInt)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text
    SliderFrame.Parent = ScrollFrame
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    SliderFrame.LayoutOrder = order
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = SliderFrame
    
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

-- Função para criar botão
local function createButton(text, callback, order)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Parent = ScrollFrame
    Button.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 38)
    Button.LayoutOrder = order
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(240, 60, 60)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end)
end

-- Função para carregar conteúdo de cada aba
function loadTabContent(tabName)
    local order = 0
    
    if tabName == "ESP" then
        createSection("ESP Features", order)
        order = order + 1
        
        createCheckbox("Enable ESP", config.espEnabled, function(value)
            config.espEnabled = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Show Boxes", config.boxes, function(value)
            config.boxes = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Show Names", config.names, function(value)
            config.names = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Show Distance", config.distance, function(value)
            config.distance = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Show Tracers", config.tracers, function(value)
            config.tracers = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Show Skeleton", config.skeleton, function(value)
            config.skeleton = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Team Check", config.teamCheck, function(value)
            config.teamCheck = value
            updateESPSettings()
        end, order)
        order = order + 1
        
    elseif tabName == "Visuals" then
        createSection("Visual Settings", order)
        order = order + 1
        
        createSlider("Thickness", config.thickness, 1, 5, function(value)
            config.thickness = value
            updateESPSettings()
        end, order, true)
        order = order + 1
        
        createSection("ESP Color", order)
        order = order + 1
        
        createSlider("Red", config.espColor.r, 0, 255, function(value)
            config.espColor.r = value
        end, order, true)
        order = order + 1
        
        createSlider("Green", config.espColor.g, 0, 255, function(value)
            config.espColor.g = value
        end, order, true)
        order = order + 1
        
        createSlider("Blue", config.espColor.b, 0, 255, function(value)
            config.espColor.b = value
        end, order, true)
        order = order + 1
        
    elseif tabName == "Hitbox" then
        createSection("Hitbox Size (Max: 20)", order)
        order = order + 1
        
        createSlider("Hitbox X", config.hitboxSize.x, 1, 20, function(value)
            config.hitboxSize.x = value
            updateESPSettings()
        end, order, true)
        order = order + 1
        
        createSlider("Hitbox Y", config.hitboxSize.y, 1, 20, function(value)
            config.hitboxSize.y = value
            updateESPSettings()
        end, order, true)
        order = order + 1
        
        createSlider("Hitbox Z", config.hitboxSize.z, 1, 20, function(value)
            config.hitboxSize.z = value
            updateESPSettings()
        end, order, true)
        order = order + 1
        
        createSlider("Transparency", config.transparency, 0, 1, function(value)
            config.transparency = value
            updateESPSettings()
        end, order, false)
        order = order + 1
        
        createSection("Actions", order)
        order = order + 1
        
        createButton("Apply to All Enemies", function()
            local count = 0
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
                    applyHitbox(v)
                    count = count + 1
                end
            end
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "FrontLine ESP",
                Text = string.format("Applied to %d enemies!", count),
                Icon = "",
                Duration = 3
            })
        end, order)
        order = order + 1
        
    elseif tabName == "Settings" then
        createSection("General Settings", order)
        order = order + 1
        
        createCheckbox("Enable Notifications", config.notifications, function(value)
            config.notifications = value
            updateESPSettings()
        end, order)
        order = order + 1
        
        createCheckbox("Auto Remove", config.autoRemove, function(value)
            config.autoRemove = value
            esp.AutoRemove = value
        end, order)
        order = order + 1
    end
end

-- Carregar conteúdo inicial
loadTabContent("ESP")

-- Notificação de menu carregado
game.StarterGui:SetCore("SendNotification", {
    Title = "FrontLine ESP",
    Text = "INSERT: Toggle Menu | END: Remove Cheat",
    Icon = "",
    Duration = 6
})

-- Função para remover completamente o cheat
local function removeCheat()
    -- Remover ESP
    esp:Toggle(false)
    for i,v in pairs(esp.Objects) do
        if v.Remove then
            v:Remove()
        end
    end
    
    -- Remover GUI
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    -- Notificação de remoção
    game.StarterGui:SetCore("SendNotification", {
        Title = "FrontLine ESP",
        Text = "Cheat removido com sucesso!",
        Icon = "",
        Duration = 3
    })
end

-- Toggle menu com tecla INSERT e remover com END
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.End then
            removeCheat()
        end
    end
end)
