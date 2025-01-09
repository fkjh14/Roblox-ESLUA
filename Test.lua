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

    return mainFrame
end

-- Funktion zum Hinzufügen eines Schatteneffekts
function GuiLibrary:AddShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = parent.Size + UDim2.new(0, 20, 0, 20)
    shadow.Position = parent.Position - UDim2.new(0, 10, 0, 10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent

    return shadow
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
    self:AddShadow(mainFrame)

    local tabContainer = self:CreateTabContainer(mainFrame)
    local contentContainer = self:CreateContentContainer(mainFrame)

    self:CreateTab("Home", tabContainer, contentContainer)
    self:CreateTab("Settings", tabContainer, contentContainer)
    self:CreateTab("Universal", tabContainer, contentContainer)
    self:CreateTab("About", tabContainer, contentContainer)
end

return GuiLibrary
