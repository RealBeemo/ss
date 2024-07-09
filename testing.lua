local nobu = {}
local Players = game:GetService("Players")
local DATABASE_URL = "https://bmodb-a3698-default-rtdb.firebaseio.com"
local HttpService = game:GetService("HttpService")

local v_u_2 = {
    ["Head"] = "Head",
    ["RightUpperArm"] = "RightArm",
    ["LeftUpperArm"] = "LeftArm",
    ["LeftUpperLeg"] = "LeftLeg",
    ["RightUpperLeg"] = "RightLeg",
    ["UpperTorso"] = "Torso"
}

local v_u_3 = {
    932154428,
    932154085,
    932153746,
    932153061,
    921606174
}

local thisScript = game:GetService("ReplicatedStorage").Effects.DevilFruits.Nobu.NobuUtil
local character = game:GetService("Players").LocalPlayer.Character

local function sendTransformation(player, transformationName)
    if not player.Character then return end
    
    local playerUserId = "Player_" .. player.UserId
    local transformationUrl = DATABASE_URL .. "/transformations/" .. playerUserId .. ".json"
    local data = {
        transformation = transformationName,
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
        print("Transformation data sent successfully for player:", player.Name)
    else
        warn("Error sending transformation data for player:", player.Name, response and response.StatusMessage)
    end
end

local function do_poof_efx(position)
    local v5 = thisScript.PoofEffect:Clone()
    v5:PivotTo(CFrame.new(position))
    v5.SwirlA.Size = Vector3.new(7, 7, 3)
    v5.SwirlB.Size = Vector3.new(5, 5, 3)
    v5.Parent = workspace.Effects
    
    local tweenService = game:GetService("TweenService")
    tweenService:Create(v5.SwirlA, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = v5.SwirlA.CFrame * CFrame.Angles(0, 0, 2.13),
        Size = Vector3.new(29, 29, 4),
        Transparency = 1
    }):Play()
    
    tweenService:Create(v5.SwirlB, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = v5.SwirlB.CFrame * CFrame.Angles(0, 0, -3.13),
        Size = Vector3.new(32, 32, 5),
        Transparency = 1
    }):Play()
    
    v5.root.Attachment.Core:Emit(1)
    v5.root.Attachment.FillStar:Emit(8)
    v5.root.Attachment.HollowStar:Emit(6)
    v5.root.Attachment.Smoke:Emit(6)
    
    delay(1.5, function() v5:Destroy() end)
    
    local v6 = Random.new()
    local sound1 = thisScript.Transform:Clone()
    sound1.Parent = v5.PrimaryPart
    sound1.PlaybackSpeed = v6:NextNumber(0.9, 1.05)
    sound1:Play()
    
    local sound2 = thisScript.Pop:Clone()
    sound2.Parent = v5.PrimaryPart
    sound2.PlaybackSpeed = v6:NextNumber(0.4, 0.9)
    sound2:Play()
end

local function do_revert_efx(position)
    local v8 = thisScript.RevertEffect:Clone()
    v8:PivotTo(CFrame.new(position))
    v8.Parent = workspace.Effects
    v8.root.Attachment.Core:Emit(2)
    v8.root.Attachment.Smoke:Emit(5)
    
    delay(1.6, function() v8:Destroy() end)
    
    local sound = thisScript.Revert:Clone()
    sound.Parent = v8.PrimaryPart
    sound.PlaybackSpeed = Random.new():NextNumber(0.95, 1.05)
    sound:Play()
end

local v_u_9 = {}

function nobu.attach_doll(p10, p11, sendToDB)
    if not p10:FindFirstChild("DollParts") then
        if v_u_9[p10] == nil then
            v_u_9[p10] = {}
        end
        local v12 = p10:GetDescendants()
        for v13 = 1, #v12 do
            if v12[v13]:IsA("BasePart") then
                v_u_9[p10][v12[v13]] = v12[v13].Transparency
                v12[v13].Transparency = 1
            end
        end
        p10.Humanoid.HipHeight = p10.Humanoid.BodyHeightScale.Value * 2 * 0.4
        do_poof_efx(p10.HumanoidRootPart.Position)
        local v14 = Instance.new("Model")
        v14.Name = "DollParts"
        for v15, v16 in v_u_2 do
            local v17 = p10[v15]
            local v18 = thisScript.DollParts[v16]:Clone()
            v18.Weld.Part1 = v17
            v18.Parent = v14
            local v19 = v18:GetChildren()
            for v20 = 1, #v19 do
                if v19[v20]:IsA("BasePart") then
                    v19[v20].Parent = v14
                end
            end
        end
        v14.Torso.Decal.Texture = "rbxassetid://" .. v_u_3[Random.new():NextInteger(1, 5)]
        if p11 ~= nil then
            local v21 = thisScript.DollParts.DahNoobAcc:Clone()
            v21.root.Weld.Part1 = p10.Head
            v21.Parent = v14
            v14.RightArm.BrickColor = BrickColor.new("Really black")
            v14.LeftLeg.BrickColor = BrickColor.new("Royal purple")
        end
        v14.Parent = p10

        if sendToDB then
            local userId = game:GetService("Players").LocalPlayer.UserId
            sendTransformation(game:GetService("Players").LocalPlayer, "Nobu")
        end
    end
end

function nobu.remove_doll(p22)
    if p22:FindFirstChild("DollParts") then
        if v_u_9[p22] then
            for v23, v24 in v_u_9[p22] do
                if v23 then
                    v23.Transparency = v24
                end
            end
            v_u_9[p22] = nil
        end
        p22.Humanoid.HipHeight = p22.Humanoid.BodyHeightScale.Value * 2
        do_revert_efx(p22.HumanoidRootPart.Position)
        p22.DollParts:Destroy()
    end
end

function nobu.start(p33, p34, ...)
    if p34 == "remove_plushie" then
        remove_doll(p33, unpack({ ... }))
    end
end

return nobu

--attach_doll(character, nil) --Function to attach the doll (the second arg can be 'true' if you want DahNoob's Plush)
--start(character, "remove_plushie") --Function to delete the doll (currently makes you invisible, lazy to fix)
