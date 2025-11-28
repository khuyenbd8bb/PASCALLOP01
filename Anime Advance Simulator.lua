if true then
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


local distance = 1000
local farm2Delay = 0.1
local waveGui = game:GetService("Players").LocalPlayer.PlayerGui.Interface.HUD.Gamemodes.Raid.Background.Wave
local roomGui = game:GetService("Players").LocalPlayer.PlayerGui
local defGui = game:GetService("Players").LocalPlayer.PlayerGui

local waveRaid = 0;local waveDungeon = 0; local waveDef = 0;
local targetWaveRaid = 500; local targetWaveDef = 500; local targetWaveDungeon = 500;

local gachaZone
local attackRangePart 
local attackRange 
local dontTeleport
local monsterList = {} -- Name, HumanoidRoot
local nameList = {} -- Table HUB
local targetList = {}
local dungeonList = {};   local raidList = {}; local defList = {}; 
local targetDungeon = {}; local targetRaid = {}; local targetDef = {};
local dungeonNumber = {}; local raidNumber = {}; local defNumber = {};
local dungeonTime  =  {}; local raidTime  =  {}; local defTime = {};
local isAutoJoinRaid = false; 
local isAutoClaimExpedition = false;
local powerList = {}; 
local tooglePower = {}; local toogleBoss = {}; local toogleStar = {}
local targetStar; local expeditionTarget;
local teleportBackBossMap = "None";  

local isTele = false
local repeatTime = 1
local locationList = {}; local locationNumber = {}; 
local locationTargetList = {}
local isTeleportFarm = false
local isTeleportHatch = false

local isHatch = false
local inDungeon = false --
local isDungeon = false
local isFarm1 = false
local isFarm2 = false
local isRankUp = false
local isFuse = false
local currentTime = os.date("*t") -- Use os.date() not os.time()


local isAutoAttack = false
table.insert(powerList, {name = "Hero Rank", auto = false})
table.insert(powerList, {name = "Ninja Rank", auto = false})
table.insert(powerList, {name = "Haki", auto = false})
table.insert(powerList, {name = "Passive", auto = false})
table.insert(powerList, {name = "Clan", auto = false})

local isBoss = false
local bossList = {
    {name = "Sea King", map = "XYZ Metropolis", kill = false},
    {name = "Cosmic Garou", map = "XYZ Metropolis", kill = false},
    {name = "Itachi", map = "Ninja Village", kill = false},
    {name = "Konan", map = "Ninja Village", kill = false},
    {name = "Robin Lucci", map = "Forgotten Shore", kill = false},
    {name = "Hantengu", map = "Slayer Forest", kill = false}
}

-- Main
task.spawn(function()
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
end)

local VirtualUser = game:GetService('VirtualUser')

game:GetService('Players').LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)


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
-- BBoss
local function teleportToMap(map)
    isTele = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
    dataRemoteEvent:FireServer(
        {
            {
                "Player",
                "Teleport",
                "Teleport",
                map,
                n = 4
            },
            "\2"
        }
    )
    task.wait(3)
    isTele = false
end
local function killBoss(boss, index)
    local Monster =  workspace.Client.Enemies:GetChildren()
    for _, monster in pairs(Monster) do
        if monster.Name ~= boss then  continue end
        local head = monster:FindFirstChild("Head")
        local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
        local safeHeight = -2
    
        local headPos = getPosition(head)
        local targetPosition = headPos + Vector3.new(5, hrpToFeet + safeHeight, 5)        
        hrp.CFrame = CFrame.new(targetPosition)

        local alive = true
        local connection 
        connection = head:GetPropertyChangedSignal("Transparency"):Connect(function()
            alive = false
            connection:Disconnect()
        end)
        while isBoss and  alive and bossList[index].kill do
            hrp.CFrame = CFrame.new(targetPosition)
            if not hrp then 
                task.wait()
                continue
            end
            if getDistance(hrp, monster) > distance then 
                return
            end
            task.wait()
        end
    end
end
local function foundBoss(text) 
    for i, boss in ipairs(bossList) do
        if string.find(text, boss.name) and string.find(text, boss.map) then 
            if boss.kill == true then 
                return i
            end
        end
    end
    return false
end
TextChatService.MessageReceived:Connect(function(message)
    if foundBoss(message.Text) == false then 
        warn(message.Text)
    end
    if not message or foundBoss(message.Text) == false or isBoss then return end
    warn("true")
    isBoss = true
    task.wait(0.5)
    local boss = foundBoss(message.Text)
    teleportToMap(bossList[boss].map)
    killBoss(bossList[boss].name, boss)
    task.wait(3)
    teleportToMap(teleportBackBossMap)
    isBoss = false
end)
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
    local head = monster:FindFirstChild("Head")
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -2
    --local alive = head.Transparency
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
                warn("he")
                if isFarm1 then kill(monster) end
                if isFarm2 then kill2(monster) end
                break
            end
        end
    end
end
task.spawn(function()
    while true do
        if inDungeon or (isFarm1 == false and isFarm2 == false) or isBoss or isTele == true then 
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
            if inDungeon or isBoss then return end 
            hrp.CFrame = CFrame.new(targetPosition)
            break
        end
    end
    task.wait(repeatTime)
end

local function autoTeleportFarm()
    while isTeleportFarm do
        if inDungeon or isBoss or isTele then 
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
-- DDungeon
task.spawn(function()
    while true do
        if isAutoJoinRaid == false then
            task.wait(5)
            continue
        end
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
        dataRemoteEvent:FireServer(
            {
                {
                    "Gamemodes",
                    "Raid",
                    "Join",
                    n = 3
                },
                "\2"
            }
        )
        task.wait(5)
    end
end)
local function killDungeon(monster)
    local head = monster:FindFirstChild("Head")
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -2
    --local alive = head.Transparency
    local headPos = getPosition(head)
    local targetPosition = headPos + Vector3.new(5, hrpToFeet + safeHeight, 5)        

    while isDungeon and isTele == false do
        hrp.CFrame = CFrame.new(targetPosition)
        if not hrp then 
            task.wait()
            continue
        end
        if not head then break end
        if head.Transparency ~= 0 then break end
        if getDistance(hrp, monster) > distance then 
            return
        end
        task.wait()
    end
end

local function checkDungeon() 
    dontTeleport = true
    while waveDungeon <= targetWaveDungeon and inDungeon and isDungeon and waveRaid <= targetWaveRaid and waveDef <= targetWaveDef and isTele == false do 
        local monsters = workspace.Client.Enemies:GetChildren()
        if #monsters == 0 then 
            task.wait()
            continue 
        end
        for _, monster in pairs(monsters) do
            local Head = monster:FindFirstChild("Head")
            if not Head or Head.Transparency ~= 0 then continue end
            if not hrp then 
                task.wait()
                continue
            end
            local dis = getDistance(hrp, monster)
            if dis >= distance or dis <= attackRange then continue end
            killDungeon(monster)
            if not isDungeon or isTele then break end
            task.wait()
        end
    task.wait()
    end
    --if isDungeon and waveRaid > targetWaveRaid or waveDef > targetWaveDef then teleportBack() end
    dontTeleport = false
end

local function joinDungeon()
    inDungeon = true
    checkDungeon()
    inDungeon = false
end
local function autoFarmDungeon()
    while (isDungeon) do
        joinDungeon()
        task.wait(1)    
    end
end
-- SStronger
task.spawn(function()
    while true do
        if targetStar == "None" then
            task.wait(1)
            continue
        end
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
        dataRemoteEvent:FireServer(
            {
                {
                    "General",
                    "Stars",
                    "Open",
                    targetStar,
                    10,
                    n = 10
                },
                "\2"
            }
        )
        task.wait(0.2)
    end
end)
task.spawn(function()
    while true do
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
        if isRankUp == true then
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
        ) end
        if isAutoClaimExpedition == true then
        dataRemoteEvent:FireServer(
            {
                {
                    "General",
                    "HeroesExpedition",
                    "Claim",
                    n = 3
                },
                "\2"
            }
        ) end
        if expeditionTarget ~= "None" then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
            dataRemoteEvent:FireServer(
                {
                    {
                        "General",
                        "HeroesExpedition",
                        "Start",
                        expeditionTarget,
                        n = 4
                    },
                    "\2"
                }
            )

        end
        task.wait(5)
    end
end)
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
        Boss = Window:AddTab({ Title = "Boss", Icon = "swords" }),
        Dungeon = Window:AddTab({ Title = "Raids", Icon = "skull" }),
        Power = Window:AddTab({ Title = "Auto Powers", Icon = "flame" }),
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
                Library:SaveConfig("TigerHubAA/monsterList.json", nameList)
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
                Library:SaveConfig("TigerHubAA/locationList.json", locationList)
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
        -- BBoss
        local teleportBackBossDropdown = tabs.Boss:AddDropdown("teleportBackBossDropdown", {
            Title = "Auto Teleport to Map",
            Description = "After kill boss",
            Values = {},
            Multi = false,
            Default = "None",
        })
        task.spawn(function()
            local nameSet =  {}
            local res = {}
            table.insert(res, "None")
            for _, boss in ipairs(bossList) do
                if nameSet[boss.map] == true then continue end
                table.insert(res, boss.map)
                nameSet[boss.map] = true
            end
            teleportBackBossDropdown:SetValues(res)
        end)
        teleportBackBossDropdown:OnChanged(function(selectedValues)
            teleportBackBossMap = selectedValues
        end)
        local sectionBoss = tabs.Boss:AddSection("Turn on before boss spawn!")
        for _, boss in ipairs(bossList) do 
            toogleBoss[boss.name] = tabs.Boss:AddToggle("toggleBoss"..boss.name, {Title = boss.map .. " " .. boss.name, Default = false, Description = "",})
            toogleBoss[boss.name]:OnChanged(function()
                boss.kill = toogleBoss[boss.name].Value
            end)
            task.wait()
        end
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
        local toogleAutoRaid = tabs.Dungeon:AddToggle("toogleAutoRaid", {Title = "Auto Farm Raid", Default = false})
        toogleAutoRaid:OnChanged(function()
            isDungeon = toogleAutoRaid.Value
        end)


        -- SStronger
        local toggleRank = tabs.Stronger:AddToggle("toggleRank", {Title = "Auto RankUp", Default = false})
        toggleRank:OnChanged(function()
            isRankUp = option1.toggleRank.Value
        end)

        local toogleExpedition = tabs.Stronger:AddToggle("toogleExpedition", {Title = "Auto Claim Heroes Expedition", Default = false})
        toogleExpedition:OnChanged(function()
            isAutoClaimExpedition = option1.toogleExpedition.Value
        end)

        local expeditionDropdown = tabs.Stronger:AddDropdown("expeditionDropdown", {
            Title = "Expedition Map: ",
            Description = "Need to select heroes first",
            Values = {},
            Multi = false,
            Default = "None",
        })
        task.spawn(function()
            local nameSet =  {}
            local res = {}
            table.insert(res, "None")
            for _, boss in ipairs(bossList) do
                if nameSet[boss.map] == true then continue end
                table.insert(res, boss.map)
                nameSet[boss.map] = true
            end
            expeditionDropdown:SetValues(res)
        end)
        expeditionDropdown:OnChanged(function(selectedValues)
            expeditionTarget = selectedValues
        end)

        local starDropdown = tabs.Stronger:AddDropdown("starDropdown", {
            Title = "Auto Hatch (stay nearby star)",
            Description = "Select Star World",
            Values = {},
            Multi = false,
            Default = "None",
        })
        task.spawn(function()
            local nameSet =  {}
            local res = {}
            table.insert(res, "None")
            for _, boss in ipairs(bossList) do
                if nameSet[boss.map] == true then continue end
                table.insert(res, boss.map)
                nameSet[boss.map] = true
            end
            starDropdown:SetValues(res)
        end)
        starDropdown:OnChanged(function(selectedValues)
            targetStar = selectedValues
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
