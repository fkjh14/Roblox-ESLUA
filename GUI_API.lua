--[[
    ASSLUA GUI API v1.6
    - FINAL KORREKTUR: Alle fehlerhaften Instance.new-Aufrufe wurden korrigiert.
    - Behält alle Funktionen von v1.5 (Skalierung, Dragging etc.)
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
        Padding = 10,
        DragBarHeight = 30
    }
}

local function createUICorner(parent)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, Config.DefaultSizes.CornerRadius)
    uiCorner.Parent = parent
end

function GUI.new(title)
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ASSLUA_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    --- KORRIGIERT: Position und AnchorPoint für eine perfekte Zentrierung
    self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = false
    self.MainFrame.Draggable = false
    self.MainFrame.Parent = self.ScreenGui
    createUICorner(self.MainFrame)

    -- Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    --- KORRIGIERT: Position und Größe relativ zum zentrierten Parent
    self.TabContainer.Size = UDim2.new(0, 150, 1, -Config.DefaultSizes.DragBarHeight)
    self.TabContainer.Position = UDim2.new(0, 0, 0, Config.DefaultSizes.DragBarHeight)
    -- AnchorPoint für Kind-Elemente wird am besten auf (0,0) belassen, um die Positionierung zu vereinfachen
    self.TabContainer.BackgroundColor3 = Config.Colors.ButtonBackground
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    createUICorner(self.TabContainer)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer

    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    --- KORRIGIERT: Position und Größe relativ zum zentrierten Parent
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -Config.DefaultSizes.DragBarHeight)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, Config.DefaultSizes.DragBarHeight)
    self.ContentContainer.BackgroundColor3 = Config.Colors.Background
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    createUICorner(self.ContentContainer)

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    --- KORRIGIERT: Positionierung, um oben rechts im DragBar-Bereich zu sein
    closeButton.Position = UDim2.new(1, -5, 0, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "❌"
    closeButton.TextColor3 = Config.Colors.ButtonText
    closeButton.ZIndex = 3
    closeButton.Parent = self.MainFrame
    closeButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)
    
    self.Tabs = {}
    self.ActiveTab = nil

    self:_createDragBar()
    self:_createResizeHandle()
    self:_setupDynamicScaling()

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
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = tab.ContentFrame
    local framePadding = Instance.new("UIPadding")
    framePadding.PaddingTop = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingBottom = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingLeft = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.PaddingRight = UDim.new(0, Config.DefaultSizes.Padding)
    framePadding.Parent = tab.ContentFrame

    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveTab then self.ActiveTab.ContentFrame.Visible = false end
        tab.ContentFrame.Visible = true
        self.ActiveTab = tab
    end)

    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}
    if not self.ActiveTab then pcall(function() tabButton.MouseButton1Click:Fire() end) end
    
    -- API für Tab-Inhalte (jetzt vollständig)
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

    function tabApi:AddToggle(options)
        local state = options.default or false
        local button = self:AddButton({ text = options.text })
        local function updateVisuals() button.Text = options.text .. ": " .. (state and "ON" or "OFF") end
        button.MouseButton1Click:Connect(function()
            state = not state
            updateVisuals()
            if options.callback then options.callback(state) end
        end)
        updateVisuals()
        return button
    end

    -- WIEDER HINZUGEFÜGT
    function tabApi:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.TextColor3 = Config.Colors.ButtonText
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextWrapped = true
        label.Text = text
        label.Parent = tab.ContentFrame
        return label
    end

    -- WIEDER HINZUGEFÜGT
    function tabApi:AddLabeledInput(options)
        local container = Instance.new("Frame")
        container.Name = "LabeledInputContainer"
        container.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        container.BackgroundTransparency = 1
        container.Parent = tab.ContentFrame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Config.Colors.ButtonText
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Text = options.label
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.6, -5, 1, 0)
        input.Position = UDim2.new(0.4, 5, 0, 0)
        input.BackgroundColor3 = Config.Colors.ButtonBackground
        input.TextColor3 = Config.Colors.ButtonText
        input.Font = Enum.Font.SourceSans
        input.TextSize = 16
        input.PlaceholderText = options.placeholder or ""
        input.Parent = container
        createUICorner(input)
        input.FocusLost:Connect(function(enter)
            if enter and input.Text ~= "" then
                local value = input.Text
                if tonumber(value) then value = tonumber(value) end
                if options.callback then options.callback(value) end
            end
        end)
        return container, input
    end

    function tabApi:AddDivider()
        local divider = Instance.new("Frame")
        divider.Name = "Divider"
        divider.Size = UDim2.new(1, 0, 0, 2)
        divider.BackgroundColor3 = Config.Colors.Divider
        divider.BorderSizePixel = 0
        divider.Parent = tab.ContentFrame
        return divider
    end

    -- WIEDER HINZUGEFÜGT
    function tabApi:AddChatBypass(options)
        local container = Instance.new("Frame")
        container.Name = "ChatBypassContainer"
        container.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        container.BackgroundTransparency = 1
        container.Parent = tab.ContentFrame
        local list = Instance.new("UIListLayout")
        list.FillDirection = Enum.FillDirection.Horizontal
        list.Padding = UDim.new(0, 5)
        list.Parent = container
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -85, 1, 0)
        input.BackgroundColor3 = Config.Colors.ButtonBackground
        input.TextColor3 = Config.Colors.ButtonText
        input.PlaceholderText = options.placeholder or "..."
        input.Parent = container
        createUICorner(input)
        local sendButton = Instance.new("TextButton")
        sendButton.Size = UDim2.new(0, 80, 1, 0)
        sendButton.BackgroundColor3 = Config.Colors.ButtonBackground
        sendButton.TextColor3 = Config.Colors.ButtonText
        sendButton.Text = options.buttonText or "Senden"
        sendButton.Parent = container
        createUICorner(sendButton)
        local function sendMessage()
            if input.Text ~= "" and options.callback then
                options.callback(input.Text)
                input.Text = ""
            end
        end
        sendButton.MouseButton1Click:Connect(sendMessage)
        input.FocusLost:Connect(function(enter) if enter then sendMessage() end end)
        return container
    end

    -- WIEDER HINZUGEFÜGT
    function tabApi:AddEventSpy()
        local spyApi = {}
        local container = Instance.new("ScrollingFrame")
        container.Name = "EventSpyContainer"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundColor3 = Config.Colors.ButtonBackground
        container.BorderSizePixel = 1
        container.BorderColor3 = Config.Colors.Divider
        container.Parent = tab.ContentFrame
        createUICorner(container)
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = container

        function spyApi:Log(eventData)
            local logText = string.format("%s | %s", eventData.direction or "N/A", eventData.name or "Unnamed")
            local logButton = Instance.new("TextButton")
            logButton.Name = "LogEntry"
            logButton.Size = UDim2.new(1, -10, 0, 25)
            logButton.Text = logText
            logButton.TextColor3 = Color3.new(1, 1, 1)
            logButton.BackgroundColor3 = Config.Colors.Background
            logButton.Font = Enum.Font.SourceSans
            logButton.TextSize = 14
            logButton.Parent = container
            if eventData.callback then
                logButton.MouseButton1Click:Connect(function() eventData.callback(eventData) end)
            end
        end
        return spyApi
    end

    return tabApi
end

function GUI:_createDragBar()
    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.DragBarHeight)
    dragBar.BackgroundTransparency = 1
    dragBar.ZIndex = 2
    dragBar.Parent = self.MainFrame
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

function GUI:_setupDynamicScaling()
    local baseSize = self.MainFrame.AbsoluteSize
    for _, element in ipairs(self.MainFrame:GetDescendants()) do
        if element.Name ~= "CloseButton" and element.Name ~= "ResizeHandle" and element.Name ~= "DragBar" then
            if element:IsA("GuiObject") then
                element:SetAttribute("OriginalSize", element.Size)
                element:SetAttribute("OriginalPosition", element.Position)
                if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                     element:SetAttribute("OriginalTextSize", element.TextSize)
                end
            end
        end
    end
    self.MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        local scaleFactor = self.MainFrame.AbsoluteSize / baseSize
        for _, element in ipairs(self.MainFrame:GetDescendants()) do
            if element.Name ~= "CloseButton" and element.Name ~= "ResizeHandle" and element.Name ~= "DragBar" then
                if element:IsA("GuiObject") then
                    local oSize, oPos, oTextSize = element:GetAttribute("OriginalSize"), element:GetAttribute("OriginalPosition"), element:GetAttribute("OriginalTextSize")
                    if oSize then element.Size = UDim2.new(oSize.X.Scale, oSize.X.Offset*scaleFactor.X, oSize.Y.Scale, oSize.Y.Offset*scaleFactor.Y) end
                    if oPos then element.Position = UDim2.new(oPos.X.Scale, oPos.X.Offset*scaleFactor.X, oPos.Y.Scale, oPos.Y.Offset*scaleFactor.Y) end
                    if oTextSize then element.TextSize = math.clamp(oTextSize*math.min(scaleFactor.X, scaleFactor.Y), 8, 48) end
                end
            end
        end
    end)
end

function GUI:_createResizeHandle()
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
