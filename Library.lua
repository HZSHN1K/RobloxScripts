-- C00lStyleUI.lua
-- Visual clone of C00lgui (appearance + animation) — NO exploit functionality.
-- Usage: local ui = loadstring(game:HttpGet("RAW_URL"))(); local win = ui("Title"); local tab = win:AddTab("Main")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local function twn(obj, props, time, style, dir)
    time = time or 0.18
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local ti = TweenInfo.new(time, style, dir)
    local ok, t = pcall(TweenService.Create, TweenService, obj, ti, props)
    if ok and t then t:Play() end
end

local function make(class, props)
    local obj = Instance.new(class)
    props = props or {}
    for k,v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    return obj
end

local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end

-- Style constants tuned to resemble C00lgui
local STYLE = {
    BG = Color3.fromRGB(14,14,16),
    Panel = Color3.fromRGB(24,24,28),
    Accent = Color3.fromRGB(137,75,255),
    Accent2 = Color3.fromRGB(95,45,190),
    Text = Color3.fromRGB(235,235,240),
    Muted = Color3.fromRGB(150,150,160)
}

local UI = {}
UI.__index = UI

local function parentGui()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    while not pg do
        pg = localPlayer:WaitForChild("PlayerGui")
        wait()
    end
    return pg
end

-- create base ScreenGui
local function NewScreen(name)
    local sg = make("ScreenGui", {Name = name or "C00lStyleUI", Parent = parentGui(), ResetOnSpawn = false})
    return sg
end

-- main window creator
function UI.new(title)
    local self = setmetatable({}, UI)
    self.ScreenGui = NewScreen("C00lStyleUI")
    -- Main frame
    local main = make("Frame", {
        Name = "Main",
        Parent = self.ScreenGui,
        Size = UDim2.new(0,540,0,360),
        Position = UDim2.new(0.5, -270, 0.5, -180),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = STYLE.BG,
        BorderSizePixel = 0
    })
    make("UICorner",{Parent = main, CornerRadius = UDim.new(0,12)})
    make("UIStroke",{Parent=main, Color=Color3.fromRGB(0,0,0), Thickness=1, Transparency=0.85})

    -- Top header (title + subtle glow)
    local header = make("Frame",{Parent=main, Size = UDim2.new(1,0,0,52), BackgroundTransparency = 1})
    local titleLbl = make("TextLabel", {
        Parent = header,
        Text = title or "C00l UI",
        TextColor3 = STYLE.Text,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Position = UDim2.new(0,18,0,14)
    })
    -- subtle accent bar under header
    local accentBar = make("Frame", {Parent=main, Size = UDim2.new(1,0,0,6), Position = UDim2.new(0,0,0,52), BackgroundColor3 = STYLE.Panel})
    make("UICorner",{Parent = accentBar, CornerRadius = UDim.new(0,6)})
    local accentFill = make("Frame", {Parent = accentBar, Size = UDim2.new(0.22,0,1,0), BackgroundColor3 = STYLE.Accent})
    make("UICorner",{Parent = accentFill, CornerRadius = UDim.new(0,6)})

    -- Content container
    local content = make("Frame", {Parent = main, Position = UDim2.new(0,0,0,58), Size = UDim2.new(1,0,1,-58), BackgroundColor3 = STYLE.Panel})
    make("UICorner",{Parent = content, CornerRadius = UDim.new(0,10)})

    -- Left tabs column
    local tabsCol = make("ScrollingFrame", {
        Parent = content,
        Size = UDim2.new(0,150,1,0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        BackgroundTransparency = 1
    })
    make("UIListLayout",{Parent = tabsCol, Padding = UDim.new(0,8), FillDirection = Enum.FillDirection.Vertical})
    make("UIPadding",{Parent=tabsCol, PaddingTop=UDim.new(0,12), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,6)})

    -- Right page area
    local pageArea = make("Frame", {Parent = content, Position = UDim2.new(0,150,0,0), Size = UDim2.new(1,-150,1,0), BackgroundTransparency = 1})
    make("UIListLayout",{Parent = pageArea, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0,10)})

    -- draggable header logic
    do
        local dragging,dragInput,startPos,origPos
        header.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = inp.Position
                origPos = main.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        header.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp == dragInput then
                local delta = inp.Position - startPos
                main.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + delta.X, origPos.Y.Scale, origPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- store internals
    self._main = main
    self._tabsCol = tabsCol
    self._pageArea = pageArea
    self._tabs = {}

    -- helper to make labeled containers on page
    local function makeRow(label)
        local container = make("Frame", {Parent = pageArea, Size = UDim2.new(1,-18,0,40), BackgroundTransparency = 1})
        local lbl = make("TextLabel", {Parent = container, Text = label or "", Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, TextColor3 = STYLE.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        return container
    end

    -- API: AddTab(name)
    function self:AddTab(name)
        local tabBtn = make("TextButton", {Parent = tabsCol, Size = UDim2.new(1,-12,0,36), Text = name, BackgroundColor3 = STYLE.Panel, TextColor3 = STYLE.Text, Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = false})
        make("UICorner",{Parent = tabBtn, CornerRadius = UDim.new(0,8)})
        local page = make("Frame", {Parent = pageArea, Size = UDim2.new(1,-18,0,0), BackgroundTransparency = 1, Visible = false})
        make("UIListLayout",{Parent = page, Padding = UDim.new(0,8)})
        make("UIPadding",{Parent = page, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,8)})

        -- activation
        tabBtn.MouseButton1Click:Connect(function()
            for _,t in pairs(self._tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = STYLE.Panel
                pcall(function() t.Button.TextColor3 = STYLE.Text end)
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = STYLE.Accent2
            twn(accentFill, {Size = UDim2.new(0, math.clamp( (math.random()*0.4 + 0.18) * accentBar.AbsoluteSize.X, 0, accentBar.AbsoluteSize.X), 1,0)}, 0.22)
        end)

        -- auto-select first
        if #self._tabs == 0 then
            wait(0.02)
            tabBtn:CaptureFocus()
            tabBtn.MouseButton1Click:Wait()
        end

        local tabObj = {}

        function tabObj:AddToggle(label, default, callback)
            local row = makeRow(label)
            row.Size = UDim2.new(1,-18,0,40)
            local toggle = make("TextButton", {Parent = row, Size = UDim2.new(0,56,0,28), Position = UDim2.new(1,-64,0.5,-14), BackgroundColor3 = default and STYLE.Accent or STYLE.Panel, Text = "", AutoButtonColor = false})
            make("UICorner",{Parent = toggle, CornerRadius = UDim.new(0,8)})
            local dot = make("Frame", {Parent = toggle, Size = UDim2.new(0.46,0,0.84,0), Position = default and UDim2.new(0.54,0,0.08,0) or UDim2.new(0.05,0,0.08,0), BackgroundColor3 = Color3.new(1,1,1)})
            make("UICorner",{Parent = dot, CornerRadius = UDim.new(1,8)})
            local state = default and true or false
            toggle.MouseButton1Click:Connect(function()
                state = not state
                twn(toggle, {BackgroundColor3 = state and STYLE.Accent or STYLE.Panel}, 0.16)
                twn(dot, {Position = state and UDim2.new(0.54,0,0.08,0) or UDim2.new(0.05,0,0.08,0)}, 0.16)
                if callback then pcall(callback, state) end
            end)
            return toggle
        end

        function tabObj:AddButton(label, callback)
            local row = makeRow(label)
            row.Size = UDim2.new(1,-18,0,38)
            local btn = make("TextButton", {Parent = row, Size = UDim2.new(0.42,0,0,28), Position = UDim2.new(1,-(0.42*pageArea.AbsoluteSize.X)-8,0.5,-14), Text = label, BackgroundColor3 = STYLE.Accent, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, AutoButtonColor = false})
            make("UICorner",{Parent = btn, CornerRadius = UDim.new(0,8)})
            btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
            return btn
        end

        function tabObj:AddSlider(label, min, max, default, step, callback)
            min = min or 0; max = max or 100; step = step or 1; default = default or min
            local cont = make("Frame", {Parent = page, Size = UDim2.new(1,-18,0,48), BackgroundTransparency = 1})
            local lbl = make("TextLabel", {Parent = cont, Text = label or "", Size = UDim2.new(0.6,0,0,18), BackgroundTransparency = 1, TextColor3 = STYLE.Text, Font = Enum.Font.Gotham, TextSize = 13, Position = UDim2.new(0,0,0,2)})
            local valTxt = make("TextLabel", {Parent = cont, Text = tostring(default), Size = UDim2.new(0.28,0,0,18), BackgroundTransparency = 1, TextColor3 = STYLE.Muted, Font = Enum.Font.Gotham, TextSize = 12, Position = UDim2.new(0.72,0,0,2), TextXAlignment = Enum.TextXAlignment.Right})
            local bar = make("Frame", {Parent = cont, Size = UDim2.new(1,-18,0,12), Position = UDim2.new(0,9,0,28), BackgroundColor3 = STYLE.BG})
            make("UICorner",{Parent = bar, CornerRadius = UDim.new(0,6)})
            local fill = make("Frame", {Parent = bar, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = STYLE.Accent})
            make("UICorner",{Parent = fill, CornerRadius = UDim.new(0,6)})

            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local abs = clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local raw = min + (max - min) * abs
                local stepped = math.floor(raw/step + 0.5)*step
                local ratio = (stepped - min)/(max - min)
                fill.Size = UDim2.new(ratio,0,1,0)
                valTxt.Text = tostring(stepped)
                if callback then pcall(callback, stepped) end
            end)
            return cont
        end

        function tabObj:AddDropdown(label, options, callback)
            options = options or {"Option"}
            local cont = make("Frame", {Parent = page, Size = UDim2.new(1,-18,0,36), BackgroundTransparency = 1})
            local lbl = make("TextLabel", {Parent = cont, Text = label or "", Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, TextColor3 = STYLE.Text, Font = Enum.Font.Gotham, TextSize = 13})
            local sel = make("TextButton", {Parent = cont, Text = options[1], Size = UDim2.new(0.42,0,1,0), Position = UDim2.new(0.52,0,0,0), BackgroundColor3 = STYLE.BG, TextColor3 = STYLE.Text, AutoButtonColor = false})
            make("UICorner",{Parent = sel, CornerRadius = UDim.new(0,8)})
            local list = make("Frame", {Parent = page, Size = UDim2.new(0,200,0,0), Position = UDim2.new(0.52,0,0,36), BackgroundColor3 = STYLE.BG, Visible = false})
            make("UICorner",{Parent = list, CornerRadius = UDim.new(0,8)})
            local layout = make("UIListLayout", {Parent = list, Padding = UDim.new(0,6)})
            make("UIPadding",{Parent = list, PaddingTop = UDim.new(0,8), PaddingBottom = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
            for _,opt in ipairs(options) do
                local b = make("TextButton", {Parent = list, Text = opt, Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1, TextColor3 = STYLE.Text, AutoButtonColor = false})
                b.MouseButton1Click:Connect(function()
                    sel.Text = opt
                    twn(list, {Size = UDim2.new(0,200,0,0)}, 0.12)
                    wait(0.12)
                    list.Visible = false
                    if callback then pcall(callback, opt) end
                end)
            end
            sel.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
                if list.Visible then
                    twn(list, {Size = UDim2.new(0,200,0,#options*30 + 12)}, 0.18)
                else
                    twn(list, {Size = UDim2.new(0,200,0,0)}, 0.12)
                end
            end)
            return cont
        end

        function tabObj:AddKeybind(label, defaultKey, callback)
            local cont = make("Frame", {Parent = page, Size = UDim2.new(1,-18,0,36), BackgroundTransparency = 1})
            local lbl = make("TextLabel", {Parent = cont, Text = label or "", Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, TextColor3 = STYLE.Text, Font = Enum.Font.Gotham, TextSize = 13})
            local picker = make("TextButton", {Parent = cont, Text = defaultKey or "None", Size = UDim2.new(0.34,0,1,0), Position = UDim2.new(0.66,0,0,0), BackgroundColor3 = STYLE.BG, TextColor3 = STYLE.Text, AutoButtonColor = false})
            make("UICorner",{Parent = picker, CornerRadius = UDim.new(0,8)})
            picker.MouseButton1Click:Connect(function()
                picker.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local name = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        picker.Text = name
                        conn:Disconnect()
                        if callback then pcall(callback, name) end
                    end
                end)
            end)
            return cont
        end

        table.insert(self._tabs, {Name = name, Button = tabBtn, Page = page})
        return tabObj
    end

    -- return API: allow window close/destroy
    function self:Destroy()
        pcall(function() self.ScreenGui:Destroy() end)
    end

    return self
end

-- callable
return setmetatable({}, {
    __call = function(_, title) return UI.new(title) end
})
