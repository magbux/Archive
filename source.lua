local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Archived = {}

local Settings = {
    Name = "Archived",
    Colors = {
        Main = Color3.fromRGB(18, 18, 18),
        Header = Color3.fromRGB(24, 24, 24),
        Container = Color3.fromRGB(30, 30, 30),
        Element = Color3.fromRGB(35, 35, 35),
        Hover = Color3.fromRGB(45, 45, 45),
        Active = Color3.fromRGB(55, 55, 55),
        Accent = Color3.fromRGB(155, 89, 182),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Outline = Color3.fromRGB(50, 50, 50),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Assets = {
        Close = "rbxassetid://3926305904",
        Min = "rbxassetid://3926305904",
        Search = "rbxassetid://6031154871",
        Arrow = "rbxassetid://6031090990",
        Check = "rbxassetid://6031048439",
        Glow = "rbxassetid://5028857472"
    }
}

local Utility = {}

function Utility:Class(className, properties)
    local instance = Instance.new(className)
    for i, v in pairs(properties) do
        instance[i] = v
    end
    return instance
end

function Utility:Tween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

function Utility:Ripple(object)
    task.spawn(function()
        local Ripple = Utility:Class("ImageLabel", {
            Name = "Ripple",
            Parent = object,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.6,
            ZIndex = 9
        })
        
        local x = Mouse.X - object.AbsolutePosition.X
        local y = Mouse.Y - object.AbsolutePosition.Y
        Ripple.Position = UDim2.new(0, x, 0, y)
        
        local size = math.max(object.AbsoluteSize.X, object.AbsoluteSize.Y) * 1.5
        
        Utility:Tween(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0, x - size/2, 0, y - size/2),
            ImageTransparency = 1
        })
        
        task.wait(0.55)
        Ripple:Destroy()
    end)
end

function Utility:Drag(topbar, object)
    local dragging = false
    local dragInput, dragStart, startPos

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
            local delta = input.Position - dragStart
            Utility:Tween(object, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

function Utility:Corner(parent, radius)
    return Utility:Class("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius)
    })
end

function Utility:Stroke(parent, color, thickness)
    return Utility:Class("UIStroke", {
        Parent = parent,
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

function Archived:Load(config)
    config = config or {}
    local Title = config.Title or "Archived"
    local Accent = config.Accent or Settings.Colors.Accent
    Settings.Colors.Accent = Accent

    local Core = Utility:Class("ScreenGui", {
        Name = "ArchivedLibrary",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    if gethui then
        Core.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(Core)
        Core.Parent = CoreGui
    else
        Core.Parent = CoreGui
    end

    local Main = Utility:Class("Frame", {
        Name = "Main",
        Parent = Core,
        BackgroundColor3 = Settings.Colors.Main,
        Position = UDim2.new(0.5, -325, 0.5, -200),
        Size = UDim2.new(0, 650, 0, 400),
        ClipsDescendants = false
    })
    Utility:Corner(Main, 6)
    
    local MainStroke = Utility:Stroke(Main, Settings.Colors.Outline, 1)

    local Shadow = Utility:Class("ImageLabel", {
        Name = "Shadow",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        Image = Settings.Assets.Glow,
        ImageColor3 = Settings.Colors.Shadow,
        ImageTransparency = 0.2,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 280, 280),
        ZIndex = -1
    })

    local Header = Utility:Class("Frame", {
        Name = "Header",
        Parent = Main,
        BackgroundColor3 = Settings.Colors.Header,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Utility:Corner(Header, 6)

    local HeaderCover = Utility:Class("Frame", {
        Name = "Cover",
        Parent = Header,
        BackgroundColor3 = Settings.Colors.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })

    Utility:Drag(Header, Main)

    local SearchArea = Utility:Class("Frame", {
        Name = "SearchArea",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 180, 1, 0)
    })

    local SearchIcon = Utility:Class("ImageLabel", {
        Name = "Icon",
        Parent = SearchArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Settings.Assets.Search,
        ImageColor3 = Settings.Colors.Accent
    })

    local TitleLabel = Utility:Class("TextLabel", {
        Name = "Title",
        Parent = SearchArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 0),
        Size = UDim2.new(1, -25, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = Settings.Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Controls = Utility:Class("Frame", {
        Name = "Controls",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 60, 1, 0)
    })

    local CloseBtn = Utility:Class("TextButton", {
        Name = "Close",
        Parent = Controls,
        BackgroundColor3 = Color3.fromRGB(255, 95, 87),
        Position = UDim2.new(1, -20, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        AutoButtonColor = false
    })
    Utility:Corner(CloseBtn, 12)

    local CloseIcon = Utility:Class("ImageLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 8, 0, 8),
        Image = Settings.Assets.Close,
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24),
        ImageTransparency = 1
    })

    local MinBtn = Utility:Class("TextButton", {
        Name = "Minimize",
        Parent = Controls,
        BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        Position = UDim2.new(1, -40, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        AutoButtonColor = false
    })
    Utility:Corner(MinBtn, 12)

    local Minimized = false

    CloseBtn.MouseEnter:Connect(function() Utility:Tween(CloseIcon, TweenInfo.new(0.2), {ImageTransparency = 0.5}) end)
    CloseBtn.MouseLeave:Connect(function() Utility:Tween(CloseIcon, TweenInfo.new(0.2), {ImageTransparency = 1}) end)
    CloseBtn.MouseButton1Click:Connect(function() Core:Destroy() end)

    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Utility:Tween(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 40)})
        else
            Utility:Tween(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 400)})
        end
    end)

    local TabContainer = Utility:Class("Frame", {
        Name = "Tabs",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -270, 1, 0)
    })

    local TabList = Utility:Class("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    local PageContainer = Utility:Class("Frame", {
        Name = "Pages",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 50),
        Size = UDim2.new(1, -30, 1, -60),
        ClipsDescendants = true
    })

    local NotifyHolder = Utility:Class("Frame", {
        Name = "NotifyHolder",
        Parent = Core,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -50),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(0, 1)
    })

    local NotifyList = Utility:Class("UIListLayout", {
        Parent = NotifyHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8)
    })

    function Archived:Notify(title, text, duration)
        local Toast = Utility:Class("Frame", {
            Parent = NotifyHolder,
            BackgroundColor3 = Settings.Colors.Header,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Utility:Corner(Toast, 4)
        local ToastStroke = Utility:Stroke(Toast, Settings.Colors.Outline, 1)
        ToastStroke.Transparency = 1

        local TTitle = Utility:Class("TextLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Settings.Colors.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })

        local TText = Utility:Class("TextLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -20, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Settings.Colors.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 1
        })
        
        local Pad = Utility:Class("UIPadding", {
            Parent = Toast,
            PaddingBottom = UDim.new(0, 10)
        })

        Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})
        Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 0})
        Utility:Tween(TTitle, TweenInfo.new(0.5), {TextTransparency = 0})
        Utility:Tween(TText, TweenInfo.new(0.5), {TextTransparency = 0})

        task.delay(duration or 3, function()
            Utility:Tween(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
            Utility:Tween(ToastStroke, TweenInfo.new(0.5), {Transparency = 1})
            Utility:Tween(TTitle, TweenInfo.new(0.5), {TextTransparency = 1})
            Utility:Tween(TText, TweenInfo.new(0.5), {TextTransparency = 1})
            task.wait(0.5)
            Toast:Destroy()
        end)
    end

    local Windows = {}
    local FirstTab = true

    function Windows:Tab(name, icon)
        local TabBtn = Utility:Class("TextButton", {
            Name = name,
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Settings.Colors.SubText,
            TextSize = 13
        })
        
        local TabIcon
        local PadLeft = 0
        if icon then
            PadLeft = 25
            TabIcon = Utility:Class("ImageLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -22, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = icon,
                ImageColor3 = Settings.Colors.SubText
            })
        end
        
        local Pad = Utility:Class("UIPadding", {
            Parent = TabBtn,
            PaddingLeft = UDim.new(0, PadLeft)
        })

        local Indicator = Utility:Class("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Settings.Colors.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(0, 0, 0, 2)
        })

        local Page = Utility:Class("ScrollingFrame", {
            Name = name,
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 0,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local PageList = Utility:Class("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        local PagePad = Utility:Class("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        local function Activate()
            for _, v in pairs(PageContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, TweenInfo.new(0.3), {TextColor3 = Settings.Colors.SubText})
                    Utility:Tween(v.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2)})
                    if v:FindFirstChild("ImageLabel") then
                        Utility:Tween(v.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Settings.Colors.SubText})
                    end
                end
            end
            
            Page.Visible = true
            Utility:Tween(TabBtn, TweenInfo.new(0.3), {TextColor3 = Settings.Colors.Text})
            Utility:Tween(Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 2)})
            if TabIcon then
                Utility:Tween(TabIcon, TweenInfo.new(0.3), {ImageColor3 = Settings.Colors.Text})
            end
            
            Page.Position = UDim2.new(0, 0, 0, 20)
            Page.CanvasGroupTransparency = 1 
            Utility:Tween(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0), CanvasGroupTransparency = 0})
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        local Elements = {}

        function Elements:Section(name)
            local SectionFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            local Text = Utility:Class("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -5, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Settings.Colors.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function Elements:Label(text)
            local LabelFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Utility:Corner(LabelFrame, 6)
            local Stroke = Utility:Stroke(LabelFrame, Settings.Colors.Outline, 1)

            local LText = Utility:Class("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function Elements:Button(name, callback)
            local ButtonFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38)
            })
            Utility:Corner(ButtonFrame, 6)
            local Stroke = Utility:Stroke(ButtonFrame, Settings.Colors.Outline, 1)

            local Btn = Utility:Class("TextButton", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13
            })

            Btn.MouseEnter:Connect(function()
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Colors.Hover})
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent})
            end)

            Btn.MouseLeave:Connect(function()
                Utility:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Colors.Element})
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline})
            end)

            Btn.MouseButton1Click:Connect(function()
                Utility:Ripple(Btn)
                callback()
            end)
        end

        function Elements:Toggle(name, default, callback)
            local ToggleFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38)
            })
            Utility:Corner(ToggleFrame, 6)
            local Stroke = Utility:Stroke(ToggleFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Switch = Utility:Class("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Settings.Colors.Container,
                Position = UDim2.new(1, -50, 0.5, -11),
                Size = UDim2.new(0, 40, 0, 22)
            })
            Utility:Corner(Switch, 11)

            local Knob = Utility:Class("Frame", {
                Parent = Switch,
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                Position = UDim2.new(0, 2, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18)
            })
            Utility:Corner(Knob, 9)

            local Btn = Utility:Class("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local State = default or false

            local function Update()
                if State then
                    Utility:Tween(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Settings.Colors.Accent})
                    Utility:Tween(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255)})
                else
                    Utility:Tween(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Settings.Colors.Container})
                    Utility:Tween(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(200,200,200)})
                end
                callback(State)
            end
            Update()

            Btn.MouseEnter:Connect(function()
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent})
            end)
            Btn.MouseLeave:Connect(function()
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline})
            end)

            Btn.MouseButton1Click:Connect(function()
                State = not State
                Utility:Ripple(Btn)
                Update()
            end)
        end

        function Elements:Slider(name, min, max, default, callback)
            local SliderFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Utility:Corner(SliderFrame, 6)
            local Stroke = Utility:Stroke(SliderFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Value = Utility:Class("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = tostring(default),
                TextColor3 = Settings.Colors.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local Track = Utility:Class("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Settings.Colors.Container,
                Position = UDim2.new(0, 10, 0, 32),
                Size = UDim2.new(1, -20, 0, 6)
            })
            Utility:Corner(Track, 3)

            local Fill = Utility:Class("Frame", {
                Parent = Track,
                BackgroundColor3 = Settings.Colors.Accent,
                Size = UDim2.new(0, 0, 1, 0)
            })
            Utility:Corner(Fill, 3)

            local Interact = Utility:Class("TextButton", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            Interact.MouseEnter:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent}) end)
            Interact.MouseLeave:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline}) end)

            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ((max - min) * pos))
                Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)})
                Value.Text = tostring(val)
                callback(val)
            end

            local p = (default - min) / (max - min)
            Fill.Size = UDim2.new(p, 0, 1, 0)

            Interact.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)

            Interact.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end

        function Elements:Dropdown(name, items, callback)
            local DropFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true
            })
            Utility:Corner(DropFrame, 6)
            local Stroke = Utility:Stroke(DropFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 0, 38),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Icon = Utility:Class("ImageLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 9),
                Size = UDim2.new(0, 20, 0, 20),
                Image = Settings.Assets.Arrow,
                ImageColor3 = Settings.Colors.SubText,
                Rotation = 90
            })

            local Interact = Utility:Class("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = ""
            })

            local ItemHolder = Utility:Class("ScrollingFrame", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 100),
                ScrollBarThickness = 0
            })

            local Layout = Utility:Class("UIListLayout", {
                Parent = ItemHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local Pad = Utility:Class("UIPadding", {
                Parent = ItemHolder,
                PaddingTop = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5)
            })

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ItemHolder.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
            end)

            local Open = false

            Interact.MouseEnter:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent}) end)
            Interact.MouseLeave:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline}) end)

            Interact.MouseButton1Click:Connect(function()
                Open = not Open
                if Open then
                    local count = math.min(#items, 5)
                    Utility:Tween(DropFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 45 + (count * 28))})
                    Utility:Tween(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Rotation = 0})
                else
                    Utility:Tween(DropFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 38)})
                    Utility:Tween(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Rotation = 90})
                end
            end)

            for _, item in pairs(items) do
                local ItemBtn = Utility:Class("TextButton", {
                    Parent = ItemHolder,
                    BackgroundColor3 = Settings.Colors.Container,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = item,
                    TextColor3 = Settings.Colors.SubText,
                    TextSize = 12
                })
                Utility:Corner(ItemBtn, 4)

                ItemBtn.MouseEnter:Connect(function()
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Colors.Accent, TextColor3 = Color3.new(1,1,1)})
                end)
                ItemBtn.MouseLeave:Connect(function()
                    Utility:Tween(ItemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Colors.Container, TextColor3 = Settings.Colors.SubText})
                end)

                ItemBtn.MouseButton1Click:Connect(function()
                    Open = false
                    Text.Text = name .. ": " .. item
                    Utility:Tween(DropFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 38)})
                    Utility:Tween(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Rotation = 90})
                    callback(item)
                end)
            end
        end

        function Elements:Textbox(name, placeholder, callback)
            local BoxFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38)
            })
            Utility:Corner(BoxFrame, 6)
            local Stroke = Utility:Stroke(BoxFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = BoxFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Input = Utility:Class("TextBox", {
                Parent = BoxFrame,
                BackgroundColor3 = Settings.Colors.Container,
                Position = UDim2.new(1, -160, 0.5, -12),
                Size = UDim2.new(0, 150, 0, 24),
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = placeholder,
                TextColor3 = Settings.Colors.Text,
                TextSize = 12
            })
            Utility:Corner(Input, 4)

            Input.Focused:Connect(function()
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent})
                Utility:Tween(Input, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end)
            
            Input.FocusLost:Connect(function()
                Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline})
                Utility:Tween(Input, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Colors.Container})
                callback(Input.Text)
            end)
        end

        function Elements:ColorPicker(name, default, callback)
            local CPFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true
            })
            Utility:Corner(CPFrame, 6)
            local Stroke = Utility:Stroke(CPFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = CPFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.5, 0, 0, 38),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Preview = Utility:Class("TextButton", {
                Parent = CPFrame,
                BackgroundColor3 = default,
                Position = UDim2.new(1, -50, 0.5, -9),
                Size = UDim2.new(0, 40, 0, 18),
                Text = "",
                AutoButtonColor = false
            })
            Utility:Corner(Preview, 4)

            local Interact = Utility:Class("TextButton", {
                Parent = CPFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = ""
            })

            local Container = Utility:Class("Frame", {
                Parent = CPFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 45),
                Size = UDim2.new(1, -20, 0, 120)
            })

            local SV = Utility:Class("ImageLabel", {
                Parent = Container,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 140, 0, 110),
                Image = "rbxassetid://4155801252"
            })
            Utility:Corner(SV, 4)

            local Hue = Utility:Class("ImageLabel", {
                Parent = Container,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 150, 0, 0),
                Size = UDim2.new(1, -150, 0, 110),
                Image = "rbxassetid://4155801252",
                ScaleType = Enum.ScaleType.Stretch
            })
            Utility:Corner(Hue, 4)
            
            local HueGrad = Utility:Class("UIGradient", {
                Parent = Hue,
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                })
            })

            local RainbowBtn = Utility:Class("TextButton", {
                Parent = Container,
                BackgroundColor3 = Settings.Colors.Container,
                Position = UDim2.new(0, 0, 1, 10),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = "Rainbow Mode",
                TextColor3 = Settings.Colors.SubText,
                TextSize = 12
            })
            Utility:Corner(RainbowBtn, 4)

            local SVCursor = Utility:Class("Frame", {
                Parent = SV,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0, 4, 0, 4),
                Rotation = 45
            })
            Utility:Stroke(SVCursor, Color3.new(0,0,0), 1)

            local HueCursor = Utility:Class("Frame", {
                Parent = Hue,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(1, 0, 0, 2),
                BorderSizePixel = 0
            })

            local h, s, v = Color3.toHSV(default)
            local rainbow = false
            local rainbowConn

            local function Update()
                local color = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = color
                SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                callback(color)
            end

            local draggingHue, draggingSV = false, false

            Hue.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end
            end)
            SV.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false draggingSV = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingHue and not rainbow then
                        local y = math.clamp((input.Position.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
                        HueCursor.Position = UDim2.new(0, 0, y, 0)
                        h = 1 - y
                        Update()
                    end
                    if draggingSV and not rainbow then
                        local x = math.clamp((input.Position.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((input.Position.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                        SVCursor.Position = UDim2.new(x, -2, y, -2)
                        s = x
                        v = 1 - y
                        Update()
                    end
                end
            end)

            RainbowBtn.MouseButton1Click:Connect(function()
                rainbow = not rainbow
                if rainbow then
                    Utility:Tween(RainbowBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Colors.Accent})
                    rainbowConn = RunService.RenderStepped:Connect(function()
                        h = (tick() % 5) / 5
                        Update()
                        HueCursor.Position = UDim2.new(0, 0, 1 - h, 0)
                    end)
                else
                    Utility:Tween(RainbowBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Colors.SubText})
                    if rainbowConn then rainbowConn:Disconnect() end
                end
            end)

            local Open = false
            Interact.MouseButton1Click:Connect(function()
                Open = not Open
                if Open then
                    Utility:Tween(CPFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 210)})
                else
                    Utility:Tween(CPFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 38)})
                end
            end)
            
            Interact.MouseEnter:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent}) end)
            Interact.MouseLeave:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline}) end)
        end

        function Elements:Keybind(name, default, callback)
             local KeyFrame = Utility:Class("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Colors.Element,
                Size = UDim2.new(1, 0, 0, 38)
            })
            Utility:Corner(KeyFrame, 6)
            local Stroke = Utility:Stroke(KeyFrame, Settings.Colors.Outline, 1)

            local Text = Utility:Class("TextLabel", {
                Parent = KeyFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = Settings.Colors.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BindBtn = Utility:Class("TextButton", {
                Parent = KeyFrame,
                BackgroundColor3 = Settings.Colors.Container,
                Position = UDim2.new(1, -90, 0.5, -10),
                Size = UDim2.new(0, 80, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = (default and default.Name) or "None",
                TextColor3 = Settings.Colors.SubText,
                TextSize = 11
            })
            Utility:Corner(BindBtn, 4)

            local listening = false

            BindBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                BindBtn.Text = "..."
                Utility:Tween(BindBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Colors.Accent})
                
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        callback(input.KeyCode)
                        BindBtn.Text = input.KeyCode.Name
                        Utility:Tween(BindBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Colors.SubText})
                        listening = false
                        conn:Disconnect()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        listening = false
                        BindBtn.Text = "None"
                        Utility:Tween(BindBtn, TweenInfo.new(0.2), {TextColor3 = Settings.Colors.SubText})
                        conn:Disconnect()
                    end
                end)
            end)
            
            BindBtn.MouseEnter:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Accent}) end)
            BindBtn.MouseLeave:Connect(function() Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Settings.Colors.Outline}) end)
        end

        return Elements
    end

    local SearchOpen = false
    SearchIcon.Parent.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            SearchOpen = not SearchOpen
            if SearchOpen then
                TitleLabel.Visible = false
                local Box = Utility:Class("TextBox", {
                    Parent = SearchArea,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 25, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Search...",
                    TextColor3 = Settings.Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Box:CaptureFocus()
                
                Box:GetPropertyChangedSignal("Text"):Connect(function()
                    local txt = Box.Text:lower()
                    if PageContainer:FindFirstChildOfClass("ScrollingFrame") and PageContainer:FindFirstChildOfClass("ScrollingFrame").Visible then
                        local activePage = nil
                        for _, v in pairs(PageContainer:GetChildren()) do if v.Visible then activePage = v end end
                        if activePage then
                            for _, v in pairs(activePage:GetChildren()) do
                                if v:IsA("Frame") then
                                    local label = v:FindFirstChild("TextLabel")
                                    if label and string.find(label.Text:lower(), txt) then
                                        v.Visible = true
                                    else
                                        v.Visible = false
                                    end
                                end
                            end
                        end
                    end
                end)

                Box.FocusLost:Connect(function()
                    if Box.Text == "" then
                        Box:Destroy()
                        TitleLabel.Visible = true
                        SearchOpen = false
                    end
                end)
            end
        end
    end)

    return Windows
end

return Archived
