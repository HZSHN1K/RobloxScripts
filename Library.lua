-- c00lgui Reborn V2.0 (2025 remake by ermol1 & community)
-- Максимально близко к оригиналу 2014–2017, но работает в 2025+

local c00lgui = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "c00lgui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 320)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Топбар в стиле c00lgui
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- классический magenta
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "c00lgui Reborn v2.0"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Arcade
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 18
title.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 0, 0)
closeButton.Font = Enum.Font.Arcade
closeButton.TextSize = 20
closeButton.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 0)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(0, 1, 1)
minimizeButton.Font = Enum.Font.Arcade
minimizeButton.TextSize = 24
minimizeButton.Parent = topBar

-- Контейнер для элементов
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -10, 1, -40)
container.Position = UDim2.new(0, 5, 0, 35)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 6
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

-- Эффекты
local function glowEffect(button)
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://24150945"
    glow.ImageColor3 = Color3.fromRGB(255, 0, 255)
    glow.ImageTransparency = 0.7
    glow.ZIndex = 0
    glow.Parent = button
end

-- Основные функции UI
function c00lgui:Button(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 255)
    btn.BorderSizePixel = 2
    btn.Text = " " .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Arcade
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextSize = 16
    btn.Parent = container
    glowEffect(btn)

    btn.MouseButton1Click:Connect(function()
        spawn(callback)
        btn.BackgroundColor3 = Color3.fromRGB(80, 0, 80)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end)
    
    return btn
end

function c00lgui:Toggle(name, default, callback)
    local state = default or false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    frame.BorderSizePixel = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggle.Text = state and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(0, 0, 0)
    toggle.Font = Enum.Font.Arcade
    toggle.Parent = frame
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        spawn(function() callback(state) end)
    end)
end

function c00lgui:Dropdown(name, items, callback)
    local open = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderColor3 = Color3.fromRGB(255, 255, 0)
    frame.BorderSizePixel = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. name .. ": <nothing>"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 0)
    arrow.Font = Enum.Font.Arcade
    arrow.Parent = frame
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, #items * 30)
    dropFrame.Position = UDim2.new(0, 0, 1, 2)
    dropFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dropFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
    dropFrame.Visible = false
    dropFrame.Parent = frame
    
    for i, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = " " .. item
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Arcade
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = dropFrame
        
        btn.MouseButton1Click:Connect(function()
            label.Text = " " .. name .. ": " .. item
            dropFrame.Visible = false
            open = false
            arrow.Text = "▼"
            callback(item)
        end)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            dropFrame.Visible = open
            arrow.Text = open and "▲" or "▼"
        end
    end)
end

function c00lgui:Slider(name, min, max, default, callback)
    local value = default or min
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    frame.BorderSizePixel = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = " " .. name .. ": " .. value
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -20, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Text = ""
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.Parent = slider
    
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = slider.AbsolutePosition.X
            local percent = math.clamp((mouseX - sliderX) / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = " " .. name .. ": " .. value
            callback(value)
        end
    end)
end

-- Кнопки закрытия/сворачивания
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 450, 0, 30) or UDim2.new(0, 450, 0, 320)
    container.Visible = not minimized
end)

-- Диско-туманчик для души
spawn(function()
    while wait(0.3) do
        if screenGui.Parent then
            topBar.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    end
end)

print([[

   ▄▄▄▄    ▄▄▄     ▄▄▄▄   ▄▄▄   
  ▓█████▄ ▒████▄  ▓█████▄ ▒████▄ 
  ▒██▒ ▄██▒██  ▀█▄ ▒██▒ ▄██▒██  ▀█▄
  ▒██░█▀  ░██▄▄▄▄██▒██░█▀  ░██▄▄▄▄██
  ░▓█  ▀█▓ ▓█   ▓██░░▓█  ▀█▓▓█   ▓██
  ░▒▓███▀▒ ▒▒   ▓▒█░▒▓███▀▒▒▒   ▓▒█░
  ▒░▒   ░   ▒   ▒▒ ░▒░▒   ░  ▒   ▒▒ ░
   ░    ░   ░   ▒    ░    ░  ░   ▒   
   ░            ░  ░ ░          ░  ░
        ░               ░      c00lgui Reborn 2025
]])

return c00lgui
