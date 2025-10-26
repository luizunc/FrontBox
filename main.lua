-- Configuração
local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false
 
local start = os.clock()
game.StarterGui:SetCore("SendNotification", {
   Title = "Script",
   Text = "Loading...",
   Icon = "",
   Duration = 5
})
-- Carrega biblioteca ESP para detecção de objetos
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luizunc/Script_FrontLine/refs/heads/main/esp-library.lua"))()
esp:Toggle(false)

-- Configuração e gerenciador do Skeleton ESP
local skeletonColor = Color3.fromRGB(255, 0, 4)
local skeletons = {}
local cam = workspace.CurrentCamera

local function newLine()
    local l = Drawing.new("Line")
    l.Thickness = 2
    l.Color = skeletonColor
    l.Visible = false
    return l
end

local function getPart(model, name)
    return model:FindFirstChild(name)
end

local skeletonPairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local function worldToScreen(v3)
    local v2, onScreen = cam:WorldToViewportPoint(v3)
    return Vector2.new(v2.X, v2.Y), onScreen
end

local function newText()
    local t = Drawing.new("Text")
    t.Size = 18
    t.Center = true
    t.Outline = true
    t.Color = skeletonColor
    t.Visible = false
    return t
end

local function createSkeleton(model)
    if skeletons[model] then return end
    local lines = {}
    for _ = 1, #skeletonPairs do
        table.insert(lines, newLine())
    end
    skeletons[model] = {
        lines = lines,
        distanceText = newText(),
        conn = model.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                for _, ln in ipairs(lines) do
                    ln.Visible = false
                    ln:Remove()
                end
                skeletons[model].distanceText:Remove()
                skeletons[model] = nil
            end
        end)
    }
end

local function updateSkeleton(model)
    local sk = skeletons[model]
    if not sk then return end
    
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Atualiza linhas do skeleton
    local i = 1
    for _, pair in ipairs(skeletonPairs) do
        local a = getPart(model, pair[1])
        local b = getPart(model, pair[2])
        local ln = sk.lines[i]
        i = i + 1
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local p1, v1 = worldToScreen(a.Position)
            local p2, v2 = worldToScreen(b.Position)
            if v1 or v2 then
                ln.From = p1
                ln.To = p2
                ln.Color = skeletonColor
                ln.Visible = true
            else
                ln.Visible = false
            end
        else
            ln.Visible = false
        end
    end
    
    -- Atualiza texto de distância
    local headPos = getPart(model, "Head")
    if headPos and headPos:IsA("BasePart") then
        local screenPos, onScreen = worldToScreen(headPos.Position + Vector3.new(0, 1, 0))
        if onScreen then
            local distance = math.floor((cam.CFrame.Position - root.Position).Magnitude)
            sk.distanceText.Position = screenPos
            sk.distanceText.Text = distance .. "m"
            sk.distanceText.Color = skeletonColor
            sk.distanceText.Visible = true
        else
            sk.distanceText.Visible = false
        end
    else
        sk.distanceText.Visible = false
    end
end

-- Detecta modelos inimigos
esp:AddObjectListener(workspace, {
   Name = "soldier_model",
   Type = "Model",
   Color = Color3.fromRGB(255, 0, 4),
 
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
       return true
   end,
 
   CustomName = "?",
   IsEnabled = "enemy"
})

esp.enemy = true
task.wait(1)

-- Cria skeletons e aplica hitboxes aos inimigos existentes
for _, v in pairs(workspace:GetDescendants()) do
   if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
       createSkeleton(v)
       local pos = v:FindFirstChild("HumanoidRootPart").Position
       for _, bp in pairs(workspace:GetChildren()) do
           if bp:IsA("BasePart") then
               local distance = (bp.Position - pos).Magnitude
               if distance <= 5 then
                   bp.Transparency = trans
                   bp.Size = size
               end
           end
       end
   end
end

local function handleDescendantAdded(descendant)
   task.wait(1)
 
   if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
       createSkeleton(descendant)
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "Script",
               Text = "[Warning] New Enemy Spawned!",
               Icon = "",
               Duration = 3
           })
       end
       
       local pos = descendant:FindFirstChild("HumanoidRootPart").Position
       for _, bp in pairs(workspace:GetChildren()) do
           if bp:IsA("BasePart") then
               local distance = (bp.Position - pos).Magnitude
               if distance <= 5 then
                   bp.Transparency = trans
                   bp.Size = size
               end
           end
       end
   end
end
 
task.spawn(function()
   game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)

-- Atualiza skeletons a cada frame
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for model, sk in pairs(skeletons) do
        if model and model.Parent then
            updateSkeleton(model)
        end
    end
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
   Title = "Script",
   Text = string.format("Script loaded in %.2f seconds (%s loading)", time, rating),
   Icon = "",
   Duration = 5
})

