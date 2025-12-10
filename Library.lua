-- c00lgui-style UI Library (Extended) - Safe UI only
-- Usage: local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/ui.lua"))()
-- Author: generated for you
-- Features:
-- Window with drag, pages (< >), grid layout
-- Button, Toggle, Slider (numeric), Dropdown, Textbox, Keybind, Separator, Label
-- Elements produce callbacks and return handles to change state

local library = {}
library.__index = library

-- ======= Utilities =======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local function Create(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    return inst
end

local function clamp(n, a, b) if n < a then return a end if n > b then return b end return n end
local function round(n) return math.floor(n + 0.5) end

local RED = Color3.fromRGB(255,0,0)
local BG = Color3.fromRGB(0,0,0)
local TXT = Color3.fromRGB(255,255,255)
local BORDER = RED

-- ======= Core Window Creator =======
function library:CreateWindow(title, opts)
    opts = opts or {}
    local self = setmetatable({}, library)

    -- ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = opts.Name or "c00lgui_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = (opts.Parent or game.CoreGui)
    })

    -- MAIN FRAME
    local Main = Create("Frame", {
        Name = "Main",
        Parent = screenGui,
        Size = UDim2.new(0, 420, 0, 450),
        Position = UDim2.new(0.5, -210, 0.5, -225),
        BackgroundColor3 = BG,
        BorderColor3 = BORDER,
        BorderSizePixel = 2,
        Active = true
    })

    -- Titlebar
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = BG,
        BorderColor3 = BORDER,
        BorderSizePixel = 2,
        Text = title or "c00lgui Reborn",
        TextColor3 = TXT,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    -- Page arrows and label
    local ArrowLeft = Create("TextButton", {
        Parent = Main,
        Name = "ArrowLeft",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundColor3 = BG,
        BorderColor3 = BORDER,
        BorderSizePixel = 2,
        Text = "<",
        TextColor3 = TXT,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })
    local ArrowRight = Create("TextButton", {
        Parent = Main,
        Name = "ArrowRight",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -32, 0, 0),
        BackgroundColor3 = BG,
        BorderColor3 = BORDER,
        BorderSizePixel = 2,
        Text = ">",
        TextColor3 = TXT,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })
    local PageLabel = Create("TextLabel", {
        Parent = Main,
        Name = "PageLabel",
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(0.5, -60, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = TXT,
        Text = "Page 1 / 1",
        Font = Enum.Font.SourceSans,
        TextSize = 14
    })

    -- Content frame and pages container
    local Content = Create("Frame", {
        Parent = Main,
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1
    })

    local PagesContainer = Create("Frame", {
        Parent = Content,
        Name = "Pages",
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Parent = Main,
        Name = "Close",
        Size = UDim2.new(1,0,0,35),
        Position = UDim2.new(0,0,1,-35),
        BackgroundColor3 = BG,
        BorderColor3 = BORDER,
        BorderSizePixel = 2,
        Text = "Close",
        TextColor3 = TXT,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })

    CloseBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Dragging (only when clicking Title)
    do
        local dragging = false
        local dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        Title.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        Title.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    -- internal state
    self._screenGui = screenGui
    self._main = Main
    self._pagesContainer = PagesContainer
    self._pages = {} -- list of pages {frame, name, elements = {}}
    self._currentPage = 1

    -- ===== Page System =====
    function self:AddPage(name)
        name = name or ("Page "..(#self._pages + 1))
        local pageFrame = Create("Frame", {
            Parent = PagesContainer,
            Name = "Page_"..#self._pages+1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0)
        })

        -- Scrolling container inside page
        local scroll = Create("ScrollingFrame", {
            Parent = pageFrame,
            Name = "Scroll",
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 6,
            BackgroundTransparency = 1,
            VerticalScrollBarInset = Enum.ScrollBarInset.Always
        })
        local grid = Create("UIGridLayout", {
            Parent = scroll,
            CellSize = UDim2.new(0, 200, 0, 36),
            FillDirectionMaxCells = 2,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0,6)
        })

        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local s = grid.AbsoluteContentSize
            scroll.CanvasSize = UDim2.new(0,0,s.Y + 8)
        end)

        local page = {
            name = name,
            frame = pageFrame,
            scroll = scroll,
            grid = grid,
            elements = {}
        }
        table.insert(self._pages, page)
        self:_updatePageLabel()
        self:_showPage(#self._pages)
        return page
    end

    function self:_updatePageLabel()
        PageLabel.Text = ("Page %d / %d"):format(self._currentPage, #self._pages)
    end

    function self:_showPage(index)
        if #self._pages == 0 then return end
        index = clamp(index, 1, #self._pages)
        for i, p in ipairs(self._pages) do
            p.frame.Visible = (i == index)
        end
        self._currentPage = index
        self:_updatePageLabel()
    end

    ArrowLeft.MouseButton1Click:Connect(function()
        local i = self._currentPage - 1
        if i < 1 then i = #self._pages end
        self:_showPage(i)
    end)
    ArrowRight.MouseButton1Click:Connect(function()
        local i = self._currentPage + 1
        if i > #self._pages then i = 1 end
        self:_showPage(i)
    end)

    -- Create initial page if none
    if #self._pages == 0 then self:AddPage("Main") end

    -- ====== Elements Factories ======
    -- Common element style helper
    local function baseButton(parent, text)
        local b = Create("TextButton", {
            Parent = parent,
            Size = UDim2.new(0,200,0,36),
            BackgroundColor3 = BG,
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            Text = text or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 16,
            AutoButtonColor = false
        })
        return b
    end

    -- Button
    function self:AddButton(text, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local b = baseButton(page.scroll, text)
        b.MouseButton1Click:Connect(function() pcall(callback) end)
        local element = {type="button", instance=b}
        table.insert(page.elements, element)
        return element
    end

    -- Label (non-interactive)
    function self:AddLabel(text, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local lbl = Create("TextLabel", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSansSemibold,
            TextSize = 16
        })
        local element = {type="label", instance=lbl}
        table.insert(page.elements, element)
        return element
    end

    -- Separator (thin line)
    function self:AddSeparator(text, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local frame = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local line = Create("Frame", {
            Parent = frame,
            Size = UDim2.new(1,-10,0,2),
            Position = UDim2.new(0,5,0,17),
            BackgroundColor3 = BORDER,
            BorderSizePixel = 0
        })
        local lbl = Create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0,10,0,0),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 12
        })
        local element = {type="separator", instance=frame}
        table.insert(page.elements, element)
        return element
    end

    -- Toggle (with indicator)
    function self:AddToggle(text, default, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local container = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local b = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = BG,
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            Text = text or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 16,
            AutoButtonColor = false
        })
        local indicator = Create("Frame", {
            Parent = container,
            Size = UDim2.new(0,24,0,24),
            Position = UDim2.new(1, -28, 0, 6),
            BackgroundColor3 = Color3.fromRGB(40,40,40),
            BorderColor3 = BORDER,
            BorderSizePixel = 2
        })
        local state = default and true or false
        local check = Create("Frame", {
            Parent = indicator,
            Size = state and UDim2.new(1,0,1,0) or UDim2.new(0,0,1,0),
            BackgroundColor3 = BORDER,
            BorderSizePixel = 0
        })

        local function set(val)
            state = not not val
            if state then
                check:TweenSize(UDim2.new(1,0,1,0),"Out","Quad",0.15,true)
            else
                check:TweenSize(UDim2.new(0,0,1,0),"Out","Quad",0.15,true)
            end
            pcall(callback, state)
        end

        b.MouseButton1Click:Connect(function()
            set(not state)
        end)

        local element = {
            type="toggle",
            instance=container,
            get = function() return state end,
            set = set
        }
        table.insert(page.elements, element)
        return element
    end

    -- Slider
    function self:AddSlider(text, min, max, default, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        min = min or 0; max = max or 100
        default = default or min
        local value = clamp(default, min, max)

        local frame = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local label = Create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1,0,0,16),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            Text = (text or "Slider").." : "..tostring(value),
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local bar = Create("Frame", {
            Parent = frame,
            Size = UDim2.new(1, -10, 0, 12),
            Position = UDim2.new(0,5,0,20),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderColor3 = BORDER,
            BorderSizePixel = 2
        })
        local fill = Create("Frame", {
            Parent = bar,
            Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
            BackgroundColor3 = BORDER,
            BorderSizePixel = 0
        })

        local dragging = false
        local connection

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                connection = RunService.RenderStepped:Connect(function()
                    local absPos = bar.AbsolutePosition.X
                    local absSize = bar.AbsoluteSize.X
                    local mouseX = UserInputService:GetMouseLocation().X
                    local x = clamp(mouseX - absPos, 0, absSize)
                    local newVal = min + (max - min) * (x / absSize)
                    newVal = math.floor(newVal + 0.5)
                    value = newVal
                    label.Text = (text or "Slider").." : "..tostring(value)
                    fill.Size = UDim2.new(x/absSize, 0, 1, 0)
                    pcall(callback, value)
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if connection then connection:Disconnect() connection = nil end
                    end
                end)
            end
        end)

        local element = {
            type="slider",
            instance=frame,
            get = function() return value end,
            set = function(v)
                value = clamp(v, min, max)
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = (text or "Slider").." : "..tostring(value)
                pcall(callback, value)
            end
        }
        table.insert(page.elements, element)
        return element
    end

    -- Dropdown
    function self:AddDropdown(text, options, defaultIndex, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        options = options or {}
        local selected = defaultIndex and options[defaultIndex] or options[1] or nil

        local container = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local mainBtn = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = BG,
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            Text = (text or "Dropdown")..": "..(selected or "None"),
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        })
        local list = Create("Frame", {
            Parent = container,
            Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(0,0,1,2),
            BackgroundColor3 = BG,
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            ClipsDescendants = true,
            Visible = false
        })
        local uiList = Create("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder})
        local function refreshList()
            for _, ch in pairs(list:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for i, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Parent = list,
                    Size = UDim2.new(1,0,0,28),
                    BackgroundTransparency = 1,
                    Text = tostring(opt),
                    TextColor3 = TXT,
                    Font = Enum.Font.SourceSans,
                    TextSize = 14,
                    AutoButtonColor = false
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    mainBtn.Text = (text or "Dropdown")..": "..tostring(selected)
                    list.Visible = false
                    pcall(callback, selected, i)
                end)
            end
            local total = #options * 28
            list.Size = UDim2.new(1,0,0, math.min(total, 28*5))
        end
        refreshList()

        mainBtn.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
        end)

        local element = {
            type="dropdown",
            instance=container,
            get = function() return selected end,
            set = function(v)
                selected = v
                mainBtn.Text = (text or "Dropdown")..": "..tostring(selected)
                pcall(callback, selected)
            end,
            options = options,
            refresh = function(newOptions)
                options = newOptions or {}
                refreshList()
            end
        }
        table.insert(page.elements, element)
        return element
    end

    -- Textbox
    function self:AddTextbox(labelText, placeholder, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local frame = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local lbl = Create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(0.45,0,1,0),
            BackgroundTransparency = 1,
            Text = labelText or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local tb = Create("TextBox", {
            Parent = frame,
            Size = UDim2.new(0.55, -6, 1, 0),
            Position = UDim2.new(0.45,6,0,0),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            Text = "",
            PlaceholderText = placeholder or "",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14
        })
        tb.ClearTextOnFocus = false
        tb.FocusLost:Connect(function(enterPressed)
            pcall(callback, tb.Text, enterPressed)
        end)
        local element = {
            type="textbox",
            instance=frame,
            get = function() return tb.Text end,
            set = function(v) tb.Text = tostring(v) end
        }
        table.insert(page.elements, element)
        return element
    end

    -- Keybind
    function self:AddKeybind(labelText, defaultKey, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        local frame = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local lbl = Create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(0.55,0,1,0),
            BackgroundTransparency = 1,
            Text = labelText or "Keybind",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local btn = Create("TextButton", {
            Parent = frame,
            Size = UDim2.new(0.45, -6, 1, 0),
            Position = UDim2.new(0.55,6,0,0),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderColor3 = BORDER,
            BorderSizePixel = 2,
            Text = defaultKey or "None",
            TextColor3 = TXT,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        })

        local waiting = false
        local key = defaultKey

        local conn
        btn.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting = true
            btn.Text = "Press a key..."
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode.Name
                    btn.Text = key
                    waiting = false
                    if conn then conn:Disconnect(); conn = nil end
                    pcall(callback, key)
                end
            end)
        end)

        -- Fire callback when key pressed
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                if tostring(inp.KeyCode.Name) == tostring(key) then
                    pcall(callback, key)
                end
            end
        end)

        local element = {
            type="keybind",
            instance=frame,
            get = function() return key end,
            set = function(k) key = k; btn.Text = tostring(k) end,
            _disconnect = function()
                if keyConn then keyConn:Disconnect(); keyConn = nil end
            end
        }
        table.insert(page.elements, element)
        return element
    end

    -- Dynamic "table-like" generator (create grid of buttons by labels)
    function self:AddGrid(labels, perRow, callback, pageIndex)
        pageIndex = pageIndex or self._currentPage
        local page = self._pages[pageIndex]
        perRow = perRow or 2
        local container = Create("Frame", {
            Parent = page.scroll,
            Size = UDim2.new(0,200,0,36),
            BackgroundTransparency = 1
        })
        local gridFrame = Create("Frame", {
            Parent = container,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1
        })
        local uiGrid = Create("UIGridLayout", {
            Parent = gridFrame,
            CellSize = UDim2.new(0, (200 - (perRow-1)*6)/perRow, 0, 34),
            FillDirectionMaxCells = perRow,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0,6)
        })

        for i, lbl in ipairs(labels) do
            local b = Create("TextButton", {
                Parent = gridFrame,
                Size = UDim2.new(0, 100, 0, 34),
                BackgroundColor3 = BG,
                BorderColor3 = BORDER,
                BorderSizePixel = 2,
                Text = tostring(lbl) or ("Btn"..i),
                TextColor3 = TXT,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                AutoButtonColor = false
            })
            b.MouseButton1Click:Connect(function()
                pcall(callback, lbl, i)
            end)
        end

        local element = {type="grid", instance=container}
        table.insert(page.elements, element)
        return element
    end

    -- Expose function to switch to page by name
    function self:SwitchToPage(nameOrIndex)
        if type(nameOrIndex) == "number" then
            self:_showPage(nameOrIndex)
        else
            for i,p in ipairs(self._pages) do
                if p.name == nameOrIndex then
                    self:_showPage(i)
                    return
                end
            end
        end
    end

    -- Return API
    self.screenGui = screenGui
    self.main = Main
    self.content = Content

    return self
end

-- Convenience: top-level factory
local exported = {}
exported.CreateWindow = function(title, opts)
    local lib = {}
    setmetatable(lib, {__index = library})
    return library.CreateWindow(lib, title, opts)
end

-- Return the module-like table
return exported
