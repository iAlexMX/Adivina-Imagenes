--// Variables principales
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Interfaz
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "NearestModelUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2

local modelNameLabel = Instance.new("TextLabel", frame)
modelNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
modelNameLabel.Position = UDim2.new(0, 0, 0, 0)
modelNameLabel.BackgroundTransparency = 1
modelNameLabel.TextColor3 = Color3.new(1, 1, 1)
modelNameLabel.TextScaled = true
modelNameLabel.Text = "Nearest Model: None"

local copyButton = Instance.new("TextButton", frame)
copyButton.Size = UDim2.new(0.6, 0, 0.3, 0)
copyButton.Position = UDim2.new(0.2, 0, 0.65, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Text = "Copy Name"

--// Funciones
local function findNearestModel()
    local closestModel = nil
    local shortestDistance = math.huge
    local myPosition = humanoidRootPart.Position
    
    for floorIndex = 0, 12 do
        local floorFolder = workspace:FindFirstChild("Map") and workspace.Map.Floors:FindFirstChild("Floor " .. floorIndex)
        if floorFolder then
            local categoriesFolder = floorFolder:FindFirstChild("Categories")
            if categoriesFolder then
                for _, category in pairs(categoriesFolder:GetChildren()) do
                    local stagesFolder = category:FindFirstChild("Stages")
                    if stagesFolder then
                        for _, model in pairs(stagesFolder:GetChildren()) do
                            if model:IsA("Model") and model.PrimaryPart then
                                local distance = (model.PrimaryPart.Position - myPosition).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    closestModel = model
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestModel
end

local function updateNearestModel()
    local nearestModel = findNearestModel()
    if nearestModel then
        modelNameLabel.Text = "Nearest Model: " .. nearestModel.Name
        copyButton:SetAttribute("ModelName", nearestModel.Name)
    else
        modelNameLabel.Text = "Nearest Model: None"
        copyButton:SetAttribute("ModelName", nil)
    end
end

-- Copiar al portapapeles
local function copyModelName()
    local name = copyButton:GetAttribute("ModelName")
    if name then
        setclipboard(name)
    end
end

-- Conexiones
copyButton.MouseButton1Click:Connect(copyModelName)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        copyModelName()
    end
end)

-- Actualizar automáticamente cada medio segundo
while true do
    updateNearestModel()
    task.wait(0.5)
end
