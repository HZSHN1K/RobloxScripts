-- CoolUI Library Implementation
local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Настройки темы
local Theme = {
    Background = Color3.fromRGB(30, 30, 35),
    Header = Color3.fromRGB(40, 40, 45),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 170, 255), -- Голубой цвет (можно менять)
    ElementBg = Color3.fromRGB(50, 50, 55),
    Hover = Color3.fromRGB(60, 60, 65)
}

-- Вспомогательная функция для перетаскивания (Draggable)
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
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

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Header = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local UIPadding = Instance.new("UIPadding")

    -- Защита GUI (если поддерживается эксплойтом)
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    ScreenGui.Name = "CoolUILib"
    ScreenGui.ResetOnSpawn = false

    -- Основное окно
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    -- Заголовок (Header)
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 30)

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header
    
    -- Исправление углов снизу хедера (визуальный фикс)
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Parent = Header
    HeaderFix.BackgroundColor3 = Theme.Header
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Position = UDim2.new(0, 0, 1, -5)
    HeaderFix.Size = UDim2.new(1, 0, 0, 5)

    Title.Name = "Title"
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name
    Title.TextColor3 = Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    MakeDraggable(Header, MainFrame)

    -- Контейнер для элементов
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.Active = true
    Container.BackgroundColor3 = Theme.Background
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0, 35)
    Container.Size = UDim2.new(1, 0, 1, -40)
    Container.ScrollBarThickness = 4
    Container.ScrollBarImageColor3 = Theme.Accent

    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    UIPadding.Parent = Container
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)

    -- Функции окна
    local WindowFunctions = {}

    function WindowFunctions:Button(text, callback)
        callback = callback or function() end
        
        local ButtonBtn = Instance.new("TextButton")
        local ButtonCorner = Instance.new("UICorner")
        
        ButtonBtn.Name = text
        ButtonBtn.Parent = Container
        ButtonBtn.BackgroundColor3 = Theme.ElementBg
        ButtonBtn.Size = UDim2.new(1, 0, 0, 32)
        ButtonBtn.AutoButtonColor = false
        ButtonBtn.Font = Enum.Font.GothamSemibold
        ButtonBtn.Text = text
        ButtonBtn.TextColor3 = Theme.Text
        ButtonBtn.TextSize = 14
        
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ButtonBtn

        -- Анимация клика
        ButtonBtn.MouseButton1Click:Connect(function()
            callback()
            TweenService:Create(ButtonBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            wait(0.1)
            TweenService:Create(ButtonBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ElementBg}):Play()
        end)
    end

    function WindowFunctions:Toggle(text, default, callback)
        callback = callback or function() end
        local toggled = default or false

        local ToggleFrame = Instance.new("TextButton") -- Используем TextButton как контейнер для клика
        local ToggleCorner = Instance.new("UICorner")
        local ToggleTitle = Instance.new("TextLabel")
        local Checkbox = Instance.new("Frame")
        local CheckCorner = Instance.new("UICorner")
        local CheckStatus = Instance.new("Frame")
        local CheckStatusCorner = Instance.new("UICorner")

        ToggleFrame.Name = text
        ToggleFrame.Parent = Container
        ToggleFrame.BackgroundColor3 = Theme.ElementBg
        ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
        ToggleFrame.AutoButtonColor = false
        ToggleFrame.Text = ""

        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = ToggleFrame

        ToggleTitle.Parent = ToggleFrame
        ToggleTitle.BackgroundTransparency = 1
        ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
        ToggleTitle.Size = UDim2.new(1, -40, 1, 0)
        ToggleTitle.Font = Enum.Font.GothamSemibold
        ToggleTitle.Text = text
        ToggleTitle.TextColor3 = Theme.Text
        ToggleTitle.TextSize = 14
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left

        Checkbox.Parent = ToggleFrame
        Checkbox.BackgroundColor3 = Theme.Background
        Checkbox.Position = UDim2.new(1, -26, 0.5, -8)
        Checkbox.Size = UDim2.new(0, 16, 0, 16)

        CheckCorner.CornerRadius = UDim.new(0, 4)
        CheckCorner.Parent = Checkbox

        CheckStatus.Parent = Checkbox
        CheckStatus.BackgroundColor3 = Theme.Accent
        CheckStatus.Size = UDim2.new(1, 0, 1, 0)
        CheckStatus.BackgroundTransparency = toggled and 0 or 1

        CheckStatusCorner.CornerRadius = UDim.new(0, 4)
        CheckStatusCorner.Parent = CheckStatus

        local function UpdateToggle()
            toggled = not toggled
            TweenService:Create(CheckStatus, TweenInfo.new(0.2), {BackgroundTransparency = toggled and 0 or 1}):Play()
            callback(toggled)
        end

        ToggleFrame.MouseButton1Click:Connect(UpdateToggle)
        -- Инициализация стартового состояния без вызова колбэка
        if default then
            CheckStatus.BackgroundTransparency = 0
        end
    end

    function WindowFunctions:Dropdown(text, options, callback)
        callback = callback or function() end
        local isDropped = false
        
        local DropdownFrame = Instance.new("Frame")
        local DropdownCorner = Instance.new("UICorner")
        local DropdownBtn = Instance.new("TextButton")
        local DropdownTitle = Instance.new("TextLabel")
        local Arrow = Instance.new("TextLabel")
        local OptionContainer = Instance.new("Frame")
        local OptionList = Instance.new("UIListLayout")

        DropdownFrame.Name = text
        DropdownFrame.Parent = Container
        DropdownFrame.BackgroundColor3 = Theme.ElementBg
        DropdownFrame.Size = UDim2.new(1, 0, 0, 32)
        DropdownFrame.ClipsDescendants = true -- Важно для скрытия списка

        DropdownCorner.CornerRadius = UDim.new(0, 4)
        DropdownCorner.Parent = DropdownFrame

        DropdownBtn.Parent = DropdownFrame
        DropdownBtn.BackgroundTransparency = 1
        DropdownBtn.Size = UDim2.new(1, 0, 0, 32)
        DropdownBtn.Text = ""

        DropdownTitle.Parent = DropdownBtn
        DropdownTitle.BackgroundTransparency = 1
        DropdownTitle.Position = UDim2.new(0, 10, 0, 0)
        DropdownTitle.Size = UDim2.new(1, -30, 1, 0)
        DropdownTitle.Font = Enum.Font.GothamSemibold
        DropdownTitle.Text = text
        DropdownTitle.TextColor3 = Theme.Text
        DropdownTitle.TextSize = 14
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left

        Arrow.Parent = DropdownBtn
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -25, 0, 0)
        Arrow.Size = UDim2.new(0, 25, 1, 0)
        Arrow.Font = Enum.Font.GothamBold
        Arrow.Text = "v"
        Arrow.TextColor3 = Theme.Text
        Arrow.TextSize = 12

        OptionContainer.Parent = DropdownFrame
        OptionContainer.BackgroundColor3 = Theme.ElementBg
        OptionContainer.BackgroundTransparency = 1
        OptionContainer.Position = UDim2.new(0, 0, 0, 35)
        OptionContainer.Size = UDim2.new(1, 0, 0, 0)

        OptionList.Parent = OptionContainer
        OptionList.SortOrder = Enum.SortOrder.LayoutOrder
        OptionList.Padding = UDim.new(0, 2)

        local function RefreshOptions()
            -- Очистка старых опций
            for _, v in pairs(OptionContainer:GetChildren()) do
                if v:IsA("TextButton") then v:Destroy() end
            end

            for _, option in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Parent = OptionContainer
                OptBtn.BackgroundColor3 = Theme.Background
                OptBtn.Size = UDim2.new(1, -10, 0, 25)
                OptBtn.Position = UDim2.new(0, 5, 0, 0) -- отступ
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.Text = option
                OptBtn.TextColor3 = Theme.Text
                OptBtn.TextSize = 13
                OptBtn.AutoButtonColor = false
                
                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    isDropped = false
                    DropdownTitle.Text = text .. ": " .. option
                    callback(option)
                    -- Закрыть меню
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 32)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                end)
            end
        end
        RefreshOptions()

        DropdownBtn.MouseButton1Click:Connect(function()
            isDropped = not isDropped
            local optionHeight = (#options * 27) + 10
            local targetSize = isDropped and UDim2.new(1, 0, 0, 32 + optionHeight) or UDim2.new(1, 0, 0, 32)
            
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = targetSize}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = isDropped and 180 or 0}):Play()
        end)
    end
    
    function WindowFunctions:Label(text)
        local Label = Instance.new("TextLabel")
        Label.Parent = Container
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(150, 150, 150)
        Label.TextSize = 12
    end

    return WindowFunctions
end

return Library
