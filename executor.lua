-- Simple Executor for Universal Script
-- Clean design, draggable, hideable

local Executor = {}

function Executor:Create()
    local self = {}
    
    -- Основное окно
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TextBox = Instance.new("TextBox")
    local ExecuteBtn = Instance.new("TextButton")
    local ClearBtn = Instance.new("TextButton")
    local CloseBtn = Instance.new("TextButton")
    local ToggleBtn = Instance.new("TextButton")
    
    -- Создаем элементы
    ScreenGui.Name = "ExecutorGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false  -- Скрыт по умолчанию
    
    MainFrame.Name = "ExecutorFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    MainFrame.BorderSizePixel = 2
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Title.BorderSizePixel = 2
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "Executor"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    
    TextBox.Name = "ScriptBox"
    TextBox.Parent = MainFrame
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TextBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
    TextBox.BorderSizePixel = 1
    TextBox.Position = UDim2.new(0.05, 0, 0.15, 0)
    TextBox.Size = UDim2.new(0.9, 0, 0.6, 0)
    TextBox.Font = Enum.Font.Code
    TextBox.Text = "-- Type your script here --"
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14
    TextBox.TextWrapped = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    TextBox.ClearTextOnFocus = false
    
    ExecuteBtn.Name = "ExecuteBtn"
    ExecuteBtn.Parent = MainFrame
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ExecuteBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    ExecuteBtn.BorderSizePixel = 2
    ExecuteBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
    ExecuteBtn.Size = UDim2.new(0.25, 0, 0.1, 0)
    ExecuteBtn.Font = Enum.Font.SourceSansBold
    ExecuteBtn.Text = "EXECUTE"
    ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteBtn.TextSize = 14
    
    ClearBtn.Name = "ClearBtn"
    ClearBtn.Parent = MainFrame
    ClearBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ClearBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    ClearBtn.BorderSizePixel = 2
    ClearBtn.Position = UDim2.new(0.4, 0, 0.8, 0)
    ClearBtn.Size = UDim2.new(0.25, 0, 0.1, 0)
    ClearBtn.Font = Enum.Font.SourceSansBold
    ClearBtn.Text = "CLEAR"
    ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearBtn.TextSize = 14
    
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = MainFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    CloseBtn.BorderSizePixel = 2
    CloseBtn.Position = UDim2.new(0.75, 0, 0.8, 0)
    CloseBtn.Size = UDim2.new(0.2, 0, 0.1, 0)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    ToggleBtn.BorderSizePixel = 2
    ToggleBtn.Position = UDim2.new(0.95, -40, 0.05, 0)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.Text = "EX"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 16
    ToggleBtn.Visible = false
    
    -- Функции
    local function executeScript()
        local code = TextBox.Text
        local func, err = loadstring(code)
        if func then
            local success, result = pcall(func)
            if not success then
                warn("Execution error:", result)
            end
        else
            warn("Syntax error:", err)
        end
    end
    
    -- Обработчики событий
    ExecuteBtn.MouseButton1Click:Connect(executeScript)
    
    ClearBtn.MouseButton1Click:Connect(function()
        TextBox.Text = ""
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    -- Горячая клавиша
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.F2 then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)
    
    -- Методы управления
    function self:Show()
        ScreenGui.Enabled = true
        ToggleBtn.Visible = true
    end
    
    function self:Hide()
        ScreenGui.Enabled = false
        ToggleBtn.Visible = false
    end
    
    function self:Toggle()
        ScreenGui.Enabled = not ScreenGui.Enabled
        ToggleBtn.Visible = ScreenGui.Enabled
        return ScreenGui.Enabled
    end
    
    function self:SetVisible(visible)
        ScreenGui.Enabled = visible
        ToggleBtn.Visible = visible
    end
    
    function self:IsVisible()
        return ScreenGui.Enabled
    end
    
    function self:Destroy()
        ScreenGui:Destroy()
    end
    
    return self
end

return Executor