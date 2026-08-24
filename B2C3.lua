local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() or players.LocalPlayer

-- File configuration path para sa save/load
local configFileName = "IOHUB_Config.json"
local currentConfigData = {
    toggles = {},
    dropdowns = {}
}

-- Load saved config if exists
if readfile and pcall(readfile, configFileName) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(configFileName))
    end)
    if success and decoded then
        currentConfigData = decoded
    end
end

local function saveConfigToFile()
    if writefile then
        pcall(function()
            writefile(configFileName, HttpService:JSONEncode(currentConfigData))
        end)
    end
end

-- Main ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalMenuGui_Delta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = coreGui
else
    screenGui.Parent = coreGui
end

----------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------
local function showNotification(message)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 220, 0, 40)
    notifFrame.Position = UDim2.new(1, -235, 1, -60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifFrame.BackgroundTransparency = 0.2
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 999
    notifFrame.Parent = screenGui

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = notifFrame

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(150, 30, 50)
    nStroke.Thickness = 1
    nStroke.Parent = notifFrame

    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, 0, 1, 0)
    nText.BackgroundTransparency = 1
    nText.Text = message
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 11
    nText.ZIndex = 1000
    nText.Parent = notifFrame

    task.delay(2, function()
        local tw = TweenService:Create(notifFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tw:Play()
        TweenService:Create(nText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        tw.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

----------------------------------------------------
-- MAIN CONTAINER WINDOW
----------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 420)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false 
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

----------------------------------------------------
-- FLOATING TOGGLE IMAGE BUTTON
----------------------------------------------------
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "MenuToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 20, 0.5, -27) 
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://139934599708171" 
toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Active = true
toggleButton.Parent = screenGui

----------------------------------------------------
-- DRAGGING FEATURE
----------------------------------------------------
local userInputService = game:GetService("UserInputService")

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

----------------------------------------------------
-- TOGGLE LOGIC
----------------------------------------------------
local uiTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local isMenuOpen = false 
local isTweening = false 

local function minimizeToButton()
    if isTweening then return end
    isTweening = true
    
    local closeTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        mainFrame.Visible = false
        isMenuOpen = false
        isTweening = false
    end)
end

local function openMenu()
    if isTweening then return end
    isTweening = true
    
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0) 
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210)
    })
    openTween:Play()
    openTween.Completed:Connect(function()
        isMenuOpen = true
        isTweening = false
    end)
end

toggleButton.MouseButton1Click:Connect(function()
    if isMenuOpen then minimizeToButton() else openMenu() end
end)

----------------------------------------------------
-- TOP WINDOW CONTROL DOTS & TITLE
----------------------------------------------------
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(0, 60, 0, 20)
controlsFrame.Position = UDim2.new(1, -75, 0, 15)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local colors = {Color3.fromRGB(255, 95, 87), Color3.fromRGB(254, 188, 46), Color3.fromRGB(40, 200, 64)}
for i, color in ipairs(colors) do
    local dot = Instance.new("TextButton")
    dot.Name = "ControlDot" .. i
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, (i - 1) * 20, 0, 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Text = ""
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = controlsFrame
    dot.MouseButton1Click:Connect(minimizeToButton)
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IOHUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 15, 0, 12)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://10840244199" 
logo.ImageColor3 = Color3.fromRGB(255, 30, 30)
logo.Parent = mainFrame

----------------------------------------------------
-- NAVIGATION & PAGES SETUP
----------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame

local uiListSide = Instance.new("UIListLayout")
uiListSide.Padding = UDim.new(0, 8)
uiListSide.SortOrder = Enum.SortOrder.LayoutOrder
uiListSide.Parent = sidebar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -195, 1, -55)
contentFrame.Position = UDim2.new(0, 180, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BackgroundTransparency = 0.4
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local tabs = {}
local pages = {}
local activeTab = nil

local function createPageContainer()
    local scrollPage = Instance.new("ScrollingFrame")
    scrollPage.Size = UDim2.new(1, -10, 1, -15)
    scrollPage.Position = UDim2.new(0, 5, 0, 10)
    scrollPage.BackgroundTransparency = 1
    scrollPage.BorderSizePixel = 0
    scrollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollPage.ScrollBarThickness = 2
    scrollPage.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollPage.Visible = false
    scrollPage.Parent = contentFrame

    local uiListContent = Instance.new("UIListLayout")
    uiListContent.Padding = UDim.new(0, 10)
    uiListContent.SortOrder = Enum.SortOrder.LayoutOrder
    uiListContent.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListContent.Parent = scrollPage
    
    uiListContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, uiListContent.AbsoluteContentSize.Y + 20)
    end)

    return scrollPage
end

local function switchTab(tabName)
    for name, btnElements in pairs(tabs) do
        if name == tabName then
            btnElements.Button.BackgroundTransparency = 0.9
            btnElements.Icon.ImageColor3 = Color3.fromRGB(255, 100, 120)
            btnElements.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            if btnElements.Stroke then btnElements.Stroke.Enabled = true end
            pages[name].Visible = true
        else
            btnElements.Button.BackgroundTransparency = 1
            btnElements.Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            btnElements.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            if btnElements.Stroke then btnElements.Stroke.Enabled = false end
            pages[name].Visible = false
        end
    end
    activeTab = tabName
end

local function createSidebarTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.LayoutOrder = order
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 20, 40)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Enabled = false
    stroke.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 12, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    icon.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Parent = sidebar
    
    tabs[name] = {Button = btn, Icon = icon, Label = lbl, Stroke = stroke}
    pages[name] = createPageContainer()
end

----------------------------------------------------
-- MAIN DROPDOWN SECTION
----------------------------------------------------
local function createDropdownSection(pageName, sectionTitle)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local isOpen = false 
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.92, 0, 0, 40)
    dropContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = targetPage

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 40)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -28, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 40)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 8)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, 40)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- NESTED DROPDOWN SECTION
----------------------------------------------------
local function createNestedDropdownSection(parentContainer, sectionTitle)
    local isOpen = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -35, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 36)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 6)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- BUTTON CREATOR (Para sa Action Buttons tulad ng Save)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 100, 0, 26)
    actionBtn.Position = UDim2.new(1, -100, 0.5, -13)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50)
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "Save"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end

----------------------------------------------------
-- MULTI-SELECT DROPDOWN SELECTOR (FIXED SEARCH)
----------------------------------------------------
local function createDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    if not currentConfigData.dropdowns[title] then
        currentConfigData.dropdowns[title] = {}
    end
    local selectedItems = currentConfigData.dropdowns[title]
    local allSelected = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = "None selected"
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.92, 0, 0, 28)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search 🔎"
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.ClearTextOnFocus = false
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, 90)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}
    local allBtn = nil

    local function updateSelectedLabel()
        local count = 0
        local names = {}
        for item, isSel in pairs(selectedItems) do
            if isSel then
                count = count + 1
                table.insert(names, item)
            end
        end
        if count == 0 then
            selectedLbl.Text = "None selected"
        elseif count == #itemsListTable then
            selectedLbl.Text = "All selected"
        else
            selectedLbl.Text = table.concat(names, ", ")
        end
    end

    local function updateAllButtonState()
        if not allBtn then return end
        local allCurrentlySelected = true
        for _, itemText in ipairs(itemsListTable) do
            if not selectedItems[itemText] then
                allCurrentlySelected = false
                break
            end
        end
        allSelected = allCurrentlySelected
        
        allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
        allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
        allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
    end

    local function populateOptions(filter)
        -- Linisin nang lubusan ang lumang buttons para hindi magpatong-patong
        for _, btn in pairs(optionButtons) do 
            if btn.Button then btn.Button:Destroy() end 
        end
        optionButtons = {}
        if allBtn then allBtn:Destroy() allBtn = nil end

        -- I-trim at gawing lowercase ang filter para sa malinis na paghahanap
        local cleanFilter = string.lower(string.gsub(filter or "", "^%s*(.-)%s*$", "%1"))

        -- Ilagay ang "All" button kung pasok sa filter
        if cleanFilter == "" or string.find(string.lower("All"), cleanFilter) then
            allBtn = Instance.new("TextButton")
            allBtn.Size = UDim2.new(1, 0, 0, 26)
            allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
            allBtn.Text = "  All"
            allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            allBtn.TextSize = 11
            allBtn.TextXAlignment = Enum.TextXAlignment.Left

            local allCorner = Instance.new("UICorner")
            allCorner.CornerRadius = UDim.new(0, 4)
            allCorner.Parent = allBtn

            allBtn.MouseButton1Click:Connect(function()
                allSelected = not allSelected
                for _, itemText in ipairs(itemsListTable) do
                    selectedItems[itemText] = allSelected
                end
                updateAllButtonState()
                for _, btnData in pairs(optionButtons) do
                    local isSel = selectedItems[btnData.ItemName] == true
                    btnData.Button.BackgroundColor3 = isSel and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    btnData.Button.BackgroundTransparency = isSel and 0.2 or 0.5
                    btnData.Button.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    btnData.Button.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                end
                updateSelectedLabel()
                if callback then callback(selectedItems) end
            end)

            allBtn.Parent = scrollOptions
        end

        -- I-loop at i-filter ang mga item batay sa tinype sa search box
        for _, itemText in ipairs(itemsListTable) do
            local lowerItemText = string.lower(itemText)
            if cleanFilter == "" or string.find(lowerItemText, cleanFilter) then
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                
                local isSelected = selectedItems[itemText] == true
                optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
                optBtn.Text = "  " .. itemText
                optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.TextXAlignment = Enum.TextXAlignment.Left

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selectedItems[itemText] = not selectedItems[itemText]
                    
                    local nowSelected = selectedItems[itemText]
                    optBtn.BackgroundColor3 = nowSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    optBtn.BackgroundTransparency = nowSelected and 0.2 or 0.5
                    optBtn.TextColor3 = nowSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    optBtn.Font = nowSelected and Enum.Font.GothamBold or Enum.Font.Gotham

                    updateAllButtonState()
                    updateSelectedLabel()
                    if callback then callback(selectedItems) end
                end)

                optBtn.Parent = scrollOptions
                table.insert(optionButtons, {Button = optBtn, ItemName = itemText})
            end
        end

        updateAllButtonState()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            scrollOptions.Size = UDim2.new(0.92, 0, 0, optionListHeight)
            
            local totalTargetHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalTargetHeight)
        end
    end

    populateOptions("")
    updateSelectedLabel()
    if callback then callback(selectedItems) end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateOptions(searchBox.Text)
    end)

    optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
    end)

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalHeight)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end


----------------------------------------------------
-- SINGLE-SELECT DROPDOWN SELECTOR (Walang Search / Walang All)
----------------------------------------------------
local function createSingleDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    -- Gagamit tayo ng string value para sa single selection state
    if not currentConfigData.singleDropdowns then
        currentConfigData.singleDropdowns = {}
    end
    if not currentConfigData.singleDropdowns[title] then
        currentConfigData.singleDropdowns[title] = itemsListTable[1] or ""
    end
    
    local selectedValue = currentConfigData.singleDropdowns[title]
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = selectedValue ~= "" and selectedValue or "Select..."
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, #itemsListTable * 30 + 5)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}

    local function populateOptions()
        for _, btn in pairs(optionButtons) do btn:Destroy() end
        optionButtons = {}

        for _, itemText in ipairs(itemsListTable) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            
            local isSelected = (selectedValue == itemText)
            optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
            
            optBtn.Text = "  " .. itemText
            optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            optBtn.TextSize = 11
            optBtn.TextXAlignment = Enum.TextXAlignment.Left

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                selectedValue = itemText
                currentConfigData.singleDropdowns[title] = selectedValue
                selectedLbl.Text = selectedValue
                
                -- Isara ang dropdown pagkapili
                isOpen = false
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
                TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()

                populateOptions()
                if callback then callback(selectedValue) end
            end)

            optBtn.Parent = scrollOptions
            table.insert(optionButtons, optBtn)
        end
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 5)
    end

    populateOptions()
    if callback then callback(selectedValue) end

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local totalHeight = listLayout.AbsoluteContentSize.Y + 20
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end

----------------------------------------------------
-- ENTER TEXT / INPUT BOX (Para sa Custom Weight Target)
----------------------------------------------------
local function createEnterText(parentContainer, title, placeholder, defaultVal, callback)
    if not currentConfigData.inputs then
        currentConfigData.inputs = {}
    end
    if currentConfigData.inputs[title] == nil then
        currentConfigData.inputs[title] = tostring(defaultVal or "")
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parentContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 100, 0, 26)
    textBox.Position = UDim2.new(1, -108, 0.5, -13)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    textBox.BackgroundTransparency = 0.4
    textBox.Text = currentConfigData.inputs[title]
    textBox.PlaceholderText = placeholder or "Enter..."
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 11
    textBox.ClearTextOnFocus = false
    textBox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        local val = textBox.Text
        currentConfigData.inputs[title] = val
        if callback then
            callback(val)
        end
    end)

    return container
end



----------------------------------------------------
-- TOGGLE CREATOR
----------------------------------------------------
local function createToggle(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = currentConfigData.toggles[title] == true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applyState(state, immediate)
        enabled = state
        currentConfigData.toggles[title] = enabled
        if immediate then
            if enabled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicator.Position = UDim2.new(1, -15, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                indicator.Position = UDim2.new(0, 3, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        else
            if enabled then
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            else
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
        if callback then callback(enabled) end
    end

    applyState(enabled, true)
    
    toggleBtn.MouseButton1Click:Connect(function()
        applyState(not enabled, false)
    end)
    
    toggleBtn.Parent = row
    row.Parent = parentContainer
end

local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

----------------------------------------------------
-- TOGGLE CREATOR (May On/Off switch)
----------------------------------------------------
local function createToggle(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.92, 0, 0, 55)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 20)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 3, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = false
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        else
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        if callback then callback(enabled) end
    end)
    
    toggleBtn.Parent = row
    row.Parent = targetPage
end

----------------------------------------------------
-- 2. UPDATED BUTTON CREATOR (Malaking Rectangle + Mouse Icon)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 48) -- Swabe ang taas para sa dalawang linya ng text
    row.BackgroundTransparency = 1
    
    -- Ang buong row ay ginawang isang malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(1, 0, 1, 0)
    actionBtn.Position = UDim2.new(0, 0, 0, 0)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50) -- Kulay ng button mo
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "" -- Walang default text, gagamit tayo ng labels
    actionBtn.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    -- Spacing sa loob para sa mga teksto
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = actionBtn
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.8, 0, 0, 18)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Mouse Clicker Icon sa kanang dulo
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(1, -24, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🖱️"
    iconLabel.TextSize = 14
    iconLabel.Parent = actionBtn
    
    -- Click trigger ng button
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end


----------------------------------------------------
-- BAGONG BUTTON CREATOR (Para lang sa mga Standalone Buttons na may Mouse Pointer)
----------------------------------------------------
local function createCustomButton(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    -- Ang mismong malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = title .. "_CustomRectangle"
    actionBtn.Size = UDim2.new(0.92, 0, 0, 55) -- Malaking rectangle
    actionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Kulay na babagay sa background ng IOHUB mo
    actionBtn.BackgroundTransparency = 0.4
    actionBtn.Text = "" -- Alisin ang default button text
    actionBtn.AutoButtonColor = true

    -- Bilugan ang mga kanto ng rectangle
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn

    -- Spacing para hindi nakadikit ang mga letra sa gilid
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = actionBtn
    
    -- Title Label sa loob ng malaking button
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.Position = UDim2.new(0, 0, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label sa loob ng malaking button
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Ang Mouse Click Cursor Asset sa kanang dulo ng rectangle
    local mouseIcon = Instance.new("ImageLabel")
    mouseIcon.Name = "MousePointerIcon"
    mouseIcon.Size = UDim2.new(0, 22, 0, 22)
    mouseIcon.Position = UDim2.new(1, -25, 0.5, -11)
    mouseIcon.BackgroundTransparency = 1
    mouseIcon.Image = "rbxassetid://10734896206" -- Mouse click cursor icon asset
    mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    mouseIcon.Parent = actionBtn
    
    -- Click at Flash Effect para sa mouse pointer
    actionBtn.MouseButton1Click:Connect(function()
        mouseIcon.ImageColor3 = Color3.fromRGB(255, 100, 120)
        task.wait(0.1)
        mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        if callback then callback() end
    end)
    
    actionBtn.Parent = targetPage
end


-- ====================================================================
-- 3. SIDEBAR TABS & GROUPS DEFINITION
-- ====================================================================

createSidebarTab("Section 1", "rbxassetid://10723345479", 1)
createSidebarTab("Section 2", "rbxassetid://10723345479", 2)
createSidebarTab("Section 3", "rbxassetid://10723345479", 3)
createSidebarTab("Section 4", "rbxassetid://10723345479", 4)
createSidebarTab("Section 5", "rbxassetid://10723345479", 5)
createSidebarTab("Section 6", "rbxassetid://10723345479", 6)
createSidebarTab("Settings", "rbxassetid://10723345479", 7)



-- Kunin ang mga kailangang serbisyo
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Function para sa gilid na notification
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer




-- Loop Connections
local espConnection = nil




-- Helper 2: Dynamic Demon Hitbox Finder
local function getActiveMonsterHitbox()
	local maze = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("Maze")
	if not maze then return nil end
	
	local normalDemon = maze:FindFirstChild("GrinDemon")
	if normalDemon and normalDemon:FindFirstChild("Hitbox") then
		return normalDemon.Hitbox
	end
	
	local nmDemon = maze:FindFirstChild("GrinDemonNM")
	if nmDemon and nmDemon:FindFirstChild("Hitbox") then
		return nmDemon.Hitbox
	end
	return nil
end



-- Helper 4: Create Highlight Effect
local function createHighlightOnInstance(target)
	if not target then return end
	if target:FindFirstChild("CustomDemonESP") or (target.Parent and target.Parent:FindFirstChild("CustomDemonESP")) then 
		return 
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "CustomDemonESP"
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.4
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	
	if target:IsA("Model") then
		highlight.Parent = target
	else
		highlight.Parent = target.Parent or target
	end
end

-- Helper 5: Simultaneous ESP Scanner
local function updateSimultaneousESP(enable)
	local maze = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("Maze")
	if not enable then
		if maze then
			for _, v in ipairs(maze:GetDescendants()) do
				if v.Name == "CustomDemonESP" then v:Destroy() end
			end
		end
		return
	end
	if maze then
		local normalDemon = maze:FindFirstChild("GrinDemon")
		if normalDemon then
			local hitbox = normalDemon:FindFirstChild("Hitbox")
			if hitbox then createHighlightOnInstance(hitbox) else createHighlightOnInstance(normalDemon) end
		end
		local nmDemon = maze:FindFirstChild("GrinDemonNM")
		if nmDemon then
			local hitbox = nmDemon:FindFirstChild("Hitbox")
			if hitbox then createHighlightOnInstance(hitbox) else createHighlightOnInstance(nmDemon) end
		end
	end
end


-- Helper function para sa notification sa gilid
local function sendNotif(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3,
    })
end


-- Helper function para hindi paulit-ulit ang code sa teleport
local function teleport(cf)
    local character = game.Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = cf
    else
        sendNotif("Error", "Hindi makita ang HumanoidRootPart!")
    end
end





-- ====================================================================
-- SECTION TAB: AUTO FREE YOURSELF TOGGLE
-- ====================================================================
local autoFreeActive = false
local freeTask = nil

createToggle("Section 1", "Auto Free Yourself", "Automatically Click Free Yourself", function(state)
    autoFreeActive = state
    
    if autoFreeActive then
        notify("IOHUB", "Auto Free ON", 1.5)
        
        freeTask = task.spawn(function()
            while autoFreeActive do
                local replicatedStorage = game:GetService("ReplicatedStorage")
                local packages = replicatedStorage:FindFirstChild("Packages")
                local packet = packages and packages:FindFirstChild("Packet")
                local packetFunc = packet and packet:FindFirstChild("PacketFunction")
                
                if packetFunc and packetFunc:IsA("RemoteFunction") then
                    pcall(function()
                        packetFunc:InvokeServer(
                            0,
                            {
                                ["__args"] = {},
                                ["__tree"] = {
                                    [1] = "QuickTimeService",
                                    [2] = "Clicked"
                                },
                                ["__callType"] = 0
                            }
                        )
                    end)
                end
                
                -- Bilis ng pag-loop / pag-click para makalaya agad (pwede mong baguhin ang task.wait)
                task.wait(0.1)
            end
        end)
    else
        notify("IOHUB" , "Auto Free OFF", 1.5)
        autoFreeActive = false
        if freeTask then
            task.cancel(freeTask)
            freeTask = nil
        end
    end
end)


createToggle("Section 1", "Esp Monster", "Show Highlights GrinDemon", function(state)
	if state then -- Kapag pinindot at naging ON
		if espConnection then espConnection:Disconnect() end
		espConnection = RunService.RenderStepped:Connect(function()
			updateSimultaneousESP(true)
		end)
	else -- Kapag pinindot ulit at naging OFF
		if espConnection then
			espConnection:Disconnect()
			espConnection = nil
		end
		updateSimultaneousESP(false)
	end
end)


createCustomButton("Section 1", "Auto Spin", "Fire SpinModel Prompt", function()
    teleport(CFrame.new(-71.821, 49.343, 9.392))
    task.wait(0.5)
    
    local puzzleModel = workspace:FindFirstChild("Section1") 
        and workspace.Section1:FindFirstChild("Puzzle") 
        and workspace.Section1.Puzzle:FindFirstChild("SpinModel")
        
    local prompt = puzzleModel and puzzleModel:FindFirstChild("ProximityPrompt")
    
    if prompt then
        for i = 1, 14 do
            fireproximityprompt(prompt)
            task.wait(0.5)
        end
        sendNotif("IOHUB", "Spin Complete")
    else
        sendNotif("IOHUB", "Spin Prompt Not Found")
    end
end)

createCustomButton("Section 1", "Chase 1 Start" , "Start GrinDemon Chase", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-265.143, 53.611, -32.770)
    end
end)

createCustomButton("Section 1", "Chase 1 End", "Teleport to End", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-101.210, 20.456, -395.666)
        sendNotif("IOHUB", "Wait GrinDemon Chase End")
    end
end)







local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mga CFrames para sa Holes, Craft, at Fire (Ilagay sa pinakataas)
local holeCFrames = {
	CFrame.new(-59.096, 25.471, -596.931), -- Hole 1
	CFrame.new(-25.330, 25.471, -463.755), -- Hole 2
	CFrame.new(37.675, 25.471, -565.439),  -- Hole 3
	CFrame.new(-13.501, 25.471, -758.526), -- Hole 4
	CFrame.new(-38.726, 25.471, -869.459), -- Hole 5
	CFrame.new(-180.032, 25.471, -750.073) -- Hole 6
}

local craftCFrame = CFrame.new(-214.153, 25.471, -734.088)
local fireCFrame = CFrame.new(-185.657, 25.471, -799.441)

-- HELPER FUNCTIONS (Ilagay sa labas ng mga button)
local function instantTeleport(targetCFrame)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if character then
		character:PivotTo(targetCFrame)
		task.wait(0.5)
	end
end

local function getClosestPromptInFolder(folderPath)
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
	local hrp = character.HumanoidRootPart
	if not folderPath then return nil end
	
	local closestPrompt = nil
	local shortestDistance = math.huge
	for _, v in ipairs(folderPath:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			local parentPart = v.Parent
			if parentPart and parentPart:IsA("BasePart") then
				local distance = (hrp.Position - parentPart.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPrompt = v
				end
			end
		end
	end
	return closestPrompt
end




createCustomButton("Section 1", "Auto Collect Items", "Teleport To Hole And Collect Items", function()
	task.spawn(function()
		local mazeFolder = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("Maze")
		local holesFolder = mazeFolder and mazeFolder:FindFirstChild("Holes")

		for i, cframe in ipairs(holeCFrames) do
			instantTeleport(cframe)
			task.wait(0.3) -- Delay para mag-load ang prompt sa mobile executor
			
			local prompt = getClosestPromptInFolder(holesFolder)
			if prompt then
				fireproximityprompt(prompt)
				task.wait(0.4) -- Delay para matapos ang animation ng pagkuha
			end
		end
	end)
end)

createCustomButton("Section 1", "Auto Craft", "Teleport to Craft and Click Craft Button", function()
	task.spawn(function()
		instantTeleport(craftCFrame)
		task.wait(0.4)
		
		local craftingFolder = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("Maze") and workspace.Section1.Maze:FindFirstChild("Crafting")
		local prompt = getClosestPromptInFolder(craftingFolder)
		
		if prompt then
			for i = 1, 3 do
				fireproximityprompt(prompt)
				task.wait(0.2)
			end
			
			task.wait(0.2) -- Kaunting hintay bago i-invoke ang CraftingService
			pcall(function()
				local replicatedStorage = game:GetService("ReplicatedStorage")
				local packages = replicatedStorage:FindFirstChild("Packages")
				local packet = packages and packages:FindFirstChild("Packet")
				local packetFunc = packet and packet:FindFirstChild("PacketFunction")
				
				if packetFunc and packetFunc:IsA("RemoteFunction") then
					packetFunc:InvokeServer(
						0,
						{
							["__args"] = {},
							["__tree"] = {
								[1] = "CraftingService",
								[2] = "Interact",
							},
							["__callType"] = 0,
						}
					)
				end
			end)
			
			-- DAGDAG: Itatago o idi-disable ang Crafting GUI sa PlayerGui
			task.wait(0.3) -- Bigyan ng sandali na lumitaw bago i-hide
			local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui then
				local craftingGui = playerGui:FindFirstChild("Crafting")
				if craftingGui then
					-- Kung ScreenGui ito, pwede mong i-false ang Enabled
					if craftingGui:IsA("ScreenGui") then
						craftingGui.Enabled = false
					end
					-- O kaya ay i-hide ang mga Frame sa loob nito kung sakaling sakop ng ibang uri ng gui
					for _, child in ipairs(craftingGui:GetDescendants()) do
						if child:IsA("GuiObject") then
							child.Visible = false
						end
					end
				end
			end
		end
	end)
end)



createCustomButton("Section 1", "Auto Fire", "Equip Torch, Teleport to Flame and Fire Prompt", function()
	task.spawn(function()
		local player = game:GetService("Players").LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local backpack = player:FindFirstChild("Backpack")
		
		-- 1. I-equip ang Torch mula sa Backpack papunta sa Character
		if backpack then
			local torch = backpack:FindFirstChild("Torch")
			if torch then
				-- Kung Tool ito, pwede nating gamitin ang Humanoid:EquipTool o kaya direktang i-parent
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and torch:IsA("Tool") then
					humanoid:EquipTool(torch)
				else
					-- Fallback kung sakaling ililipat nang direkta
					torch.Parent = character
				end
				task.wait(0.3) -- Sandaling hintay para masigurong na-equip na
			end
		end
		
		-- 2. Sunod ay mag-teleport sa Flame CFrame
		instantTeleport(fireCFrame)
		task.wait(0.4)
		
		-- 3. Hanapin at i-fire ang prompt
		local craftingFolder = workspace:FindFirstChild("Section1") and workspace.Section1:FindFirstChild("Maze") and workspace.Section1.Maze:FindFirstChild("Crafting")
		local prompt = getClosestPromptInFolder(craftingFolder)
		
		if prompt then
			for i = 1, 3 do
				fireproximityprompt(prompt)
				task.wait(0.2)
			end
		end
	end)
end)





createCustomButton("Section 1", "GrinDemon End", "Move to the Trigger Cutscene", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-328.789, 8.585, -1107.152)
    end
end)

-- ====================================================================
-- CONTROL 4: CYCLE BELL LOCATIONS (TELEPORT ONLY)
-- ====================================================================
local BELL_LOCATIONS = {
    CFrame.new(-392.047, 9.000, -1364.373),
    CFrame.new(-202.990, 8.761, -1395.895),
    CFrame.new(-343.816, 9.000, -1702.281),
    CFrame.new(-685.956, 9.000, -2054.589),
    CFrame.new(-1012.033, 9.100, -1978.761),
    CFrame.new(-758.837, 18.869, -1701.883),
    CFrame.new(-804.377, 9.000, -1358.513),
    CFrame.new(-494.011, 11.308, -1434.631)
}

local currentBellIndex = 1

createCustomButton("Section 2", "Bell Locations", "Teleport to Bell Locations", function()
    -- I-update ang index
    currentBellIndex = currentBellIndex + 1
    if currentBellIndex > #BELL_LOCATIONS then
        currentBellIndex = 1
    end
    
    local targetCF = BELL_LOCATIONS[currentBellIndex]
    
    -- Teleport
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = targetCF
        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        notify("Bell Teleport", "📍 Teleported to Bell " .. currentBellIndex, 1)
    else
        notify("Error", "Hindi makita ang Character!", 1)
    end
end)
  
-- ====================================================================
-- 1. AUTO SLASH TOGGLE
-- ====================================================================
local autoSlashActive = false

createToggle("Section 2", "Auto Slash Toggle", "Automatically Slash Your Weapon", function(state)
    autoSlashActive = state
    
    if autoSlashActive then
        notify("IOHUB", "Auto Slash ON")
        task.spawn(function()
            while autoSlashActive do
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char then
                    local sword = char:FindFirstChild("Bone Sword")
                    if not sword and player:FindFirstChild("Backpack") then
                        local bpSword = player.Backpack:FindFirstChild("Bone Sword")
                        if bpSword then
                            bpSword.Parent = char
                            sword = char:FindFirstChild("Bone Sword")
                        end
                    end
                    
                    if sword and sword.Parent == char then
                        sword:Activate()
                    end
                end
                task.wait(0.2) -- Bilis ng pag-slash
            end
        end)
    else
        notify("IOHUB", "Auto Slash OFF")
    end
end)


-- ====================================================================
-- 2. WAYPOINT SCAN & TELEPORT HUNT BUTTON
-- ====================================================================
-- Listahan ng iyong mga CFrame checkpoints
local waypoints = {
    CFrame.new(-389.769, 9.054, -1340.872),
    CFrame.new(-225.440, 8.360, -1383.834),
    CFrame.new(-372.936, 8.360, -1693.338),
    CFrame.new(-777.813, 17.816, -1725.588),
    CFrame.new(-802.746, 7.577, -1384.521),
    CFrame.new(-528.608, 7.371, -1465.223)
}

createCustomButton("Section 2", "Hunt Flies", "Find Flied Near to Bell and Kill", function()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then 
            
            return 
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        
        
        -- Umihip/Mag-loop sa bawat CFrame waypoint
        for index, targetCFrame in ipairs(waypoints) do
            char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then break end
            hrp = char.HumanoidRootPart
            
            -- Teleport sa kasalukuyang waypoint
            hrp.CFrame = targetCFrame
            task.wait(0.35) -- Sandaling hintay para mag-load ang paligid sa pwesto
            
            -- I-scan ang FlyHitbox
            local fliesFolder = workspace:FindFirstChild("Section2") 
                and workspace.Section2:FindFirstChild("FlyNoobs") 
                and workspace.Section2.FlyNoobs:FindFirstChild("Flies") 
                and workspace.Section2.FlyNoobs.Flies:FindFirstChild("RoamArea") 
                and workspace.Section2.FlyNoobs.Flies.RoamArea:FindFirstChild("FlyAI")
                
            local foundFly = false
            if fliesFolder then
                local targetHitbox = fliesFolder:FindFirstChild("FlyHitbox")
                if targetHitbox and targetHitbox:IsA("BasePart") then
                    local targetPosY = targetHitbox.Position.Y
                    
                    -- Y-axis filter: Target (8 to 20), Ignore (50 up)
                    if targetPosY >= 8 and targetPosY <= 20 then
                        local dist = (hrp.Position - targetHitbox.Position).Magnitude
                        if dist <= 40 then
                            foundFly = true
                            notify("IOHUB", "Flies Found")
                            
                            -- Lumipat direkta sa posisyon ng Fly
                            hrp.CFrame = targetHitbox.CFrame
                            
                            -- Manatili (stay) sa pwesto nang 2 segundo para tirisin
                            local stayTime = 0
                            while stayTime < 2.0 do
                                if targetHitbox and targetHitbox.Parent then
                                    hrp.CFrame = targetHitbox.CFrame
                                end
                                task.wait(0.1)
                                stayTime = stayTime + 0.1
                            end
                        end
                    end
                end
            end
            
            -- KUNG WALANG NADE-DETECT NA FLY: Agad na lilipat sa susunod na waypoint (walang patumpik-tumpik)
            if not foundFly then
                -- Opsyonal: print("Walang Fly dito, lilipat sa susunod...")
                task.wait(0.1)
            end
        end
        
        
    end)
end)



-- ====================================================================
-- AUTO-FIRE SOLVER (FIXED FIRST-FIRE SKIP BUG)
-- ====================================================================

local function notify(title, text)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 2}) end)
end

createCustomButton("Section 2", "Record and Auto Click (Beta)", "This one is in Development and Keeps Improving Must Click This First Before Opening the Memory Puzzle", function()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        local packetFunc = game:GetService("ReplicatedStorage").Packages.Packet.PacketFunction
        if not packetFunc then
            
            return
        end
       
        -- 1. HANAPIN ANG PINAKAMALAPIT NA BELL SA PLAYER
        local bell2 = nil
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local shortestDist = math.huge
            
            local bellsFolder = workspace:FindFirstChild("Section2") and workspace.Section2:FindFirstChild("Bells")
            if bellsFolder then
                for _, bellModel in ipairs(bellsFolder:GetChildren()) do
                    local targetBell = bellModel:FindFirstChild("2")
                    if targetBell then
                        local partToCheck = targetBell:FindFirstChild("Base") or targetBell:FindFirstChildWhichIsA("BasePart")
                        if partToCheck then
                            local dist = (hrp.Position - partToCheck.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bell2 = targetBell
                            end
                        end
                    end
                end
            end
        end
        
        if not bell2 then 
            
            return
        end
        
        local targetContainer = nil
        for _, child in ipairs(bell2:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                if #child:GetChildren() >= 5 then
                    targetContainer = child
                    break
                end
            end
        end
        
        if not targetContainer then
            targetContainer = bell2
        end
        
        local rawParts = {}
        for _, part in ipairs(targetContainer:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(rawParts, part)
            end
        end
        
        local sizeCounts = {}
        for _, part in ipairs(rawParts) do
            local szStr = tostring(part.Size)
            sizeCounts[szStr] = (sizeCounts[szStr] or 0) + 1
        end
        
        local targetSize = nil
        local maxCount = 0
        for sz, count in pairs(sizeCounts) do
            if count >= 5 and count > maxCount then
                maxCount = count
                targetSize = sz
            end
        end
        
        local parts = {}
        for _, part in ipairs(rawParts) do
            if targetSize and tostring(part.Size) == targetSize then
                table.insert(parts, part)
            elseif not targetSize and #rawParts <= 12 then
                if part.Name ~= "Base" and part.Name ~= "Model" then
                    table.insert(parts, part)
                end
            end
        end
        
        if #parts == 0 then
            parts = rawParts
        end
        
        table.sort(parts, function(a, b)
            local posA = a.Position
            local posB = b.Position
            if math.abs(posA.Y - posB.Y) > 0.6 then
                return posA.Y > posB.Y
            else
                return posA.X < posB.X
            end
        end)
        
        local finalParts = {}
        for i = 1, math.min(9, #parts) do
            table.insert(finalParts, parts[i])
        end
        
        -- ==========================================
        -- RECORDING PHASE
        -- ==========================================
        local recordedParts = {}
        local recordedIndices = {}
        notify("IOHUB", "RECORDING")
        
        local isRecording = true
        local activeNeonPart = nil 
        
        while isRecording do
            local currentNeonPart = nil
            local foundIndex = nil
            
            for index, part in ipairs(finalParts) do
                if part.Material == Enum.Material.Neon then
                    currentNeonPart = part
                    foundIndex = index
                    break 
                end
            end
            
            if currentNeonPart then
                if activeNeonPart ~= currentNeonPart then
                    activeNeonPart = currentNeonPart
                    table.insert(recordedParts, currentNeonPart)
                    table.insert(recordedIndices, foundIndex)
                    
                    
                    
                    if #recordedParts >= 5 then 
                        isRecording = false 
                    end
                    
                    task.wait(0.3)
                end
            else
                activeNeonPart = nil
            end
            
            task.wait(0.01)
        end
        
        local recordString = table.concat(recordedIndices, ",")
        notify("Recorded", recordString)
        
        -- Maglaan ng sapat na bwelo bago mag-fire para hindi masikip sa network queue
        task.wait(0.5) 
        
        -- ==========================================
        -- FIRING & INSTANT EXIT PHASE (FIXED)
        -- ==========================================
        for i, btnPart in ipairs(recordedParts) do
            -- Siguraduhing buhay at valid pa ang part bago i-click
            if btnPart and btnPart.Parent then
                packetFunc:InvokeServer(0, {
                    ["__args"] = { [1] = btnPart },
                    ["__tree"] = { [1] = "PuzzleService", [2] = "Clicked" },
                    ["__callType"] = 0,
                })
            end
            
            -- Kung ito ang unang item (i == 1), bigyan muna ng kaunting tiyempo ang server bago mag-tuloy sa 2, 3, 4, 5
            if i == 1 then
                task.wait(0.15)
            elseif i == 5 then
                task.wait(0.05)
                pcall(function()
                    packetFunc:InvokeServer(0, {
                        ["__args"] = {},
                        ["__tree"] = {
                            [1] = "PuzzleService",
                            [2] = "ExitPuzzle",
                        },
                        ["__callType"] = 0,
                    })
                end)
                
            else
                task.wait(0.25)
            end
        end
    end)
end)







-- ====================================================================
-- SECTION 2: AUTO TELEPORT TO POSITIVE / UPSTAIRS DOOR & FIRE PROMPT
-- ====================================================================

createCustomButton("Section 2", "Find Puzzle Door", "Teleports to the Puzzle Door", function()
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoidRootPart then return end
        
        local puzzleDoorsFolder = workspace:FindFirstChild("Section2") 
            and workspace.Section2:FindFirstChild("PuzzleDoor") 
            and workspace.Section2.PuzzleDoor:FindFirstChild("Doors")
            
        if not puzzleDoorsFolder then
            
            return
        end
        
        local targetPuzzleDoor = nil
        local targetWoodPart = nil
        local highestY = -999999
        
        -- Siyasatin ang lahat ng pinto para hanapin ang nasa taas (positive / 0 pataas, o pinakamataas)
        for _, puzzleDoor in ipairs(puzzleDoorsFolder:GetChildren()) do
            local doorPortal = puzzleDoor:FindFirstChild("DoorPortal")
            local wood = doorPortal and doorPortal:FindFirstChild("Wood")
            
            if wood and wood:IsA("BasePart") then
                local currentY = wood.Position.Y
                -- Hahanapin natin ang pinakamataas na pinto (lalo na kung positive na ito)
                if currentY > highestY then
                    highestY = currentY
                    highestWoodPart = wood
                    targetPuzzleDoor = puzzleDoor
                end
            end
        end
        
        -- Siguraduhin nating positive / nasa taas na talaga ang pinto bago mag-teleport
        if highestWoodPart and highestY >= 0 then
            -- Teleport sa pinto (may kaunting +3 sa Y para di maipit)
            local pos = highestWoodPart.Position
            humanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
            
            
            
            -- Hanapin at i-fire ang ProximityPrompt sa DoorDetector
            task.wait(0.1) -- Sandaling hintay para mag-load ang posisyon pagka-teleport
            
            local doorDetector = targetPuzzleDoor and targetPuzzleDoor:FindFirstChild("DoorDetector")
            local prompt = doorDetector and doorDetector:FindFirstChildOfClass("ProximityPrompt")
            
            if prompt then
                prompt.HoldDuration = 0 -- Gawing instant kung sakaling may hold duration
                fireproximityprompt(prompt)
                
            else
                
            end
            
        else
            
        end
    end)
end)




-- ====================================================================
-- SECTION 2: AUTO FIX COMBOS (MULTI-DOOR SCANNER)
-- ====================================================================
createCustomButton("Section 2", "Auto Fix Shape", "Solves DoorPuzzleService and shows detected shapes in notification", function()
    pcall(function()
        local combosFolder = nil
        
        -- Kunin ang Doors folder
        local doorsFolder = workspace:FindFirstChild("Section2") 
            and workspace.Section2:FindFirstChild("PuzzleDoor") 
            and workspace.Section2.PuzzleDoor:FindFirstChild("Doors")
            
        if doorsFolder then
            -- I-scan ang LAHAT ng pinto (maging pang-2 man yan, pang-5, o kahit ilan)
            for _, door in ipairs(doorsFolder:GetChildren()) do
                local shapes = door:FindFirstChild("Shapes")
                if shapes and shapes:FindFirstChild("Combos") then
                    local comboCandidate = shapes.Combos
                    
                    -- Siguraduhing may laman o may mga anak (children) ang Combos bago natin piliin
                    local hasItems = false
                    if comboCandidate:FindFirstChild("SurfaceGui") and #comboCandidate.SurfaceGui:GetChildren() > 0 then
                        hasItems = true
                    elseif #comboCandidate:GetChildren() > 0 then
                        hasItems = true
                    end
                    
                    if hasItems then
                        combosFolder = comboCandidate
                        break -- Nahanap na natin ang tamang pinto na may active combo!
                    end
                end
            end
            
            -- Fallback kung sakaling walang lumitaw na may laman, kukunin muna kahit anong may Shapes.Combos
            if not combosFolder then
                for _, door in ipairs(doorsFolder:GetChildren()) do
                    if door:FindFirstChild("Shapes") and door.Shapes:FindFirstChild("Combos") then
                        combosFolder = door.Shapes.Combos
                        break
                    end
                end
            end
        end
        
        local detectedCombo = {}
        
        if combosFolder then
            -- Kukunin ang mga elements sa loob ng Combos (SurfaceGui children)
            if combosFolder:FindFirstChild("SurfaceGui") then
                for _, uiItem in pairs(combosFolder.SurfaceGui:GetChildren()) do
                    if uiItem:IsA("ImageLabel") or uiItem:IsA("TextLabel") or uiItem:IsA("GuiObject") then
                        table.insert(detectedCombo, uiItem.Name)
                    end
                end
            end
            
            -- Kung wala sa SurfaceGui, baka nasa mismong Combos folder
            if #detectedCombo == 0 then
                for _, item in pairs(combosFolder:GetChildren()) do
                    if item.Name ~= "SurfaceGui" then
                        table.insert(detectedCombo, item.Name)
                    end
                end
            end
        end
        
        -- Kung may nahanap na shapes, ipapadala na sa server
        if #detectedCombo > 0 then
            local packetFunc = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
                and game:GetService("ReplicatedStorage").Packages:FindFirstChild("Packet")
                and game:GetService("ReplicatedStorage").Packages.Packet:FindFirstChild("PacketFunction")
                
            if packetFunc then
                packetFunc:InvokeServer(
                    0,
                    {
                        ["__args"] = { detectedCombo },
                        ["__tree"] = {
                            [1] = "DoorPuzzleService",
                            [2] = "Clicked",
                        },
                        ["__callType"] = 0,
                    }
                )
                
            else
                
            end
        else
            
        end
    end)
end)



createCustomButton("Section 2", "Teleport to End Chase", "Trigger Chase End", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-3889.054, -57.371, -2292.617)
    end
end)


-- ====================================================================
-- SECTION 2 TAB: SKIP WALK (TELEPORT SEQUENCE)
-- ====================================================================
local SKIP_WALK_LOCATIONS = {
    CFrame.new(4240.901, 25.269, -2339.474),
    CFrame.new(4241.483, 27.676, -2519.480)
}

createCustomButton("Section 2", "Skip Walk", "Teleports through the skip walk sequence with a 1-second delay", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        
        return
    end
    
    local hrp = char.HumanoidRootPart
    
    
    
    -- 1. Teleport sa Unang CFrame
    hrp.CFrame = SKIP_WALK_LOCATIONS[1]
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    -- 2. Maghintay ng 1 segundo
    task.wait(1)
    
    -- I-check ulit kung buhay o naroon pa ang character bago ang sunod na TP
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- 3. Teleport sa Pangalawang CFrame
        hrp.CFrame = SKIP_WALK_LOCATIONS[2]
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        
    end
end)


-- Nilagyan natin ng variable para masubaybayan kung naka-on o off
local isAutoPromptActive = false

-- Ang background loop na kusang mag-i-trigger habang naka-ON
task.spawn(function()
    while true do
        if isAutoPromptActive then
            pcall(function()
                -- Sinusubukan hanapin ang tamang folder sa Workspace
                local section = workspace:FindFirstChild("Section2.5") or workspace:FindFirstChild("Section2_5")
                
                if section then
                    local targetPrompt = section.MindGame.Boats.Boat1.EnzukaiGame.RootPart.PromptAttachment.ProximityPrompt
                    
                    if targetPrompt and targetPrompt:IsA("ProximityPrompt") then
                        if fireproximityprompt then
                            fireproximityprompt(targetPrompt)
                        else
                            targetPrompt:InputHoldBegin()
                            targetPrompt:InputHoldEnd()
                        end
                    end
                end
            end)
        end
        task.wait(0.2) -- Bilis ng pag-check/pag-fire
    end
end)

-- Ang iyong createToggle function
createToggle("Section 2", "Auto Enzukai Prompt", "Automatically Fire Enzukai Prompt", function(state)
    isAutoPromptActive = state
    
    if state then
        -- Optional notification kung gusto mo makita na umilaw/gumana
        pcall(function() 
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Prompt", Text = "Naka-ON na!", Duration = 2}) 
        end)
    else
        pcall(function() 
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Prompt", Text = "Naka-OFF na.", Duration = 2}) 
        end)
    end
end)



createToggle("Section 3", "Disable Isamu", "Ignore Isamu", function(state)
    if state then
        
        if _G.IsamuConnection then _G.IsamuConnection:Disconnect() end
        
        _G.IsamuConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local section3 = workspace:FindFirstChild("Section3")
            local isamuModel = section3 and section3:FindFirstChild("IsamuAI")
            
            if isamuModel then
                for _, obj in ipairs(isamuModel:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanTouch = false
                        obj.CanCollide = false
                    elseif obj:IsA("TouchTransmitter") then
                        obj:Destroy()
                    end
                end
            end
        end)
    else
        -- KUNG NAKA-OFF: Itigil ang pag-disable
        if _G.IsamuConnection then
            _G.IsamuConnection:Disconnect()
            _G.IsamuConnection = nil
        end
    end
end)


createCustomButton("Section 3", "Safe Spot", "Teleport to Safe Spot", function()
    local character = LocalPlayer.Character -- FIXED localPlayer to LocalPlayer
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(1136.000, 29.324, -2400.000)
    end
end)






local BROOM_CFRAME = CFrame.new(1137.647, 18.628, -2382.834)

local DIRT_LOCATIONS = {
    CFrame.new(1150.480, 18.654, -2360.774), CFrame.new(1158.194, 18.654, -2361.384),
    CFrame.new(1140.213, 18.628, -2360.446), CFrame.new(1125.050, 18.628, -2380.611),
    CFrame.new(1108.685, 18.628, -2372.122), CFrame.new(1154.625, 18.654, -2380.986),
    CFrame.new(1147.327, 18.628, -2392.135), CFrame.new(1124.460, 18.628, -2400.167),
    CFrame.new(1129.012, 18.628, -2421.547), CFrame.new(1125.317, 18.628, -2441.497),
    CFrame.new(1117.341, 31.405, -2369.188), CFrame.new(1129.575, 31.485, -2372.698)
}

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

local function teleport(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function equipBroom()
    local localPlayer = game.Players.LocalPlayer
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    local broom = game:GetService("Workspace"):FindFirstChild("BroomStick", true) or (backpack and backpack:FindFirstChild("BroomStick"))
    if broom and broom:IsA("Tool") and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid:EquipTool(broom)
    end
end

local function getClosestDirtPrompt()
    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closestPrompt = nil
    local shortestDistance = math.huge
    
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj.Name == "Dirt" and obj:FindFirstChild("ProximityPrompt") then
            local promptPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if promptPart then
                local dist = (hrp.Position - promptPart.Position).Magnitude
                if dist < 8 and dist < shortestDistance then
                    shortestDistance = dist
                    closestPrompt = obj.ProximityPrompt
                end
            end
        end
    end
    
    return closestPrompt
end

createCustomButton("Section 3", "Auto Sweeping (Optional)", "Gets broom and cleans all 12 dirts properly", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        
        return
    end
    
    
    
    task.spawn(function()
        -- 1. Teleport at Kunin ang Broom
        teleport(BROOM_CFRAME)
        task.wait(0.4)
        
        local broomGiver = game:GetService("Workspace"):FindFirstChild("BroomStickGiver", true)
        if broomGiver and broomGiver:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(broomGiver.ProximityPrompt)
            task.wait(0.6)
            equipBroom()
        end

        -- 2. Linisin ang 12 dirts na may tamang delay para sa 4x fire bago lumipat
        for _, pos in ipairs(DIRT_LOCATIONS) do
            teleport(pos)
            task.wait(0.4)
            
            local dirtPrompt = getClosestDirtPrompt()
            
            if dirtPrompt then
                for i = 1, 4 do
                    if dirtPrompt and dirtPrompt.Parent then
                        fireproximityprompt(dirtPrompt)
                        task.wait(0.5)
                    end
                end
            else
                local fallbackDirt = game:GetService("Workspace"):FindFirstChild("Dirt", true)
                if fallbackDirt and fallbackDirt:FindFirstChild("ProximityPrompt") then
                    for i = 1, 4 do
                        fireproximityprompt(fallbackDirt.ProximityPrompt)
                        task.wait(0.5)
                    end
                end
            end
            
            task.wait(0.25)
        end
        
        
    end)
end)



-- ====================================================================
-- SECTION 4 TAB: AUTO TV OFF & WASH PLATES (BUTTON)
-- ====================================================================
local TV_CFRAME = CFrame.new(1116.200, 18.628, -2360.524)
local PLATES_CFRAME = CFrame.new(1152.429, 18.654, -2362.860)

local function fireTVPrompt()
    local section3 = game:GetService("Workspace"):FindFirstChild("Section3")
    if section3 then
        local chores = section3:FindFirstChild("Chores")
        local tvSection = chores and chores:FindFirstChild("TV")
        local television = tvSection and tvSection:FindFirstChild("Television")
        local tvPart = television and television:FindFirstChild("TV")
        local prompt = tvPart and tvPart:FindFirstChild("ProximityPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
    end
end

local function firePlatesPrompt()
    local section3 = game:GetService("Workspace"):FindFirstChild("Section3")
    if section3 then
        local chores = section3:FindFirstChild("Chores")
        local washing = chores and chores:FindFirstChild("WashingDishes")
        local wash = washing and washing:FindFirstChild("Wash")
        local prompt = wash and wash:FindFirstChild("ProximityPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then 
            fireproximityprompt(prompt) 
            
            -- I-fire ang Finished remote nang 10 beses pagkatapos ma-trigger ang prompt
            task.spawn(function()
                local remote = washing and washing:FindFirstChild("Remote")
                if remote and remote:IsA("RemoteEvent") then
                    for i = 1, 10 do
                        pcall(function()
                            remote:FireServer("Finished")
                        end)
                        task.wait(0.05) -- Kaunting agwat bawat fire para hindi ma-rate limit
                    end
                end
            end)
        end
    end
end

createCustomButton("Section 3", "Auto TV & Plates (Optional)", "Turns off TV and washes plates once", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        
        return
    end
    
    
    
    task.spawn(function()
        teleportTo(TV_CFRAME)
        task.wait(0.2)
        fireTVPrompt()
        
        task.wait(0.5)
        
        teleportTo(PLATES_CFRAME)
        task.wait(0.2)
        firePlatesPrompt()
        
        
    end)
end)


-- ====================================================================
-- SECTION 4 TAB: AUTO PRAY BUTTON
-- ====================================================================
local PRAY_CFRAME = CFrame.new(1150.211, 18.489, -2415.742)

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

local function teleportTo(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function firePrayPrompt()
    local section3 = game:GetService("Workspace"):FindFirstChild("Section3")
    if section3 then
        local chores = section3:FindFirstChild("Chores")
        local praySection = chores and chores:FindFirstChild("Pray")
        local pillow = praySection and praySection:FindFirstChild("PrayPillow")
        local prompt = pillow and pillow:FindFirstChild("ProximityPrompt")
        
        if prompt and prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
        end
    end
end

createCustomButton("Section 3", "Auto Pray (Optional)", "Teleports to the pray pillow and fires the prompt", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        
        return
    end
    
    
    
    -- Teleport sa Pray Pillow CFrame
    teleportTo(PRAY_CFRAME)
    
    -- Konting delay bago i-fire ang prompt para siguradong nakarating na
    task.delay(0.25, function()
        firePrayPrompt()
        
    end)
end)

-- ====================================================================
-- SECTION 4 TAB: AUTO CABINET BUTTON (FIXED PROMPT DETECTION)
-- ====================================================================
local CABINET_LOCATIONS = {
    CFrame.new(1116.496, 18.500, -2448.125),
    CFrame.new(1102.377, 18.604, -2424.642),
    CFrame.new(1125.822, 18.628, -2391.274),
    CFrame.new(1113.874, 18.792, -2412.971),
    CFrame.new(1114.525, 31.405, -2369.288)
}

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

local function teleportTo(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

-- Dynamic function para hanapin ang cabinet prompt na malapit sa kasalukuyang pwesto mo
local function getClosestCabinetPrompt()
    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closestPrompt = nil
    local shortestDistance = math.huge
    
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj.Name == "Interactive" and obj:FindFirstChild("ProximityPrompt") then
            local promptPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if promptPart then
                local dist = (hrp.Position - promptPart.Position).Magnitude
                if dist < 8 and dist < shortestDistance then
                    shortestDistance = dist
                    closestPrompt = obj.ProximityPrompt
                end
            end
        end
    end
    
    return closestPrompt
end

createCustomButton("Section 3", "Auto Cabinet (Optional)", "Teleports through all cabinet locations and fires prompts properly", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        
        return
    end
    
    
    
    task.spawn(function()
        for index, cf in ipairs(CABINET_LOCATIONS) do
            teleportTo(cf)
            task.wait(0.35) -- Bigyan ng sapat na oras para mag-sync ang posisyon
            
            local cabinetPrompt = getClosestCabinetPrompt()
            if cabinetPrompt then
                fireproximityprompt(cabinetPrompt)
            else
                -- Fallback kung sakaling hanapin sa buong Cabinets folder
                local section3 = game:GetService("Workspace"):FindFirstChild("Section3")
                local chores = section3 and section3:FindFirstChild("Chores")
                local cabinets = chores and chores:FindFirstChild("Cabinets")
                local prompt = cabinets and cabinets:FindFirstChild("ProximityPrompt", true)
                if prompt and prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
            
            task.wait(0.3) -- Delay bago lumipat sa susunod na cabinet
        end
        
    end)
end)





createCustomButton("Section 4", "Teleport to Crowbar Location", "Trigger Animation Get Crowbar", function()
    local character = LocalPlayer.Character -- FIXED localPlayer to LocalPlayer
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(2249.338, -7.462, 2363.537)
    end
end)

createCustomButton("Section 4", "Wall", "Break the Wall Using Crowbar", function()
    local character = LocalPlayer.Character -- FIXED localPlayer to LocalPlayer
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(2056.822, -7.462, 2262.631)
    end
end)



-- ====================================================================
-- SECTION 4 TAB: AUTO COLLECT 1 LARVAE & SUBMIT BUTTON
-- ====================================================================
local SUBMIT_CFRAME = CFrame.new(1936.610, 19.545, 4646.815)

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

local function teleportTo(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

createCustomButton("Section 4", "Auto Collect 1 Larvae and Submit", "Collects a single Larvae and submits it once to DogWall", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        notify("Larvae", "❌ Character not found!", 1.5)
        return
    end
    
    notify("Larvae", "🐛 Scanning for Larvae...", 1)
    
    task.spawn(function()
        -- 1. Isang beses lang maghahanap sa buong Workspace para sa LarvaeGiver
        local larvaeGiver = game:GetService("Workspace"):FindFirstChild("LarvaeGiver", true)
        
        if larvaeGiver then
            -- Kunin ang CFrame o Pivot ng RootPart o ng mismong object
            local targetPart = larvaeGiver:FindFirstChild("RootPart") or (larvaeGiver:IsA("BasePart") and larvaeGiver)
            local targetCF = targetPart and (targetPart:IsA("BasePart") and targetPart.CFrame or targetPart:GetPivot()) or larvaeGiver:GetPivot()
            
            -- Teleport sa Larvae
            teleportTo(targetCF + Vector3.new(0, 3, 0))
            task.wait(0.4)
            
            -- Hanapin at i-fire ang ProximityPrompt
            local prompt = larvaeGiver:FindFirstChild("ProximityPrompt", true)
            if prompt and prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
                notify("Larvae", "📦 Larvae collected! Submitting...", 1)
            else
                notify("Larvae", "⚠️ Prompt not found on Larvae!", 1.5)
                return
            end
        else
            notify("Larvae", "⚠️ No Larvae found in workspace!", 1.5)
            return
        end
        
        task.wait(0.6)
        
        -- 2. Teleport sa DogWall para i-submit
        teleportTo(SUBMIT_CFRAME)
        task.wait(0.4)
        
        -- Hanapin at i-fire ang submit prompt sa DogWall
        local dogWall = game:GetService("Workspace"):FindFirstChild("DogWall", true)
        local submitPrompt = dogWall and dogWall:FindFirstChild("ProximityPrompt", true)
        
        if submitPrompt and submitPrompt:IsA("ProximityPrompt") then
            fireproximityprompt(submitPrompt)
            notify("Larvae", "✨ Successfully submitted!", 1.5)
        else
            notify("Larvae", "⚠️ Submit prompt not found!", 1.5)
        end
    end)
end)


createCustomButton("Section 4", "Hole", "Teleport to Hole", function()
    local character = LocalPlayer.Character -- FIXED localPlayer to LocalPlayer
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(2370.575, -1.333, 6127.396)
    end
end)


-- ====================================================================
-- SHARED NOTIFICATION FUNCTION
-- ====================================================================
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end

-- ====================================================================
-- ISPY HOUSE (PER CLICK) BUTTON
-- ====================================================================
local ISPY_HOUSES = {
    { name = "House 1", cframe = CFrame.new(1682.987, 32.865, -764.905) },
    { name = "House 2", cframe = CFrame.new(2074.665, 32.879, -793.259) },
    { name = "House 3", cframe = CFrame.new(2193.862, 32.881, -490.308) },
    { name = "House 4", cframe = CFrame.new(1646.422, 32.797, -449.143) },
    { name = "House 5", cframe = CFrame.new(1870.938, 32.881, -466.799) }
}

local currentHouseIndex = 1

local function teleportTo(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function getClosestHousePrompt()
    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closestPrompt = nil
    local shortestDistance = math.huge
    
    local section5 = game:GetService("Workspace"):FindFirstChild("Section5")
    local ispy = section5 and section5:FindFirstChild("ISPY")
    local houses = ispy and ispy:FindFirstChild("Houses")
    
    if houses then
        for _, houseFolder in ipairs(houses:GetChildren()) do
            local playerPart = houseFolder:FindFirstChild("Player")
            local hrPart = playerPart and playerPart:FindFirstChild("HumanoidRootPart")
            local prompt = hrPart and hrPart:FindFirstChild("ProximityPrompt")
            
            if hrPart and prompt then
                local dist = (hrp.Position - hrPart.Position).Magnitude
                if dist < 12 and dist < shortestDistance then
                    shortestDistance = dist
                    closestPrompt = prompt
                end
            end
        end
    end
    
    return closestPrompt
end

-- Palitan ang "Section 4" ng "Section 5" kung iyon ang tamang tab sa UI mo
createCustomButton("Section 5", "Find House", "Teleport to House 1 to House 5", function()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        notify("IOHUB", "Character Not Found!", 1.5)
        return
    end
    
    local houseData = ISPY_HOUSES[currentHouseIndex]
    
    task.spawn(function()
        teleportTo(houseData.cframe)
        task.wait(0.35)
        
        local prompt = getClosestHousePrompt()
        if prompt then
            fireproximityprompt(prompt)
            
        else
            local fallbackPrompt = game:GetService("Workspace"):FindFirstChild("ProximityPrompt", true)
            if fallbackPrompt and fallbackPrompt:IsA("ProximityPrompt") then
                fireproximityprompt(fallbackPrompt)
                
            else
                
            end
        end
        
        currentHouseIndex = currentHouseIndex + 1
        if currentHouseIndex > #ISPY_HOUSES then
            currentHouseIndex = 1
        end
    end) -- Inayos na: end na lang, hindi na end.end
end)




-- ====================================================================
-- SECTION TAB: AUTO SPOT TOGGLE (ISPY SERVICE)
-- ====================================================================
local autoSpotActive = false
local spotTask = nil

createToggle("Section 5", "Auto Spot Yurei", "Automatically Remove Yurei", function(state)
    autoSpotActive = state
    
    if autoSpotActive then
        notify("IOHUB", "Auto Spot ON", 1.5)
        
        spotTask = task.spawn(function()
            while autoSpotActive do
                local replicatedStorage = game:GetService("ReplicatedStorage")
                local packages = replicatedStorage:FindFirstChild("Packages")
                local packet = packages and packages:FindFirstChild("Packet")
                local packetFunc = packet and packet:FindFirstChild("PacketFunction")
                
                if packetFunc and packetFunc:IsA("RemoteFunction") then
                    pcall(function()
                        packetFunc:InvokeServer(0, {
                            ["__args"] = {},
                            ["__tree"] = {
                                [1] = "IspyService",
                                [2] = "Spotted"
                            },
                            ["__callType"] = 0
                        })
                    end)
                end
                
                -- Pwede mong baguhin ang delay (oras) dito kung gaano kadalas mag-spot (halimbawa: 0.5 segundo)
                task.wait(0.5)
            end
        end)
    else
        notify("IOHUB", "Auto Spot OFF", 1.5)
        autoSpotActive = false
        if spotTask then
            task.cancel(spotTask)
            spotTask = nil
        end
    end
end)


-- Global variables para ma-share ang data sa pagitan ng Toggle at Button
local scannedMatches = {}
local isAutoScanActive = false

-- ====================================================================
-- 1. AUTO SCAN ITEM TOGGLE (With Live Detection & Notifications)
-- ====================================================================
createToggle("Section 5", "Auto Scan Item", "Automatically Scan Items and Send Notification", function(state)
    isAutoScanActive = state
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local localItems = {
        "Godzilla", "Fan", "Pineapple", "Hat", "Doll", "Apple", "Sword", "Book", "Key", 
        "Arrow", "Bell", "Eyes", "Vase", "SunSymbol", "Butterfly", "Horse", "Foot", 
        "Hawk", "Crystal", "JapaneseStoneLantern", "Amongus", "Skull", "TraditionalLantern", 
        "Katana", "Crown", "Telephone", "Oni", "Tank", "RubberDuck", "Moustache", "Painting", 
        "Fish", "MailBox", "Trash", "Cat", "KintoruHead", "VoDooDoll", "DeerSkull", 
        "TeddyBear", "WorkingLantern", "Trap", "RiceBarrel", "Alien", "Mask"
    }
    
    if not state then
        scannedMatches = {}
        return
    end
    
    -- Live Scanner Loop habang naka-on ang toggle
    task.spawn(function()
        local lastTextProcessed = ""
        
        while isAutoScanActive do
            local targetText = ""
            pcall(function()
                local section5 = playerGui:FindFirstChild("Section5")
                if section5 then
                    local textLbl = section5:FindFirstChild("TextLabel")
                    if textLbl and textLbl:IsA("TextLabel") then
                        targetText = textLbl.Text
                    end
                end
            end)
            
            -- Kung nagbago ang text sa screen, i-scan agad natin
            if targetText ~= "" and targetText ~= lastTextProcessed then
                lastTextProcessed = targetText
                local newMatches = {}
                
                for itemTarget in string.gmatch(targetText, "[^,]+") do
                    local cleanTargetName = string.gsub(itemTarget, "^%s*(.-)%s*$", "%1")
                    local targetNormalized = cleanTargetName:lower():gsub("%s+", "")
                    
                    for _, validItem in ipairs(localItems) do
                        local validNormalized = validItem:lower():gsub("%s+", "")
                        if validNormalized == targetNormalized then
                            local exists = false
                            for _, m in ipairs(newMatches) do
                                if m == validItem then exists = true break end
                            end
                            if not exists then
                                table.insert(newMatches, validItem)
                            end
                        end
                    end
                end
                
                scannedMatches = newMatches
                
                -- Magpapakita ng notification sa gilid kung may nadetect
                if #scannedMatches > 0 then
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "IOHUB",
                            Text = "Cursed Item: " .. table.concat(scannedMatches, ", "),
                            Duration = 3,
                        })
                    end)
                end
            end
            
            task.wait(0.5) -- Check bawat kalahating segundo
        end
    end)
end)


-- ====================================================================
-- 2. FIRE SCANNED ITEMS BUTTON (Safe 2s Delay & State Validator)
-- ====================================================================
createCustomButton("Section 5", "Auto Click Cursed Items", "Automatically Click the Cursed Items", function()
    -- I-check muna kung nakabukas ang Auto Scan toggle
    if not isAutoScanActive then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Must Turn on Scanner First",
                Duration = 3,
            })
        end)
        return
    end
    
    -- I-check kung may laman ba ang na-scan
    if #scannedMatches == 0 then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Items not Found",
                Duration = 3,
            })
        end)
        return
    end
    
    -- Simulan ang pag-fire paisa-isa na may 2 seconds delay
    task.spawn(function()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Starting Click",
                Duration = 2,
            })
        end)
        
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local packetFunc = ReplicatedStorage:FindFirstChild("Packages") 
            and ReplicatedStorage.Packages:FindFirstChild("Packet") 
            and ReplicatedStorage.Packages.Packet:FindFirstChild("PacketFunction")
            
        for _, itemName in ipairs(scannedMatches) do
            if packetFunc then
                pcall(function() 
                    packetFunc:InvokeServer(0, {
                        ["__args"] = {itemName}, 
                        ["__tree"] = {"IspyService", "Clicked"}, 
                        ["__callType"] = 0
                    }) 
                end)
            end
            -- 2 seconds interval para ligtas sa anti-cheat kick
            task.wait(0.5)
        end
        
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Complete",
                Duration = 3,
            })
        end)
    end)
end)



createCustomButton("Section 5", "Delete Boss Walls & Decors", "Deletes invisible walls and specific structural models in Section 5 Boss build", function()
    pcall(function()
        local buildFolder = workspace:FindFirstChild("Section5") 
            and workspace.Section5:FindFirstChild("Boss") 
            and workspace.Section5.Boss:FindFirstChild("Build")
            
        if not buildFolder then
            notify("Clean Boss", "❌ Build folder not found in Section 5!", 2)
            return
        end
        
        local deletedCount = 0
        
        -- Listahan ng mga pangalan na gusto nating burahin
        local namesToDelete = {
            ["InvisWall"] = true,
            ["c01-15k"] = true,
            ["roman1-10k"] = true,
            ["roman2-5k"] = true,
            ["roman3-8k"] = true
        }
        
        -- Suriin ang lahat ng mga bagay sa loob ng Build folder at burahin kung sakto ang pangalan
        for _, obj in ipairs(buildFolder:GetChildren()) do
            if namesToDelete[obj.Name] then
                obj:Destroy()
                deletedCount = deletedCount + 1
            end
        end
        
        notify("IOHUB", "Successfully Deleted " .. deletedCount .. " objects!", 2)
    end)
end)



createCustomButton("Section 5", "Open Boss Fight Gui", "Show Boss Fight Control Panel", function()
    -- CLEANUP muna para hindi mag-double UI kung na-click ulit
    local existingCore = game.CoreGui:FindFirstChild("KatanaCollectGui")
    if existingCore then existingCore:Destroy() end
    
    local player = game:GetService("Players").LocalPlayer
    local existingPlayerGui = player.PlayerGui:FindFirstChild("KatanaCollectGui")
    if existingPlayerGui then existingPlayerGui:Destroy() end

    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.Name = "KatanaCollectGui"
    screenGui.DisplayOrder = 999999 -- Para laging nasa ibabaw at hindi matakpan

    -- GUI Frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 160, 0, 155)
    frame.Position = UDim2.new(0.5, -80, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- ❌ Close Button (X Button sa kanang itaas ng Frame)
    local btnClose = Instance.new("TextButton", frame)
    btnClose.Size = UDim2.new(0, 25, 0, 25)
    btnClose.Position = UDim2.new(1, -30, 0, 5)
    btnClose.Text = "X"
    btnClose.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btnClose.TextColor3 = Color3.new(1, 1, 1)
    btnClose.TextSize = 14
    btnClose.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 4)

    -- Function para i-destroy/isara ang buong GUI kapag pinindot ang X
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- 1. Collect Toggle Button
    local btnToggle = Instance.new("TextButton", frame)
    btnToggle.Size = UDim2.new(0, 140, 0, 30)
    btnToggle.Position = UDim2.new(0, 10, 0, 35)
    btnToggle.Text = "COLLECT: OFF"
    btnToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btnToggle.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnToggle).CornerRadius = UDim.new(0, 5)

    -- 2. Auto Fire Prompt Toggle Button
    local btnAutoPrompt = Instance.new("TextButton", frame)
    btnAutoPrompt.Size = UDim2.new(0, 140, 0, 30)
    btnAutoPrompt.Position = UDim2.new(0, 10, 0, 75)
    btnAutoPrompt.Text = "AUTO PROMPT: OFF"
    btnAutoPrompt.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btnAutoPrompt.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnAutoPrompt).CornerRadius = UDim.new(0, 5)

    -- 3. ESP Yurei Toggle Button
    local btnEspYurei = Instance.new("TextButton", frame)
    btnEspYurei.Size = UDim2.new(0, 140, 0, 30)
    btnEspYurei.Position = UDim2.new(0, 10, 0, 115)
    btnEspYurei.Text = "ESP YUREI: OFF"
    btnEspYurei.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btnEspYurei.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnEspYurei).CornerRadius = UDim.new(0, 5)

    local collecting = false
    local autoPromptActive = false
    local espYureiActive = false
    local safeSpotCFrame = CFrame.new(3078.000, 17.000, -540.000)
-- old CFrame.new(3090.283, 17.118, -302.038)
    -- Fly Function (Anti-Fall / Anti-Void)
    local function setFly(state)
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp then return end
        
        if state then
            if not hrp:FindFirstChild("FlyVel") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "FlyVel"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.zero
                
                local bg = Instance.new("BodyGyro", hrp)
                bg.Name = "FlyGyro"
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.P = 1000
            end
            if hum then hum.PlatformStand = true end
        else
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "FlyVel" or v.Name == "FlyGyro" then v:Destroy() end
            end
            if hum then hum.PlatformStand = false end
        end
    end

    -- ESP Yurei Toggle Logic
    btnEspYurei.MouseButton1Click:Connect(function()
        espYureiActive = not espYureiActive
        btnEspYurei.Text = espYureiActive and "ESP YUREI: ON" or "ESP YUREI: OFF"
        btnEspYurei.BackgroundColor3 = espYureiActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)

    -- Loop para sa ESP Yurei
    task.spawn(function()
        while screenGui.Parent do
            pcall(function()
                local bossFolder = workspace:FindFirstChild("Section5") 
                    and workspace.Section5:FindFirstChild("Boss") 
                    and workspace.Section5.Boss:FindFirstChild("MonsterFolder")
                
                if bossFolder then
                    local targets = {
                        { body = bossFolder:FindFirstChild("Yurei") and bossFolder.Yurei:FindFirstChild("Body"), head = bossFolder:FindFirstChild("Yurei") and bossFolder.Yurei:FindFirstChild("YureiHitboxHead") },
                        { body = bossFolder:FindFirstChild("YureiNM") and bossFolder.YureiNM:FindFirstChild("YureiHitbox"), head = bossFolder:FindFirstChild("YureiNM") and bossFolder.YureiNM:FindFirstChild("YureiHitboxHead") }
                    }
                    
                    for _, target in ipairs(targets) do
                        local bodyPart = target.body
                        local headPart = target.head
                        
                        if espYureiActive then
                            if bodyPart and not bodyPart:FindFirstChild("YureiESP") then
                                local hl = Instance.new("Highlight", bodyPart)
                                hl.Name = "YureiESP"
                                hl.FillColor = Color3.fromRGB(0, 255, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                            if headPart and not headPart:FindFirstChild("YureiESP") then
                                local hl = Instance.new("Highlight", headPart)
                                hl.Name = "YureiESP"
                                hl.FillColor = Color3.fromRGB(255, 0, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                        else
                            if bodyPart and bodyPart:FindFirstChild("YureiESP") then bodyPart.YureiESP:Destroy() end
                            if headPart and headPart:FindFirstChild("YureiESP") then headPart.YureiESP:Destroy() end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)

    -- Auto Fire Prompt Button Logic
    btnAutoPrompt.MouseButton1Click:Connect(function()
        autoPromptActive = not autoPromptActive
        btnAutoPrompt.Text = autoPromptActive and "AUTO PROMPT: ON" or "AUTO PROMPT: OFF"
        btnAutoPrompt.BackgroundColor3 = autoPromptActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)

    -- Auto Fire Prompt Background Loop (Wala nang MaxActivationDistance modification)
    task.spawn(function()
        while screenGui.Parent do
            if autoPromptActive then
                pcall(function()
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            d.HoldDuration = 0
                            fireproximityprompt(d)
                        end
                    end
                end)
            end
            task.wait(0.2)
        end
    end)

    -- Collect Toggle Button
    btnToggle.MouseButton1Click:Connect(function()
        collecting = not collecting
        if collecting then
            btnToggle.Text = "COLLECT: ON"
            btnToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            setFly(false)
            btnToggle.Text = "COLLECT: OFF"
            btnToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)

    -- Main Loop (Auto Collect Katanas - Ignores if Transparency is 1)
    task.spawn(function()
        while screenGui.Parent do
            if collecting then
                pcall(function()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        setFly(true)
                        
                        local foundGiver = false
                        for _, d in ipairs(workspace:GetDescendants()) do
                            if d:IsA("ProximityPrompt") and d.Parent and d.Parent.Name == "KatanaGiver" then
                                local giverPart = d.Parent
                                if giverPart:IsA("BasePart") and giverPart.Transparency < 1 then
                                    local pos = giverPart.Position
                                    hrp.CFrame = CFrame.new(pos.X, pos.Y - 18, pos.Z)
                                    
                                    d.HoldDuration = 0
                                    fireproximityprompt(d)
                                    
                                    foundGiver = true
                                    task.wait(0.3)
                                    break
                                end
                            end
                        end
                        
                        setFly(false)
                        hrp.CFrame = safeSpotCFrame
                        collecting = false
                        btnToggle.Text = "COLLECT: OFF"
                        btnToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end)




createCustomButton("Section 5", "Enter to Tree", "Teleport to Tree and Enter", function()
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Hanapin ang Part sa TreePortal
        local treePart = workspace:FindFirstChild("Section5")
            and workspace.Section5:FindFirstChild("Boss")
            and workspace.Section5.Boss:FindFirstChild("DeathAnimation")
            and workspace.Section5.Boss.DeathAnimation:FindFirstChild("TreePortal")
            and workspace.Section5.Boss.DeathAnimation.TreePortal:FindFirstChild("Part")
            
        if hrp and treePart then
            -- Teleport sa pwesto ng part (+3 sa Y para hindi ma-stuck)
            hrp.CFrame = treePart.CFrame + Vector3.new(0, 3, 0)
            
            -- Hanapin at i-fire ang ProximityPrompt
            local prompt = treePart:FindFirstChildOfClass("ProximityPrompt") or treePart:FindFirstChild("ProximityPrompt")
            if prompt then
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 99999
                fireproximityprompt(prompt)
            end
        end
    end)
end)





createCustomButton("Section 6", "Shinigami Chase End", "Teleport to Chase End", function()
    local character = LocalPlayer.Character -- FIXED localPlayer to LocalPlayer
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-1699.319, 88.252, 7807.395)
    end
end)





-- ====================================================================
-- AUTO LOAD SAVED BUTTON
-- ====================================================================
createCustomButton("Settings", "Auto Load Saved", "Auto Load Saved Game", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local mimicSaveSync = replicatedStorage:FindFirstChild("MimicSaveSync")
    
    if mimicSaveSync and mimicSaveSync:IsA("RemoteEvent") then
        pcall(function()
            mimicSaveSync:FireServer(0, 1)
        end)
        
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Success",
                Duration = 3,
            })
        end)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "IOHUB",
                Text = "Not Found",
                Duration = 3,
            })
        end)
    end
end)



-- ====================================================================
-- DAYTIME / MORNING TOGGLE (SETTINGS)
-- ====================================================================
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- I-save ang original settings para maibalik kapag naka-off
local originalLightingData = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    GlobalShadows = Lighting.GlobalShadows,
    Atmosphere = {},
    ColorCorrection = {},
    Sky = {}
}

createToggle("Settings", "DayTime/Morning", "Toggles full brightness / removes darkness and red atmosphere", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    if state then
        -- ===== [TOGGLE ON] =====
        -- I-save ang current state mago bago palitan
        originalLightingData.ClockTime = Lighting.ClockTime
        originalLightingData.Brightness = Lighting.Brightness
        originalLightingData.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLightingData.Ambient = Lighting.Ambient
        originalLightingData.GlobalShadows = Lighting.GlobalShadows

        pcall(function()
            Lighting.ClockTime = 14
            Lighting.Brightness = 3
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            Lighting.GlobalShadows = false
            
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") then
                    originalLightingData.Atmosphere[child] = {Density = child.Density, Haze = child.Haze, Color = child.Color, Decay = child.Decay}
                    child.Density = 0
                    child.Haze = 0
                    child.Color = Color3.fromRGB(255, 255, 255)
                    child.Decay = Color3.fromRGB(255, 255, 255)
                elseif child:IsA("ColorCorrectionEffect") then
                    originalLightingData.ColorCorrection[child] = {TintColor = child.TintColor, Saturation = child.Saturation, Contrast = child.Contrast}
                    child.TintColor = Color3.fromRGB(255, 255, 255)
                    child.Saturation = 0.1
                    child.Contrast = 0.1
                elseif child:IsA("Sky") then
                    originalLightingData.Sky[child] = child.StarCount
                    child.StarCount = 0
                end
            end
        end)
        
        notify("DayTime Active", "☀️ DayTime Morning Enabled", 2.5)
    else
        -- ===== [TOGGLE OFF] =====
        pcall(function()
            Lighting.ClockTime = originalLightingData.ClockTime
            Lighting.Brightness = originalLightingData.Brightness
            Lighting.OutdoorAmbient = originalLightingData.OutdoorAmbient
            Lighting.Ambient = originalLightingData.Ambient
            Lighting.GlobalShadows = originalLightingData.GlobalShadows
            
            for child, data in pairs(originalLightingData.Atmosphere) do
                if child and child.Parent then
                    child.Density = data.Density
                    child.Haze = data.Haze
                    child.Color = data.Color
                    child.Decay = data.Decay
                end
            end

            for child, data in pairs(originalLightingData.ColorCorrection) do
                if child and child.Parent then
                    child.TintColor = data.TintColor
                    child.Saturation = data.Saturation
                    child.Contrast = data.Contrast
                end
            end

            for child, starCount in pairs(originalLightingData.Sky) do
                if child and child.Parent then
                    child.StarCount = starCount
                end
            end
        end)

        notify("DayTime Disabled", "🌙 Original Darkness Restored", 2.5)
    end
end)




-- ====================================================================
-- ANTI-LAG / LOW GRAPHICS TOGGLE
-- ====================================================================
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local antilagConnection = nil
local originalSettings = {}

createToggle("Settings", "Anti-Lag / Low Graphics", "Boosts FPS by disabling shadows, particles, and heavy textures", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    if state then
        -- ===== [TOGGLE ON] =====
        notify("Anti-Lag", "Enabling FPS Boost...", 2)

        local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            originalSettings.WaterWaveSize = Terrain.WaterWaveSize
            originalSettings.WaterWaveSpeed = Terrain.WaterWaveSpeed
            originalSettings.WaterReflectance = Terrain.WaterReflectance
            originalSettings.WaterTransparency = Terrain.WaterTransparency
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        originalSettings.GlobalShadows = Lighting.GlobalShadows
        originalSettings.FogEnd = Lighting.FogEnd
        originalSettings.FogStart = Lighting.FogStart
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9

        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                originalSettings[v] = {CastShadow = v.CastShadow, Material = v.Material, Reflectance = v.Reflectance}
                v.CastShadow = false
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                if originalSettings[v] == nil then originalSettings[v] = v.Transparency end
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                if originalSettings[v] == nil then originalSettings[v] = v.Lifetime end
                v.Lifetime = NumberRange.new(0)
            end
        end

        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                originalSettings[v] = v.Enabled
                v.Enabled = false
            end
        end

        antilagConnection = Workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    RunService.Heartbeat:Wait()
                    child:Destroy()
                elseif child:IsA("BasePart") then
                    child.CastShadow = false
                end
            end)
        end)

        notify("Anti-Lag", "⚡ Anti-Lag Enabled: Graphics Optimized", 3)
    else
        -- ===== [TOGGLE OFF] =====
        if antilagConnection then
            antilagConnection:Disconnect()
            antilagConnection = nil
        end

        local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain and originalSettings.WaterTransparency then
            Terrain.WaterWaveSize = originalSettings.WaterWaveSize
            Terrain.WaterWaveSpeed = originalSettings.WaterWaveSpeed
            Terrain.WaterReflectance = originalSettings.WaterReflectance
            Terrain.WaterTransparency = originalSettings.WaterTransparency
        end

        Lighting.GlobalShadows = originalSettings.GlobalShadows ~= nil and originalSettings.GlobalShadows or true
        Lighting.FogEnd = originalSettings.FogEnd ~= nil and originalSettings.FogEnd or 100000
        Lighting.FogStart = originalSettings.FogStart ~= nil and originalSettings.FogStart or 0

        for _, v in pairs(game:GetDescendants()) do
            if originalSettings[v] then
                if v:IsA("BasePart") then
                    v.CastShadow = originalSettings[v].CastShadow
                    v.Material = originalSettings[v].Material
                    v.Reflectance = originalSettings[v].Reflectance
                elseif v:IsA("Decal") then
                    v.Transparency = originalSettings[v]
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = originalSettings[v]
                end
            end
        end

        for _, v in pairs(Lighting:GetDescendants()) do
            if originalSettings[v] ~= nil and v:IsA("PostEffect") then
                v.Enabled = originalSettings[v]
            end
        end

        originalSettings = {}
        notify("Anti-Lag", "⚪ Anti-Lag Disabled: Original Graphics Restored", 2)
    end
end)






switchTab("Section 1")

