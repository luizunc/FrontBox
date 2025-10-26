--this script is designed to work with the Roblox game engine and is intended for educational purposes only. It modifies the game's behavior by applying ESP (Extra Sensory Perception) to enemy models and changing their hitbox size and transparency.
-- It also sends notifications to the player when certain events occur, such as loading the script and spawning new enemies. The script uses a custom ESP library to achieve this functionality.
-- The script is not intended for use in any malicious or harmful way and should only be used in a safe and controlled environment.
-- Please ensure that you have permission to use this script in the game you are playing and that it does not violate any terms of service or community guidelines.


-- this is my script, please do not steal it or claim it as your own. I worked hard on this and would appreciate it if you could respect my work. Thank you!p
-- kind regards, storager.kkr



-- ____ _____ ___  ____      _    ____ _____ ____    _  ___  ______       
--/ ___|_   _/ _ \|  _ \    / \  / ___| ____|  _ \  | |/ / |/ /  _ \  
--\___ \ | || | | | |_) |  / _ \| |  _|  _| | |_) | | ' /| ' /| |_) | 
 --___) || || |_| |  _ <  / ___ \ |_| | |___|  _ < _| . \| . \|  _ < 
--|____/ |_| \___/|_| \_\/_/   \_\____|_____|_| \_(_)_|\_\_|\_\_| \_\




-- ____ _____ ___  ____      _    ____ _____ ____    _  ___  ______       
--/ ___|_   _/ _ \|  _ \    / \  / ___| ____|  _ \  | |/ / |/ /  _ \  
--\___ \ | || | | | |_) |  / _ \| |  _|  _| | |_) | | ' /| ' /| |_) | 
 --___) || || |_| |  _ <  / ___ \ |_| | |___|  _ < _| . \| . \|  _ < 
--|____/ |_| \___/|_| \_\/_/   \_\____|_____|_| \_(_)_|\_\_|\_\_| \_\






-- ____ _____ ___  ____      _    ____ _____ ____    _  ___  ______       
--/ ___|_   _/ _ \|  _ \    / \  / ___| ____|  _ \  | |/ / |/ /  _ \  
--\___ \ | || | | | |_) |  / _ \| |  _|  _| | |_) | | ' /| ' /| |_) | 
 --___) || || |_| |  _ <  / ___ \ |_| | |___|  _ < _| . \| . \|  _ < 
--|____/ |_| \___/|_| \_\/_/   \_\____|_____|_| \_(_)_|\_\_|\_\_| \_\




-- ____ _____ ___  ____      _    ____ _____ ____    _  ___  ______       
--/ ___|_   _/ _ \|  _ \    / \  / ___| ____|  _ \  | |/ / |/ /  _ \  
--\___ \ | || | | | |_) |  / _ \| |  _|  _| | |_) | | ' /| ' /| |_) | 
 --___) || || |_| |  _ <  / ___ \ |_| | |___|  _ < _| . \| . \|  _ < 
--|____/ |_| \___/|_| \_\/_/   \_\____|_____|_| \_(_)_|\_\_|\_\_| \_\





-- ____ _____ ___  ____      _    ____ _____ ____    _  ___  ______       
--/ ___|_   _/ _ \|  _ \    / \  / ___| ____|  _ \  | |/ / |/ /  _ \  
--\___ \ | || | | | |_) |  / _ \| |  _|  _| | |_) | | ' /| ' /| |_) | 
 --___) || || |_| |  _ <  / ___ \ |_| | |___|  _ < _| . \| . \|  _ < 
--|____/ |_| \___/|_| \_\/_/   \_\____|_____|_| \_(_)_|\_\_|\_\_| \_\






-- zet hitbox grootte, transparantie niveau en notificatie status
-- Set hitbox size, transparency level, and notification status
local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false
 
-- verbergt de tijd waneer het script geladen is
-- Store the time when the code starts executing
local start = os.clock()

-- stuurt een notificatie dat het script aan het laden is
-- Send a notification saying that the script is loading
game.StarterGui:SetCore("SendNotification", {
   Title = "Script",
   Text = "Loading...",
   Icon = "",
   Duration = 5
})
-- zoek de esp library op github executes het  
-- Load the ESP library and turns it on
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/STORAGERKIR/frontlines-script/refs/heads/main/esp-library.lua"))()
esp:Toggle(true)


-- zet de ESP instellingen in
-- Configure ESP settings
esp.Boxes = true
esp.Names = true
esp.Tracers = false
esp.Players = false

-- voegt een object listener toe aan de workspace om vijandige modellen te detecteren
-- Add an object listener to the workspace to detect enemy models
esp:AddObjectListener(workspace, {
   Name = "soldier_model",
   Type = "Model",
   Color = Color3.fromRGB(255, 0, 4),
 
   -- specifeseer de primaire deel van het model als de "HumanoidRootPart" 
   -- Specify the primary part of the model as the HumanoidRootPart
   PrimaryPart = function(obj)
       local root
       repeat
           root = obj:FindFirstChild("HumanoidRootPart")
           task.wait()
       until root
       return root
   end,
    
   -- gebruikt een validator functie om te controleren of de modellen geen "friendly_marker" child hebben
   -- Use a validator function to ensure that models do not have the "friendly_marker" child
   Validator = function(obj)
       task.wait(1)
       if obj:FindFirstChild("friendly_marker") then
           return false
       end
       return true
   end,
 
   -- maak een niewe naam voor enemy modellen ( onnodig maar kan handig zijn)
    -- Create a new name for enemy models (unnecessary but can be useful)
   -- Set a custom name to use for the enemy models
   CustomName = "?",
 
   -- zet de esp aan voor enemy modellen
   -- Enable the ESP for enemy models
   IsEnabled = "enemy"
})
 
-- Enable the ESP for enemy models
esp.enemy = true
 
-- Wait for the game to load fully before applying hitboxes
task.wait(1)
 
-- Apply hitboxes to all existing enemy models in the workspace
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
 
-- Function to handle when a new descendant is added to the workspace
local function handleDescendantAdded(descendant)
   task.wait(1)
 
   -- If the new descendant is an enemy model and notifications are enabled, send a notification
   if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "Script",
               Text = "[Warning] New Enemy Spawned! Applied hitboxes.",
               Icon = "",
               Duration = 3
           })
       end
 
       -- Apply hitboxes to the new enemy model
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
 
-- Connect the handleDescendantAdded function to the DescendantAdded event of the workspace
task.spawn(function()
   game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)
 
-- Store the time when the code finishes executing
local finish = os.clock()
 
-- Calculate how long the code took to run and determine a rating for the loading speed
local time = finish - start
local rating
if time < 3 then
   rating = "fast"
elseif time < 5 then
   rating = "acceptable"
else
   rating = "slow"
end
 
-- Send a notification showing how long the code took to run and its rating
game.StarterGui:SetCore("SendNotification", {
   Title = "Script",
   Text = string.format("Script loaded in %.2f seconds (%s loading)", time, rating),
   Icon = "",
   Duration = 5
})
