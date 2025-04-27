--// Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local floorsFolder = workspace:WaitForChild("Map"):WaitForChild("Floors")
local proximityDistance = 25 -- distancia de detección

--// Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModelDetectorGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Parent = screenGui

local modelNameLabel = Instance.new("TextLabel")
modelNameLabel.Size = UDim2.new(1, 0, 0.6, 0)
modelNameLabel.Position = UDim2.new(0, 0, 0, 0)
modelNameLabel.BackgroundTransparency = 1
modelNameLabel.TextColor3 = Color3.new(1, 1, 1)
modelNameLabel.TextScaled = true
modelNameLabel.Font = Enum.Font.GothamBold
modelNameLabel.Text = ""
modelNameLabel.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, 0, 0.4, 0)
copyButton.Position = UDim2.new(0, 0, 0.6, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.Gotham
copyButton.Text = "Copiar Nombre (o pulsa Q)"
copyButton.Parent = frame

--// Variables de detección
local closestModel = nil

--// Función para copiar al portapapeles
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    end
end

--// Función para buscar el modelo más cercano correctamente
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

--// Botón de copiar
copyButton.MouseButton1Click:Connect(function()
    if closestModel then
        copyToClipboard(closestModel.Name)
    end
end)

--// Tecla Q para copiar
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
        if closestModel then
            copyToClipboard(closestModel.Name)
        end
    end
end)

--// Loop principal
task.spawn(function()
    while task.wait(0.2) do
        closestModel = findClosestModel()

        if closestModel then
            modelNameLabel.Text = closestModel.Name
            frame.Visible = true
            --print("Detectado: "..closestModel.Name)
        else
            frame.Visible = false
        end
    end
end)
