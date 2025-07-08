--[[
    ASSLUA GUI API v1.3 (Fehler- & Layout-Korrektur)
    Eine modulare Bibliothek zur strikten Trennung von UI und Spiellogik.
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local GUI = {}
GUI.__index = GUI

-- Konfiguration, die exakt dem Original-Skript entspricht
local Config = {
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        Highlight = Color3.fromRGB(255, 0, 0),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        ButtonText = Color3.fromRGB(255, 255, 255)
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
function GUI.new(title) -- Titel wird für Konsolen-Warnungen etc. beibehalten
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ASSLUA_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    -- KORRIGIERT: Originalgetreue Position und AnchorPoint (implizit 0,0)
    self.MainFrame.Position = UDim2.new(0, 150, 0.5, -Config.DefaultSizes.FrameHeight / 2)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    createUICorner(self.MainFrame)

    -- Schließen-Button direkt auf dem MainFrame, wie im Original
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10) -- Original-Position
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "❌"
    closeButton.Parent = self.MainFrame
    closeButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)

    -- Tab- und Content-Container, wie im Original
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, 0)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 0)
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

    self.Tabs = {}
    self.ActiveTab = nil

    self:_createResizeHandle() -- Resize-Handle-Logik

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

-- Erstellt einen neuen Tab
function GUI:CreateTab(name)
    local tab = {}
    tab.Name = name
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 50) -- Original-Größe
    tabButton.BackgroundColor3 = Config.Colors.ButtonBackground
    tabButton.TextColor3 = Config.Colors.ButtonText
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 18
    tabButton.Text = name
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer
    createUICorner(tabButton)

    -- Der Content-Frame für den Tab-Inhalt
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

    -- Tab-Wechsel-Logik
    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.ContentFrame.Visible = false
            self.Tabs[self.ActiveTab.Name].Button.BackgroundColor3 = Config.Colors.ButtonBackground
        end
        tab.ContentFrame.Visible = true
        -- Highlight wird hier nicht gesetzt, da es im Original auch keinen aktiven Zustand gab
        self.ActiveTab = tab
    end)

    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}

    if not self.ActiveTab then
        pcall(function() tabButton.MouseButton1Click:Fire() end)
    end
    
    local tabApi = {}
    
    function tabApi:AddButton(options)
        local button = Instance.new("TextButton")
        button.Name = options.text or "Button"
        button.Size = UDim2.new(1, -Config.DefaultSizes.Padding*2, 0, Config.DefaultSizes.ButtonHeight)
        button.BackgroundColor3 = Config.Colors.ButtonBackground
        button.TextColor3 = Config.Colors.ButtonText
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.Text = options.text
        button.Parent = tab.ContentFrame
        createUICorner(button)
        if options.callback then
            button.MouseButton1Click:Connect(options.callback)
        end
        return button
    end

    function tabApi:AddToggle(options)
        local state = options.default or false
        local button = self:AddButton({ text = options.text })
        
        local function updateVisuals()
            button.Text = options.text .. ": " .. (state and "ON" or "OFF")
        end
        
        button.MouseButton1Click:Connect(function()
            state = not state
            updateVisuals()
            if options.callback then
                options.callback(state)
            end
        end)
        
        updateVisuals()
        return button
    end
    
    -- Alle weiteren Add-Funktionen bleiben gleich... (AddLabeledInput, etc.)
    -- Sie werden hier der Vollständigkeit halber eingefügt.
    
    function tabApi:AddLabeledInput(options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -Config.DefaultSizes.Padding*2, 0, Config.DefaultSizes.ButtonHeight)
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

        input.FocusLost:Connect(function(enterPressed)
            if enterPressed and input.Text ~= "" then
                local value = input.Text
                if options.isNumber then value = tonumber(value) end
                if value and options.callback then options.callback(value) end
            end
        end)
        return container, input
    end

    function tabApi:AddLabel(text, size)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -Config.DefaultSizes.Padding*2, 0, size or 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = Config.Colors.ButtonText
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextWrapped = true
        label.Text = text
        label.Parent = tab.ContentFrame
        return label
    end

    return tabApi
end

function GUI:_createResizeHandle()
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Active = true
    resizeHandle.Parent = self.MainFrame
    createUICorner(resizeHandle)

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.MainFrame.Draggable = false
            local startPos = UserInputService:GetMouseLocation()
            local startSize = self.MainFrame.AbsoluteSize
            local moveConnection, releaseConnection
            
            moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
                -- KORRIGIERT: Fehlerbehandlung für Vector2/Vector3
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local currentMousePos = UserInputService:GetMouseLocation()
                    local delta = currentMousePos - startPos
                    local newWidth = math.max(350, startSize.X + delta.X)
                    local newHeight = math.max(250, startSize.Y + delta.Y)
                    self.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end)
            
            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                    self.MainFrame.Draggable = true
                end
            end)
        end
    end)
end

return GUI
