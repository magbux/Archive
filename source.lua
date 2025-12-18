--[[ 
    ARCHIVE UI LIBRARY V2
    Premium, Dark-Themed User Interface
    Added: ColorPicker, Notifications, Labels, Improved Animations
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")

local Archive = {}

-- // Utility: Draggable
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

-- // Utility: Tweening
local function Tween(instance, properties, time)
	TweenService:Create(instance, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

-- // Main Library
function Archive.new(Name)
	local UI = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local MainStroke = Instance.new("UIStroke")
	local MainCorner = Instance.new("UICorner")
	local Sidebar = Instance.new("Frame")
	local SidebarCorner = Instance.new("UICorner")
	local SidebarLayout = Instance.new("UIListLayout")
	local SidebarPadding = Instance.new("UIPadding")
	local Title = Instance.new("TextLabel")
	local Pages = Instance.new("Frame")
	local NotificationHolder = Instance.new("Frame")
    local NotificationLayout = Instance.new("UIListLayout")

	-- Theme Colors
	local Theme = {
		Background = Color3.fromRGB(16, 16, 16),
		Sidebar = Color3.fromRGB(22, 22, 22),
		Element = Color3.fromRGB(28, 28, 28),
		Text = Color3.fromRGB(240, 240, 240),
		TextDim = Color3.fromRGB(140, 140, 140),
		Accent = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(40, 40, 40)
	}

	-- Setup
	UI.Name = "ArchiveUI"
	UI.Parent = CoreGui
	UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Notifications Holder
    NotificationHolder.Name = "Notifications"
    NotificationHolder.Parent = UI
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Position = UDim2.new(1, -220, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.Size = UDim2.new(0, 200, 1, 0)
    
    NotificationLayout.Parent = NotificationHolder
    NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotificationLayout.Padding = UDim.new(0, 5)

	Main.Name = "Main"
	Main.Parent = UI
	Main.BackgroundColor3 = Theme.Background
	Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	Main.Size = UDim2.new(0, 600, 0, 420)
	Main.ClipsDescendants = true

	MainStroke.Parent = Main
	MainStroke.Color = Theme.Border
	MainStroke.Thickness = 1
	MainStroke.Transparency = 0.5

	MainCorner.CornerRadius = UDim.new(0, 8)
	MainCorner.Parent = Main

	MakeDraggable(Main, Main)

	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.Size = UDim2.new(0, 150, 1, 0)
	Sidebar.BorderSizePixel = 0

	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = Sidebar

	-- Fix right side of sidebar
	local SidebarFix = Instance.new("Frame")
	SidebarFix.Parent = Sidebar
	SidebarFix.BorderSizePixel = 0
	SidebarFix.BackgroundColor3 = Theme.Sidebar
	SidebarFix.Size = UDim2.new(0, 10, 1, 0)
	SidebarFix.Position = UDim2.new(1, -10, 0, 0)

	SidebarLayout.Parent = Sidebar
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 6)

	SidebarPadding.Parent = Sidebar
	SidebarPadding.PaddingTop = UDim.new(0, 50)
	SidebarPadding.PaddingLeft = UDim.new(0, 12)
	SidebarPadding.PaddingRight = UDim.new(0, 12)

	Title.Name = "Title"
	Title.Parent = Main
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Position = UDim2.new(0, 18, 0, 14)
	Title.Size = UDim2.new(0, 120, 0, 25)
	Title.Font = Enum.Font.GothamBold
	Title.Text = Name:upper()
	Title.TextColor3 = Theme.Text
	Title.TextSize = 14.000
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTransparency = 0.2

	Pages.Name = "Pages"
	Pages.Parent = Main
	Pages.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Pages.BackgroundTransparency = 1.000
	Pages.Position = UDim2.new(0, 160, 0, 10)
	Pages.Size = UDim2.new(0, 430, 1, -20)

	local Window = {
		Tabs = {}
	}

    function Window:Notify(Title, Text, Duration)
        local Frame = Instance.new("Frame")
        local FrameCorner = Instance.new("UICorner")
        local FrameStroke = Instance.new("UIStroke")
        local NTitle = Instance.new("TextLabel")
        local NText = Instance.new("TextLabel")

        Frame.Name = "Notification"
        Frame.Parent = NotificationHolder
        Frame.BackgroundColor3 = Theme.Element
        Frame.Size = UDim2.new(1, 0, 0, 60)
        Frame.BackgroundTransparency = 1 -- Animate in
        
        FrameCorner.CornerRadius = UDim.new(0, 6)
        FrameCorner.Parent = Frame
        
        FrameStroke.Parent = Frame
        FrameStroke.Color = Theme.Border
        FrameStroke.Transparency = 1 -- Animate in
        
        NTitle.Parent = Frame
        NTitle.BackgroundTransparency = 1
        NTitle.Position = UDim2.new(0, 10, 0, 5)
        NTitle.Size = UDim2.new(1, -20, 0, 20)
        NTitle.Font = Enum.Font.GothamBold
        NTitle.Text = Title
        NTitle.TextColor3 = Theme.Text
        NTitle.TextSize = 13
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.TextTransparency = 1
        
        NText.Parent = Frame
        NText.BackgroundTransparency = 1
        NText.Position = UDim2.new(0, 10, 0, 25)
        NText.Size = UDim2.new(1, -20, 0, 30)
        NText.Font = Enum.Font.Gotham
        NText.Text = Text
        NText.TextColor3 = Theme.TextDim
        NText.TextSize = 12
        NText.TextXAlignment = Enum.TextXAlignment.Left
        NText.TextYAlignment = Enum.TextYAlignment.Top
        NText.TextTransparency = 1
        NText.TextWrapped = true

        -- Animation In
        Tween(Frame, {BackgroundTransparency = 0.1})
        Tween(FrameStroke, {Transparency = 0.5})
        Tween(NTitle, {TextTransparency = 0})
        Tween(NText, {TextTransparency = 0})

        task.delay(Duration or 3, function()
            -- Animation Out
            Tween(Frame, {BackgroundTransparency = 1})
            Tween(FrameStroke, {Transparency = 1})
            Tween(NTitle, {TextTransparency = 1})
            Tween(NText, {TextTransparency = 1})
            wait(0.3)
            Frame:Destroy()
        end)
    end

	function Window:addPage(Name)
		local TabButton = Instance.new("TextButton")
		local TabCorner = Instance.new("UICorner")
		local Page = Instance.new("ScrollingFrame")
		local PageLayout = Instance.new("UIListLayout")
		local PagePadding = Instance.new("UIPadding")

		TabButton.Name = Name
		TabButton.Parent = Sidebar
		TabButton.BackgroundColor3 = Theme.Element
		TabButton.BackgroundTransparency = 1
		TabButton.Size = UDim2.new(1, 0, 0, 32)
		TabButton.Font = Enum.Font.GothamMedium
		TabButton.Text = Name
		TabButton.TextColor3 = Theme.TextDim
		TabButton.TextSize = 13.000
		TabButton.AutoButtonColor = false

		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabButton

		Page.Name = Name
		Page.Parent = Pages
		Page.Active = true
		Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Page.BackgroundTransparency = 1.000
		Page.BorderSizePixel = 0
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Border
		Page.Visible = false

		PageLayout.Parent = Page
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 12)

		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 5)
		PagePadding.PaddingLeft = UDim.new(0, 5)
		PagePadding.PaddingRight = UDim.new(0, 5)
		PagePadding.PaddingBottom = UDim.new(0, 5)

		local function UpdateTabs()
			for _, v in pairs(Window.Tabs) do
				Tween(v.Button, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim})
				v.Page.Visible = false
			end
			Tween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Element, TextColor3 = Theme.Text})
			Page.Visible = true
		end

		TabButton.MouseButton1Click:Connect(UpdateTabs)
		
		TabButton.MouseEnter:Connect(function()
			if Page.Visible == false then
				Tween(TabButton, {TextColor3 = Theme.Text})
			end
		end)
		TabButton.MouseLeave:Connect(function()
			if Page.Visible == false then
				Tween(TabButton, {TextColor3 = Theme.TextDim})
			end
		end)

		if #Window.Tabs == 0 then
			UpdateTabs()
		end

		table.insert(Window.Tabs, {Button = TabButton, Page = Page})

		local PageFuncs = {}

		function PageFuncs:addSection(Name)
			local Section = Instance.new("Frame")
			local SectionCorner = Instance.new("UICorner")
			local SectionStroke = Instance.new("UIStroke")
			local SectionTitle = Instance.new("TextLabel")
			local Container = Instance.new("Frame")
			local ContainerLayout = Instance.new("UIListLayout")
			local ContainerPadding = Instance.new("UIPadding")

			Section.Name = Name
			Section.Parent = Page
			Section.BackgroundColor3 = Theme.Sidebar
			Section.Size = UDim2.new(1, -6, 0, 30) 
			Section.ClipsDescendants = true

			SectionCorner.CornerRadius = UDim.new(0, 6)
			SectionCorner.Parent = Section
			
			SectionStroke.Parent = Section
			SectionStroke.Color = Theme.Border
			SectionStroke.Thickness = 1
			SectionStroke.Transparency = 0.8

			SectionTitle.Name = "Title"
			SectionTitle.Parent = Section
			SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionTitle.BackgroundTransparency = 1.000
			SectionTitle.Position = UDim2.new(0, 12, 0, 0)
			SectionTitle.Size = UDim2.new(1, -24, 0, 34)
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.Text = Name
			SectionTitle.TextColor3 = Theme.Text
			SectionTitle.TextSize = 12.000
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

			Container.Name = "Container"
			Container.Parent = Section
			Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Container.BackgroundTransparency = 1.000
			Container.Position = UDim2.new(0, 0, 0, 34)
			Container.Size = UDim2.new(1, 0, 0, 0)

			ContainerLayout.Parent = Container
			ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContainerLayout.Padding = UDim.new(0, 6)

			ContainerPadding.Parent = Container
			ContainerPadding.PaddingBottom = UDim.new(0, 12)
			ContainerPadding.PaddingLeft = UDim.new(0, 12)
			ContainerPadding.PaddingRight = UDim.new(0, 12)

			local function ResizeSection()
				local h = ContainerLayout.AbsoluteContentSize.Y
				Section.Size = UDim2.new(1, -6, 0, h + 46)
				Container.Size = UDim2.new(1, 0, 0, h)
				Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
			end
			
			ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeSection)

			local SectionFuncs = {}

            -- // LABEL
            function SectionFuncs:addLabel(Text)
                local LabelFrame = Instance.new("Frame")
                local LabelText = Instance.new("TextLabel")
                
                LabelFrame.Parent = Container
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                
                LabelText.Parent = LabelFrame
                LabelText.BackgroundTransparency = 1
                LabelText.Size = UDim2.new(1, 0, 1, 0)
                LabelText.Font = Enum.Font.Gotham
                LabelText.Text = Text
                LabelText.TextColor3 = Theme.TextDim
                LabelText.TextSize = 12
                LabelText.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- // BUTTON
			function SectionFuncs:addButton(Name, Callback)
				Callback = Callback or function() end
				local Button = Instance.new("TextButton")
				local ButtonCorner = Instance.new("UICorner")
				local ButtonStroke = Instance.new("UIStroke")

				Button.Name = Name
				Button.Parent = Container
				Button.BackgroundColor3 = Theme.Element
				Button.Size = UDim2.new(1, 0, 0, 32)
				Button.Font = Enum.Font.Gotham
				Button.Text = Name
				Button.TextColor3 = Theme.Text
				Button.TextSize = 12.000
				Button.AutoButtonColor = false

				ButtonCorner.CornerRadius = UDim.new(0, 4)
				ButtonCorner.Parent = Button
				
				ButtonStroke.Parent = Button
				ButtonStroke.Color = Theme.Border
				ButtonStroke.Thickness = 1
				ButtonStroke.Transparency = 0.5
				ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3 = Color3.fromRGB(45,45,45)}) end)
				Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3 = Theme.Element}) end)
				Button.MouseButton1Click:Connect(function()
					Callback()
					Tween(Button, {TextSize = 10}, 0.1)
					wait(0.1)
					Tween(Button, {TextSize = 12}, 0.1)
				end)
			end

            -- // TOGGLE
			function SectionFuncs:addToggle(Name, Default, Callback)
				Callback = Callback or function() end
				local Toggled = Default or false
				local ToggleBtn = Instance.new("TextButton")
				local ToggleCorner = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local CheckFrame = Instance.new("Frame")
				local CheckCorner = Instance.new("UICorner")
				local CheckCircle = Instance.new("Frame")
				local CircleCorner = Instance.new("UICorner")
				local ButtonStroke = Instance.new("UIStroke")

				ToggleBtn.Name = Name
				ToggleBtn.Parent = Container
				ToggleBtn.BackgroundColor3 = Theme.Element
				ToggleBtn.Size = UDim2.new(1, 0, 0, 32)
				ToggleBtn.AutoButtonColor = false
				ToggleBtn.Text = ""
				
				ButtonStroke.Parent = ToggleBtn
				ButtonStroke.Color = Theme.Border
				ButtonStroke.Thickness = 1
				ButtonStroke.Transparency = 0.5

				ToggleCorner.CornerRadius = UDim.new(0, 4)
				ToggleCorner.Parent = ToggleBtn

				Title.Parent = ToggleBtn
				Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Title.BackgroundTransparency = 1.000
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -50, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Theme.Text
				Title.TextSize = 12.000
				Title.TextXAlignment = Enum.TextXAlignment.Left

				CheckFrame.Parent = ToggleBtn
				CheckFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				CheckFrame.Position = UDim2.new(1, -44, 0.5, -10)
				CheckFrame.Size = UDim2.new(0, 34, 0, 20)

				CheckCorner.CornerRadius = UDim.new(1, 0)
				CheckCorner.Parent = CheckFrame
				
				CheckCircle.Parent = CheckFrame
				CheckCircle.BackgroundColor3 = Theme.TextDim
				CheckCircle.Position = UDim2.new(0, 2, 0.5, -8)
				CheckCircle.Size = UDim2.new(0, 16, 0, 16)
				
				CircleCorner.CornerRadius = UDim.new(1, 0)
				CircleCorner.Parent = CheckCircle

				local function UpdateState()
					if Toggled then
						Tween(CheckFrame, {BackgroundColor3 = Theme.Accent})
						Tween(CheckCircle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Element})
					else
						Tween(CheckFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
						Tween(CheckCircle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim})
					end
				end
				
				UpdateState()

				ToggleBtn.MouseButton1Click:Connect(function()
					Toggled = not Toggled
					UpdateState()
					Callback(Toggled)
				end)
			end

            -- // SLIDER
			function SectionFuncs:addSlider(Name, Default, Min, Max, Callback)
				Callback = Callback or function() end
				local SliderFrame = Instance.new("Frame")
				local SliderCorner = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local ValueLabel = Instance.new("TextLabel")
				local Bar = Instance.new("Frame")
				local BarCorner = Instance.new("UICorner")
				local Fill = Instance.new("Frame")
				local FillCorner = Instance.new("UICorner")
				local ClickButton = Instance.new("TextButton")
				local ButtonStroke = Instance.new("UIStroke")

				SliderFrame.Name = Name
				SliderFrame.Parent = Container
				SliderFrame.BackgroundColor3 = Theme.Element
				SliderFrame.Size = UDim2.new(1, 0, 0, 48)

				SliderCorner.CornerRadius = UDim.new(0, 4)
				SliderCorner.Parent = SliderFrame
				
				ButtonStroke.Parent = SliderFrame
				ButtonStroke.Color = Theme.Border
				ButtonStroke.Thickness = 1
				ButtonStroke.Transparency = 0.5

				Title.Parent = SliderFrame
				Title.BackgroundTransparency = 1.000
				Title.Position = UDim2.new(0, 10, 0, 8)
				Title.Size = UDim2.new(1, -50, 0, 20)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Theme.Text
				Title.TextSize = 12.000
				Title.TextXAlignment = Enum.TextXAlignment.Left

				ValueLabel.Parent = SliderFrame
				ValueLabel.BackgroundTransparency = 1.000
				ValueLabel.Position = UDim2.new(1, -40, 0, 8)
				ValueLabel.Size = UDim2.new(0, 30, 0, 20)
				ValueLabel.Font = Enum.Font.GothamBold
				ValueLabel.Text = tostring(Default)
				ValueLabel.TextColor3 = Theme.Accent
				ValueLabel.TextSize = 12.000

				Bar.Parent = SliderFrame
				Bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				Bar.Position = UDim2.new(0, 10, 0, 32)
				Bar.Size = UDim2.new(1, -20, 0, 6)

				BarCorner.CornerRadius = UDim.new(0, 3)
				BarCorner.Parent = Bar

				Fill.Parent = Bar
				Fill.BackgroundColor3 = Theme.Accent
				Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)

				FillCorner.CornerRadius = UDim.new(0, 3)
				FillCorner.Parent = Fill

				ClickButton.Parent = Bar
				ClickButton.BackgroundTransparency = 1
				ClickButton.Size = UDim2.new(1, 0, 1, 0)
				ClickButton.Text = ""

				local Dragging = false

				local function Move(Input)
					local pos = UDim2.new(math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1), 0, 1, 0)
					Tween(Fill, {Size = pos}, 0.1)
					local val = math.floor(((pos.X.Scale * (Max - Min)) + Min) * 10) / 10
					ValueLabel.Text = tostring(val)
					Callback(val)
				end

				ClickButton.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						Move(Input)
					end
				end)

				ClickButton.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
						Move(Input)
					end
				end)
			end

            -- // DROPDOWN
			function SectionFuncs:addDropdown(Name, List, Default, Callback)
				Callback = Callback or function() end
				local Dropdown = Instance.new("Frame")
				local DropCorner = Instance.new("UICorner")
				local DropBtn = Instance.new("TextButton")
				local Title = Instance.new("TextLabel")
				local Arrow = Instance.new("ImageLabel")
				local ListFrame = Instance.new("ScrollingFrame")
				local ListLayout = Instance.new("UIListLayout")
				local ListPadding = Instance.new("UIPadding")
				local ButtonStroke = Instance.new("UIStroke")

				Dropdown.Name = Name
				Dropdown.Parent = Container
				Dropdown.BackgroundColor3 = Theme.Element
				Dropdown.Size = UDim2.new(1, 0, 0, 32)
				Dropdown.ClipsDescendants = true

				DropCorner.CornerRadius = UDim.new(0, 4)
				DropCorner.Parent = Dropdown
				
				ButtonStroke.Parent = Dropdown
				ButtonStroke.Color = Theme.Border
				ButtonStroke.Thickness = 1
				ButtonStroke.Transparency = 0.5

				DropBtn.Parent = Dropdown
				DropBtn.BackgroundTransparency = 1
				DropBtn.Size = UDim2.new(1, 0, 0, 32)
				DropBtn.Text = ""

				Title.Parent = DropBtn
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -30, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Default or Name
				Title.TextColor3 = Theme.Text
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left

				Arrow.Parent = DropBtn
				Arrow.BackgroundTransparency = 1
				Arrow.Position = UDim2.new(1, -25, 0.5, -10)
				Arrow.Size = UDim2.new(0, 20, 0, 20)
				Arrow.Image = "rbxassetid://6034818372"
				Arrow.ImageColor3 = Theme.TextDim

				ListFrame.Parent = Dropdown
				ListFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				ListFrame.BorderSizePixel = 0
				ListFrame.Position = UDim2.new(0, 0, 0, 36)
				ListFrame.Size = UDim2.new(1, 0, 0, 100)
				ListFrame.ScrollBarThickness = 2
				ListFrame.ScrollBarImageColor3 = Theme.Border

				ListLayout.Parent = ListFrame
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Padding = UDim.new(0, 2)

				ListPadding.Parent = ListFrame
				ListPadding.PaddingLeft = UDim.new(0, 5)
				ListPadding.PaddingRight = UDim.new(0, 5)

				local Open = false
				
				local function RefreshList()
					for _, v in pairs(ListFrame:GetChildren()) do
						if v:IsA("TextButton") then v:Destroy() end
					end
					
					for _, item in pairs(List) do
						local ItemBtn = Instance.new("TextButton")
						ItemBtn.Parent = ListFrame
						ItemBtn.BackgroundColor3 = Theme.Element
						ItemBtn.BackgroundTransparency = 1
						ItemBtn.Size = UDim2.new(1, 0, 0, 26)
						ItemBtn.Font = Enum.Font.Gotham
						ItemBtn.Text = item
						ItemBtn.TextColor3 = Theme.TextDim
						ItemBtn.TextSize = 12
						ItemBtn.AutoButtonColor = false
						
						local ItemCorner = Instance.new("UICorner")
						ItemCorner.CornerRadius = UDim.new(0, 4)
						ItemCorner.Parent = ItemBtn
						
						ItemBtn.MouseEnter:Connect(function() Tween(ItemBtn, {BackgroundTransparency = 0, TextColor3 = Theme.Text}) end)
						ItemBtn.MouseLeave:Connect(function() Tween(ItemBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}) end)
						
						ItemBtn.MouseButton1Click:Connect(function()
							Open = false
							Title.Text = item
							Tween(Dropdown, {Size = UDim2.new(1, 0, 0, 32)})
							Tween(Arrow, {Rotation = 0})
							Callback(item)
						end)
					end
					ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
				end

				RefreshList()

				DropBtn.MouseButton1Click:Connect(function()
					Open = not Open
					if Open then
						Tween(Dropdown, {Size = UDim2.new(1, 0, 0, 140)})
						Tween(Arrow, {Rotation = 180})
					else
						Tween(Dropdown, {Size = UDim2.new(1, 0, 0, 32)})
						Tween(Arrow, {Rotation = 0})
					end
				end)
			end
			
            -- // KEYBIND
			function SectionFuncs:addKeybind(Name, Default, Callback)
				Callback = Callback or function() end
				local KeybindFrame = Instance.new("Frame")
				local KeyCorner = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local KeyBtn = Instance.new("TextButton")
				local KeyBtnCorner = Instance.new("UICorner")
				local ButtonStroke = Instance.new("UIStroke")

				KeybindFrame.Name = Name
				KeybindFrame.Parent = Container
				KeybindFrame.BackgroundColor3 = Theme.Element
				KeybindFrame.Size = UDim2.new(1, 0, 0, 32)
				
				ButtonStroke.Parent = KeybindFrame
				ButtonStroke.Color = Theme.Border
				ButtonStroke.Thickness = 1
				ButtonStroke.Transparency = 0.5

				KeyCorner.CornerRadius = UDim.new(0, 4)
				KeyCorner.Parent = KeybindFrame

				Title.Parent = KeybindFrame
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -80, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Theme.Text
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left

				KeyBtn.Parent = KeybindFrame
				KeyBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				KeyBtn.Position = UDim2.new(1, -70, 0.5, -10)
				KeyBtn.Size = UDim2.new(0, 60, 0, 20)
				KeyBtn.Font = Enum.Font.GothamBold
				KeyBtn.Text = Default and Default.Name or "NONE"
				KeyBtn.TextColor3 = Theme.TextDim
				KeyBtn.TextSize = 10
				KeyBtn.AutoButtonColor = false

				KeyBtnCorner.CornerRadius = UDim.new(0, 4)
				KeyBtnCorner.Parent = KeyBtn

				local Listening = false

				KeyBtn.MouseButton1Click:Connect(function()
					Listening = true
					KeyBtn.Text = "..."
					Tween(KeyBtn, {TextColor3 = Theme.Accent})
				end)

				UserInputService.InputBegan:Connect(function(Input)
					if Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
						Listening = false
						KeyBtn.Text = Input.KeyCode.Name:upper()
						Tween(KeyBtn, {TextColor3 = Theme.TextDim})
						Callback(Input.KeyCode)
					elseif Input.KeyCode == Default then
						Callback(Input.KeyCode)
					end
				end)
			end

            -- // COLOR PICKER
            function SectionFuncs:addColorPicker(Name, Default, Callback)
                Callback = Callback or function() end
                local Color3Value = Default or Color3.fromRGB(255, 255, 255)
                
                local PickerFrame = Instance.new("Frame")
                local PickerCorner = Instance.new("UICorner")
                local Title = Instance.new("TextLabel")
                local Display = Instance.new("TextButton")
                local DisplayCorner = Instance.new("UICorner")
                local ButtonStroke = Instance.new("UIStroke")
                
                local ExpandFrame = Instance.new("Frame")
                local HueSlide = Instance.new("ImageButton")
                local HueCorner = Instance.new("UICorner")
                local HueGrad = Instance.new("UIGradient")
                local SatSlide = Instance.new("ImageButton")
                local SatCorner = Instance.new("UICorner")
                local SatGrad = Instance.new("UIGradient")
                local ValSlide = Instance.new("ImageButton")
                local ValCorner = Instance.new("UICorner")
                local ValGrad = Instance.new("UIGradient")

                PickerFrame.Name = Name
                PickerFrame.Parent = Container
                PickerFrame.BackgroundColor3 = Theme.Element
                PickerFrame.Size = UDim2.new(1, 0, 0, 32)
                PickerFrame.ClipsDescendants = true

                PickerCorner.CornerRadius = UDim.new(0, 4)
                PickerCorner.Parent = PickerFrame
                
                ButtonStroke.Parent = PickerFrame
                ButtonStroke.Color = Theme.Border
                ButtonStroke.Thickness = 1
                ButtonStroke.Transparency = 0.5

                Title.Parent = PickerFrame
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -50, 0, 32)
                Title.Font = Enum.Font.Gotham
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left

                Display.Parent = PickerFrame
                Display.BackgroundColor3 = Color3Value
                Display.Position = UDim2.new(1, -40, 0, 6)
                Display.Size = UDim2.new(0, 30, 0, 20)
                Display.Text = ""
                Display.AutoButtonColor = false

                DisplayCorner.CornerRadius = UDim.new(0, 4)
                DisplayCorner.Parent = Display

                -- Expand Area
                ExpandFrame.Parent = PickerFrame
                ExpandFrame.BackgroundTransparency = 1
                ExpandFrame.Position = UDim2.new(0, 10, 0, 35)
                ExpandFrame.Size = UDim2.new(1, -20, 0, 60)

                -- Helper to create slider
                local function CreateSlider(parent, gradInfo, yPos)
                    local Slider = Instance.new("ImageButton")
                    local Corn = Instance.new("UICorner")
                    local Grad = Instance.new("UIGradient")
                    
                    Slider.Parent = parent
                    Slider.BackgroundColor3 = Color3.new(1,1,1)
                    Slider.Position = UDim2.new(0, 0, 0, yPos)
                    Slider.Size = UDim2.new(1, 0, 0, 10)
                    Slider.AutoButtonColor = false
                    
                    Corn.CornerRadius = UDim.new(0, 2)
                    Corn.Parent = Slider
                    
                    Grad.Color = gradInfo
                    Grad.Parent = Slider
                    return Slider
                end

                local h, s, v = Color3.toHSV(Color3Value)

                -- Hue Slider
                local HueSeq = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                }
                local HueBtn = CreateSlider(ExpandFrame, HueSeq, 0)

                -- Saturation Slider
                local SatSeq = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h, 1, v))
                local SatBtn = CreateSlider(ExpandFrame, SatSeq, 15)

                -- Value Slider
                local ValSeq = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)) -- Updated dynamic
                local ValBtn = CreateSlider(ExpandFrame, ValSeq, 30)

                local Open = false
                
                Display.MouseButton1Click:Connect(function()
                    Open = not Open
                    if Open then
                        Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 80)})
                    else
                        Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 32)})
                    end
                end)

                -- Update Loop
                local function UpdateColor()
                    Color3Value = Color3.fromHSV(h, s, v)
                    Display.BackgroundColor3 = Color3Value
                    -- Update gradients
                    SatBtn.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h, 1, v))
                    ValBtn.UIGradient.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromHSV(h, s, 1))
                    Callback(Color3Value)
                end

                -- Logic for Dragging
                local function HandleDrag(btn, type)
                    local Dragging = false
                    btn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
                    end)
                    btn.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = math.clamp((input.Position.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
                            if type == "H" then h = pct
                            elseif type == "S" then s = pct
                            elseif type == "V" then v = pct end
                            UpdateColor()
                        end
                    end)
                     -- Click support
                    btn.MouseButton1Down:Connect(function()
                        Dragging = true
                        local pct = math.clamp((Mouse.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
                        if type == "H" then h = pct
                        elseif type == "S" then s = pct
                        elseif type == "V" then v = pct end
                        UpdateColor()
                    end)
                end

                HandleDrag(HueBtn, "H")
                HandleDrag(SatBtn, "S")
                HandleDrag(ValBtn, "V")
            end

			return SectionFuncs
		end
		
		return PageFuncs
	end
	return Window
end

return Archive
