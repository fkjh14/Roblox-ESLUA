--[[
    ASSLUA GUI API v1.0
    Eine modulare Bibliothek zur einfachen Erstellung von Benutzeroberflächen.
	A Simple Script LUA GUI
]]

-- Verhindert mehrfaches Laden des Skripts
if getgenv and getgenv().ATG_LOADED then
    error("ASSLUA GUI ist bereits geladen!", 0)
    return
end

if getgenv then
    getgenv().ATG_LOADED = true
end

-- Dienste cachen
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local GUI = {}
GUI.__index = GUI

-- Hauptkonfiguration
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
        ButtonWidth = 200,
        ButtonHeight = 50,
        CornerRadius = 15
    }
}

-- Hilfsfunktion: Erstelle eine UI-Ecke
local function createUICorner(parent, cornerRadius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, cornerRadius)
    uiCorner.Parent = parent
end

-- Hauptfenster-Erstellung
function GUI.new(title)
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ASSLUA"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    self.MainFrame.Position = UDim2.new(0, 150, 0.5, -Config.DefaultSizes.FrameHeight / 2)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Visible = scriptContext.isVisible
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    createUICorner(self.MainFrame, Config.DefaultSizes.CornerRadius)

    -- Tab- und Content-Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, 0)
	self.TabContainer.Position = UDim2.new(0, 0, 0, 0)
    self.TabContainer.BackgroundColor3 = Config.Colors.ButtonBackground
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    createUICorner(self.TabContainer, Config.DefaultSizes.CornerRadius)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = self.TabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = self.TabContainer

    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, 0)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 0)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame

    self.Tabs = {}
    self.ActiveTab = nil

    self:_createHeader(title)
    self:_createResizeHandle()

    -- Sichtbarkeit per Hotkey (F1)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F1 then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
    
    -- AFK-Schutz
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    return self
end

function GUI:_createHeader(title)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Config.Colors.ButtonBackground
    header.BorderSizePixel = 0
    header.Parent = self.MainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Config.Colors.ButtonBackground
    titleLabel.TextColor3 = Config.Colors.ButtonText
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0,15)
    titlePadding.Parent = titleLabel
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Config.Colors.ButtonBackground
    closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "X"
    closeButton.Parent = header

    closeButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
        if getgenv then getgenv().AdvancedGuiApiLoaded = false end
    end)
end

function GUI:_createResizeHandle()
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 15, 0, 15)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundColor3 = Config.Colors.ButtonBackground
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
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = moveInput.Position - startPos
                    local newWidth = math.max(450, startSize.X + delta.X)
                    local newHeight = math.max(300, startSize.Y + delta.Y)
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

-- Tab-Erstellung
function GUI:CreateTab(name)
    local tab = {}
    tab.Name = name
    
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = Config.Colors.ButtonBackground
    tabButton.TextColor3 = Config.Colors.ButtonText
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 18
    tabButton.Text = name
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer
    createUICorner(tabButton)

    -- Tab Content Frame
    tab.ContentFrame = Instance.new("ScrollingFrame")
    tab.ContentFrame.Name = name .. "Content"
    tab.ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    tab.ContentFrame.BackgroundTransparency = 1
    tab.ContentFrame.BorderSizePixel = 0
    tab.ContentFrame.Visible = false
    tab.ContentFrame.Parent = self.ContentContainer
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, Config.DefaultSizes.Padding)
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
        tabButton.BackgroundColor3 = Config.Colors.Highlight
        self.ActiveTab = tab
    end)

    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}

    -- Setze ersten Tab als aktiv
    if not self.ActiveTab then
        pcall(function()
            tabButton.MouseButton1Click:Fire()
        end)
    end
    
    -- Methoden für den Tab zurückgeben
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
        if options.callback then
            button.MouseButton1Click:Connect(options.callback)
        end
        return button
    end

    function tabApi:AddToggle(options)
        local state = options.default or false
        local button = Instance.new("TextButton")
        button.Name = options.text or "Toggle"
        button.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        button.BackgroundColor3 = Config.Colors.ButtonBackground
        button.TextColor3 = Config.Colors.ButtonText
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.Parent = tab.ContentFrame
        createUICorner(button)
        
        local function updateText()
            button.Text = options.text .. ": " .. (state and "ON" or "OFF")
            button.BackgroundColor3 = state and Config.Colors.Highlight or Config.Colors.ButtonBackground
        end
        
        button.MouseButton1Click:Connect(function()
            state = not state
            updateText()
            if options.callback then
                options.callback(state)
            end
        end)
        
        updateText()
        return button
    end
    
    function tabApi:AddLabeledInput(options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        container.BackgroundTransparency = 1
        container.Parent = tab.ContentFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Config.Colors.ButtonText
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Text = options.label
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.6, 0, 1, 0)
        input.Position = UDim2.new(0.4, 0, 0, 0)
        input.BackgroundColor3 = Config.Colors.ButtonBackground
        input.TextColor3 = Config.Colors.ButtonText
        input.Font = Enum.Font.SourceSans
        input.TextSize = 16
        input.PlaceholderText = options.placeholder or ""
        input.Parent = container
        createUICorner(input)

        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local value = input.Text
                if options.isNumber then
                    value = tonumber(value)
                end
                if value and options.callback then
                    options.callback(value)
                end
            end
        end)
        return container, input
    end

    function tabApi:AddLabel(text, size)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, size or 30)
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

if getgenv then
    getgenv().AdvancedGuiApi = GUI
    getgenv().AdvancedGuiApiLoaded = true
end

return GUI
