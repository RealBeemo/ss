local ControlModule = {}

function ControlModule.new()
    local ContextActionService = game:GetService("ContextActionService")
    local HttpService = game:GetService("HttpService")

    local self = {
        forwardValue = 0,
        backwardValue = 0,
        leftValue = 0,
        rightValue = 0
    }

    local function handleMoveForward(actionName, inputState, inputObject)
        self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
        return Enum.ContextActionResult.Pass
    end

    local function handleMoveBackward(actionName, inputState, inputObject)
        self.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
        return Enum.ContextActionResult.Pass
    end

    local function handleMoveLeft(actionName, inputState, inputObject)
        self.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
        return Enum.ContextActionResult.Pass
    end

    local function handleMoveRight(actionName, inputState, inputObject)
        self.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
        return Enum.ContextActionResult.Pass
    end

    local forwardActionId = HttpService:GenerateGUID(false)
    local backwardActionId = HttpService:GenerateGUID(false)
    local leftActionId = HttpService:GenerateGUID(false)
    local rightActionId = HttpService:GenerateGUID(false)

    ContextActionService:BindAction(forwardActionId, handleMoveForward, false, Enum.KeyCode.W)
    ContextActionService:BindAction(backwardActionId, handleMoveBackward, false, Enum.KeyCode.S)
    ContextActionService:BindAction(leftActionId, handleMoveLeft, false, Enum.KeyCode.A)
    ContextActionService:BindAction(rightActionId, handleMoveRight, false, Enum.KeyCode.D)

    function self:GetMoveVector()
        return Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
    end

    return self
end

return ControlModule
