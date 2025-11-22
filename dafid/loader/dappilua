-- UNIVERSAL FISHING EXPLOIT SUITE v2.0 - FIXED VERSION
-- Combined Features: Auto Fishing + GUI + Multi-Location Farm

-- GUNAKAN ORION LIBRARY YANG ASLI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    Content = "dappi Fishing Suite Activated",
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
    autoCast = false,
    autoReel = false,
    autoCatch = false,
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

-- FIX: TAMBAHKAN FUNGSI MOUSECLICK YANG HILANG
local function mouse1click()
    -- Simulate mouse click for fishing
    if reelRemote and isFishing then
        local elapsed = tick() - startTick
        pcall(function()
            reelRemote:FireServer(elapsed)
        end)
    end
end

-- SECTION: AUTO FISHING REMOTE DETECTION
local FishingSection = FishingTab:AddSection({Name = "Fishing Automation"})

-- Find fishing remotes automatically
spawn(function()
    for _, v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if not castRemote and (n:find("start") or n:find("cast") or n:find("fish")) then
                castRemote = v
                print("[FOUND] Cast Remote:", v:GetFullName())
            end
            if not reelRemote and (n:find("reel") or n:find("pull") or n:find("drag")) then
                reelRemote = v
                print("[FOUND] Reel Remote:", v:GetFullName())
            end
        end
    end
    if not castRemote then
        warn("[ERROR] Cast Remote not found!")
    end
    if not reelRemote then
        warn("[ERROR] Reel Remote not found!")
    end
end)

-- AUTO FISHING CONTROLS
FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoCast = state
        OrionLib:MakeNotification({
            Name = "Auto Cast",
            Content = state and "Enabled" or "Disabled",
            Time = 2
        })
    end
})

FishingSection:AddToggle({
    Name = "Auto Reel", 
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoReel = state
        OrionLib:MakeNotification({
            Name = "Auto Reel",
            Content = state and "Enabled" or "Disabled", 
            Time = 2
        })
    end
})

FishingSection:AddToggle({
    Name = "Perfect Catch",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoPerfection = state
        OrionLib:MakeNotification({
            Name = "Perfect Catch",
            Content = state and "Enabled" or "Disabled",
            Time = 2
        })
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
        OrionLib:MakeNotification({
            Name = "Fishing Speed",
            Content = "Set to " .. value .. "x",
            Time = 2
        })
    end
})

-- MAIN FISHING LOOP (FIXED)
spawn(function()
    while task.wait(getgenv().FishingConfig.loopSpeed) do
        if not getgenv().FishingConfig.autoCast then continue end
        if isFishing then continue end
        
        -- AUTO CAST LOGIC
        if castRemote then
            pcall(function()
                isFishing = true
                startTick = tick()
                castRemote:FireServer()
                print("[FISHING] Casting line...")
                
                -- Auto reel after delay if enabled
                if getgenv().FishingConfig.autoReel then
                    task.wait(3) -- Wait for bite
                    if isFishing then
                        mouse1click()
                    end
                end
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
            local configName = name:gsub(" ", "") .. "Enabled"
            getgenv().FishingConfig[configName] = state
            
            OrionLib:MakeNotification({
                Name = "Farm " .. name,
                Content = state and "Started" or "Stopped",
                Time = 3
            })
            
            if state then
                -- Create platform
                if platform then platform:Destroy() end
                platform = Instance.new("Part")
                platform.Name = "FarmingPlatform"
                platform.Size = Vector3.new(10, 1, 10)
                platform.Anchored = true
                platform.Material = Enum.Material.Neon
                platform.BrickColor = BrickColor.new("Bright blue")
                platform.Transparency = 0.7
                platform.CanCollide = true
                platform.Parent = workspace
                
                -- Start farming loop
                spawn(function()
                    while getgenv().FishingConfig[configName] do
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = cf
                            platform.CFrame = cf - Vector3.new(0, 4, 0)
                            task.wait(1)
                        end)
                        task.wait(0.5)
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
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = cf
                OrionLib:MakeNotification({
                    Name = "Teleported",
                    Content = "Arrived at " .. name,
                    Time = 2
                })
            end)
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
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
        OrionLib:MakeNotification({
            Name = "Walk Speed",
            Content = "Set to " .. value,
            Time = 2
        })
    end
})

PlayerSection:AddToggle({
    Name = "Auto Collect Items",
    Default = false,
    Callback = function(state)
        getgenv().FishingConfig.autoCollect = state
        OrionLib:MakeNotification({
            Name = "Auto Collect",
            Content = state and "Enabled" or "Disabled",
            Time = 2
        })
        
        spawn(function()
            while getgenv().FishingConfig.autoCollect do
                pcall(function()
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("Handle") then
                            v.Handle.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end)
                task.wait(0.5)
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
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        OrionLib:MakeNotification({
            Name = "Loaded",
            Content = "Infinite Yield activated",
            Time = 3
        })
    end
})

print("dappi v2.0 - Fixed System Loaded Successfully!")
