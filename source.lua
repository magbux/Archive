local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}

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

function Library.new(Name)
	local UI = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Sidebar = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local SidebarLayout = Instance.new("UIListLayout")
	local SidebarPadding = Instance.new("UIPadding")
	local Title = Instance.new("TextLabel")
	local Pages = Instance.new("Frame")
	local UICorner_3 = Instance.new("UICorner")

	UI.Name = Name
	UI.Parent = game.CoreGui
	UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Main.Name = "Main"
	Main.Parent = UI
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Main.Position = UDim2.new(0.5, -275, 0.5, -175)
	Main.Size = UDim2.new(0, 550, 0, 350)

	UICorner.CornerRadius = UDim.new(0, 6)
	UICorner.Parent = Main

	MakeDraggable(Main, Main)

	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Sidebar.Size = UDim2.new(0, 130, 1, 0)

	UICorner_2.CornerRadius = UDim.new(0, 6)
	UICorner_2.Parent = Sidebar

	local Cover = Instance.new("Frame")
	Cover.BorderSizePixel = 0
	Cover.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Cover.Size = UDim2.new(0, 5, 1, 0)
	Cover.Position = UDim2.new(1, -5, 0, 0)
	Cover.Parent = Sidebar

	SidebarLayout.Parent = Sidebar
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 5)

	SidebarPadding.Parent = Sidebar
	SidebarPadding.PaddingTop = UDim.new(0, 40)
	SidebarPadding.PaddingLeft = UDim.new(0, 10)

	Title.Name = "Title"
	Title.Parent = Main
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Position = UDim2.new(0, 10, 0, 10)
	Title.Size = UDim2.new(0, 110, 0, 25)
	Title.Font = Enum.Font.GothamBold
	Title.Text = Name
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 16.000
	Title.TextXAlignment = Enum.TextXAlignment.Left

	Pages.Name = "Pages"
	Pages.Parent = Main
	Pages.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Pages.BackgroundTransparency = 1.000
	Pages.Position = UDim2.new(0, 140, 0, 10)
	Pages.Size = UDim2.new(0, 400, 1, -20)

	local Window = {
		Tabs = {}
	}

	function Window:addPage(Name, IconID)
		local TabButton = Instance.new("TextButton")
		local UICorner_Tab = Instance.new("UICorner")
		local Page = Instance.new("ScrollingFrame")
		local PageLayout = Instance.new("UIListLayout")
		local PagePadding = Instance.new("UIPadding")

		TabButton.Name = Name
		TabButton.Parent = Sidebar
		TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.BackgroundTransparency = 1.000
		TabButton.Size = UDim2.new(0, 110, 0, 30)
		TabButton.Font = Enum.Font.Gotham
		TabButton.Text = Name
		TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		TabButton.TextSize = 14.000

		UICorner_Tab.CornerRadius = UDim.new(0, 4)
		UICorner_Tab.Parent = TabButton

		Page.Name = Name
		Page.Parent = Pages
		Page.Active = true
		Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Page.BackgroundTransparency = 1.000
		Page.BorderSizePixel = 0
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
		Page.Visible = false

		PageLayout.Parent = Page
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)

		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 5)
		PagePadding.PaddingLeft = UDim.new(0, 5)
		PagePadding.PaddingRight = UDim.new(0, 5)

		local function UpdateTabs()
			for _, v in pairs(Window.Tabs) do
				v.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
				v.Button.BackgroundTransparency = 1
				v.Page.Visible = false
			end
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TabButton.BackgroundTransparency = 0.95
			Page.Visible = true
		end

		TabButton.MouseButton1Click:Connect(UpdateTabs)

		if #Window.Tabs == 0 then
			UpdateTabs()
		end

		table.insert(Window.Tabs, {Button = TabButton, Page = Page})

		local PageFuncs = {}

		function PageFuncs:addSection(Name)
			local Section = Instance.new("Frame")
			local SectionCorner = Instance.new("UICorner")
			local SectionTitle = Instance.new("TextLabel")
			local Container = Instance.new("Frame")
			local ContainerLayout = Instance.new("UIListLayout")
			local ContainerPadding = Instance.new("UIPadding")

			Section.Name = Name
			Section.Parent = Page
			Section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			Section.Size = UDim2.new(1, -10, 0, 30) 
			Section.ClipsDescendants = true

			SectionCorner.CornerRadius = UDim.new(0, 4)
			SectionCorner.Parent = Section

			SectionTitle.Name = "Title"
			SectionTitle.Parent = Section
			SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionTitle.BackgroundTransparency = 1.000
			SectionTitle.Position = UDim2.new(0, 10, 0, 0)
			SectionTitle.Size = UDim2.new(1, -20, 0, 30)
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.Text = Name
			SectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
			SectionTitle.TextSize = 12.000
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

			Container.Name = "Container"
			Container.Parent = Section
			Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Container.BackgroundTransparency = 1.000
			Container.Position = UDim2.new(0, 0, 0, 30)
			Container.Size = UDim2.new(1, 0, 0, 0)

			ContainerLayout.Parent = Container
			ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContainerLayout.Padding = UDim.new(0, 5)

			ContainerPadding.Parent = Container
			ContainerPadding.PaddingBottom = UDim.new(0, 10)
			ContainerPadding.PaddingLeft = UDim.new(0, 10)
			ContainerPadding.PaddingRight = UDim.new(0, 10)

			local function ResizeSection()
				local h = ContainerLayout.AbsoluteContentSize.Y
				Section.Size = UDim2.new(1, -10, 0, h + 40)
				Container.Size = UDim2.new(1, 0, 0, h)
				Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
			end
			
			ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeSection)

			local SectionFuncs = {}

			function SectionFuncs:addButton(Name, Callback)
				Callback = Callback or function() end
				local Button = Instance.new("TextButton")
				local ButtonCorner = Instance.new("UICorner")

				Button.Name = Name
				Button.Parent = Container
				Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				Button.Size = UDim2.new(1, 0, 0, 30)
				Button.Font = Enum.Font.Gotham
				Button.Text = Name
				Button.TextColor3 = Color3.fromRGB(255, 255, 255)
				Button.TextSize = 12.000
				Button.AutoButtonColor = false

				ButtonCorner.CornerRadius = UDim.new(0, 4)
				ButtonCorner.Parent = Button

				Button.MouseEnter:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
				end)
				Button.MouseLeave:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
				end)
				Button.MouseButton1Click:Connect(function()
					Callback()
					TweenService:Create(Button, TweenInfo.new(0.1), {TextSize = 10}):Play()
					wait(0.1)
					TweenService:Create(Button, TweenInfo.new(0.1), {TextSize = 12}):Play()
				end)
			end

			function SectionFuncs:addToggle(Name, Default, Callback)
				Callback = Callback or function() end
				local Toggled = Default or false
				local ToggleBtn = Instance.new("TextButton")
				local ToggleCorner = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local CheckFrame = Instance.new("Frame")
				local CheckCorner = Instance.new("UICorner")
				local CheckStatus = Instance.new("Frame")
				local StatusCorner = Instance.new("UICorner")

				ToggleBtn.Name = Name
				ToggleBtn.Parent = Container
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				ToggleBtn.Size = UDim2.new(1, 0, 0, 30)
				ToggleBtn.AutoButtonColor = false
				ToggleBtn.Text = ""

				ToggleCorner.CornerRadius = UDim.new(0, 4)
				ToggleCorner.Parent = ToggleBtn

				Title.Parent = ToggleBtn
				Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Title.BackgroundTransparency = 1.000
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -40, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title.TextSize = 12.000
				Title.TextXAlignment = Enum.TextXAlignment.Left

				CheckFrame.Parent = ToggleBtn
				CheckFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				CheckFrame.Position = UDim2.new(1, -26, 0.5, -8)
				CheckFrame.Size = UDim2.new(0, 16, 0, 16)

				CheckCorner.CornerRadius = UDim.new(0, 4)
				CheckCorner.Parent = CheckFrame

				CheckStatus.Parent = CheckFrame
				CheckStatus.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
				CheckStatus.Size = UDim2.new(1, 0, 1, 0)
				CheckStatus.BackgroundTransparency = Toggled and 0 or 1

				StatusCorner.CornerRadius = UDim.new(0, 4)
				StatusCorner.Parent = CheckStatus

				ToggleBtn.MouseButton1Click:Connect(function()
					Toggled = not Toggled
					TweenService:Create(CheckStatus, TweenInfo.new(0.2), {BackgroundTransparency = Toggled and 0 or 1}):Play()
					Callback(Toggled)
				end)
			end

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

				SliderFrame.Name = Name
				SliderFrame.Parent = Container
				SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				SliderFrame.Size = UDim2.new(1, 0, 0, 45)

				SliderCorner.CornerRadius = UDim.new(0, 4)
				SliderCorner.Parent = SliderFrame

				Title.Parent = SliderFrame
				Title.BackgroundTransparency = 1.000
				Title.Position = UDim2.new(0, 10, 0, 5)
				Title.Size = UDim2.new(1, -50, 0, 20)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title.TextSize = 12.000
				Title.TextXAlignment = Enum.TextXAlignment.Left

				ValueLabel.Parent = SliderFrame
				ValueLabel.BackgroundTransparency = 1.000
				ValueLabel.Position = UDim2.new(1, -40, 0, 5)
				ValueLabel.Size = UDim2.new(0, 30, 0, 20)
				ValueLabel.Font = Enum.Font.Gotham
				ValueLabel.Text = tostring(Default)
				ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				ValueLabel.TextSize = 12.000

				Bar.Parent = SliderFrame
				Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				Bar.Position = UDim2.new(0, 10, 0, 30)
				Bar.Size = UDim2.new(1, -20, 0, 6)

				BarCorner.CornerRadius = UDim.new(0, 3)
				BarCorner.Parent = Bar

				Fill.Parent = Bar
				Fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
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
					TweenService:Create(Fill, TweenInfo.new(0.1), {Size = pos}):Play()
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

				Dropdown.Name = Name
				Dropdown.Parent = Container
				Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				Dropdown.Size = UDim2.new(1, 0, 0, 30)
				Dropdown.ClipsDescendants = true

				DropCorner.CornerRadius = UDim.new(0, 4)
				DropCorner.Parent = Dropdown

				DropBtn.Parent = Dropdown
				DropBtn.BackgroundTransparency = 1
				DropBtn.Size = UDim2.new(1, 0, 0, 30)
				DropBtn.Text = ""

				Title.Parent = DropBtn
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -30, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Default or Name
				Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left

				Arrow.Parent = DropBtn
				Arrow.BackgroundTransparency = 1
				Arrow.Position = UDim2.new(1, -25, 0.5, -10)
				Arrow.Size = UDim2.new(0, 20, 0, 20)
				Arrow.Image = "rbxassetid://6034818372"

				ListFrame.Parent = Dropdown
				ListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				ListFrame.BorderSizePixel = 0
				ListFrame.Position = UDim2.new(0, 0, 0, 35)
				ListFrame.Size = UDim2.new(1, 0, 0, 100)
				ListFrame.ScrollBarThickness = 2

				ListLayout.Parent = ListFrame
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Padding = UDim.new(0, 2)

				ListPadding.Parent = ListFrame
				ListPadding.PaddingLeft = UDim.new(0, 5)

				local Open = false
				
				local function RefreshList()
					for _, v in pairs(ListFrame:GetChildren()) do
						if v:IsA("TextButton") then v:Destroy() end
					end
					
					for _, item in pairs(List) do
						local ItemBtn = Instance.new("TextButton")
						ItemBtn.Parent = ListFrame
						ItemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
						ItemBtn.Size = UDim2.new(1, -5, 0, 25)
						ItemBtn.Font = Enum.Font.Gotham
						ItemBtn.Text = item
						ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
						ItemBtn.TextSize = 12
						ItemBtn.AutoButtonColor = false
						
						local ItemCorner = Instance.new("UICorner")
						ItemCorner.CornerRadius = UDim.new(0, 4)
						ItemCorner.Parent = ItemBtn
						
						ItemBtn.MouseButton1Click:Connect(function()
							Open = false
							Title.Text = item
							TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
							TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
							Callback(item)
						end)
					end
					ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5)
				end

				RefreshList()

				DropBtn.MouseButton1Click:Connect(function()
					Open = not Open
					if Open then
						TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 140)}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
					else
						TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
					end
				end)
			end
			
			function SectionFuncs:addKeybind(Name, Default, Callback)
				Callback = Callback or function() end
				local KeybindFrame = Instance.new("Frame")
				local KeyCorner = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local KeyBtn = Instance.new("TextButton")
				local KeyBtnCorner = Instance.new("UICorner")

				KeybindFrame.Name = Name
				KeybindFrame.Parent = Container
				KeybindFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				KeybindFrame.Size = UDim2.new(1, 0, 0, 30)

				KeyCorner.CornerRadius = UDim.new(0, 4)
				KeyCorner.Parent = KeybindFrame

				Title.Parent = KeybindFrame
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 10, 0, 0)
				Title.Size = UDim2.new(1, -80, 1, 0)
				Title.Font = Enum.Font.Gotham
				Title.Text = Name
				Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left

				KeyBtn.Parent = KeybindFrame
				KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				KeyBtn.Position = UDim2.new(1, -70, 0.5, -10)
				KeyBtn.Size = UDim2.new(0, 60, 0, 20)
				KeyBtn.Font = Enum.Font.Gotham
				KeyBtn.Text = Default and Default.Name or "None"
				KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
				KeyBtn.TextSize = 11

				KeyBtnCorner.CornerRadius = UDim.new(0, 4)
				KeyBtnCorner.Parent = KeyBtn

				local Listening = false

				KeyBtn.MouseButton1Click:Connect(function()
					Listening = true
					KeyBtn.Text = "..."
				end)

				UserInputService.InputBegan:Connect(function(Input)
					if Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
						Listening = false
						KeyBtn.Text = Input.KeyCode.Name
						Callback(Input.KeyCode)
					elseif Input.KeyCode == Default then
						Callback(Input.KeyCode)
					end
				end)
			end

			return SectionFuncs
		end
		
		return PageFuncs
	end
	return Window
end

return Library
