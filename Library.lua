-- c00lgui Reborn Rc7 - FIXED VERSION
-- Исправлен баг с отображением страниц

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
local GRAY = Color3.fromRGB(100, 100, 100)

--=== MAIN WINDOW ===--
function library:CreateWindow(title)
    local self = {}
    
    -- Система страниц
    local currentPage = 1
    local pages = {{name = "Main"}}  -- Первая страница по умолчанию
    local pageElements = {}
    
    local ScreenGui = Create("ScreenGui", {
        Parent = game.CoreGui,
        Name = "c00lgui_Reborn_Rc7",
        ResetOnSpawn = false,
        Enabled = true
    })

    -- Основное окно
    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Active = true
    })

    -- Заголовок
    local Title = Create("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = title or "c00lgui Reborn Rc7",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })

    -- Перетаскивание окна
    local dragging = false
    local dragInput, dragStart, startPos

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

    -- Контентная область
    local Content = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- Сетка для 4 колонок
    local UIColumns = {}
    local UIListLayouts = {}
    for i = 1, 4 do
        local column = Create("Frame", {
            Parent = Content,
            Size = UDim2.new(0.25, 0, 1, 0),
            Position = UDim2.new((i-1) * 0.25, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })
        
        local UIList = Create("UIListLayout", {
            Parent = column,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2)
        })
        
        UIColumns[i] = column
        UIListLayouts[i] = UIList
    end

    -- Стрелки для переключения страниц
    local LeftArrow = Create("TextButton", {
        Parent = Content,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 1,
        Text = "<",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Visible = false
    })

    local RightArrow = Create("TextButton", {
        Parent = Content,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 1,
        Text = ">",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Visible = false
    })

    -- Функция для обновления отображения страницы (ИСПРАВЛЕННАЯ)
    local function updatePageDisplay()
        print("Обновление страницы:", currentPage, "Всего страниц:", #pages)
        
        -- Скрываем все элементы во всех колонках
        for i = 1, 4 do
            for _, child in pairs(UIColumns[i]:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    child.Visible = false
                end
            end
        end
        
        -- Показываем элементы текущей страницы
        if pageElements[currentPage] then
            print("Элементов на странице:", #pageElements[currentPage])
            for elementId, elementData in pairs(pageElements[currentPage]) do
                if elementData.element and elementData.element.Parent then
                    elementData.element.Visible = true
                    print("Показан элемент", elementId, "в колонке", elementData.column)
                end
            end
        else
            pageElements[currentPage] = {}
        end
        
        -- Обновляем стрелки
        LeftArrow.Visible = currentPage > 1
        RightArrow.Visible = currentPage < #pages
        
        -- Обновляем заголовок
        Title.Text = (title or "c00lgui Reborn Rc7") .. " - Page " .. currentPage .. "/" .. #pages
    end

    -- Переключение страниц
    LeftArrow.MouseButton1Click:Connect(function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            updatePageDisplay()
        end
    end)

    RightArrow.MouseButton1Click:Connect(function()
        if currentPage < #pages then
            currentPage = currentPage + 1
            updatePageDisplay()
        end
    end)

    -- Кнопка закрытия
    local Close = Create("TextButton", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 1, -35),
        BackgroundColor3 = BLACK,
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = "Close",
        TextColor3 = WHITE,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --=== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===--
    
    -- Функция для добавления элемента на текущую страницу (ИСПРАВЛЕННАЯ)
    local function addElementToPage(element, column)
        if not pageElements[currentPage] then
            pageElements[currentPage] = {}
        end
        
        local elementId = #pageElements[currentPage] + 1
        pageElements[currentPage][elementId] = {
            element = element,
            column = column or ((elementId - 1) % 4) + 1
        }
        
        -- Распределяем по колонкам
        local targetColumn = column or ((elementId - 1) % 4) + 1
        element.Parent = UIColumns[targetColumn]
        element.Visible = (currentPage == 1)  -- Показываем только если это первая страница
        
        print("Добавлен элемент", elementId, "на страницу", currentPage, "колонка", targetColumn)
        
        return element
    end
    
    -- Функция для создания новой страницы (ИСПРАВЛЕННАЯ)
    function self:NewPage(name)
        table.insert(pages, {name = name})
        pageElements[#pages] = {}  -- Создаем пустой массив для элементов новой страницы
        print("Создана новая страница:", name, "ID:", #pages)
        
        -- Не переключаемся автоматически на новую страницу
        -- Оставляем пользователя на текущей странице
        
        return #pages
    end
    
    -- Функция для переключения на страницу (ИСПРАВЛЕННАЯ)
    function self:GoToPage(pageNum)
        if pageNum >= 1 and pageNum <= #pages then
            currentPage = pageNum
            updatePageDisplay()
            return true
        end
        return false
    end

    --=== ЭЛЕМЕНТЫ ИНТЕРФЕЙСА ===--

    function self:Button(text, callback, column)
        local button = Create("TextButton", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 25),
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = BLACK
        end)
        
        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return addElementToPage(button, column)
    end

    function self:Toggle(text, default, callback, column)
        local value = default or false
        
        local toggle = Create("TextButton", {
            BackgroundColor3 = value and Color3.fromRGB(40, 0, 0) or BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 25),
            Text = text .. " : " .. (value and "ON" or "OFF"),
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        toggle.MouseEnter:Connect(function()
            toggle.BackgroundColor3 = value and Color3.fromRGB(60, 0, 0) or Color3.fromRGB(30, 0, 0)
        end)
        
        toggle.MouseLeave:Connect(function()
            toggle.BackgroundColor3 = value and Color3.fromRGB(40, 0, 0) or BLACK
        end)
        
        toggle.MouseButton1Click:Connect(function()
            value = not value
            toggle.Text = text .. " : " .. (value and "ON" or "OFF")
            toggle.BackgroundColor3 = value and Color3.fromRGB(40, 0, 0) or BLACK
            if callback then callback(value) end
        end)
        
        return addElementToPage(toggle, column)
    end

    function self:Section(title, column)
        local section = Create("TextLabel", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 20),
            Text = title,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        
        return addElementToPage(section, column)
    end

    function self:Empty(column)
        local empty = Create("TextLabel", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 25),
            Text = "Empty",
            TextColor3 = GRAY,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        
        return addElementToPage(empty, column)
    end

    function self:Slider(text, min, max, default, callback, column)
        local sliderFrame = Create("Frame", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 40)
        })
        
        local label = Create("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local bar = Create("Frame", {
            Parent = sliderFrame,
            Size = UDim2.new(1, -10, 0, 8),
            Position = UDim2.new(0, 5, 0, 20),
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
            Position = UDim2.new(1, -45, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSansBold,
            TextSize = 12,
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
        
        return addElementToPage(sliderFrame, column)
    end

    function self:TextBox(text, placeholder, callback, column)
        local container = Create("Frame", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 40)
        })
        
        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
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
            PlaceholderText = placeholder or "Enter...",
            TextColor3 = WHITE,
            PlaceholderColor3 = GRAY,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            ClearTextOnFocus = false
        })
        
        textBox.FocusLost:Connect(function(enterPressed)
            if callback and enterPressed then
                callback(textBox.Text)
            end
        end)
        
        return addElementToPage(container, column)
    end

    function self:Dropdown(text, options, default, callback, column)
        local container = Create("Frame", {
            BackgroundColor3 = BLACK,
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 40),
            ClipsDescendants = true
        })
        
        local label = Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local dropdownBtn = Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 18),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderColor3 = RED,
            BorderSizePixel = 1,
            Text = options[default] or "Select...",
            TextColor3 = WHITE,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        dropdownBtn.MouseEnter:Connect(function()
            dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end)
        
        dropdownBtn.MouseLeave:Connect(function()
            dropdownBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end)
        
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
                AutoButtonColor = false,
                LayoutOrder = i
            })
            
            optionBtn.MouseEnter:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            end)
            
            optionBtn.MouseLeave:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end)
            
            optionBtn.MouseButton1Click:Connect(function()
                selectedValue = i
                dropdownBtn.Text = option
                dropdownOpen = false
                dropdownFrame.Visible = false
                if callback then callback(i, option) end
            end)
        end
        
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
        
        return addElementToPage(container, column)
    end

    --=== ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===--
    
    function self:GetCurrentPage()
        return currentPage
    end
    
    function self:GetPageCount()
        return #pages
    end
    
    function self:ClearPage()
        if pageElements[currentPage] then
            for _, elementData in pairs(pageElements[currentPage]) do
                if elementData.element then
                    elementData.element:Destroy()
                end
            end
            pageElements[currentPage] = {}
        end
    end
    
    function self:ToggleVisibility()
        ScreenGui.Enabled = not ScreenGui.Enabled
        return ScreenGui.Enabled
    end
    
    function self:Show()
        ScreenGui.Enabled = true
    end
    
    function self:Hide()
        ScreenGui.Enabled = false
    end
    
    function self:IsVisible()
        return ScreenGui.Enabled
    end
    
    function self:Destroy()
        ScreenGui:Destroy()
    end
    
    function self:SetPosition(x, y)
        Main.Position = UDim2.new(0, x, 0, y)
    end
    
    function self:GetPosition()
        return Main.Position
    end
    
    -- ИНИЦИАЛИЗАЦИЯ (ВАЖНО!)
    -- Инициализируем первую страницу
    pageElements[1] = {}
    updatePageDisplay()  -- Показываем первую страницу
    
    return self
end

return library
