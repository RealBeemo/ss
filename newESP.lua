local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/thoth.lua"))()

local RunService, UserInputService, HttpService = Utility.RunService, Utility.UserInputService, Utility.HttpService

local EntityESP = {}

local worldToViewportPoint = clonefunction(Instance.new('Camera').WorldToViewportPoint)
local vectorToWorldSpace = CFrame.new().VectorToWorldSpace
local getMouseLocation = clonefunction(UserInputService.GetMouseLocation)

local id = HttpService:GenerateGUID(false)

local vector3New = Vector3.new
local Vector2New = Vector2.new

local mathFloor = math.floor

local mathRad = math.rad
local mathCos = math.cos
local mathSin = math.sin
local mathAtan2 = math.atan2

local scalarPointAX, scalarPointAY
local scalarPointBX, scalarPointBY

local labelOffset, tracerOffset
local boxOffsetTopRight, boxOffsetBottomLeft

local realGetRPProperty

local setRP
local getRPProperty
local destroyRP

local scalarSize = 20

local ESP_RED_COLOR, ESP_GREEN_COLOR = Color3.fromRGB(192, 57, 43), Color3.fromRGB(39, 174, 96)
local TRIANGLE_ANGLE = mathRad(45)

local function createDrawing(type)
    return Drawing.new(type)
end

setRP = function(object, p, v)
    if object then
        object[p] = v
    end
end

getRPProperty = function(object, p)
    if object then
        return object[p]
    end
end

destroyRP = function(object)
    if object then
        object:Remove()
    end
end

local ESPSettings = {
    Enabled = false,
    Players = true,
    Boxes = true,
    Tracers = true,
    Color = Color3.fromRGB(255, 255, 255),
    BoxesColor = Color3.fromRGB(255, 255, 255),
    TracersColor = Color3.fromRGB(255, 255, 255),
    proximityArrows = true,
    maxEspDistance = 1000,
    maxProximityArrowDistance = 500,
    showStamina = false,
    showDFValue = false,
    showPlayerName = true,
    selfESP = false,
    fontSize = 16, -- Default font size
    customObjects = {} -- Custom objects
}

do --// Entity ESP
    EntityESP = {}
    EntityESP.__index = EntityESP
    EntityESP.__ClassName = 'entityESP'

    EntityESP.id = 0

    local emptyTable = {}

    function EntityESP.new(player)
        EntityESP.id += 1

        local self = setmetatable({}, EntityESP)

        self._id = EntityESP.id
        self._player = player
        self._playerName = player.Name

        self._triangle = createDrawing('Triangle')
        self._triangle.Visible = true
        self._triangle.Thickness = 0
        self._triangle.Color = Color3.fromRGB(255, 255, 255)
        self._triangle.Filled = true

        self._label = createDrawing('Text')
        self._label.Visible = false
        self._label.Center = true
        self._label.Outline = true
        self._label.Text = ''
        self._label.Font = Drawing.Fonts.UI
        self._label.Size = ESPSettings.fontSize -- Use default font size
        self._label.Color = Color3.fromRGB(255, 255, 255)

        self._box = createDrawing('Quad')
        self._box.Visible = false
        self._box.Thickness = 1
        self._box.Filled = false
        self._box.Color = Color3.fromRGB(255, 255, 255)

        self._line = createDrawing('Line')
        self._line.Visible = false
        self._line.Color = Color3.fromRGB(255, 255, 255)

        return self
    end

    function EntityESP:Destroy()
        destroyRP(self._triangle)
        destroyRP(self._label)
        destroyRP(self._box)
        destroyRP(self._line)
    end

    function EntityESP:Hide()
        setRP(self._triangle, 'Visible', false)
        setRP(self._label, 'Visible', false)
        setRP(self._box, 'Visible', false)
        setRP(self._line, 'Visible', false)
    end

    function EntityESP:Update()
        if not ESPSettings.Enabled then
            self:Hide()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return self:Hide() end

        local character = self._player.Character
        if not character then return self:Hide() end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return self:Hide() end

        local rootPartPosition = rootPart.Position

        local labelPos, visibleOnScreen = worldToViewportPoint(camera, rootPartPosition)
        local triangle = self._triangle

        local distance = (rootPartPosition - camera.CFrame.Position).Magnitude
        if distance > ESPSettings.maxEspDistance then return self:Hide() end

        local espColor = ESPSettings.Color
        local canView = false

        if ESPSettings.proximityArrows and not visibleOnScreen and distance < ESPSettings.maxProximityArrowDistance then
            local vectorUnit

            if labelPos.Z < 0 then
                vectorUnit = -(Vector2New(labelPos.X, labelPos.Y) - camera.ViewportSize / 2).Unit
            else
                vectorUnit = (Vector2New(labelPos.X, labelPos.Y) - camera.ViewportSize / 2).Unit
            end

            local degreeOfCorner = -mathAtan2(vectorUnit.X, vectorUnit.Y) - TRIANGLE_ANGLE
            local closestPointToPlayer = camera.ViewportSize / 2 + vectorUnit * scalarSize

            local pointA, pointB, pointC = self:GetOffsetTrianglePosition(closestPointToPlayer, degreeOfCorner)

            setRP(triangle, 'PointA', pointA)
            setRP(triangle, 'PointB', pointB)
            setRP(triangle, 'PointC', pointC)

            setRP(triangle, 'Color', espColor)
            canView = true
        end

        setRP(triangle, 'Visible', canView)
        if not visibleOnScreen then return self:Hide() end

        self._visible = visibleOnScreen

        local label, box, line = self._label, self._box, self._line

        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local stamina = ""
        local dfValue = "None"

        if ESPSettings.showStamina then
            local staminaObj = game.ReplicatedStorage:FindFirstChild("Stats" .. self._player.Name)
            if staminaObj and staminaObj:FindFirstChild("Stamina") then
                stamina = "[Stamina] [" .. staminaObj.Stamina.Value .. "]"
            end
        end

        if ESPSettings.showDFValue then
            local dfObj = game.ReplicatedStorage["Stats" .. self._player.Name]
            if dfObj and dfObj.Stats and dfObj.Stats:FindFirstChild("DF") then
                dfValue = dfObj.Stats.DF.Value ~= "" and dfObj.Stats.DF.Value or "None"
            end
        end

        local text
        if ESPSettings.showPlayerName then
            text = string.format("[%s] [%d]\n[%d/%d]\n[%s]\n%s", self._playerName, mathFloor(distance), mathFloor(health), mathFloor(maxHealth), dfValue, stamina)
        else
            text = string.format("[%d/%d] [%dm]\n[%s]\n%s", mathFloor(health), mathFloor(maxHealth), mathFloor(distance), dfValue, stamina)
        end

        local labelPosition = ESPSettings.Boxes and worldToViewportPoint(camera, rootPartPosition + Vector3.new(0, 3, 0)) or Vector2New(labelPos.X, labelPos.Y)

        setRP(label, 'Visible', visibleOnScreen)
        setRP(label, 'Position', labelPosition)
        setRP(label, 'Text', text)
        setRP(label, 'Color', espColor)
        setRP(label, 'Size', ESPSettings.fontSize) -- Update font size live

        if ESPSettings.Boxes then
            local topLeft = worldToViewportPoint(camera, rootPartPosition + Vector3.new(-3, 3, 0))
            local bottomRight = worldToViewportPoint(camera, rootPartPosition + Vector3.new(3, -3, 0))

            setRP(box, 'Visible', visibleOnScreen)
            setRP(box, 'PointA', Vector2New(topLeft.X, topLeft.Y))
            setRP(box, 'PointB', Vector2New(bottomRight.X, topLeft.Y))
            setRP(box, 'PointC', Vector2New(bottomRight.X, bottomRight.Y))
            setRP(box, 'PointD', Vector2New(topLeft.X, bottomRight.Y))
            setRP(box, 'Color', ESPSettings.BoxesColor)
        else
            setRP(box, 'Visible', false)
        end

        if ESPSettings.Tracers then
            local linePosition = worldToViewportPoint(camera, rootPartPosition + tracerOffset)

            setRP(line, 'Visible', visibleOnScreen)
            setRP(line, 'From', getMouseLocation(UserInputService))
            setRP(line, 'To', Vector2New(linePosition.X, linePosition.Y))
            setRP(line, 'Color', ESPSettings.TracersColor)
        else
            setRP(line, 'Visible', false)
        end
    end

    function EntityESP:GetOffsetTrianglePosition(closestPoint, radiusOfDegree)
        local cosOfRadius, sinOfRadius = mathCos(radiusOfDegree), mathSin(radiusOfDegree)
        local closestPointX, closestPointY = closestPoint.X, closestPoint.Y

        local sameBCCos = (closestPointX + scalarPointBX * cosOfRadius)
        local sameBCSin = (closestPointY + scalarPointBX * sinOfRadius)

        local sameACSin = (scalarPointAY * sinOfRadius)
        local sameACCos = (scalarPointAY * cosOfRadius)

        local pointX1 = (closestPointX + scalarPointAX * cosOfRadius) - sameACSin
        local pointY1 = closestPointY + (scalarPointAX * sinOfRadius) + sameACCos

        local pointX2 = sameBCCos - (scalarPointBY * sinOfRadius)
        local pointY2 = sameBCSin + (scalarPointBY * cosOfRadius)

        local pointX3 = sameBCCos - sameACSin
        local pointY3 = sameBCSin + sameACCos

        return Vector2New(mathFloor(pointX1), mathFloor(pointY1)), Vector2New(mathFloor(pointX2), mathFloor(pointY2)), Vector2New(mathFloor(pointX3), mathFloor(pointY3))
    end

    local function updateESP()
        local camera = workspace.CurrentCamera
        if not camera then return end

        local viewportSize = camera.ViewportSize

        labelOffset = Vector3.new(0, 0, 0)
        tracerOffset = Vector3.new(0, -4.5, 0)

        boxOffsetTopRight = Vector3.new(2.5, 3, 0)
        boxOffsetBottomLeft = Vector3.new(-2.5, -4.5, 0)

        scalarSize = 20
        scalarPointAX, scalarPointAY = scalarSize, scalarSize
        scalarPointBX, scalarPointBY = -scalarSize, -scalarSize
    end

    updateESP()
    RunService:BindToRenderStep(id, Enum.RenderPriority.Camera.Value, updateESP)
end

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

function ESP:AddCustomObject(name, position, color)
    print("Adding custom object:", name, position, color)
    if not name or not position then
        warn("Name or position is missing")
        return
    end
    table.insert(ESPSettings.customObjects, {name = name, position = position, color = color})
end

local ESPObjects = {}

-- Update loop
RunService.RenderStepped:Connect(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if not ESPSettings.selfESP and player == game.Players.LocalPlayer then
            if ESPObjects[player] then
                ESPObjects[player]:Hide()
            end
            ESPObjects[player] = nil
            continue
        end

        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            if ESPObjects[player] then
                ESPObjects[player]:Hide()
            end
            ESPObjects[player] = nil
            continue
        end

        if not ESPObjects[player] then
            ESPObjects[player] = EntityESP.new(player)
        end

        ESPObjects[player]:Update()
    end

    -- Cleanup ESP objects for players that no longer exist
    for player, espObject in pairs(ESPObjects) do
        if not game.Players:FindFirstChild(player.Name) then
            espObject:Destroy()
            ESPObjects[player] = nil
        end
    end

    -- Update custom objects
    for _, customObject in pairs(ESPSettings.customObjects) do
        if not customObject.name then
            warn("Custom object name is nil, skipping")
            continue
        end

        if not customObject.position then
            warn("Custom object position is nil, skipping")
            continue
        end

        local position = customObject.position
        local distance = (position - workspace.CurrentCamera.CFrame.Position).Magnitude
        if distance > ESPSettings.maxEspDistance then continue end

        local labelPos, visibleOnScreen = worldToViewportPoint(workspace.CurrentCamera, position)

        local espObject = ESPObjects[customObject.name]
        if not espObject then
            espObject = createDrawing('Text')
            espObject.Center = true
            espObject.Outline = true
            espObject.Font = Drawing.Fonts.UI
            espObject.Size = ESPSettings.fontSize
            espObject.Color = customObject.color or ESPSettings.Color
            ESPObjects[customObject.name] = espObject
        end

        if visibleOnScreen then
            espObject.Visible = true
            espObject.Position = Vector2New(labelPos.X, labelPos.Y)
            espObject.Text = string.format("[%s] [%dm]", customObject.name, mathFloor(distance))
        else
            espObject.Visible = false
        end
    end
end)

return ESP
