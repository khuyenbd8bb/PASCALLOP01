if true then 
local Webhook = "https://discord.com/api/webhooks/1443160031775424523/ivqtzsxrV7RRjenuvoLlLTzXJAWL7MmZzRPZdYbNvYqbnc29_dQjy4ZVs-pid4dUJn1F"
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Config-Library/main/Main.lua"))()
local TextChatService = game:GetService("TextChatService")

local distance = 10000
local playerSpeed = 30

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")

local isFarm = false; local isMine = false
local monsterList = {} ; local nameList = {}; local targetList = {}

-- MAIN
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
    table.clear(nameList)
    table.clear(monsterList)

    for _, rock in pairs(Rock) do
        if rock.Name == "Hitbox" then
            local nameText = rock.Parent.Name
            local hitbox = rock
            if getDistance(hrp, hitbox) >= distance then continue end
            
            if not nameSet[nameText] then
                table.insert(monsterList, nameText)
                nameSet[nameText] = true
                table.insert(nameList, nameText)
            end
        end
    end
end
local function mine(rock)
    local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
    local safeHeight = -2

    local headPos = getPosition(rock)
    local targetPosition = headPos + Vector3.new(1, hrpToFeet + safeHeight, 1)        
    hrp.CFrame = CFrame.new(targetPosition)

    local stillTarget = false
    for _, target in pairs(targetList) do
        if not rock  then return end
        if (target == rock.Parent.Name) then
            stillTarget = true
            break;
        end
    end   
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
        for _, target in pairs(targetList) do
            if not rock.Parent or not rock then return end
            if (target == name) then
                stillTarget = true
                break;
            end
        end
        task.wait()
    end
end
local function check()
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

            for _, target in ipairs(targetList) do
                if (target == name) then
                    mine(rock)
                end
            end
        end
    end
    warn("ended")
end
local function autoFarm()
    while isFarm do
        check()
        task.wait()
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

local function teleSell()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Dialogue = ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService.RF.Dialogue -- RemoteFunction 
    local GreedyCey = workspace.Proximity["Greedy Cey"]
    Dialogue:InvokeServer(
        GreedyCey
    )
end
local Window = Fluent:CreateWindow({
    Title = "Tiger HUB | Anime Weapons | Version: 3.0 | Power Pannel",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local tabs = {
        Farm = Window:AddTab({ Title = "Farm", Icon = "swords" }),
        More = Window:AddTab({ Title = "Mores", Icon = "user-cog" }),
        Settings = Window:AddTab({ Title = "Player Config", Icon = "user-cog" })
    }
    
local option1 = Fluent.Options
do
    
    local MultiDropdown = tabs.Farm:AddDropdown("MultiDropdown", {
        Title = "Select Enemies",
        Description = "ONLY WORK WITH INSTANT KILL",
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

    local resetButton = tabs.Farm:AddButton({
        Title = "Reset Rocks List",
        Description = "",
        Callback = function() 
            MultiDropdown:SetValue({})
            resetRockList() 
            MultiDropdown:SetValues(nameList)
            for _, p in pairs(nameList) do
                warn(p)
            end
            Library:SaveConfig("TigerHubForge/monsterList.json", nameList)
        end
    })
    MultiDropdown:SetValues(nameList)

    
    local toogleFarm = tabs.Farm:AddToggle("toogleFarm", {Title = "Auto Farm Selected Rock", Default = false})
    toogleFarm:OnChanged(function()
        isFarm = toogleFarm.Value
        if (toogleFarm.Value) then
            task.spawn(function() 
                autoFarm()
            end)
        end
    end)
    local toogleMine = tabs.Farm:AddToggle("toogleFarm", {Title = "Auto Mining", Default = false})
    toogleMine:OnChanged(function()
        isMine = toogleMine.Value
        if (toogleMine.Value) then
            task.spawn(function() 
                autoFarm()
            end)
        end
    end)
    -- mmore
    local SellButton = tabs.More:AddButton({
        Title = "Sell Ore",
        Description = "",
        Callback = function() 
            teleSell()
        end
    })
    
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
