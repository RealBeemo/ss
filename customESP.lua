local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBeemo/ss/main/thoth.lua"))()

local RunService, UserInputService, HttpService = Utility.RunService, Utility.UserInputService, Utility.HttpService

local CustomESP = {}

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
    Boxes = false,
    Tracers = false,
    Color = Color3.fromRGB(255, 255, 255),
    BoxesColor = Color3.fromRGB(255, 255, 255),
    TracersColor = Color3.fromRGB(255, 255, 255),
    proximityArrows = false,
    maxEspDistance = 1000,
    maxProximityArrowDistance = 500,
    showObjectName = false,
    fontSize = 13 -- Default font size
}

do --// Custom Object ESP
    CustomESP = {}
    CustomESP.__index = CustomESP
    CustomESP.__ClassName = 'customESP'

    CustomESP.id = 0

    local emptyTable = {}

    function CustomESP.new(object, name)
        CustomESP.id += 1

        local self = setmetatable({}, CustomESP)

        self._id = CustomESP.id
        self._object = object
        self._objectName = name or "Object"

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

    function CustomESP:Destroy()
        destroyRP(self._triangle)
        destroyRP(self._label)
        destroyRP(self._box)
        destroyRP(self._line)
    end

    function CustomESP:Hide()
        setRP(self._triangle, 'Visible', false)
        setRP(self._label, 'Visible', false)
        setRP(self._box, 'Visible', false)
        setRP(self._line, 'Visible', false)
    end

    function CustomESP:Update()
        if not ESPSettings.Enabled then
            self:Hide()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return self:Hide() end

        local object = self._object
        if not object or not object:IsA("BasePart") then return self:Hide() end

        local objectPosition = object.Position

        local labelPos, visibleOnScreen = worldToViewportPoint(camera, objectPosition)
        local triangle = self._triangle

        local distance = (objectPosition - camera.CFrame.Position).Magnitude
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
        if ESPSettings.showObjectName then
            text = string.format("[%s] [%dm]", self._objectName, mathFloor(distance))
        else
            text = string.format("[%dm]", mathFloor(distance))
        end

        local labelPosition = ESPSettings.Boxes and worldToViewportPoint(camera, objectPosition + Vector3.new(0, 3, 0)) or Vector2New(labelPos.X, labelPos.Y)

        setRP(label, 'Visible', visibleOnScreen)
        setRP(label, 'Position', labelPosition)
        setRP(label, 'Text', text)
        setRP(label, 'Color', espColor)
        setRP(label, 'Size', ESPSettings.fontSize) -- Update font size live

        if ESPSettings.Boxes then
            local topLeft = worldToViewportPoint(camera, objectPosition + Vector3.new(-3, 3, 0))
            local bottomRight = worldToViewportPoint(camera, objectPosition + Vector3.new(3, -3, 0))

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
            local linePosition = worldToViewportPoint(camera, objectPosition + tracerOffset)

            setRP(line, 'Visible', visibleOnScreen)
            setRP(line, 'From', getMouseLocation(UserInputService))
            setRP(line, 'To', Vector2New(linePosition.X, linePosition.Y))
            setRP(line, 'Color', ESPSettings.TracersColor)
        else
            setRP(line, 'Visible', false)
        end
    end

    function CustomESP:GetOffsetTrianglePosition(closestPoint, radiusOfDegree)
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

local CustomESPManager = {}

function CustomESPManager:Toggle(state)
    ESPSettings.Enabled = state
end

function CustomESPManager:SetBoxes(state)
    ESPSettings.Boxes = state
end

function CustomESPManager:SetTracers(state)
    ESPSettings.Tracers = state
end

function CustomESPManager:SetColor(color)
    ESPSettings.Color = color
end

function CustomESPManager:SetBoxesColor(color)
    ESPSettings.BoxesColor = color
end

function CustomESPManager:SetTracersColor(color)
    ESPSettings.TracersColor = color
end

function CustomESPManager:SetMaxDistance(distance)
    ESPSettings.maxEspDistance = distance
end

function CustomESPManager:SetProximityArrows(state)
    ESPSettings.proximityArrows = state
end

function CustomESPManager:SetMaxProximityArrowDistance(distance)
    ESPSettings.maxProximityArrowDistance = distance
end

function CustomESPManager:SetShowObjectName(state)
    ESPSettings.showObjectName = state
end

function CustomESPManager:SetFontSize(size)
    ESPSettings.fontSize = size
    for _, espObject in pairs(CustomESPObjects or {}) do
        if espObject._label then
            espObject._label.Size = size
        end
    end
end

local CustomESPObjects = {}

function CustomESPManager:AddESP(object, name)
    if not object or not object:IsA("BasePart") then return end
    if not CustomESPObjects[object] then
        CustomESPObjects[object] = CustomESP.new(object, name)
    end
end

function CustomESPManager:RemoveESP(object)
    if CustomESPObjects[object] then
        CustomESPObjects[object]:Destroy()
        CustomESPObjects[object] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then
        warn("Camera not found")
        return
    end

    -- Update ESP for custom objects
    for object, espObject in pairs(CustomESPObjects) do
        if not object or not object:IsA("BasePart") then
            espObject:Destroy()
            CustomESPObjects[object] = nil
            continue
        end

        espObject:Update()
    end

    -- Cleanup ESP objects for custom objects that no longer exist
    for object, espObject in pairs(CustomESPObjects) do
        if not object.Parent then
            espObject:Destroy()
            CustomESPObjects[object] = nil
        end
    end
end)

return CustomESPManager
