

if game.PlaceId == 105716258039711 then
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua"))()
local TextChatService = game:GetService("TextChatService")
local HatchGui = game:GetService("Players").LocalPlayer.PlayerGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
local hrp = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid")


local distance = 700
local farm2Delay = 0.1
local waveGui = game:GetService("Players").LocalPlayer.PlayerGui
local roomGui = game:GetService("Players").LocalPlayer.PlayerGui
local defGui = game:GetService("Players").LocalPlayer.PlayerGui

local waveRaid = 0;local waveDungeon = 0; local waveDef = 0;
local targetWaveRaid = 500; local targetWaveDef = 500; local targetWaveDungeon = 500;

local gachaZone
local attackRangePart 
local attackRange 

local monsterList = {} -- Name, HumanoidRoot
local nameList = {} -- Table HUB
local targetList = {}
local dungeonList = {};   local raidList = {}; local defList = {}; 
local targetDungeon = {}; local targetRaid = {}; local targetDef = {};
local dungeonNumber = {}; local raidNumber = {}; local defNumber = {};
local dungeonTime  =  {}; local raidTime  =  {}; local defTime = {};
local powerList = {}; 
local tooglePower = {}
local teleportBackMap = "None"; 

local repeatTime = 1
local locationList = {}; local locationNumber = {}; 
local locationTargetList = {}
local isTeleportFarm = false
local isTeleportHatch = false

local isHatch = false
local inDungeon = false
local isDungeon = false
local isFarm1 = false
local isFarm2 = false
local isKilling = false
local isRankUp = false
local isFuse = false
local currentTime = os.date("*t") -- Use os.date() not os.time()

local isAutoAttack = false
table.insert(powerList, {name = "Hero Rank", auto = false})
table.insert(powerList, {name = "Ninja Rank", auto = false})
table.insert(powerList, {name = "Haki", auto = false})
table.insert(powerList, {name = "Passive", auto = false})
-- Main


local function setAutoAttack()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
    dataRemoteEvent:FireServer(
        {
            {
                "General",
                "Settings",
                "Update",
                "Auto Click",
                isAutoAttack,
                n = 20
            },
            "\2"
        }
    )
    dataRemoteEvent:FireServer(
        {
            {
                "General",
                "Settings",
                "Update",
                "Auto Attack",
                isAutoAttack,
                n = 20
            },
            "\2"
        }
    )
end
task.spawn(function()
    while true do
        attackRangePart =  workspace.Cache:FindFirstChild("Area")
        if not attackRangePart  then 
            task.wait(1)
            continue
        end
        attackRange = attackRangePart.Size.X/2
        task.wait(1)
    end
end)

player.CharacterAdded:Connect(function(character)
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    print("Character updated!")
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


local function loadData()
    local ok = true
    if not isfolder("TigerHubAA") or not isfile("TigerHubAA/monsterList.json") then
        makefolder("TigerHubAA")
        writefile("TigerHubAA/monsterList.json", "[]") -- Changed from {} to [] for array
        ok = false
    end
    
    if not isfolder("TigerHubAA") or not isfile("TigerHubAA/locationList.json") then
        makefolder("TigerHubAA")
        writefile("TigerHubAA/locationList.json", "[]") -- Changed from {} to [] for array
        ok = false
    end
    if not ok then return end
    -- Read the file content first, then decode it
    local monsterJsonContent = readfile("TigerHubAA/monsterList.json")
    local monsterTable = Library.Decode(monsterJsonContent)
    
    nameList = monsterTable

    monsterJsonContent = readfile("TigerHubAA/locationList.json")
    monsterTable = Library.Decode(monsterJsonContent)
    locationList = monsterTable

    for i, locationObj in ipairs(monsterTable) do
        -- Extract the number
        table.insert(locationNumber, locationObj.number)
        
        -- Convert the pos string to Vector3
        local posString = locationObj.pos
        local x, y, z = posString:match("Vector3_%(([%d%.%-]+),%s*([%d%.%-]+),%s*([%d%.%-]+)%)")
        
        if x and y and z then
            locationList[i] = {
                number = locationObj.number,
                pos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
            }
        end
    end

end
--FFarm
local function resetEnemiesList()
    local monsters = workspace.Client.Enemies:GetChildren()
    local nameSet = {}           -- helper table for checking duplicates
    table.clear(nameList)
    table.clear(monsterList)

    for _, monster in pairs(monsters) do
        
        if monster.Name == "" or not monster.Name then 
            task.wait()
            continue 
        end
        local nameText = monster.Name
        
        if monster.Head.Transparency ~= 0 then continue end
        if getDistance(hrp, monster.HumanoidRootPart) >= distance then continue end

        if not nameSet[nameText] then
            table.insert(monsterList, nameText)
            nameSet[nameText] = true
            table.insert(nameList, nameText)
        end
    end
end
local function kill(monster)
    local head = monster:FindFirstChild("Head")
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -2
    --local alive = head.Transparency
    if inDungeon then 
        isKilling = false
        return
    end
    local headPos = getPosition(head)
    local targetPosition = headPos + Vector3.new(5, hrpToFeet + safeHeight, 5)        
    hrp.CFrame = CFrame.new(targetPosition)

    local stillTarget = false
    for _, target in pairs(targetList) do
        if not monster or not monster.Name then return end
        if (target == monster.Name) then
            stillTarget = true
            break;
        end
    end   
    local alive = true
    local connection 
    connection = head:GetPropertyChangedSignal("Transparency"):Connect(function()
        alive = false
        connection:Disconnect()
    end)
    while isFarm1 and stillTarget  and alive do
        hrp.CFrame = CFrame.new(targetPosition)
        if not hrp then 
            task.wait()
            continue
        end
        if getDistance(hrp, monster) > distance then 
            return
        end
        stillTarget = false
        if inDungeon then 
            isKilling = false
            return
        end
        for _, target in pairs(targetList) do
            if not monster.Parent or not monster then return end
            if monster.Name == "" then return end
            if (target == monster.Name) then
                stillTarget = true
                break;
            end
        end
        task.wait()
    end
end
local function kill2(monster)
    warn("heree")
    local head = monster:FindFirstChild("Head")
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -2
    --local alive = head.Transparency
    if inDungeon then 
        isKilling = false
        return
    end
    local headPos = getPosition(head)
    local targetPosition = headPos + Vector3.new(5, hrpToFeet + safeHeight, 5)        
    hrp.CFrame = CFrame.new(targetPosition)

    task.wait(farm2Delay)
end

local function check()
    local monsters = workspace.Client.Enemies:GetChildren()
    for _, monster in pairs(monsters) do
        if not isFarm1 and not isFarm2 then break end
        if not monster:FindFirstChild("Head") then return end
        local Head = monster.Head
        if Head.Transparency ~= 0 then continue end
        if not hrp then 
            task.wait()
            continue
        end
        local dis = getDistance(hrp, monster)
        if dis >= distance or dis <= attackRange then continue end

        if not monster then continue end
        if monster.Name == "" or not monster.Name then 
            task.wait()
            continue
        end
        local nameText = monster.Name

        for _, target in ipairs(targetList) do
            if (target == nameText) then
                warn(isFarm1, isFarm2)
                if isFarm1 then kill(monster) end
                warn(1)
                if isFarm2 then kill2(monster) end
                break
            end
        end
    end
end
task.spawn(function()
    while true do
        if inDungeon or (isFarm1 == false and isFarm2 == false) then 
            task.wait()
            continue
        end
        check() 
        task.wait()
    end
end)
-- LLocation 
local function teleportTo(target)
    for _, location in ipairs(locationList) do
        if (location.number == target) then
            
            local Pos = location.pos
            if (getPosition(hrp) - Pos).Magnitude  > distance then return end
            
            local targetPosition = Pos        
            if inDungeon then return end 
            hrp.CFrame = CFrame.new(targetPosition)
            break
        end
    end
    task.wait(repeatTime)
end

local function autoTeleportFarm()
    while isTeleportFarm do
        if inDungeon then 
            task.wait()
            continue 
        end
        for _, location in ipairs(locationTargetList) do
            teleportTo(location)
        end

        task.wait()
    end
end
local function addLocation()
    local Position = hrp.Position
    local size = #locationList
    size = "Location #" .. tostring(size + 1)
    table.insert(locationList, {number = size, pos = Position})
end
-- PPower
local function changePower(name, value)
    for _, power in pairs(powerList) do
        if power.name == name then 
            power.auto = value
            return
        end
    end
end
task.spawn(function()
    while true do
        for _, power in pairs(powerList) do
            if power.auto == false then 
                task.wait()
                continue
            end
            local name = power.name
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
            dataRemoteEvent:FireServer(
                {
                    {
                        "General",
                        "Gacha",
                        "Roll",
                        name,
                        {},
                        n = 10
                    },
                    "\2"
                }
            )
        end
        task.wait()
    end
end)
-- SStronger
local function autoHatch()
    while isHatch do
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
        dataRemoteEvent:FireServer(
            {
                {
                    "General",
                    "Stars",
                    "Open",
                    "XYZ Metropolis",
                    10,
                    n = 10
                },
                "\2"
            }
        )
        task.wait()
    end
end
local function autoFuse()
end
local function autoRankUp()
    while isRankUp do
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
        dataRemoteEvent:FireServer(
            {
                {
                    "General",
                    "RankUp",
                    "RankUp",
                    n = 10
                },
                "\2"
            }
        )
        task.wait(10)
    end

end
-- GGUI
    
    local Window = Fluent:CreateWindow({
        Title = "Tiger HUB | Anime Advance Simulator | Version: 1 | Functions",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
    })

    TextChatService.MessageReceived:Connect(function(message)
        if not message or not message.TextSource then return end
        if not (message.TextSource.Name == player.Name) then return end
        if #message.Text == 1 then 
            Window:Minimize()
        end
    end)
    
    local tabs = {
        Main = Window:AddTab({ Title = "Farm", Icon = "swords" }),
        Farm2 = Window:AddTab({ Title = "Location Farm", Icon = "swords" }),
        Power = Window:AddTab({ Title = "Auto Powers", Icon = "flame" }),
        Dungeon = Window:AddTab({ Title = "Dungeons/ Raids", Icon = "skull" }),
        Stronger = Window:AddTab({ Title = "Auto Stronger", Icon = "flame" }),
        Settings = Window:AddTab({ Title = "Player Config", Icon = "user-cog" })
    }
    
    local option1 = Fluent.Options
    do
        loadData()
        
        local MultiDropdown = tabs.Main:AddDropdown("MultiDropdown", {
            Title = "Select Enemies",
            Description = "",
            Values = {},
            Multi = true,
            Default = {},
        })
        MultiDropdown:OnChanged(function(selectedValues)
            table.clear(targetList)

            for name, state in pairs(selectedValues) do
                if state then
                    table.insert(targetList, name)
                end
            end        
        end)

        local resetButton = tabs.Main:AddButton({
            Title = "Reset Enemies",
            Description = "Always Reset Enemies after change map",
            Callback = function() 
                MultiDropdown:SetValue({})
                resetEnemiesList() 
                MultiDropdown:SetValues(nameList)
                Library:SaveConfig("TigerHub/monsterList.json", nameList)
            end
        })
        MultiDropdown:SetValues(nameList)

        
        local toogleFarm1 = tabs.Main:AddToggle("toogleFarm1", {Title = "1Auto kill selected enemies", Default = false, Description = "",})
        toogleFarm1:OnChanged(function()
            isFarm1 = toogleFarm1.Value

        end)
        local section1 = tabs.Main:AddSection("If u can 1 hit that enemie use this")
        local toogleFarm2 = tabs.Main:AddToggle("toogleFarm2", {Title = "2Auto kill selected enemies", Default = false, Description = "ONLY WORK WITH INSTANT KILL",})
        toogleFarm2:OnChanged(function()
            isFarm2 = toogleFarm2.Value
            warn(isFarm2)
        end)
        local teleportFarmSpeed = tabs.Main:AddInput("teleportFarmSpeed", {
            Title = "Teleport Delay (Seconds)",
            Default = 0.5,
            Placeholder = "Placeholder",
            Numeric = true, -- Only allows numbers
            Finished = false, -- Only calls callback when you press enter
            Callback = function(Value)
            end
        })

        teleportFarmSpeed:OnChanged(function()
            if teleportFarmSpeed.Value == nil or teleportFarmSpeed.Value == "" then
                farm2Delay = 0.5 else
                farm2Delay = math.max(teleportFarmSpeed.Value, 0.3
                )
            end
        end)
        -- LLocation FFarm
        local locationDropdown = tabs.Farm2:AddDropdown("locationDropdown", {
            Title = "Location Selection",
            Description = "Select Location to teleport",
            Values = {},
            Multi = true,
            Default = {},
        })
        
        locationDropdown:OnChanged(function(selectedValues)
            table.clear(locationTargetList)

            for number, state in pairs(selectedValues) do
                if state then
                    table.insert(locationTargetList, number)
                end
            end
        end)

        
        local addLocation = tabs.Farm2:AddButton({
            Title = "Add Location to dropdown",
            Description = "your currently position",
            Callback = function() 
                addLocation()
                locationDropdown:SetValue({})
                local list = {}
                for _, location in ipairs(locationList) do
                    table.insert(list, location.number)
                end
                locationDropdown:SetValues(list)
                Library:SaveConfig("TigerHub/locationList.json", locationList)
            end
        })

        locationDropdown:SetValues(locationNumber)
        
        local toogleTeleport = tabs.Farm2:AddToggle("toogleTeleport", {Title = "Auto Teleport accross all ur location", Default = false})
        toogleTeleport:OnChanged(function()
            isTeleportFarm = toogleTeleport.Value
            if (isTeleportFarm) then
                task.spawn(function() 
                    autoTeleportFarm()
                end)
            end
        end)
        
        local teleportSpeed = tabs.Farm2:AddInput("Input", {
            Title = "Teleport Delay (Seconds)",
            Default = 2,
            Placeholder = "Placeholder",
            Numeric = true, -- Only allows numbers
            Finished = false, -- Only calls callback when you press enter
            Callback = function(Value)
            end
        })

        teleportSpeed:OnChanged(function()
            if teleportSpeed.Value == nil or teleportSpeed.Value == "" then
                repeatTime = 1 else
                repeatTime = math.max(teleportSpeed.Value, 0.3)
            end
        end)

        local clearLocation = tabs.Farm2:AddButton({
            Title = "Clear all location",
            Description = "W Farm",
            Callback = function() 
                locationDropdown:SetValues({})
                table.clear(locationList)
            end
        })

        local toogleLocationHatch = tabs.Farm2:AddToggle("toogleLocationHatch", {Title = "Location Gacha", Default = false, Description = "Req(Auto Gacha + Location farm)",})
        toogleLocationHatch:OnChanged(function()
            isTeleportHatch = toogleLocationHatch.Value
        end)
        -- PPower
        for _, power in pairs(powerList) do 
            local name = power.name 
            tooglePower[name] = tabs.Power:AddToggle("toggle"..name, {Title = "Auto "..name, Default = false, Description = "",})
            tooglePower[name]:OnChanged(function()
                changePower(name, tooglePower[name].Value)
            end)
            task.wait()
        end
        --Dungeon
        local dropdownDungeon = tabs.Dungeon:AddDropdown("dropdownDungeon", {
            Title = "Dungeons",
            Description = "Select Dungeon to auto farm",
            Values = {},
            Multi = true,
            Default = {},
        })
        dropdownDungeon:SetValues(dungeonList)

        dropdownDungeon:OnChanged(function(selectedValues)
            table.clear(targetDungeon)

            for name, state in pairs(selectedValues) do
                if state then
                    table.insert(targetDungeon, name)
                end
            end
        end)

        local dropdownRaid = tabs.Dungeon:AddDropdown("dropdownRaid", {
            Title = "Raids",
            Description = "Select Raids to auto farm",
            Values = {},
            Multi = true,
            Default = {},
        })
        dropdownRaid:SetValues(raidList)

        dropdownRaid:OnChanged(function(selectedValues)
            table.clear(targetRaid)

            for name, state in pairs(selectedValues) do
                if state then
                    table.insert(targetRaid, name)
                end
            end
        end)

        local dropdownDef = tabs.Dungeon:AddDropdown("dropdownDef", {
            Title = "Defense",
            Description = "Select Defense Mode to auto farm",
            Values = {},
            Multi = true,
            Default = {},
        })
        dropdownDef:SetValues(defList)

        dropdownDef:OnChanged(function(selectedValues)
            table.clear(targetDef)

            for name, state in pairs(selectedValues) do
                if state then
                    table.insert(targetDef, name)
                end
            end
        end)

        local toogleFarmDungeon = tabs.Dungeon:AddToggle("toogleFarmDungeon", {Title = "Auto Farm Dungeons/ Raids", Default = false})
        toogleFarmDungeon:OnChanged(function()
            isDungeon = toogleFarmDungeon.Value
            if isDungeon then 
                autoFarmDungeon()
            end
        end)

        local teleportBackDropdown = tabs.Dungeon:AddDropdown("teleportBackDropdown", {
            Title = "Auto Teleport to Map",
            Description = "IF NOT IN DUNGEON OR RAID",
            Values = {"None", "Naruto","DragonBall", "OnePiece", "DemonSlayer", "Paradis"},
            Multi = false,
            Default = "None",
        })
        
        teleportBackDropdown:OnChanged(function(selectedValues)
            teleportBackMap = selectedValues
        end)

        local inputTargetWaveRaid = tabs.Dungeon:AddInput("inputTargetWaveRaid", {
            Title = "Target Wave (Raid)",
            Description = "Leave after this wave",
            Default = 500,
            Placeholder = "Placeholder",
            Numeric = true, -- Only allows numbers
            Finished = true, -- Only calls callback when you press enter
            Callback = function(Value)
            end
        })
        inputTargetWaveRaid:OnChanged(function()
            if inputTargetWaveRaid.Value == nil or not inputTargetWaveRaid.Value then
                targetWaveRaid = 100 else
                targetWaveRaid = tonumber(inputTargetWaveRaid.Value)
            end
        end)

        local inputTargetWaveDef = tabs.Dungeon:AddInput("inputTargetWaveDef", {
            Title = "Target Wave (Defense)",
            Description = "Leave after this wave",
            Default = 500,
            Placeholder = "Placeholder",
            Numeric = true, -- Only allows numbers
            Finished = true, -- Only calls callback when you press enter
            Callback = function(Value)
            end
        })
        inputTargetWaveDef:OnChanged(function()
            if inputTargetWaveDef.Value == nil or not inputTargetWaveDef.Value then
                targetWaveDef = 100 else
                targetWaveDef = tonumber(inputTargetWaveDef.Value)
            end
        end)

        -- SStronger
        local toogleAutoAttack = tabs.Stronger:AddToggle("toogleAutoAttack", {Title = "Auto Attack/Grind", Default = false})
        toogleAutoAttack:OnChanged(function()
            isAutoAttack = toogleAutoAttack.Value
            task.spawn(function() 
               setAutoAttack()
            end)
        end)
        local toggleRank = tabs.Stronger:AddToggle("toggleRank", {Title = "Auto RankUp", Default = false})
        toggleRank:OnChanged(function()
            isRankUp = option1.toggleRank.Value
            task.spawn(function() autoRankUp() end)
        end)
        local toggleHatch = tabs.Stronger:AddToggle("toggleHatch", {Title = "Auto Gacha(nearby)", Default = false})
        toggleHatch:OnChanged(function()
            isHatch = option1.toggleHatch.Value
            task.spawn(function() autoHatch() end)
        end)
        -- Player
        local close = tabs.Settings:AddParagraph({
            Title = "chat ONE LETTER on chat -> Gui will show/ hide",
            Content = "Click LeftControl To Hide/ Show Hub"
        })

        local fpsBoost =  tabs.Settings:AddToggle("fpsBoost", {Title = "Reduce Lag/ FPS Boost", Default = false})
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
        SaveManager:SetFolder("TigerHubConfig/AnimeAdvance")

        InterfaceManager:BuildInterfaceSection(tabs.Settings)
        SaveManager:BuildConfigSection(tabs.Settings)


        Window:SelectTab(1)

        -- You can use the SaveManager:LoadAutoloadConfig() to load a config
        -- which has been marked to be one that auto loads!
        SaveManager:LoadAutoloadConfig()
        tabs.Settings:AddSection("Only work with lastest config")
    end
end



--part.CanCollide = false -- Players can walk through
