--[[ 
    ARCHIVED UI LIBRARY 
    Inspiration: Krnl (Layout), Venyx (Feel), Fluent Amethyst (Colors)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Archived = {}

--// Settings & Theme
Archived.Settings = {
    Name = "Archived",
    Accent = Color3.fromRGB(155, 89, 182), -- Amethyst Purple
    Background = Color3.fromRGB(20, 20, 20), -- Krnl Dark
    Header = Color3.fromRGB(25, 25, 25),
    Item = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(240, 240, 240),
    Placeholder = Color3.fromRGB(150, 150, 150)
}

--// Utility Functions
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
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

	topbarobject.InputChanged:Connect(function(input)
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

local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function Ripple(Button)
	spawn(function()
		local Circle = Instance.new("ImageLabel")
		Circle.Name = "Circle"
		Circle.Parent = Button
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.BackgroundTransparency = 1.000
		Circle.ZIndex = 10
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Color3.fromRGB(210, 210, 210)
		Circle.ImageTransparency = 0.8
		
        local Mouse = Players.LocalPlayer:GetMouse()
		local NewX = Mouse.X - Circle.AbsolutePosition.X
		local NewY = Mouse.Y - Circle.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)
		
		local Size = 0
		if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X * 1.5
		else
			Size = Button.AbsoluteSize.Y * 1.5
		end
		
		Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", 0.5, false)
		
		for i = 1, 10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.05
			wait(0.5/10)
		end
		Circle:Destroy()
	end)
end

--// Main Library Logic
function Archived:Window(options)
    local WindowName = options.Name or "Archived"
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ArchivedUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    -- Main Frame (The Window)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Archived.Settings.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 600, 0, 400) -- PC Default Size
    
    -- Rounded Corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame
    
    -- Stroke (Glow effect)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = MainFrame
    UIStroke.Color = Color3.fromRGB(40,40,40)
    UIStroke.Thickness = 1
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Archived.Settings.Header
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    TopBarCorner.Parent = TopBar
    
    -- Fix bottom corners of top bar to be flat
    local TopBarCover = Instance.new("Frame")
    TopBarCover.Name = "Cover"
    TopBarCover.Parent = TopBar
    TopBarCover.BackgroundColor3 = Archived.Settings.Header
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Position = UDim2.new(0, 0, 1, -10)
    TopBarCover.Size = UDim2.new(1, 0, 0, 10)

    MakeDraggable(TopBar, MainFrame)

    -- Search Bar / Logo Area (Top Left)
    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Parent = TopBar
    SearchContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SearchContainer.BackgroundTransparency = 1
    SearchContainer.Position = UDim2.new(0, 10, 0, 8)
    SearchContainer.Size = UDim2.new(0, 160, 0, 30)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "Logo"
    SearchIcon.Parent = SearchContainer
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 5, 0, 5)
    SearchIcon.Size = UDim2.new(0, 20, 0, 20)
    SearchIcon.Image = "rbxassetid://6031154871" -- Magnifying glass / Logo
    SearchIcon.ImageColor3 = Archived.Settings.Accent

    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = SearchContainer
    SearchBox.BackgroundTransparency = 1
    SearchBox.Position = UDim2.new(0, 35, 0, 0)
    SearchBox.Size = UDim2.new(1, -35, 1, 0)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.PlaceholderText = WindowName
    SearchBox.Text = ""
    SearchBox.TextColor3 = Archived.Settings.Text
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    -- Controls (Top Right)
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Parent = TopBar
    Controls.BackgroundTransparency = 1
    Controls.Position = UDim2.new(1, -70, 0, 0)
    Controls.Size = UDim2.new(0, 70, 1, 0)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Controls
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = Controls
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -70, 0, 0)
    MinBtn.Size = UDim2.new(0, 35, 1, 0)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.TextSize = 14
    
    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 45)})
        else
            Tween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)})
        end
    end)

    -- Tab Button Container (Top Center)
    local TabButtonContainer = Instance.new("Frame")
    TabButtonContainer.Name = "Tabs"
    TabButtonContainer.Parent = TopBar
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.Position = UDim2.new(0, 180, 0, 0)
    TabButtonContainer.Size = UDim2.new(1, -260, 1, 0)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabButtonContainer
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 10, 0, 55)
    PageContainer.Size = UDim2.new(1, -20, 1, -65)
    PageContainer.ClipsDescendants = true

    local Tabs = {}
    local FirstTab = true

    --// Tab Logic
    function Tabs:Tab(name)
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name.."Btn"
        TabBtn.Parent = TabButtonContainer
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 0, 0, 30) -- Auto sized
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 13
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        
        -- Tab Indicator/Underline
        local Indicator = Instance.new("Frame")
        Indicator.Parent = TabBtn
        Indicator.BackgroundColor3 = Archived.Settings.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 1, -2)
        Indicator.Size = UDim2.new(0, 0, 0, 2)
        
        -- Page Frame
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name.."Page"
        Page.Parent = PageContainer
        Page.Active = true
        Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Archived.Settings.Accent
        Page.Visible = false
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Switch Function
        local function Activate()
            for _, v in pairs(PageContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(TabButtonContainer:GetChildren()) do
                if v:IsA("TextButton") then 
                    Tween(v, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)})
                    Tween(v.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2)})
                end
            end
            
            Page.Visible = true
            Tween(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)})
            Tween(Indicator, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 2)})
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        local Elements = {}

        --// Section
        function Elements:Section(text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "Section"
            SectionLabel.Parent = Page
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(1, 0, 0, 25)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = "  "..text
            SectionLabel.TextColor3 = Archived.Settings.Accent
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        --// Button
        function Elements:Button(text, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "Button"
            ButtonFrame.Parent = Page
            ButtonFrame.BackgroundColor3 = Archived.Settings.Item
            ButtonFrame.Size = UDim2.new(1, -10, 0, 35)
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = ButtonFrame
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = ButtonFrame
            Btn.BackgroundTransparency = 1
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Font = Enum.Font.Gotham
            Btn.Text = text
            Btn.TextColor3 = Archived.Settings.Text
            Btn.TextSize = 14
            Btn.ClipsDescendants = true
            
            Btn.MouseButton1Click:Connect(function()
                Ripple(Btn)
                callback()
            end)
            
            -- Hover Effect
            Btn.MouseEnter:Connect(function()
                Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)})
            end)
            Btn.MouseLeave:Connect(function()
                Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Archived.Settings.Item})
            end)
        end

        --// Toggle
        function Elements:Toggle(text, default, callback)
            local toggled = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Parent = Page
            ToggleFrame.BackgroundColor3 = Archived.Settings.Item
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Archived.Settings.Text
            ToggleLabel.TextSize = 14
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = toggled and Archived.Settings.Accent or Color3.fromRGB(50, 50, 50)
            SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchBg.Size = UDim2.new(0, 40, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg
            
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Parent = SwitchBg
            SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SwitchCircle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = SwitchCircle
            
            local Trigger = Instance.new("TextButton")
            Trigger.Parent = ToggleFrame
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""
            
            Trigger.MouseButton1Click:Connect(function()
                toggled = not toggled
                Ripple(Trigger)
                if toggled then
                    Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Archived.Settings.Accent})
                    Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)})
                else
                    Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                    Tween(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)})
                end
                callback(toggled)
            end)
        end

        --// Slider
        function Elements:Slider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "Slider"
            SliderFrame.Parent = Page
            SliderFrame.BackgroundColor3 = Archived.Settings.Item
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Archived.Settings.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Archived.Settings.Placeholder
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local SlideBar = Instance.new("Frame")
            SlideBar.Parent = SliderFrame
            SlideBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            SlideBar.Position = UDim2.new(0, 10, 0, 35)
            SlideBar.Size = UDim2.new(1, -20, 0, 6)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SlideBar
            
            local Fill = Instance.new("Frame")
            Fill.Parent = SlideBar
            Fill.BackgroundColor3 = Archived.Settings.Accent
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Trigger = Instance.new("TextButton")
            Trigger.Parent = SliderFrame
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""
            
            local dragging = false
            
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local SizeScale = math.clamp((input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
                    local Value = math.floor(min + ((max - min) * SizeScale))
                    
                    Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeScale, 0, 1, 0)})
                    ValueLabel.Text = tostring(Value)
                    callback(Value)
                end
            end)
        end
        
        --// Dropdown
        function Elements:Dropdown(text, list, callback)
            local isDropped = false
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Parent = Page
            DropdownFrame.BackgroundColor3 = Archived.Settings.Item
            DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            DropdownFrame.ClipsDescendants = true
            
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropdownFrame

            local Label = Instance.new("TextLabel")
            Label.Parent = DropdownFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -40, 0, 35)
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Archived.Settings.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 7)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Image = "rbxassetid://6031090990"
            Arrow.Rotation = 90
            
            local Trigger = Instance.new("TextButton")
            Trigger.Parent = DropdownFrame
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropdownFrame
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 5)
            
            -- Padding for list
            local Pad = Instance.new("UIPadding")
            Pad.PaddingTop = UDim.new(0, 35)
            Pad.Parent = DropdownFrame

            local function RefreshSize()
                if isDropped then
                    Tween(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 35 + (#list * 25) + 5)})
                    Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                else
                    Tween(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 35)})
                    Tween(Arrow, TweenInfo.new(0.3), {Rotation = 90})
                end
            end
            
            for i, v in pairs(list) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Parent = DropdownFrame
                ItemBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
                ItemBtn.Size = UDim2.new(1, -20, 0, 25)
                ItemBtn.Position = UDim2.new(0, 10, 0, 0)
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.Text = v
                ItemBtn.TextColor3 = Archived.Settings.Placeholder
                ItemBtn.TextSize = 13
                
                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 4)
                ItemCorner.Parent = ItemBtn
                
                ItemBtn.MouseButton1Click:Connect(function()
                    isDropped = false
                    RefreshSize()
                    Label.Text = text .. " : " .. v
                    callback(v)
                end)
            end
            
            Trigger.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                RefreshSize()
            end)
        end

        return Elements
    end
    
    return Tabs
end

return Archived
