local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local client =  Players.LocalPlayer
local targetName = "Robocon_001"
local currentRebirth
local currentCash
local collectPart 
local needToBuy = {}
local ok = true
local needtoBuy = {}
local foundPriority = 0
local Priority = {"Dropper", "Upgrader", "Floor", "Bridge", "Upgrade"}
local rebirthProgress = game:GetService("Players").Robocon_001.PlayerGui.TopbarStandard.Holders.Right.Widget.IconButton.Menu.IconSpot.Contents.IconLabelContainer.IconLabel.ContentText
local openRebirth = game:GetService("Players").LocalPlayer.PlayerGui.other["HUD Elements"].Left.Frame.Rebirth
local rebirthButton = game:GetService("Players").LocalPlayer.PlayerGui.main.mainFrame.Rebirth.Frame.rebirth
local rebirthFrame =  game:GetService("Players").LocalPlayer.PlayerGui.main.mainFrame.Rebirth.Frame


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
	local safeHeight = 0 -- Extra height to ensure you spawn above it

	-- Build CFrame facing the collect part’s front direction
	local targetPosition = button.Position + Vector3.new(0, hrpToFeet + safeHeight, 0)
	local direction = (button.CFrame.LookVector * 5) -- face same direction as the part
	hrp.CFrame = CFrame.new(targetPosition, targetPosition + direction)
	warn("BOUGHT : ", name)
	task.wait(0.7)
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

	foundPriority = 0
end

local function collectCash() 
	local character = client.Character
	local hrp = character:WaitForChild("HumanoidRootPart")
	firetouchinterest(collectPart, hrp, 0)
	task.wait(0.1)
    firetouchinterest(collectPart, hrp, 1)
	task.wait(0.1)
end 

local function getButtonCenter(button)
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local centerX = absPos.X + absSize.X/2
    local centerY = absPos.Y + absSize.Y
    return centerX, centerY
end

local function clickButton(button)
	local x, y = getButtonCenter(button)
	mousemoveabs(x, y)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	findData()
end
local function loopAutoBuy()
	while(ok) do
        rebirthProgress = game:GetService("Players").Robocon_001.PlayerGui.TopbarStandard.Holders.Right.Widget.IconButton.Menu.IconSpot.Contents.IconLabelContainer.IconLabel.ContentText
        if (rebirthProgress:find("100") or rebirthProgress:find("99")) then
            if (rebirthFrame.Visible == false) then
                clickButton(openRebirth)
                task.wait(0.2)
                clickButton(rebirthButton)
            else
                clickButton(rebirthButton)
                task.wait(0.2)
                clickButton(openRebirth)
            end
        end
    	collectCash()
		autoBuy()
		task.wait(0.2)
	end
end

local function isPlayerInServer()
    --loadstring:HttpGet("https://rawscripts.net/raw/Universal-Script-Keyless-dex-working-new-25658"))()
	findData()
    updateCurrencyPlayer(client)
	loopAutoBuy()
    return
end

isPlayerInServer()


