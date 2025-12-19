--[[
    ARCHIVED UI LIBRARY
    Version: 2.0 (Premium)
    Inspiration: Krnl, Venyx, Fluent
    Credits: Venyx (Animations), Krnl (Layout)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Archived = {}
Archived.__index = Archived

local Settings = {
    Name = "Archived",
    Theme = {
        Accent = Color3.fromRGB(155, 89, 182),
        Glow = Color3.fromRGB(170, 100, 200),
        Background = Color3.fromRGB(18, 18, 18),
        Header = Color3.fromRGB(22, 22, 22),
        Container = Color3.fromRGB(28, 28, 28),
        Element = Color3.fromRGB(32, 32, 32),
        Text = Color3.fromRGB(245, 245, 245),
        SubText = Color3.fromRGB(160, 160, 160),
        Outline = Color3.fromRGB(45, 45, 45)
    },
    Input = {
        Toggle = Enum.KeyCode.RightControl
    }
}

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

function Utility:Ripple(object)
    spawn(function()
        local Circle = Instance.new("ImageLabel")
        Circle.Name = "Ripple"
        Circle.Parent = object
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1.000
        Circle.ZIndex = 10
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Circle.ImageTransparency = 0.8
        
        local NewX = Mouse.X - Circle.AbsolutePosition.X
        local NewY = Mouse.Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        
        local Size = 0
        if object.AbsoluteSize.X > object.AbsoluteSize.Y then
             Size = object.AbsoluteSize.X * 1.5
        else
             Size = object.AbsoluteSize.Y * 1.5
        end
        
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", 0.5, false)
        
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.05
            task.wait(0.5/10)
        end
        Circle:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        Utility:Tween(object, TweenInfo.new(0.15), {Position = Position})
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Utility:GetTextSize(text, font, size, width)
    return TextService:GetTextSize(text, size, font, Vector2.new(width, 10000))
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
        Name = "Archived"
    }, options or {})

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ArchivedLibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Settings.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -215)
    MainFrame.Size = UDim2.new(0, 650, 0, 430)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Settings.Theme.Outline
    MainStroke.Thickness = 1
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Settings.Theme.Header
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    
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

    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Parent = TopBar
    SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchContainer.BackgroundTransparency = 1.000
    SearchContainer.Position = UDim2.new(0, 10, 0, 8)
    SearchContainer.Size = UDim2.new(0, 200, 0, 30)

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "Logo"
    LogoIcon.Parent = SearchContainer
    LogoIcon.BackgroundTransparency = 1.000
    LogoIcon.Position = UDim2.new(0, 0, 0.5, -9)
    LogoIcon.Size = UDim2.new(0, 18, 0, 18)
    LogoIcon.Image = "rbxassetid://6031154871"
    LogoIcon.ImageColor3 = Settings.Theme.Accent

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = SearchContainer
    TitleLabel.BackgroundTransparency = 1.000
    TitleLabel.Position = UDim2.new(0, 26, 0, 0)
    TitleLabel.Size = UDim2.new(1, -26, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = options.Name
    TitleLabel.TextColor3 = Settings.Theme.Text
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ControlContainer = Instance.new("Frame")
    ControlContainer.Name = "ControlContainer"
    ControlContainer.Parent = TopBar
    ControlContainer.BackgroundTransparency = 1.000
    ControlContainer.Position = UDim2.new(1, -70, 0, 0)
    ControlContainer.Size = UDim2.new(0, 70, 1, 0)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Parent = ControlContainer
    CloseButton.BackgroundTransparency = 1.000
    CloseButton.Position = UDim2.new(0.5, 0, 0, 0)
    CloseButton.Size = UDim2.new(0.5, 0, 1, 0)
    CloseButton.Font = Enum.Font.GothamMedium
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Settings.Theme.SubText
    CloseButton.TextSize = 14

    CloseButton.MouseEnter:Connect(function()
        Utility:Tween(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 60, 60)})
    end)

    CloseButton.MouseLeave:Connect(function()
        Utility:Tween(CloseButton, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.SubText})
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Parent = ControlContainer
    MinimizeButton.BackgroundTransparency = 1.000
    MinimizeButton.Size = UDim2.new(0.5, 0, 1, 0)
    MinimizeButton.Font = Enum.Font.GothamMedium
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Settings.Theme.SubText
    MinimizeButton.TextSize = 18

    MinimizeButton.MouseEnter:Connect(function()
        Utility:Tween(MinimizeButton, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.Text})
    end)

    MinimizeButton.MouseLeave:Connect(function()
        Utility:Tween(MinimizeButton, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.SubText})
    end)

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1.000
    PageContainer.Position = UDim2.new(0, 12, 0, 55)
    PageContainer.Size = UDim2.new(1, -24, 1, -67)
    PageContainer.ClipsDescendants = true

    local IsMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            PageContainer.Visible = false
            Utility:Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 45)})
            Utility:Tween(TopBarFiller, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        else
            Utility:Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 430)})
            Utility:Tween(TopBarFiller, TweenInfo.new(0.4), {BackgroundTransparency = 0})
            task.delay(0.3, function()
                if not IsMinimized then PageContainer.Visible = true end
            end)
        end
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = TopBar
    TabContainer.BackgroundTransparency = 1.000
    TabContainer.Position = UDim2.new(0, 200, 0, 0)
    TabContainer.Size = UDim2.new(1, -270, 1, 0)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)

    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "Notifications"
    NotificationContainer.Parent = ScreenGui
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Position = UDim2.new(1, -330, 1, -350)
    NotificationContainer.Size = UDim2.new(0, 300, 0, 300)
    
    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.Parent = NotificationContainer
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 8)

    function Archived:Notify(config)
        config = Utility:Validate({
            Title = "System",
            Content = "Notification",
            Duration = 5
        }, config or {})

        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Parent = NotificationContainer
        Toast.BackgroundColor3 = Settings.Theme.Header
        Toast.BackgroundTransparency = 0.1
        Toast.Size = UDim2.new(1, 0, 0, 0)
        Toast.AutomaticSize = Enum.AutomaticSize.Y
        Toast.BorderSizePixel = 0
        Toast.ClipsDescendants = true

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 6)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Parent = Toast
        ToastStroke.Color = Settings.Theme.Accent
        ToastStroke.Thickness = 1
        ToastStroke.Transparency = 1
        
        local ToastTitle = Instance.new("TextLabel")
        ToastTitle.Name = "Title"
        ToastTitle.Parent = Toast
        ToastTitle.BackgroundTransparency = 1
        ToastTitle.Position = UDim2.new(0, 12, 0, 8)
        ToastTitle.Size = UDim2.new(1, -24, 0, 20)
        ToastTitle.Font = Enum.Font.GothamBold
        ToastTitle.Text = config.Title
        ToastTitle.TextColor3 = Settings.Theme.Accent
        ToastTitle.TextSize = 14
        ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToastTitle.TextTransparency = 1

        local ToastContent = Instance.new("TextLabel")
        ToastContent.Name = "Content"
        ToastContent.Parent = Toast
        ToastContent.BackgroundTransparency = 1
        ToastContent.Position = UDim2.new(0, 12, 0, 28)
        ToastContent.Size = UDim2.new(1, -24, 0, 0)
        ToastContent.AutomaticSize = Enum.AutomaticSize.Y
        ToastContent.Font = Enum.Font.Gotham
        ToastContent.Text = config.Content
        ToastContent.TextColor3 = Settings.Theme.Text
        ToastContent.TextSize = 13
        ToastContent.TextWrapped = true
        ToastContent.TextXAlignment = Enum.TextXAlignment.Left
        ToastContent.TextTransparency = 1
        
        local Padding = Instance.new("UIPadding")
        Padding.Parent = Toast
        Padding.PaddingBottom = UDim.new(0, 12)

        Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 0})
        Utility:Tween(ToastTitle, TweenInfo.new(0.5), {TextTransparency = 0})
        Utility:Tween(ToastContent, TweenInfo.new(0.5), {TextTransparency = 0})
        
        task.delay(config.Duration, function()
            Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 1})
            Utility:Tween(ToastTitle, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(ToastContent, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(Toast, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            task.wait(0.5)
            Toast:Destroy()
        end)
    end

    local Handler = {}
    local FirstTab = true

    function Handler:Tab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name.."Btn"
        TabButton.Parent = TabContainer
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(0, 0, 1, 0)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = name
        TabButton.TextColor3 = Settings.Theme.SubText
        TabButton.TextSize = 13
        TabButton.AutomaticSize = Enum.AutomaticSize.X

        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Parent = TabButton
        Indicator.BackgroundColor3 = Settings.Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 1, -2)
        Indicator.Size = UDim2.new(0, 0, 0, 2)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name.."Page"
        TabPage.Parent = PageContainer
        TabPage.Active = true
        TabPage.BackgroundColor3 = Settings.Theme.Background
        TabPage.BackgroundTransparency = 1.000
        TabPage.BorderSizePixel = 0
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = Settings.Theme.Accent
        TabPage.Visible = false

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = TabPage
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)

        local PagePad = Instance.new("UIPadding")
        PagePad.Parent = TabPage
        PagePad.PaddingTop = UDim.new(0, 5)
        PagePad.PaddingLeft = UDim.new(0, 2)
        PagePad.PaddingRight = UDim.new(0, 2)
        PagePad.PaddingBottom = UDim.new(0, 5)

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        local function ShowTab()
            for _, v in pairs(PageContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, TweenInfo.new(0.3), {TextColor3 = Settings.Theme.SubText})
                    Utility:Tween(v.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2)})
                end
            end
            
            TabPage.Visible = true
            Utility:Tween(TabButton, TweenInfo.new(0.3), {TextColor3 = Settings.Theme.Text})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 2)})
        end

        TabButton.MouseButton1Click:Connect(ShowTab)

        if FirstTab then
            FirstTab = false
            ShowTab()
        end

        local Element = {}

        function Element:Section(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.Parent = TabPage
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 24)

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = SectionFrame
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Position = UDim2.new(0, 2, 0, 0)
            SectionLabel.Size = UDim2.new(1, 0, 1, 0)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = text
            SectionLabel.TextColor3 = Settings.Theme.Accent
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Element:Button(options)
            options = Utility:Validate({
                Name = "Button",
                Callback = function() end
            }, options or {})

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "Button"
            ButtonFrame.Parent = TabPage
            ButtonFrame.BackgroundColor3 = Settings.Theme.Element
            ButtonFrame.Size = UDim2.new(1, 0, 0, 34)

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonFrame

            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Parent = ButtonFrame
            ButtonStroke.Color = Settings.Theme.Outline
            ButtonStroke.Thickness = 1
            ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Parent = ButtonFrame
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
            ButtonLabel.Font = Enum.Font.Gotham
            ButtonLabel.Text = options.Name
            ButtonLabel.TextColor3 = Settings.Theme.Text
            ButtonLabel.TextSize = 13

            local Interact = Instance.new("TextButton")
            Interact.Parent = ButtonFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(ButtonStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            end)
            
            Interact.MouseLeave:Connect(function()
                Utility:Tween(ButtonStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Element})
            end)
            
            Interact.MouseButton1Click:Connect(function()
                Utility:Ripple(Interact)
                options.Callback()
            end)
        end

        function Element:Toggle(options)
            options = Utility:Validate({
                Name = "Toggle",
                Default = false,
                Callback = function() end
            }, options or {})

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = Settings.Theme.Element
            ToggleFrame.Size = UDim2.new(1, 0, 0, 34)

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame

            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Parent = ToggleFrame
            ToggleStroke.Color = Settings.Theme.Outline
            ToggleStroke.Thickness = 1

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = options.Name
            ToggleLabel.TextColor3 = Settings.Theme.Text
            ToggleLabel.TextSize = 13
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchBg = Instance.new("Frame")
            SwitchBg.Name = "Switch"
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SwitchBg.Position = UDim2.new(1, -44, 0.5, -10)
            SwitchBg.Size = UDim2.new(0, 34, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg
            
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Parent = SwitchBg
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

            local function Update()
                if Toggled then
                    Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Accent})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)})
                else
                    Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)})
                end
                options.Callback(Toggled)
            end
            Update()

            Interact.MouseEnter:Connect(function()
                Utility:Tween(ToggleStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(ToggleStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
            end)

            Interact.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Utility:Ripple(Interact)
                Update()
            end)
        end

        function Element:Slider(options)
            options = Utility:Validate({
                Name = "Slider",
                Min = 0,
                Max = 100,
                Default = 50,
                Decimals = 0,
                Callback = function() end
            }, options or {})

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "Slider"
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = Settings.Theme.Element
            SliderFrame.Size = UDim2.new(1, 0, 0, 45)

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Parent = SliderFrame
            SliderStroke.Color = Settings.Theme.Outline
            SliderStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(1, -20, 0, 15)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 15)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(options.Default)
            ValueLabel.TextColor3 = Settings.Theme.SubText
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Track = Instance.new("Frame")
            Track.Parent = SliderFrame
            Track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Track.Position = UDim2.new(0, 10, 0, 28)
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
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(SliderStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(SliderStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
            end)

            local Dragging = false
            local Min = options.Min
            local Max = options.Max
            local Default = math.clamp(options.Default, Min, Max)
            local Decimals = options.Decimals

            local function Update(input)
                local SizeScale = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local RawValue = Min + ((Max - Min) * SizeScale)
                local Value = math.floor(RawValue * (10 ^ Decimals)) / (10 ^ Decimals)
                
                Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeScale, 0, 1, 0)})
                ValueLabel.Text = tostring(Value)
                options.Callback(Value)
            end
            
            -- Initial Set
            local Ratio = (Default - Min) / (Max - Min)
            Fill.Size = UDim2.new(Ratio, 0, 1, 0)
            ValueLabel.Text = tostring(Default)

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

        function Element:Dropdown(options)
            options = Utility:Validate({
                Name = "Dropdown",
                Items = {},
                Multi = false,
                Callback = function() end
            }, options or {})

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Parent = TabPage
            DropdownFrame.BackgroundColor3 = Settings.Theme.Element
            DropdownFrame.Size = UDim2.new(1, 0, 0, 34)
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
            Label.Size = UDim2.new(1, -40, 0, 34)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Arrow = Instance.new("ImageLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 7)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Image = "rbxassetid://6031090990"
            Arrow.ImageColor3 = Settings.Theme.SubText
            Arrow.Rotation = 90

            local Interact = Instance.new("TextButton")
            Interact.Parent = DropdownFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 0, 34)
            Interact.Text = ""

            local ItemList = Instance.new("UIListLayout")
            ItemList.Parent = DropdownFrame
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0, 5)

            local ItemPad = Instance.new("UIPadding")
            ItemPad.Parent = DropdownFrame
            ItemPad.PaddingTop = UDim.new(0, 38)
            ItemPad.PaddingBottom = UDim.new(0, 5)
            ItemPad.PaddingLeft = UDim.new(0, 5)
            ItemPad.PaddingRight = UDim.new(0, 5)

            local Dropped = false

            local function Refresh()
                if Dropped then
                    local Count = #options.Items
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 45 + (Count * 25))})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                else
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 34)})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 90})
                end
            end

            for _, item in ipairs(options.Items) do
                local ItemButton = Instance.new("TextButton")
                ItemButton.Parent = DropdownFrame
                ItemButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                ItemButton.Size = UDim2.new(1, 0, 0, 22)
                ItemButton.Font = Enum.Font.Gotham
                ItemButton.Text = item
                ItemButton.TextColor3 = Settings.Theme.SubText
                ItemButton.TextSize = 12
                
                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 4)
                ItemCorner.Parent = ItemButton
                
                ItemButton.MouseEnter:Connect(function()
                    Utility:Tween(ItemButton, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.Text})
                    Utility:Tween(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                end)
                
                ItemButton.MouseLeave:Connect(function()
                    Utility:Tween(ItemButton, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.SubText})
                    Utility:Tween(ItemButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                end)

                ItemButton.MouseButton1Click:Connect(function()
                    if not options.Multi then
                        Dropped = false
                        Refresh()
                        Label.Text = options.Name .. " : " .. item
                    end
                    options.Callback(item)
                end)
            end
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(DropStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(DropStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
            end)

            Interact.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                Refresh()
            end)
        end

        function Element:Textbox(options)
            options = Utility:Validate({
                Name = "Textbox",
                Placeholder = "Type here...",
                Callback = function() end
            }, options or {})

            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "Textbox"
            BoxFrame.Parent = TabPage
            BoxFrame.BackgroundColor3 = Settings.Theme.Element
            BoxFrame.Size = UDim2.new(1, 0, 0, 34)

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
            Label.Size = UDim2.new(1, -150, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local InputBox = Instance.new("TextBox")
            InputBox.Parent = BoxFrame
            InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            InputBox.Position = UDim2.new(1, -140, 0.5, -12)
            InputBox.Size = UDim2.new(0, 130, 0, 24)
            InputBox.Font = Enum.Font.Gotham
            InputBox.PlaceholderText = options.Placeholder
            InputBox.Text = ""
            InputBox.TextColor3 = Settings.Theme.Text
            InputBox.TextSize = 12
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = InputBox

            InputBox.Focused:Connect(function()
                Utility:Tween(BoxStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(InputBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
            end)

            InputBox.FocusLost:Connect(function()
                Utility:Tween(BoxStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(InputBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                options.Callback(InputBox.Text)
            end)
        end

        function Element:Keybind(options)
            options = Utility:Validate({
                Name = "Keybind",
                Default = Enum.KeyCode.None,
                Callback = function() end
            }, options or {})

            local KeyFrame = Instance.new("Frame")
            KeyFrame.Name = "Keybind"
            KeyFrame.Parent = TabPage
            KeyFrame.BackgroundColor3 = Settings.Theme.Element
            KeyFrame.Size = UDim2.new(1, 0, 0, 34)

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeyFrame

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Parent = KeyFrame
            KeyStroke.Color = Settings.Theme.Outline
            KeyStroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = KeyFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local BindBtn = Instance.new("TextButton")
            BindBtn.Parent = KeyFrame
            BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -10)
            BindBtn.Size = UDim2.new(0, 80, 0, 20)
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.Text = options.Default.Name
            BindBtn.TextColor3 = Settings.Theme.SubText
            BindBtn.TextSize = 12

            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 4)
            BindCorner.Parent = BindBtn

            local Binding = false

            BindBtn.MouseButton1Click:Connect(function()
                Binding = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Settings.Theme.Accent
                Utility:Tween(KeyStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
            end)

            UserInputService.InputBegan:Connect(function(input)
                if Binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Binding = false
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = Settings.Theme.SubText
                        Utility:Tween(KeyStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                        options.Callback(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                         -- Cancel
                         Binding = false
                         BindBtn.Text = "None"
                         BindBtn.TextColor3 = Settings.Theme.SubText
                         Utility:Tween(KeyStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                         options.Callback(Enum.KeyCode.None)
                    end
                end
            end)
        end

        function Element:ColorPicker(options)
            options = Utility:Validate({
                Name = "ColorPicker",
                Default = Color3.fromRGB(255, 255, 255),
                Callback = function() end
            }, options or {})

            local CPFrame = Instance.new("Frame")
            CPFrame.Name = "ColorPicker"
            CPFrame.Parent = TabPage
            CPFrame.BackgroundColor3 = Settings.Theme.Element
            CPFrame.Size = UDim2.new(1, 0, 0, 34)
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
            Label.Size = UDim2.new(1, -60, 0, 34)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ColorPreview = Instance.new("TextButton")
            ColorPreview.Parent = CPFrame
            ColorPreview.BackgroundColor3 = options.Default
            ColorPreview.Position = UDim2.new(1, -50, 0.5, -10)
            ColorPreview.Size = UDim2.new(0, 40, 0, 20)
            ColorPreview.Text = ""
            
            local PreviewCorner = Instance.new("UICorner")
            PreviewCorner.CornerRadius = UDim.new(0, 4)
            PreviewCorner.Parent = ColorPreview

            local Interact = Instance.new("TextButton")
            Interact.Parent = CPFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 0, 34)
            Interact.Text = ""
            
            -- Picker UI
            local Container = Instance.new("Frame")
            Container.Parent = CPFrame
            Container.BackgroundColor3 = Color3.fromRGB(0,0,0)
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 10, 0, 40)
            Container.Size = UDim2.new(1, -20, 0, 150)
            Container.Visible = false

            local SVMap = Instance.new("ImageLabel")
            SVMap.Name = "SV"
            SVMap.Parent = Container
            SVMap.BorderSizePixel = 0
            SVMap.Position = UDim2.new(0, 0, 0, 0)
            SVMap.Size = UDim2.new(0, 140, 0, 140)
            SVMap.Image = "rbxassetid://4155801252" -- Saturation/Value Gradient
            
            local SVStroke = Instance.new("UIStroke")
            SVStroke.Parent = SVMap
            SVStroke.Color = Settings.Theme.Outline
            SVStroke.Thickness = 1
            
            local SVCursor = Instance.new("Frame")
            SVCursor.Parent = SVMap
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SVCursor.Size = UDim2.new(0, 4, 0, 4)
            SVCursor.Rotation = 45
            
            local HueBar = Instance.new("ImageLabel")
            HueBar.Name = "Hue"
            HueBar.Parent = Container
            HueBar.BorderSizePixel = 0
            HueBar.Position = UDim2.new(0, 150, 0, 0)
            HueBar.Size = UDim2.new(1, -150, 0, 140)
            HueBar.Image = "rbxassetid://4155801252" -- Reused texture, but we override color with gradient
            HueBar.ScaleType = Enum.ScaleType.Stretch
            
            local HueGradient = Instance.new("UIGradient")
            HueGradient.Parent = HueBar
            HueGradient.Rotation = 90
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
            })
            
            local HueStroke = Instance.new("UIStroke")
            HueStroke.Parent = HueBar
            HueStroke.Color = Settings.Theme.Outline
            HueStroke.Thickness = 1

            local HueCursor = Instance.new("Frame")
            HueCursor.Parent = HueBar
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            HueCursor.Size = UDim2.new(1, 0, 0, 2)
            
            local h, s, v = Color3.toHSV(options.Default)
            
            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = color
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                options.Callback(color)
            end
            
            local DraggingHue, DraggingSV = false, false
            
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = true
                end
            end)
            
            SVMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSV = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = false
                    DraggingSV = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if DraggingHue then
                        local Y = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                        HueCursor.Position = UDim2.new(0, 0, Y, 0)
                        h = 1 - Y
                        UpdateColor()
                    end
                    if DraggingSV then
                        local X = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                        local Y = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                        SVCursor.Position = UDim2.new(X, -2, Y, -2)
                        s = X
                        v = 1 - Y
                        UpdateColor()
                    end
                end
            end)
            
            local IsOpen = false
            Interact.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    Utility:Tween(CPFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 200)})
                    Container.Visible = true
                else
                    Utility:Tween(CPFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 34)})
                    Container.Visible = false
                end
            end)
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(CPStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(CPStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
            end)
            
            UpdateColor()
        end

        return Element
    end
    return Handler
end

return Archived
