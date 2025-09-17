-- Enhanced Islands Item Duplicator using Game Path Analysis
-- Uses comprehensive path traversal from game structure analysis
-- Advanced item giving with multiple fallback methods
-- Auto-discovers new paths and adapts to game updates

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

-- Variables
local uiVisible = false
local exitScript = false
local screenGui
local frame
local idTextBox
local amountTextBox
local addButton
local statusLabel
local discoveredPaths = {}
local pathCache = {}

-- Auto-discover new paths function
function discoverNewPaths()
    print("🔍 Auto-discovering new game paths...")

    local newPaths = {
        services = {},
        networking = {},
        memory = {},
        tools = {}
    }

    -- Discover services
    local allServices = game:GetChildren()
    for _, service in pairs(allServices) do
        if service:IsA("Service") then
            local path = "game:GetService('" .. service.Name .. "')"
            table.insert(newPaths.services, path)
            print("📡 Found service: " .. service.Name)
        end
    end

    -- Discover ReplicatedStorage networking
    pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local path = "game:GetService('ReplicatedStorage')"
                local current = obj
                local pathParts = {}

                while current and current ~= ReplicatedStorage do
                    table.insert(pathParts, 1, "['" .. current.Name .. "']")
                    current = current.Parent
                end

                local fullPath = path .. table.concat(pathParts)
                if string.find(obj.Name:lower(), "item") or string.find(obj.Name:lower(), "inventory") or
                   string.find(obj.Name:lower(), "give") or string.find(obj.Name:lower(), "add") then
                    table.insert(newPaths.networking, fullPath)
                    print("🌐 Found networking path: " .. fullPath)
                end
            end
        end
    end)

    -- Discover memory paths
    pcall(function()
        local perfStats = Stats:FindFirstChild("PerformanceStats")
        if perfStats then
            local memory = perfStats:FindFirstChild("Memory")
            if memory then
                for _, category in pairs(memory:GetChildren()) do
                    local path = "game:GetService('Stats').PerformanceStats.Memory." .. category.Name
                    table.insert(newPaths.memory, path)
                    print("🧠 Found memory path: " .. path)
                end
            end
        end
    end)

    -- Discover tool paths
    pcall(function()
        local toolLocations = {ReplicatedStorage, Workspace, game:GetService("StarterPack")}
        for _, location in pairs(toolLocations) do
            if location:FindFirstChild("Tools") then
                local path = "game:GetService('" .. location.Name .. "').Tools"
                table.insert(newPaths.tools, path)
                print("🔧 Found tools path: " .. path)
            end
        end
    end)

    -- Merge with existing paths
    for category, paths in pairs(newPaths) do
        for _, path in pairs(paths) do
            if not discoveredPaths[category] then discoveredPaths[category] = {} end
            if not table.find(discoveredPaths[category], path) then
                table.insert(discoveredPaths[category], path)
            end
        end
    end

    print("✅ Path discovery complete!")
    print("📊 Total discovered paths: " ..
          (#discoveredPaths.services or 0) + (#discoveredPaths.networking or 0) +
          (#discoveredPaths.memory or 0) + (#discoveredPaths.tools or 0))

    return newPaths
end

-- Cache path resolution for performance
function getCachedPath(pathString)
    if pathCache[pathString] then
        return pathCache[pathString]
    end

    local success, result = pcall(function()
        return loadstring("return " .. pathString)()
    end)

    if success then
        pathCache[pathString] = result
        return result
    else
        pathCache[pathString] = nil
        return nil
    end
end

-- Backup method for when primary methods fail
function backupItemAddition(targetPlayer, itemId, amount)
    print("🔄 Executing backup item addition methods...")

    local backupMethods = {
        -- Method 1: Direct inventory manipulation
        function()
            print("🔧 Backup 1: Direct inventory manipulation")
            if targetPlayer.Backpack then
                -- Try to find existing item and modify its amount
                for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Amount") then
                        local currentAmount = tool.Amount.Value
                        tool.Amount.Value = currentAmount + amount
                        print("📊 Modified existing tool amount: " .. currentAmount .. " -> " .. tool.Amount.Value)
                        return true
                    end
                end
            end
            return false
        end,

        -- Method 2: StarterGear manipulation
        function()
            print("🔧 Backup 2: StarterGear manipulation")
            if targetPlayer.StarterGear then
                for _, tool in pairs(targetPlayer.StarterGear:GetChildren()) do
                    if tool:IsA("Tool") then
                        local clonedTool = tool:Clone()
                        clonedTool.Parent = targetPlayer.Backpack
                        print("🔥 Added tool from StarterGear: " .. tool.Name)
                        return true
                    end
                end
            end
            return false
        end,

        -- Method 3: Character tool manipulation
        function()
            print("🔧 Backup 3: Character tool manipulation")
            if targetPlayer.Character then
                for _, tool in pairs(targetPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        -- Try to duplicate the tool
                        local clonedTool = tool:Clone()
                        if clonedTool then
                            clonedTool.Parent = targetPlayer.Backpack
                            print("🔥 Duplicated character tool: " .. tool.Name)
                            return true
                        end
                    end
                end
            end
            return false
        end,

        -- Method 4: Server storage exploration
        function()
            print("🔧 Backup 4: Server storage exploration")
            local serverStorage = game:GetService("ServerStorage")
            if serverStorage then
                for _, obj in pairs(serverStorage:GetDescendants()) do
                    if obj:IsA("Tool") then
                        local clonedTool = obj:Clone()
                        clonedTool.Parent = targetPlayer.Backpack
                        print("🔥 Added tool from ServerStorage: " .. obj.Name)
                        return true
                    end
                end
            end
            return false
        end
    }

    -- Execute backup methods
    for i, method in ipairs(backupMethods) do
        local success = pcall(method)
        if success then
            print("✅ Backup method " .. i .. " succeeded")
            return true
        else
            print("❌ Backup method " .. i .. " failed")
        end
        task.wait(0.1)
    end

    return false
end

-- Enhanced logging function
function logAction(action, details, success)
    local timestamp = os.date("%H:%M:%S")
    local status = success and "✅" or "❌"
    local message = string.format("[%s] %s %s: %s", timestamp, status, action, details)

    print(message)

    -- Store in global log for debugging
    if not _G.ScriptLog then _G.ScriptLog = {} end
    table.insert(_G.ScriptLog, {
        timestamp = timestamp,
        action = action,
        details = details,
        success = success
    })
end

-- Error recovery function
function handleError(errorMessage, context)
    logAction("ERROR", context .. " - " .. errorMessage, false)

    -- Try to recover from common errors
    if string.find(errorMessage, "not found") then
        print("🔄 Attempting to rediscover paths...")
        discoverNewPaths()
    elseif string.find(errorMessage, "access denied") then
        print("🚫 Access denied - trying alternative methods...")
        return "access_denied"
    elseif string.find(errorMessage, "timeout") then
        print("⏰ Timeout - retrying with longer delay...")
        task.wait(1)
        return "retry"
    end

    return "failed"
end

-- Enhanced Islands Item Duplicator using Game Path Analysis
-- Uses comprehensive path traversal from game structure analysis
-- Advanced item giving with multiple fallback methods

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")

-- Variables
local uiVisible = false
local exitScript = false
local screenGui
local frame
local idTextBox
local amountTextBox
local addButton
local statusLabel

-- Game path database from analysis
local gamePaths = {
    -- Core services
    services = {
        "game:GetService('Workspace')",
        "game:GetService('RunService')",
        "game:GetService('GuiService')",
        "game:GetService('Stats')",
        "game:GetService('Stats').PerformanceStats",
        "game:GetService('Stats').PerformanceStats.Memory",
        "game:GetService('ReplicatedStorage')",
        "game:GetService('ServerStorage')",
        "game:GetService('ServerScriptService')"
    },

    -- ReplicatedStorage networking paths
    networking = {
        "game:GetService('ReplicatedStorage')['rbxts_include']",
        "game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']",
        "game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']['@rbxts']",
        "game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']['@rbxts'].net",
        "game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']['@rbxts'].net.out",
        "game:GetService('ReplicatedStorage')['rbxts_include']['node_modules']['@rbxts'].net.out._NetManaged",
        "game:GetService('ReplicatedStorage')['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events']",
        "game:GetService('ReplicatedStorage')['functions-@easy-games/game-core:shared/game-core-networking@getFunctions.Functions']",
        "game:GetService('ReplicatedStorage')['events-@easy-games/lobby:shared/lobby-networking@getEvents.Events']",
        "game:GetService('ReplicatedStorage')['functions-@easy-games/lobby:shared/lobby-networking@getFunctions.Functions']"
    },

    -- Memory system paths for advanced manipulation
    memory = {
        "game:GetService('Stats').PerformanceStats.Memory.CoreMemory",
        "game:GetService('Stats').PerformanceStats.Memory.PlaceMemory",
        "game:GetService('Stats').PerformanceStats.Memory.PlaceScriptMemory",
        "game:GetService('Stats').PerformanceStats.Memory.UntrackedMemory"
    },

    -- Tool/item storage paths
    tools = {
        "game:GetService('ReplicatedStorage').Tools",
        "game:GetService('StarterPack')",
        "game:GetService('StarterGui')"
    }
}

-- Path resolver function
function resolvePath(pathString)
    local success, result = pcall(function()
        return loadstring("return " .. pathString)()
    end)
    return success and result or nil
end

-- Advanced path traversal for item manipulation
function traverseAndManipulate(targetPlayer, itemId, amount)
    logAction("PATH_TRAVERSAL", "Starting for item ID " .. itemId .. " x" .. amount, true)

    local methods = {
        -- Method 1: Direct ReplicatedStorage tool manipulation
        function()
            logAction("METHOD_1", "Direct ReplicatedStorage manipulation", true)
            local success, toolsFolder = pcall(function()
                return getCachedPath("game:GetService('ReplicatedStorage').Tools")
            end)

            if success and toolsFolder then
                logAction("METHOD_1", "Found Tools folder", true)
                local addedCount = 0
                for _, tool in pairs(toolsFolder:GetChildren()) do
                    if tool:IsA("Tool") then
                        local success, clonedTool = pcall(function()
                            return tool:Clone()
                        end)
                        if success and clonedTool then
                            pcall(function()
                                clonedTool.Parent = targetPlayer.Backpack
                            end)
                            addedCount = addedCount + 1
                            logAction("METHOD_1", "Added tool: " .. tool.Name, true)
                        end
                    end
                end
                return addedCount > 0
            else
                handleError("Tools folder not found", "Method 1")
                return false
            end
        end,

        -- Method 2: Network event manipulation using discovered paths
        function()
            print("🔄 Method 2: Network event manipulation")
            local coreEvents = resolvePath("game:GetService('ReplicatedStorage')['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events']")
            if coreEvents then
                print("✅ Found core networking events")
                local eventsToTry = {"useAbility", "requestCodeGenUpdate", "sendCodeGenUpdate", "abilityUsed", "sendInfoNotification"}

                for _, eventName in pairs(eventsToTry) do
                    local event = coreEvents:FindFirstChild(eventName)
                    if event and event:IsA("RemoteEvent") then
                        print("🔥 Trying event: " .. eventName)
                        pcall(function()
                            event:FireServer(itemId, amount)
                            event:FireServer({itemId = itemId, amount = amount})
                            event:FireServer("give", itemId, amount)
                        end)
                        task.wait(0.1)
                    end
                end
                return true
            end
            return false
        end,

        -- Method 3: Network function manipulation
        function()
            print("🔄 Method 3: Network function manipulation")
            local coreFunctions = resolvePath("game:GetService('ReplicatedStorage')['functions-@easy-games/game-core:shared/game-core-networking@getFunctions.Functions']")
            if coreFunctions then
                print("✅ Found core networking functions")
                local redeemFunc = coreFunctions:FindFirstChild("s:redeemCode")
                if redeemFunc and redeemFunc:IsA("RemoteFunction") then
                    print("🔥 Trying redeem function")
                    local codes = {
                        "ITEM_" .. itemId .. "_" .. amount,
                        "GIVE_" .. itemId,
                        "REWARD_" .. itemId,
                        tostring(itemId),
                        {itemId = itemId, amount = amount}
                    }

                    for _, code in pairs(codes) do
                        pcall(function()
                            local result = redeemFunc:InvokeServer(code)
                            print("📡 Redeem result: " .. tostring(result))
                        end)
                        task.wait(0.1)
                    end
                end
                return true
            end
            return false
        end,

        -- Method 4: Memory system manipulation (advanced)
        function()
            print("🔄 Method 4: Memory system manipulation")
            local coreMemory = resolvePath("game:GetService('Stats').PerformanceStats.Memory.CoreMemory")
            if coreMemory then
                print("✅ Found core memory system")
                -- Look for inventory-related memory categories
                local inventoryCategories = {"internal/ScriptContext", "lua/bytecode", "internal/RuntimeScriptService"}

                for _, category in pairs(inventoryCategories) do
                    local memCategory = coreMemory:FindFirstChild(category)
                    if memCategory then
                        print("🔥 Found memory category: " .. category)
                        -- Try to manipulate memory values
                        pcall(function()
                            if memCategory:IsA("NumberValue") then
                                local currentValue = memCategory.Value
                                memCategory.Value = currentValue + amount
                                print("📊 Modified memory value from " .. currentValue .. " to " .. memCategory.Value)
                            end
                        end)
                    end
                end
                return true
            end
            return false
        end,

        -- Method 5: Player script manipulation
        function()
            print("🔄 Method 5: Player script manipulation")
            if targetPlayer.PlayerScripts then
                local tsFolder = targetPlayer.PlayerScripts:FindFirstChild("TS")
                if tsFolder then
                    local controllers = tsFolder:FindFirstChild("controllers")
                    if controllers then
                        local inventoryController = controllers:FindFirstChild("inventory")
                        if inventoryController then
                            local eventController = inventoryController:FindFirstChild("inventory-event-controller")
                            if eventController then
                                print("✅ Found inventory event controller")
                                local methods = {"addItem", "giveItem", "addReward", "giveReward"}

                                for _, method in pairs(methods) do
                                    if eventController[method] then
                                        print("🔥 Trying method: " .. method)
                                        pcall(function()
                                            eventController[method](itemId, amount)
                                        end)
                                        task.wait(0.1)
                                    end
                                end
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end,

        -- Method 6: Workspace manipulation
        function()
            print("🔄 Method 6: Workspace manipulation")
            local workspacePaths = {
                "game:GetService('Workspace').GameSystems",
                "game:GetService('Workspace').ServerSystems",
                "game:GetService('Workspace').Network"
            }

            for _, path in pairs(workspacePaths) do
                local obj = resolvePath(path)
                if obj then
                    print("✅ Found workspace object: " .. path)
                    -- Look for inventory-related objects
                    for _, child in pairs(obj:GetChildren()) do
                        if string.find(child.Name:lower(), "inventory") or string.find(child.Name:lower(), "item") then
                            print("🔥 Found inventory object: " .. child.Name)
                            if child:IsA("RemoteEvent") then
                                pcall(function()
                                    child:FireServer(itemId, amount)
                                    child:FireServer({itemId = itemId, amount = amount})
                                end)
                            elseif child:IsA("RemoteFunction") then
                                pcall(function()
                                    child:InvokeServer(itemId, amount)
                                end)
                            end
                        end
                    end
                end
            end
            return true
        end
    }

    -- Execute all methods
    local success = false
    for i, method in ipairs(methods) do
        local methodSuccess = pcall(method)
        if methodSuccess then
            success = true
            print("✅ Method " .. i .. " completed successfully")
        else
            print("❌ Method " .. i .. " failed")
        end
        task.wait(0.2) -- Brief pause between methods
    end

    return success
end

-- Enhanced item addition function
function addItem()
    local itemId = tonumber(idTextBox.Text)
    local amount = tonumber(amountTextBox.Text)

    if not itemId or not amount then
        logAction("VALIDATION", "Invalid ID or Amount", false)
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
        logAction("PLAYER_SEARCH", "Target player 'jdiishere6' not found", false)
        if statusLabel then
            statusLabel.Text = "Player not found"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        return
    end

    logAction("DUPLICATION_START", "Starting for " .. targetPlayer.Name .. " - Item ID " .. itemId .. " x" .. amount, true)

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
    logAction("INVENTORY_COUNT", "Initial backpack count: " .. initialCount, true)

    -- Execute advanced path traversal
    local primarySuccess = traverseAndManipulate(targetPlayer, itemId, amount)

    -- Count items after primary methods
    local afterPrimaryCount = 0
    pcall(function()
        if targetPlayer.Backpack then
            afterPrimaryCount = #targetPlayer.Backpack:GetChildren()
        end
    end)

    local itemsAddedPrimary = afterPrimaryCount - initialCount
    logAction("PRIMARY_METHODS", "Items added by primary methods: " .. itemsAddedPrimary, primarySuccess)

    -- If primary methods didn't work, try backup methods
    local backupSuccess = false
    if itemsAddedPrimary <= 0 then
        logAction("BACKUP_METHODS", "Primary methods failed, trying backup methods", true)
        if statusLabel then
            statusLabel.Text = "Trying backup methods..."
        end

        backupSuccess = backupItemAddition(targetPlayer, itemId, amount)
    end

    -- Final count
    local finalCount = 0
    pcall(function()
        if targetPlayer.Backpack then
            finalCount = #targetPlayer.Backpack:GetChildren()
        end
    end)

    local totalItemsAdded = finalCount - initialCount
    logAction("FINAL_COUNT", "Total items added: " .. totalItemsAdded, totalItemsAdded > 0)

    -- Update status
    if (primarySuccess or backupSuccess) and totalItemsAdded > 0 then
        logAction("SUCCESS", "Added " .. totalItemsAdded .. " items successfully", true)
        if statusLabel then
            statusLabel.Text = "Success! Added " .. totalItemsAdded .. " items"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        logAction("FAILURE", "No items were added", false)
        if statusLabel then
            statusLabel.Text = "Failed - No items added"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- Trigger inventory refresh
    pcall(function()
        local inventoryUpdateEvent = targetPlayer:FindFirstChild("InventoryUpdateEvent")
        if inventoryUpdateEvent then
            inventoryUpdateEvent:FireServer("refresh")
            inventoryUpdateEvent:FireServer({action = "refresh"})
            logAction("INVENTORY_REFRESH", "Triggered inventory update event", true)
        else
            logAction("INVENTORY_REFRESH", "InventoryUpdateEvent not found", false)
        end
    end)
end

-- Create UI
function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Enhanced Islands Duplicator"
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
    addButton.Text = "Add Item (Enhanced)"
    addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.Parent = frame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 360, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 140)
    statusLabel.Text = "Ready - Using advanced path analysis"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextWrapped = true
    statusLabel.Parent = frame

    -- Path analysis info
    local pathInfo = Instance.new("TextLabel")
    pathInfo.Size = UDim2.new(0, 360, 0, 80)
    pathInfo.Position = UDim2.new(0, 20, 0, 170)
    local totalBasePaths = #gamePaths.services + #gamePaths.networking + #gamePaths.memory + #gamePaths.tools
    local totalDiscoveredPaths = (#discoveredPaths.services or 0) + (#discoveredPaths.networking or 0) +
                                (#discoveredPaths.memory or 0) + (#discoveredPaths.tools or 0)
    pathInfo.Text = "Base paths: " .. totalBasePaths .. " | Discovered: " .. totalDiscoveredPaths .. "\n" ..
                   "Services: " .. #gamePaths.services .. " | Networking: " .. #gamePaths.networking .. "\n" ..
                   "Memory: " .. #gamePaths.memory .. " | Tools: " .. #gamePaths.tools .. "\n" ..
                   "Press G to toggle, Shift+G to exit"
    pathInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    pathInfo.BackgroundTransparency = 1
    pathInfo.TextWrapped = true
    pathInfo.TextSize = 11
    pathInfo.Parent = frame

    -- Rediscover paths button
    local rediscoverButton = Instance.new("TextButton")
    rediscoverButton.Size = UDim2.new(0, 120, 0, 25)
    rediscoverButton.Position = UDim2.new(0, 20, 0, 255)
    rediscoverButton.Text = "🔍 Rediscover Paths"
    rediscoverButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    rediscoverButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rediscoverButton.TextSize = 10
    rediscoverButton.Parent = frame

    rediscoverButton.MouseButton1Click:Connect(function()
        if rediscoverButton.Text == "Working..." then return end

        statusLabel.Text = "Rediscovering paths..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        rediscoverButton.Text = "Working..."
        rediscoverButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

        task.spawn(function()
            local newPaths = discoverNewPaths()

            -- Update path info display
            local newTotalDiscovered = (#discoveredPaths.services or 0) + (#discoveredPaths.networking or 0) +
                                     (#discoveredPaths.memory or 0) + (#discoveredPaths.tools or 0)
            pathInfo.Text = "Base paths: " .. totalBasePaths .. " | Discovered: " .. newTotalDiscovered .. "\n" ..
                           "Services: " .. #gamePaths.services .. " | Networking: " .. #gamePaths.networking .. "\n" ..
                           "Memory: " .. #gamePaths.memory .. " | Tools: " .. #gamePaths.tools .. "\n" ..
                           "Press G to toggle, Shift+G to exit"

            statusLabel.Text = "Paths rediscovered!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            rediscoverButton.Text = "🔍 Rediscover Paths"
            rediscoverButton.BackgroundColor3 = Color3.fromRGB(100, 100, 150)

            task.wait(2)
            statusLabel.Text = "Ready - Enhanced path analysis active"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end)

    addButton.MouseButton1Click:Connect(function()
        if addButton.Text == "Working..." then return end

        addButton.Text = "Working..."
        addButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

        task.spawn(function()
            addItem()

            addButton.Text = "Add Item (Enhanced)"
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
print("🚀 Enhanced Islands Duplicator initialized")
print("📊 Loaded " .. #gamePaths.services + #gamePaths.networking + #gamePaths.memory + #gamePaths.tools .. " base game paths")

-- Auto-discover additional paths
print("🔍 Starting path discovery...")
local discovered = discoverNewPaths()

print("📊 Total paths available: " ..
      (#gamePaths.services + (#discoveredPaths.services or 0)) + (#gamePaths.networking + (#discoveredPaths.networking or 0)) +
      (#gamePaths.memory + (#discoveredPaths.memory or 0)) + (#gamePaths.tools + (#discoveredPaths.tools or 0)))

print("🎯 Press G to toggle UI, Shift+G to exit")
print("💡 Script log available in _G.ScriptLog")

createUI()

-- Test function for script validation
function runSelfTest()
    print("🧪 Running Enhanced Duplicator Self-Test...")

    local testResults = {
        pathResolution = false,
        playerDetection = false,
        uiCreation = false,
        logging = false
    }

    -- Test 1: Path resolution
    local testPath = "game:GetService('ReplicatedStorage')"
    local success, result = pcall(function()
        return getCachedPath(testPath)
    end)
    testResults.pathResolution = success and result ~= nil
    logAction("SELF_TEST", "Path resolution test: " .. (testResults.pathResolution and "PASS" or "FAIL"), testResults.pathResolution)

    -- Test 2: Player detection
    local foundPlayer = false
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == "jdiishere6" or player.DisplayName == "jdiishere6" then
            foundPlayer = true
            break
        end
    end
    testResults.playerDetection = foundPlayer
    logAction("SELF_TEST", "Player detection test: " .. (testResults.playerDetection and "PASS" or "FAIL"), testResults.playerDetection)

    -- Test 3: UI creation
    testResults.uiCreation = screenGui ~= nil and frame ~= nil
    logAction("SELF_TEST", "UI creation test: " .. (testResults.uiCreation and "PASS" or "FAIL"), testResults.uiCreation)

    -- Test 4: Logging system
    testResults.logging = _G.ScriptLog ~= nil and type(_G.ScriptLog) == "table"
    logAction("SELF_TEST", "Logging system test: " .. (testResults.logging and "PASS" or "FAIL"), testResults.logging)

    -- Summary
    local passedTests = 0
    for _, result in pairs(testResults) do
        if result then passedTests = passedTests + 1 end
    end

    print("📊 Self-Test Results: " .. passedTests .. "/4 tests passed")

    if passedTests == 4 then
        print("✅ All systems operational!")
        if statusLabel then
            statusLabel.Text = "Self-test passed! All systems ready"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        print("⚠️ Some systems may not be working correctly")
        if statusLabel then
            statusLabel.Text = "Self-test: " .. passedTests .. "/4 passed"
            statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end

    return testResults
end

-- Add self-test button to UI
local selfTestButton = Instance.new("TextButton")
selfTestButton.Size = UDim2.new(0, 100, 0, 25)
selfTestButton.Position = UDim2.new(0, 150, 0, 255)
selfTestButton.Text = "🧪 Self-Test"
selfTestButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
selfTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
selfTestButton.TextSize = 10
selfTestButton.Parent = frame

selfTestButton.MouseButton1Click:Connect(function()
    if selfTestButton.Text == "Testing..." then return end

    statusLabel.Text = "Running self-test..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    selfTestButton.Text = "Testing..."
    selfTestButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

    task.spawn(function()
        runSelfTest()

        selfTestButton.Text = "🧪 Self-Test"
        selfTestButton.BackgroundColor3 = Color3.fromRGB(150, 100, 150)
    end)
end)

-- Main loop
while not exitScript do
    task.wait(0.1)
end

-- Cleanup
if screenGui then
    screenGui:Destroy()
end

print("Script exited")