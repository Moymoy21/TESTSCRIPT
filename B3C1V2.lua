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
createSidebarTab("Section 3", "rbxassetid://10734951111", 3)
createSidebarTab("Section 4", "rbxassetid://10734951111", 4)
createSidebarTab("Section 5", "rbxassetid://10734951111", 5)
createSidebarTab("Settings", "rbxassetid://10734951111", 6)


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




-- ====================================================================
-- SECTION 1 GATA 5X MULTI-FIRE SKY SNIPER CONTROL BUTTON
-- ====================================================================
createCustomButton("Section 1", "Auto Kill Gata", "Teleport to Gata and Kill", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Global variable thread configuration to allow safe interlocking cancellations
    _G.GataKillLoopActive = false
    task.wait(0.15)
    _G.GataKillLoopActive = true
    _G.EradicatedGataTable = {} -- Blacklist tracking map for completed nodes per execution [INDEX]

    -- Local function for clean English side notifications
    local function notify(title, text)
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end

    -- Verify folder path structural nodes natively
    local gruntsFolder = Workspace:FindFirstChild("Section1")
        and Workspace.Section1:FindFirstChild("Grunts")

    if not gruntsFolder then
        notify("Error", "Section 1 Grunts folder not loaded in Workspace yet!")
        return
    end

    -- Save your initial state coordinates as a baseline anchor before launching [INDEX]
    local originalSafeCFrame = humanoidRootPart.CFrame
    local originalHipHeight = humanoid.HipHeight or 0

    notify("Sniper Active", "Hunting Grunts. Positioning safely 15 studs above targets...", 2.5)

    task.spawn(function()
        while _G.GataKillLoopActive do
            -- Re-verify alive variables state dynamically inside the running frame thread [INDEX]
            if not character or not character.Parent or not humanoidRootPart.Parent then 
                break 
            end
            
            local currentGruntsList = gruntsFolder:GetChildren()
            local targetGataUnit = nil
            local remainingGataTargetsCount = 0
            
            -- SCANNER MATRIX WITH BLACKLIST: Filters out dead or already cataloged instances [INDEX]
            for _, gataObj in ipairs(currentGruntsList) do
                if gataObj:IsA("Model") and not _G.EradicatedGataTable[gataObj] then
                    remainingGataTargetsCount = remainingGataTargetsCount + 1
                    if not targetGataUnit then
                        targetGataUnit = gataObj -- Target locked [INDEX]
                    end
                end
            end
            
            -- INTERLOCK TERMINATOR: Return home and restore parameters once target indices drop to 0 [INDEX]
            if remainingGataTargetsCount == 0 or not targetGataUnit or not _G.GataKillLoopActive then
                if humanoid then humanoid.HipHeight = originalHipHeight end
                task.wait(0.05)
                if humanoidRootPart and originalSafeCFrame then
                    humanoidRootPart.CFrame = originalSafeCFrame
                end
                notify("Sniper Finished", "All Gata targets successfully eliminated!")
                break
            end
            
            -- =========================================================================
            -- PIPELINE: TELEPORT ON TOP (15 STUDS) AND FIRE 5 TIMES CONSECUTIVELY [INDEX]
            -- =========================================================================
            if targetGataUnit and _G.GataKillLoopActive then
                local gataPivotCFrame = targetGataUnit:GetPivot()
                
                pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                task.wait(0.01)
                
                -- Secure character 15 studs directly above the monster's pivot point [INDEX]
                local targetSafeCFrame = gataPivotCFrame * CFrame.new(0, 15, 0)
                humanoidRootPart.CFrame = targetSafeCFrame
                
                -- Anti-Gravity Float Upgrade: Prevent ground snapping physics [INDEX]
                pcall(function() humanoid.HipHeight = 15 end)
                task.wait(0.15) -- Streaming rendering synchronization buffer delay [INDEX]

                -- POSITION GLUE ACCELERATOR: Lock root elements tightly in mid-air [INDEX]
                local isLockingActive = true
                local lockConnection
                lockConnection = RunService.Heartbeat:Connect(function()
                    if isLockingActive and humanoidRootPart and _G.GataKillLoopActive then
                        humanoidRootPart.CFrame = targetSafeCFrame 
                        humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Block physics drift forces [INDEX]
                    end
                end)

                -- FIXED 5X MULTI-FIRE LOOP INJECTION MACHINE [INDEX]
                notify("Target Focused", "Executing 5x damage payload on " .. targetGataUnit.Name, 1)
                for round = 1, 5 do
                    if not _G.GataKillLoopActive or not targetGataUnit or not targetGataUnit.Parent then break end
                    
                    pcall(function()
                        for _, insideDescendant in ipairs(targetGataUnit:GetDescendants()) do
                            if insideDescendant:IsA("RemoteEvent") then
                                insideDescendant:FireServer()
                                insideDescendant:FireServer("Damage", 100)
                                insideDescendant:FireServer("Kill")
                                insideDescendant:FireServer(true)
                            end
                        end
                    end)
                    task.wait(0.06) -- Rapid packet delivery ticket window [INDEX]
                end

                -- STRICT 2-SECOND POSITION RETENING COOLDOWN [INDEX]
                for secondsLeft = 2, 1, -1 do
                    if not _G.GataKillLoopActive then break end
                    notify("Processing Stay", "Enforcing server synchronization: " .. secondsLeft .. "s...", 1)
                    task.wait(1)
                end

                -- Break local mid-air connection layer [INDEX]
                isLockingActive = false
                if lockConnection then lockConnection:Disconnect() end
                
                -- Temporary standard scale fallback right before moving to the next item node [INDEX]
                pcall(function() humanoid.HipHeight = originalHipHeight end)
                
                -- Blacklist current unique instance address pointer to shift frames [INDEX]
                _G.EradicatedGataTable[targetGataUnit] = true
                task.wait(0.15) 
            end
        end
    end)
end)



-- I-wrap sa iyong custom button function
createCustomButton("Section 1", "Civilian Interact", "Teleport to Civilian and Interact", function()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Siguraduhing umiiral ang folder ng mga civilian bago mag-umpisa
    local deadCiviliansFolder = Workspace:FindFirstChild("Section1") 
        and Workspace.Section1:FindFirstChild("DeadCivilians")

    if not deadCiviliansFolder then
        notify("Error", "Not Found DeadCivilians folder!", 3)
        return
    end

    -- Ang iyong mga eksaktong ligtas na CFrame listahan
    local civiliansCFrame = {
        CFrame.new(82.2101974, 7.01562452, 229.03598, 0.999974549, 1.60358249e-09, -0.00713643711, -1.60001368e-09, 1, 5.05793407e-10, 0.00713643711, -4.94362107e-10, 0.999974549),
        CFrame.new(29.5840073, 7.05437136, -87.9759293, 0.999974549, 7.98299926e-10, -0.00713643711, -7.60655594e-10, 1, 5.27766053e-09, 0.00713643711, -5.27209787e-09, 0.999974549),
        CFrame.new(-182.772629, 7.01562452, 73.8156357, 0.0309865493, 1.37417135e-08, 0.999519825, -2.71963851e-09, 1, -1.36640024e-08, -0.999519825, -2.29493224e-09, 0.0309865493),
        CFrame.new(225.873566, 7.03801394, -84.7873001, 0.999954641, 6.97570335e-10, 0.00952569582, -9.66604463e-10, 1, 2.82383912e-08, -0.00952569582, -2.82463173e-08, 0.999954641),
        CFrame.new(-3.58142662, 7.01562452, -176.386215, -0.992575169, -1.97492529e-08, -0.121632636, -1.93827052e-08, 1, -4.19672697e-09, 0.121632636, -1.80799731e-09, -0.992575169),
        CFrame.new(80.6713104, 7.0411253, 149.687668, -0.997461557, 1.115201e-08, -0.0712069646, 1.04766196e-08, 1, 9.85837101e-09, 0.0712069646, 9.08733799e-09, -0.997461557)
    }

    -- Helper function para hanapin ang ProximityPrompt na pinakamalapit sa posisyon ng player
    local function getClosestPrompt()
        local closestPrompt = nil
        local shortestDistance = math.huge

        for _, civilian in ipairs(deadCiviliansFolder:GetChildren()) do
            local hrp = civilian:FindFirstChild("HumanoidRootPart")
            local prompt = hrp and hrp:FindFirstChildOfClass("ProximityPrompt")
            
            if prompt and hrp then
                local distance = (humanoidRootPart.Position - hrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = prompt
                end
            end
        end
        return closestPrompt
    end

    notify("Script Started", "Teleporting to DeadCivilians", 3)

    -- Loop sa iyong 6 na safe CFrames
    for i, targetCFrame in ipairs(civiliansCFrame) do
        -- 1. I-teleport ang player gamit ang iyong ligtas na coordinate
        humanoidRootPart.CFrame = targetCFrame
        task.wait(0.4) -- Delay para siguradong naka-load ang lapag at hindi mahulog

        -- 2. Hanapin ang pinakamalapit na ProximityPrompt sa posisyong ito
        local prompt = getClosestPrompt()

        if prompt then
            -- 3. I-bypass ang mga posibleng restriction ng prompt (para sa nakahigang civilian)
            local originalRequiresLineOfSight = prompt.RequiresLineOfSight
            local originalMaxDistance = prompt.MaxActivationDistance
            
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50 -- Tinaasan para sigurado kahit may kaunting distansya
            task.wait(0.1)

            -- 4. Trigger ang Proximity Prompt at mag-notify sa gilid ng screen
            fireproximityprompt(prompt)
            notify("Interacting", "Civilian [" .. i .. "/" .. #civiliansCFrame .. "]", 1.5)

            -- 5. Ibalik sa dati ang properties ng prompt (iwas anti-cheat flag)
            prompt.RequiresLineOfSight = originalRequiresLineOfSight
            prompt.MaxActivationDistance = originalMaxDistance

            -- 6. Maghintay ng 2 segundo bago lumipat sa kasunod
            task.wait(2)
        else
            notify("Warning", "No Prompt on Spot #" .. i, 2)
            task.wait(1)
        end
    end

    notify("Success", "Done Interact", 4)
end)



    
-- ====================================================================
-- Naayos na Unang Button (Idinagdag ang tamang Player check)
-- ====================================================================
createCustomButton("Section 1", "Teleport to Mika", "Go to Mika and Watch Her", function()
    -- Kinuha ang local player para hindi mag-error
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-260.086, 7.016, -299.436)
    end
end)

-- ====================================================================
-- Ang Hideo Interact Button ay WALANG MALI (100% Malinis)
-- ====================================================================
createCustomButton("Section 1", "Hideo Interact", "Teleport to Hideo and Interact", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    notify("Teleporting", "Going to Hideo...", 1.5)
    humanoidRootPart.CFrame = CFrame.new(107.692, 7.064, 269.127)
    task.wait(0.5)

    local hideoScene = Workspace:FindFirstChild("Section1") and Workspace.Section1:FindFirstChild("HideoScene")
    local hideo2 = hideoScene and hideoScene:FindFirstChild("Hideo2")
    local hrp = hideo2 and hideo2:FindFirstChild("HumanoidRootPart")
    local prompt = hrp and hrp:FindFirstChildOfClass("ProximityPrompt")

    if prompt then
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.1)

        fireproximityprompt(prompt)
        notify("Success", "Interacted on Hideo!", 2)

        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
    else
        notify("Error", "Hideo Prompt not Found", 3)
    end
end)

-- ====================================================================
-- Ang Unlock Gate & School Door Button ay WALANG MALI (100% Malinis)
-- ====================================================================
createCustomButton("Section 1", "Unlock Gate & School Door", "Get Key and Unlock The Gate and School Door", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- STAGE 1
    notify("Stage 1/3", "Goin to BoltCutter...", 2)
    humanoidRootPart.CFrame = CFrame.new(202.509, 7.060, 109.554)
    task.wait(0.5)

    local boltPrompt = Workspace:FindFirstChild("Section1")
        and Workspace.Section1:FindFirstChild("SchoolGatePart")
        and Workspace.Section1.SchoolGatePart:FindFirstChild("Truck")
        and Workspace.Section1.SchoolGatePart.Truck:FindFirstChild("BoltCutter")
        and Workspace.Section1.SchoolGatePart.Truck.BoltCutter:FindFirstChild("Main")
        and Workspace.Section1.SchoolGatePart.Truck.BoltCutter.Main:FindFirstChild("ProximityPrompt")

    if boltPrompt then
        safeFirePrompt(boltPrompt)
        notify("Stage 1 Success", "Got the BoltCutter!", 1.5)
    else
        notify("Stage 1 Failed", "BoltCutter not Found!", 3)
    end
    task.wait(1)

    -- STAGE 2
    notify("Stage 2/3", "Going to Gate...", 2)
    humanoidRootPart.CFrame = CFrame.new(124.809, 7.052, 273.595)
    task.wait(0.5)

    local gatePrompt = Workspace:FindFirstChild("Section1")
        and Workspace.Section1:FindFirstChild("SchoolGatePart")
        and Workspace.Section1.SchoolGatePart:FindFirstChild("Gate")
        and Workspace.Section1.SchoolGatePart.Gate:FindFirstChild("Chain")
        and Workspace.Section1.SchoolGatePart.Gate.Chain:FindFirstChild("PromptPart")
        and Workspace.Section1.SchoolGatePart.Gate.Chain.PromptPart:FindFirstChild("ProximityPrompt")

    if gatePrompt then
        for i = 1, 4 do
            notify("Unlocking Gate", "Firing chain prompt: (" .. i .. "/4)", 1)
            safeFirePrompt(gatePrompt)
            task.wait(0.3)
        end
        notify("Stage 2 Success", "Gate Unlocked", 1.5)
    else
        notify("Stage 2 Failed", "Gate Prompt Not Found", 3)
    end
    task.wait(1)

    -- STAGE 3
    notify("Stage 3/3", "Papunta na sa School Door...", 2)
    humanoidRootPart.CFrame = CFrame.new(174.551, 7.541, 329.988)
    task.wait(0.5)

    local doorPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("School")
        and Workspace.Section2.School:FindFirstChild("Doors")
        and Workspace.Section2.School.Doors:FindFirstChild("MainDoors")
        and Workspace.Section2.School.Doors.MainDoors:FindFirstChild("EntireDoor")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor:FindFirstChild("Door")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor.Door:FindFirstChild("PROXPART")
        and Workspace.Section2.School.Doors.MainDoors.EntireDoor.Door.PROXPART:FindFirstChild("ProximityPrompt")

    if doorPrompt then
        safeFirePrompt(doorPrompt)
        notify("Stage 3 Success", "Main School Door is now open!", 2)
    else
        notify("Stage 3 Failed", "Door School Prompt Not Found", 3)
    end
    
    notify("Success", "Fully Complete", 4)
end)




-- LOCKER & DIARY

createCustomButton("Section 2", "Locker & Diary", "Teleport to Locker, open it, and read the Diary", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Local function para sa malinis na notification sa gilid
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function para sa ligtas na pag-fire ng ProximityPrompt (Anti-Cheat & Distance Bypass)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50 -- Tinaasan para abot kahit may harang
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- =========================================================================
    -- STAGE 1: Teleport sa Locker at Buksan Ito
    -- =========================================================================
    notify("Stage 1/2", "Papunta na sa Locker...", 2)
    humanoidRootPart.CFrame = CFrame.new(143.386, 20.483, 503.915)
    task.wait(0.5) -- Sandaling wait para mag-sync ang posisyon sa lapag

    local lockerPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("MAINOBJECTIVE")
        and Workspace.Section2.MAINOBJECTIVE:FindFirstChild("Locker")
        and Workspace.Section2.MAINOBJECTIVE.Locker:FindFirstChild("LockerDoor")
        and Workspace.Section2.MAINOBJECTIVE.Locker.LockerDoor:FindFirstChild("ProximityPart")
        and Workspace.Section2.MAINOBJECTIVE.Locker.LockerDoor.ProximityPart:FindFirstChild("ProximityPrompt")

    if lockerPrompt then
        safeFirePrompt(lockerPrompt)
        notify("Locker Success", "Nabuksan na ang Locker!", 1.5)
    else
        notify("Locker Warning", "Hindi mahanap ang Locker prompt! Nagpatuloy pa rin...", 2.5)
    end
    task.wait(1) -- Delay para matapos ang open animation ng locker bago lumipat sa diary

    -- =========================================================================
    -- STAGE 2: I-fire ang Red Diary Prompt (Awtomatikong pagbasa)
    -- =========================================================================
    notify("Stage 2/2", "Binabasa na ang Red Diary...", 2)
    
    local diaryPrompt = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("MAINOBJECTIVE")
        and Workspace.Section2.MAINOBJECTIVE:FindFirstChild("Diary")
        and Workspace.Section2.MAINOBJECTIVE.Diary:FindFirstChild("ProximityPrompt")

    if diaryPrompt then
        -- Tandaan: Dahil nasa tabi lang ng Locker ang Diary ayon sa layunin ng game design, 
        -- hindi mo na kailangang mag-teleport ulit. I-fi-fire na agad ito ng safeFirePrompt gamit ang distance buffer.
        safeFirePrompt(diaryPrompt)
        notify("Mission Success", "Nabasa na ang Red Diary!", 3)
    else
        notify("Error", "Hindi mahanap ang Red Diary ProximityPrompt!", 3)
    end
end)

-- ====================================================================
-- UNIFIED TOGGLE: AKARI & AKARI RAGE ESP (HOGO STYLE HIGHLIGHT) + INTEGRATED SAFE ZONE RADAR
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local akariConnection = nil
_G.RadarThreadActive = false -- Variable para kontrolin ang buhay ng radar loop

createToggle("Section 2", "Akari & Akari(Rage) Esp", "Show Esp Name Location of Monster", function(state)
    -- Kumuha o gumawa ng lalagyan sa CoreGui para sa mga visual elements
    local espContainer = CoreGui:FindFirstChild("IOHUB_AkariUnifiedContainer")
    if not espContainer then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IOHUB_AkariUnifiedContainer"
        espContainer.Parent = CoreGui
    end

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Function para maglagay ng Hogo-style Highlight at BillboardGui sa Model ni Akari
    local function applyModelESP(model, isRage)
        if not model or not model:IsA("Model") then return end
        
        local tagIdentifier = "AkariESP_" .. model.Name .. "_" .. tostring(model.WorldPivot.Position)
        if espContainer:FindFirstChild(tagIdentifier) then return end

        -- 1. Buong Katawan Highlight (Katulad ng sa Hogo ESP)
        local highlight = model:FindFirstChild("AkariHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "AkariHighlight"
            highlight.FillColor = isRage and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 0, 100) -- Pula kapag rage, Pink kapag normal
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = model
        end

        -- 2. Hanapin ang ulo o pangunahing bahagi para paglagyan ng Name Tag Billboard
        local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Hitbox") or model:FindFirstChildWhichIsA("BasePart")
        if targetPart then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = tagIdentifier
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 3.5, 0)
            billboard.Adornee = targetPart
            billboard.Parent = espContainer
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = isRage and "Akari (RAGE)" or "Akari"
            label.TextColor3 = isRage and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 0, 100)
            label.TextSize = 20
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0
            label.Parent = billboard
        end
    end

    -- Function para i-check kung Akari o AkariRage ang lumabas
    local function scanAkariFolders()
        local normalFolder = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Monster") and Workspace.Section2.Monster:FindFirstChild("Akari")
        local rageFolder = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Rage") and Workspace.Section2.Rage:FindFirstChild("AkariRage")

        if normalFolder and normalFolder:IsA("Model") then
            applyModelESP(normalFolder, false)
        end
        if rageFolder and rageFolder:IsA("Model") then
            applyModelESP(rageFolder, true)
        end
    end

    -- =========================================================================
    -- STATE EVALUATION (ON / OFF SWITCHES)
    -- =========================================================================
    if state then
        -- ===== [TOGGLE ON] =====
        -- 1. Agarang i-scan ang buong workspace para sa kasalukuyang spawn
        scanAkariFolders()

        -- 2. Makinig sa buong Workspace para sa mga biglang sumusulpot na monsters
        if not akariConnection then
            akariConnection = Workspace.DescendantAdded:Connect(function(descendant)
                task.spawn(function()
                    pcall(function()
                        if descendant.Name == "Akari" and descendant:IsA("Model") then
                            applyModelESP(descendant, false)
                        elseif descendant.Name == "AkariRage" and descendant:IsA("Model") then
                            applyModelESP(descendant, true)
                        end
                    end)
                end)
            end)
        end

        -- 3. INTEGRATED RADAR ENGINE (25-Stud SafeZone Radar)
        if not _G.RadarThreadActive then
            _G.RadarThreadActive = true
            task.spawn(function()
                local safeZoneCFrame = CFrame.new(174.887, 9.931, 368.043)
                local safetyDistanceThreshold = 25

                while _G.RadarThreadActive do
                    task.wait(0.15)
                    
                    local character = player.Character
                    local currentHRP = character and character:FindFirstChild("HumanoidRootPart")
                    
                    local normalAkari = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Monster") and Workspace.Section2.Monster:FindFirstChild("Akari")
                    local rageAkari = Workspace:FindFirstChild("Section2") and Workspace.Section2:FindFirstChild("Rage") and Workspace.Section2.Rage:FindFirstChild("AkariRage")
                    
                    local threatModel = normalAkari or rageAkari
                    local threatPart = threatModel and (threatModel:FindFirstChild("HumanoidRootPart") or threatModel:FindFirstChild("Hitbox") or threatModel:FindFirstChildWhichIsA("BasePart"))
                    
                    if threatPart and currentHRP then
                        local distance = (currentHRP.Position - threatPart.Position).Magnitude
                        
                            if distance <= safetyDistanceThreshold then
                            local threatName = (threatModel.Name == "AkariRage") and "Akari (RAGE)" or "Akari"
                            notify("🚨 DANGER DETECTED", threatName .. " is within " .. math.floor(distance) .. " studs! Teleporting to SafeZone!", 3)
                            
                            -- Konekta dito para automatic ding mapatay ang Auto AkariSpider loop
                            _G.SpiderKillLoopActive = false 
                            
                            currentHRP.CFrame = safeZoneCFrame
                            task.wait(2.5) -- Cooldown buffer to prevent teleport loops
                        end

                    end
                end
            end)
        end

        notify("IOHUB ACTIVE", "📦 Hogo-Style ESP and SafeZone Radar: ON", 3)
    else
        -- ===== [TOGGLE OFF] =====
        if akariConnection then
            akariConnection:Disconnect()
            akariConnection = nil
        end
        
        _G.RadarThreadActive = false
        
        -- Alisin ang mga Highlight sa mga modelo ni Akari
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc.Name == "AkariHighlight" then
                desc:Destroy()
            end
        end
        
        if espContainer then
            espContainer:ClearAllChildren()
        end
        
        notify("IOHUB STATUS", "⚪ ESP and SafeZone Radar: OFF", 2)
    end
end)



-- ====================================================================
-- SECTION 2 AKARI SPIDER AUTO-KILL LOOP & TIMED EXIT DOOR BUTTON
-- ====================================================================
createCustomButton("Section 2", "Auto AkariSpider", "Teleport to AkariSpider and Kill", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Global variable thread configuration to allow safe interlocking cancellations
    _G.SpiderKillLoopActive = false
    task.wait(0.15)
    _G.SpiderKillLoopActive = true
    _G.EradicatedSpidersTable = {} 

    -- Local function for clean English side notifications
    local function notify(title, text)
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end

    -- Line of Sight and Proximity Prompt Overrider (Bypasses eyesight checks point-blank)
    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        task.wait(0.05)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    -- Verify your core Section 2 target spiders directory folder path structure
    local spidersFolder = Workspace:FindFirstChild("Section2")
        and Workspace.Section2:FindFirstChild("MAINOBJECTIVE2")
        and Workspace.Section2.MAINOBJECTIVE2:FindFirstChild("Spiders")
        
    if not spidersFolder then
        notify("Error", "Section 2 Spiders folder not found or not loaded yet!")
        return
    end

    notify("Sniper Live", "Hyper-Spam Sniper active. Commencing room sweep...", 3)

    -- =========================================================================
    -- PHASE 1: POINT-BLANK SPIDER ERADICATION SWEEP LOOP
    -- =========================================================================
    task.spawn(function()
        while _G.SpiderKillLoopActive do
            if not character or not character.Parent or not humanoidRootPart.Parent then break end
            
            local targetSpiderModel = nil
            local targetCFrame = nil
            
            -- SCANNER LOOP: Look for any loaded Akari Spiders inside your custom Workspace folder path
            local currentSpidersList = spidersFolder:GetChildren()
            local remainingSpiderTargetsCount = 0
            
            for _, spiderObj in ipairs(currentSpidersList) do
                if spiderObj:IsA("Model") and not _G.EradicatedSpidersTable[spiderObj] then
                    local validPart = spiderObj:FindFirstChild("Hitbox") or spiderObj:FindFirstChild("HumanoidRootPart") or spiderObj:FindFirstChildWhichIsA("BasePart", true)
                    if validPart and validPart.Parent then
                        remainingSpiderTargetsCount = remainingSpiderTargetsCount + 1
                        if not targetSpiderModel then
                            targetSpiderModel = spiderObj
                            targetCFrame = validPart.CFrame 
                        end
                    end
                end
            end
            
            -- INTERLOCK ESCAPE GATEWAY: Breaks Phase 1 once the uncompleted targets count drops to 0
            if remainingSpiderTargetsCount == 0 or not targetSpiderModel or not _G.SpiderKillLoopActive then
                notify("Area Cleared", "All spiders eliminated! Transitioning to Exit Gate...", 2)
                break
            end
            
            -- TRIGGER ATK PHASE: Execute locked 2-second burst damage payload on the current spider index
            if targetSpiderModel and targetCFrame and _G.SpiderKillLoopActive then
                pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                task.wait(0.01)
                
                -- Secure target position coordinates 4 studs below the spider hitbox grid mesh
                local safeSnapCFrame = targetCFrame * CFrame.new(0, -4, 0)
                humanoidRootPart.CFrame = safeSnapCFrame
                task.wait(0.15) 

                -- HEARTBEAT GLUE LAYER: Locks your root part tightly at point-blank range
                local isLockingActive = true
                local lockConnection
                lockConnection = RunService.Heartbeat:Connect(function()
                    if isLockingActive and humanoidRootPart and _G.SpiderKillLoopActive then
                        humanoidRootPart.CFrame = safeSnapCFrame 
                        humanoidRootPart.Velocity = Vector3.new(0, 0, 0) 
                    end
                end)

                notify("Target Captured", "Spamming damage data to: " .. targetSpiderModel.Name, 1)

                -- TIMED 2-SECOND HYPER-SPAM COOLDOWN WINDOW: Fires multiple damage packet injection waves
                local startTime = os.clock()
                while _G.SpiderKillLoopActive and (os.clock() - startTime < 2.0) do
                    if not targetSpiderModel or not targetSpiderModel.Parent then break end
                    
                    pcall(function()
                        for _, insideDescendant in ipairs(targetSpiderModel:GetDescendants()) do
                            if insideDescendant:IsA("RemoteEvent") then
                                insideDescendant:FireServer()
                                insideDescendant:FireServer("Damage", 100)
                                insideDescendant:FireServer("Kill")
                                insideDescendant:FireServer(true)
                            end
                        end
                    end)
                    task.wait(0.1) -- Rapid fire rate interval delay
                end

                -- Disconnect the heartbeat frame physics weld
                isLockingActive = false
                if lockConnection then lockConnection:Disconnect() end
                
                -- Permanently blacklist this unique model group memory address
                _G.EradicatedSpidersTable[targetSpiderModel] = true
                task.wait(0.05) 
            end
        end

        -- =========================================================================
        -- PHASE 2: AUTOMATIC FINAL TELEPORT & RELIABLE TIMED EXIT PROMPT CHECK
        -- =========================================================================
        if _G.SpiderKillLoopActive then
            notify("Exit Phase", "Teleporting directly to School Exit Gate...", 2)
            
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
            task.wait(0.02)
            
            -- Teleport directly to your requested school exit checkpoint coordinate node
            local exitDoorCFrame = CFrame.new(174.953, 7.586, 513.158)
            humanoidRootPart.CFrame = exitDoorCFrame
            task.wait(0.3) -- Basic coordinate settle gap

            -- =========================================================================
            -- TIMED DELAY UPGRADE: Forced 2-second delay to settle server components
            -- =========================================================================
            for secondsLeft = 2, 1, -1 do
                if not _G.SpiderKillLoopActive then break end
                notify("Syncing Map", "Enforcing server synchronization: " .. secondsLeft .. "s...", 1)
                task.wait(1)
            end

            notify("Searching Prompt", "Scanning directory tree for Exit ProximityPrompt...", 1.5)
            
            -- Recursive lookup loop structure using active timeout verification gates
            local exitPrompt = nil
            local scanAttempts = 0
            
            while not exitPrompt and scanAttempts < 30 and _G.SpiderKillLoopActive do
                scanAttempts = scanAttempts + 1
                
                -- Dynamic tree evaluation checking your verified path string
                local doorFolder = Workspace:FindFirstChild("Section2")
                    and Workspace.Section2:FindFirstChild("School")
                    and Workspace.Section2.School:FindFirstChild("Doors")
                    and Workspace.Section2.School.Doors:FindFirstChild("ExitDoor")
                
                if doorFolder then
                    local proxPart = doorFolder:FindFirstChild("ProxPart")
                    exitPrompt = proxPart and proxPart:FindFirstChildOfClass("ProximityPrompt")
                end
                
                -- Fallback Tree Scanning check running concurrently in case indexing fails
                if not exitPrompt then
                    local fallbackExit = Workspace:FindFirstChild("ExitDoor", true)
                    exitPrompt = fallbackExit and fallbackExit:FindFirstChildWhichIsA("ProximityPrompt", true)
                end
                
                if not exitPrompt then 
                    task.wait(0.1) -- Refresh cycle frequency
                end
            end

            -- Execute the prompt interaction footprint sequence point-blank
            if exitPrompt then
                safeFirePrompt(exitPrompt)
                notify("Mission Completed", "Exit Door activated successfully! Section 2 cleared.", 4)
            else
                notify("Streaming Failure", "Exit Door prompt failed to stream into the Workspace cache!", 4)
            end
        end
    end)
end)




-- CONTACT IJO


createCustomButton("Section 3", "Contact IJO Quest", "Teleport to Ijo, wait 3s, and back to SafeZone", function()
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Local function para sa malinis na notification sa gilid
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Ang iyong mga eksaktong CFrame coordinates
    local ijoCFrame = CFrame.new(-3392.948, 8.000, 763.995)
    local section3SafeZone = CFrame.new(-3584.720, 8.000, 247.522)

    -- =========================================================================
    -- STAGE 1: Teleport kay Contact Ijo
    -- =========================================================================
    notify("Stage 1/2", "Papunta na kay Contact Ijo...", 2)
    
    -- Bypass collision/physics locking bago lumipat
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    task.wait(0.02)
    
    humanoidRootPart.CFrame = ijoCFrame

    -- =========================================================================
    -- STAGE 2: Maghintay ng 3 Segundo (Interaction/Quest trigger window)
    -- =========================================================================
    for i = 3, 1, -1 do
        notify("Waiting...", "Nasa tapat ni Ijo. Babalik sa SafeZone sa loob ng " .. i .. "s...", 1)
        task.wait(1)
    end

    -- =========================================================================
    -- STAGE 3: Awtomatikong Pagbalik sa SafeZone
    -- =========================================================================
    notify("Stage 2/2", "Bumabalik na sa SafeZone...", 1.5)
    
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    task.wait(0.02)
    
    humanoidRootPart.CFrame = section3SafeZone
    notify("Mission Complete", "Naka-secure na sa SafeZone!", 3)
end)


-- ====================================================================
-- SECTION 3 MIZUNO ESP (HOGO STYLE HIGHLIGHT) + INTEGRATED SAFE ZONE RADAR
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local section3Connection = nil
_G.Section3RadarActive = false 

createToggle("Section 3", "Mizuno Box & Name ESP", "Highlights Mizuno and enables the 25-stud escape radar", function(state)
    -- Lumikha ng hiwalay na container sa CoreGui para sa Section 3 assets
    local espContainer = CoreGui:FindFirstChild("IOHUB_Section3Container")
    if not espContainer then
        espContainer = Instance.new("Folder")
        espContainer.Name = "IOHUB_Section3Container"
        espContainer.Parent = CoreGui
    end

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Function para maglagay ng Hogo-style Highlight at BillboardGui sa Model ni Mizuno
    local function applyModelESP(model)
        if not model or not model:IsA("Model") then return end
        
        local tagIdentifier = "MizunoESP_" .. model.Name
        if espContainer:FindFirstChild(tagIdentifier) then return end

        -- 1. Buong Katawan Highlight (Katulad ng sa Hogo ESP)
        local highlight = model:FindFirstChild("MizunoHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "MizunoHighlight"
            highlight.FillColor = Color3.fromRGB(0, 255, 255) -- Neon Cyan
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = model
        end

        -- 2. Hanapin ang ulo o root part para sa Name Tag Billboard
        local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Hitbox") or model:FindFirstChildWhichIsA("BasePart")
        if targetPart then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = tagIdentifier
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 3.5, 0)
            billboard.Adornee = targetPart
            billboard.Parent = espContainer
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "Mizuno"
            label.TextColor3 = Color3.fromRGB(0, 255, 255)
            label.TextSize = 20
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0
            label.Parent = billboard
        end
    end

    -- Function para i-check ang folder ni Mizuno
    local function scanMizunoFolder()
        local mizunoFolder = Workspace:FindFirstChild("Section3") 
            and Workspace.Section3:FindFirstChild("Monster") 
            and Workspace.Section3.Monster:FindFirstChild("Mizuno")

        if mizunoFolder and mizunoFolder:IsA("Model") then
            applyModelESP(mizunoFolder)
        end
    end

    -- =========================================================================
    -- STATE CONTROL (ON / OFF SWITCHES)
    -- =========================================================================
    if state then
        -- ===== [TOGGLE ON] =====
        -- 1. I-scan agad ang Workspace
        scanMizunoFolder()

        -- 2. Makinig gamit ang DescendantAdded para sa live tracking
        if not section3Connection then
            section3Connection = Workspace.DescendantAdded:Connect(function(descendant)
                task.spawn(function()
                    pcall(function()
                        if descendant.Name == "Mizuno" and descendant:IsA("Model") then
                            applyModelESP(descendant)
                        end
                    end)
                end)
            end)
        end

        -- 3. INTEGRATED RADAR ENGINE FOR MIZUNO (25 Studs Range Threshold Check)
        if not _G.Section3RadarActive then
            _G.Section3RadarActive = true
            task.spawn(function()
                local section3SafeZone = CFrame.new(-3584.720, 8.000, 247.522)
                local safetyDistanceThreshold = 25 

                while _G.Section3RadarActive do
                    task.wait(0.15)
                    
                    local character = player.Character
                    local currentHRP = character and character:FindFirstChild("HumanoidRootPart")
                    
                    local liveMizuno = Workspace:FindFirstChild("Section3") 
                        and Workspace.Section3:FindFirstChild("Monster") 
                        and Workspace.Section3.Monster:FindFirstChild("Mizuno")
                        
                    local threatPart = liveMizuno and (liveMizuno:FindFirstChild("HumanoidRootPart") or liveMizuno:FindFirstChild("Hitbox") or liveMizuno:FindFirstChildWhichIsA("BasePart"))
                    
                    if threatPart and currentHRP then
                        local distance = (currentHRP.Position - threatPart.Position).Magnitude
                        
                                               if distance <= safetyDistanceThreshold then
                            notify("🚨 MIZUNO DETECTED", "Mizuno is within " .. math.floor(distance) .. " studs! Teleporting to SafeZone!", 3)
                            
                            -- Papatayin nito ang Auto Restore Power loop o tween kapag may banta
                            _G.Section3RestoreActive = false
                            
                            currentHRP.CFrame = section3SafeZone
                            task.wait(2.5) 
                        end

                    end
                end
            end)
        end

        notify("IOHUB ACTIVE", "📦 Mizuno Hogo-Style ESP and Radar: ON", 3)
    else
        -- ===== [TOGGLE OFF] =====
        if section3Connection then
            section3Connection:Disconnect()
            section3Connection = nil
        end
        
        _G.Section3RadarActive = false
        
        -- Alisin ang mga Highlight kay Mizuno
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc.Name == "MizunoHighlight" then
                desc:Destroy()
            end
        end
        
        if espContainer then
            espContainer:ClearAllChildren()
        end
        
        notify("IOHUB STATUS", "⚪ Mizuno ESP and Radar: OFF", 2)
    end
end)





createCustomButton("Section 3", "Auto Restore Power", "Teleport to All Power Circuit and Finish MiniGame", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Global control variable para makontrol ng SafeZone radar
    _G.Section3RestoreActive = false
    task.wait(0.15)
    _G.Section3RestoreActive = true

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Helper function for safe ProximityPrompt triggering
    local function safeFirePrompt(prompt)
        if prompt then
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50
            task.wait(0.05)
            fireproximityprompt(prompt)
        end
        return true
    end

    -- Helper function to perform fast tweens with target speed (e.g. 250)
    local function fastTweenTo(targetCFrame, speed)
        local distance = (humanoidRootPart.Position - targetCFrame.Position).Magnitude
        local duration = distance / (speed or 250)
        
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        
        -- Abort tween kung sakaling ma-trigger ang danger
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.Section3RestoreActive then
                tween:Cancel()
                return false
            end
            task.wait(0.05)
        end
        task.wait(0.1) -- Small stabilization delay
        return true
    end

    -- Verify that the Circuits folder exists in Section 3
    local circuitsFolder = Workspace:FindFirstChild("Section3")
        and Workspace.Section3:FindFirstChild("OBJECTIVE")
        and Workspace.Section3.OBJECTIVE:FindFirstChild("Circuits")

    if not circuitsFolder then
        notify("Error", "Circuits folder not found in Section 3!", 4)
        return
    end

    -- Get the exact Cobalt module network event path
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet Remote Event path not found!", 4)
        return
    end

    local circuitPositions = {
        CFrame.new(-3230.88599, 8.51531696, 681.428955, 0.948552489, 0, 0.316619992, 0, 1, 0, -0.316619992, 0, 0.948552489),
        CFrame.new(-3594.27295, 8.64291477, 786.69104, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247),
        CFrame.new(-3513.80835, 8.46253777, 554.146118, -0.949462295, 0, 0.313881457, 0, 1, 0, -0.313881457, 0, -0.949462295),
        CFrame.new(-3153.30762, 8.55415249, 484.829102, 0, 0, 1, 0, 1, -0, -1, 0, 0),
        CFrame.new(-3388.81348, 8.52897835, 582.247437, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07),
        CFrame.new(-3699.98584, 8.54430199, 618.209167, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
    }

    local function getClosestCircuitPrompt()
        local closestPrompt = nil
        local closestCircuitModel = nil
        local shortestDistance = math.huge

        for _, obj in ipairs(circuitsFolder:GetChildren()) do
            local promptPart = obj:FindFirstChild("PromptPart")
            local prompt = promptPart and promptPart:FindFirstChildOfClass("ProximityPrompt")
            
            if prompt and promptPart then
                local distance = (humanoidRootPart.Position - promptPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPrompt = prompt
                    closestCircuitModel = obj
                end
            end
        end
        return closestPrompt, closestCircuitModel
    end

    notify("Farm Started", "Executing fast Cobalt sequence for all 6 circuits...", 3)

    -- Loop through each circuit spots
    for index, targetCFrame in ipairs(circuitPositions) do
        if not _G.Section3RestoreActive then break end
        
        notify("Progress", "Teleporting to Circuit [" .. index .. "/6]...", 1)
        
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        task.wait(0.01)
        
        humanoidRootPart.CFrame = targetCFrame
        task.wait(0.4) 

        if not _G.Section3RestoreActive then break end

        local prompt, circuitModel = getClosestCircuitPrompt()

        if prompt and circuitModel then
            safeFirePrompt(prompt)
            task.wait(0.2) 

            for round = 1, 3 do
                if not _G.Section3RestoreActive then break end
                CobaltEvent:FireServer("Section3/CircuitRoundComplete", circuitModel)
                task.wait(0.1) 
            end
            
            task.wait(0.4) 
        else
            notify("Warning", "Circuit prompt not found at Spot #" .. index, 1)
        end
    end

    if not _G.Section3RestoreActive then return end

    -- =========================================================================
    -- TWEEN CHAIN & SEQUENCE WITH SPEED 250
    -- =========================================================================
    notify("Farm Finished", "Restored! Fast-gliding to trigger cinematic...", 2)
    local firstDest = CFrame.new(-3389.176, 8.000, 807.249)
    if not fastTweenTo(firstDest, 250) then return end

    for i = 25, 1, -1 do
        if not _G.Section3RestoreActive then return end
        notify("Cinematic Window", "Waiting for scene: " .. i .. "s remaining...", 1)
        task.wait(1)
    end

    if not _G.Section3RestoreActive then return end
    notify("Door Sequence", "Fast-gliding to auto-trigger door open...", 2)
    local doorDest = CFrame.new(-3389.251, 8.000, 761.373)
    if not fastTweenTo(doorDest, 250) then return end
    
    task.wait(1)

    if not _G.Section3RestoreActive then return end
    notify("Moving to End", "Gliding to final target location...", 2)
    local endDest = CFrame.new(-3392.523, 7.675, 890.753)
    if not fastTweenTo(endDest, 250) then return end

    notify("Success", "All sequences and tweens executed successfully!", 4)
end)



createCustomButton("Section 4", "Get ID & Open Gate", "Teleports to ID Card and opens the Lab Gate", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        task.wait(0.1)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    notify("Entrance", "Starting ID & Gate sequence...", 2)

    -- =========================================================================
    -- STEP 1: Get ID Card
    -- =========================================================================
    notify("Step 1/2", "Teleporting to ID Card...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3375.321, -299.782, 4686.612)
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.5)

    local idPrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Entrance")
        and Workspace.Section4.Lab.Floor1.Entrance:FindFirstChild("IDCARD")
        and Workspace.Section4.Lab.Floor1.Entrance.IDCARD:FindFirstChild("ProximityPrompt")

    if idPrompt then
        safeFirePrompt(idPrompt)
        notify("Success", "ID Card picked up!", 1.5)
    else
        notify("Warning", "ID Card prompt not found! Proceeding...", 2)
    end
    task.wait(1)

    -- =========================================================================
    -- STEP 2: Open Lab Gate
    -- =========================================================================
    notify("Step 2/2", "Teleporting to Lab Gate...", 1.5)
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.02)
    humanoidRootPart.CFrame = CFrame.new(-3378.124, -300.218, 4662.547)
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.5)

    local gatePrompt = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("Floor1")
        and Workspace.Section4.Lab.Floor1:FindFirstChild("Entrance")
        and Workspace.Section4.Lab.Floor1.Entrance:FindFirstChild("SFXPart")
        and Workspace.Section4.Lab.Floor1.Entrance.SFXPart:FindFirstChild("ProximityPrompt")

    if gatePrompt then
        safeFirePrompt(gatePrompt)
        notify("Success", "Lab Gate opened!", 1.5)
    else
        notify("Warning", "Gate prompt not found!", 2)
    end

    notify("Complete", "ID Card acquired and Lab Gate opened!", 3)
end)




-- ====================================================================
-- INDEPENDENT AUTOMATIC VALVE HARVESTER BUTTON (FAST FIRE PATCHED)
-- ====================================================================
createCustomButton("Section 4", "Auto Valves Only", "Automates fast valve loops cleanly and moves to Contain", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    _G.CleanseRoomActive = false
    task.wait(0.15)
    _G.CleanseRoomActive = true
    _G.ClearedValves = {} 
    _G.HogoThreatDetected = false

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local function forceDexFire(prompt)
        if not prompt then return false end
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50
            
            prompt:InputHoldBegin()
            task.wait(0.01)
            prompt:InputHoldEnd()
            
            fireproximityprompt(prompt)
        end)
        return true
    end

    local cleanseFolder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("CleanseRoomObjective")

    if not cleanseFolder then
        notify("Critical Error", "CleanseRoomObjective folder not found!", 4)
        return
    end

    notify("Valves Farm", "Initializing fast Valve automation...", 3)
    task.wait(0.2)

    local valvesFolder = cleanseFolder:FindFirstChild("Valves")
    if valvesFolder then
        while _G.CleanseRoomActive do
            if _G.HogoThreatDetected then
                notify("Emergency Abort", "Automation killed due to immediate threat presence!", 3)
                break
            end

            local currentValvesList = valvesFolder:GetChildren()
            local targetValve = nil
            local remainingUncleanedCount = 0
            
            for _, obj in ipairs(currentValvesList) do
                if obj:IsA("Model") and not _G.ClearedValves[obj.Name] then
                    remainingUncleanedCount = remainingUncleanedCount + 1
                    if not targetValve then
                        targetValve = obj 
                    end
                end
            end
            
            if remainingUncleanedCount == 0 or not targetValve or not _G.CleanseRoomActive then
                break
            end
            
            if targetValve and _G.CleanseRoomActive then
                notify("Valve Locked", "Snapping coordinates to: " .. targetValve.Name, 1.5)
                
                pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                task.wait(0.01)
                
                local freshPivot = targetValve:GetPivot()
                humanoidRootPart.CFrame = freshPivot
                task.wait(0.3)

                local isLockingActive = true
                local lockConnection
                lockConnection = RunService.Heartbeat:Connect(function()
                    if isLockingActive and humanoidRootPart and _G.CleanseRoomActive and not _G.HogoThreatDetected then
                        humanoidRootPart.CFrame = freshPivot 
                        humanoidRootPart.Velocity = Vector3.new(0, 0, 0) 
                    else
                        if lockConnection then lockConnection:Disconnect() end
                    end
                end)

                -- FAST RAPID-FIRE 2-SECOND WINDOW
                notify("Fast Spam", "Rapid firing prompts inside " .. targetValve.Name, 1.5)
                local startTime = os.clock()
                
                while _G.CleanseRoomActive and not _G.HogoThreatDetected and (os.clock() - startTime < 2.0) do
                    if not targetValve or not targetValve.Parent then break end
                    
                    local firedAny = false
                    for _, descendant in ipairs(targetValve:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            forceDexFire(descendant)
                            firedAny = true
                        end
                    end
                    
                    if firedAny then
                        task.wait(0.05)
                    else
                        task.wait(0.02)
                    end
                end

                isLockingActive = false
                if lockConnection then lockConnection:Disconnect() end
                
                if _G.HogoThreatDetected then break end

                _G.ClearedValves[targetValve.Name] = true
                notify("Valve Logged", "Successfully cleared " .. targetValve.Name, 1.5)
                
                for secondsLeft = 2, 1, -1 do
                    if not _G.CleanseRoomActive or _G.HogoThreatDetected then break end
                    notify("Transition", "Moving to next valve in " .. secondsLeft .. "s...", 1)
                    task.wait(1)
                end
            end
        end
    end

    if _G.CleanseRoomActive and not _G.HogoThreatDetected then
        notify("Valves Clear", "Teleporting to Contain location...", 2.5)
        task.wait(0.5)

        local containCFrame = CFrame.new(-3441.648, -299.855, 4378.025)
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        task.wait(0.02)
        
        humanoidRootPart.CFrame = containCFrame
        notify("Success", "Arrived safely at the Contain zone!", 4)
    end
end)


-- ====================================================================
-- INDEPENDENT COBALT SHAPE TERMINAL BYPASS BUTTON (POV RELEASE FIXED)
-- ====================================================================
createCustomButton("Section 4", "Auto Terminals Only", "Bypasses all shape terminals instantly and moves to Contain", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Global variable thread configuration to allow safe interlocking cancellations
    _G.CleanseRoomActive = false
    task.wait(0.15)
    _G.CleanseRoomActive = true
    _G.ClearedTerminalsMemory = {} -- Blacklist tracking map using unique object reference addresses

    -- Local function for clean English side notifications
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- MINIDEX SUPREMACY FIRE ENGINE (Bypasses eyesight line checks natively)
    local function forceDexFire(prompt)
        if not prompt then return false end
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50
            
            prompt:InputHoldBegin()
            task.wait(0.02)
            prompt:InputHoldEnd()
            
            fireproximityprompt(prompt)
        end)
        return true
    end

    -- Grab the verified Cobalt Module Event from your logs
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet route not found!", 4)
        return
    end

    -- Core Objective Folder Path
    local cleanseFolder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("CleanseRoomObjective")

    if not cleanseFolder then
        notify("Critical Error", "CleanseRoomObjective folder not found!", 4)
        return
    end

    notify("Terminals Farm", "Initializing Shape Terminals network scan...", 3)
    task.wait(0.5)

    local shapeTerminalsFolder = cleanseFolder:FindFirstChild("ShapeTerminals")
    if shapeTerminalsFolder then
        while _G.CleanseRoomActive do
            local currentTerminalsList = shapeTerminalsFolder:GetChildren()
            local targetTerminalUnit = nil
            local activeUncleanedCount = 0
            
            -- SCANNER WITH MEMORY REFERENCE: Identifies each "Terminal" frame even if sharing identical names
            for _, obj in ipairs(currentTerminalsList) do
                if obj:IsA("Model") and (obj.Name == "Terminal" or string.find(obj.Name:lower(), "terminal")) and not _G.ClearedTerminalsMemory[obj] then
                    activeUncleanedCount = activeUncleanedCount + 1
                    if not targetTerminalUnit then
                        targetTerminalUnit = obj -- Lock onto the unique object memory slot reference location
                    end
                end
            end
            
            -- INTERLOCK BREAK GATES: Safely abort loop layer if all folder elements have been cleanly blacklisted
            if activeUncleanedCount == 0 or not targetTerminalUnit or not _G.CleanseRoomActive then
                notify("Terminals Clear", "All loaded terminals successfully processed!", 2)
                break
            end
            
            -- =========================================================================
            -- PIPELINE: TARGET EXECUTION RELAY BLOCK
            -- =========================================================================
            if targetTerminalUnit and _G.CleanseRoomActive then
                local promptPart = targetTerminalUnit:FindFirstChild("PromptPart") or targetTerminalUnit:FindFirstChildWhichIsA("BasePart", true)
                local terminalPrompt = targetTerminalUnit:FindFirstChildWhichIsA("ProximityPrompt", true)

                if promptPart then
                    notify("Terminal Lock", "Snapping coordinates to active Terminal frame...", 1.5)
                    
                    -- STEP 1: Teleport character model point-blank to meet distance evaluation criteria
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    task.wait(0.01)
                    
                    -- Dynamic position offset alignment to avoid physical clip blocks
                    humanoidRootPart.CFrame = promptPart.CFrame * CFrame.new(0, 0, -1)
                    task.wait(0.6) -- HUMANIZED physics delay allows streaming assets to render properly

                    -- STEP 2: Fire prompt to visually register the activation event footprint token on the server
                    if terminalPrompt then
                        forceDexFire(terminalPrompt)
                        task.wait(0.4) -- Wait delay gives the game UI pipeline time to render completely "Open"
                    end

                    -- STEP 3: HYPER INJECTION COBALT CHAIN (2 Rounds for this specific model reference pointer)
                    notify("Bypassing", "Injecting 2x RoundComplete packets...", 1)
                    pcall(function()
                        -- Round 1 Completion Packet
                        CobaltEvent:FireServer("ShapeTerminal/RoundComplete", targetTerminalUnit)
                        task.wait(0.25) -- Safe firing interval prevents network drop rate throttling
                        
                        -- Round 2 Completion Packet
                        CobaltEvent:FireServer("ShapeTerminal/RoundComplete", targetTerminalUnit)
                        task.wait(0.25)
                    end)

                    -- STEP 4: RELEASE SIGNAL INJECTION (Completely tears down the camera block)
                    pcall(function()
                        CobaltEvent:FireServer("ShapeTerminal/Release", targetTerminalUnit)
                    end)
                    notify("POV Restored", "Terminal camera lock released cleanly!", 1)
                    
                    -- Blacklist the completed unique pointer so the next scanning loop ignores it entirely
                    _G.ClearedTerminalsMemory[targetTerminalUnit] = true
                    task.wait(0.6) -- Post-terminal cooldown buffer spacing to settle character properties
                else
                    -- Fallback index blocking if target instance lacks solid structure paths
                    _G.ClearedTerminalsMemory[targetTerminalUnit] = true
                    task.wait(0.1)
                end
            end
        end
    end

    -- =========================================================================
    -- TERMINAL ROUTING ENDPOINT: TELEPORT TO CONTAIN CFRAME
    -- =========================================================================
    if _G.CleanseRoomActive then
        notify("Quest Finished", "All sectors completed! Teleporting to Contain location...", 2.5)
        task.wait(0.5)

        local containCFrame = CFrame.new(-3441.648, -299.855, 4378.025)
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        task.wait(0.02)
        
        humanoidRootPart.CFrame = containCFrame
        notify("Success", "Arrived safely at the Contain zone!", 4)
    end
end)

-- ====================================================================
-- INDEPENDENT COBALT SHAPE TERMINAL BYPASS (INSTANT EVENT FIRE ONLY)
-- ====================================================================
createCustomButton("Section 4", "Auto Terminals Only V2", "Bypasses all shape terminals instantly via Cobalt and moves to Contain", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    _G.CleanseRoomActive = false
    task.wait(0.15)
    _G.CleanseRoomActive = true
    _G.ClearedTerminalsMemory = {}

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet route not found!", 4)
        return
    end

    local cleanseFolder = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("CleanseRoomObjective")

    if not cleanseFolder then
        notify("Critical Error", "CleanseRoomObjective folder not found!", 4)
        return
    end

    notify("Terminals Farm", "Initializing Instant Cobalt Shape Terminals scan...", 3)
    task.wait(0.3)

    local shapeTerminalsFolder = cleanseFolder:FindFirstChild("ShapeTerminals")
    if shapeTerminalsFolder then
        while _G.CleanseRoomActive do
            local currentTerminalsList = shapeTerminalsFolder:GetChildren()
            local targetTerminalUnit = nil
            local activeUncleanedCount = 0
            
            for _, obj in ipairs(currentTerminalsList) do
                if obj:IsA("Model") and (obj.Name == "Terminal" or string.find(obj.Name:lower(), "terminal")) and not _G.ClearedTerminalsMemory[obj] then
                    activeUncleanedCount = activeUncleanedCount + 1
                    if not targetTerminalUnit then
                        targetTerminalUnit = obj
                    end
                end
            end
            
            if activeUncleanedCount == 0 or not targetTerminalUnit or not _G.CleanseRoomActive then
                notify("Terminals Clear", "All loaded terminals successfully bypassed!", 2)
                break
            end
            
            if targetTerminalUnit and _G.CleanseRoomActive then
                local promptPart = targetTerminalUnit:FindFirstChild("PromptPart") or targetTerminalUnit:FindFirstChildWhichIsA("BasePart", true)

                if promptPart then
                    -- Teleport muna sa pwesto para di ka ma-anticheat kick sa layo
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    task.wait(0.01)
                    humanoidRootPart.CFrame = promptPart.CFrame * CFrame.new(0, 0, -1)
                    task.wait(0.2)

                    -- Instant Cobalt Fire (Walang prompt clicking)
                    pcall(function()
                        CobaltEvent:FireServer("ShapeTerminal/RoundComplete", targetTerminalUnit)
                        task.wait(0.1)
                        CobaltEvent:FireServer("ShapeTerminal/RoundComplete", targetTerminalUnit)
                        task.wait(0.1)
                        CobaltEvent:FireServer("ShapeTerminal/Release", targetTerminalUnit)
                    end)
                    
                    notify("Bypassed", "Terminal instantly cleared via packet!", 1)
                    _G.ClearedTerminalsMemory[targetTerminalUnit] = true
                    task.wait(0.2)
                else
                    _G.ClearedTerminalsMemory[targetTerminalUnit] = true
                    task.wait(0.1)
                end
            end
        end
    end

    if _G.CleanseRoomActive then
        notify("Quest Finished", "All sectors completed! Teleporting to Contain location...", 2)
        task.wait(0.3)

        local containCFrame = CFrame.new(-3441.648, -299.855, 4378.025)
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        task.wait(0.02)
        
        humanoidRootPart.CFrame = containCFrame
        notify("Success", "Arrived safely at the Contain zone!", 3)
    end
end)



-- ====================================================================
-- AUTO EXIT TO STAIRS BUTTON WRAPPER (TELEPORT VERSION)
-- ====================================================================
createCustomButton("Section 4", "Exit to Stairs", "Teleports to exit position and fires the ProximityPrompt", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Hanapin ang ProximityPrompt gamit ang path
    local exitPart = Workspace:FindFirstChild("Section4")
        and Workspace.Section4:FindFirstChild("Lab")
        and Workspace.Section4.Lab:FindFirstChild("ExitToStairs")
        and Workspace.Section4.Lab.ExitToStairs:FindFirstChild("EXIT")
        and Workspace.Section4.Lab.ExitToStairs.EXIT:FindFirstChild("ProxPart")

    local prompt = exitPart and exitPart:FindFirstChild("ProximityPrompt")

    if not prompt then
        notify("Error", "Exit ProximityPrompt not found!", 4)
        return
    end

    notify("Teleporting", "Teleporting to Exit to Stairs...", 2)

    -- Target CFrame mula sa binigay mong coordinates
    local targetPosition = CFrame.new(-3467.400, -299.855, 4349.562)
    
    -- Instant Teleport at tanggal velocity para hindi ma-fling
    humanoidRootPart.CFrame = targetPosition
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.3)

    -- I-adjust muna ang properties ng prompt para siguradong gagana
    local originalRequiresLineOfSight = prompt.RequiresLineOfSight
    local originalMaxDistance = prompt.MaxActivationDistance
    
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 50
    task.wait(0.05)

    -- I-fire ang prompt
    fireproximityprompt(prompt)
    notify("Success", "Exit prompt triggered!", 2)
    task.wait(0.5)

    -- Ibalik sa dati ang prompt properties
    prompt.RequiresLineOfSight = originalRequiresLineOfSight
    prompt.MaxActivationDistance = originalMaxDistance

    notify("Complete", "Successfully used Exit to Stairs!", 3)
end)




-- ====================================================================
-- BUTTON 1: SECTION 5 MAIN SWITCH ACTIVATOR
-- ====================================================================
createCustomButton("Section 5", "Main Switch", "Teleport to Main Switch and Turn On", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local function safeFirePrompt(prompt)
        if not prompt then return false end
        local originalRequiresLineOfSight = prompt.RequiresLineOfSight
        local originalMaxDistance = prompt.MaxActivationDistance
        
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        task.wait(0.05)
        
        fireproximityprompt(prompt)
        
        prompt.RequiresLineOfSight = originalRequiresLineOfSight
        prompt.MaxActivationDistance = originalMaxDistance
        return true
    end

    local powerSwitchModel = Workspace:FindFirstChild("Section5")
        and Workspace.Section5:FindFirstChild("MainObjective")
        and Workspace.Section5.MainObjective:FindFirstChild("PowerSwitch")

    if not powerSwitchModel then
        notify("Error", "PowerSwitch path not found in Section 5!", 4)
        return
    end

    notify("Power Switch", "Teleporting to Main Power Switch...", 1.5)

    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.01)

    -- Hardcoded position lock anchor coordinates
    local switchCFrame = CFrame.new(-2037.31445, -353.530029, 4641.99805)
    humanoidRootPart.CFrame = switchCFrame
    task.wait(0.5) -- Streaming context safety buffer

    local switchPrompt = powerSwitchModel:FindFirstChild("RootPart")
        and powerSwitchModel.RootPart:FindFirstChildOfClass("ProximityPrompt")
        or powerSwitchModel:FindFirstChildWhichIsA("ProximityPrompt", true)

    if switchPrompt then
        safeFirePrompt(switchPrompt)
        notify("Success", "Power Switch triggered completely!", 3)
    else
        notify("Warning", "Switch prompt instance not visible yet!", 3)
    end
end)

-- ====================================================================
-- BUTTON 2: HYPER-SPEED SILENT WIREBOX INJECTOR (ANTI-MONSTER ATTACK)
-- ====================================================================
createCustomButton("Section 5", "Auto Fix Wirebox", "Fix All Wirebox without teleporting", function()
    local Workspace = game:GetService("Workspace")
    local StarterGui = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    -- Grab the verified Cobalt Module Event directly from memory
    local CobaltEvent = ReplicatedStorage:FindFirstChild("modules")
        and ReplicatedStorage.modules:FindFirstChild("Packet")
        and ReplicatedStorage.modules.Packet:FindFirstChild("Reliable")

    if not CobaltEvent then
        notify("Critical Error", "Cobalt Packet route not found!", 4)
        return
    end

    local boxesFolder = Workspace:FindFirstChild("Section5")
        and Workspace.Section5:FindFirstChild("MainObjective")
        and Workspace.Section5.MainObjective:FindFirstChild("Boxes")

    if not boxesFolder then
        notify("Critical Error", "Boxes folder not loaded in Workspace!", 4)
        return
    end

    local wireBoxesList = boxesFolder:GetChildren()
    notify("Sniper Active", "Launching packet extraction on " .. tostring(#wireBoxesList) .. " wireboxes...", 2)

    -- LIGHTNING EXECUTION LOOP: Purong network packets, walang physics teleportation at lag
    for index, targetBox in ipairs(wireBoxesList) do
        if targetBox.Name == "WireBox" or targetBox:IsA("Model") then
            -- Mabilis na sunod-sunod na pagpapadala ng buong 3-signal logic loop matrix
            pcall(function()
                -- 1. Angkinin ang device sa server
                CobaltEvent:FireServer("Section5/WireBoxClaim", targetBox)
                
                -- 2. Solusyunan agad ang machine engine
                CobaltEvent:FireServer("Section5/WireBoxComplete", targetBox)
                
                -- 3. Isara at patayin ang UI overlay layer screen block
                CobaltEvent:FireServer("Section5/WireBoxRelease", targetBox)
            end)
        end
    end

    notify("Sniper Finished", "All wireboxes bypassed silently! Trigger Main Switch now.", 4)
end)




createCustomButton("Section 5", "Hospital Cinematic Extra", "Standing on Shion Bed (Other Player Can See You)", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-2563.28369, -392.85376, 4208.02734, 0.999966621, -4.32398883e-06, 0.00816796999, 2.56917538e-05, 0.999996603, -0.00261594029, -0.00816793088, 0.00261606299, 0.999963224) 
    end
end)



createCustomButton("Settings", "DayTime/Morning", "Leave to the Darkness", function()
    local lighting = game:GetService("Lighting")
    
    pcall(function()
        -- 1. I-set ang oras sa tanghali
        lighting.ClockTime = 14
        lighting.Brightness = 3
        lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        lighting.Ambient = Color3.fromRGB(150, 150, 150)
        lighting.GlobalShadows = false
        
        -- 2. Tanggalin o i-neutralize ang Atmosphere (pula/maulap na epekto)
        for _, child in ipairs(lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                -- Gawing transparent o alisin ang density at kulay ng ulap
                child.Density = 0
                child.Haze = 0
                child.Color = Color3.fromRGB(255, 255, 255)
                child.Decay = Color3.fromRGB(255, 255, 255)
            elseif child:IsA("ColorCorrectionEffect") then
                -- Alisin ang tint o redness
                child.TintColor = Color3.fromRGB(255, 255, 255)
                child.Saturation = 0.1
                child.Contrast = 0.1
            elseif child:IsA("Sky") then
                -- Opsyonal: Pwedeng tanggalin o hayaan, pero mas maganda kung babaguhin ang lighting properties
                child.StarCount = 0
            elseif child:IsA("PointLight") or child:IsA("SpotLight") then
                child.Brightness = 5
                child.Range = 60
            end
        end
    end)
    
    notify("Settings Updated", "The DayTime Morning Activated", 2.5)
end)





switchTab("Section 1")

