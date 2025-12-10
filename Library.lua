-- c00lgui-style UI Library (safe version, no exploit features)
-- Made for loadstring importing

local library = {}

--=== UTILS ===--
local function Create(obj, props)
    local o = Instance.new(obj)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local RED = Color3.fromRGB(255, 0, 0)

--=== MAIN WINDOW ===--
function library:CreateWindow(title)
    local self = {}

    local ScreenGui = Create("ScreenGui", {
        Parent = game.CoreGui,
        Name = "c00lgui_UI"
    })

    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 420, 0, 450),
        Position = UDim2.new(0.5, -210, 0.5, -225),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BorderColor3 = RED,
        BorderSizePixel = 2
    })

    local Title = Create("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = title or "c00lgui UI",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.SourceSans,
        TextSize = 20
    })

    local Content = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1,0,1,-70),
        Position = UDim2.new(0,0,0,35),
        BackgroundTransparency = 1
    })

    local UIGrid = Create("UIGridLayout", {
        Parent = Content,
        CellSize = UDim2.new(0, 200, 0, 35),
        FillDirectionMaxCells = 2,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })

    local Close = Create("TextButton", {
        Parent = Main,
        Size = UDim2.new(1,0,0,35),
        Position = UDim2.new(0,0,1,-35),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BorderColor3 = RED,
        BorderSizePixel = 2,
        Text = "Close",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.SourceSans,
        TextSize = 20
    })

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- STORAGE
    self.Content = Content

    --=== ELEMENTS ===--

    function self:Button(text, callback)
        local b = Create("TextButton", {
            Parent = Content,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Text = text,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.SourceSans,
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
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Text = text.." : "..tostring(value),
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.SourceSans,
            TextSize = 18
        })

        b.MouseButton1Click:Connect(function()
            value = not value
            b.Text = text.." : "..tostring(value)
            if callback then callback(value) end
        end)

        return b
    end

    function self:Slider(text, min, max, default, callback)
        local sliderFrame = Create("Frame", {
            Parent = Content,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BorderColor3 = RED,
            BorderSizePixel = 2,
            Size = UDim2.new(0,200,0,35)
        })

        local label = Create("TextLabel", {
            Parent = sliderFrame,
            Size = UDim2.new(1,0,0,18),
            BackgroundTransparency = 1,
            Text = text.." : "..default,
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.SourceSans,
            TextSize = 16
        })

        local bar = Create("Frame", {
            Parent = sliderFrame,
            Size = UDim2.new(1, -10, 0, 10),
            Position = UDim2.new(0,5,0,20),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderColor3 = RED,
            BorderSizePixel = 2
        })

        local fill = Create("Frame", {
            Parent = bar,
            Size = UDim2.new((default-min)/(max-min),0,1,0),
            BackgroundColor3 = RED,
            BorderSizePixel = 0
        })

        bar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = game:GetService("RunService").RenderStepped:Connect(function()
                    local mouse = game:GetService("UserInputService"):GetMouseLocation().X
                    local x = math.clamp(mouse - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                    fill.Size = UDim2.new(x/bar.AbsoluteSize.X,0,1,0)

                    local value = math.floor(min + (max-min)*(x/bar.AbsoluteSize.X))
                    label.Text = text.." : "..value
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

    return self
end

return library
