--[[
    ASSLUA GUI API v1.1
    Eine modulare Bibliothek zur strikten Trennung von UI und Spiellogik.
    A Simple Script LUA GUI
]]

-- Dienste, die die API intern benötigt
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local GUI = {}
GUI.__index = GUI

-- Hauptkonfiguration für das Aussehen
local Config = {
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        TabContainer = Color3.fromRGB(40, 40, 40),
        ContentContainer = Color3.fromRGB(35, 35, 35),
        Highlight = Color3.fromRGB(200, 40, 40),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        ButtonText = Color3.fromRGB(255, 255, 255)
    },
    DefaultSizes = {
        FrameWidth = 600,
        FrameHeight = 400,
        ButtonHeight = 40,
        CornerRadius = 8,
        Padding = 10
    }
}

-- Hilfsfunktion: Erstellt eine UI-Ecke
local function createUICorner(parent)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, Config.DefaultSizes.CornerRadius)
    uiCorner.Parent = parent
end

-- ## HAUPTFUNKTIONEN ##

-- Erstellt das Hauptfenster und gibt das Window-Objekt zurück
function GUI.new(title)
    local self = setmetatable({}, GUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ASSLUA_GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.DefaultSizes.FrameWidth, 0, Config.DefaultSizes.FrameHeight)
    self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    createUICorner(self.MainFrame)

    -- Tab- und Content-Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, 0)
    self.TabContainer.BackgroundColor3 = Config.Colors.TabContainer
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    createUICorner(self.TabContainer)
    
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
    
    -- AFK-Schutz (ohne externe Logik, gehört zur GUI-Session)
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    return self
end

-- Erstellt einen neuen Tab und gibt ein Tab-API-Objekt zurück
function GUI:CreateTab(name)
    local tab = {}
    tab.Name = name
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = Config.Colors.TabContainer
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
    tab.ContentFrame.BackgroundColor3 = Config.Colors.ContentContainer
    tab.ContentFrame.BorderSizePixel = 0
    tab.ContentFrame.Visible = false
    tab.ContentFrame.Parent = self.ContentContainer
    createUICorner(tab.ContentFrame)
    
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
            self.Tabs[self.ActiveTab.Name].Button.BackgroundColor3 = Config.Colors.TabContainer
        end
        tab.ContentFrame.Visible = true
        tabButton.BackgroundColor3 = Config.Colors.Highlight
        self.ActiveTab = tab
    end)

    self.Tabs[name] = {Button = tabButton, Frame = tab.ContentFrame}

    if not self.ActiveTab then
        pcall(function() tabButton.MouseButton1Click:Fire() end)
    end
    
    -- ## TAB-API (Methoden zum Hinzufügen von Elementen) ##
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
        local button = self:AddButton({ text = options.text })
        
        local function updateVisuals()
            button.Text = options.text .. ": " .. (state and "ON" or "OFF")
            button.BackgroundColor3 = state and Config.Colors.Highlight or Config.Colors.ButtonBackground
        end
        
        button.MouseButton1Click:Connect(function()
            state = not state
            updateVisuals()
            if options.callback then
                options.callback(state)
            end
        end)
        
        updateVisuals() -- Initial state
        return button
    end
    
    function tabApi:AddLabeledInput(options)
        local container = Instance.new("Frame")
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
        label.Size = UDim2.new(1, 0, 0, size or 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = Config.Colors.ButtonText
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextWrapped = true
        label.Text = text
        label.Parent = tab.ContentFrame
        return label
    end

    function tabApi:AddChatBypass(options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, Config.DefaultSizes.ButtonHeight)
        container.BackgroundTransparency = 1
        container.LayoutOrder = 100
        container.Parent = tab.ContentFrame
        local list = Instance.new("UIListLayout")
        list.FillDirection = Enum.FillDirection.Horizontal
        list.Padding = UDim.new(0, 5)
        list.Parent = container

        local input = Instance.new("TextBox")
        input.Name = "ChatInput"
        input.Size = UDim2.new(1, -85, 1, 0)
        input.BackgroundColor3 = Config.Colors.ButtonBackground
        input.TextColor3 = Config.Colors.ButtonText
        input.Font = Enum.Font.SourceSans
        input.TextSize = 16
        input.PlaceholderText = options.placeholder or "Nachricht..."
        input.Parent = container
        createUICorner(input)
        
        local sendButton = Instance.new("TextButton")
        sendButton.Name = "SendButton"
        sendButton.Size = UDim2.new(0, 80, 1, 0)
        sendButton.BackgroundColor3 = Config.Colors.ButtonBackground
        sendButton.TextColor3 = Config.Colors.ButtonText
        sendButton.Font = Enum.Font.SourceSansBold
        sendButton.TextSize = 16
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
    
    function tabApi:AddEventSpy(options)
        -- API erstellt die komplexe UI-Struktur
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, -Config.DefaultSizes.ButtonHeight - 10)
        container.BackgroundTransparency = 1
        container.Parent = tab.ContentFrame
        
        local eventList = Instance.new("ScrollingFrame")
        eventList.Size = UDim2.new(1, 0, 1, 0)
        eventList.BackgroundColor3 = Config.Colors.ButtonBackground
        eventList.Parent = container
        createUICorner(eventList)
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = eventList
        
        -- API gibt eine Methode zurück, mit der die Logik neue Events in die UI eintragen kann
        local eventSpyApi = {}
        function eventSpyApi:Log(eventData)
            local logButton = Instance.new("TextButton")
            logButton.Size = UDim2.new(1, -10, 0, 25)
            logButton.Position = UDim2.new(0, 5, 0, 0)
            logButton.Text = string.format("%s | %s", eventData.direction, eventData.name)
            logButton.TextColor3 = Color3.new(1, 1, 1)
            logButton.BackgroundColor3 = Config.Colors.Background
            logButton.Font = Enum.Font.SourceSans
            logButton.TextSize = 14
            logButton.Parent = eventList
            
            logButton.MouseButton1Click:Connect(function()
                -- Hier könnte man ein Detail-Fenster öffnen
                print(string.format("Event: %s | Args: %d", eventData.name, #eventData.args))
            end)
        end
        
        -- Der Scan-Button wird als normaler Toggle erstellt, seine Logik liegt aber außerhalb der API
        self:AddToggle({ text = "Scan Events", callback = options.scanCallback })
        
        return eventSpyApi
    end

    return tabApi
end

-- ## INTERNE HILFSFUNKTIONEN ##

function GUI:_createHeader(title)
    -- Erstellt den oberen Fensterbalken mit Titel und Schließen-Button
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Config.Colors.TabContainer
    header.BorderSizePixel = 0
    header.Parent = self.MainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.BackgroundColor3 = header.BackgroundColor3
    titleLabel.TextColor3 = Config.Colors.ButtonText
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Text = "  " .. title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = header.BackgroundColor3
    closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Text = "X"
    closeButton.Parent = header
    closeButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)
end

function GUI:_createResizeHandle()
    -- Erstellt den Anfasser zum Ändern der Fenstergröße
    local resizeHandle = Instance.new("ImageButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 15, 0, 15)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundColor3 = Config.Colors.TabContainer
    resizeHandle.Image = "rbxassetid://5006322303" -- Ein kleines Dreieck-Icon
    resizeHandle.ImageColor3 = Config.Colors.ButtonText
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
                    self.MainFrame.Size = UDim2.new(0, math.max(450, startSize.X + delta.X), 0, math.max(300, startSize.Y + delta.Y))
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
