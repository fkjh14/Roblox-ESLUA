wait(0.5)
local TweenService = game:GetService("TweenService")

local ba = Instance.new("ScreenGui")
local ca = Instance.new("Frame")
local da = Instance.new("Frame")
local _b = Instance.new("TextLabel")
local ab = Instance.new("TextLabel")
local closeButton = Instance.new("TextButton")
local UICorner_ca = Instance.new("UICorner")  -- Abgerundete Ecken für das Hauptlabel
local UICorner_da = Instance.new("UICorner")  -- Abgerundete Ecken für den Frame
local UICorner_closeButton = Instance.new("UICorner")  -- Abgerundete Ecken für den Close-Button
local UIStroke_ca = Instance.new("UIStroke")  -- Hinzufügen eines Rahmens um das Hauptlabel
local UIStroke_da = Instance.new("UIStroke")  -- Hinzufügen eines Rahmens um den Frame
local UIGradient_ca = Instance.new("UIGradient")
local UIGradient_da = Instance.new("UIGradient")
local UICorner_title = Instance.new("UICorner")

local position = UDim2.new(0.698610067, 0, 0.098096624, 0)
local lastPosition = position  -- Variable zum Speichern der letzten Position

-- Setze die GUI
ba.Parent = game.CoreGui
ba.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hauptcontainer für GUI
ca.Parent = ba
ca.Active = true --c
ca.BackgroundColor3 = Color3.new(0.117, 0.117, 0.117)
ca.Draggable = true --c
ca.Position = position
local guiSize = UDim2.new(0, 400, 0, 180)  -- Größe des GUI-Elements
ca.Size = guiSize -- Größere Größe, um Platz für Schatten zu bieten
ca.ClipsDescendants = true
ca.ZIndex = 2

-- Hauptlabel (Titel)
local title = Instance.new("TextLabel")
title.Parent = ca
title.Active = true
title.BackgroundColor3 = Color3.new(0.117, 0.117, 0.117)
title.Size = UDim2.new(1, 0, 0, 60)
title.Font = Enum.Font.GothamBold
title.Text = "Anti AFK Script (Toggle with LeftCtrl + G)"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20

-- Abgerundete Ecken für das Hauptläbel
UICorner_title.Parent = title
UICorner_title.CornerRadius = UDim.new(0, 15)

-- Abgerundete Ecken für das Hauptlabel
UICorner_ca.Parent = ca
UICorner_ca.CornerRadius = UDim.new(0, 15)

-- Rahmen um das Hauptlabel
UIStroke_ca.Parent = ca
UIStroke_ca.Thickness = 2
UIStroke_ca.Color = Color3.fromRGB(0, 255, 255)

-- Farbverlauf für das Hauptlabel
UIGradient_ca.Parent = ca
UIGradient_ca.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 123, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 212, 255))
}

-- Frame (Hintergrund)
da.Parent = ca
da.BackgroundColor3 = Color3.new(0.137, 0.137, 0.137)
da.Position = UDim2.new(0, 0, 0.3, 0)
da.Size = UDim2.new(1, 0, 0.7, 0)

-- Abgerundete Ecken für den Frame
UICorner_da.Parent = da
UICorner_da.CornerRadius = UDim.new(0, 15)

-- Rahmen um den Frame
UIStroke_da.Parent = da
UIStroke_da.Thickness = 2
UIStroke_da.Color = Color3.fromRGB(0, 255, 255)

-- Farbverlauf für den Frame
UIGradient_da.Parent = da
UIGradient_da.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 200))
}

-- Footer Text
_b.Parent = da
_b.BackgroundColor3 = Color3.new(0.137, 0.137, 0.137)
_b.Position = UDim2.new(0, 0, 0.70, 0)
_b.Size = UDim2.new(1, 0, 0, 20)
_b.Font = Enum.Font.Gotham
_b.Text = "made by fkjh14"
_b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
_b.TextSize = 16

-- Status Text
ab.Parent = da
ab.BackgroundColor3 = Color3.new(0.137, 0.137, 0.137)
ab.Position = UDim2.new(0, 0, 0.2, 0)
ab.Size = UDim2.new(1, 0, 0, 50)
ab.Font = Enum.Font.GothamBold
ab.Text = "Status: Active"
ab.TextColor3 = Color3.new(0, 255, 255)
ab.TextSize = 18

-- Close-Button
closeButton.Parent = da
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 20

-- Abgerundete Ecken für den Close-Button
UICorner_closeButton.Parent = closeButton
UICorner_closeButton.CornerRadius = UDim.new(0, 5)

-- Funktion zum Schließen der GUI mit Animation
local bb = game:GetService("VirtualUser")
local idleConnection

local function DeconstructScript()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(ca, tweenInfo, {Position = UDim2.new(0.698610067, 0, -1, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        if idleConnection then
            idleConnection:Disconnect()
        end
        ba:Destroy()
    end)
end

closeButton.MouseButton1Click:Connect(DeconstructScript)

-- AFK-Schutz Script
idleConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
    bb:CaptureController()
    bb:ClickButton2(Vector2.new())
    local tweenInfo = TweenInfo.new(0.3)
    local changeText = TweenService:Create(ab, tweenInfo, {TextColor3 = Color3.new(1, 0.5, 0.5)})
    changeText:Play()
    ab.Text = "Roblox tried to kick you but I kicked it instead"
    wait(2)
    local resetText = TweenService:Create(ab, tweenInfo, {TextColor3 = Color3.new(0, 255, 255)})
    resetText:Play()
    ab.Text = "Status: Active"
end)

-- Funktion zum Ein- und Ausschalten der GUI mit Animation
local guiVisible = true
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
local screenSize = screenGui.AbsoluteSize
local centerX = (screenSize.X - guiSize.X.Offset) / 2
local centerY = (screenSize.Y - guiSize.Y.Offset) / 2

local function toggleGui()
    guiVisible = not guiVisible
    if guiVisible then
        local tween = TweenService:Create(ca, TweenInfo.new(0.5), {Position = lastPosition})
        tween:Play()
    else
        lastPosition = ca.Position  -- Speichere die aktuelle Position
        local tween = TweenService:Create(ca, TweenInfo.new(0.5), {Position = UDim2.new(0, centerX, -1, centerY)})
        tween:Play()
    end
end

-- Keybind für das Umschalten der GUI (LeftCtrl + G)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.G and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
            toggleGui()
        end
    end
end)
