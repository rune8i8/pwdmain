-- pwd.MAIN | single-file host build | TARGET = da hood (local fixture)
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local Config = {
    camlock = {
        enabled=false, autoToggle=false, key="C", mode="Toggle",
        hitPart="HumanoidRootPart", closestPointMode="Default", closestPointScale=0.000,
        fovRadius=0, maxDistance=0,
        forceFieldCheck=false, visibleCheck=false, carriedCheck=false,
        knockedCheck=false, selfKnockedCheck=false,
        easingStyle="Quad", easingDirection="Out", smoothness=0.000,
        pullStrength=false, pullBaseValue=0.000, pullMoveValue=0.000,
        prediction=false, predictionX=0.000, predictionY=0.000, predictionZ=0.000
    },
    flamelock = {
        enabled=false, rightClickLock=false, activationMode="Hold", key="Z",
        hitPart="HumanoidRootPart", smoothness=0.000, prediction=0.000,
        leftOffset=0.000, upOffset=0.000
    },
    hitbox  = { enabled=false, size=2, visibility=0.000 },
    hood    = {
        silentAim=false, revolverBypass=false, wallCheck=false, knockCheck=false,
        fovRadius=100, hitPart="Head", prediction=false, predAmount=0.165, godmode=false,
        forceHit=false, fhMode="Fov", fhFovRadius=100, fhTracer=false,
        fhFullAuto=false, fhFireRate=0.067
    },
    silent  = {
        enabled=false, showFov=false, revolverBypass=false, wallCheck=false,
        knockCheck=false, fovRadius=100, bulletSpread=100, hitPart="Head"
    },
    atmosphere = { color="Air Pink" },
    esp = {
        enabled=false, box=false, name=false, distance=false, chams=false,
        snapline=false, health=false, colorCorrection=false, saturation=0.500,
        color=Color3.fromRGB(255,255,255)
    },
    headless = { enabled=false },
    antiFall = { enabled=true },
    delayChanger = {
        enabled=false, revolverDelay=0.030, doubleBarrelDelay=0.300,
        tacticalShotgunDelay=0.000, othersDelay=0.095
    },
    speed = { enabled=false, key="R", value=50 },
    antiAimView = {
        enabled=false, antiFakeAccuracy=false, antiModNotify=false,
        antiModKick=false, kickDelay=3
    },
    ui = { toggleKey="RightShift", open=true }
}

local function getChar() return LocalPlayer.Character end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function getClosestPlayer(maxDist)
    local closest, dist = nil, maxDist or math.huge
    local root = getRoot()
    if not root then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - Camera.CFrame.Position).Magnitude
                if d < dist then dist, closest = d, p end
            end
        end
    end
    return closest
end

local function isVisible(target)
    if not target or not target.Character then return false end
    local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
    local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return res == nil
end

local function camlock()
    if not Config.camlock.enabled then return end
    local target = getClosestPlayer(Config.camlock.maxDistance > 0 and Config.camlock.maxDistance or nil)
    if not target then return end
    local part = target.Character:FindFirstChild(Config.camlock.hitPart)
              or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    if Config.camlock.visibleCheck and not isVisible(target) then return end
    local goal = CFrame.new(Camera.CFrame.Position, part.Position)
    if Config.camlock.smoothness > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(goal, Config.camlock.smoothness)
    else
        Camera.CFrame = goal
    end
end

local function flamelock()
    if not Config.flamelock.enabled then return end
    local target = getClosestPlayer()
    if not target then return end
    local part = target.Character:FindFirstChild(Config.flamelock.hitPart)
              or target.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local goal = CFrame.new(Camera.CFrame.Position, part.Position)
    Camera.CFrame = goal * CFrame.new(Config.flamelock.leftOffset, Config.flamelock.upOffset, 0)
end

local function hitboxExpander()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Config.hitbox.enabled then
                    hrp.Size = Vector3.new(Config.hitbox.size, Config.hitbox.size, Config.hitbox.size)
                    hrp.Transparency = Config.hitbox.visibility
                    hrp.CanCollide = false
                    hrp.Massless = true
                else
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Transparency = 1
                end
            end
        end
    end
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if (Config.silent.enabled or Config.hood.silentAim) and method == "FindPartOnRayWithIgnoreList" then
        local target = getClosestPlayer(Config.silent.fovRadius > 0 and Config.silent.fovRadius or nil)
        if target and target.Character then
            local part = target.Character:FindFirstChild(Config.silent.hitPart)
                      or target.Character:FindFirstChild("Head")
            if part then return part, part.Position end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function speed()
    local hum = getHum()
    if not hum then return end
    if Config.speed.enabled then hum.WalkSpeed = Config.speed.value end
end

local function antiFall()
    local hum = getHum()
    if not hum then return end
    if Config.antiFall.enabled then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

local function delayChanger()
    if not Config.delayChanger.enabled then return end
    _G.Delays = {
        Revolver        = Config.delayChanger.revolverDelay,
        DoubleBarrel    = Config.delayChanger.doubleBarrelDelay,
        TacticalShotgun = Config.delayChanger.tacticalShotgunDelay,
        Others          = Config.delayChanger.othersDelay
    }
end

local function headless()
    local char = getChar()
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if Config.headless.enabled then
        head.Transparency = 1
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Mesh") or v:IsA("SpecialMesh") or v:IsA("Decal") then v:Destroy() end
        end
        local n = char:FindFirstChild("Neck")
        if n then n.Part1 = nil end
    end
end

local function atmosphere()
    local map = {
        ["Air Pink"]      = Color3.fromRGB(255,200,220),
        ["Mint"]          = Color3.fromRGB(180,255,210),
        ["Light Orange"]  = Color3.fromRGB(255,210,160),
        ["Cyan"]          = Color3.fromRGB(170,240,255),
        ["Green"]         = Color3.fromRGB(170,255,170),
        ["Purple"]        = Color3.fromRGB(210,170,255),
        ["Pink"]          = Color3.fromRGB(255,170,220),
        ["Electric Blue"] = Color3.fromRGB(120,200,255),
        ["Light Red"]     = Color3.fromRGB(255,170,170),
        ["Violet"]        = Color3.fromRGB(190,140,255),
        ["Dark Red"]      = Color3.fromRGB(180,60,60)
    }
    local c = map[Config.atmosphere.color] or Color3.fromRGB(255,255,255)
    Lighting.Ambient = c
    Lighting.OutdoorAmbient = c
end

local espCache = {}
local function esp()
    for _, d in pairs(espCache) do
        if d.box then d.box:Remove() end
        if d.name then d.name:Remove() end
        if d.dist then d.dist:Remove() end
    end
    espCache = {}
    if not Config.esp.enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = {}
                    if Config.esp.box then
                        local b = Drawing.new("Square")
                        b.Size = Vector2.new(50,80); b.Position = Vector2.new(pos.X-25, pos.Y-40)
                        b.Color = Config.esp.color; b.Thickness = 1; b.Filled = false; b.Visible = true
                        d.box = b
                    end
                    if Config.esp.name then
                        local n = Drawing.new("Text")
                        n.Text = p.Name; n.Position = Vector2.new(pos.X, pos.Y-60)
                        n.Size = 14; n.Center = true; n.Outline = true
                        n.Color = Config.esp.color; n.Visible = true
                        d.name = n
                    end
                    if Config.esp.distance then
                        local t = Drawing.new("Text")
                        local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                        t.Text = dist.."m"; t.Position = Vector2.new(pos.X, pos.Y+45)
                        t.Size = 12; t.Center = true; t.Outline = true
                        t.Color = Config.esp.color; t.Visible = true
                        d.dist = t
                    end
                    espCache[p] = d
                end
            end
        end
    end
end

local function antiAimView()
    if not Config.antiAimView.enabled then return end
    if Config.antiAimView.antiModKick then
        LocalPlayer.Kick = function() end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(camlock)
    pcall(flamelock)
    pcall(hitboxExpander)
    pcall(speed)
    pcall(antiFall)
    pcall(delayChanger)
    pcall(headless)
    pcall(atmosphere)
    pcall(esp)
    pcall(antiAimView)
end)

local function saveCfg(name)
    writefile("pwd_"..name..".json", HttpService:JSONEncode(Config))
end
local function loadCfg(name)
    if isfile("pwd_"..name..".json") then
        local d = HttpService:JSONDecode(readfile("pwd_"..name..".json"))
        for k,v in pairs(d) do Config[k]=v end
    end
end
local function delCfg(name)
    if isfile("pwd_"..name..".json") then delfile("pwd_"..name..".json") end
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent = parent end
    return o
end

local gui = new("ScreenGui", {Name="pwd.MAIN", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local theme = {
    bg=Color3.fromRGB(255,250,235), panel=Color3.fromRGB(255,253,245),
    side=Color3.fromRGB(255,252,240), line=Color3.fromRGB(230,215,190),
    text=Color3.fromRGB(120,100,80), textDim=Color3.fromRGB(180,160,140),
    accent=Color3.fromRGB(255,200,215)
}

local main = new("Frame", {
    Name="Main", Size=UDim2.new(0,620,0,360),
    Position=UDim2.new(0.5,-310,0.5,-180),
    BackgroundColor3=theme.bg, BorderSizePixel=0, Active=true, Draggable=true
}, gui)
new("UICorner", {CornerRadius=UDim.new(0,6)}, main)
new("UIStroke", {Color=theme.line, Thickness=1}, main)

local title = new("Frame", {
    Size=UDim2.new(1,0,0,26), BackgroundColor3=theme.panel, BorderSizePixel=0
}, main)
new("UICorner", {CornerRadius=UDim.new(0,6)}, title)
new("TextLabel", {
    Text="  pwd.MAIN", BackgroundTransparency=1, Font=Enum.Font.GothamBold,
    TextSize=13, TextColor3=theme.text, TextXAlignment=Enum.TextXAlignment.Left,
    Size=UDim2.new(0.5,0,1,0)
}, title)
new("TextLabel", {
    Text="Tuesday, 15 September, 26  ", BackgroundTransparency=1, Font=Enum.Font.Gotham,
    TextSize=11, TextColor3=theme.textDim, TextXAlignment=Enum.TextXAlignment.Right,
    Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0)
}, title)

local side = new("Frame", {
    Size=UDim2.new(0,110,1,-26), Position=UDim2.new(0,0,0,26),
    BackgroundColor3=theme.side, BorderSizePixel=0
}, main)
new("UIStroke", {Color=theme.line, Thickness=1}, side)

local content = new("Frame", {
    Size=UDim2.new(1,-110,1,-26), Position=UDim2.new(0,110,0,26),
    BackgroundColor3=theme.panel, BorderSizePixel=0
}, main)
new("UIStroke", {Color=theme.line, Thickness=1}, content)

local tabBar = new("Frame", {
    Size=UDim2.new(1,0,0,26), BackgroundColor3=theme.panel, BorderSizePixel=0
}, content)
new("UIStroke", {Color=theme.line, Thickness=1}, tabBar)

local body = new("Frame", {
    Size=UDim2.new(1,0,1,-26), Position=UDim2.new(0,0,0,26),
    BackgroundColor3=theme.panel, BorderSizePixel=0
}, content)

local function clearBody()
    for _,v in ipairs(body:GetChildren()) do v:Destroy() end
end

local function addToggle(page, label, key, cfg)
    local f = new("Frame", {Size=UDim2.new(0,240,0,22), BackgroundTransparency=1}, page)
    local cb = new("TextButton", {
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,4,0,4),
        BackgroundColor3=cfg[key] and theme.accent or theme.panel, Text="", BorderSizePixel=0
    }, f)
    new("UIStroke", {Color=theme.line, Thickness=1}, cb)
    new("TextLabel", {
        Text=label, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=theme.text, TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,24,0,0), Size=UDim2.new(1,-24,1,0)
    }, f)
    cb.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        cb.BackgroundColor3 = cfg[key] and theme.accent or theme.panel
    end)
end

local function addSlider(page, label, key, cfg, min, max, step)
    local f = new("Frame", {Size=UDim2.new(0,240,0,32), BackgroundTransparency=1}, page)
    new("TextLabel", {
        Text=label, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=theme.text, TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,4,0,0), Size=UDim2.new(1,-50,0,14)
    }, f)
    local box = new("TextBox", {
        Text=tostring(cfg[key]), Size=UDim2.new(0,44,0,16),
        Position=UDim2.new(1,-48,0,0), BackgroundColor3=theme.panel,
        TextColor3=theme.textDim, Font=Enum.Font.Gotham, TextSize=11, BorderSizePixel=0
    }, f)
    new("UIStroke", {Color=theme.line, Thickness=1}, box)
    local bar = new("Frame", {
        Size=UDim2.new(1,-8,0,4), Position=UDim2.new(0,4,0,20),
        BackgroundColor3=theme.line, BorderSizePixel=0
    }, f)
    local fill = new("Frame", {
        Size=UDim2.new(0,0,1,0), BackgroundColor3=theme.accent, BorderSizePixel=0
    }, bar)
    local function refresh()
        local a = (cfg[key]-min)/(max-min)
        fill.Size = UDim2.new(a,0,1,0)
        box.Text = tostring(cfg[key])
    end
    refresh()
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then cfg[key]=math.clamp(n,min,max); refresh() end
    end)
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            cfg[key] = min + rel*(max-min)
            if step then cfg[key] = math.floor(cfg[key]/step+0.5)*step end
            refresh()
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local function addTextBox(page, label, key, cfg)
    local f = new("Frame", {Size=UDim2.new(0,240,0,24), BackgroundTransparency=1}, page)
    new("TextLabel", {
        Text=label, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=theme.text, TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,4,0,0), Size=UDim2.new(0.5,0,1,0)
    }, f)
    local box = new("TextBox", {
        Text=tostring(cfg[key]), Position=UDim2.new(0.5,0,0,3), Size=UDim2.new(0.5,-4,0,18),
        BackgroundColor3=theme.panel, TextColor3=theme.textDim, Font=Enum.Font.Gotham,
        TextSize=11, BorderSizePixel=0
    }, f)
    new("UIStroke", {Color=theme.line, Thickness=1}, box)
    box.FocusLost:Connect(function() cfg[key]=box.Text end)
end

local function addButton(page, label, cb)
    local b = new("TextButton", {
        Text=label, Size=UDim2.new(0,240,0,20), BackgroundColor3=theme.panel,
        TextColor3=theme.textDim, Font=Enum.Font.Gotham, TextSize=12, BorderSizePixel=0
    }, page)
    new("UIStroke", {Color=theme.line, Thickness=1}, b)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function addDropdown(page, label, key, cfg, options)
    local f = new("Frame", {Size=UDim2.new(0,240,0,24), BackgroundTransparency=1}, page)
    new("TextLabel", {
        Text=label, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=theme.text, TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,4,0,0), Size=UDim2.new(0.5,0,1,0)
    }, f)
    local b = new("TextButton", {
        Text=tostring(cfg[key]), Position=UDim2.new(0.5,0,0,3), Size=UDim2.new(0.5,-4,0,18),
        BackgroundColor3=theme.panel, TextColor3=theme.textDim, Font=Enum.Font.Gotham,
        TextSize=11, BorderSizePixel=0
    }, f)
    new("UIStroke", {Color=theme.line, Thickness=1}, b)
    local idx = table.find(options, cfg[key]) or 1
    b.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        cfg[key] = options[idx]
        b.Text = cfg[key]
    end)
end

local function newPage()
    return new("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}, body)
end

local pages = {}

function pages.camlock()
    clearBody(); local p = newPage()
    addToggle(p,"Camlock Enabled","enabled",Config.camlock)
    addToggle(p,"Auto Toggle (Gun)","autoToggle",Config.camlock)
    addTextBox(p,"Toggle Key","key",Config.camlock)
    addDropdown(p,"Mode","mode",Config.camlock,{"Toggle","Hold"})
    addTextBox(p,"Hit Part","hitPart",Config.camlock)
    addDropdown(p,"Closest Point Mode","closestPointMode",Config.camlock,{"Default","Center","Edge"})
    addSlider(p,"Closest Point Scale","closestPointScale",Config.camlock,0,1,0.001)
    addSlider(p,"FOV Radius","fovRadius",Config.camlock,0,360,1)
    addSlider(p,"Max Distance","maxDistance",Config.camlock,0,1000,1)
    addToggle(p,"Force Field Check","forceFieldCheck",Config.camlock)
    addToggle(p,"Visible Check","visibleCheck",Config.camlock)
    addToggle(p,"Carried Check","carriedCheck",Config.camlock)
    addToggle(p,"Knocked Check","knockedCheck",Config.camlock)
    addToggle(p,"Self Knocked Check","selfKnockedCheck",Config.camlock)
    addDropdown(p,"Easing Style","easingStyle",Config.camlock,{"Quad","Linear","Sine","Back"})
    addDropdown(p,"Easing Direction","easingDirection",Config.camlock,{"Out","In","InOut"})
    addSlider(p,"Smoothness","smoothness",Config.camlock,0,1,0.001)
    addToggle(p,"Pull Strength","pullStrength",Config.camlock)
    addSlider(p,"Pull Base Value","pullBaseValue",Config.camlock,0,5,0.001)
    addSlider(p,"Pull Move Value","pullMoveValue",Config.camlock,0,5,0.001)
    addToggle(p,"Prediction","prediction",Config.camlock)
    addSlider(p,"Prediction X","predictionX",Config.camlock,-1,1,0.001)
    addSlider(p,"Prediction Y","predictionY",Config.camlock,-1,1,0.001)
    addSlider(p,"Prediction Z","predictionZ",Config.camlock,-1,1,0.001)
end

function pages.flamelock()
    clearBody(); local p = newPage()
    addToggle(p,"Flamelock","enabled",Config.flamelock)
    addToggle(p,"Right Click Lock","rightClickLock",Config.flamelock)
    addDropdown(p,"Activation Mode","activationMode",Config.flamelock,{"Hold","Toggle"})
    addTextBox(p,"Flamelock Key","key",Config.flamelock)
    addTextBox(p,"Hit Part","hitPart",Config.flamelock)
    addSlider(p,"Smoothness","smoothness",Config.flamelock,0,1,0.001)
    addSlider(p,"Prediction","prediction",Config.flamelock,0,1,0.001)
    addSlider(p,"Left Offset","leftOffset",Config.flamelock,-1,1,0.001)
    addSlider(p,"Up Offset","upOffset",Config.flamelock,-1,1,0.001)
end

function pages.hitbox()
    clearBody(); local p = newPage()
    addToggle(p,"Hitbox Expander","enabled",Config.hitbox)
    addSlider(p,"Hitbox Size","size",Config.hitbox,1,20,0.1)
    addSlider(p,"Visibility","visibility",Config.hitbox,0,1,0.001)
end

function pages.hood()
    clearBody(); local p = newPage()
    addToggle(p,"HC Silent Aim","silentAim",Config.hood)
    addToggle(p,"HC Revolver Bypass","revolverBypass",Config.hood)
    addToggle(p,"HC Wall Check","wallCheck",Config.hood)
    addToggle(p,"HC Knock Check","knockCheck",Config.hood)
    addSlider(p,"HC FOV Radius","fovRadius",Config.hood,0,360,1)
    addTextBox(p,"HC Hit Part","hitPart",Config.hood)
    addToggle(p,"HC Prediction","prediction",Config.hood)
    addSlider(p,"HC Pred Amount","predAmount",Config.hood,0,1,0.001)
    addToggle(p,"HC Godmode","godmode",Config.hood)
    addToggle(p,"Force Hit","forceHit",Config.hood)
    addDropdown(p,"FH Mode","fhMode",Config.hood,{"Fov","Nearest","Mouse"})
    addSlider(p,"FH FOV Radius","fhFovRadius",Config.hood,0,360,1)
    addToggle(p,"FH Tracer","fhTracer",Config.hood)
    addToggle(p,"FH Full Auto","fhFullAuto",Config.hood)
    addSlider(p,"FH Fire Rate","fhFireRate",Config.hood,0,1,0.001)
end

function pages.silent()
    clearBody(); local p = newPage()
    addToggle(p,"Silent Aim","enabled",Config.silent)
    addToggle(p,"Show FOV","showFov",Config.silent)
    addToggle(p,"Revolver Bypass","revolverBypass",Config.silent)
    addToggle(p,"Wall Check","wallCheck",Config.silent)
    addToggle(p,"Knock Check","knockCheck",Config.silent)
    addSlider(p,"FOV Radius","fovRadius",Config.silent,0,360,1)
    addSlider(p,"Bullet Spread","bulletSpread",Config.silent,0,100,1)
    addTextBox(p,"Hit Part","hitPart",Config.silent)
end

function pages.atmosphere()
    clearBody(); local p = newPage()
    local colors = {"Air Pink","Mint","Light Orange","Cyan","Green","Purple","Pink","Electric Blue","Light Red","Violet","Dark Red"}
    for _, c in ipairs(colors) do
        addButton(p, c, function()
            Config.atmosphere.color = c
            atmosphere()
        end)
    end
end

function pages.esp()
    clearBody(); local p = newPage()
    addToggle(p,"ESP","enabled",Config.esp)
    addToggle(p,"Box","box",Config.esp)
    addToggle(p,"Name","name",Config.esp)
    addToggle(p,"Distance","distance",Config.esp)
    addToggle(p,"Chams","chams",Config.esp)
    addToggle(p,"Snapline","snapline",Config.esp)
    addToggle(p,"Health","health",Config.esp)
    addToggle(p,"Color Correction","colorCorrection",Config.esp)
    addSlider(p,"Saturation","saturation",Config.esp,0,1,0.001)
end

function pages.headless()
    clearBody(); local p = newPage()
    addToggle(p,"Headless Mode","enabled",Config.headless)
end

function pages.antiFall()
    clearBody(); local p = newPage()
    addToggle(p,"Anti Fall","enabled",Config.antiFall)
end

function pages.delay()
    clearBody(); local p = newPage()
    addToggle(p,"Delay Changer","enabled",Config.delayChanger)
    addSlider(p,"[Revolver] Delay","revolverDelay",Config.delayChanger,0,1,0.001)
    addSlider(p,"[Double Barrel] Delay","doubleBarrelDelay",Config.delayChanger,0,1,0.001)
    addSlider(p,"[Tactical Shotgun] Delay","tacticalShotgunDelay",Config.delayChanger,0,1,0.001)
    addSlider(p,"Others Delay","othersDelay",Config.delayChanger,0,1,0.001)
end

function pages.speed()
    clearBody(); local p = newPage()
    addToggle(p,"Speed Master","enabled",Config.speed)
    addTextBox(p,"Speed Key","key",Config.speed)
    addSlider(p,"Speed Value","value",Config.speed,16,500,1)
end

function pages.antiAim()
    clearBody(); local p = newPage()
    addToggle(p,"Anti Aim View","enabled",Config.antiAimView)
    addToggle(p,"Anti Fake Accuracy","antiFakeAccuracy",Config.antiAimView)
    addToggle(p,"Anti Mod Notify","antiModNotify",Config.antiAimView)
    addToggle(p,"Anti Mod Kick","antiModKick",Config.antiAimView)
    addSlider(p,"Kick Delay","kickDelay",Config.antiAimView,0,10,1)
end

function pages.config()
    clearBody(); local p = newPage()
    addTextBox(p,"Config Name","name",Config.config or {name=""})
    addButton(p,"Save Config",function() saveCfg("default") end)
    addButton(p,"Load Config",function() loadCfg("default") end)
    addButton(p,"Delete Config",function() delCfg("default") end)
end

local categories = {
    {name="combat",     tabs={{"camlock",pages.camlock},{"flamelock",pages.flamelock},{"hitbox expander",pages.hitbox},{"hood customs",pages.hood},{"silent aim",pages.silent}}},
    {name="visuals",    tabs={{"atmosphere",pages.atmosphere},{"esp",pages.esp}}},
    {name="whitelist",  tabs={{"whitelist",function() clearBody() end}}},
    {name="avatar",     tabs={{"headless",pages.headless}}},
    {name="misc",       tabs={{"anti fall",pages.antiFall},{"delay changer",pages.delay},{"speed",pages.speed}}},
    {name="protection", tabs={{"anti aim view",pages.antiAim}}},
    {name="settings",   tabs={{"config",pages.config}}}
}

local sideButtons = {}
local yPos = 0
for _, cat in ipairs(categories) do
    local b = new("TextButton", {
        Text=cat.name, Size=UDim2.new(1,-8,0,24), Position=UDim2.new(0,4,0,yPos+4),
        BackgroundColor3=theme.side, TextColor3=theme.textDim,
        Font=Enum.Font.Gotham, TextSize=12, BorderSizePixel=0
    }, side)
    yPos = yPos + 28
    b.MouseButton1Click:Connect(function()
        for _,v in ipairs(body:GetChildren()) do v:Destroy() end
        for _,v in ipairs(tabBar:GetChildren()) do v:Destroy() end
        local x = 0
        for _, tab in ipairs(cat.tabs) do
            local tb = new("TextButton", {
                Text=tab[1], Size=UDim2.new(0,110,1,0), Position=UDim2.new(0,x,0,0),
                BackgroundColor3=theme.panel, TextColor3=theme.textDim,
                Font=Enum.Font.Gotham, TextSize=11, BorderSizePixel=0
            }, tabBar)
            new("UIStroke", {Color=theme.line,
