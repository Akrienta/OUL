--OUL--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

if RunService:IsServer() then
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("OULVortexEvent")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "OULVortexEvent"
	remote.Parent = ReplicatedStorage
end

ReplicatedStorage:SetAttribute("OULVortexServerSide", true)

local wants = {}
local states = {}
local lastFire = {}

remote.OnServerEvent:Connect(function(player, want, speed, radius)
	local now = os.clock()
	if lastFire[player] and now - lastFire[player] < 0.05 then return end
	lastFire[player] = now

	if typeof(want) ~= "boolean" then return end
	speed, radius = tonumber(speed), tonumber(radius)
	if not speed or not radius or speed ~= speed or radius ~= radius then return end

	wants[player] = {
		want = want,
		speed = math.clamp(speed, 1, 100),
		radius = math.clamp(radius, 2, 60),
	}
end)

local function place(st, ease)
	local root = st.root
	local t = os.clock()
	local spin = t * st.speed * 0.5
	local center = root.Position
	local count = math.max(st.orbitCount, 1)
	local rest = { [root] = root.CFrame }

	for _, j in ipairs(st.joints) do
		local m = j.motor
		local p0 = m.Part0
		if m.Parent and p0 and j.part.Parent then
			local r = (rest[p0] or p0.CFrame) * j.c0 * m.Transform * j.c1:Inverse()
			rest[j.part] = r

			local cf = r
			if not j.head then
				local sl = j.slot

				local k = (sl - 0.5) / count
				local phi = math.acos(1 - 2 * k)
				local theta = sl * 2.399963
				local dir = Vector3.new(math.sin(phi) * math.cos(theta), math.cos(phi), math.sin(phi) * math.sin(theta))
				local tilt = CFrame.Angles(spin * 0.6, spin, spin * 0.35)

				local rad = st.radius * (0.5 + 0.5 * math.sin(t * st.speed * (0.12 + (sl % 4) * 0.035) + sl * 1.7))
				local pos = center + tilt:VectorToWorldSpace(dir) * rad
				local orbit = CFrame.new(pos) * CFrame.Angles(t * 2 + sl, t * 1.3 + sl * 0.6, t * 1.7)
				cf = r:Lerp(orbit, ease)
			end
			j.part.CFrame = cf
		end
	end
end

local function restore(player)
	local st = states[player]
	if not st then return end
	states[player] = nil

	if st.root and st.root.Parent then
		pcall(place, st, 0)
	end
	for _, j in ipairs(st.joints) do
		pcall(function()
			if j.part.Parent then
				j.part.Anchored = j.anchored
				j.part.CanCollide = j.canCollide
			end
			if j.motor.Parent then
				j.motor.Enabled = j.enabled
			end
		end)
	end
	pcall(function()
		if st.hum and st.requiresNeck ~= nil then
			st.hum.RequiresNeck = st.requiresNeck
		end
	end)
end

local function build(char, hum, root)
	local st = {
		char = char, hum = hum, root = root,
		joints = {}, orbitCount = 0, blend = 0,
		speed = 6, radius = 5,
		requiresNeck = hum.RequiresNeck,
	}

	local motors = {}
	for _, m in ipairs(char:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 and m.Part1:IsDescendantOf(char) then
			motors[#motors + 1] = m
		end
	end

	local placed, done, slot = { [root] = true }, {}, 0
	local progress = true
	while progress do
		progress = false
		for _, m in ipairs(motors) do
			if not done[m] and placed[m.Part0] and not placed[m.Part1] then
				done[m], placed[m.Part1] = true, true
				progress = true
				local isHead = m.Part1.Name == "Head"
				if not isHead then slot += 1 end
				st.joints[#st.joints + 1] = {
					motor = m, part = m.Part1, c0 = m.C0, c1 = m.C1,
					enabled = m.Enabled, canCollide = m.Part1.CanCollide,
					anchored = m.Part1.Anchored, head = isHead, slot = slot,
				}
			end
		end
	end
	st.orbitCount = slot

	hum.RequiresNeck = false
	for _, j in ipairs(st.joints) do
		j.motor.Enabled = false
		j.part.CanCollide = false
		j.part.Anchored = true
	end
	return st
end

RunService.Heartbeat:Connect(function(dt)
	for player, w in pairs(wants) do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = hum and hum.RootPart

		local st = states[player]
		if st and (st.char ~= char or st.root ~= root) then
			restore(player)
			st = nil
		end

		if w.want and hum and root and hum.Health > 0 then
			if not st then
				st = build(char, hum, root)
				states[player] = st
			end
			st.speed, st.radius = w.speed, w.radius
			st.blend = math.min(1, st.blend + dt / 0.5)
		elseif st then
			st.blend = math.max(0, st.blend - dt / 0.5)
			if st.blend <= 0 then
				restore(player)
				st = nil
			end
		end

		if st then
			local b = st.blend
			place(st, b * b * (3 - 2 * b))
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	restore(player)
	wants[player] = nil
	lastFire[player] = nil
end)

return
end

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if shared.OULCleanup then
	pcall(shared.OULCleanup)
	shared.OULCleanup = nil
end

do
	pcall(function() RunService:UnbindFromRenderStep("Aimbot") end)
	pcall(function() RunService:UnbindFromRenderStep("AimAssist") end)
	pcall(function() RunService:UnbindFromRenderStep("OULMenuMouse") end)

	local containers = { LocalPlayer:WaitForChild("PlayerGui") }
	pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
	pcall(function()
		if gethui then table.insert(containers, gethui()) end
	end)

	for _, container in ipairs(containers) do
		for _, name in ipairs({ "AimbotUI", "AimAssistUI" }) do
			pcall(function()
				local old = container:FindFirstChild(name)
				while old do
					old:Destroy()
					old = container:FindFirstChild(name)
				end
			end)
		end
	end

	local oldBlur = Lighting:FindFirstChild("OULMenuBlur")
	while oldBlur do
		oldBlur:Destroy()
		oldBlur = Lighting:FindFirstChild("OULMenuBlur")
	end

	local oldFolder = workspace:FindFirstChild("OULESP")
	while oldFolder do
		oldFolder:Destroy()
		oldFolder = workspace:FindFirstChild("OULESP")
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			for _, child in ipairs(char:GetChildren()) do
				if child.Name == "ESPChams" or child.Name == "ESPName" then
					child:Destroy()
				end
			end
		end
	end
end

local alive = true
local connections = {}
local function track(conn)
	connections[#connections + 1] = conn
	return conn
end

local EASE = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_IN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_OUT = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local THEME_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SLIDE = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local FONT = Enum.Font.RobotoMono

local LOGO_ID = ""
local LOGO_FILE = "OUL_logo.png"
local LOGO_PURPLE = Color3.fromRGB(145, 90, 255)
local LOGO_BLUE = Color3.fromRGB(50, 145, 255)

local function makeLogo(parent, size, x, y, zIndex)
	zIndex = zIndex or 101

	local src
	if LOGO_ID ~= "" then
		src = "rbxassetid://" .. LOGO_ID
	else
		pcall(function()
			if isfile and getcustomasset and isfile(LOGO_FILE) then
				src = getcustomasset(LOGO_FILE)
			end
		end)
	end

	if src then
		local img = Instance.new("ImageLabel")
		img.Name = "OULLogo"
		img.BackgroundTransparency = 1
		img.BorderSizePixel = 0
		img.Size = UDim2.fromOffset(size, size)
		img.Position = UDim2.fromOffset(x, y)
		img.ScaleType = Enum.ScaleType.Fit
		img.Image = src
		img.ZIndex = zIndex
		img.Parent = parent

		Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
		return img
	end

	local ring = Instance.new("Frame")
	ring.Name = "OULLogo"
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.Size = UDim2.fromOffset(size, size)
	ring.Position = UDim2.fromOffset(x, y)
	ring.ZIndex = zIndex
	ring.Parent = parent
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = math.max(1.5, size / 10)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = ring

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(LOGO_PURPLE, LOGO_BLUE)
	grad.Rotation = 45
	grad.Parent = stroke

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.Text = "OUL"
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = math.max(6, math.floor(size * 0.36))
	lbl.TextColor3 = Color3.fromRGB(240, 242, 252)
	lbl.ZIndex = zIndex
	lbl.Parent = ring
	return ring
end

local function tween(obj, props, info)
	TweenService:Create(obj, info or EASE, props):Play()
end

local function apply(obj, props, animate)
	if animate then
		tween(obj, props)
	else
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
end

local Theme = {
	Text = Color3.fromRGB(228, 232, 255),
	Switch = Color3.fromRGB(88, 122, 255),
	Accent = Color3.fromRGB(140, 95, 255),
	Background = Color3.fromRGB(8, 9, 20),
	Outline = Color3.fromRGB(44, 46, 86),
	Dim = Color3.fromRGB(110, 165, 210),
	Field = Color3.fromRGB(34, 34, 42),
	Group = Color3.fromRGB(22, 22, 28),
}
local bound = {}
local themeListeners = {}

local function deriveTheme()
	Theme.Dim = Theme.Text:Lerp(Theme.Background, 0.4)
	Theme.Field = Theme.Background:Lerp(Theme.Text, 0.1)
	Theme.Group = Theme.Background:Lerp(Theme.Text, 0.035)
end
deriveTheme()

local function bind(obj, prop, fn)
	obj[prop] = fn()
	bound[#bound + 1] = { obj = obj, prop = prop, fn = fn }
end

local function themeText(obj, dim)
	bind(obj, "TextColor3", function()
		return dim and Theme.Dim or Theme.Text
	end)
end

local function onTheme(fn)
	themeListeners[#themeListeners + 1] = fn
end

local function applyTheme()
	deriveTheme()
	for _, b in ipairs(bound) do
		if b.obj.Parent then
			tween(b.obj, { [b.prop] = b.fn() }, THEME_TWEEN)
		end
	end
	for _, fn in ipairs(themeListeners) do
		fn()
	end
end

local Settings = {
	Enabled = true,
	Holding = false,
	FOV = 150,
	IgnoreFOV = false,
	TeamCheck = true,
	Strength = 500,
	Prediction = false,
	PredictionMs = 100,
	Triggerbot = false,
	TriggerDelay = 50,
	TriggerOnClick = false,
	ESP = true,
	Chams = true,
	BlurEnabled = true,
	BlurAmount = 18,
	ShowNames = false,
	Tracers = false,
	Boxes = false,
	BoxFill = false,
	Skeleton = false,
	ESPHealth = false,
	Skybox = false,
	SkyRainbow = false,
	WallCheck = true,
	Watermark = true,
	ShowFOV = true,
	AimPart = "Head",
	AimMode = "Hold",
	Fullbright = false,
	NoFog = false,
	Radar = false,
	RadarRange = 250,
	RadarSize = 160,
	RadarCorner = "TopRight",
	RadarX = -1,
	RadarY = -1,
	RadarDotSize = 7,
	RadarLineThickness = 1,
	UITransparency = 0,
	Fly = false,
	FlySpeed = 60,
	FlyVortex = false,
	VortexSpeed = 6,
	VortexRadius = 5,
	Noclip = false,
	Speed = false,
	SpeedValue = 40,
	InfiniteJump = false,
	Notifications = true,
	TargetNPCs = true,
	ESPNPCs = true,
	MouseTP = true,
	KeybindList = true,
	Ragebot = false,
	RageDistance = 4,
	RageBehind = true,
	RageAbove = false,
	RageBelow = false,
	RageOrbit = false,
	OrbitSpeed = 6,
	RageMode = "Closest",
	RageTarget = "",
}

local setESPEnabled
local printTeamInfo

local VORTEX_DISABLED = false
local LockedSettings = {}

local DisplayNames = {
	Enabled = "Aimbot", ShowFOV = "FOV Circle", IgnoreFOV = "Ignore FOV", TeamCheck = "Team Check", Triggerbot = "Triggerbot",
	ESP = "ESP", Chams = "Chams", ShowNames = "Usernames", Tracers = "Tracers",
	Boxes = "Boxes", BoxFill = "Box Fill", Skeleton = "Skeleton", ESPHealth = "Health", Skybox = "Skybox", SkyRainbow = "Rainbow Sky", Fly = "Fly", FlyVortex = "Vortex",
	Noclip = "Noclip", Speed = "Speed", InfiniteJump = "Infinite Jump",
	Watermark = "Watermark", BlurEnabled = "Background Blur", Notifications = "Notifications",
	TargetNPCs = "Target Zombies/NPCS", ESPNPCs = "Zombie/NPC ESP",
	MouseTP = "Mouse TP", KeybindList = "Keybind List",
	Ragebot = "Ragebot", RageOrbit = "Orbit",
	Fullbright = "Fullbright", NoFog = "No Fog", Radar = "Radar",
}

local Binds = {}
local function defBind(id, label, kind, key, input)
	Binds[#Binds + 1] = { id = id, label = label, kind = kind, key = key, input = input, default = input }
end
defBind("menu", "Menu", "menu", nil, Enum.KeyCode.End)
defBind("panic", "Panic (unload)", "panic", nil, Enum.KeyCode.Home)
defBind("aim", "Aim key", "hold", nil, Enum.UserInputType.MouseButton2)
for _, k in ipairs({
	"Enabled", "ShowFOV", "IgnoreFOV", "TeamCheck", "Triggerbot", "Ragebot", "ESP", "Chams", "ShowNames", "Tracers", "Boxes",
	"BoxFill", "Skeleton", "Skybox", "Fly", "Noclip", "Speed", "InfiniteJump", "Watermark", "BlurEnabled", "Notifications", "KeybindList",
}) do
	local default
	if k == "Triggerbot" then default = Enum.KeyCode.P end
	if k == "Fly" then default = Enum.KeyCode.Equals end
	if k == "Noclip" then default = Enum.KeyCode.N end
	defBind(k, DisplayNames[k], "toggle", k, default)
end
defBind("MouseTPKey", "Mouse TP", "press", nil, Enum.KeyCode.T)

local function getBind(id)
	for _, b in ipairs(Binds) do
		if b.id == id then return b end
	end
end

local KEY_NAMES = {
	Equals = "=", Minus = "-", Return = "Enter", Backquote = "`", LeftBracket = "[",
	RightBracket = "]", Semicolon = ";", Quote = "'", Comma = ",", Period = ".",
	Slash = "/", BackSlash = "\\", LeftShift = "LShift", RightShift = "RShift",
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftAlt = "LAlt", RightAlt = "RAlt",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6",
	Seven = "7", Eight = "8", Nine = "9",
}
local function keyName(input)
	if not input then return "None" end
	if input.EnumType == Enum.KeyCode then
		return KEY_NAMES[input.Name] or input.Name
	end
	if input == Enum.UserInputType.MouseButton1 then return "Left Click" end
	if input == Enum.UserInputType.MouseButton2 then return "Right Click" end
	if input == Enum.UserInputType.MouseButton3 then return "Middle Click" end
	return input.Name
end

local function inputMatches(input, bindInput)
	if not bindInput then return false end
	if bindInput.EnumType == Enum.KeyCode then
		return input.KeyCode == bindInput
	end
	return input.UserInputType == bindInput
end

local hintFns = {}
local function addHint(label, fn)
	label.Text = fn()
	hintFns[#hintFns + 1] = function()
		label.Text = fn()
	end
end
local function updateKeyHints()
	for _, fn in ipairs(hintFns) do
		fn()
	end
end

local rebinding = nil
local bindButtons = {}
local function refreshBindUI()
	for id, btn in pairs(bindButtons) do
		local b = getBind(id)
		if rebinding == b then
			btn.Text = "press a key..."
		else
			btn.Text = keyName(b.input)
		end
	end
end

local toggles = {}
local notify
local toast
local vortexStatus, vortexServerLabel
local rageStatus

local MAX_HIGHLIGHTS = 30
local ESPColors = {
	Fill = Color3.fromRGB(255, 70, 70),
	Outline = Color3.fromRGB(255, 255, 255),
	Tracer = Color3.fromRGB(255, 70, 70),
	Name = Color3.fromRGB(255, 255, 255),
	Box = Color3.fromRGB(255, 255, 255),
	BoxFill = Color3.fromRGB(255, 70, 70),
	Skeleton = Color3.fromRGB(255, 255, 255),
	Sky = Color3.fromRGB(90, 140, 255),
	Radar = Color3.fromRGB(255, 70, 70),
	RadarLines = Color3.fromRGB(255, 255, 255),
}

local FOVColor = Color3.fromRGB(255, 255, 255)
local persistOK = false
local saveStatusText = "saving: connecting..."
local saveStatusLabel
local saveNowFn = function() end

local Positions = {}
local function posToArr(p)
	return { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
end
local function arrToPos(a)
	if type(a) ~= "table" then return nil end
	for i = 1, 4 do
		if type(a[i]) ~= "number" or a[i] ~= a[i] then return nil end
	end
	return UDim2.new(math.clamp(a[1], 0, 1), math.clamp(a[2], -4000, 4000), math.clamp(a[3], 0, 1), math.clamp(a[4], -4000, 4000))
end

local ConfigAPI = {
	available = false,
	colorRefreshers = {},
	colorGetters = {
		["FOV Color"] = function() return FOVColor end,
		["Cham Fill"] = function() return ESPColors.Fill end,
		["Cham Outline"] = function() return ESPColors.Outline end,
		["Box"] = function() return ESPColors.Box end,
		["Box Fill"] = function() return ESPColors.BoxFill end,
		["Skeleton"] = function() return ESPColors.Skeleton end,
		["Sky Colour"] = function() return ESPColors.Sky end,
		["Radar"] = function() return ESPColors.Radar end,
		["Radar Lines"] = function() return ESPColors.RadarLines end,
		["Tracers"] = function() return ESPColors.Tracer end,
		["Usernames"] = function() return ESPColors.Name end,
		["Checkbox"] = function() return Theme.Switch end,
		["Accent"] = function() return Theme.Accent end,
		["Text"] = function() return Theme.Text end,
		["Background"] = function() return Theme.Background end,
		["Outline"] = function() return Theme.Outline end,
	},
}

do
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SAVE_VERSION = 2

local SAVE_BOOLS = {
	"Enabled", "IgnoreFOV", "TeamCheck", "Triggerbot", "TriggerOnClick", "ESP", "Chams", "BlurEnabled", "ShowNames", "Tracers",
	"Boxes", "BoxFill", "Skeleton", "ESPHealth", "Skybox", "SkyRainbow", "Watermark", "ShowFOV", "Fly", "Noclip", "Speed", "Fullbright", "NoFog", "Radar", "Prediction",
	"InfiniteJump", "Notifications", "TargetNPCs", "ESPNPCs", "MouseTP", "KeybindList", "Ragebot",
	"RageBehind", "RageAbove", "RageBelow", "RageOrbit",
}
local SAVE_NUMBERS = {
	RadarRange = { 50, 1000 },
	RadarSize = { 100, 300 },
	RadarDotSize = { 4, 14 },
	RadarX = { -1, 10000 },
	RadarY = { -1, 10000 },
	RadarLineThickness = { 1, 4 },
	FOV = { 20, 500 }, Strength = { 1, 500 }, PredictionMs = { 0, 500 }, TriggerDelay = { 0, 300 },
	BlurAmount = { 1, 56 }, UITransparency = { 0, 70 }, FlySpeed = { 5, 1000 },
	VortexSpeed = { 1, 100 }, VortexRadius = { 2, 60 }, SpeedValue = { 16, 250 },
	RageDistance = { 2, 20 }, OrbitSpeed = { 1, 30 },
}
local SAVE_THEME = { "Text", "Switch", "Accent", "Background", "Outline" }
local SAVE_ESP = { "Fill", "Outline", "Tracer", "Name", "Box", "BoxFill", "Skeleton", "Sky", "Radar", "RadarLines" }

local function colorToArr(c)
	return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
end

local function arrToColor(a)
	if type(a) == "table" and type(a[1]) == "number" and type(a[2]) == "number" and type(a[3]) == "number" then
		return Color3.fromRGB(math.clamp(a[1], 0, 255), math.clamp(a[2], 0, 255), math.clamp(a[3], 0, 255))
	end
end

local function inputToString(i)
	if not i then return "" end
	if i.EnumType == Enum.KeyCode then return "K:" .. i.Name end
	return "M:" .. i.Name
end

local function stringToInput(str)
	if type(str) ~= "string" or #str < 3 then return nil end
	local kind, name = str:sub(1, 1), str:sub(3)
	if kind == "K" then
		local ok, v = pcall(function() return Enum.KeyCode[name] end)
		if ok then return v end
	elseif kind == "M" and (name == "MouseButton2" or name == "MouseButton3") then
		return Enum.UserInputType[name]
	end
	return nil
end

local function takeSnapshot()
	local snap = { v = SAVE_VERSION, settings = {}, theme = {}, esp = {}, binds = {}, pos = {} }
	for _, k in ipairs(SAVE_BOOLS) do
		snap.settings[k] = Settings[k] and true or false
	end
	for k in pairs(SAVE_NUMBERS) do
		snap.settings[k] = Settings[k]
	end
	snap.settings.AimPart = Settings.AimPart
	snap.settings.AimMode = Settings.AimMode
	snap.settings.RageMode = Settings.RageMode
	snap.settings.RageTarget = Settings.RageTarget
	for _, k in ipairs(SAVE_THEME) do
		snap.theme[k] = colorToArr(Theme[k])
	end
	for _, k in ipairs(SAVE_ESP) do
		snap.esp[k] = colorToArr(ESPColors[k])
	end
	snap.fov = colorToArr(FOVColor)
	if Positions.hud then snap.pos.hud = posToArr(Positions.hud) end
	if Positions.keylist then snap.pos.keylist = posToArr(Positions.keylist) end
	for _, b in ipairs(Binds) do
		snap.binds[b.id] = inputToString(b.input)
	end
	return snap
end

local function applySaved(d)
	local s = type(d.settings) == "table" and d.settings or {}
	for _, k in ipairs(SAVE_BOOLS) do
		if type(s[k]) == "boolean" then Settings[k] = s[k] end
	end
	for k, range in pairs(SAVE_NUMBERS) do
		if type(s[k]) == "number" and s[k] == s[k] then
			Settings[k] = math.clamp(math.floor(s[k] + 0.5), range[1], range[2])
		end
	end
	if s.AimPart == "Head" or s.AimPart == "Body" then Settings.AimPart = s.AimPart end
	if s.AimMode == "Hold" or s.AimMode == "Toggle" then Settings.AimMode = s.AimMode end
	if type(s.RadarCorner) == "string" then
		local corners = { TopRight = true, TopLeft = true, BottomRight = true, BottomLeft = true, Custom = true }
		if corners[s.RadarCorner] then Settings.RadarCorner = s.RadarCorner end
	end
	if s.RageMode == "Closest" or s.RageMode == "Selected" then Settings.RageMode = s.RageMode end
	if type(s.RageTarget) == "string" then Settings.RageTarget = s.RageTarget:sub(1, 24) end

	if type(d.v) == "number" and d.v >= SAVE_VERSION then
		local t = type(d.theme) == "table" and d.theme or {}
		for _, k in ipairs(SAVE_THEME) do
			local c = arrToColor(t[k])
			if c then Theme[k] = c end
		end
		deriveTheme()
	end

	local e = type(d.esp) == "table" and d.esp or {}
	for _, k in ipairs(SAVE_ESP) do
		local c = arrToColor(e[k])
		if c then ESPColors[k] = c end
	end
	FOVColor = arrToColor(d.fov) or FOVColor

	local p = type(d.pos) == "table" and d.pos or {}
	Positions.hud = arrToPos(p.hud)
	Positions.keylist = arrToPos(p.keylist)

	local b = type(d.binds) == "table" and d.binds or {}
	for _, bind in ipairs(Binds) do
		local v = b[bind.id]
		if v == "" then
			if bind.kind ~= "menu" and bind.kind ~= "panic" then bind.input = nil end
		elseif v ~= nil then
			local inp = stringToInput(v)
			if inp then bind.input = inp end
		end
	end
end

local function setStatus(text)
	saveStatusText = text
	if saveStatusLabel then saveStatusLabel.Text = text end
end

local hasFiles = type(readfile) == "function" and type(writefile) == "function"
local FILE_NAME = "OULMenu_" .. tostring(LocalPlayer.UserId) .. ".json"

local manualPending = false

if hasFiles then

	local okRead, content = pcall(readfile, FILE_NAME)
	if okRead and type(content) == "string" and content ~= "" then
		local okDecode, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		if okDecode and type(data) == "table" then
			local okApply, err = pcall(applySaved, data)
			if not okApply then warn("[OUL save] could not apply the saved file: " .. tostring(err)) end
		end
	end
	persistOK = true
	setStatus("saving: local file")

	local function writeNow()
		local okEnc, enc = pcall(function()
			return HttpService:JSONEncode(takeSnapshot())
		end)
		if not okEnc then return false, enc end
		local okWrite, err = pcall(writefile, FILE_NAME, enc)
		return okWrite, err, enc
	end

	saveNowFn = function()
		local ok, err = writeNow()
		setStatus(ok and "saved to file" or "save failed (see Output)")
		if not ok then warn("[OUL save] " .. tostring(err)) end
		if toast then toast(ok and "Settings saved" or "Save failed - see Output") end
	end

	local lastSaved = HttpService:JSONEncode(takeSnapshot())
	task.spawn(function()
		while alive do
			task.wait(1)
			if not alive then break end
			local okEnc, enc = pcall(function()
				return HttpService:JSONEncode(takeSnapshot())
			end)
			if okEnc and enc ~= lastSaved then
				lastSaved = enc
				local ok, err = pcall(writefile, FILE_NAME, enc)
				setStatus(ok and "saved to file" or "save failed (see Output)")
				if not ok then warn("[OUL save] " .. tostring(err)) end
			end
		end
	end)
else
	local saveRemote = ReplicatedStorage:FindFirstChild("OULSaveSettings")
	local loadFn = ReplicatedStorage:WaitForChild("OULLoadSettings", 3)
	saveRemote = saveRemote or ReplicatedStorage:WaitForChild("OULSaveSettings", 1)
	local statusRemote = ReplicatedStorage:FindFirstChild("OULSaveStatus") or ReplicatedStorage:WaitForChild("OULSaveStatus", 1)

	if loadFn and saveRemote then
		local result, done = nil, false
		task.spawn(function()
			local ok, res = pcall(function()
				return loadFn:InvokeServer()
			end)
			if ok then result = res end
			done = true
		end)
		local waited = os.clock()
		while not done and os.clock() - waited < 10 do
			task.wait()
		end

		if type(result) == "table" and result.loaded then
			persistOK = true
			setStatus("saving: on")
			if type(result.data) == "table" then
				local ok, err = pcall(applySaved, result.data)
				if not ok then warn("[OUL save] could not apply saved settings: " .. tostring(err)) end
			end
		elseif type(result) == "table" then
			setStatus("saving off: load failed")
			warn("[OUL save] the server could not load your data, so saving is off: " .. tostring(result.reason))
		else
			setStatus("saving off: no reply")
			warn("[OUL save] the server did not answer in time, so saving is off")
		end
	else
		setStatus("saving off: no server script")
		warn("[OUL save] OULSaveServer not found in ReplicatedStorage/ServerScriptService, so your settings will not be saved")
	end

	if persistOK then

		if statusRemote then
			track(statusRemote.OnClientEvent:Connect(function(ok, msg)
				if ok then
					setStatus("saved")
				else
					setStatus("save failed (see Output)")
					warn("[OUL save] " .. tostring(msg))
				end
				if manualPending then
					manualPending = false
					if toast then toast(ok and "Settings saved" or "Save failed - see Output") end
				end
			end))
		end

		saveNowFn = function()
			manualPending = true
			setStatus("saving...")
			pcall(function()
				saveRemote:FireServer(takeSnapshot(), true)
			end)
		end

		local lastSaved = HttpService:JSONEncode(takeSnapshot())
		task.spawn(function()
			while alive do
				task.wait(1)
				if not alive then break end
				local ok, enc = pcall(function()
					return HttpService:JSONEncode(takeSnapshot())
				end)
				if ok and enc ~= lastSaved then
					lastSaved = enc
					setStatus("saving...")
					pcall(function()
						saveRemote:FireServer(takeSnapshot())
					end)
				end
			end
		end)
	else
		saveNowFn = function()
			if toast then toast("Saving is off - see the status line") end
		end
	end
end

local CONFIG_DIR = "OULConfigs"
local AUTOLOAD_FILE = CONFIG_DIR .. "/_autoload.txt"

ConfigAPI.available = hasFiles
	and type(listfiles) == "function" and type(delfile) == "function"
	and type(isfolder) == "function" and type(makefolder) == "function"
	and type(isfile) == "function"

local function cfgPath(name)
	return CONFIG_DIR .. "/" .. name .. ".json"
end

function ConfigAPI.clean(name)
	name = tostring(name or "")
	name = name:gsub("[^%w%-_ ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
	return name:sub(1, 24)
end

function ConfigAPI.list()
	local names = {}
	local ok, files = pcall(listfiles, CONFIG_DIR)
	if ok and type(files) == "table" then
		for _, f in ipairs(files) do
			local n = string.match(f, "([^/\\]+)%.json$")
			if n then names[#names + 1] = n end
		end
	end
	table.sort(names, function(a, b) return a:lower() < b:lower() end)
	return names
end

function ConfigAPI.save(name)
	name = ConfigAPI.clean(name)
	if name == "" then return false, "bad name" end
	return pcall(function()
		if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
		writefile(cfgPath(name), HttpService:JSONEncode(takeSnapshot()))
	end)
end

function ConfigAPI.load(name)
	return pcall(function()
		applySaved(HttpService:JSONDecode(readfile(cfgPath(name))))
	end)
end

function ConfigAPI.getAutoload()
	local ok, v = pcall(function()
		if isfile(AUTOLOAD_FILE) then return readfile(AUTOLOAD_FILE) end
	end)
	if ok and type(v) == "string" then
		v = ConfigAPI.clean(v)
		if v ~= "" then return v end
	end
	return nil
end

function ConfigAPI.setAutoload(name)
	return pcall(function()
		if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
		writefile(AUTOLOAD_FILE, name or "")
	end)
end

function ConfigAPI.delete(name)
	return pcall(function()
		if isfile(cfgPath(name)) then delfile(cfgPath(name)) end
		if ConfigAPI.getAutoload() == name then writefile(AUTOLOAD_FILE, "") end
	end)
end

if ConfigAPI.available then
	local auto = ConfigAPI.getAutoload()
	local exists = auto and select(2, pcall(isfile, cfgPath(auto)))
	if auto and exists then
		local ok, err = ConfigAPI.load(auto)
		if not ok then warn("[OUL config] autoload failed: " .. tostring(err)) end
	end
end
end

local CORPSE_WORDS = { "ragdoll", "corpse", "dead", "bodies", "debris", "gib" }
local function isAlive(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
	if model:GetAttribute("Dead") or model:GetAttribute("IsDead") or hum:GetAttribute("Dead") then
		return false
	end

	if not Players:GetPlayerFromCharacter(model) then

		if Players:FindFirstChild(model.Name) then return false end
		local node = model
		while node and node ~= workspace do
			local n = string.lower(node.Name)
			for _, w in ipairs(CORPSE_WORDS) do
				if string.find(n, w, 1, true) then return false end
			end
			node = node.Parent
		end
	end
	return true
end

local npcCache = {}
task.spawn(function()
	while alive do
		local list = {}
		for _, d in ipairs(workspace:GetDescendants()) do
			if d:IsA("Humanoid") then
				local model = d.Parent
				if model and model:IsA("Model") and model ~= LocalPlayer.Character
					and not Players:GetPlayerFromCharacter(model) and isAlive(model) then
					list[#list + 1] = model
				end
			end
		end
		npcCache = list
		task.wait(1)
	end
end)

local function espEntities()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local c = plr.Character
			list[#list + 1] = { plr, (c and isAlive(c)) and c or nil }
		end
	end
	if Settings.ESPNPCs then
		for _, model in ipairs(npcCache) do
			if model.Parent and isAlive(model) then
				list[#list + 1] = { model, model }
			end
		end
	end
	return list
end

local espFolder = Instance.new("Folder")
espFolder.Name = "OULESP"
espFolder.Parent = workspace

local applyWorldLighting
do
local savedLighting = nil
applyWorldLighting = function()
	if Settings.Fullbright or Settings.NoFog then
		if not savedLighting then
			savedLighting = {
				Brightness = Lighting.Brightness,
				ClockTime = Lighting.ClockTime,
				GlobalShadows = Lighting.GlobalShadows,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				Ambient = Lighting.Ambient,
				FogStart = Lighting.FogStart,
				FogEnd = Lighting.FogEnd,
			}
		end
	end

	if Settings.Fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	elseif savedLighting then
		Lighting.Brightness = savedLighting.Brightness
		Lighting.ClockTime = savedLighting.ClockTime
		Lighting.GlobalShadows = savedLighting.GlobalShadows
		Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
		Lighting.Ambient = savedLighting.Ambient
	end

	if Settings.NoFog then
		Lighting.FogStart = 100000
		Lighting.FogEnd = 100000
		for _, c in ipairs(Lighting:GetChildren()) do
			if c:IsA("Atmosphere") then
				if c:GetAttribute("OULOrigDensity") == nil then
					c:SetAttribute("OULOrigDensity", c.Density)
				end
				c.Density = 0
			end
		end
	elseif savedLighting then
		Lighting.FogStart = savedLighting.FogStart
		Lighting.FogEnd = savedLighting.FogEnd
		for _, c in ipairs(Lighting:GetChildren()) do
			if c:IsA("Atmosphere") then
				c.Density = c:GetAttribute("OULOrigDensity") or c.Density
			end
		end
	end

	if not Settings.Fullbright and not Settings.NoFog then
		savedLighting = nil
	end
end

track(RunService.Heartbeat:Connect(function()
	if (Settings.Fullbright or Settings.NoFog) and savedLighting then
		applyWorldLighting()
	end
end))
end

do
	local radarGui = Instance.new("Frame")
	radarGui.Name = "OULRadar"
	radarGui.BackgroundTransparency = 1
	radarGui.AnchorPoint = Vector2.new(0.5, 0.5)
	radarGui.Size = UDim2.fromOffset(Settings.RadarSize, Settings.RadarSize)
	radarGui.Visible = false
	radarGui.ZIndex = 90
	radarGui.Parent = gui

	local useDrawing = false
	pcall(function()
		if Drawing and Drawing.new then
			local t = Drawing.new("Circle")
			t.Visible = false
			t:Remove()
			useDrawing = true
		end
	end)
	ConfigAPI.radarMode = useDrawing and "Drawing" or "GUI"

	local BLACK = Color3.fromRGB(0, 0, 0)
	local RING_FRACS = { 1, 2 / 3, 1 / 3 }
	local MARGIN, TOP_MARGIN = 16, 50

	local function radarCentre(r)
		local vp = workspace.CurrentCamera.ViewportSize
		local corner = Settings.RadarCorner
		if corner == "Custom" then
			if Settings.RadarX < 0 or Settings.RadarY < 0 then
				Settings.RadarX = vp.X - MARGIN - r
				Settings.RadarY = TOP_MARGIN + r
			end
			return math.clamp(Settings.RadarX, r, vp.X - r), math.clamp(Settings.RadarY, r, vp.Y - r)
		end
		local cx = (corner == "TopLeft" or corner == "BottomLeft") and (MARGIN + r) or (vp.X - MARGIN - r)
		local cy = (corner == "TopLeft" or corner == "TopRight") and (TOP_MARGIN + r) or (vp.Y - MARGIN - r)
		return cx, cy
	end

	local dObjs = {}
	local function newD(kind)
		local o = Drawing.new(kind)
		o.Visible = false
		dObjs[#dObjs + 1] = o
		return o
	end

	local dRings, dLines, dCenter = {}, {}, nil
	if useDrawing then
		for _ = 1, #RING_FRACS do
			local back, front = newD("Circle"), newD("Circle")
			for _, c in ipairs({ back, front }) do
				c.NumSides = 64
				c.Filled = false
			end
			back.Color, back.Transparency = BLACK, 0.45
			front.Transparency = 1
			dRings[#dRings + 1] = { back, front }
		end
		for _ = 1, 2 do
			local back, front = newD("Line"), newD("Line")
			back.Color, back.Transparency = BLACK, 0.45
			front.Transparency = 0.8
			dLines[#dLines + 1] = { back, front }
		end
		dCenter = newD("Circle")
		dCenter.Filled = true
		dCenter.Radius = 3
		dCenter.NumSides = 16
		dCenter.Transparency = 1
	end

	local gRings, gLines, gCentre = {}, {}, nil
	for _, frac in ipairs(RING_FRACS) do
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.Size = UDim2.fromScale(frac, frac)
		ring.BackgroundTransparency = 1
		ring.ZIndex = 90
		ring.Parent = radarGui
		Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
		local st = Instance.new("UIStroke")
		st.Transparency = 0.1
		st.Parent = ring
		gRings[#gRings + 1] = st
	end
	for i = 1, 2 do
		local line = Instance.new("Frame")
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Position = UDim2.fromScale(0.5, 0.5)
		line.Size = (i == 1) and UDim2.new(1, 0, 0, 1) or UDim2.new(0, 1, 1, 0)
		line.BackgroundTransparency = 0.3
		line.BorderSizePixel = 0
		line.ZIndex = 90
		line.Parent = radarGui
		gLines[#gLines + 1] = line
	end
	do
		local centre = Instance.new("Frame")
		centre.AnchorPoint = Vector2.new(0.5, 0.5)
		centre.Position = UDim2.fromScale(0.5, 0.5)
		centre.Size = UDim2.fromOffset(6, 6)
		centre.BorderSizePixel = 0
		centre.ZIndex = 91
		centre.Parent = radarGui
		Instance.new("UICorner", centre).CornerRadius = UDim.new(1, 0)
		gCentre = centre
	end

	local dots = {}
	local dragging, dragOffset = false, Vector2.zero

	track(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not (Settings.Radar and Settings.RadarCorner == "Custom") then return end
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then return end
		local r = Settings.RadarSize / 2
		local cx, cy = radarCentre(r)
		local m = UserInputService:GetMouseLocation()
		if (m - Vector2.new(cx, cy)).Magnitude <= r then
			dragging = true
			dragOffset = Vector2.new(cx, cy) - m
		end
	end))

	local function dropDot(key)
		local d = dots[key]
		if d then
			pcall(function()
				if useDrawing then d:Remove() else d:Destroy() end
			end)
			if useDrawing then
				for i, o in ipairs(dObjs) do
					if o == d then
						table.remove(dObjs, i)
						break
					end
				end
			end
			dots[key] = nil
		end
	end

	local function hideDrawing()
		for _, o in ipairs(dObjs) do
			pcall(function() o.Visible = false end)
		end
	end

	track(RunService.RenderStepped:Connect(function()
		if not Settings.Radar then
			dragging = false
			radarGui.Visible = false
			if useDrawing then hideDrawing() end
			for key in pairs(dots) do dropDot(key) end
			return
		end

		local size = Settings.RadarSize
		local r = size / 2
		if dragging then
			if Settings.RadarCorner == "Custom" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				local m = UserInputService:GetMouseLocation() + dragOffset
				Settings.RadarX, Settings.RadarY = m.X, m.Y
			else
				dragging = false
			end
		end
		local cx, cy = radarCentre(r)
		local range = Settings.RadarRange
		local lineColor = ESPColors.RadarLines
		local lineThick = Settings.RadarLineThickness
		local dotSize = Settings.RadarDotSize

		if useDrawing then
			radarGui.Visible = false
			for i, frac in ipairs(RING_FRACS) do
				local back, front = dRings[i][1], dRings[i][2]
				back.Position, front.Position = Vector2.new(cx, cy), Vector2.new(cx, cy)
				back.Radius, front.Radius = r * frac, r * frac
				back.Thickness = lineThick + 2
				front.Thickness = lineThick
				front.Color = lineColor
				back.Visible, front.Visible = true, true
			end
			for i, l in ipairs(dLines) do
				local from, to
				if i == 1 then
					from, to = Vector2.new(cx - r, cy), Vector2.new(cx + r, cy)
				else
					from, to = Vector2.new(cx, cy - r), Vector2.new(cx, cy + r)
				end
				local back, front = l[1], l[2]
				back.From, back.To = from, to
				front.From, front.To = from, to
				back.Thickness = lineThick + 2
				front.Thickness = lineThick
				front.Color = lineColor
				back.Visible, front.Visible = true, true
			end
			dCenter.Position = Vector2.new(cx, cy)
			dCenter.Color = lineColor
			dCenter.Visible = true
		else
			radarGui.Size = UDim2.fromOffset(size, size)
			radarGui.Position = UDim2.fromOffset(cx, cy)
			radarGui.Visible = true
			for _, st in ipairs(gRings) do
				st.Color = lineColor
				st.Thickness = lineThick
			end
			for _, line in ipairs(gLines) do
				line.BackgroundColor3 = lineColor
			end
			gCentre.BackgroundColor3 = lineColor
		end

		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then
			for key in pairs(dots) do dropDot(key) end
			return
		end

		local cam = workspace.CurrentCamera
		local look = cam.CFrame.LookVector
		local flatLook = Vector3.new(look.X, 0, look.Z)
		if flatLook.Magnitude < 0.001 then flatLook = Vector3.new(0, 0, -1) end
		local base = CFrame.lookAt(Vector3.zero, flatLook)

		local live = {}
		for _, ent in ipairs(espEntities()) do
			local key, char = ent[1], ent[2]
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				live[key] = true
				local delta = root.Position - myRoot.Position
				local rel = base:VectorToObjectSpace(Vector3.new(delta.X, 0, delta.Z))
				local v = Vector2.new(rel.X, rel.Z) / range
				if v.Magnitude > 1 then v = v.Unit end

				local d = dots[key]
				if useDrawing then
					if not d then
						d = newD("Circle")
						d.Filled = true
						d.NumSides = 16
						d.Transparency = 1
						dots[key] = d
					end
					d.Color = ESPColors.Radar
					d.Radius = dotSize / 2
					d.Position = Vector2.new(cx, cy) + v * r
					d.Visible = true
				else
					if not d then
						d = Instance.new("Frame")
						d.AnchorPoint = Vector2.new(0.5, 0.5)
						d.BorderSizePixel = 0
						d.ZIndex = 92
						d.Parent = radarGui
						Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
						dots[key] = d
					end
					d.Size = UDim2.fromOffset(dotSize, dotSize)
					d.BackgroundColor3 = ESPColors.Radar
					d.Position = UDim2.fromOffset(r + v.X * r, r + v.Y * r)
				end
			end
		end

		for key in pairs(dots) do
			if not live[key] then dropDot(key) end
		end
	end))

	ConfigAPI.radarCleanup = function()
		for _, o in ipairs(dObjs) do
			pcall(function() o:Remove() end)
		end
		dObjs = {}
		dots = {}
	end
end

local highlights = {}
local nameTags = {}

local function removeTag(plr)
	local t = nameTags[plr]
	if t then
		t:Destroy()
		nameTags[plr] = nil
	end
end

local function applyTag(plr, char)
	local head = char:FindFirstChild("Head")
	if not head then return end
	removeTag(plr)

	local tag = Instance.new("BillboardGui")
	tag.Name = "ESPName"
	tag.Adornee = head
	tag.AlwaysOnTop = true
	tag.Size = UDim2.fromOffset(200, 20)
	tag.StudsOffset = Vector3.new(0, 2.2, 0)
	tag.Enabled = Settings.ESP and Settings.ShowNames

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = plr.Name
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextColor3 = ESPColors.Name
	lbl.TextStrokeTransparency = 0.4
	lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	lbl.Parent = tag

	tag.Parent = espFolder
	nameTags[plr] = tag
end

local function setChamColor(color)
	ESPColors.Fill = color
	for _, h in pairs(highlights) do
		h.FillColor = color
	end
end

local function setChamOutlineColor(color)
	ESPColors.Outline = color
	for _, h in pairs(highlights) do
		h.OutlineColor = color
	end
end

local function setTracerColor(color)
	ESPColors.Tracer = color
end

local function setBoxColor(color)
	ESPColors.Box = color
end

local function setBoxFillColor(color)
	ESPColors.BoxFill = color
end

local function setNameColor(color)
	ESPColors.Name = color
	for _, tag in pairs(nameTags) do
		local lbl = tag:FindFirstChild("Label")
		if lbl then
			lbl.TextColor3 = color
		end
	end
end

local function removeESP(plr)
	removeTag(plr)
	local h = highlights[plr]
	if h then
		h:Destroy()
		highlights[plr] = nil
	end
end

local function applyESP(plr, char)
	removeESP(plr)
	if not char then return end

	local h = Instance.new("Highlight")
	h.Name = "ESPChams"
	h.Adornee = char
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillColor = ESPColors.Fill
	h.OutlineColor = ESPColors.Outline
	h.FillTransparency = 0.5
	h.OutlineTransparency = 0
	h.Enabled = Settings.ESP and Settings.Chams
	h.Parent = char
	highlights[plr] = h
end

local function refreshESP()
	local cam = workspace.CurrentCamera
	local camPos = cam and cam.CFrame.Position or Vector3.zero
	local list = {}
	local seen = {}

	for _, ent in ipairs(espEntities()) do
		local key, char = ent[1], ent[2]
		seen[key] = true
		if char then
			local h = highlights[key]
			if not h or not h.Parent or h.Adornee ~= char then
				applyESP(key, char)
				h = highlights[key]
			end

			local head = char:FindFirstChild("Head")
			local tag = nameTags[key]
			if head and (not tag or not tag.Parent or tag.Adornee ~= head) then
				applyTag(key, char)
				tag = nameTags[key]
			end
			if tag then
				tag.Enabled = Settings.ESP and Settings.ShowNames
			end

			local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
			local dist = root and (root.Position - camPos).Magnitude or math.huge
			if h then
				table.insert(list, { h = h, dist = dist, npc = key:IsA("Model") })
			end
		else
			removeESP(key)
		end
	end

	for key in pairs(highlights) do
		if not seen[key] then removeESP(key) end
	end
	for key in pairs(nameTags) do
		if not seen[key] then removeTag(key) end
	end

	table.sort(list, function(a, b)
		if a.npc ~= b.npc then return not a.npc end
		return a.dist < b.dist
	end)
	for i, item in ipairs(list) do
		item.h.Enabled = Settings.ESP and Settings.Chams and i <= MAX_HIGHLIGHTS
	end
end

local function trackPlayer(plr)
	if plr == LocalPlayer then return end
	track(plr.CharacterAdded:Connect(function(char)

		pcall(function()
			applyESP(plr, char)
			refreshESP()
		end)
		task.spawn(function()
			char:WaitForChild("HumanoidRootPart", 10)
			if alive and plr.Character == char then
				pcall(function()
					applyESP(plr, char)
					refreshESP()
				end)
			end
		end)
	end))
	track(plr.CharacterRemoving:Connect(function()
		removeESP(plr)
	end))
	if plr.Character then
		applyESP(plr, plr.Character)
	end
end

setESPEnabled = function()
	refreshESP()
end

for _, plr in ipairs(Players:GetPlayers()) do
	trackPlayer(plr)
end
track(Players.PlayerAdded:Connect(trackPlayer))
track(Players.PlayerRemoving:Connect(removeESP))

task.spawn(function()
	while alive do
		task.wait(0.25)
		local ok, err = pcall(refreshESP)
		if not ok then
			warn("[OUL esp] " .. tostring(err))
		end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "AimbotUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
pcall(function() gui.OnTopOfCoreBlur = true end)

do
	local preferred
	pcall(function()
		if gethui then
			preferred = gethui()
		else
			preferred = game:GetService("CoreGui")
		end
	end)

	local ok = false
	if preferred then
		ok = pcall(function()
			gui.Parent = preferred
		end) and gui.Parent == preferred
	end
	if not ok then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
circle.Parent = gui
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke", circle)
circleStroke.Color = FOVColor
circleStroke.Thickness = 1.5
circleStroke.Transparency = 0.3

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function outline(obj, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	bind(s, "Color", function()
		return Theme.Outline
	end)
	return s
end

local function newLabel(parent, text, size, dim)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = FONT
	l.TextSize = size or 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	themeText(l, dim)
	l.Parent = parent
	return l
end

local SIDE_W = 96
local PANEL_W = SIDE_W + 440
local TITLE_H = 38
local TAB_ROW = 30
local PAGE_X = SIDE_W + 8
local PAGE_Y = TITLE_H + 8
local FOOTER_H = 18

local panel = Instance.new("CanvasGroup")
panel.Size = UDim2.fromOffset(PANEL_W, 300)

do
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	panel.Position = UDim2.fromOffset(math.floor((vp.X - PANEL_W) / 2), math.floor((vp.Y - 300) / 2))
end
panel.BorderSizePixel = 0
panel.Active = true
panel.ZIndex = 100
panel.GroupTransparency = 1
panel.Visible = false
panel.Parent = gui
bind(panel, "BackgroundColor3", function()
	return Theme.Background
end)
corner(panel, 5)
outline(panel)

do
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BorderSizePixel = 0
topLine.ZIndex = 5
topLine.Parent = panel
bind(topLine, "BackgroundColor3", function()
	return Theme.Accent
end)
end

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = panel

makeLogo(titleBar, 26, 10, (TITLE_H - 26) / 2)

local TAB_NAMES = { "combat", "visuals", "movement", "settings" }
local TAB_LABELS = { combat = "Combat", visuals = "Visuals", movement = "Movement", settings = "Settings" }

local SUBTABS = {
	combat = {
		{ id = "aimbot", label = "Aimbot" },
		{ id = "trigger", label = "Triggerbot" },
		{ id = "silent", label = "Silent Aim" },
		{ id = "antikatana", label = "Antikatana" },
		{ id = "ragebot", label = "Ragebot" },
	},
	visuals = { { id = "esp", label = "ESP" }, { id = "colours", label = "Colours" }, { id = "sky", label = "Sky" }, { id = "radar", label = "Radar" }, { id = "world", label = "World" } },
	settings = { { id = "general", label = "General" }, { id = "keybinds", label = "Keybinds" }, { id = "configs", label = "Configs" } },
	movement = { { id = "fly", label = "Fly" }, { id = "vortex", label = "Vortex" }, { id = "noclip", label = "Noclip" }, { id = "speed", label = "Speed" }, { id = "jump", label = "Jump" }, { id = "mousetp", label = "Mouse TP" } },
}
local SUB_H = 26
local SUB_W = 80

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, SIDE_W, 1, -(TITLE_H + FOOTER_H))
tabBar.Position = UDim2.fromOffset(0, TITLE_H)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel

do
local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.fromOffset(0, TITLE_H)
titleLine.BorderSizePixel = 0
titleLine.Parent = panel
bind(titleLine, "BackgroundColor3", function()
	return Theme.Outline
end)
end

do
local tabLine = Instance.new("Frame")
tabLine.Size = UDim2.new(0, 1, 1, -(TITLE_H + FOOTER_H))
tabLine.Position = UDim2.fromOffset(SIDE_W, TITLE_H)
tabLine.BorderSizePixel = 0
tabLine.Parent = panel
bind(tabLine, "BackgroundColor3", function()
	return Theme.Outline
end)
end

local underline = Instance.new("Frame")
underline.Size = UDim2.fromOffset(2, TAB_ROW - 8)
underline.Position = UDim2.fromOffset(0, 11)
underline.BorderSizePixel = 0
underline.ZIndex = 3
underline.Parent = tabBar
bind(underline, "BackgroundColor3", function()
	return Theme.Accent
end)

do
local footer = newLabel(panel, "", 11, true)
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, PAGE_X, 1, -5)
footer.Size = UDim2.new(1, -(PAGE_X + 8), 0, 12)
addHint(footer, function()
	return keyName(getBind("menu").input) .. "  -  hide / show menu"
end)
end

local hud = Instance.new("TextLabel")
hud.Size = UDim2.fromOffset(112, 32)
hud.AnchorPoint = Vector2.new(1, 0)
hud.Position = Positions.hud or UDim2.new(1, -10, 0, 8)
hud.BackgroundTransparency = 0.15
hud.BorderSizePixel = 0
hud.Text = "FPS : --"
hud.TextXAlignment = Enum.TextXAlignment.Right
do
	local hudPad = Instance.new("UIPadding")
	hudPad.PaddingRight = UDim.new(0, 12)
	hudPad.Parent = hud
end
hud.Font = FONT
hud.TextSize = 12
hud.Visible = Settings.Watermark
hud.ZIndex = 100
hud.Parent = gui
bind(hud, "BackgroundColor3", function()
	return Theme.Background
end)
themeText(hud)
corner(hud, 4)
makeLogo(hud, 24, 6, 4)
do
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = hud
	bind(s, "Color", function()
		return Theme.Accent
	end)
end

do
	hud.Active = true
	local dragging, dragStart, startPos
	hud.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPos = true, input.Position, hud.Position
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			hud.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragging then
				Positions.hud = hud.Position
			end
			dragging = false
		end
	end))
end

do
	local frames, elapsed = 0, 0
	track(RunService.RenderStepped:Connect(function(dt)
		frames += 1
		elapsed += dt
		if elapsed >= 0.5 then
			hud.Text = "FPS : " .. math.floor(frames / elapsed + 0.5)
			frames, elapsed = 0, 0
		end
	end))
end

local keyList = Instance.new("Frame")
keyList.Name = "KeybindList"
keyList.Size = UDim2.fromOffset(150, 0)
keyList.AutomaticSize = Enum.AutomaticSize.XY
keyList.Position = Positions.keylist or UDim2.new(0, 10, 0.35, 0)
keyList.BackgroundTransparency = 0.15
keyList.BorderSizePixel = 0
keyList.Active = true
keyList.Visible = Settings.KeybindList
keyList.ZIndex = 100
keyList.Parent = gui
bind(keyList, "BackgroundColor3", function()
	return Theme.Background
end)
corner(keyList, 4)
do
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = keyList
	bind(s, "Color", function()
		return Theme.Accent
	end)

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = keyList

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 5)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = keyList
end

do
	local head = newLabel(keyList, "Keybinds", 12)
	head.Size = UDim2.fromOffset(0, 16)
	head.AutomaticSize = Enum.AutomaticSize.X
	head.LayoutOrder = 0
	head.ZIndex = 101
	bind(head, "TextColor3", function()
		return Theme.Accent
	end)
	pcall(function()
		head.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
	end)
end

do
	local dragging, dragStart, startPos
	keyList.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPos = true, input.Position, keyList.Position
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			keyList.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragging then
				Positions.keylist = keyList.Position
			end
			dragging = false
		end
	end))
end

do

	local SKIP = { menu = true, panic = true, Watermark = true, BlurEnabled = true, Notifications = true, KeybindList = true }
	local rows = {}
	local lastSig
	local timer = 0

	local function rebuild()
		local entries, sig = {}, {}
		for _, b in ipairs(Binds) do
			if b.input and not SKIP[b.id] then
				local on, tag
				if b.kind == "toggle" then
					on, tag = Settings[b.key] and true or false, "Toggle"
				elseif b.kind == "hold" then
					on, tag = Settings.Holding and true or false, (Settings.AimMode == "Toggle") and "Toggle" or "Hold"
				else
					on, tag = false, "Press"
				end
				local name = string.gsub(b.label, "%s*%(hold%)", "")
				local text = "[" .. keyName(b.input) .. "] " .. name .. " (" .. tag .. ")"
				entries[#entries + 1] = { text = text, on = on }
				sig[#sig + 1] = text .. (on and "1" or "0")
			end
		end

		local s = table.concat(sig, "|")
		if s == lastSig then return end
		lastSig = s

		for _, r in ipairs(rows) do
			r:Destroy()
		end
		rows = {}
		for i, e in ipairs(entries) do
			local l = Instance.new("TextLabel")
			l.BackgroundTransparency = 1
			l.Size = UDim2.fromOffset(0, 14)
			l.AutomaticSize = Enum.AutomaticSize.X
			l.LayoutOrder = i
			l.Font = FONT
			l.TextSize = 12
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.Text = e.text
			l.TextColor3 = e.on and Theme.Accent or Theme.Dim
			l.ZIndex = 101
			l.Parent = keyList
			rows[i] = l
		end
	end

	onTheme(function()
		lastSig = nil
	end)

	track(RunService.Heartbeat:Connect(function(dt)
		timer += dt
		if timer < 0.1 then return end
		timer = 0
		if Settings.KeybindList then
			rebuild()
		end
	end))
end

do
	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPos = true, input.Position, panel.Position
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			panel.Position = UDim2.fromOffset(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))
end

local toastHolder = Instance.new("Frame")
toastHolder.Name = "Toasts"
toastHolder.BackgroundTransparency = 1
toastHolder.AnchorPoint = Vector2.new(1, 1)
toastHolder.Position = UDim2.new(1, -14, 1, -14)
toastHolder.Size = UDim2.fromOffset(210, 260)
toastHolder.ZIndex = 200
toastHolder.Parent = gui
do
	local tl = Instance.new("UIListLayout")
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
	tl.HorizontalAlignment = Enum.HorizontalAlignment.Right
	tl.Padding = UDim.new(0, 6)
	tl.Parent = toastHolder
end

local toastOrder = 0
local toastList = {}

toast = function(richText)
	toastOrder += 1
	local t = Instance.new("CanvasGroup")
	t.Size = UDim2.fromOffset(200, 26)
	t.BorderSizePixel = 0
	t.GroupTransparency = 1
	t.LayoutOrder = toastOrder
	t.ZIndex = 200
	t.Parent = toastHolder
	bind(t, "BackgroundColor3", function()
		return Theme.Background
	end)
	corner(t, 4)
	local stroke = outline(t, 0.2)
	bind(stroke, "Color", function()
		return Theme.Accent
	end)

	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Font = FONT
	l.TextSize = 12
	l.RichText = true
	l.Text = richText
	l.ZIndex = 201
	l.Parent = t
	themeText(l)

	toastList[#toastList + 1] = t
	while #toastList > 5 do
		local old = table.remove(toastList, 1)
		pcall(function() old:Destroy() end)
	end

	tween(t, { GroupTransparency = 0 }, FADE_IN)
	task.delay(2.2, function()
		if t.Parent then
			tween(t, { GroupTransparency = 1 }, TweenInfo.new(0.3))
			task.delay(0.35, function()
				pcall(function() t:Destroy() end)
			end)
		end
	end)
end

notify = function(name, on)
	if not Settings.Notifications then return end
	local color = on and "rgb(90,200,120)" or "rgb(235,90,90)"
	toast(name .. "  <font color=\"" .. color .. "\">" .. (on and "ON" or "OFF") .. "</font>")
end

local blur = Lighting:FindFirstChild("OULMenuBlur") or Instance.new("BlurEffect")
blur.Name = "OULMenuBlur"
blur.Size = 0
blur.Parent = Lighting
local blurInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local menuOpen = false
local menuToken = 0
local prevMouseBehavior, prevMouseIcon

local function updateBlur()
	local target = (menuOpen and Settings.BlurEnabled) and Settings.BlurAmount or 0
	TweenService:Create(blur, blurInfo, { Size = target }):Play()
end

do
local modalBtn = Instance.new("TextButton")
modalBtn.Size = UDim2.fromOffset(0, 0)
modalBtn.BackgroundTransparency = 1
modalBtn.Text = ""
modalBtn.Modal = true
modalBtn.Parent = panel
end

local function setMenuVisible(visible)
	if visible and not menuOpen then
		prevMouseBehavior = UserInputService.MouseBehavior
		prevMouseIcon = UserInputService.MouseIconEnabled
	elseif not visible and menuOpen and prevMouseBehavior then

		UserInputService.MouseBehavior = prevMouseBehavior
		UserInputService.MouseIconEnabled = prevMouseIcon
		prevMouseBehavior = nil
	end
	menuOpen = visible
	menuToken += 1
	local token = menuToken

	if visible then
		panel.Visible = true
		tween(panel, { GroupTransparency = Settings.UITransparency / 100 }, FADE_IN)
	else
		tween(panel, { GroupTransparency = 1 }, FADE_OUT)
		task.delay(FADE_OUT.Time, function()
			if menuToken == token then
				panel.Visible = false
			end
		end)
	end
	updateBlur()
end

RunService:BindToRenderStep("OULMenuMouse", Enum.RenderPriority.Last.Value, function()
	if menuOpen then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end)

local refreshers = {}
local orders = setmetatable({}, { __mode = "k" })
local function nextOrder(parent)
	local n = (orders[parent] or 0) + 1
	orders[parent] = n
	return n
end

local pages = {}
local searchIndex = {}
local groupPage = setmetatable({}, { __mode = "k" })
local function reg(parent, text)
	local pg = groupPage[parent]
	if pg and text and text ~= "" then
		searchIndex[#searchIndex + 1] = { text = text, page = pg.name }
	end
end
local currentTab
local currentPage
local currentSub = { combat = "aimbot", visuals = "esp", movement = "fly", settings = "general" }
local pageState = {}
local updateSize

local function newPage(name, hasSubs)
	local frame = Instance.new("CanvasGroup")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromOffset(PAGE_X, PAGE_Y + (hasSubs and SUB_H or 0))
	frame.Size = UDim2.new(1, -(PAGE_X + 8), 0, 100)
	frame.GroupTransparency = 1
	frame.Visible = false
	frame.Parent = panel

	local cols = {}
	for i = 1, 2 do
		local col = Instance.new("Frame")
		col.BackgroundTransparency = 1
		col.Size = UDim2.new(0.5, -4, 0, 0)
		col.AutomaticSize = Enum.AutomaticSize.Y
		col.Position = UDim2.new((i - 1) * 0.5, (i - 1) * 4, 0, 0)
		col.Parent = frame
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = col
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if updateSize then updateSize(false) end
		end)
		cols[i] = { frame = col, layout = layout }
	end

	local page = { name = name, frame = frame, cols = cols, subOffset = hasSubs and SUB_H or 0 }
	pages[name] = page
	return page
end

local function newGroup(page, colIndex, titleText)
	local col = page.cols[colIndex].frame

	local g = Instance.new("Frame")
	g.Size = UDim2.new(1, 0, 0, 0)
	g.AutomaticSize = Enum.AutomaticSize.Y
	g.BorderSizePixel = 0
	g.LayoutOrder = nextOrder(col)
	g.Parent = col
	bind(g, "BackgroundColor3", function()
		return Theme.Group
	end)
	corner(g, 4)
	outline(g)

	local head = newLabel(g, titleText, 12)
	head.Size = UDim2.new(1, 0, 0, 20)
	head.TextXAlignment = Enum.TextXAlignment.Center
	pcall(function()
		head.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
	end)

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Position = UDim2.fromOffset(0, 20)
	line.BorderSizePixel = 0
	line.BackgroundTransparency = 0.4
	line.Parent = g
	bind(line, "BackgroundColor3", function()
		return Theme.Outline
	end)

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(0, 21)
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = g
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 7)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = content

	groupPage[content] = page
	return content
end

local function addNote(parent, text)
	local l = newLabel(parent, text, 11, true)
	l.Size = UDim2.new(1, 0, 0, 14)
	l.LayoutOrder = nextOrder(parent)
	return l
end

local function addCheckbox(parent, text, key, onChanged)
	reg(parent, text)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Text = ""
	row.AutoButtonColor = false
	row.LayoutOrder = nextOrder(parent)
	row.Parent = parent

	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(14, 14)
	box.AnchorPoint = Vector2.new(0, 0.5)
	box.Position = UDim2.new(0, 0, 0.5, 0)
	box.BorderSizePixel = 0
	box.Parent = row
	corner(box, 3)
	local stroke = outline(box, 0.2)

	local tick = Instance.new("Frame")
	tick.Size = UDim2.fromOffset(0, 0)
	tick.AnchorPoint = Vector2.new(0.5, 0.5)
	tick.Position = UDim2.new(0.5, 0, 0.5, 0)
	tick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tick.BorderSizePixel = 0
	tick.Parent = box
	corner(tick, 2)

	local label = newLabel(row, text, 12)
	label.Position = UDim2.fromOffset(22, 0)
	label.Size = UDim2.new(1, -22, 1, 0)

	local function refresh(animate)
		local on = Settings[key]
		apply(box, { BackgroundColor3 = on and Theme.Switch or Theme.Field }, animate)
		apply(tick, { Size = on and UDim2.fromOffset(6, 6) or UDim2.fromOffset(0, 0) }, animate)
	end

	row.MouseEnter:Connect(function()
		tween(stroke, { Transparency = 0 })
		tween(box, { BackgroundColor3 = Settings[key] and Theme.Switch or Theme.Field:Lerp(Theme.Text, 0.12) })
	end)
	row.MouseLeave:Connect(function()
		tween(stroke, { Transparency = 0.2 })
		refresh(true)
	end)
	refreshers[key] = refresh

	local function toggleSetting()
		if LockedSettings[key] then return end
		Settings[key] = not Settings[key]
		refresh(true)
		if onChanged then onChanged(Settings[key]) end
		if notify then notify(DisplayNames[key] or text, Settings[key]) end
	end
	toggles[key] = { toggle = toggleSetting }
	row.MouseButton1Click:Connect(toggleSetting)
	onTheme(function()
		refresh(true)
	end)
	refresh(false)
	return row
end

local function addSlider(parent, text, min, max, key, onChanged)
	reg(parent, text)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 20)
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true
	bar.LayoutOrder = nextOrder(parent)
	bar.Parent = parent
	bind(bar, "BackgroundColor3", function()
		return Theme.Field
	end)
	corner(bar, 3)
	outline(bar, 0.4)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundTransparency = 0.15
	fill.Parent = bar
	bind(fill, "BackgroundColor3", function()
		return Theme.Accent
	end)

	local label = newLabel(bar, "", 12)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.ZIndex = 3

	local function setValue(v)
		v = math.clamp(math.floor(v + 0.5), min, max)
		Settings[key] = v
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		label.Text = text .. ": " .. v
		if onChanged then onChanged(v) end
	end

	local dragging = false
	local function update(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		setValue(min + a * (max - min))
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			tween(fill, { BackgroundTransparency = 0 })
			update(input.Position.X)
		end
	end)
	bar.MouseEnter:Connect(function()
		tween(fill, { BackgroundTransparency = 0 })
	end)
	bar.MouseLeave:Connect(function()
		if not dragging then
			tween(fill, { BackgroundTransparency = 0.15 })
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input.Position.X)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
			dragging = false
			tween(fill, { BackgroundTransparency = 0.15 })
		end
	end))

	setValue(Settings[key])
	refreshers[key] = function() setValue(Settings[key]) end
	return bar
end

local function addSegment(parent, text, key, optA, optB, onChanged)
	reg(parent, text)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundTransparency = 1
	row.LayoutOrder = nextOrder(parent)
	row.Parent = parent

	local label = newLabel(row, text, 12)
	label.Size = UDim2.new(0, 64, 1, 0)

	local seg = Instance.new("Frame")
	seg.Size = UDim2.new(1, -68, 1, 0)
	seg.Position = UDim2.fromOffset(68, 0)
	seg.BorderSizePixel = 0
	seg.Parent = row
	bind(seg, "BackgroundColor3", function()
		return Theme.Field
	end)
	corner(seg, 3)
	outline(seg, 0.4)

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0.5, -4, 1, -4)
	pill.BorderSizePixel = 0
	pill.Parent = seg
	bind(pill, "BackgroundColor3", function()
		return Theme.Accent
	end)
	corner(pill, 2)

	local buttons = {}
	local function refresh(animate)
		local idx = (Settings[key] == optA) and 1 or 2
		local pos = UDim2.new((idx - 1) * 0.5, 2, 0, 2)
		if animate then
			tween(pill, { Position = pos }, SLIDE)
		else
			pill.Position = pos
		end
		for i, btn in ipairs(buttons) do
			apply(btn, {
				TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Theme.Dim,
			}, animate)
		end
	end

	for i, name in ipairs({ optA, optB }) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.5, 0, 1, 0)
		btn.Position = UDim2.new((i - 1) * 0.5, 0, 0, 0)
		btn.BackgroundTransparency = 1
		btn.Text = name
		btn.Font = FONT
		btn.TextSize = 12
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.ZIndex = 2
		btn.Parent = seg
		btn.MouseButton1Click:Connect(function()
			Settings[key] = name
			refresh(true)
			if onChanged then onChanged(name) end
		end)
		buttons[i] = btn
	end
	onTheme(function()
		refresh(true)
	end)
	refreshers[key] = refresh
	refresh(false)
	return row
end

local function addButton(parent, text, color, hoverColor, onClick)
	reg(parent, text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 22)
	btn.BorderSizePixel = 0
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.Font = FONT
	btn.TextSize = 12
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	btn.LayoutOrder = nextOrder(parent)
	btn.Parent = parent
	corner(btn, 3)

	btn.MouseEnter:Connect(function()
		tween(btn, { BackgroundColor3 = hoverColor })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, { BackgroundColor3 = color })
	end)
	btn.MouseButton1Click:Connect(onClick)
	return btn
end

local PALETTE = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(255, 160, 60),
	Color3.fromRGB(255, 205, 60),
	Color3.fromRGB(255, 230, 80),
	Color3.fromRGB(170, 230, 70),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(150, 240, 170),
	Color3.fromRGB(60, 200, 200),
	Color3.fromRGB(80, 220, 255),
	Color3.fromRGB(120, 180, 255),
	Color3.fromRGB(95, 140, 255),
	Color3.fromRGB(160, 100, 255),
	Color3.fromRGB(230, 90, 230),
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(170, 170, 185),
}

local BACKGROUNDS = {
	Color3.fromRGB(8, 9, 20),
	Color3.fromRGB(18, 18, 23),
	Color3.fromRGB(8, 8, 10),
	Color3.fromRGB(30, 30, 30),
	Color3.fromRGB(48, 48, 56),
	Color3.fromRGB(16, 24, 44),
	Color3.fromRGB(14, 30, 48),
	Color3.fromRGB(26, 32, 52),
	Color3.fromRGB(20, 40, 44),
	Color3.fromRGB(16, 36, 30),
	Color3.fromRGB(40, 26, 16),
	Color3.fromRGB(44, 20, 24),
	Color3.fromRGB(44, 16, 40),
	Color3.fromRGB(32, 20, 48),
	Color3.fromRGB(210, 216, 230),
	Color3.fromRGB(235, 238, 245),
}

local function paletteWith(default)
	for _, c in ipairs(PALETTE) do
		if c == default then
			return PALETTE
		end
	end
	local list = { default }
	for i = 1, #PALETTE - 1 do
		list[#list + 1] = PALETTE[i]
	end
	return list
end

local GRID_W = 8 * 18 + 7 * 5
local PAL_H = 60

local function addColor(parent, text, colors, onPick, default, hueS, hueV)
	reg(parent, text)
	hueS = hueS or 0.75
	hueV = hueV or 1

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.BackgroundTransparency = 1
	holder.LayoutOrder = nextOrder(parent)
	holder.Parent = parent
	local hl = Instance.new("UIListLayout")
	hl.Padding = UDim.new(0, 2)
	hl.SortOrder = Enum.SortOrder.LayoutOrder
	hl.Parent = holder

	local head = Instance.new("TextButton")
	head.Size = UDim2.new(1, 0, 0, 20)
	head.BackgroundTransparency = 1
	head.Text = ""
	head.AutoButtonColor = false
	head.LayoutOrder = 1
	head.Parent = holder

	local label = newLabel(head, text, 12)
	label.Size = UDim2.new(1, -36, 1, 0)

	local preview = Instance.new("Frame")
	preview.Size = UDim2.fromOffset(28, 12)
	preview.AnchorPoint = Vector2.new(1, 0.5)
	preview.Position = UDim2.new(1, 0, 0.5, 0)
	preview.BackgroundColor3 = default or colors[1]
	preview.BorderSizePixel = 0
	preview.Parent = head
	corner(preview, 3)
	local previewStroke = outline(preview, 0.2)

	head.MouseEnter:Connect(function()
		tween(previewStroke, { Transparency = 0 })
	end)
	head.MouseLeave:Connect(function()
		tween(previewStroke, { Transparency = 0.2 })
	end)

	local pal = Instance.new("Frame")
	pal.Size = UDim2.new(1, 0, 0, 0)
	pal.BackgroundTransparency = 1
	pal.ClipsDescendants = true
	pal.LayoutOrder = 2
	pal.Parent = holder

	local grid = Instance.new("Frame")
	grid.Size = UDim2.fromOffset(GRID_W, 41)
	grid.Position = UDim2.fromOffset(0, 2)
	grid.BackgroundTransparency = 1
	grid.Parent = pal
	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.fromOffset(18, 18)
	gl.CellPadding = UDim2.fromOffset(5, 5)
	gl.FillDirectionMaxCells = 8
	gl.SortOrder = Enum.SortOrder.LayoutOrder
	gl.Parent = grid

	local marker
	local marks = {}
	local function selectSwatch(index, animate)
		for j, st in ipairs(marks) do
			local t = (j == index) and 0 or 1
			if animate then
				tween(st, { Transparency = t })
			else
				st.Transparency = t
			end
		end
	end

	local function setPreview(color)
		tween(preview, { BackgroundColor3 = color })
	end

	for i, color in ipairs(colors) do
		local sw = Instance.new("TextButton")
		sw.BackgroundColor3 = color
		sw.BorderSizePixel = 0
		sw.Text = ""
		sw.AutoButtonColor = false
		sw.LayoutOrder = i
		sw.Parent = grid
		corner(sw, 3)
		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Color = Color3.fromRGB(255, 255, 255)
		st.Thickness = 2
		st.Transparency = 1
		st.Parent = sw
		marks[i] = st
		sw.MouseButton1Click:Connect(function()
			selectSwatch(i, true)
			if marker then marker.Visible = false end
			setPreview(color)
			onPick(color)
		end)
	end

	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromOffset(GRID_W, 8)
	bar.Position = UDim2.fromOffset(0, 50)
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.BorderSizePixel = 0
	bar.Parent = pal
	corner(bar, 3)

	local keys = {}
	for i = 0, 6 do
		keys[#keys + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, hueS, hueV))
	end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(keys)
	gradient.Parent = bar

	marker = Instance.new("Frame")
	marker.Size = UDim2.fromOffset(4, 12)
	marker.AnchorPoint = Vector2.new(0.5, 0.5)
	marker.Position = UDim2.new(0, 0, 0.5, 0)
	marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	marker.BorderSizePixel = 0
	marker.Visible = false
	marker.Parent = bar
	corner(marker, 2)
	local markerStroke = Instance.new("UIStroke")
	markerStroke.Color = Color3.fromRGB(20, 20, 28)
	markerStroke.Thickness = 1
	markerStroke.Transparency = 0.2
	markerStroke.Parent = marker

	local function pickHue(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local color = Color3.fromHSV(math.min(a, 0.999), hueS, hueV)
		marker.Visible = true
		marker.Position = UDim2.new(a, 0, 0.5, 0)
		selectSwatch(nil, true)
		preview.BackgroundColor3 = color
		onPick(color)
	end

	local dragging = false
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			pickHue(input.Position.X)
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			pickHue(input.Position.X)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))

	local open = false
	head.MouseButton1Click:Connect(function()
		open = not open
		tween(pal, { Size = UDim2.new(1, 0, 0, open and PAL_H or 0) }, SLIDE)
	end)

	for i, color in ipairs(colors) do
		if color == default then
			selectSwatch(i, false)
		end
	end

	local getCurrent = ConfigAPI.colorGetters[text]
	if getCurrent then
		table.insert(ConfigAPI.colorRefreshers, function()
			local c = getCurrent()
			preview.BackgroundColor3 = c
			marker.Visible = false
			local found
			for i, color in ipairs(colors) do
				if color == c then found = i end
			end
			selectSwatch(found, false)
		end)
	end
	return holder
end

local tabButtons = {}
local tabIndex = {}
local subButtons = {}
local subIndex = {}
local subPos = {}
local subBars = {}

local function pageKey(tab, sub)
	return sub and (tab .. "_" .. sub) or tab
end

local function refreshTabs(animate)
	for name, btn in pairs(tabButtons) do
		apply(btn, { TextColor3 = (name == currentTab) and Theme.Text or Theme.Dim }, animate)
	end
	for tabId, group in pairs(subButtons) do
		for subId, btn in pairs(group) do
			local on = (tabId == currentTab and currentSub[tabId] == subId)
			apply(btn, { TextColor3 = on and Theme.Text or Theme.Dim }, animate)
		end
	end
end

local function pageHeight(p)
	local h = 0
	for _, c in ipairs(p.cols) do
		h = math.max(h, c.layout.AbsoluteContentSize.Y)
	end
	return h
end

updateSize = function(animate)
	for _, p in pairs(pages) do
		p.frame.Size = UDim2.new(1, -(PAGE_X + 8), 0, pageHeight(p))
	end
	if not currentPage or not pages[currentPage] then return end
	local cur = pages[currentPage]

	local pageH = math.max(pageHeight(cur) + cur.subOffset, #TAB_NAMES * TAB_ROW + 8)
	local target = UDim2.fromOffset(PANEL_W, PAGE_Y + pageH + FOOTER_H + 8)
	if animate then
		tween(panel, { Size = target }, SLIDE)
	else
		panel.Size = target
	end
end

local function selectPage(tabId, subId, instant)
	currentTab = tabId
	if subId then
		currentSub[tabId] = subId
	else
		subId = currentSub[tabId]
	end
	local key = pageKey(tabId, subId)
	currentPage = key

	for n, p in pairs(pages) do
		local on = (n == key)
		pageState[p] = on
		if on then
			p.frame.Visible = true
			if instant then
				p.frame.GroupTransparency = 0
			else
				tween(p.frame, { GroupTransparency = 0 }, FADE_IN)
			end
		elseif instant then
			p.frame.GroupTransparency = 1
			p.frame.Visible = false
		else
			tween(p.frame, { GroupTransparency = 1 }, FADE_OUT)
			task.delay(FADE_OUT.Time, function()
				if not pageState[p] then
					p.frame.Visible = false
				end
			end)
		end
	end

	local idx = tabIndex[tabId]
	local pos = UDim2.fromOffset(0, 8 + (idx - 1) * TAB_ROW + 3)
	if instant then
		underline.Position = pos
	else
		tween(underline, { Position = pos }, SLIDE)
	end

	for id, bar in pairs(subBars) do
		bar.frame.Visible = (id == tabId)
	end
	local bar = subBars[tabId]
	if bar and subPos[tabId][subId] then
		local sp = subPos[tabId][subId]
		local lpos = UDim2.fromOffset(sp.x + 6, SUB_H - 8)
		local lsize = UDim2.fromOffset(sp.w - 12, 2)
		if instant then
			bar.line.Position = lpos
			bar.line.Size = lsize
		else
			tween(bar.line, { Position = lpos, Size = lsize }, SLIDE)
		end
	end

	refreshTabs(not instant)
	updateSize(not instant)
end

for i, name in ipairs(TAB_NAMES) do
	tabIndex[name] = i
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, TAB_ROW - 2)
	btn.Position = UDim2.fromOffset(0, 8 + (i - 1) * TAB_ROW)
	btn.BackgroundTransparency = 1
	btn.Text = TAB_LABELS[name]
	btn.Font = FONT
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	btn.Parent = tabBar
	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingLeft = UDim.new(0, 14)
	tabPad.Parent = btn
	tabButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		if currentTab ~= name then
			selectPage(name, nil, false)
		end
	end)
	btn.MouseEnter:Connect(function()
		if currentTab ~= name then
			tween(btn, { TextColor3 = Theme.Text })
		end
	end)
	btn.MouseLeave:Connect(function()
		if currentTab ~= name then
			tween(btn, { TextColor3 = Theme.Dim })
		end
	end)
end

for tabId, subs in pairs(SUBTABS) do
	local subW = math.min(SUB_W, math.floor((PANEL_W - PAGE_X - 8) / #subs))
	local bar = Instance.new("Frame")
	bar.BackgroundTransparency = 1
	bar.Size = UDim2.new(1, -(PAGE_X + 8), 0, SUB_H - 4)
	bar.Position = UDim2.fromOffset(PAGE_X, PAGE_Y - 4)
	bar.Visible = false
	bar.Parent = panel

	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, 0, 0, 1)
	sep.Position = UDim2.fromOffset(0, SUB_H - 6)
	sep.BorderSizePixel = 0
	sep.BackgroundTransparency = 0.4
	sep.Parent = bar
	bind(sep, "BackgroundColor3", function()
		return Theme.Outline
	end)

	local line = Instance.new("Frame")
	line.Size = UDim2.fromOffset(subW - 12, 2)
	line.Position = UDim2.fromOffset(6, SUB_H - 8)
	line.BorderSizePixel = 0
	line.ZIndex = 3
	line.Parent = bar
	bind(line, "BackgroundColor3", function()
		return Theme.Accent
	end)

	subButtons[tabId] = {}
	subIndex[tabId] = {}
	subPos[tabId] = {}
	local x = 0
	for i, sub in ipairs(subs) do
		subIndex[tabId][sub.id] = i
		subPos[tabId][sub.id] = { x = x, w = subW }
		local sb = Instance.new("TextButton")
		sb.Size = UDim2.fromOffset(subW, SUB_H - 8)
		sb.Position = UDim2.fromOffset(x, 0)
		sb.BackgroundTransparency = 1
		sb.Text = sub.label
		sb.Font = FONT
		sb.TextSize = 12
		sb.AutoButtonColor = false
		sb.Parent = bar
		subButtons[tabId][sub.id] = sb
		sb.MouseButton1Click:Connect(function()
			if not (currentTab == tabId and currentSub[tabId] == sub.id) then
				selectPage(tabId, sub.id, false)
			end
		end)
		sb.MouseEnter:Connect(function()
			if not (currentTab == tabId and currentSub[tabId] == sub.id) then
				tween(sb, { TextColor3 = Theme.Text })
			end
		end)
		sb.MouseLeave:Connect(function()
			if not (currentTab == tabId and currentSub[tabId] == sub.id) then
				tween(sb, { TextColor3 = Theme.Dim })
			end
		end)

		x = x + subW
	end
	subBars[tabId] = { frame = bar, line = line }
end

onTheme(function()
	refreshTabs(true)
end)

do
	local aimPage = newPage("combat_aimbot", true)
	local g = newGroup(aimPage, 1, "Aimbot")
	addCheckbox(g, "Enabled", "Enabled")
	addCheckbox(g, "Ignore FOV", "IgnoreFOV")
	addCheckbox(g, "Team Check", "TeamCheck")
	addCheckbox(g, "Target Zombies/NPCS", "TargetNPCs")
	addSlider(g, "FOV", 20, 500, "FOV", function(v)
		circle.Size = UDim2.fromOffset(v * 2, v * 2)
	end)
	addSlider(g, "Strength", 1, 500, "Strength")
	addCheckbox(g, "Prediction", "Prediction")
	addSlider(g, "Prediction (ms)", 0, 500, "PredictionMs")
	addSegment(g, "Target", "AimPart", "Head", "Body")
	addSegment(g, "Key mode", "AimMode", "Hold", "Toggle", function()
		Settings.Holding = false
		updateKeyHints()
	end)

	local v = newGroup(aimPage, 2, "FOV Circle")
	addCheckbox(v, "Show FOV", "ShowFOV")
	addColor(v, "FOV Color", paletteWith(FOVColor), function(color)
		circleStroke.Color = color
		FOVColor = color
	end, FOVColor)

	local info = newGroup(aimPage, 2, "Info")
	addHint(addNote(info, ""), function()
		local k = string.lower(keyName(getBind("aim").input))
		if Settings.AimMode == "Toggle" then
			return "press " .. k .. " to toggle aim"
		end
		return "hold " .. k .. " to aim"
	end)
	addNote(info, "range: 1000 studs")
	addNote(info, "needs mouse lock")
	addNote(info, "strength: 1 = soft pull,")
	addNote(info, "500 = straight lock")
	addNote(info, "prediction leads moving")
	addNote(info, "targets by their speed")
	addButton(info, "Print team info", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
		if printTeamInfo then printTeamInfo() end
	end)
end

do
	local trigPage = newPage("combat_trigger", true)
	local t = newGroup(trigPage, 1, "Triggerbot")
	addCheckbox(t, "Enabled", "Triggerbot")
	addSlider(t, "Delay (ms)", 0, 300, "TriggerDelay")
	addCheckbox(t, "Left click only", "TriggerOnClick")

	local info = newGroup(trigPage, 2, "Info")
	addHint(addNote(info, ""), function()
		return keyName(getBind("Triggerbot").input) .. "  -  triggerbot on / off"
	end)
	addNote(info, "uses Team Check")
	addNote(info, "(set in the Aimbot tab)")
	addNote(info, "range: 1000 studs")
	addNote(info, "needs mouse lock")
end

local function addPlaceholderPage(pageName, boxTitle)
	local page = newPage(pageName, true)
	local g = newGroup(page, 1, boxTitle)
	local devLabel = addNote(g, "In Development")
	devLabel.TextSize = 12
	devLabel.TextXAlignment = Enum.TextXAlignment.Center
	bind(devLabel, "TextColor3", function()
		return Theme.Accent
	end)
	return page
end

addPlaceholderPage("combat_silent", "Silent Aim")

addPlaceholderPage("combat_antikatana", "Antikatana")

do
	local ragePage = newPage("combat_ragebot", true)
	local g = newGroup(ragePage, 1, "Ragebot")
	addCheckbox(g, "Rage", "Ragebot")
	addSegment(g, "Mode", "RageMode", "Closest", "Selected")

	local rageModes = { "RageBehind", "RageAbove", "RageBelow" }
	local function modeChanged(key)
		return function(on)
			if not on then return end
			for _, k in ipairs(rageModes) do
				if k ~= key then
					Settings[k] = false
					if refreshers[k] then refreshers[k](true) end
				end
			end
		end
	end
	addCheckbox(g, "Behind", "RageBehind", modeChanged("RageBehind"))
	addCheckbox(g, "Above", "RageAbove", modeChanged("RageAbove"))
	addCheckbox(g, "Below", "RageBelow", modeChanged("RageBelow"))
	addSlider(g, "Distance", 2, 20, "RageDistance")
	addCheckbox(g, "Orbit", "RageOrbit")
	addSlider(g, "Orbit Speed", 1, 30, "OrbitSpeed")

	local sel = newGroup(ragePage, 2, "Selected Target")

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 22)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.PlaceholderText = "username..."
	box.Text = Settings.RageTarget
	box.Font = FONT
	box.TextSize = 12
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.LayoutOrder = nextOrder(sel)
	box.Parent = sel
	bind(box, "BackgroundColor3", function() return Theme.Field end)
	bind(box, "TextColor3", function() return Theme.Text end)
	bind(box, "PlaceholderColor3", function() return Theme.Dim end)
	corner(box, 3)
	outline(box, 0.4)
	do
		local bp = Instance.new("UIPadding")
		bp.PaddingLeft = UDim.new(0, 6)
		bp.Parent = box
	end

	local plist = Instance.new("ScrollingFrame")
	plist.Size = UDim2.new(1, 0, 0, 96)
	plist.BorderSizePixel = 0
	plist.ScrollBarThickness = 3
	plist.CanvasSize = UDim2.new()
	plist.AutomaticCanvasSize = Enum.AutomaticSize.Y
	plist.LayoutOrder = nextOrder(sel)
	plist.Parent = sel
	bind(plist, "BackgroundColor3", function() return Theme.Field end)
	corner(plist, 3)
	outline(plist, 0.4)
	do
		local ll = Instance.new("UIListLayout")
		ll.Padding = UDim.new(0, 2)
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Parent = plist
		local lp = Instance.new("UIPadding")
		lp.PaddingTop = UDim.new(0, 3)
		lp.PaddingLeft = UDim.new(0, 3)
		lp.PaddingRight = UDim.new(0, 3)
		lp.Parent = plist
	end

	local lastSig
	local function rebuildPlayers()
		local names = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then names[#names + 1] = plr.Name end
		end
		table.sort(names, function(a, b) return a:lower() < b:lower() end)

		local q = string.lower(Settings.RageTarget or "")
		local sig = table.concat(names, "|") .. "#" .. q
		if sig == lastSig then return end
		lastSig = sig

		for _, c in ipairs(plist:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for i, name in ipairs(names) do
			local on = (q ~= "" and string.lower(name) == q)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -6, 0, 20)
			b.BorderSizePixel = 0
			b.AutoButtonColor = false
			b.Font = FONT
			b.TextSize = 12
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.LayoutOrder = i
			b.Text = "  " .. name
			b.BackgroundTransparency = on and 0 or 1
			b.BackgroundColor3 = Theme.Accent
			b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Theme.Text
			b.Parent = plist
			corner(b, 3)
			b.MouseButton1Click:Connect(function()
				Settings.RageTarget = name
				box.Text = name
				lastSig = nil
				rebuildPlayers()
			end)
		end
	end

	box.FocusLost:Connect(function()
		Settings.RageTarget = string.gsub(box.Text, "^%s+", ""):gsub("%s+$", ""):sub(1, 24)
		lastSig = nil
		rebuildPlayers()
	end)
	refreshers.RageTarget = function()
		box.Text = Settings.RageTarget
		lastSig = nil
		rebuildPlayers()
	end
	onTheme(function() lastSig = nil rebuildPlayers() end)
	track(Players.PlayerAdded:Connect(function() task.defer(rebuildPlayers) end))
	track(Players.PlayerRemoving:Connect(function() task.defer(rebuildPlayers) end))
	rebuildPlayers()

	local info = newGroup(ragePage, 2, "Info")
	rageStatus = addNote(info, "Target: none")
	addHint(addNote(info, ""), function()
		return keyName(getBind("Ragebot").input) .. "  -  rage on / off"
	end)
	addNote(info, "Closest: sticks you to the")
	addNote(info, "nearest player until they die")
	addNote(info, "Selected: sticks to the name")
	addNote(info, "picked above (ignores teams)")
	addNote(info, "behind, above or below")
	addNote(info, "orbit: spin around them")
	addNote(info, "(distance = orbit radius)")
	addNote(info, "uses Team Check")
end

do
	local espPage = newPage("visuals_esp", true)
	local g = newGroup(espPage, 1, "ESP")
	addCheckbox(g, "Enabled", "ESP", function()
		setESPEnabled()
	end)
	addCheckbox(g, "Chams", "Chams", function()
		setESPEnabled()
	end)
	addCheckbox(g, "Show Usernames", "ShowNames", function()
		setESPEnabled()
	end)
	addCheckbox(g, "Tracers", "Tracers")
	addCheckbox(g, "Boxes", "Boxes")
	addCheckbox(g, "Box Fill", "BoxFill")
	addCheckbox(g, "Skeleton", "Skeleton")
	addCheckbox(g, "Health", "ESPHealth")
	addCheckbox(g, "Zombie/NPC ESP", "ESPNPCs")

	local info = newGroup(espPage, 2, "Info")
	addNote(info, "chams show through walls")
	addNote(info, "everything needs ESP on")
	addNote(info, "boxes: outline + optional")
	addNote(info, "see-through fill")
	addNote(info, "skeleton: bone lines")
	addNote(info, "health: bar beside player")
	addNote(info, "colours are in Colours")
end

do
	local colPage = newPage("visuals_colours", true)
	local c1 = newGroup(colPage, 1, "Chams")
	addColor(c1, "Cham Fill", paletteWith(ESPColors.Fill), setChamColor, ESPColors.Fill)
	addColor(c1, "Cham Outline", paletteWith(ESPColors.Outline), setChamOutlineColor, ESPColors.Outline)

	local cb = newGroup(colPage, 1, "Boxes")
	addColor(cb, "Box", paletteWith(ESPColors.Box), setBoxColor, ESPColors.Box)
	addColor(cb, "Box Fill", paletteWith(ESPColors.BoxFill), setBoxFillColor, ESPColors.BoxFill)

	local c2 = newGroup(colPage, 2, "Text & Lines")
	addColor(c2, "Tracers", paletteWith(ESPColors.Tracer), setTracerColor, ESPColors.Tracer)
	addColor(c2, "Usernames", paletteWith(ESPColors.Name), setNameColor, ESPColors.Name)
	addColor(c2, "Skeleton", paletteWith(ESPColors.Skeleton), function(color)
		ESPColors.Skeleton = color
	end, ESPColors.Skeleton)
end

do
	local radarPage = newPage("visuals_radar", true)
	local g = newGroup(radarPage, 1, "Radar")
	addCheckbox(g, "Enabled", "Radar", function(on)
		if on and toast then toast("Radar  -  " .. tostring(ConfigAPI.radarMode) .. " mode") end
	end)
	addSlider(g, "Range (studs)", 50, 1000, "RadarRange")
	addSlider(g, "Size", 100, 300, "RadarSize")
	addSlider(g, "Dot Size", 4, 14, "RadarDotSize")
	addSlider(g, "Line Thickness", 1, 4, "RadarLineThickness")

	local pos = newGroup(radarPage, 1, "Position")
	do
		local grid = Instance.new("Frame")
		grid.Size = UDim2.new(1, 0, 0, 106)
		grid.BackgroundTransparency = 1
		grid.LayoutOrder = nextOrder(pos)
		grid.Parent = pos
		local gl = Instance.new("UIGridLayout")
		gl.CellSize = UDim2.new(0.5, -3, 0, 30)
		gl.CellPadding = UDim2.fromOffset(6, 6)
		gl.SortOrder = Enum.SortOrder.LayoutOrder
		gl.Parent = grid

		local buttons = {}
		local corners = {
			{ id = "TopLeft", label = "Top Left", order = 1 },
			{ id = "TopRight", label = "Top Right", order = 2 },
			{ id = "BottomLeft", label = "Bottom Left", order = 3 },
			{ id = "BottomRight", label = "Bottom Right", order = 4 },
			{ id = "Custom", label = "Custom (drag)", order = 5 },
		}
		local function refresh(animate)
			for id, btn in pairs(buttons) do
				apply(btn, {
					BackgroundTransparency = (Settings.RadarCorner == id) and 0 or 1,
					TextColor3 = (Settings.RadarCorner == id) and Color3.fromRGB(255, 255, 255) or Theme.Dim,
				}, animate)
			end
		end
		for _, c in ipairs(corners) do
			local btn = Instance.new("TextButton")
			btn.LayoutOrder = c.order
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Font = FONT
			btn.TextSize = 12
			btn.Text = c.label
			btn.Parent = grid
			bind(btn, "BackgroundColor3", function() return Theme.Accent end)
			corner(btn, 3)
			outline(btn, 0.4)
			buttons[c.id] = btn
			btn.MouseButton1Click:Connect(function()
				Settings.RadarCorner = c.id
				refresh(true)
			end)
		end
		onTheme(function() refresh(true) end)
		refreshers.RadarCorner = refresh
		refresh(false)
	end
	addNote(pos, "Custom: open the menu, then")
	addNote(pos, "left click + drag the radar")

	local colg = newGroup(radarPage, 2, "Colours")
	addColor(colg, "Radar", paletteWith(ESPColors.Radar), function(color)
		ESPColors.Radar = color
	end, ESPColors.Radar)
	addColor(colg, "Radar Lines", paletteWith(ESPColors.RadarLines), function(color)
		ESPColors.RadarLines = color
	end, ESPColors.RadarLines)

	local info = newGroup(radarPage, 2, "Info")
	addNote(info, "rings + crosshair only,")
	addNote(info, "no background: stays out")
	addNote(info, "of the way of your screen")
	addNote(info, "dots = other players")
	addNote(info, "range = edge of the rings")
	addHint(addNote(info, ""), function()
		return "mode: " .. tostring(ConfigAPI.radarMode)
	end)
end

do
	local skyPage = newPage("visuals_sky", true)
	local g = newGroup(skyPage, 1, "Skybox")
	addCheckbox(g, "Enabled", "Skybox")
	addCheckbox(g, "Rainbow", "SkyRainbow")
	addColor(g, "Sky Colour", paletteWith(ESPColors.Sky), function(color)
		ESPColors.Sky = color
	end, ESPColors.Sky)

	local info = newGroup(skyPage, 2, "Info")
	addNote(info, "recolours the whole sky")
	addNote(info, "hides the game's own sky")
	addNote(info, "and haze (put back when off)")
	addNote(info, "rainbow cycles colours")
	addNote(info, "needs writefile support")
end

do
	local worldPage = newPage("visuals_world", true)
	local g = newGroup(worldPage, 1, "World")
	addCheckbox(g, "Fullbright", "Fullbright", function()
		applyWorldLighting()
	end)
	addCheckbox(g, "No Fog", "NoFog", function()
		applyWorldLighting()
	end)

	local info = newGroup(worldPage, 2, "Info")
	addNote(info, "fullbright: max brightness,")
	addNote(info, "no shadows, flat lighting")
	addNote(info, "no fog: removes distance fog")
	addNote(info, "and atmosphere haze")
	addNote(info, "original lighting restored")
	addNote(info, "when turned off / unloaded")
end

do
	local flyPage = newPage("movement_fly", true)
	local g = newGroup(flyPage, 1, "Fly")
	addCheckbox(g, "Enabled", "Fly")
	addSlider(g, "Speed", 5, 1000, "FlySpeed")

	local k = newGroup(flyPage, 2, "Controls")
	addNote(k, "W A S D  -  move")
	addNote(k, "Space  -  up")
	addNote(k, "Ctrl  -  down")
	addHint(addNote(k, ""), function()
		return keyName(getBind("Fly").input) .. "  -  fly on / off"
	end)
end

do
	local vortexPage = newPage("movement_vortex", true)
	local w = newGroup(vortexPage, 2, "WARNING")
	for _, line in ipairs({
		"BUGGY / EXPERIMENTAL",
		"can glitch your movement",
		"or camera. If it breaks,",
		"turn it off or reset your",
		"character. Use at your",
		"own risk.",
	}) do
		local n = addNote(w, line)
		bind(n, "TextColor3", function() return Color3.fromRGB(235, 90, 90) end)
	end

	local g = newGroup(vortexPage, 1, "Vortex")
	addCheckbox(g, "Vortex Mode", "FlyVortex", function(on)
		if on and toast then toast("Vortex is buggy - see the warning") end
	end)
	addSlider(g, "Vortex Speed", 1, 100, "VortexSpeed")
	addSlider(g, "Vortex Radius", 2, 60, "VortexRadius")

	local st = newGroup(vortexPage, 2, "Status")
	vortexStatus = addNote(st, "Vortex: off")
	vortexServerLabel = addNote(st, "Server: checking...")
	addNote(st, "your body parts orbit you")
	addNote(st, "works with or without fly")
	addNote(st, "orbit head: only safe if the")
	addNote(st, "server has RequiresNeck off")
	addNote(st, "executor mode: joints are")
	addNote(st, "destroyed so it replicates")

	if VORTEX_DISABLED then

		local shade = Instance.new("TextButton")
		shade.Name = "DisabledShade"
		shade.Size = UDim2.new(1, 0, 1, 0)
		shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		shade.BackgroundTransparency = 0.45
		shade.BorderSizePixel = 0
		shade.Text = ""
		shade.AutoButtonColor = false
		shade.Active = true
		shade.ZIndex = 50
		shade.Parent = vortexPage.frame
		corner(shade, 4)

		local tag = Instance.new("TextLabel")
		tag.Name = "DisabledLabel"
		tag.AnchorPoint = Vector2.new(0.5, 0.5)
		tag.Position = UDim2.new(0.5, 0, 0.5, 0)
		tag.Size = UDim2.new(1, 0, 0, 24)
		tag.BackgroundTransparency = 1
		tag.Text = "Disabled"
		tag.Font = FONT
		tag.TextSize = 18
		tag.TextColor3 = Color3.fromRGB(235, 80, 80)
		tag.ZIndex = 51
		tag.Parent = vortexPage.frame
		pcall(function()
			tag.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
		end)
	end
end

do
	local speedPage = newPage("movement_speed", true)
	local g = newGroup(speedPage, 1, "Speed")
	addCheckbox(g, "Enabled", "Speed")
	addSlider(g, "Walk Speed", 16, 250, "SpeedValue")

	local info = newGroup(speedPage, 2, "Info")
	addNote(info, "changes your walk speed")
	addNote(info, "normal speed comes back")
	addNote(info, "when you switch it off")
end

do
	local jumpPage = newPage("movement_jump", true)
	local g = newGroup(jumpPage, 1, "Infinite Jump")
	addCheckbox(g, "Enabled", "InfiniteJump")

	local info = newGroup(jumpPage, 2, "Info")
	addNote(info, "jump again in mid-air")
	addNote(info, "just press jump")
end

do
	local tpPage = newPage("movement_mousetp", true)
	local g = newGroup(tpPage, 1, "Mouse TP")
	addCheckbox(g, "Enabled", "MouseTP")

	local info = newGroup(tpPage, 2, "Info")
	addHint(addNote(info, ""), function()
		return keyName(getBind("MouseTPKey").input) .. "  -  teleport"
	end)
	addNote(info, "teleports you to where")
	addNote(info, "your mouse / crosshair")
	addNote(info, "is pointing")
	addNote(info, "change the key in Keybinds")
end

do
	local noclipPage = newPage("movement_noclip", true)
	local g = newGroup(noclipPage, 1, "Noclip")
	addCheckbox(g, "Enabled", "Noclip")

	local info = newGroup(noclipPage, 2, "Info")
	addNote(info, "walk through walls")
	addHint(addNote(info, ""), function()
		return keyName(getBind("Noclip").input) .. "  -  noclip on / off"
	end)
	addNote(info, "combine with fly to")
	addNote(info, "move through anything")
end

do
	local settingsPage = newPage("settings_general", true)
	local m = newGroup(settingsPage, 1, "Menu")
	addSlider(m, "UI Transparency", 0, 70, "UITransparency", function(v)
		if menuOpen then
			panel.GroupTransparency = v / 100
		end
	end)
	addCheckbox(m, "Watermark", "Watermark", function(on)
		hud.Visible = on
	end)
	addCheckbox(m, "Keybind List", "KeybindList", function(on)
		keyList.Visible = on
	end)
	addCheckbox(m, "Notifications", "Notifications")
	addCheckbox(m, "Background Blur", "BlurEnabled", function()
		updateBlur()
	end)
	addSlider(m, "Blur Amount", 1, 56, "BlurAmount", function()
		updateBlur()
	end)

	local u = newGroup(settingsPage, 1, "Script")
	addButton(u, "Unload", Color3.fromRGB(170, 55, 65), Color3.fromRGB(205, 75, 85), function()
		local fn = shared.OULCleanup
		shared.OULCleanup = nil
		if fn then fn() end
	end)

	addButton(u, "Save now", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
		saveNowFn()
	end)
	saveStatusLabel = addNote(u, saveStatusText)

	local switchDefault = Theme.Switch
	local accentDefault = Theme.Accent
	local textDefault = Theme.Text
	local outlineDefault = Theme.Outline

	local c = newGroup(settingsPage, 2, "Menu Colours")
	addColor(c, "Checkbox", paletteWith(switchDefault), function(color)
		Theme.Switch = color
		applyTheme()
	end, switchDefault)
	addColor(c, "Accent", paletteWith(accentDefault), function(color)
		Theme.Accent = color
		applyTheme()
	end, accentDefault)
	addColor(c, "Text", paletteWith(textDefault), function(color)
		Theme.Text = color
		applyTheme()
	end, textDefault)
	addColor(c, "Background", BACKGROUNDS, function(color)
		Theme.Background = color
		applyTheme()
	end, Theme.Background, 0.55, 0.28)
	addColor(c, "Outline", paletteWith(outlineDefault), function(color)
		Theme.Outline = color
		applyTheme()
	end, outlineDefault, 0.45, 0.6)
end

do
	local keyPage = newPage("settings_keybinds", true)
	local function addKeybindRow(parent, id)
		local b = getBind(id)
		reg(parent, b.label)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundTransparency = 1
		row.LayoutOrder = nextOrder(parent)
		row.Parent = parent

		local label = newLabel(row, b.label, 12)
		label.Size = UDim2.new(1, -92, 1, 0)

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(88, 20)
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, 0, 0.5, 0)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Font = FONT
		btn.TextSize = 11
		btn.Text = keyName(b.input)
		btn.Parent = row
		bind(btn, "BackgroundColor3", function()
			return Theme.Field
		end)
		bind(btn, "TextColor3", function()
			return Theme.Text
		end)
		corner(btn, 3)
		outline(btn, 0.4)
		bindButtons[id] = btn

		btn.MouseButton1Click:Connect(function()
			rebinding = (rebinding == b) and nil or b
			refreshBindUI()
		end)
	end

	local c = newGroup(keyPage, 1, "Combat")
	for _, id in ipairs({ "aim", "Enabled", "ShowFOV", "IgnoreFOV", "TeamCheck", "Triggerbot", "Ragebot" }) do
		addKeybindRow(c, id)
	end

	local mv = newGroup(keyPage, 1, "Movement")
	for _, id in ipairs({ "Fly", "Noclip", "Speed", "InfiniteJump", "MouseTPKey" }) do
		addKeybindRow(mv, id)
	end

	local v = newGroup(keyPage, 2, "Visuals")
	for _, id in ipairs({ "ESP", "Chams", "ShowNames", "Tracers", "Boxes", "BoxFill", "Skeleton", "Skybox" }) do
		addKeybindRow(v, id)
	end

	local m = newGroup(keyPage, 2, "Menu")
	for _, id in ipairs({ "menu", "panic", "Watermark", "KeybindList", "BlurEnabled", "Notifications" }) do
		addKeybindRow(m, id)
	end
	addNote(m, "click a key, then press a new one")
	addNote(m, "Esc  -  cancel    Backspace  -  clear")
	addNote(m, "Panic  -  unloads everything")
	addButton(m, "Reset all keybinds", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
		for _, b in ipairs(Binds) do
			b.input = b.default
		end
		rebinding = nil
		refreshBindUI()
		updateKeyHints()
		toast("Keybinds reset")
	end)
end

do
	local cfgPage = newPage("settings_configs", true)
	local g = newGroup(cfgPage, 1, "Configs")

	if not ConfigAPI.available then
		addNote(g, "needs executor file support")
		addNote(g, "(listfiles, delfile,")
		addNote(g, "isfolder, makefolder)")
	else
		local BLUE, BLUE_H = Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170)
		local RED, RED_H = Color3.fromRGB(170, 55, 65), Color3.fromRGB(205, 75, 85)

		local function reloadUI()
			for _, fn in pairs(refreshers) do pcall(fn, true) end
			setChamColor(ESPColors.Fill)
			setChamOutlineColor(ESPColors.Outline)
			setNameColor(ESPColors.Name)
			circleStroke.Color = FOVColor
			applyTheme()
			for _, fn in ipairs(ConfigAPI.colorRefreshers) do pcall(fn) end
			hud.Visible = Settings.Watermark
			keyList.Visible = Settings.KeybindList
			if Positions.hud then hud.Position = Positions.hud end
			if Positions.keylist then keyList.Position = Positions.keylist end
			refreshBindUI()
			updateKeyHints()
			setESPEnabled()
		end

		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, 0, 0, 120)
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 3
		list.CanvasSize = UDim2.new()
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.LayoutOrder = nextOrder(g)
		list.Parent = g
		bind(list, "BackgroundColor3", function() return Theme.Field end)
		corner(list, 3)
		outline(list, 0.4)
		local ll = Instance.new("UIListLayout")
		ll.Padding = UDim.new(0, 2)
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Parent = list
		local lp = Instance.new("UIPadding")
		lp.PaddingTop = UDim.new(0, 3)
		lp.PaddingLeft = UDim.new(0, 3)
		lp.PaddingRight = UDim.new(0, 3)
		lp.Parent = list

		local autoNote = addNote(g, "autoload: none")

		local selected, autoBtn, delBtn, pendingDelete = nil, nil, nil, false

		local function rebuild()
			for _, c in ipairs(list:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			local names = ConfigAPI.list()
			local auto = ConfigAPI.getAutoload()

			local found = false
			for _, n in ipairs(names) do
				if n == selected then found = true end
			end
			if not found then selected = nil end

			for i, name in ipairs(names) do
				local on = (name == selected)
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, -6, 0, 20)
				b.BorderSizePixel = 0
				b.AutoButtonColor = false
				b.Font = FONT
				b.TextSize = 12
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.LayoutOrder = i
				b.Text = "  " .. name .. (name == auto and "  [auto]" or "")
				b.BackgroundTransparency = on and 0 or 1
				b.BackgroundColor3 = Theme.Accent
				b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Theme.Text
				b.Parent = list
				corner(b, 3)
				b.MouseButton1Click:Connect(function()
					selected = name
					pendingDelete = false
					if delBtn then delBtn.Text = "Delete" end
					rebuild()
				end)
			end

			autoNote.Text = "autoload: " .. (auto or "none")
			if autoBtn then
				autoBtn.Text = (auto and auto == selected) and "Remove autoload" or "Set as autoload"
			end
		end
		onTheme(rebuild)

		local m = newGroup(cfgPage, 2, "Manage")

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, 0, 0, 22)
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.PlaceholderText = "new config name..."
		box.Text = ""
		box.Font = FONT
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.LayoutOrder = nextOrder(m)
		box.Parent = m
		bind(box, "BackgroundColor3", function() return Theme.Field end)
		bind(box, "TextColor3", function() return Theme.Text end)
		bind(box, "PlaceholderColor3", function() return Theme.Dim end)
		corner(box, 3)
		outline(box, 0.4)
		local bp = Instance.new("UIPadding")
		bp.PaddingLeft = UDim.new(0, 6)
		bp.Parent = box

		addButton(m, "Create new", BLUE, BLUE_H, function()
			local name = ConfigAPI.clean(box.Text)
			if name == "" then toast("Type a config name first") return end
			for _, n in ipairs(ConfigAPI.list()) do
				if string.lower(n) == string.lower(name) then
					toast("That name already exists")
					return
				end
			end
			local ok, err = ConfigAPI.save(name)
			if ok then
				selected = name
				box.Text = ""
				toast("Created: " .. name)
			else
				warn("[OUL config] " .. tostring(err))
				toast("Create failed - see Output")
			end
			rebuild()
		end)

		addButton(m, "Save (overwrite)", BLUE, BLUE_H, function()
			if not selected then toast("Select a config first") return end
			local ok, err = ConfigAPI.save(selected)
			if not ok then warn("[OUL config] " .. tostring(err)) end
			toast(ok and ("Saved: " .. selected) or "Save failed - see Output")
		end)

		addButton(m, "Load", BLUE, BLUE_H, function()
			if not selected then toast("Select a config first") return end
			local ok, err = ConfigAPI.load(selected)
			if ok then
				reloadUI()
				toast("Loaded: " .. selected)
			else
				warn("[OUL config] " .. tostring(err))
				toast("Load failed - see Output")
			end
		end)

		autoBtn = addButton(m, "Set as autoload", BLUE, BLUE_H, function()
			if not selected then toast("Select a config first") return end
			if ConfigAPI.getAutoload() == selected then
				ConfigAPI.setAutoload("")
				toast("Autoload removed")
			else
				ConfigAPI.setAutoload(selected)
				toast("Autoload: " .. selected)
			end
			rebuild()
		end)

		delBtn = addButton(m, "Delete", RED, RED_H, function()
			if not selected then toast("Select a config first") return end
			if not pendingDelete then
				pendingDelete = true
				delBtn.Text = "Click again to confirm"
				task.delay(2.5, function()
					if pendingDelete then
						pendingDelete = false
						delBtn.Text = "Delete"
					end
				end)
				return
			end
			pendingDelete = false
			delBtn.Text = "Delete"
			local ok, err = ConfigAPI.delete(selected)
			if not ok then warn("[OUL config] " .. tostring(err)) end
			toast(ok and ("Deleted: " .. selected) or "Delete failed - see Output")
			selected = nil
			rebuild()
		end)

		addNote(m, "autoload applies on launch")

		rebuild()
	end
end

do
	local MAX_ROWS = 4
	local ROW_H = 32

	local box = Instance.new("TextBox")
	box.Name = "Search"
	box.Size = UDim2.fromOffset(170, 22)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -10, 0.5, 0)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.PlaceholderText = "search settings..."
	box.Text = ""
	box.Font = FONT
	box.TextSize = 12
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ZIndex = 110
	box.Parent = titleBar
	bind(box, "BackgroundColor3", function() return Theme.Field end)
	bind(box, "TextColor3", function() return Theme.Text end)
	bind(box, "PlaceholderColor3", function() return Theme.Dim end)
	corner(box, 3)
	outline(box, 0.4)
	do
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = box
	end

	local results = Instance.new("ScrollingFrame")
	results.Name = "SearchResults"
	results.Size = UDim2.fromOffset(250, 0)
	results.AnchorPoint = Vector2.new(1, 0)
	results.Position = UDim2.new(1, -10, 0, TITLE_H - 2)
	results.BorderSizePixel = 0
	results.ScrollBarThickness = 3
	results.CanvasSize = UDim2.new()
	results.AutomaticCanvasSize = Enum.AutomaticSize.Y
	results.Visible = false
	results.ZIndex = 150
	results.Parent = panel
	bind(results, "BackgroundColor3", function() return Theme.Group end)
	corner(results, 4)
	outline(results, 0)
	do
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 2)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = results
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 3)
		pad.PaddingBottom = UDim.new(0, 3)
		pad.PaddingLeft = UDim.new(0, 3)
		pad.PaddingRight = UDim.new(0, 3)
		pad.Parent = results
	end

	local firstHit

	local function go(hit)
		box.Text = ""
		results.Visible = false
		box:ReleaseFocus()
		if currentTab ~= hit.tab or currentSub[hit.tab] ~= hit.sub then
			selectPage(hit.tab, hit.sub, false)
		end
	end

	local function rowLabel(parent, text, size, y, h, color)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromOffset(6, y)
		l.Size = UDim2.new(1, -12, 0, h)
		l.Font = FONT
		l.TextSize = size
		l.Text = text
		l.TextColor3 = color
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextTruncate = Enum.TextTruncate.AtEnd
		l.ZIndex = 152
		l.Parent = parent
	end

	local function rebuild()
		for _, c in ipairs(results:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		firstHit = nil

		local q = string.lower(box.Text)
		q = (string.gsub(q, "^%s+", ""))
		q = (string.gsub(q, "%s+$", ""))
		if q == "" then
			results.Visible = false
			return
		end

		local hits = {}
		for _, e in ipairs(searchIndex) do
			local tab, sub = string.match(e.page, "^(%w+)_(%w+)$")
			local subLabel = ""
			for _, st in ipairs(SUBTABS[tab] or {}) do
				if st.id == sub then subLabel = st.label end
			end
			local path = (TAB_LABELS[tab] or tab) .. " > " .. subLabel
			local name = string.lower(e.text)
			local rank
			if string.find(name, q, 1, true) then
				rank = (string.sub(name, 1, #q) == q) and 1 or 2
			elseif string.find(string.lower(path), q, 1, true) then
				rank = 3
			end
			if rank then
				hits[#hits + 1] = { text = e.text, tab = tab, sub = sub, path = path, rank = rank }
			end
		end
		table.sort(hits, function(a, b)
			if a.rank ~= b.rank then return a.rank < b.rank end
			if a.text ~= b.text then return a.text < b.text end
			return a.path < b.path
		end)

		results.Visible = true
		if #hits == 0 then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, 0, 0, 22)
			b.BackgroundTransparency = 1
			b.Text = ""
			b.AutoButtonColor = false
			b.ZIndex = 151
			b.Parent = results
			rowLabel(b, "no matching settings", 12, 0, 22, Theme.Dim)
			results.Size = UDim2.fromOffset(250, 28)
			return
		end

		firstHit = hits[1]
		for i = 1, math.min(#hits, 40) do
			local hit = hits[i]
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, 0, 0, ROW_H)
			b.BorderSizePixel = 0
			b.BackgroundColor3 = Theme.Accent
			b.BackgroundTransparency = 1
			b.Text = ""
			b.AutoButtonColor = false
			b.LayoutOrder = i
			b.ZIndex = 151
			b.Parent = results
			corner(b, 3)
			rowLabel(b, hit.text, 12, 3, 15, Theme.Text)
			rowLabel(b, hit.path, 10, 18, 12, Theme.Dim)
			b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.6 }) end)
			b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 1 }) end)
			b.MouseButton1Click:Connect(function() go(hit) end)
		end
		results.Size = UDim2.fromOffset(250, math.min(#hits, MAX_ROWS) * (ROW_H + 2) + 8)
	end

	box:GetPropertyChangedSignal("Text"):Connect(rebuild)
	box.Focused:Connect(rebuild)
	box.FocusLost:Connect(function(enterPressed)
		if enterPressed and firstHit then
			go(firstHit)
			return
		end
		task.delay(0.2, function()
			if not box:IsFocused() then
				results.Visible = false
			end
		end)
	end)
	onTheme(rebuild)
end

currentTab = "combat"
currentPage = pageKey("combat", currentSub.combat)
for name, p in pairs(pages) do
	local on = (name == currentPage)
	pageState[p] = on
	p.frame.Visible = true
	p.frame.GroupTransparency = on and 0 or 1
end
refreshTabs(false)
task.spawn(function()
	RunService.RenderStepped:Wait()
	if alive then
		updateSize(false)
		selectPage("combat", nil, true)

		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
		if vp then
			panel.Position = UDim2.fromOffset(
				math.floor((vp.X - PANEL_W) / 2),
				math.floor((vp.Y - panel.Size.Y.Offset) / 2)
			)
		end
	end
end)

setMenuVisible(true)

local canDamage
do

local TEAM_WORDS = { "team", "squad", "faction", "side", "clan", "party", "alliance" }
local NOT_TEAM_WORDS = { "kill", "score", "death", "point", "damage", "rank", "level", "win", "count", "size", "chat" }
local function isTeamName(name)
	local n = string.lower(name)
	for _, w in ipairs(NOT_TEAM_WORDS) do
		if string.find(n, w, 1, true) then return false end
	end
	for _, w in ipairs(TEAM_WORDS) do
		if string.find(n, w, 1, true) then return true end
	end
	return false
end

local function collect(inst, out)
	if not inst then return end
	for k, v in pairs(inst:GetAttributes()) do
		if out[k] == nil and isTeamName(k) then out[k] = v end
	end
	for _, c in ipairs(inst:GetChildren()) do
		if c:IsA("ValueBase") and out[c.Name] == nil and isTeamName(c.Name) then
			out[c.Name] = c.Value
		end
	end
	local stats = inst:FindFirstChild("leaderstats")
	if stats then
		for _, c in ipairs(stats:GetChildren()) do
			if c:IsA("ValueBase") and out[c.Name] == nil and isTeamName(c.Name) then
				out[c.Name] = c.Value
			end
		end
	end
end

local function sameTeam(plr)
	local me = LocalPlayer

	if me.Team and plr.Team then
		return me.Team == plr.Team
	end

	local a, b = {}, {}
	collect(me, a)
	collect(me.Character, a)
	collect(plr, b)
	collect(plr.Character, b)
	local differ = false
	for k, v in pairs(a) do
		if b[k] ~= nil then
			if b[k] == v then return true end
			differ = true
		end
	end
	if differ then return false end

	if not me.Neutral and not plr.Neutral then
		return me.TeamColor == plr.TeamColor
	end
	return nil
end

canDamage = function(plr)
	if not Settings.TeamCheck then return true end
	local char = plr.Character
	if char and char:FindFirstChildOfClass("ForceField") then return false end
	return sameTeam(plr) ~= true
end

local function allFields(inst)
	if not inst then return "(none)" end
	local t = {}
	for k, v in pairs(inst:GetAttributes()) do t[#t + 1] = "@" .. k .. "=" .. tostring(v) end
	for _, c in ipairs(inst:GetChildren()) do
		if c:IsA("ValueBase") then t[#t + 1] = c.Name .. "=" .. tostring(c.Value) end
	end
	return #t > 0 and table.concat(t, ", ") or "(none)"
end

local function teamFields(plr)
	local f = {}
	collect(plr, f)
	collect(plr.Character, f)
	local t = {}
	for k, v in pairs(f) do t[#t + 1] = k .. "=" .. tostring(v) end
	return #t > 0 and table.concat(t, ", ") or "(none)"
end

printTeamInfo = function()
	print("[OUL team] ===== you: " .. LocalPlayer.Name .. " =====")
	print("[OUL team] Team:", LocalPlayer.Team, "| TeamColor:", LocalPlayer.TeamColor, "| Neutral:", LocalPlayer.Neutral)
	print("[OUL team] team-like fields:", teamFields(LocalPlayer))
	print("[OUL team] player values:", allFields(LocalPlayer))
	print("[OUL team] character values:", allFields(LocalPlayer.Character))
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			print("[OUL team] ----- " .. plr.Name .. " -----")
			print("[OUL team] Team:", plr.Team, "| TeamColor:", plr.TeamColor, "| Neutral:", plr.Neutral)
			print("[OUL team] sameTeam:", sameTeam(plr), "| canDamage:", canDamage(plr))
			print("[OUL team] team-like fields:", teamFields(plr))
			print("[OUL team] player values:", allFields(plr))
			print("[OUL team] character values:", allFields(plr.Character))
		end
	end
	toast("Team info printed to Output")
end

end

local function isVisible(part, character)
	if not Settings.WallCheck then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character, character }
	local origin = Camera.CFrame.Position
	local result = workspace:Raycast(origin, part.Position - origin, params)
	return result == nil
end

local function getAimPart(char)
	if Settings.AimPart == "Head" then
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("HumanoidRootPart")
end

local MAX_AIM_DISTANCE = 1000

local function getTarget()

	local mousePos = workspace.CurrentCamera.ViewportSize / 2
	local best, bestDist = nil, Settings.IgnoreFOV and math.huge or Settings.FOV

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or Camera.CFrame.Position

	local function consider(char, plr)
		local hum = char:FindFirstChildOfClass("Humanoid")
		local part = getAimPart(char)
		if not (hum and part and isAlive(char)) then return end
		if plr then
			if not canDamage(plr) then return end
		elseif Settings.TeamCheck and char:FindFirstChildOfClass("ForceField") then
			return
		end
		if (part.Position - origin).Magnitude > MAX_AIM_DISTANCE then return end
		local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then return end
		local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
		if dist < bestDist and isVisible(part, char) then
			best, bestDist = part, dist
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			consider(plr.Character, plr)
		end
	end

	if Settings.TargetNPCs then
		for _, model in ipairs(npcCache) do
			if model.Parent then
				consider(model, nil)
			end
		end
	end

	return best
end

local triggerSeenAt = nil
local lastShot = 0

local leftHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
local synth = { began = 0, ended = 0, expires = 0 }
local function markSynthetic()
	synth.began += 1
	synth.ended += 1
	synth.expires = os.clock() + 0.25
end
track(UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if synth.began > 0 and os.clock() < synth.expires then
		synth.began -= 1
	else
		leftHeld = true
	end
end))
track(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if synth.ended > 0 and os.clock() < synth.expires then
		synth.ended -= 1
	else
		leftHeld = false
	end
end))

local function playerUnderCrosshair()
	local cam = workspace.CurrentCamera
	local m = UserInputService:GetMouseLocation()
	local ray = cam:ViewportPointToRay(m.X, m.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * MAX_AIM_DISTANCE, params)
	if not result then return nil end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	while model and not model:FindFirstChildOfClass("Humanoid") do
		model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
	end
	if not model or model == LocalPlayer.Character then return nil end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or not isAlive(model) then return nil end

	local plr = Players:GetPlayerFromCharacter(model)
	if plr then
		if plr ~= LocalPlayer and canDamage(plr) then
			return plr
		end
		return nil
	end

	if not Settings.TargetNPCs then return nil end
	if Settings.TeamCheck and model:FindFirstChildOfClass("ForceField") then return nil end
	return model
end

local function fireClick()
	markSynthetic()
	if mouse1click then
		if pcall(mouse1click) then return end
	end

	local ok = pcall(function()
		local vim = game:GetService("VirtualInputManager")
		local m = UserInputService:GetMouseLocation()
		vim:SendMouseButtonEvent(m.X, m.Y, 0, true, game, 0)
		vim:SendMouseButtonEvent(m.X, m.Y, 0, false, game, 0)
	end)
	if ok then return end

	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	end
end

track(RunService.Heartbeat:Connect(function()
	local mouseLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
	if not Settings.Triggerbot or menuOpen or not mouseLocked or UserInputService:GetFocusedTextBox() then
		triggerSeenAt = nil
		return
	end

	if Settings.TriggerOnClick and not leftHeld then
		triggerSeenAt = nil
		return
	end

	if not playerUnderCrosshair() then
		triggerSeenAt = nil
		return
	end

	local now = os.clock()
	triggerSeenAt = triggerSeenAt or now

	if now - triggerSeenAt >= Settings.TriggerDelay / 1000 and now - lastShot >= 0.1 then
		lastShot = now
		fireClick()
	end
end))

local tracerLines = {}
local TRACER_MAX_DISTANCE = 1000

local function removeTracer(plr)
	local line = tracerLines[plr]
	if line then
		line:Destroy()
		tracerLines[plr] = nil
	end
end

track(Players.PlayerRemoving:Connect(removeTracer))

track(RunService.RenderStepped:Connect(function()
	if not (Settings.ESP and Settings.Tracers) then
		for plr in pairs(tracerLines) do
			removeTracer(plr)
		end
		return
	end

	local cam = workspace.CurrentCamera
	local size = cam.ViewportSize
	local from = Vector2.new(size.X / 2, size.Y / 2)

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position

	local ents = espEntities()
	local live = {}
	for _, e in ipairs(ents) do live[e[1]] = true end
	for k in pairs(tracerLines) do
		if not live[k] then removeTracer(k) end
	end

	for _, ent in ipairs(ents) do
		local plr = ent[1]
		if plr ~= LocalPlayer then
			local char = ent[2]
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local line = tracerLines[plr]
			local shown = false

			if hum and root and hum.Health > 0
				and (root.Position - origin).Magnitude <= TRACER_MAX_DISTANCE then
				local p = cam:WorldToViewportPoint(root.Position)

				local delta
				if p.Z > 0 then
					delta = Vector2.new(p.X, p.Y) - from
				else

					local lp = cam.CFrame:PointToObjectSpace(root.Position)
					local dir = Vector2.new(lp.X, -lp.Y)
					dir = dir.Magnitude > 0.001 and dir.Unit or Vector2.new(0, 1)
					delta = dir * math.max(size.X, size.Y)
				end
				if delta.Magnitude > 4000 then
					delta = delta.Unit * 4000
				end

				shown = true
				if not line then
					line = Instance.new("Frame")
					line.Name = "OULTracer"
					line.AnchorPoint = Vector2.new(0.5, 0.5)
					line.BorderSizePixel = 0
					line.Parent = gui
					tracerLines[plr] = line
				end
				local to = from + delta
				line.BackgroundColor3 = ESPColors.Tracer
				line.Size = UDim2.fromOffset(delta.Magnitude, 1.5)
				line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
				line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
				line.Visible = true
			end

			if not shown and line then
				line.Visible = false
			end
		end
	end
end))

local boxFrames = {}

local function removeBox(plr)
	local f = boxFrames[plr]
	if f then
		f:Destroy()
		boxFrames[plr] = nil
	end
end

track(Players.PlayerRemoving:Connect(removeBox))

track(RunService.RenderStepped:Connect(function()
	if not (Settings.ESP and Settings.Boxes) then
		for plr in pairs(boxFrames) do
			removeBox(plr)
		end
		return
	end

	local cam = workspace.CurrentCamera

	local ents = espEntities()
	local live = {}
	for _, e in ipairs(ents) do live[e[1]] = true end
	for k in pairs(boxFrames) do
		if not live[k] then removeBox(k) end
	end

	for _, ent in ipairs(ents) do
		local plr = ent[1]
		if plr ~= LocalPlayer then
			local char = ent[2]
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local box = boxFrames[plr]
			local shown = false

			if hum and root and hum.Health > 0 then

				local look = root.CFrame.LookVector
				local yaw = (look.X * look.X + look.Z * look.Z > 0.0001) and math.atan2(-look.X, -look.Z) or 0
				local base = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
				local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
				local inFront = true
				for i = 0, 7 do
					local sx = (i % 2 == 0) and -2 or 2
					local sy = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
					local sz = (i < 4) and -1 or 1
					local sp = cam:WorldToViewportPoint(base:PointToWorldSpace(Vector3.new(sx, sy, sz)))
					if sp.Z <= 0 then
						inFront = false
						break
					end
					minX = math.min(minX, sp.X)
					maxX = math.max(maxX, sp.X)
					minY = math.min(minY, sp.Y)
					maxY = math.max(maxY, sp.Y)
				end
				if inFront then
					local w = maxX - minX
					local h = maxY - minY
					if h > 2 then
						shown = true
						if not box then
							box = Instance.new("Frame")
							box.Name = "OULBox"
							box.BorderSizePixel = 0
							box.Parent = gui
							local stroke = Instance.new("UIStroke")
							stroke.Thickness = 1.5
							stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
							stroke.Parent = box
							boxFrames[plr] = box
						end
						box.Position = UDim2.fromOffset(minX, minY)
						box.Size = UDim2.fromOffset(w, h)
						box.BackgroundColor3 = ESPColors.BoxFill
						box.BackgroundTransparency = Settings.BoxFill and 0.7 or 1
						box:FindFirstChildOfClass("UIStroke").Color = ESPColors.Box
						box.Visible = true
					end
				end
			end

			if not shown and box then
				box.Visible = false
			end
		end
	end
end))

do
	local skeletons = {}
	local SKELETON_MAX_DISTANCE = 1000

	local function removeSkeleton(key)
		local s = skeletons[key]
		if s then
			for _, l in ipairs(s.lines) do l:Destroy() end
			skeletons[key] = nil
		end
	end
	track(Players.PlayerRemoving:Connect(removeSkeleton))

	local function buildJoints(char)
		local out = {}
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				for _, m in ipairs(part:GetChildren()) do
					if m:IsA("Motor6D") then
						local a, b = m.Part0, m.Part1
						if a and b and a.Parent == char and b.Parent == char
							and a.Name ~= "HumanoidRootPart" and b.Name ~= "HumanoidRootPart" then
							out[#out + 1] = { a, b }
						end
					end
				end
			end
		end
		return out
	end

	track(RunService.RenderStepped:Connect(function()
		if not (Settings.ESP and Settings.Skeleton) then
			for key in pairs(skeletons) do removeSkeleton(key) end
			return
		end

		local cam = workspace.CurrentCamera
		local myChar = LocalPlayer.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local origin = myRoot and myRoot.Position or cam.CFrame.Position

		local ents = espEntities()
		local live = {}
		for _, e in ipairs(ents) do
			if e[2] then live[e[1]] = true end
		end
		for key in pairs(skeletons) do
			if not live[key] then removeSkeleton(key) end
		end

		local now = os.clock()
		for _, ent in ipairs(ents) do
			local key, char = ent[1], ent[2]
			if key ~= LocalPlayer and char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart")
				local s = skeletons[key]
				if s and s.char ~= char then
					removeSkeleton(key)
					s = nil
				end

				if hum and root and hum.Health > 0
					and (root.Position - origin).Magnitude <= SKELETON_MAX_DISTANCE then
					if not s then
						s = { char = char, joints = {}, lines = {}, built = 0 }
						skeletons[key] = s
					end
					if now - s.built > 2 then
						s.built = now
						s.joints = buildJoints(char)
					end

					for i, j in ipairs(s.joints) do
						local line = s.lines[i]
						if not line then
							line = Instance.new("Frame")
							line.Name = "OULBone"
							line.AnchorPoint = Vector2.new(0.5, 0.5)
							line.BorderSizePixel = 0
							line.Parent = gui
							s.lines[i] = line
						end

						local a, b = j[1], j[2]
						local shown = false
						if a.Parent and b.Parent then
							local pa = cam:WorldToViewportPoint(a.Position)
							local pb = cam:WorldToViewportPoint(b.Position)
							if pa.Z > 0 and pb.Z > 0 then
								local p1, p2 = Vector2.new(pa.X, pa.Y), Vector2.new(pb.X, pb.Y)
								local delta = p2 - p1
								local mid = (p1 + p2) / 2
								line.Size = UDim2.fromOffset(delta.Magnitude, 1.5)
								line.Position = UDim2.fromOffset(mid.X, mid.Y)
								line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
								line.BackgroundColor3 = ESPColors.Skeleton
								shown = true
							end
						end
						line.Visible = shown
					end
					for i = #s.joints + 1, #s.lines do
						s.lines[i].Visible = false
					end
				elseif s then
					for _, l in ipairs(s.lines) do l.Visible = false end
				end
			end
		end
	end))
end

do
	local bars = {}

	local function removeBar(key)
		local b = bars[key]
		if b then
			b.bg:Destroy()
			bars[key] = nil
		end
	end
	track(Players.PlayerRemoving:Connect(removeBar))

	local function screenBounds(cam, root)
		local look = root.CFrame.LookVector
		local yaw = (look.X * look.X + look.Z * look.Z > 0.0001) and math.atan2(-look.X, -look.Z) or 0
		local base = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
		local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
		for i = 0, 7 do
			local sx = (i % 2 == 0) and -2 or 2
			local sy = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
			local sz = (i < 4) and -1 or 1
			local sp = cam:WorldToViewportPoint(base:PointToWorldSpace(Vector3.new(sx, sy, sz)))
			if sp.Z <= 0 then return nil end
			minX = math.min(minX, sp.X)
			maxX = math.max(maxX, sp.X)
			minY = math.min(minY, sp.Y)
			maxY = math.max(maxY, sp.Y)
		end
		return minX, minY, maxX, maxY
	end

	track(RunService.RenderStepped:Connect(function()
		if not (Settings.ESP and Settings.ESPHealth) then
			for key in pairs(bars) do removeBar(key) end
			return
		end

		local cam = workspace.CurrentCamera
		local ents = espEntities()
		local live = {}
		for _, e in ipairs(ents) do
			if e[2] then live[e[1]] = true end
		end
		for key in pairs(bars) do
			if not live[key] then removeBar(key) end
		end

		for _, ent in ipairs(ents) do
			local key, char = ent[1], ent[2]
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart")
				local b = bars[key]
				local shown = false

				if hum and root and hum.Health > 0 then
					local minX, minY, maxX, maxY = screenBounds(cam, root)
					if minX and maxY - minY > 2 then
						shown = true
						if not b then
							local bg = Instance.new("Frame")
							bg.Name = "OULHealthBar"
							bg.BorderSizePixel = 0
							bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
							bg.BackgroundTransparency = 0.35
							bg.Parent = gui
							local fill = Instance.new("Frame")
							fill.BorderSizePixel = 0
							fill.AnchorPoint = Vector2.new(0, 1)
							fill.Parent = bg
							b = { bg = bg, fill = fill }
							bars[key] = b
						end

						local h = maxY - minY
						local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
						b.bg.Position = UDim2.fromOffset(minX - 7, minY)
						b.bg.Size = UDim2.fromOffset(4, h)
						b.fill.Position = UDim2.new(0, 1, 1, -1)
						b.fill.Size = UDim2.new(1, -2, 0, math.max((h - 2) * pct, 0))
						b.fill.BackgroundColor3 = Color3.fromRGB(235, 70, 70):Lerp(Color3.fromRGB(90, 220, 120), pct)
						b.bg.Visible = true
					end
				end

				if not shown and b then
					b.bg.Visible = false
				end
			end
		end
	end))
end

do
	local stash = {}
	local mySky
	local active = false
	local scanTimer, lastKey = 0, nil
	local assets, files = {}, {}
	local canFiles = type(writefile) == "function" and type(getcustomasset) == "function"

	local function be32(n)
		return string.char(
			math.floor(n / 16777216) % 256,
			math.floor(n / 65536) % 256,
			math.floor(n / 256) % 256,
			n % 256
		)
	end

	local crcTable
	local function crc32(str)
		if not crcTable then
			crcTable = {}
			for i = 0, 255 do
				local c = i
				for _ = 1, 8 do
					if bit32.band(c, 1) == 1 then
						c = bit32.bxor(0xEDB88320, bit32.rshift(c, 1))
					else
						c = bit32.rshift(c, 1)
					end
				end
				crcTable[i] = c
			end
		end
		local c = 0xFFFFFFFF
		for i = 1, #str do
			c = bit32.bxor(crcTable[bit32.band(bit32.bxor(c, str:byte(i)), 0xFF)], bit32.rshift(c, 8))
		end
		return bit32.bxor(c, 0xFFFFFFFF)
	end

	local function pngChunk(kind, data)
		return be32(#data) .. kind .. data .. be32(crc32(kind .. data))
	end

	local function solidPNG(r, g, b)
		local raw = string.char(0, r, g, b)
		local a, bb = 1, 0
		for i = 1, #raw do
			a = (a + raw:byte(i)) % 65521
			bb = (bb + a) % 65521
		end
		local zlib = "\120\1" .. "\1" .. "\4\0" .. "\251\255" .. raw .. be32(bb * 65536 + a)
		local ihdr = be32(1) .. be32(1) .. "\8\2\0\0\0"
		return "\137PNG\13\10\26\10" .. pngChunk("IHDR", ihdr) .. pngChunk("IDAT", zlib) .. pngChunk("IEND", "")
	end

	local function q(v)
		return math.clamp(math.floor(v * 255 / 8 + 0.5) * 8, 0, 255)
	end

	local function skyAsset(c)
		local r, g, b = q(c.R), q(c.G), q(c.B)
		local key = string.format("%02X%02X%02X", r, g, b)
		if assets[key] then return assets[key], key end
		local ok, res = pcall(function()
			local name = "OULSky_" .. key .. ".png"
			writefile(name, solidPNG(r, g, b))
			files[#files + 1] = name
			return getcustomasset(name)
		end)
		if ok and res then
			assets[key] = res
			return res, key
		end
		return nil, key
	end

	local function stashOthers()
		for _, c in ipairs(Lighting:GetChildren()) do
			if (c:IsA("Sky") or c:IsA("Atmosphere")) and c ~= mySky then
				stash[#stash + 1] = c
				c.Parent = nil
			end
		end
	end

	local function enable()
		if not canFiles then return false end
		active = true
		lastKey = nil

		mySky = Instance.new("Sky")
		mySky.Name = "OULSky"
		mySky.StarCount = 0
		mySky.CelestialBodiesShown = false

		stashOthers()
		mySky.Parent = Lighting
		return true
	end

	local function disable(purge)
		if active then
			active = false
			if mySky then pcall(function() mySky:Destroy() end) mySky = nil end
			for _, c in ipairs(stash) do
				pcall(function() c.Parent = Lighting end)
			end
			stash = {}
		end
		if purge then
			if type(delfile) == "function" then
				for _, f in ipairs(files) do pcall(delfile, f) end
			end
			files, assets = {}, {}
		end
	end

	track(RunService.Heartbeat:Connect(function(dt)
		if Settings.Skybox then
			if not active and not enable() then
				Settings.Skybox = false
				if refreshers.Skybox then refreshers.Skybox(true) end
				toast("Skybox needs file support")
				return
			end

			scanTimer += dt
			if scanTimer >= 1 then
				scanTimer = 0
				stashOthers()
				if mySky.Parent ~= Lighting then mySky.Parent = Lighting end
			end

			local c
			if Settings.SkyRainbow then
				c = Color3.fromHSV((math.floor(os.clock() * 6) % 60) / 60, 0.75, 1)
			else
				c = ESPColors.Sky
			end
			local asset, key = skyAsset(c)
			if asset and key ~= lastKey then
				lastKey = key
				mySky.SkyboxBk, mySky.SkyboxDn, mySky.SkyboxFt = asset, asset, asset
				mySky.SkyboxLf, mySky.SkyboxRt, mySky.SkyboxUp = asset, asset, asset
			end
		elseif active then
			disable()
		end
	end))

	ConfigAPI.skyRestore = disable
end

local flyActive = false

local function flyDirection()
	local cf = workspace.CurrentCamera.CFrame
	local d = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + cf.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - cf.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + cf.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - cf.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0, 1, 0) end
	if d.Magnitude > 0 then
		return d.Unit
	end
	return d
end

track(RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and root and hum.Health > 0) then
		flyActive = false
		return
	end

	if Settings.Fly then
		flyActive = true
		hum.PlatformStand = true

		local dir = UserInputService:GetFocusedTextBox() and Vector3.new(0, 0, 0) or flyDirection()
		root.AssemblyLinearVelocity = dir * Settings.FlySpeed
		root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		local look = workspace.CurrentCamera.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude > 0.01 then
			root.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
		end
	elseif flyActive then
		flyActive = false
		hum.PlatformStand = false
		root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end
end))

local speedHum, speedOrig
track(RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if Settings.Speed and hum and hum.Health > 0 then
		if speedHum ~= hum then
			if speedHum and speedHum.Parent then speedHum.WalkSpeed = speedOrig end
			speedHum = hum
			speedOrig = hum.WalkSpeed
		end
		hum.WalkSpeed = Settings.SpeedValue
	elseif speedHum then
		if speedHum.Parent then speedHum.WalkSpeed = speedOrig end
		speedHum = nil
	end
end))

track(UserInputService.JumpRequest:Connect(function()
	if not Settings.InfiniteJump then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

local noclipOrig = {}

local function noclipRestore()
	for part in pairs(noclipOrig) do
		if part.Parent then
			part.CanCollide = true
		end
		noclipOrig[part] = nil
	end
end

track(RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	if Settings.Noclip and char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				noclipOrig[part] = true
				part.CanCollide = false
			end
		end
	elseif next(noclipOrig) then
		noclipRestore()
	end
end))

local function mouseTeleport()
	if not Settings.MouseTP or menuOpen then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and root and hum.Health > 0) then return end

	local cam = workspace.CurrentCamera
	local m = UserInputService:GetMouseLocation()
	local ray = cam:ViewportPointToRay(m.X, m.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 10000, params)
	if not result then
		if toast then toast("Mouse TP  -  nothing in range") end
		return
	end

	local lift = Vector3.new(0, hum.HipHeight + root.Size.Y / 2, 0)
	local pos = result.Position + result.Normal * 2 + lift
	root.CFrame = CFrame.new(pos) * (root.CFrame - root.CFrame.Position)
	root.AssemblyLinearVelocity = Vector3.zero
end

local rageTarget = nil
local rageShown = nil
local rageAngle = 0

local function getRageTarget(myRoot)

	if Settings.RageMode == "Selected" then
		local query = string.lower(Settings.RageTarget or "")
		if query == "" then return nil, "pick a player" end
		local pick
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local n, d = string.lower(plr.Name), string.lower(plr.DisplayName)
				if n == query or d == query then
					pick = plr
					break
				elseif not pick and (string.find(n, query, 1, true) or string.find(d, query, 1, true)) then
					pick = plr
				end
			end
		end
		if not pick then return nil, "not in server" end
		local char = pick.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not (root and isAlive(char)) then return nil, pick.Name .. " (dead)" end
		return { root = root, name = pick.Name, plr = pick }
	end

	if rageTarget and rageTarget.plr and rageTarget.plr.Parent == Players then
		local char = rageTarget.plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and root == rageTarget.root and isAlive(char) then
			return rageTarget
		end
	end

	local best, bestDist
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and isAlive(char) and canDamage(plr) then
				local d = (root.Position - myRoot.Position).Magnitude
				if not bestDist or d < bestDist then
					best, bestDist = { root = root, name = plr.Name, plr = plr }, d
				end
			end
		end
	end
	return best
end

local function setRageStatus(text)
	if rageStatus and rageShown ~= text then
		rageShown = text
		rageStatus.Text = text
	end
end

track(RunService.Stepped:Connect(function(_, dt)
	if not Settings.Ragebot then
		rageTarget = nil
		setRageStatus("Target: none")
		return
	end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local myRoot = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and myRoot and hum.Health > 0) then return end

	local why
	rageTarget, why = getRageTarget(myRoot)
	if not rageTarget then
		setRageStatus("Target: " .. (why or "none found"))
		return
	end
	setRageStatus("Target: " .. rageTarget.name)

	local targetPos = rageTarget.root.Position
	local dist = Settings.RageDistance

	if Settings.RageOrbit then
		rageAngle = (rageAngle + dt * Settings.OrbitSpeed) % (math.pi * 2)
		local height = 0
		if Settings.RageAbove then
			height = dist
		elseif Settings.RageBelow then
			height = -dist
		end
		local pos = targetPos + Vector3.new(math.cos(rageAngle) * dist, height, math.sin(rageAngle) * dist)
		myRoot.CFrame = CFrame.lookAt(pos, targetPos)
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
		return
	end

	local look = rageTarget.root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then return end
	flat = flat.Unit

	local pos
	if Settings.RageAbove then
		pos = targetPos + Vector3.new(0, dist, 0)
	elseif Settings.RageBelow then
		pos = targetPos - Vector3.new(0, dist, 0)
	else

		pos = targetPos - flat * dist
	end

	myRoot.CFrame = CFrame.lookAt(pos, pos + flat)
	myRoot.AssemblyLinearVelocity = Vector3.zero
	myRoot.AssemblyAngularVelocity = Vector3.zero
end))

local vortexRestoreAll, vortexRemote
do
local vstate = nil

local function claimNetwork()
	pcall(function()
		if type(sethiddenproperty) == "function" then
			sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
		end
	end)
	pcall(function()
		if type(setsimulationradius) == "function" then
			setsimulationradius(math.huge, math.huge)
		end
	end)
	pcall(function()
		LocalPlayer.MaximumSimulationRadius = math.huge
	end)
end

local function placeAll(st, ease)
	local root = st.root
	local t = os.clock()
	local spin = t * st.speed * 0.5
	local center = root.Position
	local count = math.max(st.orbitCount, 1)
	local rest = { [root] = root.CFrame }

	for _, j in ipairs(st.joints) do
		local p0 = j.p0
		if p0.Parent and j.part.Parent then
			local r = (rest[p0] or p0.CFrame) * j.c0 * j.c1:Inverse()
			rest[j.part] = r

			local cf = r
			if not j.head then
				local sl = j.slot

				local k = (sl - 0.5) / count
				local phi = math.acos(1 - 2 * k)
				local theta = sl * 2.399963
				local dir = Vector3.new(math.sin(phi) * math.cos(theta), math.cos(phi), math.sin(phi) * math.sin(theta))
				local tilt = CFrame.Angles(spin * 0.6, spin, spin * 0.35)

				local rad = st.radius * (0.5 + 0.5 * math.sin(t * st.speed * (0.12 + (sl % 4) * 0.035) + sl * 1.7))
				local pos = center + tilt:VectorToWorldSpace(dir) * rad
				local orbit = CFrame.new(pos) * CFrame.Angles(t * 2 + sl, t * 1.3 + sl * 0.6, t * 1.7)
				cf = r:Lerp(orbit, ease)
			end
			j.part.CFrame = cf
			j.part.AssemblyLinearVelocity = Vector3.zero
			j.part.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function vortexRestore(skipRebuild)
	local st = vstate
	if not st then return end
	vstate = nil
	if skipRebuild then return end

	pcall(placeAll, st, 0)
	for _, j in ipairs(st.joints) do
		pcall(function()
			if j.part.Parent and j.p0.Parent then
				j.part.CanCollide = j.canCollide
				j.part.AssemblyLinearVelocity = Vector3.zero
				local m = Instance.new("Motor6D")
				m.Name = j.name
				m.C0 = j.c0
				m.C1 = j.c1
				m.Part0 = j.p0
				m.Part1 = j.part
				m.Parent = j.parent
			end
		end)
	end
	pcall(function()
		if st.hum and st.requiresNeck ~= nil then
			st.hum.RequiresNeck = st.requiresNeck
		end
	end)
	pcall(function()
		if st.cam and st.hum then st.cam.CameraSubject = st.hum end
	end)
end

function vortexRestoreAll()
	vortexRestore(false)
end

local function vortexBuild(char, hum, root)
	local st = {
		char = char, hum = hum, root = root,
		joints = {}, orbitCount = 0, blend = 0,
		speed = Settings.VortexSpeed, radius = Settings.VortexRadius,
		requiresNeck = hum.RequiresNeck, lastClaim = 0,
	}

	local motors = {}
	for _, m in ipairs(char:GetDescendants()) do

		if m:IsA("Motor6D") and m.Name ~= "Neck" and m.Part0 and m.Part1 and m.Part1:IsDescendantOf(char) then
			motors[#motors + 1] = m
		end
	end

	local placed, done, slot = { [root] = true }, {}, 0
	local progress = true
	while progress do
		progress = false
		for _, m in ipairs(motors) do
			if not done[m] and placed[m.Part0] and not placed[m.Part1] then
				done[m], placed[m.Part1] = true, true
				progress = true
				local isHead = m.Part1.Name == "Head"
				if not isHead then slot += 1 end
				st.joints[#st.joints + 1] = {
					motor = m, name = m.Name, parent = m.Parent,
					p0 = m.Part0, part = m.Part1, c0 = m.C0, c1 = m.C1,
					canCollide = m.Part1.CanCollide, head = isHead, slot = slot,
				}
			end
		end
	end
	st.orbitCount = slot

	hum.RequiresNeck = false
	claimNetwork()
	for _, j in ipairs(st.joints) do
		pcall(function() j.motor:Destroy() end)
		j.part.CanCollide = false
	end

	pcall(function()
		st.cam = workspace.CurrentCamera
		st.cam.CameraSubject = root
	end)
	return st
end

track(RunService.Stepped:Connect(function()
	local st = vstate
	if st and st.root.Parent then placeAll(st, st.blend * st.blend * (3 - 2 * st.blend)) end
end))

track(RunService.Heartbeat:Connect(function()
	local st = vstate
	if st and st.root.Parent then
		placeAll(st, st.blend * st.blend * (3 - 2 * st.blend))
		local now = os.clock()
		if now - st.lastClaim > 1 then
			st.lastClaim = now
			claimNetwork()
		end
	end
end))

task.spawn(function()
	vortexRemote = game:GetService("ReplicatedStorage"):WaitForChild("OULVortexEvent", 5)
end)
local vortexSent = { want = false, speed = nil, radius = nil, at = 0 }

local function sendVortex()
	if not vortexRemote then return end
	local want = (not VORTEX_DISABLED and alive and Settings.FlyVortex) and true or false
	local sp, rad = Settings.VortexSpeed, Settings.VortexRadius
	local changed = want ~= vortexSent.want
	local tweaked = want and (sp ~= vortexSent.speed or rad ~= vortexSent.radius)
		and os.clock() - vortexSent.at >= 0.1
	if changed or tweaked then
		vortexSent = { want = want, speed = sp, radius = rad, at = os.clock() }
		vortexRemote:FireServer(want, sp, rad)
	end
end

local vortexLastError
local function vortexFrame(dt)
	local serverSide = game:GetService("ReplicatedStorage"):GetAttribute("OULVortexServerSide") == true

	local want = (not VORTEX_DISABLED) and (not serverSide) and alive and Settings.FlyVortex

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = (hum and hum.RootPart) or (char and char:FindFirstChild("HumanoidRootPart"))

	local st = vstate
	if st and (st.char ~= char or not root or st.root ~= root) then
		vortexRestore(true)
		st = nil
	end

	if want and hum and root and hum.Health > 0 then
		if not st then
			st = vortexBuild(char, hum, root)
			vstate = st
		end
		st.speed, st.radius = Settings.VortexSpeed, Settings.VortexRadius
		st.blend = math.min(1, st.blend + dt / 0.5)
	elseif st then
		st.blend = math.max(0, st.blend - dt / 0.5)
		if st.blend <= 0 then
			vortexRestore(false)
			st = nil
		end
	end

	if vortexStatus then
		local msg
		if VORTEX_DISABLED then
			msg = "disabled"
		elseif serverSide then
			msg = Settings.FlyVortex and "on (server-side)" or "off"
		elseif not Settings.FlyVortex then
			msg = "off"
		elseif not (hum and root) then
			msg = "waiting for character"
		elseif st and st.orbitCount == 0 then
			msg = "no joints found"
		elseif st then
			msg = "on, " .. st.orbitCount .. " parts (executor)"
		else
			msg = "starting"
		end
		vortexStatus.Text = "Vortex: " .. msg
		vortexServerLabel.Text = (vortexRemote and serverSide) and "Server: ok (all see it)" or "Server: none (executor)"
	end

	sendVortex()
end

track(RunService.RenderStepped:Connect(function(dt)
	local ok, err = pcall(vortexFrame, dt)
	if not ok then
		if err ~= vortexLastError then
			vortexLastError = err
			warn("[OUL vortex] " .. tostring(err))
		end
		if vortexStatus then
			vortexStatus.Text = "Vortex: error (see Output)"
		end
	end
end))
end

local function panicNow()
	pcall(function() gui.Enabled = false end)
	pcall(function() blur.Size = 0 end)
	local fn = shared.OULCleanup
	shared.OULCleanup = nil
	if fn then pcall(fn) end

	pcall(function() gui:Destroy() end)
	pcall(function() blur:Destroy() end)
	pcall(function() espFolder:Destroy() end)
end

track(UserInputService.InputBegan:Connect(function(input, processed)
	if rebinding then
		local b = rebinding
		local newInput
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				rebinding = nil
				refreshBindUI()
				return
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				if b.kind == "menu" or b.kind == "panic" then
					toast("This key can't be cleared")
					return
				end
				newInput = false
			elseif input.KeyCode ~= Enum.KeyCode.Unknown then
				newInput = input.KeyCode
			else
				return
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then
			newInput = input.UserInputType
		else
			return
		end

		if newInput then
			for _, o in ipairs(Binds) do
				if o ~= b and o.kind == "panic" and o.input == newInput then
					toast("That key is the panic key")
					return
				end
			end
			for _, o in ipairs(Binds) do
				if o ~= b and o.input == newInput then
					o.input = nil
				end
			end
		end
		b.input = newInput or nil
		Settings.Holding = false
		rebinding = nil
		refreshBindUI()
		updateKeyHints()
		toast(b.label .. "  ->  " .. keyName(b.input))
		return
	end

	local panicBind = getBind("panic")
	if panicBind and panicBind.input and inputMatches(input, panicBind.input) then
		panicNow()
		return
	end

	if processed then return end

	for _, b in ipairs(Binds) do
		if b.input and inputMatches(input, b.input) then
			if b.kind == "toggle" then
				local t = toggles[b.key]
				if t then t.toggle() end
			elseif b.kind == "menu" then
				setMenuVisible(not menuOpen)
			elseif b.kind == "hold" then
				if Settings.AimMode == "Toggle" then
					Settings.Holding = not Settings.Holding
					if notify then notify("Aim lock", Settings.Holding) end
				else
					Settings.Holding = true
				end
			elseif b.kind == "press" then
				mouseTeleport()
			end
		end
	end
end))

local RETURN_WINDOW = 1.0
local JUMP_ANGLE = math.rad(25)
local aimEndedAt = 0
local savedCFrame = nil

local aiming = false
local lockedPart = nil

track(UserInputService.InputEnded:Connect(function(input)
	if Settings.AimMode ~= "Toggle" and inputMatches(input, getBind("aim").input) then
		if aiming then
			aimEndedAt = os.clock()
			savedCFrame = workspace.CurrentCamera.CFrame
		end
		Settings.Holding = false
	end
end))

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
	Camera = workspace.CurrentCamera

	local m = UserInputService:GetMouseLocation()
	circle.Position = UDim2.fromOffset(m.X, m.Y)
	circle.Visible = Settings.Enabled and Settings.ShowFOV and not Settings.IgnoreFOV

	if savedCFrame and not Settings.Holding then
		if os.clock() - aimEndedAt > RETURN_WINDOW then
			savedCFrame = nil
		else
			local cur = Camera.CFrame
			local angle = math.acos(math.clamp(cur.LookVector:Dot(savedCFrame.LookVector), -1, 1))
			local mouseMoved = UserInputService:GetMouseDelta().Magnitude

			if angle > JUMP_ANGLE and mouseMoved < 2 then

				Camera.CFrame = CFrame.new(cur.Position) * (savedCFrame - savedCFrame.Position)
			else
				savedCFrame = cur
			end
		end
	end

	local mouseLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
	local wasAiming = aiming
	aiming = Settings.Enabled and Settings.Holding and mouseLocked and not menuOpen
	if wasAiming and not aiming and Settings.AimMode == "Toggle" then
		aimEndedAt = os.clock()
		savedCFrame = Camera.CFrame
	end
	if not aiming then
		lockedPart = nil
		return
	end

	if lockedPart then
		local model = lockedPart:FindFirstAncestorOfClass("Model")
		local valid = lockedPart.Parent ~= nil and model ~= nil and isAlive(model)
		if valid then
			local _, onScreen = Camera:WorldToViewportPoint(lockedPart.Position)
			if not onScreen or not isVisible(lockedPart, model) then
				valid = false
			end
		end
		if not valid then
			lockedPart = nil
		end
	end
	if not lockedPart then
		lockedPart = getTarget()
		if not lockedPart then return end
	end
	local target = lockedPart

	local alpha = (Settings.Strength >= 500) and 1 or (1 - math.exp(-Settings.Strength * dt))

	local aimPos = target.Position
	if Settings.Prediction then
		local tm = target:FindFirstAncestorOfClass("Model")
		local troot = tm and tm:FindFirstChild("HumanoidRootPart")
		if troot then
			local v = troot.AssemblyLinearVelocity
			aimPos = aimPos + Vector3.new(v.X, 0, v.Z) * (Settings.PredictionMs / 1000)
		end
	end

	local goal = CFrame.lookAt(Camera.CFrame.Position, aimPos)
	Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end)

local function cleanup()
	alive = false

	Settings.Enabled = false
	Settings.Holding = false
	Settings.Fullbright = false
	Settings.NoFog = false
	Settings.Radar = false
	Settings.Triggerbot = false
	Settings.Ragebot = false
	Settings.RageOrbit = false
	Settings.ESP = false
	Settings.Chams = false
	Settings.ShowNames = false
	Settings.Tracers = false
	Settings.ESPHealth = false
	Settings.Fly = false
	Settings.FlyVortex = false
	Settings.Noclip = false
	Settings.Speed = false
	Settings.InfiniteJump = false
	rebinding = nil

	pcall(function()
		if speedHum and speedHum.Parent then speedHum.WalkSpeed = speedOrig end
	end)

	pcall(noclipRestore)
	pcall(applyWorldLighting)
	pcall(function()
		if ConfigAPI.radarCleanup then ConfigAPI.radarCleanup() end
	end)
	pcall(function()
		if ConfigAPI.skyRestore then ConfigAPI.skyRestore(true) end
	end)

	pcall(vortexRestoreAll)
	pcall(function()
		if vortexRemote then
			vortexRemote:FireServer(false, Settings.VortexSpeed, Settings.VortexRadius)
		end
	end)

	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum and flyActive then hum.PlatformStand = false end
		if root and flyActive then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
	end)

	for _, conn in ipairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(connections)

	pcall(function() RunService:UnbindFromRenderStep("Aimbot") end)
	pcall(function() RunService:UnbindFromRenderStep("OULMenuMouse") end)

	pcall(function()
		if menuOpen and prevMouseBehavior then
			UserInputService.MouseBehavior = prevMouseBehavior
			UserInputService.MouseIconEnabled = prevMouseIcon
		end
	end)

	for plr, h in pairs(highlights) do
		pcall(function() h:Destroy() end)
		highlights[plr] = nil
	end

	for plr, t in pairs(nameTags) do
		pcall(function() t:Destroy() end)
		nameTags[plr] = nil
	end

	for plr, l in pairs(tracerLines) do
		pcall(function() l:Destroy() end)
		tracerLines[plr] = nil
	end

	for plr, b in pairs(boxFrames) do
		pcall(function() b:Destroy() end)
		boxFrames[plr] = nil
	end

	Settings.Boxes = false
	Settings.Skeleton = false

	pcall(function() espFolder:Destroy() end)
	pcall(function() gui:Destroy() end)
	pcall(function() blur:Destroy() end)
end

shared.OULCleanup = cleanup
