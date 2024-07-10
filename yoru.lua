local Yoru = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Effects = workspace.Effects

local DATABASE_URL = "https://bmodb-a3698-default-rtdb.firebaseio.com"
local TweenService = game:GetService("TweenService")

local thisScript = ReplicatedStorage.Effects.Weapons.Yoru["Thousand Slices"]

local function sendMove(player, moveName)
    if not player.Character then return end
    
    local playerUserId = "Player_" .. player.UserId
    local MoveUrl = DATABASE_URL .. "/moves/" .. playerUserId .. ".json"
    local data = {
        move = moveName,
        userId = player.UserId,
        characterPath = player.Character:GetFullName(),
        placeId = game.PlaceId
    }
    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return request({
            Url = MoveUrl,
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

local function toggleParticles(instance, enabled, delayTime)
    local function setParticles(emitter, state)
        for _, descendant in ipairs(emitter:GetDescendants()) do
            if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                descendant.Enabled = state
            end
        end
    end

    if delayTime then
        task.delay(delayTime, function()
            setParticles(instance, false)
        end)
    end

    setParticles(instance, enabled)
end

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Include
RaycastParams.FilterDescendantsInstances = { workspace.Terrain, workspace.Islands, workspace.Env }

local function playSound(position, sound)
    local soundInstance = Instance.new("Sound")
    soundInstance.Parent = position
    soundInstance.SoundId = sound.SoundId
    soundInstance:Play()
    game.Debris:AddItem(soundInstance, soundInstance.TimeLength)
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

local function recolorParticles(instance, colors)
    local colorSequence = ColorSequence.new(colors)
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            descendant.Color = colorSequence
        elseif descendant:IsA("Trail") then
            descendant.Color = colorSequence
        end
    end
end

local function playAnimation(player, animationId)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("Humanoid not found")
        return
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId

    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator")
    local animationTrack = animator:LoadAnimation(animation)
    animationTrack:Play()

    return animationTrack
end

function Yoru.start(player, sendToDB, color, normalColor)
    local character = player.Character
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local lookVector = rootPart.CFrame.LookVector
    local scale = thisScript.Effects:GetScale()
    local offset = 15 * scale

    if normalColor then
        for _, v in pairs(weapon:GetDescendants()) do
            if v:IsA("MeshPart") and v.Color == Color3.fromRGB(148, 190, 129) then
                v.Color = normalColor
            end
        end
        recolorParticles(weapon, color)
        toggleParticles(weapon, true)
    end

    local firstEffect = thisScript.Effects["First (Emit)"]:Clone()
    firstEffect.CFrame = rootPart.CFrame + (lookVector * 2) * CFrame.new(0, -3, -offset)
    if color then
        recolorParticles(firstEffect, color)
    end
    firstEffect.Parent = Effects
    customEmit(firstEffect)
    destroyInstance(firstEffect, 2)

    local animTrack = playAnimation(17421237192)
    playSound(rootPart, thisScript.YoruSliceBarrage)

    task.delay(1, function()
        animTrack:AdjustSpeed(0.4)
    end)

    task.wait(0.7)

    local secondEffect = thisScript.Effects["Second (Emit)"]:Clone()
    secondEffect.CFrame = rootPart.CFrame + (lookVector * 2) * CFrame.new(0, 0, -offset)
    if color then
        recolorParticles(secondEffect, color)
    end
    secondEffect.Parent = Effects
    customEmit(secondEffect)
    destroyInstance(secondEffect, 1)

    task.wait(0.05)

    local slices = thisScript.Effects.Slices:Clone()
    slices:PivotTo(rootPart.CFrame + (lookVector * 2) * CFrame.new(0, 1, -offset))
    if color then
        recolorParticles(slices, color)
    end
    slices.Parent = Effects
    toggleParticles(slices["Third (Enable)"], true)

    local raycastResult = workspace:Raycast(slices.GroundScratch.Position + Vector3.new(0, 5, 0), Vector3.new(0, -12, 0), RaycastParams)
    if raycastResult then
        toggleParticles(slices.GroundScratch, true)
        slices.GroundScratch.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(math.pi / 2, 0, 0) * CFrame.new(0, -0.2, 0)
    end

    task.spawn(function()
        for _ = 0, 25 do
            local greenEffect = thisScript.Effects.Green:Clone()
            local blackEffect = thisScript.Effects.Black:Clone()

            local greenCFrame = slices.PrimaryPart.CFrame * CFrame.new(math.random(-8, 8) * scale, math.random(-8, 8) * scale, math.random(-8, 8) * scale) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
            greenEffect.CFrame = greenCFrame
            if color then
                recolorParticles(greenEffect, color)
            end
            greenEffect.Parent = Effects
            destroyInstance(greenEffect, 0.2)

            local blackCFrame = slices.PrimaryPart.CFrame * CFrame.new(math.random(-8, 8) * scale, math.random(-8, 8) * scale, math.random(-8, 8) * scale) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
            blackEffect.CFrame = blackCFrame
            blackEffect.Parent = Effects
            destroyInstance(blackEffect, 0.2)

            TweenService:Create(greenEffect.Mesh, TweenInfo.new(0.1), { Scale = Vector3.new(0, 0, math.random(10, 15)) * scale }):Play()
            TweenService:Create(blackEffect.Mesh, TweenInfo.new(0.1), { Scale = Vector3.new(0, 0, math.random(10, 15)) * scale }):Play()

            task.wait(0.064)
        end
    end)

    if sendToDB then
        game:GetService("ReplicatedStorage").Events.takestam:FireServer(5)
        sendMove(player, "YoruBarrage")
    end

    task.wait(1.6)
    toggleParticles(slices, false)
    destroyInstance(slices, 2)
end

return Yoru
