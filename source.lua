local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Archived = {}
Archived.__index = Archived

local Settings = {
    Name = "Archived",
    Theme = {
        Accent = Color3.fromRGB(155, 89, 182),
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(25, 25, 25),
        Container = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(240, 240, 240),
        DarkText = Color3.fromRGB(170, 170, 170),
        Outline = Color3.fromRGB(40, 40, 40)
    },
    Folder = "ArchivedConfig"
}

if not isfolder(Settings.Folder) then
    makefolder(Settings.Folder)
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindableEvent = Instance.new("BindableEvent")
    return self
end

function Signal:Fire(...)
    self._bindableEvent:Fire(...)
end

function Signal:Connect(handler)
    if not (type(handler) == "function") then
        error("Handler must be a function")
    end
    return self._bindableEvent.Event:Connect(handler)
end

function Signal:Destroy()
    if self._bindableEvent then
        self._bindableEvent:Destroy()
        self._bindableEvent = nil
    end
end

local Utility = {}

function Utility:Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:GetTextSize(text, font, size, width)
    return TextService:GetTextSize(text, size, font, Vector2.new(width, 10000))
end

function Utility:Ripple(object)
    spawn(function()
        local circle = Instance.new("ImageLabel")
        circle.Name = "Ripple"
        circle.Parent = object
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BackgroundTransparency = 1.000
        circle.ZIndex = 10
        circle.Image = "rbxassetid://266543268"
        circle.ImageColor3 = Color3.fromRGB(210, 210, 210)
        circle.ImageTransparency = 0.8
        
        local newX = Mouse.X - circle.AbsolutePosition.X
        local newY = Mouse.Y - circle.AbsolutePosition.Y
        circle.Position = UDim2.new(0, newX, 0, newY)
        
        local size = 0
        if object.AbsoluteSize.X > object.AbsoluteSize.Y then
            size = object.AbsoluteSize.X * 1.5
        else
            size = object.AbsoluteSize.Y * 1.5
        end
        
        circle:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), "Out", "Quad", 0.5, false)
        
        for i = 1, 10 do
            circle.ImageTransparency = circle.ImageTransparency + 0.05
            task.wait(0.5/10)
        end
        circle:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, object)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Utility:Validate(defaults, options)
    for i, v in pairs(defaults) do
        if options[i] == nil then
            options[i] = v
        end
    end
    return options
end

function Archived:Window(options)
    options = Utility:Validate({
        Name = "Archived UI"
    }, options or {})

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Archived"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Settings.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Settings.Theme.Outline
    MainStroke.Thickness = 1

    local TopBar = Instance.new("Frame")
    TopBar.Name = "Header"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Settings.Theme.Header
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    TopBarCorner.Parent = TopBar
    
    local TopBarFiller = Instance.new("Frame")
    TopBarFiller.Name = "Filler"
    TopBarFiller.Parent = TopBar
    TopBarFiller.BackgroundColor3 = Settings.Theme.Header
    TopBarFiller.BorderSizePixel = 0
    TopBarFiller.Position = UDim2.new(0, 0, 1, -10)
    TopBarFiller.Size = UDim2.new(1, 0, 0, 10)

    Utility:MakeDraggable(TopBar, MainFrame)

    local SearchRegion = Instance.new("Frame")
    SearchRegion.Name = "SearchRegion"
    SearchRegion.Parent = TopBar
    SearchRegion.BackgroundTransparency = 1
    SearchRegion.Position = UDim2.new(0, 12, 0, 0)
    SearchRegion.Size = UDim2.new(0, 200, 1, 0)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Parent = SearchRegion
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 0, 0.5, -8)
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Settings.Theme.Accent

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchInput"
    SearchBox.Parent = SearchRegion
    SearchBox.BackgroundTransparency = 1
    SearchBox.Position = UDim2.new(0, 24, 0, 0)
    SearchBox.Size = UDim2.new(1, -24, 1, 0)
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    SearchBox.PlaceholderText = options.Name
    SearchBox.Text = ""
    SearchBox.TextColor3 = Settings.Theme.Text
    SearchBox.TextSize = 13
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    local ControlRegion = Instance.new("Frame")
    ControlRegion.Name = "Controls"
    ControlRegion.Parent = TopBar
    ControlRegion.BackgroundTransparency = 1
    ControlRegion.Position = UDim2.new(1, -80, 0, 0)
    ControlRegion.Size = UDim2.new(0, 80, 1, 0)

    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Name = "Exit"
    ExitBtn.Parent = ControlRegion
    ExitBtn.BackgroundTransparency = 1
    ExitBtn.Position = UDim2.new(0.5, 0, 0, 0)
    ExitBtn.Size = UDim2.new(0.5, 0, 1, 0)
    ExitBtn.Font = Enum.Font.GothamMedium
    ExitBtn.Text = "X"
    ExitBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    ExitBtn.TextSize = 14
    ExitBtn.MouseEnter:Connect(function()
        Utility:Tween(ExitBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)})
    end)
    ExitBtn.MouseLeave:Connect(function()
        Utility:Tween(ExitBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)})
    end)
    ExitBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.Parent = ControlRegion
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(0, 0, 0, 0)
    MinBtn.Size = UDim2.new(0.5, 0, 1, 0)
    MinBtn.Font = Enum.Font.GothamMedium
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    MinBtn.TextSize = 14
    
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Utility:Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 40)})
        else
            Utility:Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 400)})
        end
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabSelection"
    TabContainer.Parent = TopBar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 220, 0, 0)
    TabContainer.Size = UDim2.new(1, -300, 1, 0)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 15, 0, 50)
    PageContainer.Size = UDim2.new(1, -30, 1, -60)
    PageContainer.ClipsDescendants = true

    local NotificationArea = Instance.new("Frame")
    NotificationArea.Name = "Notifications"
    NotificationArea.Parent = ScreenGui
    NotificationArea.BackgroundTransparency = 1
    NotificationArea.Position = UDim2.new(1, -320, 1, -320)
    NotificationArea.Size = UDim2.new(0, 300, 0, 300)
    
    local NotifyList = Instance.new("UIListLayout")
    NotifyList.Parent = NotificationArea
    NotifyList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyList.Padding = UDim.new(0, 5)

    function Archived:Notify(config)
        config = Utility:Validate({
            Title = "Notification",
            Content = "Content",
            Duration = 5
        }, config or {})

        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Parent = NotificationArea
        Toast.BackgroundColor3 = Settings.Theme.Header
        Toast.BackgroundTransparency = 0.1
        Toast.Size = UDim2.new(1, 0, 0, 0)
        Toast.AutomaticSize = Enum.AutomaticSize.Y
        Toast.BorderSizePixel = 0

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 6)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Parent = Toast
        ToastStroke.Color = Settings.Theme.Accent
        ToastStroke.Thickness = 1
        
        local ToastTitle = Instance.new("TextLabel")
        ToastTitle.Parent = Toast
        ToastTitle.BackgroundTransparency = 1
        ToastTitle.Position = UDim2.new(0, 10, 0, 5)
        ToastTitle.Size = UDim2.new(1, -20, 0, 20)
        ToastTitle.Font = Enum.Font.GothamBold
        ToastTitle.Text = config.Title
        ToastTitle.TextColor3 = Settings.Theme.Accent
        ToastTitle.TextSize = 14
        ToastTitle.TextXAlignment = Enum.TextXAlignment.Left

        local ToastContent = Instance.new("TextLabel")
        ToastContent.Parent = Toast
        ToastContent.BackgroundTransparency = 1
        ToastContent.Position = UDim2.new(0, 10, 0, 25)
        ToastContent.Size = UDim2.new(1, -20, 0, 0)
        ToastContent.AutomaticSize = Enum.AutomaticSize.Y
        ToastContent.Font = Enum.Font.Gotham
        ToastContent.Text = config.Content
        ToastContent.TextColor3 = Settings.Theme.Text
        ToastContent.TextSize = 13
        ToastContent.TextWrapped = true
        ToastContent.TextXAlignment = Enum.TextXAlignment.Left

        local Padding = Instance.new("UIPadding")
        Padding.Parent = Toast
        Padding.PaddingBottom = UDim.new(0, 10)

        Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1})
        
        task.delay(config.Duration, function()
            Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
            Utility:Tween(ToastTitle, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(ToastContent, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 1})
            task.wait(0.5)
            Toast:Destroy()
        end)
    end

    local WindowHandler = {}
    local FirstTab = true

    function WindowHandler:Tab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(0, 0, 1, 0)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = name
        TabButton.TextColor3 = Settings.Theme.DarkText
        TabButton.TextSize = 13
        TabButton.AutomaticSize = Enum.AutomaticSize.X

        local Indicator = Instance.new("Frame")
        Indicator.Name = "ActiveIndicator"
        Indicator.Parent = TabButton
        Indicator.BackgroundColor3 = Settings.Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 1, -2)
        Indicator.Size = UDim2.new(0, 0, 0, 2)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "Page"
        TabPage.Parent = PageContainer
        TabPage.Active = true
        TabPage.BackgroundColor3 = Settings.Theme.Background
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = Settings.Theme.Accent
        TabPage.Visible = false

        local PageList = Instance.new("UIListLayout")
        PageList.Parent = TabPage
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 6)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = TabPage
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 5)
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        local function ShowTab()
            for _, v in pairs(PageContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, TweenInfo.new(0.3), {TextColor3 = Settings.Theme.DarkText})
                    Utility:Tween(v.ActiveIndicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2)})
                end
            end

            TabPage.Visible = true
            Utility:Tween(TabButton, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 2)})
        end

        TabButton.MouseButton1Click:Connect(ShowTab)

        if FirstTab then
            FirstTab = false
            ShowTab()
        end

        local ElementHandler = {}

        function ElementHandler:Section(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.Parent = TabPage
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)

            local Label = Instance.new("TextLabel")
            Label.Parent = SectionFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 2, 0, 0)
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Font = Enum.Font.GothamBold
            Label.Text = text
            Label.TextColor3 = Settings.Theme.Accent
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function ElementHandler:Button(options)
            options = Utility:Validate({
                Name = "Button",
                Callback = function() end
            }, options or {})

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "ButtonElement"
            ButtonFrame.Parent = TabPage
            ButtonFrame.BackgroundColor3 = Settings.Theme.Container
            ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = ButtonFrame
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Parent = ButtonFrame
            BtnStroke.Color = Settings.Theme.Outline
            BtnStroke.Thickness = 1

            local BtnText = Instance.new("TextLabel")
            BtnText.Parent = ButtonFrame
            BtnText.BackgroundTransparency = 1
            BtnText.Size = UDim2.new(1, 0, 1, 0)
            BtnText.Font = Enum.Font.Gotham
            BtnText.Text = options.Name
            BtnText.TextColor3 = Settings.Theme.Text
            BtnText.TextSize = 13
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = ButtonFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""

            Interact.MouseButton1Click:Connect(function()
                Utility:Ripple(Interact)
                options.Callback()
            end)

            Interact.MouseEnter:Connect(function()
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Container})
            end)
        end

        function ElementHandler:Toggle(options)
            options = Utility:Validate({
                Name = "Toggle",
                Default = false,
                Callback = function() end
            }, options or {})

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleElement"
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = Settings.Theme.Container
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            
            local TglCorner = Instance.new("UICorner")
            TglCorner.CornerRadius = UDim.new(0, 4)
            TglCorner.Parent = ToggleFrame

            local TglStroke = Instance.new("UIStroke")
            TglStroke.Parent = ToggleFrame
            TglStroke.Color = Settings.Theme.Outline
            TglStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchArea = Instance.new("Frame")
            SwitchArea.Parent = ToggleFrame
            SwitchArea.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SwitchArea.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchArea.Size = UDim2.new(0, 40, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchArea
            
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Parent = SwitchArea
            SwitchCircle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            SwitchCircle.Position = UDim2.new(0, 2, 0.5, -8)
            SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = SwitchCircle

            local Interact = Instance.new("TextButton")
            Interact.Parent = ToggleFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""

            local Toggled = options.Default

            local function UpdateToggle()
                if Toggled then
                    Utility:Tween(SwitchArea, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Accent})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)})
                else
                    Utility:Tween(SwitchArea, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)})
                end
                options.Callback(Toggled)
            end
            
            UpdateToggle()

            Interact.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Utility:Ripple(Interact)
                UpdateToggle()
            end)
        end

        function ElementHandler:Slider(options)
            options = Utility:Validate({
                Name = "Slider",
                Min = 0,
                Max = 100,
                Default = 50,
                Decimals = 0,
                Callback = function() end
            }, options or {})

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "SliderElement"
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = Settings.Theme.Container
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            
            local SldCorner = Instance.new("UICorner")
            SldCorner.CornerRadius = UDim.new(0, 4)
            SldCorner.Parent = SliderFrame
            
            local SldStroke = Instance.new("UIStroke")
            SldStroke.Parent = SliderFrame
            SldStroke.Color = Settings.Theme.Outline
            SldStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(options.Default)
            ValueLabel.TextColor3 = Settings.Theme.DarkText
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Track = Instance.new("Frame")
            Track.Parent = SliderFrame
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Track.Position = UDim2.new(0, 10, 0, 32)
            Track.Size = UDim2.new(1, -20, 0, 6)
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.BackgroundColor3 = Settings.Theme.Accent
            Fill.Size = UDim2.new(0, 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local Interact = Instance.new("TextButton")
            Interact.Parent = SliderFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""

            local Dragging = false
            local Min = options.Min
            local Max = options.Max
            local Default = math.clamp(options.Default, Min, Max)
            local Decimals = options.Decimals or 0

            local function Update(input)
                local SizeScale = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local RawValue = Min + ((Max - Min) * SizeScale)
                local Value = math.floor(RawValue * (10 ^ Decimals)) / (10 ^ Decimals)
                
                Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeScale, 0, 1, 0)})
                ValueLabel.Text = tostring(Value)
                options.Callback(Value)
            end

            local function SetInitial(val)
                local ratio = (val - Min) / (Max - Min)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                ValueLabel.Text = tostring(val)
            end
            
            SetInitial(Default)

            Interact.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(input)
                end
            end)

            Interact.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end

        function ElementHandler:Dropdown(options)
            options = Utility:Validate({
                Name = "Dropdown",
                Items = {},
                Multi = false,
                Callback = function() end
            }, options or {})

            local Dropped = false
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "DropdownElement"
            DropdownFrame.Parent = TabPage
            DropdownFrame.BackgroundColor3 = Settings.Theme.Container
            DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            DropdownFrame.ClipsDescendants = true

            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropdownFrame

            local DropStroke = Instance.new("UIStroke")
            DropStroke.Parent = DropdownFrame
            DropStroke.Color = Settings.Theme.Outline
            DropStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = DropdownFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -40, 0, 36)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Arrow = Instance.new("ImageLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 8)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Image = "rbxassetid://6031090990"
            Arrow.ImageColor3 = Settings.Theme.DarkText
            Arrow.Rotation = 90

            local Interact = Instance.new("TextButton")
            Interact.Parent = DropdownFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 0, 36)
            Interact.Text = ""

            local ItemList = Instance.new("UIListLayout")
            ItemList.Parent = DropdownFrame
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0, 4)
            
            local ItemPadding = Instance.new("UIPadding")
            ItemPadding.Parent = DropdownFrame
            ItemPadding.PaddingTop = UDim.new(0, 40)
            ItemPadding.PaddingBottom = UDim.new(0, 5)
            ItemPadding.PaddingLeft = UDim.new(0, 5)
            ItemPadding.PaddingRight = UDim.new(0, 5)

            local function Refresh()
                local count = #options.Items
                if Dropped then
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 40 + (count * 28) + 10)})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                else
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 36)})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 90})
                end
            end

            for _, item in ipairs(options.Items) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Name = item
                ItemBtn.Parent = DropdownFrame
                ItemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.Text = item
                ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                ItemBtn.TextSize = 13
                
                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 4)
                ItemCorner.Parent = ItemBtn

                ItemBtn.MouseButton1Click:Connect(function()
                    if not options.Multi then
                        Dropped = false
                        Refresh()
                        Label.Text = options.Name .. ": " .. item
                    end
                    options.Callback(item)
                end)
            end

            Interact.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                Refresh()
            end)
        end

        function ElementHandler:Textbox(options)
            options = Utility:Validate({
                Name = "Textbox",
                Placeholder = "Input...",
                Callback = function() end
            }, options or {})

            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "TextboxElement"
            BoxFrame.Parent = TabPage
            BoxFrame.BackgroundColor3 = Settings.Theme.Container
            BoxFrame.Size = UDim2.new(1, 0, 0, 36)

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = BoxFrame

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Parent = BoxFrame
            BoxStroke.Color = Settings.Theme.Outline
            BoxStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = BoxFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local InputBox = Instance.new("TextBox")
            InputBox.Parent = BoxFrame
            InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            InputBox.Position = UDim2.new(0.45, 0, 0.2, 0)
            InputBox.Size = UDim2.new(0.53, 0, 0.6, 0)
            InputBox.Font = Enum.Font.Gotham
            InputBox.PlaceholderText = options.Placeholder
            InputBox.Text = ""
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.TextSize = 13
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = InputBox

            InputBox.FocusLost:Connect(function()
                options.Callback(InputBox.Text)
            end)
        end

        function ElementHandler:Keybind(options)
            options = Utility:Validate({
                Name = "Keybind",
                Default = Enum.KeyCode.None,
                Callback = function() end
            }, options or {})

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = "KeybindElement"
            KeybindFrame.Parent = TabPage
            KeybindFrame.BackgroundColor3 = Settings.Theme.Container
            KeybindFrame.Size = UDim2.new(1, 0, 0, 36)

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeybindFrame

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Parent = KeybindFrame
            KeyStroke.Color = Settings.Theme.Outline
            KeyStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = KeybindFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local BindBtn = Instance.new("TextButton")
            BindBtn.Parent = KeybindFrame
            BindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            BindBtn.Position = UDim2.new(1, -90, 0.2, 0)
            BindBtn.Size = UDim2.new(0, 80, 0.6, 0)
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.Text = options.Default.Name
            BindBtn.TextColor3 = Settings.Theme.DarkText
            BindBtn.TextSize = 12

            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 4)
            BindCorner.Parent = BindBtn

            local Binding = false

            BindBtn.MouseButton1Click:Connect(function()
                Binding = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Settings.Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(input)
                if Binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Binding = false
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = Settings.Theme.DarkText
                        options.Callback(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Binding = false
                        BindBtn.Text = "None"
                        options.Callback(Enum.KeyCode.None)
                    end
                end
            end)
        end

        function ElementHandler:ColorPicker(options)
            options = Utility:Validate({
                Name = "ColorPicker",
                Default = Color3.fromRGB(255, 255, 255),
                Callback = function() end
            }, options or {})

            local CPFrame = Instance.new("Frame")
            CPFrame.Name = "ColorPickerElement"
            CPFrame.Parent = TabPage
            CPFrame.BackgroundColor3 = Settings.Theme.Container
            CPFrame.Size = UDim2.new(1, 0, 0, 36)
            CPFrame.ClipsDescendants = true

            local CPCorner = Instance.new("UICorner")
            CPCorner.CornerRadius = UDim.new(0, 4)
            CPCorner.Parent = CPFrame

            local CPStroke = Instance.new("UIStroke")
            CPStroke.Parent = CPFrame
            CPStroke.Color = Settings.Theme.Outline
            CPStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = CPFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -50, 0, 36)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ColorIndicator = Instance.new("TextButton")
            ColorIndicator.Parent = CPFrame
            ColorIndicator.BackgroundColor3 = options.Default
            ColorIndicator.Position = UDim2.new(1, -40, 0.5, -10)
            ColorIndicator.Size = UDim2.new(0, 30, 0, 20)
            ColorIndicator.Text = ""
            
            local IndCorner = Instance.new("UICorner")
            IndCorner.CornerRadius = UDim.new(0, 4)
            IndCorner.Parent = ColorIndicator

            local PickerContainer = Instance.new("Frame")
            PickerContainer.Parent = CPFrame
            PickerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            PickerContainer.Position = UDim2.new(0, 10, 0, 40)
            PickerContainer.Size = UDim2.new(1, -20, 0, 150)
            PickerContainer.Visible = false

            local SVMap = Instance.new("ImageLabel")
            SVMap.Parent = PickerContainer
            SVMap.Position = UDim2.new(0, 0, 0, 0)
            SVMap.Size = UDim2.new(0, 140, 0, 140)
            SVMap.Image = "rbxassetid://4155801252"

            local HueBar = Instance.new("ImageLabel")
            HueBar.Parent = PickerContainer
            HueBar.Position = UDim2.new(0, 150, 0, 0)
            HueBar.Size = UDim2.new(0, 20, 0, 140)
            HueBar.Image = "rbxassetid://4155801252" 

            local HueSlider = Instance.new("Frame")
            HueSlider.Parent = HueBar
            HueSlider.BackgroundColor3 = Color3.new(1,1,1)
            HueSlider.BorderSizePixel = 0
            HueSlider.Size = UDim2.new(1, 0, 0, 2)
            
            local SVSlider = Instance.new("Frame")
            SVSlider.Parent = SVMap
            SVSlider.BackgroundColor3 = Color3.new(1,1,1)
            SVSlider.BorderSizePixel = 0
            SVSlider.Size = UDim2.new(0, 4, 0, 4)
            
            local Open = false
            ColorIndicator.MouseButton1Click:Connect(function()
                Open = not Open
                if Open then
                    Utility:Tween(CPFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 200)})
                    PickerContainer.Visible = true
                else
                    Utility:Tween(CPFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 36)})
                    PickerContainer.Visible = false
                end
            end)
        end

        return ElementHandler
    end

    return WindowHandler
end

return Archived
