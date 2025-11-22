-- UNIVERSAL FISHING EXPLOIT SUITE v2.0
-- Combined Features: Auto Fishing + GUI + Multi-Location Farm

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/fixyou-boop/Creator/refs/heads/main/dappi/main/source')))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- MAIN WINDOW
local Window = OrionLib:MakeWindow({
    Name = "dappscott", 
    HidePremium = false,
    SaveConfig = true, 
    ConfigFolder = "FishingConfig",
    IntroEnabled = true,
    IntroText = "Advanced Fishing System",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- NOTIFICATION
OrionLib:MakeNotification({
    Name = "System Loaded!",
    Content = "Universal Fishing Suite Activated",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- TABS ORGANIZATION
local FishingTab = Window:MakeTab({Name = "Auto Fishing", Icon = "rbxassetid://4483345998"})
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998"})
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998"})
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998"})

-- SHARED CONFIGURATION
getgenv().FishingConfig = {
    -- Auto Fishing Settings
    autoCast = true,
    autoReel = true,
    autoCatch = true,
    loopSpeed = 0.25,
    speedMultiplier = 1.0,
    superFast = 0,
    delayMode = 1.0,
    autoPerfection = false,
    animationEnabled = true,
    autoEquipRadar = false,
    
    -- Auto Farm Settings
    autoFarmEnabled = false,
    coralFarmEnabled = false,
    depthsFarmEnabled = false,
    volcanoFarmEnabled = false,
    autoCollect = false,
    
    -- Player Settings
    walkSpeed = 16
}

-- VARIABLES
local castRemote, reelRemote, StartRemote, ReelRemote, NotifyRemote
local isFishing = false
local startTick = 0
local biteTick = nil
local platform = nil

-- SECTION: AUTO FISHING REMOTE DETECTION
local FishingSection = FishingTab:AddSection({Name = "Fishing Automation"})

-- Find fishing remotes automatically
spawn(function()
    for _, v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if not castRemote and (n:find("start") or n:find("cast") or n:find("fish")) then
                castRemote = v
            end
            if not reelRemote and (n:find("reel") or n:find("pull") or n:find("drag")) then
                reelRemote = v
            end
            if not StartRemote and n:find("start") then
                StartRemote = v
            end
            if not ReelRemote and n:find("reel") then
                ReelRemote = v
            end
            if not NotifyRemote and n:find("notify") then
                NotifyRemote = v
            end
        end
    end
    print("[FISHING] Remotes detection completed")
end)

-- AUTO FISHING CONTROLS
FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoCast = state
    end
})

FishingSection:AddToggle({
    Name = "Auto Reel",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoReel = state
    end
})

FishingSection:AddToggle({
    Name = "Perfect Catch",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoPerfection = state
    end
})

FishingSection:AddSlider({
    Name = "Fishing Speed",
    Min = 0.1,
    Max = 5.0,
    Default = 1.0,
    Increment = 0.1,
    Callback = function(value)
        getgenv().FishingConfig.speedMultiplier = value
    end
})

-- MAIN FISHING LOOP (from first script)
spawn(function()
    while wait(getgenv().FishingConfig.loopSpeed) do
        if not getgenv().FishingConfig.autoCast then continue end
        
        -- AUTO CAST LOGIC
        if castRemote and not isFishing then
            pcall(function()
                isFishing = true
                startTick = tick()
                castRemote:FireServer()
            end)
        end
    end
end)

-- SECTION: AUTO FARM
local FarmSection = FarmTab:AddSection({Name = "Location Farming"})

local farmLocations = {
    ["Kohana Island"] = CFrame.new(-759.0910034179688, 24.309707641601562, 429.12823486328125),
    ["Coral Reefs"] = CFrame.new(-3222.68994140625, 9.972307205200195, 1898.0626220703125),
    ["The Depths"] = CFrame.new(3239.964599609375, -1298.2198486328125, 1353.6944580078125)
}

for name, cf in pairs(farmLocations) do
    FarmSection:AddToggle({
        Name = "Farm at " .. name,
        Default = false,
        Callback = function(state)
            if name == "Kohana Island" then
                getgenv().FishingConfig.autoFarmEnabled = state
            elseif name == "Coral Reefs" then
                getgenv().FishingConfig.coralFarmEnabled = state
            elseif name == "The Depths" then
                getgenv().FishingConfig.depthsFarmEnabled = state
            end
            
            if state then
                -- Create platform
                platform = Instance.new("Part")
                platform.Size = Vector3.new(5, 1, 5)
                platform.Anchored = true
                platform.Material = Enum.Material.Plastic
                platform.Parent = workspace
                
                -- Start farming loop
                spawn(function()
                    while getgenv().FishingConfig[name:gsub(" ", "") .. "Enabled"] do
                        LocalPlayer.Character.HumanoidRootPart.CFrame = cf
                        platform.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                        mouse1click()
                        wait(0.5)
                    end
                    -- Cleanup
                    if platform then
                        platform:Destroy()
                        platform = nil
                    end
                end)
            else
                -- Cleanup when disabled
                if platform then
                    platform:Destroy()
                    platform = nil
                end
            end
        end
    })
end

-- SECTION: TELEPORTS
local TeleportSection = TeleportTab:AddSection({Name = "Quick Teleports"})

local locations = {
    ["Starter Island"] = CFrame.new(23.435884475708008, 4.625000953674316, 2868.347412109375),
    ["Kohana Island"] = CFrame.new(-842.8712158203125, 55.500057220458984, 146.21389770507812),
    ["Kohana Volcano"] = CFrame.new(-606.581787109375, 59.000057220458984, 105.82990264892578),
    ["Coral Reefs"] = CFrame.new(-2853.76318359375, 47.499996185302734, 1988.1397705078125),
    ["The Depths"] = CFrame.new(2002.4705810546875, 12.10128402709961, 1385.3233642578125),
    ["Altar Enchant"] = CFrame.new(3177.329345703125, -1302.72998046875, 1427.3759765625)
}

for name, cf in pairs(locations) do
    TeleportSection:AddButton({
        Name = "TP to " .. name,
        Callback = function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = cf
            OrionLib:MakeNotification({
                Name = "Teleported",
                Content = "Arrived at " .. name,
                Time = 2
            })
        end
    })
end

-- SECTION: PLAYER MODIFICATIONS
local PlayerSection = PlayerTab:AddSection({Name = "Player Settings"})

PlayerSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        getgenv().FishingConfig.walkSpeed = value
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

PlayerSection:AddToggle({
    Name = "Auto Collect Items",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoCollect = state
        spawn(function()
            while getgenv().FishingConfig.autoCollect do
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        v.Handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    end
                end
                wait(0.1)
            end
        end)
    end
})

-- EMERGENCY STOP SYSTEM
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        -- Disable all features
        for key, value in pairs(getgenv().FishingConfig) do
            if type(value) == "boolean" then
                getgenv().FishingConfig[key] = false
            end
        end
        
        -- Cleanup
        if platform then
            platform:Destroy()
            platform = nil
        end
        
        isFishing = false
        
        OrionLib:MakeNotification({
            Name = "EMERGENCY STOP",
            Content = "All features disabled",
            Time = 3
        })
    end
end)

-- LOAD INFINITE YIELD (Optional)
PlayerSection:AddButton({
    Name = "Load Infinite Dappi",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/fixyou-boop/Creator/refs/heads/main/dappi/main/loader'))()
        OrionLib:MakeNotification({
            Name = "Loaded",
            Content = "Infinite Yield activated",
            Time = 3
        })
    end
})

print("dappi v2.0 - Fully Integrated System Loaded")