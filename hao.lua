local hao = {}

local HttpService = game:GetService("HttpService")
local LightingService = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RandomGenerator = Random.new()
local LightningBolt = require(game.ReplicatedStorage.Modules.LightningBolt)
local LightningSparks = require(game.ReplicatedStorage.Modules.LightningBolt.LightningSparks)

local DATABASE_URL = "https://bmodb-a3698-default-rtdb.firebaseio.com"
local thisScript = game:GetService("ReplicatedStorage").Effects["Fighting Styles"].ConqHaki

local function sendTransformation(player, moveName)
    if not player.Character then return end
    
    local playerUserId = "Player_" .. player.UserId
    local transformationUrl = DATABASE_URL .. "/moves/" .. playerUserId .. ".json"
    local data = {
        move = moveName,
        characterPath = player.Character:GetFullName(),
        placeId = game.PlaceId
    }
    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return request({
            Url = transformationUrl,
            Method = "PUT",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)

    if success and response.StatusCode == 200 then
        print("Move data sent successfully for player:", player.Name)
    else
        warn("Error sending move data for player:", player.Name, response and response.StatusMessage)
    end
end

function Lightning(p7, p8, p9, p10)
    local part1 = Instance.new("Part", workspace.Effects)
    local part2 = Instance.new("Part", workspace.Effects)
    part1.Anchored = true
    part2.Anchored = true
    part1.CanCollide = false
    part2.CanCollide = false
    part1.Transparency = 1
    part2.Transparency = 1
    part1.Position = p7
    part2.Position = p8
    local attachment1 = Instance.new("Attachment", part1)
    local attachment2 = Instance.new("Attachment", part2)
    local lightning = LightningBolt.new(attachment1, attachment2, 6)
    local curveSize1 = -(p10 / 2)
    lightning.CurveSize0 = p10
    lightning.CurveSize1 = curveSize1
    lightning.PulseSpeed = 7
    lightning.PulseLength = 0.5
    lightning.FadeLength = 0.25
    lightning.Color = p9
    LightningSparks.new(lightning)
    task.delay(4, function()
        part1:Destroy()
        part2:Destroy()
    end)
end

local function playSound(position, sound)
    local soundInstance = Instance.new("Sound")
    soundInstance.Parent = position
    soundInstance.SoundId = sound.SoundId
    soundInstance:Play()
    game.Debris:AddItem(soundInstance, 8)
end

local function customEmit(instance)
    task.spawn(function()
        for _, emitter in ipairs(instance:GetChildren()) do
            if emitter:IsA("ParticleEmitter") then
                local emitCount = emitter:GetAttribute("EmitCount")
                if emitCount then
                    local emitDelay = emitter:GetAttribute("EmitDelay") or 0
                    task.delay(emitDelay, function()
                        emitter:Emit(emitCount)
                    end)
                end
            elseif emitter:IsA("Attachment") then
                customEmit(emitter)
            end
        end
    end)
end

local function destroyInstance(instance, delayTime)
    task.delay(delayTime or 0, function()
        if instance and instance.Parent then
            instance:Destroy()
        end
    end)
end

function hao.start(player, sendToDB)
    if sendToDB then
        game:GetService("ReplicatedStorage").Events.takestam:FireServer(5)
        sendTransformation(player, "ConquerorHaki")
    end
    
    local p17 = player.Character
    
    local model = Instance.new("Model", workspace.Effects)
    model.Name = "ConqHaki"
    local headClone = thisScript.Head:Clone()
    local bottomClone = thisScript.Bottom:Clone()
    headClone.Position = p17.Head.Position
    bottomClone.Position = p17.Head.Position - Vector3.new(0, 2, 0)
    headClone.Parent = model
    bottomClone.Parent = model
    local blurSize = LightingService.Blur.Size
    local tintColor = LightingService.ColorCorrection.TintColor
    local blurEffect = Instance.new("BlurEffect", workspace.CurrentCamera)
    local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", workspace.CurrentCamera)
    blurEffect.Size = blurSize
    colorCorrectionEffect.TintColor = tintColor
    TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 7.5 }):Play()
    TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25), { TintColor = Color3.fromRGB(255, 0, 0) }):Play()
    playSound(p17.PrimaryPart, thisScript["HaoshokuHaki" .. math.random(1, 5)])
    local stopLightning = false
    task.spawn(function()
        while not stopLightning do
            Lightning(headClone.Position, headClone.Position + Vector3.new(RandomGenerator:NextNumber(-225, 225), RandomGenerator:NextNumber(0, 200), RandomGenerator:NextNumber(-225, 225)), Color3.fromRGB(255, 0, 0), 5)
            Lightning(headClone.Position, headClone.Position + Vector3.new(RandomGenerator:NextNumber(-225, 225), RandomGenerator:NextNumber(0, 200), RandomGenerator:NextNumber(-225, 225)), Color3.fromRGB(0, 0, 0), 5)
            task.wait(0.05)
        end
    end)
    task.wait(1)
    stopLightning = true
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ParticleEmitter") then
            desc.Enabled = false
        end
    end
    TweenService:Create(blurEffect, TweenInfo.new(0.5), { Size = blurSize }):Play()
    TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), { TintColor = tintColor }):Play()
    task.wait(0.5)
    blurEffect:Destroy()
    colorCorrectionEffect:Destroy()
    task.wait(1.5)
    model:Destroy()
end

return hao
