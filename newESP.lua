local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/thoth.lua"))()

local RunService, UserInputService, HttpService = Utility.RunService, Utility.UserInputService, Utility.HttpService

local EntityESP = {}
local CustomObjects = {}

local worldToViewportPoint = clonefunction(Instance.new('Camera').WorldToViewportPoint)
local getMouseLocation = clonefunction(UserInputService.GetMouseLocation)

local id = HttpService:GenerateGUID(false)

local vector3New = Vector3.new
local Vector2New = Vector2.new

local mathFloor = math.floor

local setRP = function(object, p, v)
    if object then
        object[p] = v
    end
end

local getRPProperty = function(object, p)
    if object then
        return object[p]
    end
end

local destroyRP = function(object)
    if object then
        object:Remove()
    end
end

local ESPSettings = {
    Enabled = false,
    Players = false,
    Boxes = false,
    Tracers = false,
    Color = Color3.fromRGB(255, 255, 255),
    BoxesColor = Color3.fromRGB(255, 255, 255),
    TracersColor = Color3.fromRGB(255, 255, 255),
    proximityArrows = false,
    maxEspDistance = 1000,
    maxProximityArrowDistance = 500,
    showStamina = false,
    showDFValue = false,
    showPlayerName = false,
    selfESP = false,
    fontSize = 13 -- Default font size
}

-- Custom Object Class
local CustomObject = {}
CustomObject.__index = CustomObject

function CustomObject.new(name, position, color)
    local self = setmetatable({}, CustomObject)
    self._name = name
    self._position = position
    self._color = color

    self._label = Drawing.new('Text')
    self._label.Visible = true
    self._label.Center = true
    self._label.Outline = true
    self._label.Text = name
    self._label.Font = Drawing.Fonts.UI
    self._label.Size = ESPSettings.fontSize
    self._label.Color = color

    return self
end

function CustomObject:Update()
    if not ESPSettings.Enabled then
        self:Hide()
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return self:Hide() end

    local labelPos, visibleOnScreen = worldToViewportPoint(camera, self._position)
    if not visibleOnScreen then
        self:Hide()
        return
    end

    setRP(self._label, 'Visible', visibleOnScreen)
    setRP(self._label, 'Position', Vector2New(labelPos.X, labelPos.Y))
    setRP(self._label, 'Text', self._name)
    setRP(self._label, 'Color', self._color)
    setRP(self._label, 'Size', ESPSettings.fontSize) -- Update font size live
end

function CustomObject:Hide()
    setRP(self._label, 'Visible', false)
end

function CustomObject:Destroy()
    destroyRP(self._label)
end

function CustomObject:SetColor(color)
    self._color = color
    setRP(self._label, 'Color', color)
end

-- ESP Management Functions
local ESP = {}

function ESP:Toggle(state)
    ESPSettings.Enabled = state
end

function ESP:SetPlayers(state)
    ESPSettings.Players = state
end

function ESP:SetBoxes(state)
    ESPSettings.Boxes = state
end

function ESP:SetTracers(state)
    ESPSettings.Tracers = state
end

function ESP:SetColor(color)
    ESPSettings.Color = color
end

function ESP:SetBoxesColor(color)
    ESPSettings.BoxesColor = color
end

function ESP:SetTracersColor(color)
    ESPSettings.TracersColor = color
end

function ESP:SetMaxDistance(distance)
    ESPSettings.maxEspDistance = distance
end

function ESP:SetProximityArrows(state)
    ESPSettings.proximityArrows = state
end

function ESP:SetMaxProximityArrowDistance(distance)
    ESPSettings.maxProximityArrowDistance = distance
end

function ESP:SetShowStamina(state)
    ESPSettings.showStamina = state
end

function ESP:SetShowDFValue(state)
    ESPSettings.showDFValue = state
end

function ESP:SetShowPlayerName(state)
    ESPSettings.showPlayerName = state
end

function ESP:SetSelfESP(state)
    ESPSettings.selfESP = state
end

function ESP:SetFontSize(size)
    ESPSettings.fontSize = size
    for _, espObject in pairs(ESPObjects or {}) do
        if espObject._label then
            espObject._label.Size = size
        end
    end
end

function ESP:AddObject(name, position, color)
    local newObject = CustomObject.new(name, position, color)
    table.insert(CustomObjects, newObject)
end

function ESP:RemoveObject(name)
    for i, obj in ipairs(CustomObjects) do
        if obj._name == name then
            obj:Destroy()
            table.remove(CustomObjects, i)
            break
        end
    end
end

function ESP:SetObjectColor(name, color)
    for _, obj in ipairs(CustomObjects) do
        if obj._name == name then
            obj:SetColor(color)
            break
        end
    end
end

local ESPObjects = {}

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then
        warn("Camera not found")
        return
    end

    -- Update player ESP
    for _, player in pairs(game.Players:GetPlayers()) do
        if not ESPSettings.selfESP and player == game.Players.LocalPlayer then
            if ESPObjects[player] then
                ESPObjects[player]:Hide()
            end
            ESPObjects[player] = nil
            continue
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")

        if not rootPart or not humanoid then
            if ESPObjects[player] then
                ESPObjects[player]:Hide()
            end
            ESPObjects[player] = nil
            continue
        end

        if not ESPObjects[player] then
            ESPObjects[player] = EntityESP.new(player)
        end

        local rootPartPosition = rootPart.Position
        local labelPos, visibleOnScreen = worldToViewportPoint(camera, rootPartPosition)

        ESPObjects[player]:Update()
    end

    -- Update custom objects ESP
    for _, obj in ipairs(CustomObjects) do
        obj:Update()
    end

    -- Cleanup ESP objects for players that no longer exist
    for player, espObject in pairs(ESPObjects) do
        if not game.Players:FindFirstChild(player.Name) then
            espObject:Destroy()
            ESPObjects[player] = nil
        end
    end
end)

return ESP
