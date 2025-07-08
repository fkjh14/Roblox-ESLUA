--[[
    ASSLUA GUI API v1.5
    - Behoben: Close-/Resize-Button skalieren nicht mehr mit.
    - Behoben: Unzuverlässige "Draggable"-Eigenschaft durch robuste, manuelle Implementierung ersetzt.
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local GUI = {}
GUI.__index = GUI

-- Konfiguration
local Config = {
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        Highlight = Color3.fromRGB(255, 0, 0),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        ButtonText = Color3.fromRGB(255, 255, 255),
        Divider = Color3.fromRGB(80, 80, 80)
    },
    DefaultSizes = {
        FrameWidth = 600,
        FrameHeight = 400,
        ButtonHeight = 40,
        CornerRadius = 15,
        Padding = 10
    }
}

local function createUICorner(parent)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, Config.DefaultSizes.CornerRadius)
    uiCorner.Parent = parent
end

-- Erstellt das Hauptfenster
function GUI.new(title)
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ASSLUA_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    self.MainFrame.Position = UDim2.new(0, 150, 0.5, -Config.DefaultSizes.FrameHeight / 2)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true -- Wichtig für die Mauseingabe
    -- self.MainFrame.Draggable = true -- Entfernt zugunsten der manuellen Logik
    self.MainFrame.Parent = self.ScreenGui
    createUICorner(self.MainFrame)

    -- Tab- und Content-Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, 0)
    self.TabContainer.BackgroundColor3 = Config.Colors.ButtonBackground
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    createUICorner(self.TabContainer)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, 0)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 0)
    self.ContentContainer.BackgroundColor3 = Config.Colors.Background
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    createUICorner(self.ContentContainer)

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "❌"
    closeButton.TextColor3 = Config.Colors.ButtonText
    closeButton.ZIndex = 2
    closeButton.Parent = self.MainFrame
    closeButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)

    self.Tabs = {}
    self.ActiveTab = nil

    self:_createResizeHandle()
    self:_setupDynamicScaling()
    self:_setupManualDrag() -- NEU: Manuelle Verschiebe-Logik aktivieren

    -- Globale Logik
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F1 then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    return self
end

-- CreateTab und die Widget-Funktionen (AddButton etc.) bleiben unverändert
function GUI:CreateTab(name)
    local tab = {}
    tab.Name = name
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 50)
    tabButton.BackgroundColor3 = Config.Colors.ButtonBackground
    tabButton.TextColor3 = Config.Colors.ButtonText
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 18
    tabButton.Text = name
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer
    createUICorner(tabButton)

    tab.ContentFrame = Instance.new("ScrollingFrame")
    tab.ContentFrame.Name = name .. "Content"
    tab.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    tab.ContentFrame.BackgroundTransparency = 1
    tab.ContentFrame.BorderSizePixel = 0
    tab.ContentFrame.Visible = false
    tab.ContentFrame.ClipsDescendants = true
    tab.ContentFrame.Parent = self.ContentContainer
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, Config.DefaultSizes.Padding / 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = tab.ContentFrame
    local framePadding = Instance.new("UIPadding")
    framePadding.PaddingTop = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingBottom = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingLeft = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingRight = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.Parent = tab.ContentFrame

    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.ContentFrame.Visible = false
        end
        tab.ContentFrame.Visible = true
        self.ActiveTab = tab
    end)

    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}
    if not self.ActiveTab then pcall(function() tabButton.MouseButton1Click:Fire() end) end
    
    local tabApi = {}
    
    function tabApi:AddButton(options)
        local button = Instance.new("TextButton")
        button.Name = options.text or "Button"
        button.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        button.BackgroundColor3 = Config.Colors.ButtonBackground
        button.TextColor3 = Config.Colors.ButtonText
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.Text = options.text
        button.Parent = tab.ContentFrame
        createUICorner(button)
        if options.callback then button.MouseButton1Click:Connect(options.callback) end
        return button
    end
    -- Die anderen Add-Funktionen wie AddToggle, AddDivider etc. sind hier aus Platzgründen nicht erneut abgebildet, bleiben aber identisch zur v1.4
    return tabApi
end

-- NEU: Manuelle Verschiebe-Logik
function GUI:_setupManualDrag()
    local frame = self.MainFrame
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- Beginne das Ziehen nur, wenn direkt auf den Hintergrund geklickt wird (nicht auf einen Button etc.)
            if input.UserInputState == Enum.UserInputState.Begin and input.GuiObject == frame then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end


-- VERBESSERT: Dynamische Skalierung mit Ausnahmen
function GUI:_setupDynamicScaling()
    local baseSize = self.MainFrame.AbsoluteSize
    
    -- Speichere die originalen Werte
    for _, element in ipairs(self.MainFrame:GetDescendants()) do
        if element:IsA("GuiObject") then
            element:SetAttribute("OriginalSize", element.Size)
            element:SetAttribute("OriginalPosition", element.Position)
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                 element:SetAttribute("OriginalTextSize", element.TextSize)
            end
        end
    end

    self.MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        local newSize = self.MainFrame.AbsoluteSize
        local scaleFactor = newSize / baseSize

        for _, element in ipairs(self.MainFrame:GetDescendants()) do
            -- KORRIGIERT: Ignoriere den Resize- und Close-Button
            if element.Name ~= "ResizeHandle" and element.Name ~= "CloseButton" then
                if element:IsA("GuiObject") then
                    local originalSize = element:GetAttribute("OriginalSize")
                    local originalPos = element:GetAttribute("OriginalPosition")
                    local originalTextSize = element:GetAttribute("OriginalTextSize")

                    if originalSize then
                        element.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * scaleFactor.X, originalSize.Y.Scale, originalSize.Y.Offset * scaleFactor.Y)
                    end
                    if originalPos then
                        element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset * scaleFactor.X, originalPos.Y.Scale, originalPos.Y.Offset * scaleFactor.Y)
                    end
                    if originalTextSize then
                        element.TextSize = math.clamp(originalTextSize * math.min(scaleFactor.X, scaleFactor.Y), 8, 48)
                    end
                end
            end
        end
    end)
end

function GUI:_createResizeHandle()
    -- Unverändert zur v1.4
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 3
    resizeHandle.Active = true
    resizeHandle.Parent = self.MainFrame
    createUICorner(resizeHandle)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startPos = UserInputService:GetMouseLocation()
            local startSize = self.MainFrame.AbsoluteSize
            local moveConn, releaseConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local currentPos = UserInputService:GetMouseLocation()
                    local delta = currentPos - startPos
                    self.MainFrame.Size = UDim2.new(0, math.max(350, startSize.X + delta.X), 0, math.max(250, startSize.Y + delta.Y))
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    releaseConn:Disconnect()
                end
            end)
        end
    end)
end

return GUI
