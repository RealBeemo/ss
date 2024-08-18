local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/thoth.lua"))()

local RunService, UserInputService, HttpService = Utility.RunService, Utility.UserInputService, Utility.HttpService

local EntityESP = {}
local CustomObjects = {}
local CustomColors = {}

local worldToViewportPoint = clonefunction(Instance.new('Camera').WorldToViewportPoint)
local getMouseLocation = clonefunction(UserInputService.GetMouseLocation)

local id = HttpService:GenerateGUID(false)

local vector3New = Vector3.new
local Vector2New = Vector2.new

local mathFloor = math.floor

local mathRad = math.rad
local mathCos = math.cos
local mathSin = math.sin
local mathAtan2 = math.atan2

local TRIANGLE_ANGLE = mathRad(45)

local scalarPointAX, scalarPointAY
local scalarPointBX, scalarPointBY

local labelOffset, tracerOffset
local boxOffsetTopRight, boxOffsetBottomLeft

local realGetRPProperty

local function createDrawing(type)
    return Drawing.new(type)
end

local setRP = function(object, p, v)
    if object then
        object[p] = v
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

function CustomObject.new(id, name, position, color)
    local self = setmetatable({}, CustomObject)
    self._id = id
    self._name = name
    self._position = position
    self._color = color

    self._label = Drawing.new('Text')
    self._label.Visible = true
    self._label.Center = true
    self._label.Outline = true
    self._label.Text = name
    self._label.Font = 3
    self._label.Size = ESPSettings.fontSize
    self._label.Color = color

    print("Created CustomObject:", id, name, position, color)

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
    local distance = (self._position - camera.CFrame.Position).Magnitude

    if not visibleOnScreen or distance > ESPSettings.maxEspDistance then
        self:Hide()
        return
    end

    local text = string.format("[%dm] %s", mathFloor(distance), self._name)

    setRP(self._label, 'Visible', visibleOnScreen)
    setRP(self._label, 'Position', Vector2New(labelPos.X, labelPos.Y))
    setRP(self._label, 'Text', text)
    setRP(self._label, 'Color', self._color)
    setRP(self._label, 'Size', ESPSettings.fontSize) -- Update font size live
end

function CustomObject:Hide()
    setRP(self._label, 'Visible', false)
end

function CustomObject:Destroy()
    destroyRP(self._label)
    print("Destroyed CustomObject:", self._id, self._name)
end

function CustomObject:SetColor(color)
    self._color = color
    setRP(self._label, 'Color', color)
    print("Set color for CustomObject:", self._id, self._name, color)
end

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
        --self._triangle.Thickness = 0
        self._triangle.Color = Color3.fromRGB(255, 255, 255)
        self._triangle.Filled = true

        self._label = createDrawing('Text')
        self._label.Visible = false
        self._label.Center = true
        self._label.Outline = true
        self._label.Text = ''
        self._label.Font = 3
        self._label.Size = ESPSettings.fontSize -- Use default font size
        self._label.Color = Color3.fromRGB(255, 255, 255)

        self._box = createDrawing('Quad')
        self._box.Visible = false
        --self._box.Thickness = 1
        self._box.Filled = false
        self._box.Color = Color3.fromRGB(255, 255, 255)

        self._line = createDrawing('Line')
        self._line.Visible = false
        self._line.Color = Color3.fromRGB(255, 255, 255)

        print("Created EntityESP for player:", player.Name)

        return self
    end

    function EntityESP:Destroy()
        destroyRP(self._triangle)
        destroyRP(self._label)
        destroyRP(self._box)
        destroyRP(self._line)
        print("Destroyed EntityESP for player:", self._playerName)
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

        return Vector2New(mathFloor(pointX1), mathFloor(pointY1)), Vector2New(mathFloor(pointX2), mathFloor(pointY2)), Vector2New(mathFloor(pointX3))
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
    print("ESP Toggled:", state)
end

function ESP:SetPlayers(state)
    ESPSettings.Players = state
    print("Player ESP Toggled:", state)
end

function ESP:SetBoxes(state)
    ESPSettings.Boxes = state
    print("Box ESP Toggled:", state)
end

function ESP:SetTracers(state)
    ESPSettings.Tracers = state
    print("Tracer ESP Toggled:", state)
end

function ESP:SetColor(color)
    ESPSettings.Color = color
    print("Set ESP Color:", color)
end

function ESP:SetBoxesColor(color)
    ESPSettings.BoxesColor = color
    print("Set ESP Boxes Color:", color)
end

function ESP:SetTracersColor(color)
    ESPSettings.TracersColor = color
    print("Set ESP Tracers Color:", color)
end

function ESP:SetMaxDistance(distance)
    ESPSettings.maxEspDistance = distance
    print("Set Max ESP Distance:", distance)
end

function ESP:SetProximityArrows(state)
    ESPSettings.proximityArrows = state
    print("Proximity Arrows Toggled:", state)
end

function ESP:SetMaxProximityArrowDistance(distance)
    ESPSettings.maxProximityArrowDistance = distance
    print("Set Max Proximity Arrow Distance:", distance)
end

function ESP:SetShowStamina(state)
    ESPSettings.showStamina = state
    print("Show Stamina Toggled:", state)
end

function ESP:SetShowDFValue(state)
    ESPSettings.showDFValue = state
    print("Show DF Value Toggled:", state)
end

function ESP:SetShowPlayerName(state)
    ESPSettings.showPlayerName = state
    print("Show Player Name Toggled:", state)
end

function ESP:SetSelfESP(state)
    ESPSettings.selfESP = state
    print("Self ESP Toggled:", state)
end

function ESP:SetFontSize(size)
    ESPSettings.fontSize = size
    print("Set ESP Font Size:", size)
    for _, espObject in pairs(ESPObjects or {}) do
        if espObject._label then
            espObject._label.Size = size
        end
    end
end

function ESP:AddObject(id, name, position, color)
    local newObject = CustomObject.new(id, name, position, color)
    CustomObjects[id] = newObject
    print("Added ESP Object:", id, name, position, color)
end

function ESP:RemoveObject(id)
    local obj = CustomObjects[id]
    if obj then
        obj:Destroy()
        CustomObjects[id] = nil
        print("Removed ESP Object:", id)
    end
end

function ESP:RemoveObjectsByName(name)
    for id, obj in pairs(CustomObjects) do
        if obj._name == name then
            obj:Destroy()
            CustomObjects[id] = nil
            print("Removed ESP Objects by Name:", name)
        end
    end
end

function ESP:SetObjectColorByName(name, color)
    for id, obj in pairs(CustomObjects) do
        if obj._name == name then
            obj:SetColor(color)
        end
    end
    print("Set Color for ESP Objects by Name:", name, color)
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

        ESPObjects[player]:Update()
    end

    -- Update custom objects ESP
    for _, obj in pairs(CustomObjects) do
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
