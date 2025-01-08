-- Roblox Advanced GUI Library mit futuristischem Design
-- Diese Library basiert auf deinem ursprünglichen Code und wurde für bessere Wiederverwendbarkeit und Ästhetik verbessert.

local GuiLibrary = {}

-- Verhindert mehrfaches Laden des Skripts
if getgenv and getgenv().ATG_LOADED then
    error("AdvancedTabGui ist bereits geladen!", 0)
    return
end

if getgenv then
    getgenv().ATG_LOADED = true
end

-- AFK-Schutz Script
local VirtualUser = game:GetService("VirtualUser")
idleConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("Roblox tried to kick you, but I prevented it.")
end)

-- Funktion zum Erstellen der Haupt-GUI
function GuiLibrary:CreateGui(name)
    local screenGui = Instance.new("ScreenGui")
    local COREGUI = cloneref(game:GetService("CoreGui"))
    screenGui.Name = name or "AdvancedTabGui"
    screenGui.Parent = COREGUI
    return screenGui
end

-- Funktion zum Erstellen eines Hauptframes
function GuiLibrary:CreateMainFrame(parent, size, position)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = size or UDim2.new(0, 600, 0, 400)
    mainFrame.Position = position or UDim2.new(0, 150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = parent

    -- Abgerundete Ecken
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Schatteneffekt
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- Close Button erstellen
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 18
    closeButton.Text = "❌"
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        getgenv().ATG_LOADED = false
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
                player.Character:FindFirstChild("ESP_Highlight"):Destroy()
            end
        end
        parent:Destroy()
    end)

    -- Resize Funktion hinzufügen
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = mainFrame
    resizeHandle.Active = true

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainFrame.Draggable = false
            local startPos = input.Position
            local startSize = mainFrame.Size

            local moveConnection
            local releaseConnection

            moveConnection = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = moveInput.Position - startPos
                    local newWidth = math.max(200, startSize.X.Offset + delta.X)
                    local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
                    mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end)

            releaseConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                    mainFrame.Draggable = true
                end
            end)
        end
    end)

    return mainFrame
end

-- Funktion zum Erstellen eines Tab Containers
function GuiLibrary:CreateTabContainer(parent)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, 0)
    tabContainer.Position = UDim2.new(0, 0, 0, 0)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = tabContainer

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabContainer
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return tabContainer
end

-- Funktion zum Erstellen eines Inhaltscontainers
function GuiLibrary:CreateContentContainer(parent)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, 0)
    contentContainer.Position = UDim2.new(0, 150, 0, 0)
    contentContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = contentContainer

    return contentContainer
end

-- Funktion zum Erstellen eines Tabs
function GuiLibrary:CreateTab(tabName, tabContainer, contentContainer)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 50)
    tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 18
    tabButton.Text = tabName
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = tabButton

    local tabContent = Instance.new("Frame")
    tabContent.Name = tabName .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = contentContainer

    tabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(contentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        tabContent.Visible = true
    end)

    return tabContent
end

-- Beispiel zum Erstellen der GUI
function GuiLibrary:CreateExampleGui()
    local screenGui = self:CreateGui("AdvancedTabGui")
    local mainFrame = self:CreateMainFrame(screenGui)
    local tabContainer = self:CreateTabContainer(mainFrame)
    local contentContainer = self:CreateContentContainer(mainFrame)

    self:CreateTab("Home", tabContainer, contentContainer)
    self:CreateTab("Settings", tabContainer, contentContainer)
    self:CreateTab("Universal", tabContainer, contentContainer)
    self:CreateTab("About", tabContainer, contentContainer)
end

return GuiLibrary
