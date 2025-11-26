-- Konfigurasi
local DecalsYeeted = true -- Biarkan true untuk FPS boost (tapi game jadi jelek)

-- Services
local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain

-- Setup Terrain (Air & Efek)
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0

-- Setup Lighting (Cahaya & Bayangan)
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

-- Setup Rendering Quality
settings().Rendering.QualityLevel = "Level01"

-- Loop untuk scan seluruh object di game
for _, v in pairs(game:GetDescendants()) do
    -- Mengubah Material Part menjadi Plastic
    if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    
    -- Menghilangkan Decal (Gambar tempelan)
    elseif v:IsA("Decal") and DecalsYeeted then
        v.Transparency = 1
    
    -- Mematikan Efek Partikel
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    
    -- Mengurangi efek ledakan
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    end
end

-- Mematikan Efek Visual di Lighting
for _, e in pairs(Lighting:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
