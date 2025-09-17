-- Targeted Islands Item Duplicator - Based on Game Path Analysis
-- Focuses on the most effective paths for item distribution
-- Uses specific networking and inventory systems identified from path analysis

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables
local uiVisible = false
local exitScript = false
local screenGui
local frame
local idTextBox
local amountTextBox
local addButton
local statusLabel

-- Targeted paths based on game analysis
local targetedPaths = {
    -- Core networking systems (most likely to handle item distribution)
    networking = {
        "game:GetService('ReplicatedStorage')['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events']",
        "game:GetService('ReplicatedStorage')['functions-@easy-games/game-core:shared/game-core-networking@getFunctions.Functions']",
        "game:GetService('ReplicatedStorage')['events-@easy-games/lobby:shared/lobby-networking@getEvents.Events']",
        "game:GetService('ReplicatedStorage')['functions-@easy-games/lobby:shared/lobby-networking@getFunctions.Functions']"
    },

    -- Direct tool access
    tools = {
        "game:GetService('ReplicatedStorage').Tools",
        "game:GetService('StarterPack')",
        "game:GetService('StarterGui')"
    },

    -- Memory manipulation (advanced technique)
    memory = {
        "game:GetService('Stats').PerformanceStats.Memory.CoreMemory",
        "game:GetService('Stats').PerformanceStats.Memory.PlaceMemory"
    }
}

-- Path resolver
function resolvePath(pathString)
    local success, result = pcall(function()
        return loadstring("return " .. pathString)()
    end)
    return success and result or nil
end

-- Targeted item addition using most effective methods
function addItemTargeted(targetPlayer, itemId, amount)
    print("🎯 Starting targeted duplication for item ID " .. itemId .. " x" .. amount)

    local methods = {
        -- Method 1: Core networking events (most effective)
        function()
            print("🔥 Method 1: Core networking events")
            local coreEvents = resolvePath(targetedPaths.networking[1])
            if coreEvents then
                print("✅ Found core networking events")

                -- Try multiple event types that might handle item distribution
                local eventsToTry = {
                    "useAbility",
                    "requestCodeGenUpdate",
                    "sendCodeGenUpdate",
                    "abilityUsed",
                    "sendInfoNotification",
                    "announcementEvent"
                }

                for _, eventName in pairs(eventsToTry) do
                    local event = coreEvents:FindFirstChild(eventName)
                    if event and event:IsA("RemoteEvent") then
                        print("📡 Trying event: " .. eventName)

                        -- Try different parameter combinations
                        local paramSets = {
                            {itemId, amount},
                            {itemId = itemId, amount = amount},
                            {"give", itemId, amount},
                            {"add", itemId, amount},
                            {type = "item", id = itemId, quantity = amount}
                        }

                        for _, params in pairs(paramSets) do
                            pcall(function()
                                event:FireServer(unpack(params))
                            end)
                            task.wait(0.05) -- Brief delay between attempts
                        end
                    end
                end
                return true
            end
            return false
        end,

        -- Method 2: Core networking functions
        function()
            print("🔥 Method 2: Core networking functions")
            local coreFunctions = resolvePath(targetedPaths.networking[2])
            if coreFunctions then
                print("✅ Found core networking functions")

                local functionsToTry = {
                    "s:redeemCode",
                    "s:regenCodeGenerator"
                }

                for _, funcName in pairs(functionsToTry) do
                    local func = coreFunctions:FindFirstChild(funcName)
                    if func and func:IsA("RemoteFunction") then
                        print("📡 Trying function: " .. funcName)

                        local codeSets = {
                            "ITEM_" .. itemId .. "_" .. amount,
                            "GIVE_" .. itemId,
                            "REWARD_" .. itemId,
                            tostring(itemId),
                            {itemId = itemId, amount = amount}
                        }

                        for _, code in pairs(codeSets) do
                            pcall(function()
                                local result = func:InvokeServer(code)
                                print("📋 Function result: " .. tostring(result))
                            end)
                            task.wait(0.05)
                        end
                    end
                end
                return true
            end
            return false
        end,

        -- Method 3: Direct tool manipulation from ReplicatedStorage
        function()
            print("🔥 Method 3: Direct tool manipulation")
            local toolsFolder = resolvePath(targetedPaths.tools[1])
            if toolsFolder then
                print("✅ Found Tools folder")

                -- Look for tools that match the item ID or create new ones
                for _, tool in pairs(toolsFolder:GetChildren()) do
                    if tool:IsA("Tool") then
                        -- Try to clone and add to backpack
                        local success, clonedTool = pcall(function()
                            return tool:Clone()
                        end)

                        if success and clonedTool then
                            pcall(function()
                                clonedTool.Parent = targetPlayer.Backpack
                                print("✅ Added tool: " .. tool.Name)
                            end)
                        end
                    end
                end

                -- If no tools found, try to create a generic tool
                if #toolsFolder:GetChildren() == 0 then
                    print("📝 Creating generic tool")
                    pcall(function()
                        local newTool = Instance.new("Tool")
                        newTool.Name = "Item_" .. itemId
                        newTool.Parent = targetPlayer.Backpack
                        print("✅ Created generic tool: " .. newTool.Name)
                    end)
                end

                return true
            end
            return false
        end,

        -- Method 4: Memory-based manipulation (advanced)
        function()
            print("🔥 Method 4: Memory manipulation")
            local coreMemory = resolvePath(targetedPaths.memory[1])
            if coreMemory then
                print("✅ Found core memory system")

                -- Look for inventory-related memory categories
                local memoryCategories = {
                    "internal/ScriptContext",
                    "lua/bytecode",
                    "internal/RuntimeScriptService"
                }

                for _, category in pairs(memoryCategories) do
                    local memCategory = coreMemory:FindFirstChild(category)
                    if memCategory then
                        print("🧠 Found memory category: " .. category)

                        -- Try to manipulate memory values
                        pcall(function()
                            if memCategory:IsA("NumberValue") or memCategory:IsA("IntValue") then
                                local currentValue = memCategory.Value
                                memCategory.Value = currentValue + amount
                                print("📊 Modified memory: " .. currentValue .. " -> " .. memCategory.Value)
                            end
                        end)
                    end
                end
                return true
            end
            return false
        end,

        -- Method 5: Lobby networking (backup)
        function()
            print("🔥 Method 5: Lobby networking")
            local lobbyEvents = resolvePath(targetedPaths.networking[3])
            if lobbyEvents then
                print("✅ Found lobby networking events")

                local lobbyEventsToTry = {
                    "event",
                    "createCustomMatch",
                    "teleportBegan",
                    "teleportCancelled"
                }

                for _, eventName in pairs(lobbyEventsToTry) do
                    local event = lobbyEvents:FindFirstChild(eventName)
                    if event and event:IsA("RemoteEvent") then
                        print("📡 Trying lobby event: " .. eventName)

                        pcall(function()
                            event:FireServer({
                                type = "item_request",
                                itemId = itemId,
                                amount = amount
                            })
                        end)
                        task.wait(0.05)
                    end
                end
                return true
            end
            return false
        end
    }

    -- Execute methods with timing
    local successCount = 0
    for i, method in ipairs(methods) do
        local startTime = tick()
        local success = pcall(method)
        local duration = tick() - startTime

        if success then
            successCount = successCount + 1
            print("✅ Method " .. i .. " completed successfully in " .. string.format("%.3f", duration) .. "s")
        else
            print("❌ Method " .. i .. " failed after " .. string.format("%.3f", duration) .. "s")
        end

        task.wait(0.1) -- Delay between methods
    end

    print("📊 Completed " .. successCount .. "/" .. #methods .. " methods successfully")
    return successCount > 0
end

-- Enhanced item addition function
function addItem()
    local itemId = tonumber(idTextBox.Text)
    local amount = tonumber(amountTextBox.Text)

    if not itemId or not amount then
        print("❌ Invalid ID or Amount")
        if statusLabel then
            statusLabel.Text = "Invalid ID or Amount"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        return
    end

    -- Find target player
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == "jdiishere6" or player.DisplayName == "jdiishere6" then
            targetPlayer = player
            break
        end
    end

    if not targetPlayer then
        print("❌ Target player 'jdiishere6' not found")
        if statusLabel then
            statusLabel.Text = "Player not found"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        return
    end

    print("🎯 Starting targeted duplication for " .. targetPlayer.Name)

    if statusLabel then
        statusLabel.Text = "Processing..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end

    -- Count initial items
    local initialCount = 0
    pcall(function()
        if targetPlayer.Backpack then
            initialCount = #targetPlayer.Backpack:GetChildren()
        end
    end)
    print("📊 Initial backpack count: " .. initialCount)

    -- Execute targeted duplication
    local success = addItemTargeted(targetPlayer, itemId, amount)

    -- Count final items
    local finalCount = 0
    pcall(function()
        if targetPlayer.Backpack then
            finalCount = #targetPlayer.Backpack:GetChildren()
        end
    end)
    print("📊 Final backpack count: " .. finalCount)

    local itemsAdded = finalCount - initialCount
    print("📈 Items added: " .. itemsAdded)

    -- Update status
    if success and itemsAdded > 0 then
        print("🎉 SUCCESS! Added " .. itemsAdded .. " items")
        if statusLabel then
            statusLabel.Text = "Success! Added " .. itemsAdded .. " items"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    elseif success and itemsAdded == 0 then
        print("⚠️ Methods executed but no items detected")
        if statusLabel then
            statusLabel.Text = "Methods executed - check manually"
            statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    else
        print("❌ FAILED: No methods succeeded")
        if statusLabel then
            statusLabel.Text = "Failed - No methods worked"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- Trigger inventory refresh
    pcall(function()
        local inventoryUpdateEvent = targetPlayer:FindFirstChild("InventoryUpdateEvent")
        if inventoryUpdateEvent then
            inventoryUpdateEvent:FireServer("refresh")
            inventoryUpdateEvent:FireServer({action = "refresh"})
        end
    end)
end

-- Create UI
function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Targeted Islands Duplicator"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(0, 50, 0, 20)
    idLabel.Position = UDim2.new(0, 20, 0, 50)
    idLabel.Text = "ID:"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = frame

    idTextBox = Instance.new("TextBox")
    idTextBox.Size = UDim2.new(0, 100, 0, 20)
    idTextBox.Position = UDim2.new(0, 70, 0, 50)
    idTextBox.Text = ""
    idTextBox.PlaceholderText = "Item ID"
    idTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    idTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idTextBox.Parent = frame

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(0, 60, 0, 20)
    amountLabel.Position = UDim2.new(0, 190, 0, 50)
    amountLabel.Text = "Amount:"
    amountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Parent = frame

    amountTextBox = Instance.new("TextBox")
    amountTextBox.Size = UDim2.new(0, 100, 0, 20)
    amountTextBox.Position = UDim2.new(0, 250, 0, 50)
    amountTextBox.Text = ""
    amountTextBox.PlaceholderText = "Amount"
    amountTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    amountTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountTextBox.Parent = frame

    addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0, 150, 0, 30)
    addButton.Position = UDim2.new(0, 125, 0, 90)
    addButton.Text = "Add Item (Targeted)"
    addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.Parent = frame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 360, 0, 40)
    statusLabel.Position = UDim2.new(0, 20, 0, 140)
    statusLabel.Text = "Ready - Using targeted path analysis"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextWrapped = true
    statusLabel.Parent = frame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 360, 0, 50)
    infoLabel.Position = UDim2.new(0, 20, 0, 180)
    infoLabel.Text = "Based on game path analysis\nUses core networking & memory systems\nPress G to toggle, Shift+G to exit"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextWrapped = true
    infoLabel.TextSize = 11
    infoLabel.Parent = frame

    addButton.MouseButton1Click:Connect(function()
        if addButton.Text == "Working..." then return end

        addButton.Text = "Working..."
        addButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

        task.spawn(function()
            addItem()

            addButton.Text = "Add Item (Targeted)"
            addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end)

    frame.Visible = true
end

-- Input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            exitScript = true
        else
            uiVisible = not uiVisible
            if frame then
                frame.Visible = uiVisible
            end
        end
    end
end)

-- Initialize
print("🎯 Targeted Islands Duplicator initialized")
print("📊 Using " .. #targetedPaths.networking + #targetedPaths.tools + #targetedPaths.memory .. " targeted paths")
print("🎯 Press G to toggle UI, Shift+G to exit")

createUI()

-- Main loop
while not exitScript do
    task.wait(0.1)
end

-- Cleanup
if screenGui then
    screenGui:Destroy()
end

print("Script exited")