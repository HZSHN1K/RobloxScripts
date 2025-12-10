-- c00lgui-style UI Library (Enhanced version)
-- Сохраняет оригинальный черно-красный дизайн
-- Добавлены новые элементы и функции

local library = {}

--=== UTILS ===--
local function Create(obj, props)
    local o = Instance.new(obj)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local RED = Color3.fromRGB(255, 0, 0)
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)

--=== MAIN WINDOW ===--
function library:CreateWindow(title)
    local self = {}

    local ScreenGui = Create("ScreenGui", {
        Parent = game.CoreGui,
        Name = "c00lgui_UI_" .. math.random(10000, 99999)
    })

    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 450, 0, 500),
        Position = UDim2.new(0.5, -225, 0.5, -250),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Active = true,
        Draggable = false  -- Будет включено после добавления drag-функции
    })

    -- Добавляем возможность перетаскивания
    local dragging = false
    local dragInput, dragStart, startPos

    local Title = Create("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = title or "c00lgui UI",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })

    -- Функция перетаскивания окна
    local function updateDrag(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            updateDrag(input)
        end
    end)

    local Content = Create("ScrollingFrame", {  -- Изменено на ScrollingFrame для поддержки многих элементов
        Parent = Main,
        Size = UDim2.new(1, 0, 1, -105),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = RED,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local UIGrid = Create("UIGridLayout", {
        Parent = Content,
        CellSize = UDim2.new(0, 215, 0, 40),
        FillDirectionMaxCells = 2,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        CellPadding = UDim2.new(0, 5, 0, 5)
    })

    local Close = Create("TextButton", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 1, -35),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = "Закрыть",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20
    })

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --=== НОВЫЕ ЭЛЕМЕНТЫ ===--

    -- 1. Текстовое поле (TextBox)
    function self:TextBox(text, placeholder, callback)
        local container = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0, 215, 0, 40)
        })

        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local textBox = Create("TextBox", {
            Parent = container,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = "",
            PlaceholderText = placeholder or "Введите текст...",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 16,
            ClearTextOnFocus = false
        })

        textBox.FocusLost:Connect(function(enterPressed)
            if callback and enterPressed then
                callback(textBox.Text)
            end
        end)

        return container
    end

    -- 2. Выпадающий список (Dropdown)
    function self:Dropdown(text, options, default, callback)
        local container = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0, 215, 0, 40),
            ClipsDescendants = true
        })

        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local dropdownBtn = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = options[default] or "Выберите...",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 16
        })

        local dropdownOpen = false
        local dropdownFrame = Create("Frame", {
            Parent = container,
            Size = UDim2.new(1, -10, 0, 0),
            Position = UDim2.new(0, 5, 0, 40),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Visible = false,
            ClipsDescendants = true
        })

        local UIListLayout = Create("UIListLayout", {
            Parent = dropdownFrame,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        dropdownBtn.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            dropdownFrame.Visible = dropdownOpen
            
            if dropdownOpen then
                dropdownFrame.Size = UDim2.new(1, -10, 0, math.min(#options * 25, 100))
            end
        end)

        local selectedValue = default
        for i, option in pairs(options) do
            local optionBtn = Create("TextButton", {
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderColor3 = RED,
                BorderSizePixel = 1,
                Text = option,
                TextColor3 = WHITE,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                LayoutOrder = i
            })

            optionBtn.MouseButton1Click:Connect(function()
                selectedValue = i
                dropdownBtn.Text = option
                dropdownOpen = false
                dropdownFrame.Visible = false
                if callback then callback(i, option) end
            end)
        end

        -- Закрытие dropdown при клике вне его
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                local absPos = container.AbsolutePosition
                local absSize = container.AbsoluteSize
                
                if not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                       mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y + 100) then
                    dropdownOpen = false
                    dropdownFrame.Visible = false
                end
            end
        end)

        return container
    end

    -- 3. Метка (Label)
    function self:Label(text)
        local label = Create("TextLabel", {
            Parent = Content,
            Size = UDim2.new(0, 215, 0, 25),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        return label
    end

    -- 4. Разделитель (Separator)
    function self:Separator()
        local separator = Create("Frame", {
            Parent = Content,
            Size = UDim2.new(0, 215, 0, 2),
            BackgroundColor3 = RED,
            BorderSizePixel = 0
        })
        return separator
    end

    -- 5. Кнопка с иконкой (IconButton)
    function self:IconButton(text, icon, callback)
        local button = Create("TextButton", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Text = "  " .. text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if icon then
            local iconLabel = Create("TextLabel", {
                Parent = button,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = icon,
                TextColor3 = RED,
                Font = Enum.Font.SourceSansBold,
                TextSize = 18
            })
        end

        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return button
    end

    -- 6. Поле ввода числа (NumberBox)
    function self:NumberBox(text, min, max, default, callback)
        local container = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0, 215, 0, 40)
        })

        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(0.6, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local valueLabel = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(0.4, 0, 0, 15),
            Position = UDim2.new(0.6, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = RED,
            Font = Enum.Font.SourceSansBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        local value = math.clamp(default or min, min, max)

        local decreaseBtn = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(0, 5, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = "-",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })

        local increaseBtn = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(1, -35, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = "+",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })

        local function updateValue(newValue)
            value = math.clamp(newValue, min, max)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end

        decreaseBtn.MouseButton1Click:Connect(function()
            updateValue(value - 1)
        end)

        increaseBtn.MouseButton1Click:Connect(function()
            updateValue(value + 1)
        end)

        -- Быстрое изменение при зажатии
        local function startIncrement(amount)
            local conn
            conn = game:GetService("RunService").RenderStepped:Connect(function()
                updateValue(value + amount)
            end)
            
            return function()
                conn:Disconnect()
            end
        end

        decreaseBtn.MouseButton1Down:Connect(function()
            local stop = startIncrement(-1)
            decreaseBtn.MouseButton1Up:Wait()
            stop()
        end)

        increaseBtn.MouseButton1Down:Connect(function()
            local stop = startIncrement(1)
            increaseBtn.MouseButton1Up:Wait()
            stop()
        end)

        return container
    end

    -- 7. Ключ-биндер (Keybind)
    function self:Keybind(text, defaultKey, callback)
        local container = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0, 215, 0, 40)
        })

        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(0.7, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local keyLabel = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(0.3, -10, 0, 20),
            Position = UDim2.new(0.7, 5, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = defaultKey or "None",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14
        })

        local listening = false
        local currentKey = defaultKey

        keyLabel.MouseButton1Click:Connect(function()
            listening = true
            keyLabel.Text = "..."
            keyLabel.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        end)

        local conn
        conn = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    keyLabel.Text = currentKey
                    listening = false
                    keyLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    
                    if callback then callback(currentKey) end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    currentKey = "MouseButton1"
                    keyLabel.Text = "MB1"
                    listening = false
                    keyLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    
                    if callback then callback(currentKey) end
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    currentKey = "MouseButton2"
                    keyLabel.Text = "MB2"
                    listening = false
                    keyLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    
                    if callback then callback(currentKey) end
                end
            elseif input.KeyCode.Name == currentKey and not listening then
                if callback then callback(currentKey, true) end
            end
        end)

        return container
    end

    --=== СОХРАНЕНИЕ СТАРЫХ ЭЛЕМЕНТОВ (немного улучшенных) ===--

    function self:Button(text, callback)
        local b = Create("TextButton", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })
        b.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return b
    end

    function self:Toggle(text, default, callback)
        local value = default or false

        local b = Create("TextButton", {
            Parent = Content,
            BackgroundColor3 = value and Color3.fromRGB(40, 0, 0) or BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Text = text .. " : " .. (value and "ON" or "OFF"),
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16
        })

        b.MouseButton1Click:Connect(function()
            value = not value
            b.Text = text .. " : " .. (value and "ON" or "OFF")
            b.BackgroundColor3 = value and Color3.fromRGB(40, 0, 0) or BLACK
            if callback then callback(value) end
        end)

        return b
    end

    function self:Slider(text, min, max, default, callback)
        local sliderFrame = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0, 215, 0, 50)
        })

        local label = Create("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text .. " : " .. default,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 16
        })

        local bar = Create("Frame", {
            Parent = sliderFrame,
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1
        })

        local fill = Create("Frame", {
            Parent = bar,
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = RED,
            BorderSizePixel = 0
        })

        local valueText = Create("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(0, 40, 0, 15),
            Position = UDim2.new(1, -45, 0, 10),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = RED,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        bar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = game:GetService("RunService").RenderStepped:Connect(function()
                    local mouse = game:GetService("UserInputService"):GetMouseLocation().X
                    local x = math.clamp(mouse - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                    fill.Size = UDim2.new(x / bar.AbsoluteSize.X, 0, 1, 0)

                    local value = math.floor(min + (max - min) * (x / bar.AbsoluteSize.X))
                    label.Text = text .. " : " .. value
                    valueText.Text = tostring(value)
                    if callback then callback(value) end
                end)

                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        conn:Disconnect()
                    end
                end)
            end
        end)

        return sliderFrame
    end

    --=== ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===--

    -- Функция для очистки всех элементов
    function self:Clear()
        for _, child in pairs(Content:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end

    -- Функция для показа/скрытия окна
    function self:SetVisible(visible)
        ScreenGui.Enabled = visible
    end

    -- Получить ссылку на ScreenGui
    function self:GetGui()
        return ScreenGui
    end

    -- Установить позицию окна
    function self:SetPosition(xScale, xOffset, yScale, yOffset)
        Main.Position = UDim2.new(xScale, xOffset, yScale, yOffset)
    end

    return self
end

return library
