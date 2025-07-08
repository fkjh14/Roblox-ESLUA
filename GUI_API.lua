--[[
    ASSLUA GUI API v2.0 (Final)
    - Kombiniert das stabile Layout von v1.1 mit den robusten Funktionen von v1.8.
    - Drag, Resize und Scaling funktionieren jetzt korrekt mit dem ursprünglichen Layout.
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local GUI = {}
GUI.__index = GUI

-- Konfiguration
local Config = {
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        ButtonText = Color3.fromRGB(255, 255, 255),
        Divider = Color3.fromRGB(80, 80, 80)
    },
    DefaultSizes = {
        FrameWidth = 600,
        FrameHeight = 400,
        ButtonHeight = 40,
        CornerRadius = 15,
        Padding = 10,
        DragBarHeight = 30
    }
}

local function createUICorner(parent)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, Config.DefaultSizes.CornerRadius)
    uiCorner.Parent = parent
end

-- ## GUI.new - Dein stabiles Layout mit den neuen Funktionen ##
function GUI.new(title)
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "ASSLUA_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Dein gewünschtes MainFrame-Layout
    self.MainFrame = Instance.new("Frame", self.ScreenGui)
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    self.MainFrame.Position = UDim2.new(0, 150, 0.5, -Config.DefaultSizes.FrameHeight / 2)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    createUICorner(self.MainFrame)

    -- Funktionale Elemente aus v1.8
    self.DragBar = Instance.new("Frame", self.MainFrame)
    self.DragBar.Name = "DragBar"
    self.DragBar.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.DragBarHeight)
    self.DragBar.Position = UDim2.fromScale(0, 0)
    self.DragBar.BackgroundTransparency = 1
    self.DragBar.ZIndex = 2
    
    -- Angepasste Container-Positionen
    self.TabContainer = Instance.new("Frame", self.MainFrame)
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -Config.DefaultSizes.DragBarHeight)
    self.TabContainer.Position = UDim2.new(0, 0, 0, Config.DefaultSizes.DragBarHeight)
    self.TabContainer.BackgroundColor3 = Config.Colors.ButtonBackground
    self.TabContainer.BorderSizePixel = 0
    createUICorner(self.TabContainer)
    local tabLayout = Instance.new("UIListLayout", self.TabContainer)
    local tabPadding = Instance.new("UIPadding", self.TabContainer)
    tabPadding.PaddingTop = UDim.new(0, 5); tabPadding.PaddingLeft = UDim.new(0, 5); tabPadding.PaddingRight = UDim.new(0, 5)

    self.ContentContainer = Instance.new("Frame", self.MainFrame)
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -Config.DefaultSizes.DragBarHeight)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, Config.DefaultSizes.DragBarHeight)
    self.ContentContainer.BackgroundColor3 = Config.Colors.Background
    self.ContentContainer.BorderSizePixel = 0
    createUICorner(self.ContentContainer)

    local closeButton = Instance.new("TextButton", self.MainFrame)
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "❌"
    closeButton.TextColor3 = Config.Colors.ButtonText
    closeButton.ZIndex = 3
    closeButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)
    
    self.Tabs = {}
    self.ActiveTab = nil

    self:_createDragBar()
    self:_createResizeHandle()
    self:_setupDynamicScaling()

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F1 then self.MainFrame.Visible = not self.MainFrame.Visible end
    end)
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
    end)

    return self
end

function GUI:_setupDynamicScaling()
    self.MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        local dragBarHeight = self.DragBar.AbsoluteSize.Y
        self.TabContainer.Size = UDim2.new(0, 150, 1, -dragBarHeight)
        self.ContentContainer.Size = UDim2.new(1, -150, 1, -dragBarHeight)
    end)
end

function GUI:CreateTab(name)
    -- ... (diese Funktion ist vollständig und korrekt)
    local tab = {}
    local tabButton = Instance.new("TextButton", self.TabContainer)
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 40)
    tabButton.BackgroundColor3 = Config.Colors.ButtonBackground
    tabButton.TextColor3 = Config.Colors.ButtonText
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 18
    tabButton.Text = name
    createUICorner(tabButton)
    tab.ContentFrame = Instance.new("ScrollingFrame", self.ContentContainer)
    tab.ContentFrame.Name = name .. "Content"
    tab.ContentFrame.Size = UDim2.fromScale(1, 1)
    tab.ContentFrame.BackgroundTransparency = 1
    tab.ContentFrame.BorderSizePixel = 0
    tab.ContentFrame.Visible = false
    local listLayout = Instance.new("UIListLayout", tab.ContentFrame)
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local framePadding = Instance.new("UIPadding", tab.ContentFrame)
    framePadding.PaddingLeft = UDim.new(0, 10); framePadding.PaddingRight = UDim.new(0, 10); framePadding.PaddingTop = UDim.new(0, 10)
    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveTab then self.ActiveTab.ContentFrame.Visible = false end
        tab.ContentFrame.Visible = true; self.ActiveTab = tab
    end)
    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}
    if not self.ActiveTab then pcall(function() tabButton.MouseButton1Click:Fire() end) end
    local tabApi = {}
    function tabApi:AddButton(options) local button = Instance.new("TextButton", tab.ContentFrame); button.Name = options.text or "Button"; button.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight); button.BackgroundColor3 = Config.Colors.ButtonBackground; button.TextColor3 = Config.Colors.ButtonText; button.Font = Enum.Font.SourceSansBold; button.TextSize = 16; button.Text = options.text; createUICorner(button); if options.callback then button.MouseButton1Click:Connect(options.callback) end; return button end
    function tabApi:AddToggle(options) local state = options.default or false; local button = self:AddButton({ text = options.text }); local function updateVisuals() button.Text = options.text .. ": " .. (state and "ON" or "OFF") end; button.MouseButton1Click:Connect(function() state = not state; updateVisuals(); if options.callback then options.callback(state) end end); updateVisuals(); return button end
    function tabApi:AddDivider() local divider = Instance.new("Frame", tab.ContentFrame); divider.Name = "Divider"; divider.Size = UDim2.new(1, 0, 0, 2); divider.BackgroundColor3 = Config.Colors.Divider; divider.BorderSizePixel = 0; return divider end
    function tabApi:AddLabel(text) local label = Instance.new("TextLabel", tab.ContentFrame); label.Name = "Label"; label.Size = UDim2.new(1, 0, 0, 30); label.BackgroundTransparency = 1; label.TextColor3 = Config.Colors.ButtonText; label.Font = Enum.Font.SourceSans; label.TextSize = 16; label.TextWrapped = true; label.Text = text; return label end
    return tabApi
end

function GUI:_createDragBar()
    local dragBar = self.DragBar
    local dragging, dragStart, frameStart
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, frameStart = true, input.Position, self.MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
end

function GUI:_createResizeHandle()
    local resizeHandle = Instance.new("Frame", self.MainFrame)
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 3
    resizeHandle.Active = true
    createUICorner(resizeHandle)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startPos, startSize = UserInputService:GetMouseLocation(), self.MainFrame.AbsoluteSize
            local moveConn, releaseConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = UserInputService:GetMouseLocation() - startPos
                    self.MainFrame.Size = UDim2.new(0, math.max(350, startSize.X+delta.X), 0, math.max(250, startSize.Y+delta.Y))
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect(); releaseConn:Disconnect() end
            end)
        end
    end)
end

return GUI
