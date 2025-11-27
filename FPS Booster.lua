_G.Ignore = {}
_G.Settings = {
    Players = {
        ["Ignore Me"] = true,
        ["Ignore Others"] = true,
        ["Ignore Tools"] = true
    },
    Meshes = {
        NoMesh = false,
        NoTexture = false,
        Destroy = false
    },
    Images = {
        Invisible = true,
        Destroy = false
    },
    Explosions = {
        Smaller = true,
        Invisible = false,
        Destroy = false
    },
    Particles = {
        Invisible = true,
        Destroy = false
    },
    TextLabels = {
        LowerQuality = true,
        Invisible = false,
        Destroy = false
    },
    MeshParts = {
        LowerQuality = true,
        Invisible = false,
        NoTexture = false,
        NoMesh = false,
        Destroy = false
    },
    Other = {
        ["FPS Cap"] = 360,
        ["No Camera Effects"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true,
        ["Low Quality Models"] = true,
        ["Reset Materials"] = true,
        ["Lower Quality MeshParts"] = true,
        ClearNilInstances = false
    }
}

if _G.SendNotifications == nil then
    _G.SendNotifications = true
end
if _G.ConsoleLogs == nil then
    _G.ConsoleLogs = false 
end
if _G.LoadedWait == nil then
    _G.LoadedWait = 1 
end

if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local ME = Players.LocalPlayer
local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Inst)
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function DescendantOfIgnore(Inst)
    for i, v in pairs(_G.Ignore) do
        if Inst:IsDescendantOf(v) then
            return true
        end
    end
    return false
end

local function CheckIfBad(Inst)
    if not Inst:IsDescendantOf(Players) and 
       (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Inst) or not _G.Settings.Players["Ignore Others"]) and 
       (_G.Settings.Players["Ignore Me"] and ME.Character and not Inst:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) and 
       (_G.Settings.Players["Ignore Tools"] and not Inst:IsA("BackpackItem") and not Inst:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"]) and 
       (_G.Ignore and not table.find(_G.Ignore, Inst) and not DescendantOfIgnore(Inst) or (not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0)) then
        
        if Inst:IsA("DataModelMesh") then
            if Inst:IsA("SpecialMesh") then
                if _G.Settings.Meshes.NoMesh then
                    Inst.MeshId = ""
                end
                if _G.Settings.Meshes.NoTexture then
                    Inst.TextureId = ""
                end
            end
            if _G.Settings.Meshes.Destroy then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then
                Inst.Transparency = 1
                Inst.Shiny = 1
            end
            if _G.Settings.Images.Destroy then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then
                Inst.Graphic = ""
            end
            if _G.Settings.Images.Destroy then
                Inst:Destroy()
            end
        
        elseif table.find(CanBeEnabled, Inst.ClassName) then
            if _G.Settings.Particles and _G.Settings.Particles.Invisible then
                Inst.Enabled = false
            end
            if _G.Settings.Particles and _G.Settings.Particles.Destroy then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("PostEffect") and _G.Settings.Other and _G.Settings.Other["No Camera Effects"] then
            Inst.Enabled = false
        
        elseif Inst:IsA("Explosion") then
            if _G.Settings.Explosions and _G.Settings.Explosions.Smaller then
                Inst.BlastPressure = 1
                Inst.BlastRadius = 1
            end
            if _G.Settings.Explosions and _G.Settings.Explosions.Invisible then
                Inst.BlastPressure = 1
                Inst.BlastRadius = 1
                Inst.Visible = false
            end
            if _G.Settings.Explosions and _G.Settings.Explosions.Destroy then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("Clothing") or Inst:IsA("SurfaceAppearance") or Inst:IsA("BaseWrap") then
            if _G.Settings.Other and _G.Settings.Other["No Clothes"] then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
            if _G.Settings.Other and _G.Settings.Other["Low Quality Parts"] then
                Inst.Material = Enum.Material.Plastic
                Inst.Reflectance = 0
            end
        
        elseif Inst:IsA("TextLabel") and Inst:IsDescendantOf(workspace) then
            if _G.Settings.TextLabels and _G.Settings.TextLabels.LowerQuality then
                Inst.Font = Enum.Font.SourceSans
                Inst.TextScaled = false
                Inst.RichText = false
                Inst.TextSize = 14
            end
            if _G.Settings.TextLabels and _G.Settings.TextLabels.Invisible then
                Inst.Visible = false
            end
            if _G.Settings.TextLabels and _G.Settings.TextLabels.Destroy then
                Inst:Destroy()
            end
        
        elseif Inst:IsA("Model") then
            if _G.Settings.Other and _G.Settings.Other["Low Quality Models"] then
                Inst.LevelOfDetail = Enum.ModelLevelOfDetail.StreamingMesh
            end
        
        elseif Inst:IsA("MeshPart") then
            if _G.Settings.MeshParts and _G.Settings.MeshParts.LowerQuality then
                Inst.RenderFidelity = Enum.RenderFidelity.Performance
                Inst.Reflectance = 0
                Inst.Material = Enum.Material.Plastic
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.Invisible then
                Inst.Transparency = 1
                Inst.RenderFidelity = Enum.RenderFidelity.Performance
                Inst.Reflectance = 0
                Inst.Material = Enum.Material.Plastic
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoTexture then
                Inst.TextureID = ""
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoMesh then
                Inst.MeshId = ""
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.Destroy then
                Inst:Destroy()
            end
        end
    end
end

if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "FPS Booster",
        Text = "Đang tải FPS Booster...",
        Duration = 5,
        Button1 = "OK"
    })
end

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if not terrain then
            repeat task.wait() until workspace:FindFirstChildOfClass("Terrain")
            terrain = workspace:FindFirstChildOfClass("Terrain")
        end
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
        if sethiddenproperty then
            sethiddenproperty(terrain, "Decoration", false)
        end
        if _G.ConsoleLogs then
            warn("✓ Đã tối ưu đồ họa nước")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", 2)
        end
        if _G.ConsoleLogs then
            warn("✓ Đã tắt bóng đổ")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["Low Rendering"] then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        if _G.ConsoleLogs then
            warn("✓ Đã giảm chất lượng rendering")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["Reset Materials"] then
        for i, v in pairs(MaterialService:GetChildren()) do
            v:Destroy()
        end
        MaterialService.Use2022Materials = false
        if _G.ConsoleLogs then
            warn("✓ Đã reset materials")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["FPS Cap"] then
        if setfpscap then
            local fpsCap = _G.Settings.Other["FPS Cap"]
            if type(fpsCap) == "number" then
                setfpscap(fpsCap)
                if _G.ConsoleLogs then
                    warn("✓ FPS giới hạn: " .. fpsCap)
                end
            elseif fpsCap == true then
                setfpscap(1000000)
                if _G.ConsoleLogs then
                    warn("✓ Đã bỏ giới hạn FPS")
                end
            end
        else
            warn("✗ Executor không hỗ trợ setfpscap")
        end
    end
end)

coroutine.wrap(pcall)(function()
    if _G.Settings.Other and _G.Settings.Other["ClearNilInstances"] then
        if getnilinstances then
            for _, v in pairs(getnilinstances()) do
                pcall(v.Destroy, v)
            end
            if _G.ConsoleLogs then
                warn("✓ Đã xóa nil instances")
            end
        end
    end 
end)

local Descendants = game:GetDescendants()
if _G.ConsoleLogs then
    warn("Đang kiểm tra " .. #Descendants .. " instances...")
end

for i, v in pairs(Descendants) do
    pcall(CheckIfBad, v)
end

if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "FPS Booster",
        Text = "✓ FPS Booster !",
        Duration = 10,
        Button1 = "OK"
    })
end
warn(" FPS Booster!")

local canRun = true

while true do
    Descendants = game:GetDescendants()
    for i, v in pairs(Descendants) do
        pcall(CheckIfBad, v)
    end
    task.wait(20)
end

