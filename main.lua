-- Configuração
local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false

local start = os.clock()
game.StarterGui:SetCore("SendNotification", {
   Title = "Script",
   Text = "Carregando...",
   Icon = "",
   Duration = 5
})

-- Carrega biblioteca ESP
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luizunc/Script_FrontLine/refs/heads/main/esp-library.lua"))()
esp:Toggle(false)

-- Detecta inimigos
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

-- Aplica hitboxes aos inimigos existentes
for _, v in pairs(workspace:GetDescendants()) do
   if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
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
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "Script",
               Text = "[Aviso] Novo inimigo spawnado! Hitboxes aplicados.",
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
