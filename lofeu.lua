local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DATABASE_URL = "https://bmodb-a3698-default-rtdb.firebaseio.com"

local Nobu = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/testing.lua"))()
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character

local RATE_LIMIT = 1
local lastCheckTime = 0

local function getFromPath(path)
    local segments = string.split(path, ".")
    local currentInstance = game
    for _, segment in ipairs(segments) do
        currentInstance = currentInstance:FindFirstChild(segment)
        if not currentInstance then
            return nil
        end
    end
    return currentInstance
end

local function fetchTransformationData(player)
    local playerUserId = "Player_" .. player.UserId
    local transformationUrl = string.format("%s/transformations/%s.json", DATABASE_URL, playerUserId)

    local success, response = pcall(function()
        return request({
            Url = transformationUrl,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    else
        warn("Error fetching transformation data for player:", player.Name, response and response.StatusMessage)
        return nil
    end
end

local function checkForTransformations()
    local currentTime = tick()
    if currentTime - lastCheckTime < RATE_LIMIT then
        return
    end

    lastCheckTime = currentTime
    local players = Players:GetPlayers()
    
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            coroutine.wrap(function()
                local data = fetchTransformationData(player)
                if data and data.transformation and data.characterPath and data.placeId == game.PlaceId then
                    local characterInstance = getFromPath(data.characterPath)
                    if characterInstance then
                        Nobu.attach_doll(characterInstance, true, false)
                    else
                        warn("Invalid character path:", data.characterPath)
                    end
                end
            end)()
        end
    end
end

RunService.Stepped:Connect(checkForTransformations)
--Nobu.attach_doll(character, true, true)
