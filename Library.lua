-- SimpleUI.lua (рабочая версия)
local SimpleUI = {}
SimpleUI.__index = SimpleUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function Tween(obj, prop, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), prop):Play()
end

local function MakeCorner(obj, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 6)
    c.Parent = obj
end

local function Draggable(frame)
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local dif = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dif.X, startPos.Y.Scale, startPos.Y.Offset + dif.Y)
        end
    end)
end

function SimpleUI:CreateWindow(name)
    name = name or "Simple UI"

    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame")
    main.Parent = gui
    main.Size = UDim2.new(0, 600, 0, 350)
    main.Position = UDim2.new(0.3, 0, 0.25, 0)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MakeCorner(main, 10)

    -- Header
    local header = Instance.new("Frame")
    header.Parent = main
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MakeCorner(header, 10)

    local title = Instance.new("TextLabel")
    title.Parent = header
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left

    Draggable(main)

    local tabsList = Instance.new("Frame")
    tabsList.Parent = main
    tabsList.Size = UDim2.new(0, 160, 1, -36)
    tabsList.Position = UDim2.new(0, 0, 0, 36)
    tabsList.BackgroundTransparency = 1

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = tabsList
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 6)

    local pagesFolder = Instance.new("Folder")
    pagesFolder.Parent = main

    local API = {}
    API._tabs = {}

    -- TAB creation
    function API:CreateTab(tabName)
        local tab = Instance.new("TextButton")
        tab.Parent = tabsList
        tab.Size = UDim2.new(1, -20, 0, 34)
        tab.Position = UDim2.new(0, 10, 0, 0)
        tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tab.Text = tabName
        tab.Font = Enum.Font.Gotham
        tab.TextSize = 14
        tab.TextColor3 = Color3.fromRGB(255,255,255)
        MakeCorner(tab, 6)

        local page = Instance.new("ScrollingFrame")
        page.Parent = pagesFolder
        page.Size = UDim2.new(1, -160, 1, -36)
        page.Position = UDim2.new(0, 160, 0, 36)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.ScrollBarThickness = 5
        page.ScrollBarImageColor3 = Color3.fromRGB(120,130,255)
        page.Visible = (#API._tabs == 0)

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        if #API._tabs == 0 then
            Tween(tab, {BackgroundColor3 = Color3.fromRGB(90,90,120)}, 0.2)
        end

        tab.MouseButton1Click:Connect(function()
            for _, p in pairs(pagesFolder:GetChildren()) do
                p.Visible = false
            end
            for _, b in pairs(tabsList:GetChildren()) do
                if b:IsA("TextButton") then
                    Tween(b, {BackgroundColor3 = Color3.fromRGB(40,40,50)}, 0.15)
                end
            end
            Tween(tab, {BackgroundColor3 = Color3.fromRGB(90,90,120)}, 0.15)
            page.Visible = true
        end)

        local TabAPI = {}

        function TabAPI:CreateSection(title)
            local section = Instance.new("Frame")
            section.Parent = page
            section.Size = UDim2.new(1, -10, 0, 40)
            section.BackgroundColor3 = Color3.fromRGB(35,35,45)
            MakeCorner(section, 6)

            local label = Instance.new("TextLabel")
            label.Parent = section
            label.Position = UDim2.new(0, 8, 0, 6)
            label.Size = UDim2.new(1, -16, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = title
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local inner = Instance.new("Frame")
            inner.Parent = section
            inner.Size = UDim2.new(1, -14, 0, 0)
            inner.Position = UDim2.new(0, 7, 0, 32)
            inner.BackgroundTransparency = 1

            local innerLayout = Instance.new("UIListLayout")
            innerLayout.Parent = inner
            innerLayout.Padding = UDim.new(0, 6)
            innerLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local function UpdateSize()
                section.Size = UDim2.new(1, -10, 0, 36 + innerLayout.AbsoluteContentSize.Y + 10)
            end
            innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

            local Elements = {}

            function Elements:Button(text, callback)
                local btn = Instance.new("TextButton")
                btn.Parent = inner
                btn.Size = UDim2.new(1, 0, 0, 32)
                btn.BackgroundColor3 = Color3.fromRGB(90,90,120)
                btn.Text = text
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 14
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                MakeCorner(btn, 6)

                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = Color3.fromRGB(110,110,150)}, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = Color3.fromRGB(90,90,120)}, 0.12)
                end)

                btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
            end

            return Elements
        end

        table.insert(API._tabs, TabAPI)
        return TabAPI
    end

    return API
end

return SimpleUI
