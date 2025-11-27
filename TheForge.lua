if  true then 
local Webhook = "https://discord.com/api/webhooks/1443160031775424523/ivqtzsxrV7RRjenuvoLlLTzXJAWL7MmZzRPZdYbNvYqbnc29_dQjy4ZVs-pid4dUJn1F"
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua"))()
local TextChatService = game:GetService("TextChatService")
local OreFolder = game:GetService("ReplicatedStorage").Shared.Data.Ore

local distance = 10000
local playerSpeed = 30
local goodNPC = {}; local allNPC = {}; buttonNPC = {}


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")


local autoSellRarity = 0
local isFarm = false; local isMine = false; 
local isKill = false; local isSwing = false;
local oreList = {} ; local nameOreList = {}; local targetOreList = {}
local monsterList = {} ; local nameMonsterList = {}; local targetMonsterList = {}
local oreSellList = {}; local oreSellTargetList = {};

-- MAIN

table.insert(goodNPC, "Runemaker"); table.insert(goodNPC, "Enhancer");
table.insert(goodNPC, "Miner Fred"); table.insert(goodNPC, "Sensei Moro");
table.insert(goodNPC, "Greedy Cey");

player.CharacterAdded:Connect(function(character)
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)
local function getPosition(obj1)
    if obj1:IsA("Model") then
        return obj1:GetPivot().Position
    elseif obj1:IsA("BasePart") then
        return obj1.Position
    else
        return nil
    end
end
local function getDistance(obj1, obj2)
    local pos1, pos2
    if obj1:IsA("Model") then
        pos1 = obj1:GetPivot().Position
    elseif obj1:IsA("BasePart") then
        pos1 = obj1.Position
    end

    if obj2:IsA("Model") then
        pos2 = obj2:GetPivot().Position
    elseif obj2:IsA("BasePart") then
        pos2 = obj2.Position
    end
    return (pos1 - pos2).Magnitude
end
-- FFARM MMine
task.spawn(function()
    while true do
        if isMine then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ToolActivated = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated -- RemoteFunction 
            ToolActivated:InvokeServer(
                "Pickaxe"
            )
        end
        if isSwing then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ToolActivated = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated -- RemoteFunction 
            ToolActivated:InvokeServer(
                "Weapon"
            )
        end
        task.wait(0.1)
    end
end)
local function getAllDescendants(parent)
    local list = {}
    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            table.insert(list, child)
            scan(child)
        end
    end
    scan(parent)
    return list
end
local function resetRockList()
    local Rock = getAllDescendants(workspace.Rocks)
    local nameSet = {}           -- helper table for checking duplicates
    table.clear(nameOreList)
    table.clear(oreList)

    for _, rock in pairs(Rock) do
        if rock.Name == "Hitbox" then
            local nameText = rock.Parent.Name
            local hitbox = rock
            if getDistance(hrp, hitbox) >= distance then continue end
            
            if not nameSet[nameText] then
                table.insert(oreList, nameText)
                nameSet[nameText] = true
                table.insert(nameOreList, nameText)
            end
        end
    end
end
local function mine(rock)
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -5

    local headPos = getPosition(rock)
    local targetPosition = headPos + Vector3.new(1, hrpToFeet + safeHeight, 1)        
    hrp.CFrame = CFrame.new(targetPosition)

    local stillTarget = false
    for _, target in pairs(targetOreList) do
        if not rock  then return end
        if (target == rock.Parent.Name) then
            stillTarget = true
            break;
        end
    end   
    if not rock.Parent or not rock.Parent:FindFirstChild("infoFrame") then return end
    local hp = rock.Parent.infoFrame.Frame.rockHP
    
    local alive = true
    local name = rock.Parent.Name
    local connection 
    connection = hp:GetPropertyChangedSignal("Text"):Connect(function()
        if string.sub(hp.Text, 1, 1) == "0" then
            alive = false
            connection:Disconnect()
        end
    end)
    while isFarm and stillTarget and alive do
        hrp.CFrame = CFrame.new(targetPosition)
        if not hrp then 
            task.wait()
            continue
        end
        if getDistance(hrp, rock) > distance then 
            return
        end
        stillTarget = false
        for _, target in pairs(targetOreList) do
            if not rock.Parent or not rock then return end
            if (target == name) then
                stillTarget = true
                break;
            end
        end
        task.wait()
    end
end
local function checkOre()
    local Rock = getAllDescendants(workspace.Rocks)

    for _, rock in pairs(Rock) do
        if rock.Name == "Hitbox" then
            if not rock then 
                task.wait()
                continue 
            end

            local hitbox = rock.Parent
            if not hitbox then 
                task.wait()
                continue 
            end
            local name = hitbox.Name
            if not hrp or not name then 
                task.wait()
                continue
            end
            local dis = getDistance(hrp, rock)
            if dis >= distance then continue end

            for _, target in ipairs(targetOreList) do
                if (target == name) then
                    mine(rock)
                end
            end
        end
    end
end
local function autoMine()
    while isFarm do
        checkOre()
        task.wait()
    end
end
-- KKill
local function resetMonsterList()
    local Monster = workspace.Living:GetChildren()
    local nameSet = {}           -- helper table for checking duplicates
    table.clear(nameMonsterList)
    table.clear(monsterList)

    for _, monster in pairs(Monster) do
        if not Players:FindFirstChild(monster.Name) then
            local nameText = monster.Name
            nameText = string.gsub(nameText, "%d", "")
            monster = monster:FindFirstChild("HumanoidRootPart")
            
            if getDistance(hrp, monster) >= distance then continue end
            
            if not nameSet[nameText] then
                table.insert(monsterList, nameText)
                nameSet[nameText] = true
                table.insert(nameMonsterList, nameText)
            end
        end
    end
end
local function kill(monster)
    warn("im here")
    local name = monster.Name
    name = string.gsub(name, "%d", "")
    local status = monster:FindFirstChild("Status")
    monster = monster:FindFirstChild("HumanoidRootPart")
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = 0
    local xy = 1
    local targetPosition = getPosition(monster) + Vector3.new(xy, hrpToFeet + safeHeight, xy)        
    hrp.CFrame = CFrame.new(targetPosition)
    
    local stillTarget = false
    for _, target in pairs(targetMonsterList) do
        if not monster  then return end
        if (target == name ) then
            stillTarget = true
            break;
        end
    end   
    
    local alive = true
    
    
    if not status then return end
    while isKill and stillTarget and alive and monster and monster.Parent do
        hrp.CFrame = CFrame.new(targetPosition)
        if not hrp then 
            task.wait()
            continue
        end
        if getDistance(hrp, monster) > distance then 
            return
        end
        stillTarget = false
        for _, target in pairs(targetMonsterList) do
            if not monster then return end
            if (target == name) then
                stillTarget = true
                break;
            end
        end
        targetPosition = getPosition(monster) + Vector3.new(xy, hrpToFeet + safeHeight, xy)   
        hrp.CFrame = CFrame.new(targetPosition)
        if status:FindFirstChild("Dead") then alive = false end
        task.wait()
    end
end
local function checkKill()
    local Monster = workspace.Living:GetChildren()
    for _, monster in pairs(Monster) do
        if not Players:FindFirstChild(monster.Name) then
            local hitBox = monster:FindFirstChild("HumanoidRootPart")
            if not monster or not hitBox then continue end
            local name = monster.Name
            name = string.gsub(name, "%d", "")
            if not hrp or not name then 
                task.wait()
                continue
            end
            local dis = getDistance(hrp, hitBox)
            if dis >= distance then continue end

            for _, target in ipairs(targetMonsterList) do
                if (target == name) then
                    local status = monster:FindFirstChild("Status")
                    if status:FindFirstChild("Dead") then continue end
                    kill(monster)
                end
            end
        end
    end
end
local function autoKill()
    while isKill do
        checkKill()
        task.wait()
    end
end
-- SSell
local function teleSell()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Dialogue = ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService.RF.Dialogue -- RemoteFunction 
    local GreedyCey = workspace.Proximity["Greedy Cey"]
    Dialogue:InvokeServer(
        GreedyCey
    )
end
local function scanOreChances()
    local results = {}
    for _, category in ipairs(OreFolder:GetChildren()) do
        if category:IsA("Folder") then
            for _, module in ipairs(category:GetChildren()) do
                if module:IsA("ModuleScript") then
                    local ok, data = pcall(require, module)
                    if ok and type(data) == "table" then
                        if data.Chance ~= nil then
                            results[module.Name] = {
                                Chance = data.Chance,
                                Category = category.Name
                            }
                        end
                    end
                end
            end
        end
    end
    return results
end
local chanceOreList = scanOreChances()
task.spawn(function()
    teleSell()
    local Ore = game:GetService("Players").LocalPlayer.PlayerGui.Forge.OreSelect.OresFrame.Frame.Background:GetChildren()
    while true do
    for _, ore in pairs(Ore) do
        if ore.Name and chanceOreList[ore.Name] and chanceOreList[ore.Name].Chance <= autoSellRarity then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local RunCommand = ReplicatedStorage.Shared.Packages.Knit.Services.DialogueService.RF.RunCommand -- RemoteFunction 
            warn("sell")
            RunCommand:InvokeServer(
                "SellConfirm",
                {
                    Basket = {
                        [ore.Name] = 1,
                    }
                }
            )
        end
    end
    task.wait(1)
   end
end)

-- TTeleport
local function teleportToNPC(npcTarget)
    for _, npc1 in pairs(workspace.Proximity:GetChildren()) do
        if (npc1.Name == npcTarget) then
            local addHeight = 2
            local targetPosition = getPosition(npc1) + Vector3.new(0, 2 , 0)        
            hrp.CFrame = CFrame.new(targetPosition)
        end
    end
end
--MMore
task.spawn(function()
    while true do
        --warn(humanoid.WalkSpeed)
        --humanoid.WalkSpeed = playerSpeed
        --warn(humanoid.WalkSpeed)
        task.wait(2)
    end
end)


local Window = Fluent:CreateWindow({
    Title = "Tiger HUB | The Forge | Version: 1.2 | Auto Sell Ores",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local tabs = {
        Mine = Window:AddTab({ Title = "Mining", Icon = "pickaxe" }),
        Kill = Window:AddTab({ Title = "Killing", Icon = "swords" }),
        Sell = Window:AddTab({ Title = "Auto Sell", Icon = "dollar-sign" }),
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "rabbit" }),
        More = Window:AddTab({ Title = "Mores", Icon = "rabbit" }),
        Settings = Window:AddTab({ Title = "Player Config", Icon = "user-cog" })
    }
    
local option1 = Fluent.Options
do
    -- MMine
    local MultiDropdownOre = tabs.Mine:AddDropdown("MultiDropdownOre", {
        Title = "Select Ores",
        Description = "",
        Values = {},
        Multi = true,
        Default = {},
    })
    MultiDropdownOre:OnChanged(function(selectedValues)
        table.clear(targetOreList)

        for name, state in pairs(selectedValues) do
            if state then
                table.insert(targetOreList, name)
            end
        end        
    end)

    local resetButton = tabs.Mine:AddButton({
        Title = "Reset Rocks List",
        Description = "",
        Callback = function() 
            MultiDropdownOre:SetValue({})
            resetRockList() 
            MultiDropdownOre:SetValues(nameOreList)
            Library:SaveConfig("TigerHubForge/oreList.json", nameOreList)
        end
    })
    MultiDropdownOre:SetValues(nameOreList)

    local toogleFarm = tabs.Mine:AddToggle("toogleFarm", {Title = "Auto TP to Selected Rock", Default = false})
    toogleFarm:OnChanged(function()
        isFarm = toogleFarm.Value
        if (toogleFarm.Value) then
            task.spawn(function() 
                autoMine()
            end)
        end
    end)
    local toogleMine = tabs.Mine:AddToggle("toogleFarm", {Title = "Auto Mining", Default = false})
    toogleMine:OnChanged(function()
        isMine = toogleMine.Value
    end)
    -- KKill
    local MultiDropdownMonster = tabs.Kill:AddDropdown("MultiDropdownMonster", {
        Title = "Select Monster",
        Description = "",
        Values = {},
        Multi = true,
        Default = {},
    })
    MultiDropdownMonster:OnChanged(function(selectedValues)
        table.clear(targetMonsterList)

        for name, state in pairs(selectedValues) do
            if state then
                table.insert(targetMonsterList, name)
            end
        end        
    end)

    local resetButton = tabs.Kill:AddButton({
        Title = "Reset Monster List",
        Description = "",
        Callback = function() 
            MultiDropdownMonster:SetValue({})
            resetMonsterList() 
            MultiDropdownMonster:SetValues(nameMonsterList)
            Library:SaveConfig("TigerHubForge/monsterList.json", nameMonsterList)
        end
    })
    MultiDropdownMonster:SetValues(nameMonsterList)

    
    local toogleKill = tabs.Kill:AddToggle("toogleKill", {Title = "Auto TP to Selected Monster", Default = false})
    toogleKill:OnChanged(function()
        isKill = toogleKill.Value
        if (toogleKill.Value) then
            task.spawn(function() 
                autoKill()
            end)
        end
    end)
    local toogleSwing = tabs.Kill:AddToggle("toogleSwing", {Title = "Auto Swing", Default = false})
    toogleSwing:OnChanged(function()
        isSwing = toogleSwing.Value
    end)
    -- AA SSell
    local inputAutoSell = tabs.Sell:AddInput("inputAutoSell", {
        Title = "Sell ALL Ores under this chance",
        Default = 0,
        Placeholder = "A number",
        Numeric = true, -- Only allows numbers
        Finished = true, -- Only calls callback when you press enter
        Callback = function(Value)
        end
    })

    inputAutoSell:OnChanged(function()
        if inputAutoSell.Value ~= "" then
            autoSellRarity = tonumber(inputAutoSell.Value)
        end
    end)
    -- TTeleport
    for _, npc1 in pairs(workspace.Proximity:GetChildren()) do
        for _, npc2 in pairs(goodNPC) do
            if string.find(npc1.Name, npc2) then
                buttonNPC[npc1.Name] = tabs.Teleport:AddButton({
                    Title = npc1.Name,
                    Description = "",
                    Callback = function() 
                        teleportToNPC(npc1.Name)
                    end
                })
            end
        end
    end
    local sectiontp = tabs.Teleport:AddSection("ALL NPC on MAP")
    for _, npc1 in pairs(workspace.Proximity:GetChildren()) do
        local ok = true
        for _, npc2 in pairs(goodNPC) do
            if string.find(npc1.Name, npc2) or string.find(npc1.Name, "Pickaxe") or string.find(npc1.Name, "Potion") then
                ok = false
                break;
            end
        end
        if ok == false then continue end
        buttonNPC[npc1.Name] = tabs.Teleport:AddButton({
            Title = npc1.Name,
            Description = "",
            Callback = function() 
                teleportToNPC(npc1.Name)
            end
        })
    end    
    -- mmore
    local SellButton = tabs.More:AddButton({
        Title = "Sell Ore",
        Description = "",
        Callback = function() 
            teleSell()
        end
    })
    local fpsBoost =  tabs.More:AddToggle("fpsBoost", {Title = "Reduce Lag/ FPS Boost", Default = false})
    fpsBoost:OnChanged(function()
        if fpsBoost.Value then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/khuyenbd8bb/RobloxKaitun/refs/heads/main/FPS%20Booster.lua"))()
        end
    end)
    
    function Parent(GUI)
            if syn and syn.protect_gui then
                syn.protect_gui(GUI)
                GUI.Parent = game:GetService("CoreGui")
            elseif PROTOSMASHER_LOADED then
                GUI.Parent = get_hidden_gui()
            else
                GUI.Parent = game:GetService("CoreGui")
            end
        end

        local ScreenGui = Instance.new("ScreenGui")
        Parent(ScreenGui)

        local CopyScriptPath = Instance.new("TextButton")
        CopyScriptPath.Name = ""
        CopyScriptPath.Parent = ScreenGui -- ⭐ MUST be parented to something visible
        CopyScriptPath.BackgroundColor3 = Color3.new(0.000000, 0.000000, 0.000000)
        CopyScriptPath.Position = UDim2.new(0, -25, 0, 20)
        CopyScriptPath.Size = UDim2.new(0, 50, 0, 50)
        CopyScriptPath.ZIndex = 15
        CopyScriptPath.Font = Enum.Font.SourceSans
        CopyScriptPath.Text = ""
        CopyScriptPath.TextColor3 = Color3.fromRGB(250, 251, 255)
        CopyScriptPath.TextSize = 16
        CopyScriptPath.BorderSizePixel = 2
        CopyScriptPath.BorderColor3 = Color3.new(1.000000, 1.000000, 1.000000)

        CopyScriptPath.MouseButton1Click:Connect(function()
            Window:Minimize()
        end)

        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)

        -- Ignore keys that are used by ThemeManager.
        -- (we dont want configs to save themes, do we?)
        SaveManager:IgnoreThemeSettings()

        -- You can add indexes of elements the save manager should ignore
        SaveManager:SetIgnoreIndexes({})

        -- use case for doing it this way:
        -- a script hub could have themes in a global folder
        -- and game configs in a separate folder per game
        InterfaceManager:SetFolder("TigerHubConfig")
        SaveManager:SetFolder("TigerHubConfig/Forge")

        InterfaceManager:BuildInterfaceSection(tabs.Settings)
        SaveManager:BuildConfigSection(tabs.Settings)


        Window:SelectTab(1)

        -- You can use the SaveManager:LoadAutoloadConfig() to load a config
        -- which has been marked to be one that auto loads!
        SaveManager:LoadAutoloadConfig()
        tabs.Settings:AddSection("Only work with lastest config")
end
    
end
