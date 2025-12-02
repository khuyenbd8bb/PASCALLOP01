if game.PlaceId == 105716258039711 then
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua"))()
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
local hrp = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid")
local spawnPad = nil
task.spawn(function()
    while true do
        if spawnPad and spawnPad.Parent then 
            task.wait(1)
            continue
        end
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant.Name == "Spawn" and descendant:IsA("BasePart") and descendant.Parent and descendant.Parent:IsA("Folder") then
                spawnPad = descendant
                break
            end
        end
        task.wait()
    end
end)
--MMain
local HatchGui = game:GetService("Players").LocalPlayer.PlayerGui
local distance = 10000
local farm2Delay = 0.1
local dontTeleport
local gachaZone
local attackRange = 5
local inGamemode
-- FFarm
local monsterList = {};local nameList = {};local targetList = {}
local isAutoJoinRaid = false; 
local locationList = {}; local locationNumber = {}; 
local locationTargetList = {}
local isTeleportFarm = false
--Boss
local toogleBoss = {}; local bossList = {};
-- DDungeon, Raid, Trial
local trialGui = game:GetService("Players").LocalPlayer.PlayerGui.Interface.HUD.Gamemodes.TrialEasy.Background.Wave
local waveRaid = 0;local waveDungeon = 0; local waveDef = 0; local waveTrial = 0;
local targetWaveRaid = 500; local targetWaveDef = 500; 
local targetWaveDungeon = 500; local targetWaveTrial = 500;
local trialList = {}; local targetTrial = {};
local isTrial = false
-- PPowers
local powerList = {}; local tooglePower = {};
--SStronger
local isAutoClaimExpedition = false;
local toogleStar = {}
local targetStar; local expeditionTarget;
local teleportBackMap = "None";  
local isTele = false
local repeatTime = 1
local isHatch = false
local isFarm1 = false
local isFarm2 = false
local isRankUp = false
local currentTime = os.date("*t") -- Use os.date() not os.time()
local isAutoAttack = false
--WWaveGui

trialGui:GetPropertyChangedSignal("Text"):Connect(function()
    waveTrial = tonumber((string.gsub(trialGui.Text, "Wave ", "")))
    warn(waveTrial)
end)
--table
table.insert(powerList, {name = "Hero Rank", auto = false})
table.insert(powerList, {name = "Ninja Rank", auto = false})
table.insert(powerList, {name = "Haki", auto = false})
table.insert(powerList, {name = "Passive", auto = false})
table.insert(powerList, {name = "Clan", auto = false})

bossList = {
    {name = "Sea King", map = "XYZ Metropolis", kill = false},
    {name = "Cosmic Garo", map = "XYZ Metropolis", kill = false},
    {name = "Itachu", map = "Ninja Village", kill = false},
    {name = "Nanko", map = "Ninja Village", kill = false},
    {name = "Luciu", map = "Forgotten Shore", kill = false},
    {name = "Hawkeye", map = "Forgotten Shore", kill = false},
    {name = "Hantengo", map = "Slayer Forest", kill = false},
    {name = "Kokushibe", map = "Slayer Forest", kill = false}
}
-- TTrial
trialList = {
    {name = "TrialEasy", time = 15}
}
-- Anti rejoin/ AFK
local GC = getconnections or get_signal_cons
if GC then
    for i,v in pairs(GC(Players.LocalPlayer.Idled)) do
        if v["Disable"] then
            v["Disable"](v)
        elseif v["Disconnect"] then
            v["Disconnect"](v)
        end
    end
else
    Players.LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
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
        
        local attackRangePart =  workspace.Cache:FindFirstChild("Area")
        if not attackRangePart  then 
            task.wait(1)
            continue
        end
        attackRange = attackRangePart.Size.X/2-5
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
    warn("TELE")
    task.wait(6)
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
    
        while inGamemode and bossList[index].kill do
            if head.Transparency ~= 0 then break end
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
    if not message or foundBoss(message.Text) == false or isBoss then return end
    inGamemode = true
    task.wait(0.5)
    local boss = foundBoss(message.Text)
    teleportToMap(bossList[boss].map)
    killBoss(bossList[boss].name, boss)
    teleportToMap(teleportBackMap)
    inGamemode = false
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
    while isFarm1 and stillTarget and inGamemode == false do
        if head.Transparency ~= 0 then break end
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
    local headPos = getPosition(head)
    local targetPosition = headPos + Vector3.new(5, hrpToFeet + safeHeight, 5)        
    hrp.CFrame = CFrame.new(targetPosition)

    task.wait(farm2Delay)
end

local function check()
    local monsters = workspace.Client.Enemies:GetChildren()
    for _, monster in pairs(monsters) do
        if not isFarm1 and not isFarm2 then break end
        if inGamemode then break end
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
                if inGamemode then break end
                if isFarm1 then kill(monster) end
                if isFarm2 then kill2(monster) end
                break
            end
        end
    end
end
task.spawn(function()
    while true do
        if (isFarm1 == false and isFarm2 == false) or inGamemode or isTele == true then 
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
            if inGamemode or isTele then return end 
            hrp.CFrame = CFrame.new(targetPosition)
            break
        end
    end
    task.wait(repeatTime)
end

local function autoTeleportFarm()
    while isTeleportFarm do
        if inGamemode or isTele then 
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
            task.wait(0.5)
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
    while isTrial and isTele == false and inGamemode do
        if waveTrial > targetWaveTrial then return end
        hrp.CFrame = CFrame.new(targetPosition)
        if not hrp then 
            task.wait()
            continue
        end
        if not head or head.Transparency ~= 0 or getDistance(hrp, monster) > distance then return end
        task.wait()
    end
end

local function checkTrial(trial) 
    while waveDungeon <= targetWaveDungeon 
     and waveRaid <= targetWaveRaid 
     and waveDef <= targetWaveDef 
     and waveTrial <= targetWaveTrial and
     isTele == false and inGamemode do 
        local monsters = workspace.Client.Enemies:GetChildren()
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
            if not inGamemode or isTele then break end
            if waveTrial > targetWaveTrial then return end
            task.wait()
        end
        if spawnPad and spawnPad.Parent and spawnPad.Parent.Name ~= "Trial Lobby" then
            return
        end
        if spawnPad and spawnPad.Parent and getDistance(hrp, spawnPad) <= 10 then
            return
        end
    task.wait()
    end
end
local function joinDungeon()
    local isTargetTrial = false
    currentTime = os.date("*t")
    for i, trial in pairs(trialList) do
        if trialList[i].time == currentTime.min or trialList[i].time + 30 == currentTime.min then 
            isTargetTrial = trial.name
            break
        end
    end
    if spawnPad and spawnPad.Parent and spawnPad.Parent.Name == "Trial Lobby" then
        inGamemode = true
        task.wait(1)
        checkTrial(isTargetTrial)
        task.wait(3)
        teleportToMap(teleportBackMap)
        inGamemode = false
        return
    end
    if not isTargetTrial then return end
    inGamemode = true
    task.wait(1)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local dataRemoteEvent = ReplicatedStorage.BridgeNet2.dataRemoteEvent -- RemoteEvent 
    dataRemoteEvent:FireServer(
        {
            {
                "Gamemodes",
                isTargetTrial,
                "Join",
                n = 3
            },
            "\2"
        }
    )
    task.wait(4)
    checkTrial(isTargetTrial)
    task.wait(3)
    teleportToMap(teleportBackMap)
    inGamemode = false
end
local function autoFarmDungeon()
    while (isTrial) do
        if inGamemode then 
            task.wait()
            continue
        end
        waveTrial = 0
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
        Title = "Tiger HUB | Anime Advance Simulator | Version: 3 | Trial",
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
        Teleport = Window:AddTab({ Title = "Teleport Pannel", Icon = "swords" }),
        Boss = Window:AddTab({ Title = "Boss", Icon = "swords" }),
        Trial = Window:AddTab({ Title = "Trial", Icon = "skull" }),
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

        -- TTeleport
        local teleportBackMapDropdown = tabs.Teleport:AddDropdown("teleportBackMapDropdown", {
            Title = "Auto Teleport to Map",
            Description = "After boss and all Gamemode",
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
            teleportBackMapDropdown:SetValues(res)
        end)
        teleportBackMapDropdown:OnChanged(function(selectedValues)
            teleportBackMap = selectedValues
        end)
        -- BBoss
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
        --TTrial
        local trialDropdown = tabs.Trial:AddDropdown("trialDropdown", {
            Title = "Trial Selection",
            Description = "Select Trial mode",
            Values = {},
            Multi = true,
            Default = {},
        })
        task.spawn(function()
            local res = {}
            for _, trial in pairs(trialList) do
                table.insert(res, trial.name)
            end
            trialDropdown:SetValues(res)
        end)
        trialDropdown:OnChanged(function(selectedValues)
            table.clear(targetTrial)
            for _, trialName in ipairs(selectedValues) do
                table.insert(targetTrial, trialName)
            end
        end)

        local inputTrialTarget = tabs.Trial:AddInput("inputTrialTarget", {
            Title = "Trial Target Wave",
            Description = "Leave after done this wave",
            Default = 500,
            Placeholder = "Placeholder",
            Numeric = true, -- Only allows numbers
            Finished = true, -- Only calls callback when you press enter
            Callback = function(Value)
            end
        })
        inputTrialTarget:OnChanged(function()
            if inputTrialTarget.Value == nil or inputTrialTarget.Value == "" then
                targetWaveTrial = 100 else
                targetWaveTrial = tonumber(inputTrialTarget.Value)
            end
        end)

        local toogleAutoTrial = tabs.Trial:AddToggle("toogleAutoTrial", {Title = "Auto Farm Trial", Default = false})
        toogleAutoTrial:OnChanged(function()
            isTrial = toogleAutoTrial.Value
            task.spawn(function() autoFarmDungeon() end)
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
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("TigerHubConfig")
        SaveManager:SetFolder("TigerHubConfig/AnimeAdvance")
        InterfaceManager:BuildInterfaceSection(tabs.Settings)
        SaveManager:BuildConfigSection(tabs.Settings)
        Window:SelectTab(1)
        SaveManager:LoadAutoloadConfig()
        tabs.Settings:AddSection("Only work with lastest config")
    end
end
