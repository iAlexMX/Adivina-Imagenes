local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local floorsFolder = workspace:WaitForChild("Map"):WaitForChild("Floors")
local proximityDistance = 25

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModelDetectorGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0.5, -150, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Parent = screenGui

local modelNameLabel = Instance.new("TextLabel")
modelNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
modelNameLabel.Position = UDim2.new(0, 0, 0, 0)
modelNameLabel.BackgroundTransparency = 1
modelNameLabel.TextColor3 = Color3.new(1, 1, 1)
modelNameLabel.TextScaled = true
modelNameLabel.Font = Enum.Font.GothamBold
modelNameLabel.Text = ""
modelNameLabel.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, 0, 0.3, 0)
copyButton.Position = UDim2.new(0, 0, 0.5, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.Gotham
copyButton.Text = "Copiar Nombre (o pulsa Q)"
copyButton.Parent = frame

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0.2, 0)
creditLabel.Position = UDim2.new(0, 0, 0.8, 0)
creditLabel.BackgroundTransparency = 100
creditLabel.TextColor3 = Color3.new(1, 1, 1)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.GothamSemibold
creditLabel.Text = "by AlexScriptX"
creditLabel.TextSize = 12
creditLabel.Parent = frame

local closestModel = nil
local scriptEnabled = true

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    end
end

local function findClosestModel()
    local nearest = nil
    local nearestDistance = proximityDistance

    for i = 0, 12 do
        local floor = floorsFolder:FindFirstChild("Floor " .. i)
        if floor then
            local categoriesFolder = floor:FindFirstChild("Categories")
            if categoriesFolder then
                for _, category in ipairs(categoriesFolder:GetChildren()) do
                    if category:IsA("Folder") then
                        local stagesFolder = category:FindFirstChild("Stages")
                        if stagesFolder then
                            for _, model in ipairs(stagesFolder:GetChildren()) do
                                if model:IsA("Model") then
                                    local parts = model:GetDescendants()
                                    local center = Vector3.new(0,0,0)
                                    local partCount = 0

                                    for _, part in ipairs(parts) do
                                        if part:IsA("BasePart") then
                                            center = center + part.Position
                                            partCount = partCount + 1
                                        end
                                    end

                                    if partCount > 0 then
                                        center = center / partCount
                                        local distance = (humanoidRootPart.Position - center).Magnitude
                                        if distance <= nearestDistance then
                                            nearest = model
                                            nearestDistance = distance
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nearest
end

copyButton.MouseButton1Click:Connect(function()
    if closestModel then
        copyToClipboard(closestModel.Name)
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Q then
            if closestModel then
                copyToClipboard(closestModel.Name)
            end
        elseif input.KeyCode == Enum.KeyCode.M then
            scriptEnabled = false
            frame.Visible = false

            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 300, 0, 50)
            notification.Position = UDim2.new(0.5, -150, 0.85, 0)
            notification.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            notification.TextColor3 = Color3.new(1, 1, 1)
            notification.Text = "El script se ha cerrado."
            notification.TextScaled = true
            notification.Font = Enum.Font.GothamBold
            notification.Parent = screenGui

            task.wait(5)
            notification:Destroy()
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if scriptEnabled then
            closestModel = findClosestModel()

            if closestModel then
                modelNameLabel.Text = closestModel.Name
                frame.Visible = true
                    
                copyToClipboard(closestModel.Name)
            else
                frame.Visible = false
            end
        end
    end
end)
