local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
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
        Background = Color3.fromRGB(15, 15, 15),
        Header = Color3.fromRGB(20, 20, 20),
        Container = Color3.fromRGB(25, 25, 25),
        Element = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(245, 245, 245),
        SubText = Color3.fromRGB(160, 160, 160),
        Outline = Color3.fromRGB(40, 40, 40),
        Red = Color3.fromRGB(255, 95, 87),
        Yellow = Color3.fromRGB(255, 189, 46),
        Green = Color3.fromRGB(39, 201, 63)
    }
}

local Utility = {}

function Utility:Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:Ripple(object)
    task.spawn(function()
        local RippleCircle = Instance.new("ImageLabel")
        RippleCircle.Name = "RippleEffect"
        RippleCircle.Parent = object
        RippleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        RippleCircle.BackgroundTransparency = 1.000
        RippleCircle.ZIndex = 10
        RippleCircle.Image = "rbxassetid://266543268"
        RippleCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        RippleCircle.ImageTransparency = 0.8
        
        local NewX = Mouse.X - RippleCircle.AbsolutePosition.X
        local NewY = Mouse.Y - RippleCircle.AbsolutePosition.Y
        RippleCircle.Position = UDim2.new(0, NewX, 0, NewY)
        
        local Size = 0
        if object.AbsoluteSize.X > object.AbsoluteSize.Y then
             Size = object.AbsoluteSize.X * 1.5
        else
             Size = object.AbsoluteSize.Y * 1.5
        end
        
        local TweenInfoRipple = TweenInfo.new(
            0.5,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        Utility:Tween(RippleCircle, TweenInfoRipple, {
            Size = UDim2.new(0, Size, 0, Size),
            Position = UDim2.new(0.5, -Size/2, 0.5, -Size/2),
            ImageTransparency = 1
        })
        
        task.wait(0.5)
        RippleCircle:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local TargetPosition = UDim2.new(
            StartPosition.X.Scale, 
            StartPosition.X.Offset + Delta.X, 
            StartPosition.Y.Scale, 
            StartPosition.Y.Offset + Delta.Y
        )
        
        local DragTweenInfo = TweenInfo.new(
            0.1,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
        )
        
        Utility:Tween(object, DragTweenInfo, {Position = TargetPosition})
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

function Utility:Validate(defaults, options)
    for i, v in pairs(defaults) do
        if options[i] == nil then
            options[i] = v
        end
    end
    return options
end

function Utility:CreateStroke(parent, color, thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = parent
    Stroke.Color = color
    Stroke.Thickness = thickness
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return Stroke
end

function Utility:CreateCorner(parent, radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, radius)
    Corner.Parent = parent
    return Corner
end

function Archived:Window(options)
    options = Utility:Validate({
        Name = "Archived"
    }, options or {})

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ArchivedUI"
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
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.ClipsDescendants = true
    
    Utility:CreateCorner(MainFrame, 8)
    Utility:CreateStroke(MainFrame, Settings.Theme.Outline, 1)
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Settings.Theme.Header
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    
    Utility:CreateCorner(TopBar, 8)
    
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
    SearchRegion.Position = UDim2.new(0, 15, 0, 10)
    SearchRegion.Size = UDim2.new(0, 200, 0, 30)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Parent = SearchRegion
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 0, 0.5, -10)
    SearchIcon.Size = UDim2.new(0, 20, 0, 20)
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Settings.Theme.Accent

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = SearchRegion
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 30, 0, 0)
    TitleLabel.Size = UDim2.new(1, -30, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = options.Name
    TitleLabel.TextColor3 = Settings.Theme.Text
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ControlRegion = Instance.new("Frame")
    ControlRegion.Name = "ControlRegion"
    ControlRegion.Parent = TopBar
    ControlRegion.BackgroundTransparency = 1
    ControlRegion.Position = UDim2.new(1, -70, 0, 0)
    ControlRegion.Size = UDim2.new(0, 70, 1, 0)
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = ControlRegion
    CloseButton.BackgroundColor3 = Settings.Theme.Red
    CloseButton.Position = UDim2.new(0, 45, 0.5, -6)
    CloseButton.Size = UDim2.new(0, 12, 0, 12)
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    
    Utility:CreateCorner(CloseButton, 100)
    
    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Name = "Icon"
    CloseIcon.Parent = CloseButton
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0, 2, 0, 2)
    CloseIcon.Size = UDim2.new(0, 8, 0, 8)
    CloseIcon.Image = "rbxassetid://3926305904"
    CloseIcon.ImageRectOffset = Vector2.new(284, 4)
    CloseIcon.ImageRectSize = Vector2.new(24, 24)
    CloseIcon.ImageTransparency = 1
    CloseIcon.ImageColor3 = Color3.fromRGB(150, 0, 0)

    CloseButton.MouseEnter:Connect(function()
        Utility:Tween(CloseIcon, TweenInfo.new(0.2), {ImageTransparency = 0.5})
    end)
    CloseButton.MouseLeave:Connect(function()
        Utility:Tween(CloseIcon, TweenInfo.new(0.2), {ImageTransparency = 1})
    end)
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = ControlRegion
    MinimizeButton.BackgroundColor3 = Settings.Theme.Yellow
    MinimizeButton.Position = UDim2.new(0, 25, 0.5, -6)
    MinimizeButton.Size = UDim2.new(0, 12, 0, 12)
    MinimizeButton.Text = ""
    MinimizeButton.AutoButtonColor = false
    
    Utility:CreateCorner(MinimizeButton, 100)
    
    local Minimized = false
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Utility:Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 50)})
            Utility:Tween(TopBarFiller, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        else
            Utility:Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 450)})
            Utility:Tween(TopBarFiller, TweenInfo.new(0.5), {BackgroundTransparency = 0})
        end
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = TopBar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 220, 0, 0)
    TabContainer.Size = UDim2.new(1, -300, 1, 0)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 15)
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 15, 0, 60)
    ContentContainer.Size = UDim2.new(1, -30, 1, -75)
    ContentContainer.ClipsDescendants = true

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Position = UDim2.new(1, -320, 1, -50)
    NotificationHolder.Size = UDim2.new(0, 300, 1, 0)
    NotificationHolder.AnchorPoint = Vector2.new(0, 1)

    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.Parent = NotificationHolder
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 10)

    function Archived:Notify(config)
        config = Utility:Validate({
            Title = "Notification",
            Content = "Content goes here.",
            Duration = 5
        }, config or {})

        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Parent = NotificationHolder
        Toast.BackgroundColor3 = Settings.Theme.Header
        Toast.BackgroundTransparency = 1
        Toast.Size = UDim2.new(1, 0, 0, 0) 
        Toast.AutomaticSize = Enum.AutomaticSize.Y
        Toast.BorderSizePixel = 0
        
        Utility:CreateCorner(Toast, 6)
        local ToastStroke = Utility:CreateStroke(Toast, Settings.Theme.Outline, 1)
        ToastStroke.Transparency = 1
        
        local ToastTitle = Instance.new("TextLabel")
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
        
        Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
        Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 0})
        Utility:Tween(ToastTitle, TweenInfo.new(0.5), {TextTransparency = 0})
        Utility:Tween(ToastContent, TweenInfo.new(0.5), {TextTransparency = 0})

        task.delay(config.Duration, function()
            Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
            Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 1})
            Utility:Tween(ToastTitle, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(ToastContent, TweenInfo.new(0.5), {TextTransparency = 1})
            task.wait(0.6)
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
        TabButton.TextColor3 = Settings.Theme.SubText
        TabButton.TextSize = 14
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.Parent = TabButton
        TabIndicator.BackgroundColor3 = Settings.Theme.Accent
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Position = UDim2.new(0, 0, 1, -3)
        TabIndicator.Size = UDim2.new(0, 0, 0, 3)
        
        Utility:CreateCorner(TabIndicator, 2)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Parent = ContentContainer
        Page.Active = true
        Page.BackgroundColor3 = Settings.Theme.Background
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Settings.Theme.Accent
        Page.Visible = false
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 10)
        
        local PagePad = Instance.new("UIPadding")
        PagePad.Parent = Page
        PagePad.PaddingTop = UDim.new(0, 5)
        PagePad.PaddingBottom = UDim.new(0, 5)
        PagePad.PaddingLeft = UDim.new(0, 2)
        PagePad.PaddingRight = UDim.new(0, 2)
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)
        
        local function ActivateTab()
            for _, v in pairs(ContentContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, TweenInfo.new(0.3), {TextColor3 = Settings.Theme.SubText})
                    Utility:Tween(v.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 3)})
                end
            end
            
            Page.Visible = true
            Utility:Tween(TabButton, TweenInfo.new(0.3), {TextColor3 = Settings.Theme.Text})
            Utility:Tween(TabIndicator, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 3)})
        end
        
        TabButton.MouseButton1Click:Connect(ActivateTab)
        
        if FirstTab then
            FirstTab = false
            ActivateTab()
        end
        
        local ElementHandler = {}
        
        function ElementHandler:Section(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.Parent = Page
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
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function ElementHandler:Label(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "Label"
            LabelFrame.Parent = Page
            LabelFrame.BackgroundColor3 = Settings.Theme.Element
            LabelFrame.Size = UDim2.new(1, 0, 0, 30)
            
            Utility:CreateCorner(LabelFrame, 6)
            Utility:CreateStroke(LabelFrame, Settings.Theme.Outline, 1)
            
            local Text = Instance.new("TextLabel")
            Text.Parent = LabelFrame
            Text.BackgroundTransparency = 1
            Text.Position = UDim2.new(0, 10, 0, 0)
            Text.Size = UDim2.new(1, -20, 1, 0)
            Text.Font = Enum.Font.Gotham
            Text.Text = text
            Text.TextColor3 = Settings.Theme.Text
            Text.TextSize = 13
            Text.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function ElementHandler:Button(options)
            options = Utility:Validate({
                Name = "Button",
                Callback = function() end
            }, options or {})
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "Button"
            ButtonFrame.Parent = Page
            ButtonFrame.BackgroundColor3 = Settings.Theme.Element
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
            
            Utility:CreateCorner(ButtonFrame, 6)
            local ButtonStroke = Utility:CreateStroke(ButtonFrame, Settings.Theme.Outline, 1)
            
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
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
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
        
        function ElementHandler:Toggle(options)
            options = Utility:Validate({
                Name = "Toggle",
                Default = false,
                Callback = function() end
            }, options or {})
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Parent = Page
            ToggleFrame.BackgroundColor3 = Settings.Theme.Element
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            
            Utility:CreateCorner(ToggleFrame, 6)
            local ToggleStroke = Utility:CreateStroke(ToggleFrame, Settings.Theme.Outline, 1)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = options.Name
            ToggleLabel.TextColor3 = Settings.Theme.Text
            ToggleLabel.TextSize = 13
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SwitchBg.Position = UDim2.new(1, -52, 0.5, -11)
            SwitchBg.Size = UDim2.new(0, 40, 0, 22)
            
            Utility:CreateCorner(SwitchBg, 11)
            
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Parent = SwitchBg
            SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SwitchCircle.Position = UDim2.new(0, 2, 0.5, -9)
            SwitchCircle.Size = UDim2.new(0, 18, 0, 18)
            
            Utility:CreateCorner(SwitchCircle, 9)
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = ToggleFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""
            
            local Toggled = options.Default
            
            local function UpdateState()
                if Toggled then
                    Utility:Tween(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Settings.Theme.Accent})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -20, 0.5, -9)})
                else
                    Utility:Tween(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                    Utility:Tween(SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -9)})
                end
                options.Callback(Toggled)
            end
            
            UpdateState()
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(ToggleStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(ToggleStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Element})
            end)
            
            Interact.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Utility:Ripple(Interact)
                UpdateState()
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
            SliderFrame.Name = "Slider"
            SliderFrame.Parent = Page
            SliderFrame.BackgroundColor3 = Settings.Theme.Element
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            
            Utility:CreateCorner(SliderFrame, 6)
            local SliderStroke = Utility:CreateStroke(SliderFrame, Settings.Theme.Outline, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 5)
            Label.Size = UDim2.new(1, -24, 0, 15)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 12, 0, 5)
            ValueLabel.Size = UDim2.new(1, -24, 0, 15)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(options.Default)
            ValueLabel.TextColor3 = Settings.Theme.SubText
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local Track = Instance.new("Frame")
            Track.Parent = SliderFrame
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Track.Position = UDim2.new(0, 12, 0, 30)
            Track.Size = UDim2.new(1, -24, 0, 6)
            
            Utility:CreateCorner(Track, 3)
            
            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.BackgroundColor3 = Settings.Theme.Accent
            Fill.Size = UDim2.new(0.5, 0, 1, 0)
            
            Utility:CreateCorner(Fill, 3)
            
            local Knob = Instance.new("Frame")
            Knob.Parent = Fill
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Position = UDim2.new(1, -5, 0.5, -5)
            Knob.Size = UDim2.new(0, 10, 0, 10)
            
            Utility:CreateCorner(Knob, 5)
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = SliderFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(SliderStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(SliderFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(SliderStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(SliderFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Element})
            end)
            
            local Dragging = false
            local Min = options.Min
            local Max = options.Max
            local Default = math.clamp(options.Default, Min, Max)
            local Decimals = options.Decimals
            
            local function Update(input)
                local SizeScale = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local Raw = Min + ((Max - Min) * SizeScale)
                local Val = math.floor(Raw * (10 ^ Decimals)) / (10 ^ Decimals)
                
                Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeScale, 0, 1, 0)})
                ValueLabel.Text = tostring(Val)
                options.Callback(Val)
            end
            
            local InitialRatio = (Default - Min) / (Max - Min)
            Fill.Size = UDim2.new(InitialRatio, 0, 1, 0)
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
        
        function ElementHandler:Dropdown(options)
            options = Utility:Validate({
                Name = "Dropdown",
                Items = {},
                Multi = false,
                Callback = function() end
            }, options or {})
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Parent = Page
            DropdownFrame.BackgroundColor3 = Settings.Theme.Element
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            DropdownFrame.ClipsDescendants = true
            
            Utility:CreateCorner(DropdownFrame, 6)
            local DropStroke = Utility:CreateStroke(DropdownFrame, Settings.Theme.Outline, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = DropdownFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -50, 0, 40)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 10)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Image = "rbxassetid://6031090990"
            Arrow.ImageColor3 = Settings.Theme.SubText
            Arrow.Rotation = 90
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = DropdownFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 0, 40)
            Interact.Text = ""
            
            local ItemList = Instance.new("UIListLayout")
            ItemList.Parent = DropdownFrame
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0, 5)
            
            local Pad = Instance.new("UIPadding")
            Pad.Parent = DropdownFrame
            Pad.PaddingTop = UDim.new(0, 45)
            Pad.PaddingBottom = UDim.new(0, 5)
            Pad.PaddingLeft = UDim.new(0, 5)
            Pad.PaddingRight = UDim.new(0, 5)
            
            local Dropped = false
            
            local function Refresh()
                if Dropped then
                    local Count = #options.Items
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 50 + (Count * 28))})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                else
                    Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)})
                    Utility:Tween(Arrow, TweenInfo.new(0.3), {Rotation = 90})
                end
            end
            
            for _, item in ipairs(options.Items) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Parent = DropdownFrame
                ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.Text = item
                ItemBtn.TextColor3 = Settings.Theme.SubText
                ItemBtn.TextSize = 12
                
                Utility:CreateCorner(ItemBtn, 4)
                
                ItemBtn.MouseEnter:Connect(function()
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.Text})
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
                end)
                
                ItemBtn.MouseLeave:Connect(function()
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Theme.SubText})
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                end)
                
                ItemBtn.MouseButton1Click:Connect(function()
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
                Utility:Tween(DropdownFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(DropStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(DropdownFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Element})
            end)
            
            Interact.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                Refresh()
            end)
        end
        
        function ElementHandler:Textbox(options)
            options = Utility:Validate({
                Name = "Textbox",
                Placeholder = "Input",
                Callback = function() end
            }, options or {})
            
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "Textbox"
            BoxFrame.Parent = Page
            BoxFrame.BackgroundColor3 = Settings.Theme.Element
            BoxFrame.Size = UDim2.new(1, 0, 0, 40)
            
            Utility:CreateCorner(BoxFrame, 6)
            local BoxStroke = Utility:CreateStroke(BoxFrame, Settings.Theme.Outline, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = BoxFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -150, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Input = Instance.new("TextBox")
            Input.Parent = BoxFrame
            Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Input.Position = UDim2.new(1, -160, 0.5, -14)
            Input.Size = UDim2.new(0, 150, 0, 28)
            Input.Font = Enum.Font.Gotham
            Input.PlaceholderText = options.Placeholder
            Input.Text = ""
            Input.TextColor3 = Settings.Theme.Text
            Input.TextSize = 12
            
            Utility:CreateCorner(Input, 4)
            
            Input.Focused:Connect(function()
                Utility:Tween(BoxStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(Input, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
            end)
            
            Input.FocusLost:Connect(function()
                Utility:Tween(BoxStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(Input, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                options.Callback(Input.Text)
            end)
        end
        
        function ElementHandler:Keybind(options)
            options = Utility:Validate({
                Name = "Keybind",
                Default = Enum.KeyCode.None,
                Callback = function() end
            }, options or {})
            
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Name = "Keybind"
            KeyFrame.Parent = Page
            KeyFrame.BackgroundColor3 = Settings.Theme.Element
            KeyFrame.Size = UDim2.new(1, 0, 0, 40)
            
            Utility:CreateCorner(KeyFrame, 6)
            local KeyStroke = Utility:CreateStroke(KeyFrame, Settings.Theme.Outline, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = KeyFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Parent = KeyFrame
            BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            BindBtn.Position = UDim2.new(1, -92, 0.5, -12)
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.Text = options.Default.Name
            BindBtn.TextColor3 = Settings.Theme.SubText
            BindBtn.TextSize = 12
            
            Utility:CreateCorner(BindBtn, 4)
            
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
                        Binding = false
                        BindBtn.Text = "None"
                        BindBtn.TextColor3 = Settings.Theme.SubText
                        Utility:Tween(KeyStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
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
            CPFrame.Name = "ColorPicker"
            CPFrame.Parent = Page
            CPFrame.BackgroundColor3 = Settings.Theme.Element
            CPFrame.Size = UDim2.new(1, 0, 0, 40)
            CPFrame.ClipsDescendants = true
            
            Utility:CreateCorner(CPFrame, 6)
            local CPStroke = Utility:CreateStroke(CPFrame, Settings.Theme.Outline, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = CPFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -70, 0, 40)
            Label.Font = Enum.Font.Gotham
            Label.Text = options.Name
            Label.TextColor3 = Settings.Theme.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Preview = Instance.new("TextButton")
            Preview.Parent = CPFrame
            Preview.BackgroundColor3 = options.Default
            Preview.Position = UDim2.new(1, -62, 0.5, -10)
            Preview.Size = UDim2.new(0, 50, 0, 20)
            Preview.Text = ""
            
            Utility:CreateCorner(Preview, 4)
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = CPFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 0, 40)
            Interact.Text = ""
            
            local Container = Instance.new("Frame")
            Container.Parent = CPFrame
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 10, 0, 45)
            Container.Size = UDim2.new(1, -20, 0, 170)
            Container.Visible = false
            
            local SV = Instance.new("ImageLabel")
            SV.Parent = Container
            SV.BorderSizePixel = 0
            SV.Position = UDim2.new(0, 0, 0, 0)
            SV.Size = UDim2.new(0, 150, 0, 150)
            SV.Image = "rbxassetid://4155801252"
            
            Utility:CreateCorner(SV, 4)
            
            local SVCursor = Instance.new("Frame")
            SVCursor.Parent = SV
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SVCursor.Size = UDim2.new(0, 4, 0, 4)
            SVCursor.Rotation = 45
            
            local Hue = Instance.new("ImageLabel")
            Hue.Parent = Container
            Hue.BorderSizePixel = 0
            Hue.Position = UDim2.new(0, 160, 0, 0)
            Hue.Size = UDim2.new(1, -160, 0, 150)
            Hue.Image = "rbxassetid://4155801252"
            Hue.ScaleType = Enum.ScaleType.Stretch
            
            Utility:CreateCorner(Hue, 4)
            
            local HueGradient = Instance.new("UIGradient")
            HueGradient.Parent = Hue
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
            
            local HueCursor = Instance.new("Frame")
            HueCursor.Parent = Hue
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            HueCursor.Size = UDim2.new(1, 0, 0, 2)
            
            local RainbowBtn = Instance.new("TextButton")
            RainbowBtn.Parent = Container
            RainbowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            RainbowBtn.Position = UDim2.new(0, 0, 1, 5)
            RainbowBtn.Size = UDim2.new(1, 0, 0, 20)
            RainbowBtn.Font = Enum.Font.GothamBold
            RainbowBtn.Text = "Rainbow Mode"
            RainbowBtn.TextColor3 = Settings.Theme.SubText
            RainbowBtn.TextSize = 12
            
            Utility:CreateCorner(RainbowBtn, 4)
            
            local h, s, v = Color3.toHSV(options.Default)
            local IsRainbow = false
            
            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = color
                SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                options.Callback(color)
            end
            
            local DragHue, DragSV = false, false
            
            Hue.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DragHue = true
                end
            end)
            
            SV.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DragSV = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DragHue = false
                    DragSV = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if DragHue then
                        local Y = math.clamp((input.Position.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
                        HueCursor.Position = UDim2.new(0, 0, Y, 0)
                        h = 1 - Y
                        UpdateColor()
                    end
                    if DragSV then
                        local X = math.clamp((input.Position.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                        local Y = math.clamp((input.Position.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                        SVCursor.Position = UDim2.new(X, -2, Y, -2)
                        s = X
                        v = 1 - Y
                        UpdateColor()
                    end
                end
            end)
            
            local RainbowConnection
            RainbowBtn.MouseButton1Click:Connect(function()
                IsRainbow = not IsRainbow
                if IsRainbow then
                    RainbowBtn.TextColor3 = Settings.Theme.Accent
                    RainbowConnection = RunService.RenderStepped:Connect(function()
                        h = (tick() % 5) / 5
                        UpdateColor()
                        HueCursor.Position = UDim2.new(0, 0, 1 - h, 0)
                        SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    end)
                else
                    RainbowBtn.TextColor3 = Settings.Theme.SubText
                    if RainbowConnection then RainbowConnection:Disconnect() end
                end
            end)
            
            local IsOpen = false
            Interact.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    Utility:Tween(CPFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 230)})
                    Container.Visible = true
                else
                    Utility:Tween(CPFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)})
                    Container.Visible = false
                end
            end)
            
            Interact.MouseEnter:Connect(function()
                Utility:Tween(CPStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Glow})
                Utility:Tween(CPFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            Interact.MouseLeave:Connect(function()
                Utility:Tween(CPStroke, TweenInfo.new(0.2), {Color = Settings.Theme.Outline})
                Utility:Tween(CPFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Element})
            end)
            
            UpdateColor()
        end
        
        return ElementHandler
    end
    
    return WindowHandler
end

return Archived
