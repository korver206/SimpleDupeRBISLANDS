-- Islands Item Duplicator Script for Vega X
-- Scans remotes and functions, adds items to backpack by ID and amount
-- Items stack infinitely in one slot
-- UI on bottom left, G to toggle, Shift+G to exit

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables
local remotes = {}
local funcs = {}
local uiVisible = false
local exitScript = false
local screenGui
local frame
local idTextBox
local amountTextBox
local addButton

-- Scan for all remotes
function scanRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj)
            print("Found remote: " .. obj.Name .. " at " .. obj:GetFullName())
        end
    end
    print("Total remotes found: " .. #remotes)
end

-- Scan for all functions
function scanFunctions()
    for _, func in pairs(getgc()) do
        if type(func) == "function" then
            local info = debug.getinfo(func)
            if info.name then
                table.insert(funcs, func)
                print("Found function: " .. info.name)
            end
        end
    end
    print("Total functions found: " .. #funcs)
end

-- Create simple UI on bottom left
function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0, 10, 1, -160)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Item Duplicator"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, 0, 0, 20)
    idLabel.Position = UDim2.new(0, 0, 0, 25)
    idLabel.Text = "Item ID:"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = frame

    idTextBox = Instance.new("TextBox")
    idTextBox.Size = UDim2.new(1, -10, 0, 20)
    idTextBox.Position = UDim2.new(0, 5, 0, 45)
    idTextBox.Text = ""
    idTextBox.PlaceholderText = "Enter Item ID"
    idTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    idTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idTextBox.Parent = frame

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(1, 0, 0, 20)
    amountLabel.Position = UDim2.new(0, 0, 0, 70)
    amountLabel.Text = "Amount:"
    amountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Parent = frame

    amountTextBox = Instance.new("TextBox")
    amountTextBox.Size = UDim2.new(1, -10, 0, 20)
    amountTextBox.Position = UDim2.new(0, 5, 0, 90)
    amountTextBox.Text = ""
    amountTextBox.PlaceholderText = "Enter Amount"
    amountTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    amountTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountTextBox.Parent = frame

    addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(1, -10, 0, 25)
    addButton.Position = UDim2.new(0, 5, 0, 115)
    addButton.Text = "Add Item"
    addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.Parent = frame

    addButton.MouseButton1Click:Connect(function()
        addItem()
    end)

    frame.Visible = false
end

-- Add item function
function addItem()
    local itemId = tonumber(idTextBox.Text)
    local amount = tonumber(amountTextBox.Text)
    if not itemId or not amount then
        print("Invalid ID or Amount")
        return
    end

    -- Try remotes that seem related to inventory/items
    for _, remote in pairs(remotes) do
        local name = remote.Name:lower()
        local path = remote:GetFullName():lower()
        if string.find(name, "inventory") or string.find(name, "item") or string.find(name, "add") or string.find(path, "inventory") then
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer(itemId, amount)
                end)
            elseif remote:IsA("RemoteFunction") then
                pcall(function()
                    remote:InvokeServer(itemId, amount)
                end)
            end
            print("Called remote: " .. remote.Name)
        end
    end

    -- Try functions that seem related
    for _, func in pairs(funcs) do
        local info = debug.getinfo(func)
        if info.name then
            local name = info.name:lower()
            if string.find(name, "add") or string.find(name, "give") or string.find(name, "item") then
                pcall(function()
                    func(itemId, amount)
                end)
                print("Called function: " .. info.name)
            end
        end
    end

    print("Attempted to add item ID " .. itemId .. " x" .. amount)
end

-- Key input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            exitScript = true
        else
            uiVisible = not uiVisible
            frame.Visible = uiVisible
        end
    end
end)

-- Main loop
scanRemotes()
scanFunctions()
createUI()

while not exitScript do
    task.wait(0.1)
end

-- Cleanup
if screenGui then
    screenGui:Destroy()
end

print("Script exited")