local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/thoth.lua"))()

local RunService, UserInputService, HttpService = Utility.RunService, Utility.UserInputService, Utility.HttpService

local ESP = {}

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

local scalarPointAX, scalarPointAY
local scalarPointBX, scalarPointBY

local labelOffset, tracerOffset
local boxOffsetTopRight, boxOffsetBottomLeft

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
    showObjectName = false,
    fontSize = 13 -- Default font size
}

do --// Entity ESP
    local EntityESP = {}
    EntityESP.__index = EntityESP
    EntityESP.__ClassName = 'entityESP'

    EntityESP.id = 0

    local emptyTable = {}

    function EntityESP.new(target, isPlayer)
        EntityESP.id += 1

        local self = setmetatable({}, EntityESP)

        self._id = EntityESP.id
        self._target = target
        self._isPlayer = isPlayer
        self._name = isPlayer and target.Name or "Object"

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

        local target = self._target
        local rootPart
        local isPlayer = self._isPlayer

        if isPlayer then
            local character = target.Character
            if not character then return self:Hide() end
            rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return self:Hide() end
        else
            if not target:IsA("BasePart") then return self:Hide() end
            rootPart = target
        end

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

        local text
        if isPlayer then
            local character = target.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if not humanoid then return self:Hide() end

            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local stamina = ""
            local dfValue = "None"

            if ESPSettings.showStamina then
                local staminaObj = game.ReplicatedStorage:FindFirstChild("Stats" .. target.Name)
                if staminaObj and staminaObj:FindFirstChild("Stamina") then
                    stamina = "[Stamina] [" .. staminaObj.Stamina.Value .. "]"
                end
            end

            if ESPSettings.showDFValue then
                local dfObj = game.ReplicatedStorage["Stats" .. target.Name]
                if dfObj and dfObj.Stats and dfObj.Stats:FindFirstChild("DF") then
                    dfValue = dfObj.Stats.DF.Value ~= "" and dfObj.Stats.DF.Value or "None"
                end
            end

            if ESPSettings.showPlayerName then
                text = string.format("[%s] [%d]\n[%d/%d]\n[%s]\n%s", self._name, mathFloor(distance), mathFloor(health), mathFloor(maxHealth), dfValue, stamina)
            else
                text = string.format("[%d/%d] [%dm]\n[%s]\n%s", mathFloor(health), mathFloor(maxHealth), mathFloor(distance), dfValue, stamina)
            end
        else
            if ESPSettings.showObjectName then
                text = string.format("[%s] [%dm]", self._name, mathFloor(distance))
            else
                text = string.format("[%dm]", mathFloor(distance))
            end
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

    local ESPObjects = {}

local function updateAllESPObjects()
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

        if not ESPObjects[player] then
            ESPObjects[player] = EntityESP.new(player, true)
        end

        ESPObjects[player]:Update()
    end

    -- Update ESP for custom objects
    for object, espObjectList in pairs(ESPObjects) do
        if type(espObjectList) == "table" then
            for i = #espObjectList, 1, -1 do
                local espObject = espObjectList[i]
                if not object or not object:IsA("BasePart") then
                    espObject:Destroy()
                    table.remove(espObjectList, i)
                else
                    espObject:Update()
                end
            end
            if #espObjectList == 0 then
                ESPObjects[object] = nil
            end
        end
    end
end

RunService.RenderStepped:Connect(updateAllESPObjects)

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

    function ESP:SetShowObjectName(state)
        ESPSettings.showObjectName = state
    end

    function ESP:SetFontSize(size)
        ESPSettings.fontSize = size
        for _, espObject in pairs(ESPObjects or {}) do
            if type(espObject) == "table" then
                for _, obj in pairs(espObject) do
                    if obj._label then
                        obj._label.Size = size
                    end
                end
            elseif espObject._label then
                espObject._label.Size = size
            end
        end
    end

    function ESP:AddESP(object, name)
        if not object or not object:IsA("BasePart") then return end
        local uniqueID = tostring(object:GetDebugId())
        if not ESPObjects[uniqueID] then
            ESPObjects[uniqueID] = EntityESP.new(object, false)
        end
        ESPObjects[uniqueID]._name = name
    end

    function ESP:RemoveESP(object)
        local uniqueID = tostring(object:GetDebugId())
        if ESPObjects[uniqueID] then
            ESPObjects[uniqueID]:Destroy()
            ESPObjects[uniqueID] = nil
        end
    end
end

return ESP
