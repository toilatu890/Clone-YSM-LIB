local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI_WIDTH = 210
local COLOR_BG = Color3.fromRGB(0, 0, 0)
local COLOR_RED = Color3.fromRGB(255, 0, 0)
local COLOR_GREEN = Color3.fromRGB(0, 255, 0)
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_TAB_INACTIVE = Color3.fromRGB(30, 30, 30)
local COLOR_TAB_ACTIVE = Color3.fromRGB(0, 0, 0)

local YSM = {}
YSM.__index = YSM

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
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
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

function YSM.new(title)
    local self = setmetatable({}, YSM)
    local targetParent
    local success = pcall(function() targetParent = CoreGui end)
    if not success then targetParent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    self.ScreenGui = Create("ScreenGui", {
        Name = "YSM_Mobile_Fixed",
        Parent = targetParent,
        ResetOnSpawn = false
    })

    self.MainFrame = Create("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = COLOR_BG,
        Position = UDim2.new(0.5, -UI_WIDTH/2, 0.5, -135),
        Size = UDim2.new(0, UI_WIDTH, 0, 270),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = self.MainFrame, CornerRadius = UDim.new(0, 4)})

    self.Header = Create("Frame", {
        Parent = self.MainFrame,
        BackgroundColor3 = COLOR_BG,
        Size = UDim2.new(1, 0, 0, 30),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = self.Header, CornerRadius = UDim.new(0, 4)})

    self.ToggleMenuBtn = Create("TextButton", {
        Parent = self.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = COLOR_WHITE,
        TextSize = 13
    })

    self.Title = Create("TextLabel", {
        Parent = self.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "TuX TEAM V4.5",
        TextColor3 = COLOR_WHITE,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    MakeDraggable(self.Header, self.MainFrame)

    self.TabBar = Create("ScrollingFrame", {
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 30),
        Size = UDim2.new(1, -10, 0, 25),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        BorderSizePixel = 0
    })
    Create("UIListLayout", {
        Parent = self.TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    self.ContentContainer = Create("Frame", {
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -55),
        BorderSizePixel = 0
    })

    self.Tabs = {}
    self.TabButtons = {}
    self.IsCollapsed = false
    self.OriginalHeight = 270

    self.ToggleMenuBtn.MouseButton1Click:Connect(function()
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, UI_WIDTH, 0, 30)}):Play()
            self.ToggleMenuBtn.Text = "▶"
        else
            TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, UI_WIDTH, 0, self.OriginalHeight)}):Play()
            self.ToggleMenuBtn.Text = "▼"
        end
    end)

    return self
end

function YSM:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

function YSM:Tab(name)
    local tabBtn = Create("TextButton", {
        Parent = self.TabBar,
        BackgroundColor3 = COLOR_TAB_INACTIVE,
        Size = UDim2.new(0, 40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = COLOR_TAB_INACTIVE,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.X
    })
    Create("UIPadding", {Parent = tabBtn, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
    Create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 3)})

    local tabPage = Create("ScrollingFrame", {
        Parent = self.ContentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        Visible = false
    })
    Create("UIPadding", {
        Parent = tabPage,
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    Create("UIListLayout", {
        Parent = tabPage,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    table.insert(self.Tabs, tabPage)
    table.insert(self.TabButtons, tabBtn)

    tabBtn.MouseButton1Click:Connect(function()
        for _, page in pairs(self.Tabs) do page.Visible = false end
        for _, btn in pairs(self.TabButtons) do
            btn.BackgroundColor3 = COLOR_TAB_INACTIVE
            btn.TextColor3 = COLOR_TAB_INACTIVE
        end
        tabPage.Visible = true
        tabBtn.BackgroundColor3 = COLOR_TAB_ACTIVE
        tabBtn.TextColor3 = COLOR_WHITE
    end)

    if #self.Tabs == 1 then
        tabPage.Visible = true
        tabBtn.BackgroundColor3 = COLOR_TAB_ACTIVE
        tabBtn.TextColor3 = COLOR_WHITE
    end

    local TabHandler = {}

    function TabHandler:Label(text, color)
        Create("TextLabel", {
            Parent = tabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = color or COLOR_RED,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    function TabHandler:Toggle(text, default, callback)
        local state = default or false
        local btn = Create("TextButton", {
            Parent = tabPage,
            BackgroundColor3 = state and COLOR_GREEN or COLOR_RED,
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = text:upper(),
            TextColor3 = COLOR_WHITE,
            TextSize = 12
        })
        Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 3)})

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and COLOR_GREEN or COLOR_RED
            pcall(callback, state)
        end)
    end

    function TabHandler:Button(text, callback)
        local btn = Create("TextButton", {
            Parent = tabPage,
            BackgroundColor3 = COLOR_RED,
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = text:upper(),
            TextColor3 = COLOR_WHITE,
            TextSize = 12
        })
        Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 3)})

        btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    function TabHandler:Slider(text, min, max, default, callback)
        local val = default or min
        local btn = Create("TextButton", {
            Parent = tabPage,
            BackgroundColor3 = COLOR_BG,
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 3)})

        local fillLine = Create("Frame", {
            Parent = btn,
            BackgroundColor3 = COLOR_WHITE,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 2, 0, 16),
            Position = UDim2.new((val - min) / (max - min), -1, 0.5, -8)
        })

        local valText = Create("TextLabel", {
            Parent = btn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = text .. ": " .. string.format("%.2f", val),
            TextColor3 = COLOR_WHITE,
            TextSize = 12
        })

        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
            val = min + (max - min) * pos
            fillLine.Position = UDim2.new(pos, -1, 0.5, -8)
            valText.Text = text .. ": " .. string.format("%.2f", val)
            pcall(callback, val)
        end

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end

    function TabHandler:TimeKey(timeStr)
        local frame = Create("Frame", {
            Parent = tabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38)
        })
        Create("UIListLayout", {Parent = frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
        Create("TextLabel", {
            Parent = frame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = "Time Key",
            TextColor3 = COLOR_RED,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("TextLabel", {
            Parent = frame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = timeStr,
            TextColor3 = COLOR_GREEN,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    function TabHandler:Dropdown(label, options, callback)
        local container = Create("Frame", {
            Parent = tabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            ClipsDescendants = true
        })

        local titleLbl = Create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = label,
            TextColor3 = COLOR_WHITE,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local mainBtn = Create("TextButton", {
            Parent = container,
            BackgroundColor3 = COLOR_TAB_INACTIVE,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = options[1] .. "  ▼",
            TextColor3 = COLOR_WHITE,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UIPadding", {Parent = mainBtn, PaddingLeft = UDim.new(0, 5)})
        Create("UICorner", {Parent = mainBtn, CornerRadius = UDim.new(0, 3)})

        local dropList = Create("Frame", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 1, -50)
        })
        Create("UIListLayout", {Parent = dropList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

        local isOpen = false
        mainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                container.Size = UDim2.new(1, 0, 0, 48 + (#options * 28))
            else
                container.Size = UDim2.new(1, 0, 0, 48)
            end
        end)

        for _, opt in ipairs(options) do
            local optBtn = Create("TextButton", {
                Parent = dropList,
                BackgroundColor3 = COLOR_BG,
                Size = UDim2.new(1, 0, 0, 26),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Text = opt,
                TextColor3 = COLOR_WHITE,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = optBtn, PaddingLeft = UDim.new(0, 5)})
            Create("UICorner", {Parent = optBtn, CornerRadius = UDim.new(0, 3)})

            optBtn.MouseButton1Click:Connect(function()
                mainBtn.Text = opt .. "  ▼"
                isOpen = false
                container.Size = UDim2.new(1, 0, 0, 48)
                pcall(callback, opt)
            end)
        end
    end

    return TabHandler
end

return YSM
