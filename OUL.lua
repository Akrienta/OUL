local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

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

-- ===== LOGO =====
-- Option A: upload Neon_OUL_Circular_Tech_Emblem.png in Creator Hub and paste the ID here.
-- Option B: put the PNG in your executor workspace folder named OUL_logo.png.
-- If neither is set, a built-in purple/blue ring emblem is drawn instead, so it always shows something.
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
		-- crops the PNG's black square background into a circle
		Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
		return img
	end

	-- built-in emblem: gradient ring with "OUL" inside
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

-- default theme matches the OUL logo: near-black navy, purple-to-blue accents, white text
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
	Smoothness = 1,
	Triggerbot = false,
	TriggerDelay = 50,
	TriggerOnClick = false, -- only auto-shoot while left click is held
	ESP = true,
	Chams = true,
	BlurEnabled = true,
	BlurAmount = 18,
	ShowNames = false,
	Tracers = false,
	Boxes = false,
	BoxFill = false,
	WallCheck = true,
	Watermark = true,
	ShowFOV = true,
	AimPart = "Head",
	UITransparency = 0,
	Fly = false,
	FlySpeed = 60,
	FlyVortex = false,
	VortexSpeed = 6,
	VortexRadius = 5,
	VortexCollide = false,
	Noclip = false,
	Speed = false,
	SpeedValue = 40,
	InfiniteJump = false,
	Notifications = true,
	TargetNPCs = true, -- Target Zombies (aimbot + triggerbot)
	ESPNPCs = true, -- Zombie/NPC ESP
	MouseTP = true,
	MouseTPRange = 1000,
	KeybindList = true,
}

local setESPEnabled
local printTeamInfo

local VORTEX_DISABLED = true
local LockedSettings = { FlyVortex = true }

local DisplayNames = {
	Enabled = "Aimbot", ShowFOV = "FOV Circle", IgnoreFOV = "Ignore FOV", TeamCheck = "Team Check", Triggerbot = "Triggerbot",
	ESP = "ESP", Chams = "Chams", ShowNames = "Usernames", Tracers = "Tracers",
	Boxes = "Boxes", BoxFill = "Box Fill", Fly = "Fly", FlyVortex = "Vortex",
	Noclip = "Noclip", Speed = "Speed", InfiniteJump = "Infinite Jump",
	Watermark = "Watermark", BlurEnabled = "Background Blur", Notifications = "Notifications",
	TargetNPCs = "Target Zombies/NPCS", ESPNPCs = "Zombie/NPC ESP",
	MouseTP = "Mouse TP", KeybindList = "Keybind List",
}

local Binds = {}
local function defBind(id, label, kind, key, input)
	Binds[#Binds + 1] = { id = id, label = label, kind = kind, key = key, input = input, default = input }
end
defBind("menu", "Menu", "menu", nil, Enum.KeyCode.End)
defBind("aim", "Aim (hold)", "hold", nil, Enum.UserInputType.MouseButton2)
for _, k in ipairs({
	"Enabled", "ShowFOV", "IgnoreFOV", "TeamCheck", "Triggerbot", "ESP", "Chams", "ShowNames", "Tracers", "Boxes",
	"BoxFill", "Fly", "Noclip", "Speed", "InfiniteJump", "Watermark", "BlurEnabled", "Notifications", "KeybindList",
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

local MAX_HIGHLIGHTS = 30
local ESPColors = {
	Fill = Color3.fromRGB(255, 70, 70),
	Outline = Color3.fromRGB(255, 255, 255),
	Tracer = Color3.fromRGB(255, 70, 70),
	Name = Color3.fromRGB(255, 255, 255),
	Box = Color3.fromRGB(255, 255, 255),
	BoxFill = Color3.fromRGB(255, 70, 70),
}

local FOVColor = Color3.fromRGB(255, 255, 255)
local persistOK = false
local saveStatusText = "saving: connecting..."
local saveStatusLabel
local saveNowFn = function() end

-- remembered on-screen positions (watermark + keybind list). nil = use the default spot
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

do
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- save format version. v2 = logo-matched default theme; older saves keep their settings
-- but their old menu colours are ignored once so the new look shows up
local SAVE_VERSION = 2

local SAVE_BOOLS = {
	"Enabled", "IgnoreFOV", "TeamCheck", "Triggerbot", "TriggerOnClick", "ESP", "Chams", "BlurEnabled", "ShowNames", "Tracers",
	"Boxes", "BoxFill", "Watermark", "ShowFOV", "Fly", "Noclip", "Speed",
	"InfiniteJump", "Notifications", "TargetNPCs", "ESPNPCs", "MouseTP", "KeybindList",
}
local SAVE_NUMBERS = {
	FOV = { 20, 500 }, Smoothness = { 1, 100 }, TriggerDelay = { 0, 300 },
	BlurAmount = { 1, 56 }, UITransparency = { 0, 70 }, FlySpeed = { 5, 1000 },
	VortexSpeed = { 1, 20 }, VortexRadius = { 2, 14 }, SpeedValue = { 16, 250 }, MouseTPRange = { 50, 1000 },
}
local SAVE_THEME = { "Text", "Switch", "Accent", "Background", "Outline" }
local SAVE_ESP = { "Fill", "Outline", "Tracer", "Name", "Box", "BoxFill" }

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

	-- old (pre-logo) saves keep the new default theme; saves from now on keep your picked colours
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
			if bind.kind ~= "menu" then bind.input = nil end
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
end

-- true only for living characters / NPCs. filters out corpses and ragdolls:
-- zero health, Dead state, "dead" flags, clones named after a player, and
-- anything sitting in a ragdoll / corpse style folder
local CORPSE_WORDS = { "ragdoll", "corpse", "dead", "bodies", "debris", "gib" }
local function isAlive(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
	if model:GetAttribute("Dead") or model:GetAttribute("IsDead") or hum:GetAttribute("Dead") then
		return false
	end

	if not Players:GetPlayerFromCharacter(model) then
		-- a model named after a real player that isn't their character is a body clone
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

-- non-player humanoids (NPCs). always scanned; used by the aimbot, triggerbot and ESP
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

-- everything ESP draws: {key, character}; key is the Player, or the model for NPCs
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

	-- drop ESP for NPCs that are gone
	for key in pairs(highlights) do
		if not seen[key] then removeESP(key) end
	end
	for key in pairs(nameTags) do
		if not seen[key] then removeTag(key) end
	end

	-- players first, then nearest
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

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BorderSizePixel = 0
topLine.ZIndex = 5
topLine.Parent = panel
bind(topLine, "BackgroundColor3", function()
	return Theme.Accent
end)

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
	visuals = { { id = "esp", label = "ESP" }, { id = "colours", label = "Colours" } },
	settings = { { id = "general", label = "General" }, { id = "keybinds", label = "Keybinds" } },
	movement = { { id = "fly", label = "Fly" }, { id = "vortex", label = "Vortex", disabled = true }, { id = "noclip", label = "Noclip" }, { id = "speed", label = "Speed" }, { id = "jump", label = "Jump" }, { id = "mousetp", label = "Mouse TP" } },
}
local SUB_H = 26
local SUB_W = 80

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, SIDE_W, 1, -(TITLE_H + FOOTER_H))
tabBar.Position = UDim2.fromOffset(0, TITLE_H)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.fromOffset(0, TITLE_H)
titleLine.BorderSizePixel = 0
titleLine.Parent = panel
bind(titleLine, "BackgroundColor3", function()
	return Theme.Outline
end)

local tabLine = Instance.new("Frame")
tabLine.Size = UDim2.new(0, 1, 1, -(TITLE_H + FOOTER_H))
tabLine.Position = UDim2.fromOffset(SIDE_W, TITLE_H)
tabLine.BorderSizePixel = 0
tabLine.Parent = panel
bind(tabLine, "BackgroundColor3", function()
	return Theme.Outline
end)

local underline = Instance.new("Frame")
underline.Size = UDim2.fromOffset(2, TAB_ROW - 8)
underline.Position = UDim2.fromOffset(0, 11)
underline.BorderSizePixel = 0
underline.ZIndex = 3
underline.Parent = tabBar
bind(underline, "BackgroundColor3", function()
	return Theme.Accent
end)

local footer = newLabel(panel, "", 11, true)
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, PAGE_X, 1, -5)
footer.Size = UDim2.new(1, -(PAGE_X + 8), 0, 12)
addHint(footer, function()
	return keyName(getBind("menu").input) .. "  -  hide / show menu"
end)

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

-- ===== KEYBIND LIST (draggable, position is saved) =====
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
	-- menu-only options aren't cheats, so they stay off the list
	local SKIP = { menu = true, Watermark = true, BlurEnabled = true, Notifications = true, KeybindList = true }
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
					on, tag = Settings.Holding and true or false, "Hold"
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

local modalBtn = Instance.new("TextButton")
modalBtn.Size = UDim2.fromOffset(0, 0)
modalBtn.BackgroundTransparency = 1
modalBtn.Text = ""
modalBtn.Modal = true
modalBtn.Parent = panel

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

	local page = { frame = frame, cols = cols, subOffset = hasSubs and SUB_H or 0 }
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

	return content
end

local function addNote(parent, text)
	local l = newLabel(parent, text, 11, true)
	l.Size = UDim2.new(1, 0, 0, 14)
	l.LayoutOrder = nextOrder(parent)
	return l
end

local function addCheckbox(parent, text, key, onChanged)
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
	return bar
end

local function addSegment(parent, text, key, optA, optB)
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
		end)
		buttons[i] = btn
	end
	onTheme(function()
		refresh(true)
	end)
	refresh(false)
	return row
end

local function addButton(parent, text, color, hoverColor, onClick)
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
	Color3.fromRGB(8, 9, 20), -- OUL logo navy (default)
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
	addSlider(g, "Smoothness", 1, 100, "Smoothness")
	addSegment(g, "Target", "AimPart", "Head", "Body")

	local v = newGroup(aimPage, 2, "FOV Circle")
	addCheckbox(v, "Show FOV", "ShowFOV")
	addColor(v, "FOV Color", paletteWith(FOVColor), function(color)
		circleStroke.Color = color
		FOVColor = color
	end, FOVColor)

	local info = newGroup(aimPage, 2, "Info")
	addHint(addNote(info, ""), function()
		return "hold " .. string.lower(keyName(getBind("aim").input)) .. " to aim"
	end)
	addNote(info, "range: 1000 studs")
	addNote(info, "needs mouse lock")
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

addPlaceholderPage("combat_ragebot", "Ragebot")

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
	addCheckbox(g, "Zombie/NPC ESP", "ESPNPCs")

	local info = newGroup(espPage, 2, "Info")
	addNote(info, "chams show through walls")
	addNote(info, "everything needs ESP on")
	addNote(info, "boxes: outline + optional")
	addNote(info, "see-through fill")
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
	local g = newGroup(vortexPage, 1, "Vortex")
	addCheckbox(g, "Vortex Mode", "FlyVortex")
	addSlider(g, "Vortex Speed", 1, 20, "VortexSpeed")
	addSlider(g, "Vortex Radius", 2, 14, "VortexRadius")
	addCheckbox(g, "Vortex Collision", "VortexCollide")

	local st = newGroup(vortexPage, 2, "Status")
	vortexStatus = addNote(st, "Vortex: off")
	vortexServerLabel = addNote(st, "Server: checking...")
	addNote(st, "works with or without fly")

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
	addSlider(g, "Max Range", 50, 1000, "MouseTPRange")

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
	for _, id in ipairs({ "aim", "Enabled", "ShowFOV", "IgnoreFOV", "TeamCheck", "Triggerbot" }) do
		addKeybindRow(c, id)
	end

	local mv = newGroup(keyPage, 1, "Movement")
	for _, id in ipairs({ "Fly", "Noclip", "Speed", "InfiniteJump", "MouseTPKey" }) do
		addKeybindRow(mv, id)
	end

	local v = newGroup(keyPage, 2, "Visuals")
	for _, id in ipairs({ "ESP", "Chams", "ShowNames", "Tracers", "Boxes", "BoxFill" }) do
		addKeybindRow(v, id)
	end

	local m = newGroup(keyPage, 2, "Menu")
	for _, id in ipairs({ "menu", "Watermark", "KeybindList", "BlurEnabled", "Notifications" }) do
		addKeybindRow(m, id)
	end
	addNote(m, "click a key, then press a new one")
	addNote(m, "Esc  -  cancel    Backspace  -  clear")
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
-- any attribute / value object whose name looks team-related counts as a team field
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

-- true = teammate, false = enemy, nil = can't tell
local function sameTeam(plr)
	local me = LocalPlayer
	-- 1) Roblox Teams service
	if me.Team and plr.Team then
		return me.Team == plr.Team
	end
	-- 2) any team-looking field on the player, their character, or leaderstats
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
	-- 3) plain TeamColor when both players are on a team
	if not me.Neutral and not plr.Neutral then
		return me.TeamColor == plr.TeamColor
	end
	return nil
end

-- returns false for players you cannot damage (teammates, spawn-protected).
-- every combat feature should call this before picking a target.
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
	local mousePos = UserInputService:GetMouseLocation()
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

-- tracks the REAL left mouse button; clicks the script sends itself are ignored
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

	-- walk up to the model that holds a humanoid
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
				local top = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 2.8, 0))
				local bottom = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
				if top.Z > 0 and bottom.Z > 0 then
					local h = math.abs(bottom.Y - top.Y)
					local w = h * 0.55
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
						box.Position = UDim2.fromOffset((top.X + bottom.X) / 2 - w / 2, math.min(top.Y, bottom.Y))
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

	local result = workspace:Raycast(ray.Origin, ray.Direction * Settings.MouseTPRange, params)
	if not result then
		if toast then toast("Mouse TP  -  nothing in range") end
		return
	end

	-- stand on the surface instead of inside it
	local lift = Vector3.new(0, hum.HipHeight + root.Size.Y / 2, 0)
	local pos = result.Position + result.Normal * 2 + lift
	root.CFrame = CFrame.new(pos) * (root.CFrame - root.CFrame.Position)
	root.AssemblyLinearVelocity = Vector3.zero
end

local vortexRestoreAll, vortexRemote
do
local vortexStates = {}

local function vortexCollides(j)
	return (Settings.VortexCollide and not Settings.Noclip and not j.head) and true or false
end

local function vortexEase(st)
	local b = st.blend
	return b * b * (3 - 2 * b)
end

local function vortexPlace(st, root, ease)
	local joints = st.joints
	local t = os.clock()
	local spin = t * st.speed * 0.5
	local radius = st.radius
	local center = root.Position
	local count = math.max(st.orbitCount, 1)

	local rest = { [root] = root.CFrame }

	for _, j in ipairs(joints) do
		local m = j.motor
		local p0 = m.Part0
		if m.Parent and p0 and j.part.Parent then
			local r = (rest[p0] or p0.CFrame) * j.c0 * m.Transform * j.c1:Inverse()
			rest[j.part] = r

			local cf = r
			if not j.head then
				local sl = j.slot
				local a = spin + (sl / count) * math.pi * 2
				local rad = radius + (sl % 3) * 0.8
				local h = math.sin(t * 1.5 + sl) * 2 + ((sl % 4) - 1.5) * 1.2
				local pos = center + Vector3.new(math.cos(a) * rad, h, math.sin(a) * rad)
				local orbit = CFrame.new(pos) * CFrame.Angles(t * 2 + sl, t * 1.3 + sl * 0.6, t * 1.7)
				cf = r:Lerp(orbit, ease)
			end

			j.part.CFrame = cf
			j.part.AssemblyLinearVelocity = Vector3.zero
			j.part.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function vortexRestore(plr)
	local st = vortexStates[plr]
	if not st then return end

	for _, c in ipairs(st.conns) do
		pcall(function() c:Disconnect() end)
	end
	st.conns = {}

	if st.root and st.root.Parent then
		pcall(vortexPlace, st, st.root, 0)
	end

	for _, j in ipairs(st.joints) do
		pcall(function()
			if j.part.Parent then
				j.part.CanCollide = j.canCollide
				j.part.AssemblyLinearVelocity = Vector3.zero
			end
			if j.motor.Parent then
				j.motor.C0 = j.c0
				j.motor.Enabled = j.enabled
			end
		end)
	end

	for _, c in ipairs(st.ncc) do
		pcall(function() c:Destroy() end)
	end
	st.ncc = {}

	pcall(function()
		if st.hum and st.requiresNeck ~= nil then
			st.hum.RequiresNeck = st.requiresNeck
		end
	end)

	vortexStates[plr] = nil
end

function vortexRestoreAll()
	for plr in pairs(vortexStates) do
		vortexRestore(plr)
	end
end

local function vortexBuild(plr, char, hum, root)
	local st = {
		char = char,
		hum = hum,
		root = root,
		joints = {},
		orbitCount = 0,
		blend = 0,
		dirty = false,
		requiresNeck = nil,
		conns = {},
		ncc = {},
		speed = Settings.VortexSpeed,
		radius = Settings.VortexRadius,
	}
	vortexStates[plr] = st

	local motors = {}
	for _, m in ipairs(char:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 and m.Part1:IsDescendantOf(char) then
			motors[#motors + 1] = m
		end
	end

	local placed = { [root] = true }
	local done = {}
	local slot = 0
	local progress = true
	while progress do
		progress = false
		for _, m in ipairs(motors) do
			if not done[m] and placed[m.Part0] and not placed[m.Part1] then
				done[m] = true
				placed[m.Part1] = true
				progress = true

				local isHead = m.Part1.Name == "Head"
				if not isHead then
					slot += 1
				end
				table.insert(st.joints, {
					motor = m,
					part = m.Part1,
					c0 = m.C0,
					c1 = m.C1,
					enabled = m.Enabled,
					canCollide = m.Part1.CanCollide,
					head = isHead,
					slot = slot,
				})
			end
		end
	end
	st.orbitCount = slot

	if plr == LocalPlayer then
		st.requiresNeck = hum.RequiresNeck
		hum.RequiresNeck = false
	end

	for _, j in ipairs(st.joints) do
		j.motor.Enabled = false
		j.part.CanCollide = vortexCollides(j)
	end

	local headPart
	for _, j in ipairs(st.joints) do
		if j.head then headPart = j.part end
	end
	for _, j in ipairs(st.joints) do
		if not j.head then
			for _, other in ipairs({ root, headPart }) do
				if other then
					local c = Instance.new("NoCollisionConstraint")
					c.Part0 = j.part
					c.Part1 = other
					c.Parent = j.part
					table.insert(st.ncc, c)
				end
			end
		end
	end

	table.insert(st.conns, char.DescendantAdded:Connect(function(d)
		if d:IsA("Motor6D") then
			st.dirty = true
		end
	end))

	return st
end

track(RunService.Stepped:Connect(function()
	for _, st in pairs(vortexStates) do
		if st.char and st.root and st.root.Parent then
			for _, j in ipairs(st.joints) do
				if j.part.Parent then
					j.part.CanCollide = vortexCollides(j)
				end
			end
			vortexPlace(st, st.root, vortexEase(st))
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
	for _, plr in ipairs(Players:GetPlayers()) do
		local want, sp, rad
		if VORTEX_DISABLED then
			want = false
		elseif plr == LocalPlayer then
			want = alive and Settings.FlyVortex
			sp, rad = Settings.VortexSpeed, Settings.VortexRadius
		else
			want = plr:GetAttribute("OULVortex") == true
			sp = math.clamp(tonumber(plr:GetAttribute("OULVortexSpeed")) or 6, 1, 20)
			rad = math.clamp(tonumber(plr:GetAttribute("OULVortexRadius")) or 5, 2, 14)
		end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = (hum and hum.RootPart) or (char and char:FindFirstChild("HumanoidRootPart"))

		local st = vortexStates[plr]
		if st and (st.char ~= char or not root or st.root ~= root) then
			vortexRestore(plr)
			st = nil
		end

		if want and hum and root and hum.Health > 0 then
			if not st then
				st = vortexBuild(plr, char, hum, root)
			elseif st.dirty then
				local keep = st.blend
				vortexRestore(plr)
				st = vortexBuild(plr, char, hum, root)
				st.blend = keep
			end
			st.speed, st.radius = sp, rad
			st.blend = math.min(1, st.blend + dt / 0.5)
		elseif st then
			st.blend = math.max(0, st.blend - dt / 0.5)
			if st.blend <= 0 then
				vortexRestore(plr)
				st = nil
			end
		end

		if st and root then
			vortexPlace(st, root, vortexEase(st))
		end

		if plr == LocalPlayer and vortexStatus then
			local msg
			if VORTEX_DISABLED then
				msg = "disabled"
			elseif not Settings.FlyVortex then
				msg = "off"
			elseif not (hum and root) then
				msg = "waiting for character"
			elseif st and st.orbitCount == 0 then
				msg = "no joints found"
			elseif st then
				msg = "on, " .. st.orbitCount .. " parts"
			else
				msg = "starting"
			end
			vortexStatus.Text = "Vortex: " .. msg
			vortexServerLabel.Text = vortexRemote and "Server: connected" or "Server: not found"
		end
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

track(Players.PlayerRemoving:Connect(vortexRestore))
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
				if b.kind == "menu" then
					toast("The menu key can't be cleared")
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

	if processed then return end

	for _, b in ipairs(Binds) do
		if b.input and inputMatches(input, b.input) then
			if b.kind == "toggle" then
				local t = toggles[b.key]
				if t then t.toggle() end
			elseif b.kind == "menu" then
				setMenuVisible(not menuOpen)
			elseif b.kind == "hold" then
				Settings.Holding = true
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

track(UserInputService.InputEnded:Connect(function(input)
	if inputMatches(input, getBind("aim").input) then
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
	aiming = Settings.Enabled and Settings.Holding and mouseLocked and not menuOpen
	if not aiming then return end

	local target = getTarget()
	if not target then return end

	local s = math.clamp(Settings.Smoothness / 100, 0, 0.98)
	local alpha = 1 - s ^ (dt * 60)

	local goal = CFrame.lookAt(Camera.CFrame.Position, target.Position)
	Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end)

local function cleanup()
	alive = false

	Settings.Enabled = false
	Settings.Holding = false
	Settings.Triggerbot = false
	Settings.ESP = false
	Settings.Chams = false
	Settings.ShowNames = false
	Settings.Tracers = false
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

	pcall(function() espFolder:Destroy() end)
	pcall(function() gui:Destroy() end)
	pcall(function() blur:Destroy() end)
end

shared.OULCleanup = cleanup
