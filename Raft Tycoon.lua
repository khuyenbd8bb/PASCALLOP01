local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local client
local targetName = "Khuyenbd7bd" -- Change this
local currentRebirth
local currentCash
local collectPart 
local needToBuy = {}
local ok = true
local needtoBuy = {}
local foundPriority = 0
local Priority = {"Dropper", "Upgrader", "Floor", "Wall"}
local openRebirth = game:GetService("Players").LocalPlayer.PlayerGui.other["HUD Elements"].Left.Frame.Rebirth
local rebirthButton = game:GetService("Players").LocalPlayer.PlayerGui.main.mainFrame.Rebirth.Frame.rebirth
local VirtualInputManager = game:GetService("VirtualInputManager")

local function debugButton(button, name)
    print("=== Debugging: " .. name .. " ===")
    
    if not button then
        print("❌ Button is nil")
        return
    end
    
    print("Class:", button.ClassName)
    print("Name:", button.Name)
    print("Visible:", button.Visible)
    print("Active:", button.Active)
    print("AbsoluteSize:", button.AbsoluteSize)
    print("AbsolutePosition:", button.AbsolutePosition)
    print("BackgroundTransparency:", button.BackgroundTransparency)
    
    -- Check if it's actually clickable
    local center = button.AbsolutePosition + button.AbsoluteSize / 2
    print("Center Position:", center)
    
    -- Check parent visibility
    local current = button.Parent
    while current and current:IsA("GuiObject") do
        print("Parent " .. current.Name .. " Visible:", current.Visible)
        current = current.Parent
    end
    
    print("---")
end

-- Debug both buttons
debugButton(openRebirth, "Open Rebirth Button")
debugButton(rebirthButton, "Rebirth Button")

local function safeClickButton(button, clickDelay)
    clickDelay = clickDelay or 0.5
    
    -- Validate the button exists and is visible
    if not button or not button:IsA("GuiObject") then
        warn("Invalid button")
        return
    end
    
    if not button.Visible then
        warn("Button is not visible")
        return
    end
    
    if button.AbsoluteSize.X == 0 or button.AbsoluteSize.Y == 0 then
        warn("Button has no size")
        return
    end
    
    -- Calculate center position
    local center = button.AbsolutePosition + button.AbsoluteSize / 2
    
    -- Send the click
    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    
    print("Clicked button:", button.Name)
    task.wait(clickDelay)
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end  -- ignore if typing in chat, etc.
	if input.KeyCode == Enum.KeyCode.P and ok then
		ok = false
		warn("Auto stopped (P pressed)")
	end
end)

local function findData()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "CollectPart" then
			collectPart = obj
			warn("Found collectPart")
			break
		end
	end
end

local function updateCurrencyPlayer(player)
	local leaderstats = player:WaitForChild("leaderstats")
	local Cash = leaderstats:WaitForChild("Cash")
    local Rebirth = leaderstats:WaitForChild("Rebirth")
	
    currentRebirth = Rebirth.Value
	currentCash = Cash.Value

	Cash:GetPropertyChangedSignal("Value"):Connect(function()
		currentCash = Cash.Value
		currentRebirth = Rebirth.Value
	end)

end

local function isGreen(part)
	if not part or not part:IsA("BasePart") then return false end
	local color = part.Color
	-- Checks if green is the dominant color channel
	return color.G > 0.5 and color.G > color.R and color.G > color.B
end

local function buy(button, name)
	local character = client.Character
	if not character then return end

	local hrp = character:WaitForChild("HumanoidRootPart", 2)
	local humanoid = character:WaitForChild("Humanoid", 2)
	if not hrp or not humanoid then return end

	-- Calculate a safe teleport height
	local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
	local safeHeight = 2 -- Extra height to ensure you spawn above it

	-- Build CFrame facing the collect part’s front direction
	local targetPosition = button.Position + Vector3.new(0, hrpToFeet + safeHeight, 0)
	local direction = (button.CFrame.LookVector * 5) -- face same direction as the part
	hrp.CFrame = CFrame.new(targetPosition, targetPosition + direction)
	warn("BOUGHT : ", name)
	task.wait(1)
end


local function checkName(folder, button)
	local name = folder
	local matched = false
	for _, word in ipairs(Priority) do
		-- case-insensitive check
		if name:lower():find(word:lower()) then
			if (isGreen(button)) then
				foundPriority = math.max(1, foundPriority)
				buy(button, name)
			else
				foundPriority = math.max(2, foundPriority)
				table.insert(needToBuy, {button = button, name = name})
			end
			matched = true
			break
		end
	end
	if matched == false then
		table.insert(needToBuy, {button = button, name = name})
	end
end

local function checkCost2(Cost)
	local str = Cost.Text:gsub(",", "")
	local symbol = str:gsub("[%d%.]", "")  -- remove numbers and decimals
	local isFree = str:lower():find("free") ~= nil
	local button = Cost.Parent.Parent.Parent:FindFirstChild("Main")
	local folder = Cost.Parent:FindFirstChild("NameLabel") or Cost.Parent:FindFirstChild("Name")
	if not folder then
		return
	end
	folder = folder.Text
	
	if isFree then
		buy(button, folder)
		foundPriority = math.max(foundPriority, 1)
	elseif symbol:find("%$") then
		checkName(folder, button)
	end
end

local function loopCheck(obj)
	-- Check if it's named "Main" AND has a numeric value
	if obj.Name == "Cost" then
		checkCost2(obj)
		return
	end 

	for _, child in ipairs(obj:GetChildren()) do
		loopCheck(child)
	end
end

local function autoBuy()
	--warn("LIST : LIST")

	for k in pairs(needToBuy) do
    	needToBuy[k] = nil
	end
	local TycoonsFolder = workspace:FindFirstChild("Tycoons")
	if not TycoonsFolder then
		warn("No Tycoons folder found!")
		return
	end
	for _, tycoon in ipairs(TycoonsFolder:GetChildren()) do
		loopCheck(tycoon)
	end
	if foundPriority == 0 then
		for _, item in ipairs(needToBuy) do
			if isGreen(item.button) then
				buy(item.button, item.name)
			end
		end
	end	
	
	--if rebirthButton.Visible == true then
		--safeClickButton(openRebirth)
		--safeClickButton(rebirthButton)
	--end

	foundPriority = 0
end



local function collectCash()
	local character = client.Character
	if not character then return end

	local hrp = character:WaitForChild("HumanoidRootPart", 2)
	local humanoid = character:WaitForChild("Humanoid", 2)

	-- Calculate a safe teleport height
	local hrpToFeet = (hrp.Size.Y / 2) + (humanoid.HipHeight or 2)
	local safeHeight = 5 -- Extra height to ensure you spawn above it

	-- Build CFrame facing the collect part’s front direction
	local targetPosition = collectPart.Position + Vector3.new(0, hrpToFeet + safeHeight, 0)
	local direction = (collectPart.CFrame.LookVector * 5) -- face same direction as the part
	hrp.CFrame = CFrame.new(targetPosition, targetPosition + direction)
end


local function loopAutoBuy()
	while(ok) do
		collectCash()
		task.wait(0.5)
		autoBuy()
	end
end

local function isPlayerInServer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == targetName then
            warn(targetName .. " found in server!")
			client = player
            --loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Keyless-dex-working-new-25658"))()
			findData()
            updateCurrencyPlayer(client)
			loopAutoBuy()
            return
        end
    end
    warn(targetName .. " not in server.")
end

isPlayerInServer()


