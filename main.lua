-- FrontBox - Sistema de ESP e Hitbox
-- storager.kkr
local menuOpen = true
local config = {
    -- Configurações de Hitbox
    hitboxSize = {x = 10, y = 10, z = 10},
    transparency = 1,
    notifications = false,
    
    -- Configurações de ESP
    espEnabled = false,
    boxes = false,
    names = false,
    distance = false,
    tracers = false,
    players = false,
    skeleton = false,
    teamCheck = true,
    
    -- Configurações de Cor
    espColor = {r = 255, g = 255, b = 255},
    thickness = 2,
    
    -- Performance
    autoRemove = true
}

local size = Vector3.new(config.hitboxSize.x, config.hitboxSize.y, config.hitboxSize.z)
local trans = config.transparency
local notifications = config.notifications
local start = os.clock()

game.StarterGui:SetCore("SendNotification", {
   Title = "FrontBox",
   Text = "Carregando...",
   Icon = "",
   Duration = 5
})

local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luizunc/FrontBox/main/esp.lua"))()
esp:Toggle(true)


esp.Boxes = config.boxes
esp.Names = config.names
esp.Distance = config.distance
esp.Tracers = config.tracers
esp.Players = config.players
esp.Skeleton = config.skeleton
esp.Thickness = config.thickness

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
       task.wait(1)
       if obj:FindFirstChild("friendly_marker") then
           return false
       end
       local humanoid = obj:FindFirstChildOfClass("Humanoid")
       if humanoid and humanoid.Health <= 0 then
           return false
       end
       return true
   end,
 
   CustomName = "?",
 
   IsEnabled = "enemy"
})
 
esp.enemy = true
 
task.wait(1)
 
for _, v in pairs(workspace:GetDescendants()) do
   if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
       local hrp = v:FindFirstChild("HumanoidRootPart")
       if hrp then
           hrp.Transparency = trans
           hrp.Size = size
           hrp.CanCollide = false
       end
       
       for _, part in pairs(v:GetDescendants()) do
           if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
               part.Transparency = 1
               part.CanCollide = false
           end
       end
   end
end
 
local function handleDescendantAdded(descendant)
   task.wait(1)
 
   if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "FrontBox",
               Text = "[ALERTA] Novo inimigo detectado",
               Icon = "",
               Duration = 3
           })
       end
 
       local hrp = descendant:FindFirstChild("HumanoidRootPart")
       if hrp then
           hrp.Transparency = trans
           hrp.Size = size
           hrp.CanCollide = false
       end
       
       for _, part in pairs(descendant:GetDescendants()) do
           if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
               part.Transparency = 1
               part.CanCollide = false
           end
       end
   end
end
 
task.spawn(function()
   game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)
 
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
   Title = "FrontBox",
   Text = string.format("Sistema ativo [%.2fs | %s]", time, rating),
   Icon = "",
   Duration = 5
})

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

createSeparator("ESP SETTINGS", order)
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

createCheckbox("Show Players", config.players, function(value)
    config.players = value
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

createSlider("Thickness", config.thickness, 1, 5, function(value)
    config.thickness = value
    updateESPSettings()
end, order, true)
order = order + 1

createSeparator("COLOR SETTINGS", order)
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

createSeparator("HITBOX SETTINGS", order)
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

createSeparator("NOTIFICATIONS", order)
order = order + 1

createCheckbox("Enable Notifications", config.notifications, function(value)
    config.notifications = value
    updateESPSettings()
end, order)
order = order + 1

createSeparator("PERFORMANCE", order)
order = order + 1

createCheckbox("Auto Remove", config.autoRemove, function(value)
    config.autoRemove = value
    esp.AutoRemove = value
end, order)
order = order + 1

createSeparator("ACTIONS", order)
order = order + 1

createButton("Apply to All Enemies", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Transparency = trans
                hrp.Size = size
                hrp.CanCollide = false
            end
            
                 for _, part in pairs(v:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "FrontBox",
        Text = "Aplicado em todos os inimigos!",
        Icon = "",
        Duration = 3
    })
end, order)
order = order + 1

game.StarterGui:SetCore("SendNotification", {
    Title = "FrontBox",
    Text = "[INSERT] Menu | [END] Desativar",
    Icon = "",
    Duration = 6
})

local function removeCheat()
    esp:Toggle(false)
    for i,v in pairs(esp.Objects) do
        if v.Remove then
            v:Remove()
        end
    end
    
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "FrontBox",
        Text = "Sistema desativado",
        Icon = "",
        Duration = 3
    })
end

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
