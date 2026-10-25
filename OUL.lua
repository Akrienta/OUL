local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Single instance guard ------------------------------------------------
-- Closes any previous copy of this script (and anything it left behind)
-- before this one starts, so old copies can never affect the new one.
if shared.OULCleanup then
	pcall(shared.OULCleanup)
	shared.OULCleanup = nil
end

do
	pcall(function() RunService:UnbindFromRenderStep("Aimbot") end)
	pcall(function() RunService:UnbindFromRenderStep("AimAssist") end)
	pcall(function() RunService:UnbindFromRenderStep("OULMenuMouse") end)

	-- old menus can live in PlayerGui, CoreGui or the executor's hidden gui folder
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

-- Animation helpers ---------------------------------------------------------
local EASE = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_IN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_OUT = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local THEME_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SLIDE = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local FONT = Enum.Font.RobotoMono -- flat monospace look

local function tween(obj, props, info)
	TweenService:Create(obj, info or EASE, props):Play()
end

-- sets the properties straight away, or tweens them
local function apply(obj, props, animate)
	if animate then
		tween(obj, props)
	else
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
end

-- Theme (changeable from the settings tab) -----------------------------
local Theme = {
	Text = Color3.fromRGB(150, 210, 255),       -- main text
	Switch = Color3.fromRGB(70, 160, 100),      -- checkbox "on" colour
	Accent = Color3.fromRGB(95, 140, 255),      -- sliders, selected tab, selector highlight
	Background = Color3.fromRGB(18, 18, 23),    -- menu background
	Outline = Color3.fromRGB(52, 52, 66),       -- menu / box outlines
	Dim = Color3.fromRGB(110, 165, 210),        -- derived: footer / inactive text
	Field = Color3.fromRGB(34, 34, 42),         -- derived: slider bars, buttons, unchecked boxes
	Group = Color3.fromRGB(22, 22, 28),         -- derived: section boxes
}
local bound = {}          -- every themed property: { obj, prop, fn }
local themeListeners = {} -- extra callbacks (checkbox / selector state etc.)

-- derived colours follow the text / background so every combination stays readable
local function deriveTheme()
	Theme.Dim = Theme.Text:Lerp(Theme.Background, 0.4)
	Theme.Field = Theme.Background:Lerp(Theme.Text, 0.1)
	Theme.Group = Theme.Background:Lerp(Theme.Text, 0.035)
end
deriveTheme()

-- sets obj[prop] = fn() now and again (animated) whenever the theme changes
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

-- Settings -------------------------------------------------------------
local Settings = {
	Enabled = true,       -- master switch (menu toggle), starts on
	Holding = false,      -- true while right click is held
	FOV = 150,            -- pixels
	Smoothness = 1,       -- 1-100 (1 = fastest / snaps on, 100 = slowest)
	Triggerbot = false,   -- auto-shoot when a player is under the crosshair
	TriggerDelay = 50,    -- milliseconds to wait before shooting
	ESP = false,          -- master ESP switch
	Chams = false,        -- chams (highlight fill/outline), needs ESP on
	BlurEnabled = true,   -- background blur while the menu is open
	BlurAmount = 18,      -- 1-56
	ShowNames = false,    -- usernames above players (needs ESP on)
	Tracers = false,      -- lines from the centre of the screen to players (needs ESP on)
	Boxes = false,        -- 2D box around each player (needs ESP on)
	BoxFill = false,      -- see-through fill inside the boxes
	WallCheck = true,
	Watermark = true,     -- OUL / FPS label
	ShowFOV = false,      -- FOV circle visibility
	AimPart = "Head",     -- "Head" or "Body"
	UITransparency = 0,   -- 0-70 (%), how see-through the menu is
	Fly = false,          -- fly on/off
	FlySpeed = 60,        -- studs per second
	FlyVortex = false,    -- body parts swirl around you while flying
	VortexSpeed = 6,      -- 1-20, how fast the parts spin around you
	VortexRadius = 5,     -- 2-14 studs, how wide the vortex is
	VortexCollide = false, -- the swirling parts are solid (can push / block things)
	Noclip = false,       -- walk through walls and other solid things
	Speed = false,        -- change your walk speed
	SpeedValue = 40,      -- 16-250, the walk speed used while Speed is on
	InfiniteJump = false, -- jump again in mid-air
	Notifications = true, -- little pop-ups when a setting is switched on / off
}

local setESPEnabled

-- Vortex is switched off for now: it can't be turned on, and its page is shaded.
-- To bring it back later, set this to false and remove the shade in the vortex page.
local VORTEX_DISABLED = true
local LockedSettings = { FlyVortex = true } -- checkboxes that ignore clicks

-- Names shown in notifications and in the keybind list
local DisplayNames = {
	Enabled = "Aimbot", ShowFOV = "FOV Circle", Triggerbot = "Triggerbot",
	ESP = "ESP", Chams = "Chams", ShowNames = "Usernames", Tracers = "Tracers",
	Boxes = "Boxes", BoxFill = "Box Fill", Fly = "Fly", FlyVortex = "Vortex",
	Noclip = "Noclip", Speed = "Speed", InfiniteJump = "Infinite Jump",
	Watermark = "Watermark", BlurEnabled = "Background Blur", Notifications = "Notifications",
}

-- Keybinds ---------------------------------------------------------------------
-- Every switch in the menu can have a key. "toggle" binds flip a setting, "hold" is
-- the aim button (active while held) and "menu" shows / hides the menu.
-- A bind's input is a KeyCode, a mouse button (MouseButton2 / 3) or nil (no key).
local Binds = {}
local function defBind(id, label, kind, key, input)
	Binds[#Binds + 1] = { id = id, label = label, kind = kind, key = key, input = input, default = input }
end
defBind("menu", "Menu", "menu", nil, Enum.KeyCode.End)
defBind("aim", "Aim (hold)", "hold", nil, Enum.UserInputType.MouseButton2)
for _, k in ipairs({
	"Enabled", "ShowFOV", "Triggerbot", "ESP", "Chams", "ShowNames", "Tracers", "Boxes",
	"BoxFill", "Fly", "Noclip", "Speed", "InfiniteJump", "Watermark", "BlurEnabled", "Notifications",
}) do
	local default
	if k == "Triggerbot" then default = Enum.KeyCode.P end
	if k == "Fly" then default = Enum.KeyCode.Equals end
	if k == "Noclip" then default = Enum.KeyCode.N end
	defBind(k, DisplayNames[k], "toggle", k, default)
end

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

-- labels that show a key (footer, info notes) and rewrite themselves when a key changes
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

local rebinding = nil   -- the bind that is waiting for a key press
local bindButtons = {}  -- [bind id] = the button that shows its key
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

local toggles = {} -- [Settings key] = { toggle = function } for every checkbox (used by keybinds)
local notify -- notify(name, on) pop-up; set once the menu exists
local toast  -- toast(text) general pop-up; set once the menu exists
local vortexStatus, vortexServerLabel -- little status lines in the Fly tab

-- ESP / Chams -----------------------------------------------------------
-- Uses Highlight instances (visible through walls). Roblox only draws about
-- 31 highlights at once and picks which ones arbitrarily, which is why some
-- players used to be missed in busy servers. To fix that, only the closest
-- players (up to MAX_HIGHLIGHTS) are enabled, so nearby players always show.
local MAX_HIGHLIGHTS = 30
local ESPColors = {
	Fill = Color3.fromRGB(255, 70, 70),      -- cham fill
	Outline = Color3.fromRGB(255, 255, 255), -- cham outline
	Tracer = Color3.fromRGB(255, 70, 70),    -- tracer lines
	Name = Color3.fromRGB(255, 255, 255),    -- username text
	Box = Color3.fromRGB(255, 255, 255),     -- box outline
	BoxFill = Color3.fromRGB(255, 70, 70),   -- box fill
}

-- Saving ---------------------------------------------------------------------------
-- Your choices (switches, sliders, colours and keybinds) are loaded here once at start-up,
-- before the menu is built, and saved again about a second after anything changes.
-- With an executor they go in a local file; in a normal game they go through the
-- OULSaveServer script into a DataStore (without that script nothing is saved).
local FOVColor = Color3.fromRGB(255, 255, 255) -- colour of the FOV circle
local persistOK = false -- true once the server has loaded this player's data
local saveStatusText = "saving: connecting..." -- shown in Settings > General
local saveStatusLabel -- that label (set when the settings page is built)
local saveNowFn = function() end -- the "Save now" button; replaced once saving works

-- (everything else lives in a do-block to keep the script under Luau's 200-locals limit)
do
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SAVE_BOOLS = {
	"Enabled", "Triggerbot", "ESP", "Chams", "BlurEnabled", "ShowNames", "Tracers",
	"Boxes", "BoxFill", "Watermark", "ShowFOV", "Fly", "Noclip", "Speed",
	"InfiniteJump", "Notifications",
}
local SAVE_NUMBERS = {
	FOV = { 20, 500 }, Smoothness = { 1, 100 }, TriggerDelay = { 0, 300 },
	BlurAmount = { 1, 56 }, UITransparency = { 0, 70 }, FlySpeed = { 5, 250 },
	VortexSpeed = { 1, 20 }, VortexRadius = { 2, 14 }, SpeedValue = { 16, 250 },
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

-- "" = no key, "K:<KeyCode name>", "M:MouseButton2" / "M:MouseButton3"
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
	local snap = { v = 1, settings = {}, theme = {}, esp = {}, binds = {} }
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

	local t = type(d.theme) == "table" and d.theme or {}
	for _, k in ipairs(SAVE_THEME) do
		local c = arrToColor(t[k])
		if c then Theme[k] = c end
	end
	deriveTheme()

	local e = type(d.esp) == "table" and d.esp or {}
	for _, k in ipairs(SAVE_ESP) do
		local c = arrToColor(e[k])
		if c then ESPColors[k] = c end
	end
	FOVColor = arrToColor(d.fov) or FOVColor

	local b = type(d.binds) == "table" and d.binds or {}
	for _, bind in ipairs(Binds) do
		local v = b[bind.id]
		if v == "" then
			if bind.kind ~= "menu" then bind.input = nil end -- the menu key can't be cleared
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

-- Two ways to save, picked automatically:
--   1. Executor file functions (readfile / writefile), if they exist: your settings go
--      in a local file named after your user id, so no server script is needed.
--   2. Otherwise the OULSaveServer script and a DataStore (needs the game to have it).
local hasFiles = type(readfile) == "function" and type(writefile) == "function"
local FILE_NAME = "OULMenu_" .. tostring(LocalPlayer.UserId) .. ".json"

local manualPending = false -- a "Save now" press is waiting for the server's answer

if hasFiles then
	-- load
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
		-- the server tells us whether each write worked
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
end -- saving

-- holds the username tags (local only, outside the characters)
local espFolder = Instance.new("Folder")
espFolder.Name = "OULESP"
espFolder.Parent = workspace
local highlights = {} -- [Player] = Highlight
local nameTags = {}   -- [Player] = BillboardGui

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
	h.Parent = char -- must live in the character: highlights parented elsewhere did not draw
	highlights[plr] = h
end

-- Re-creates missing highlights and enables only the closest players
local function refreshESP()
	local cam = workspace.CurrentCamera
	local camPos = cam and cam.CFrame.Position or Vector3.zero
	local list = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			if char then
				local h = highlights[plr]
				if not h or not h.Parent or h.Adornee ~= char then
					applyESP(plr, char)
					h = highlights[plr]
				end
				-- username tag
				local head = char:FindFirstChild("Head")
				local tag = nameTags[plr]
				if head and (not tag or not tag.Parent or tag.Adornee ~= head) then
					applyTag(plr, char)
					tag = nameTags[plr]
				end
				if tag then
					tag.Enabled = Settings.ESP and Settings.ShowNames
				end

				local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
				local dist = root and (root.Position - camPos).Magnitude or math.huge
				if h then
					table.insert(list, { h = h, dist = dist })
				end
			else
				removeESP(plr) -- no character right now (respawning); it is re-added when one exists
			end
		end
	end

	table.sort(list, function(a, b)
		return a.dist < b.dist
	end)
	for i, item in ipairs(list) do
		item.h.Enabled = Settings.ESP and Settings.Chams and i <= MAX_HIGHLIGHTS
	end
end

local function trackPlayer(plr)
	if plr == LocalPlayer then return end
	track(plr.CharacterAdded:Connect(function(char)
		-- apply straight away, then again once the body has loaded
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

-- Keeps chams up to date (new joins, respawns, streaming, distance changes)
task.spawn(function()
	while alive do
		task.wait(0.25)
		local ok, err = pcall(refreshESP)
		if not ok then
			warn("[OUL esp] " .. tostring(err))
		end
	end
end)

-- UI -------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999        -- drawn above every other ScreenGui
pcall(function() gui.OnTopOfCoreBlur = true end) -- also drawn above the Roblox menu blur

-- Parent to CoreGui / the executor's hidden gui folder so the menu stays on top of the
-- Roblox escape menu and other core UI. A normal LocalScript is not allowed to do that,
-- so it falls back to PlayerGui (which the Roblox menu always draws over).
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

-- FOV circle
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

-- small helpers -------------------------------------------------------------
local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

-- a 1px outline whose colour follows the theme
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

-- layout numbers
local SIDE_W = 96                  -- width of the tab sidebar on the left
local PANEL_W = SIDE_W + 440
local TITLE_H = 28
local TAB_ROW = 30                 -- height of one tab in the sidebar
local PAGE_X = SIDE_W + 8
local PAGE_Y = TITLE_H + 8
local FOOTER_H = 18

-- Main panel (a CanvasGroup, so the whole menu can fade as one piece) -------
local panel = Instance.new("CanvasGroup")
panel.Size = UDim2.fromOffset(PANEL_W, 300)
-- starts in the middle of the screen (refined below once the real height is known)
do
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	panel.Position = UDim2.fromOffset(math.floor((vp.X - PANEL_W) / 2), math.floor((vp.Y - 300) / 2))
end
panel.BorderSizePixel = 0
panel.Active = true
panel.ZIndex = 100 -- above tracers and boxes, which are drawn at the default level
panel.GroupTransparency = 1
panel.Visible = false
panel.Parent = gui
bind(panel, "BackgroundColor3", function()
	return Theme.Background
end)
corner(panel, 5)
outline(panel)

-- thin accent line across the top
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BorderSizePixel = 0
topLine.ZIndex = 5
topLine.Parent = panel
bind(topLine, "BackgroundColor3", function()
	return Theme.Accent
end)

-- title bar (drag the menu by it)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = panel

local title = newLabel(titleBar, "OUL", 15)
title.Position = UDim2.new(0, 12, 0, 2)
title.Size = UDim2.new(1, -24, 1, -2)
pcall(function()
	title.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)

-- tab bar ---------------------------------------------------------------------
local TAB_NAMES = { "combat", "visuals", "movement", "settings" }
local TAB_LABELS = { combat = "Combat", visuals = "Visuals", movement = "Movement", settings = "Settings" } -- what the tabs show
-- tabs that have sub-sections (a row of small tabs at the top of the page)
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
	movement = { { id = "fly", label = "Fly" }, { id = "vortex", label = "Vortex", disabled = true }, { id = "noclip", label = "Noclip" }, { id = "speed", label = "Speed" }, { id = "jump", label = "Jump" } },
}
local SUB_H = 26 -- height of the sub-tab row
local SUB_W = 80 -- width of one sub-tab
-- the tabs sit in a sidebar down the left side
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, SIDE_W, 1, -(TITLE_H + FOOTER_H))
tabBar.Position = UDim2.fromOffset(0, TITLE_H)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel

-- line under the title bar
local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.fromOffset(0, TITLE_H)
titleLine.BorderSizePixel = 0
titleLine.Parent = panel
bind(titleLine, "BackgroundColor3", function()
	return Theme.Outline
end)

-- line between the sidebar and the pages
local tabLine = Instance.new("Frame")
tabLine.Size = UDim2.new(0, 1, 1, -(TITLE_H + FOOTER_H))
tabLine.Position = UDim2.fromOffset(SIDE_W, TITLE_H)
tabLine.BorderSizePixel = 0
tabLine.Parent = panel
bind(tabLine, "BackgroundColor3", function()
	return Theme.Outline
end)

-- accent bar that slides up / down beside the selected tab
local underline = Instance.new("Frame")
underline.Size = UDim2.fromOffset(2, TAB_ROW - 8)
underline.Position = UDim2.fromOffset(0, 11)
underline.BorderSizePixel = 0
underline.ZIndex = 3
underline.Parent = tabBar
bind(underline, "BackgroundColor3", function()
	return Theme.Accent
end)

-- footer hint
local footer = newLabel(panel, "", 11, true)
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, PAGE_X, 1, -5)
footer.Size = UDim2.new(1, -(PAGE_X + 8), 0, 12)
addHint(footer, function()
	return keyName(getBind("menu").input) .. "  -  hide / show menu"
end)

-- OUL + FPS counter (always visible, draggable) -------------------------------
local hud = Instance.new("TextLabel")
hud.Size = UDim2.fromOffset(132, 22)
hud.AnchorPoint = Vector2.new(1, 0)
hud.Position = UDim2.new(1, -10, 0, 8)
hud.BackgroundTransparency = 0.15
hud.BorderSizePixel = 0
hud.Text = "OUL  |  FPS : --"
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

-- Make the OUL / FPS label draggable
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
			dragging = false
		end
	end))
end

-- FPS counter
do
	local frames, elapsed = 0, 0
	track(RunService.RenderStepped:Connect(function(dt)
		frames += 1
		elapsed += dt
		if elapsed >= 0.5 then
			hud.Text = "OUL  |  FPS : " .. math.floor(frames / elapsed + 0.5)
			frames, elapsed = 0, 0
		end
	end))
end

-- Dragging the panel by its title bar
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

-- Notifications --------------------------------------------------------------------
-- Small pop-ups in the bottom right: "Triggerbot  ON" / "OFF". They slide in, wait a
-- moment and fade out. Turn them off with Settings > General > Notifications.
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

-- Background blur (only while the menu is open) ---------------------------
local blur = Lighting:FindFirstChild("OULMenuBlur") or Instance.new("BlurEffect")
blur.Name = "OULMenuBlur"
blur.Size = 0
blur.Parent = Lighting
local blurInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- While the menu is open the mouse is freed, even in shift lock / first person.
-- The game's camera script locks the mouse every frame, so this runs after it
-- (last in the frame) and sets the mouse free again. The invisible Modal button is
-- the standard Roblox way to unlock the mouse and is kept as a second method.
local menuOpen = false
local menuToken = 0
local prevMouseBehavior, prevMouseIcon

-- Blur is only applied while the menu is open (and the blur switch is on)
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
		-- hand the mouse back to the game
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

-- Pages and boxes -----------------------------------------------------------
-- Each tab is a page with two columns. A column stacks "group boxes" (a title and
-- a list of controls). Everything sizes itself, so adding a control just works.
local refreshers = {} -- [Settings key] = function that redraws that checkbox (used by hotkeys)
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

-- a titled box inside a column; returns the frame that controls are added to
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

-- Controls ---------------------------------------------------------------------

-- small dim text line
local function addNote(parent, text)
	local l = newLabel(parent, text, 11, true)
	l.Size = UDim2.new(1, 0, 0, 14)
	l.LayoutOrder = nextOrder(parent)
	return l
end

-- checkbox
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

	-- one place that flips the setting, used by clicks and by keybinds
	local function toggleSetting()
		if LockedSettings[key] then return end -- locked (disabled feature)
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

-- slider: the bar itself carries the text, like "FOV: 150"
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

-- two-option selector (the highlight slides between the options)
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

-- flat button
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

-- Colour rows -------------------------------------------------------------------
-- A label with a colour box on the right. Click it and a palette (16 swatches +
-- a rainbow bar for any colour) slides open underneath.
local PALETTE = {
	Color3.fromRGB(255, 255, 255), -- white
	Color3.fromRGB(255, 70, 70),   -- red
	Color3.fromRGB(255, 160, 60),  -- orange
	Color3.fromRGB(255, 205, 60),  -- gold
	Color3.fromRGB(255, 230, 80),  -- yellow
	Color3.fromRGB(170, 230, 70),  -- lime
	Color3.fromRGB(90, 220, 120),  -- green
	Color3.fromRGB(150, 240, 170), -- mint
	Color3.fromRGB(60, 200, 200),  -- teal
	Color3.fromRGB(80, 220, 255),  -- cyan
	Color3.fromRGB(120, 180, 255), -- sky
	Color3.fromRGB(95, 140, 255),  -- blue
	Color3.fromRGB(160, 100, 255), -- purple
	Color3.fromRGB(230, 90, 230),  -- magenta
	Color3.fromRGB(255, 120, 200), -- pink
	Color3.fromRGB(170, 170, 185), -- grey
}

-- dark and light backgrounds for the menu
local BACKGROUNDS = {
	Color3.fromRGB(18, 18, 23),    -- charcoal (default)
	Color3.fromRGB(8, 8, 10),      -- black
	Color3.fromRGB(30, 30, 30),    -- graphite
	Color3.fromRGB(48, 48, 56),    -- slate
	Color3.fromRGB(16, 24, 44),    -- navy
	Color3.fromRGB(14, 30, 48),    -- ocean
	Color3.fromRGB(26, 32, 52),    -- night
	Color3.fromRGB(20, 40, 44),    -- deep teal
	Color3.fromRGB(16, 36, 30),    -- forest
	Color3.fromRGB(40, 26, 16),    -- brown
	Color3.fromRGB(44, 20, 24),    -- maroon
	Color3.fromRGB(44, 16, 40),    -- plum
	Color3.fromRGB(32, 20, 48),    -- purple
	Color3.fromRGB(60, 36, 60),    -- mauve
	Color3.fromRGB(210, 216, 230), -- silver
	Color3.fromRGB(235, 238, 245), -- light
}

-- the palette with `default` as the first swatch (so the default shows as selected)
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

local GRID_W = 8 * 18 + 7 * 5 -- eight swatches per line
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

	-- palette (slides open / closed)
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

	local marker -- rainbow bar marker, hidden when a swatch is picked
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

	-- rainbow bar: click or drag to pick any colour
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

	-- open / close
	local open = false
	head.MouseButton1Click:Connect(function()
		open = not open
		tween(pal, { Size = UDim2.new(1, 0, 0, open and PAL_H or 0) }, SLIDE)
	end)

	-- mark the default colour as selected
	for i, color in ipairs(colors) do
		if color == default then
			selectSwatch(i, false)
		end
	end
	return holder
end

-- Tabs ------------------------------------------------------------------------------
local tabButtons = {}
local tabIndex = {}
local subButtons = {} -- [tab id][sub id] = button
local subIndex = {}   -- [tab id][sub id] = position in the row
local subPos = {}     -- [tab id][sub id] = { x, w } of its button in the row
local subBars = {}    -- [tab id] = { frame, line }

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
	-- never shorter than the sidebar needs
	local pageH = math.max(pageHeight(cur) + cur.subOffset, #TAB_NAMES * TAB_ROW + 8)
	local target = UDim2.fromOffset(PANEL_W, PAGE_Y + pageH + FOOTER_H + 8)
	if animate then
		tween(panel, { Size = target }, SLIDE)
	else
		panel.Size = target
	end
end

-- opens a tab (and one of its sub-sections, if it has any)
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

	-- the sidebar bar
	local idx = tabIndex[tabId]
	local pos = UDim2.fromOffset(0, 8 + (idx - 1) * TAB_ROW + 3)
	if instant then
		underline.Position = pos
	else
		tween(underline, { Position = pos }, SLIDE)
	end

	-- the sub-tab row (only shown for tabs that have one)
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

-- sub-tab rows (Combat: Aimbot / Triggerbot, Visuals: ESP / Colours)
for tabId, subs in pairs(SUBTABS) do
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
	line.Size = UDim2.fromOffset(SUB_W - 12, 2)
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
		subPos[tabId][sub.id] = { x = x, w = SUB_W }
		local sb = Instance.new("TextButton")
		sb.Size = UDim2.fromOffset(SUB_W, SUB_H - 8)
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

		x = x + SUB_W
	end
	subBars[tabId] = { frame = bar, line = line }
end

onTheme(function()
	refreshTabs(true)
end)

-- Build the pages ---------------------------------------------------------------------
local WHITE = Color3.fromRGB(255, 255, 255)
local RED = Color3.fromRGB(255, 70, 70)

-- combat > aimbot
local aimPage = newPage("combat_aimbot", true)
do
	local g = newGroup(aimPage, 1, "Aimbot")
	addCheckbox(g, "Enabled", "Enabled")
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
end

-- combat > triggerbot
local trigPage = newPage("combat_trigger", true)
do
	local t = newGroup(trigPage, 1, "Triggerbot")
	addCheckbox(t, "Enabled", "Triggerbot")
	addSlider(t, "Delay (ms)", 0, 300, "TriggerDelay")

	local info = newGroup(trigPage, 2, "Info")
	addHint(addNote(info, ""), function()
		return keyName(getBind("Triggerbot").input) .. "  -  triggerbot on / off"
	end)
	addNote(info, "range: 1000 studs")
	addNote(info, "needs mouse lock")
end

-- placeholder pages for features that are still being built
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

-- combat > silent aim (in development)
addPlaceholderPage("combat_silent", "Silent Aim")

-- combat > antikatana (in development)
addPlaceholderPage("combat_antikatana", "Antikatana")

-- combat > ragebot (in development)
addPlaceholderPage("combat_ragebot", "Ragebot")

-- visuals > esp
local espPage = newPage("visuals_esp", true)
do
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

	local info = newGroup(espPage, 2, "Info")
	addNote(info, "chams show through walls")
	addNote(info, "everything needs ESP on")
	addNote(info, "boxes: outline + optional")
	addNote(info, "see-through fill")
	addNote(info, "colours are in Colours")
end

-- visuals > colours
local colPage = newPage("visuals_colours", true)
do
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

-- movement > fly
local flyPage = newPage("movement_fly", true)
do
	local g = newGroup(flyPage, 1, "Fly")
	addCheckbox(g, "Enabled", "Fly")
	addSlider(g, "Speed", 5, 250, "FlySpeed")

	local k = newGroup(flyPage, 2, "Controls")
	addNote(k, "W A S D  -  move")
	addNote(k, "Space  -  up")
	addNote(k, "Ctrl  -  down")
	addHint(addNote(k, ""), function()
		return keyName(getBind("Fly").input) .. "  -  fly on / off"
	end)
end

-- movement > vortex
local vortexPage = newPage("movement_vortex", true)
do
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
		-- dark shade over the whole section; being a button, it also blocks clicks
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

		-- red "Disabled" label, centered on the page
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

-- movement > speed
local speedPage = newPage("movement_speed", true)
do
	local g = newGroup(speedPage, 1, "Speed")
	addCheckbox(g, "Enabled", "Speed")
	addSlider(g, "Walk Speed", 16, 250, "SpeedValue")

	local info = newGroup(speedPage, 2, "Info")
	addNote(info, "changes your walk speed")
	addNote(info, "normal speed comes back")
	addNote(info, "when you switch it off")
end

-- movement > jump
local jumpPage = newPage("movement_jump", true)
do
	local g = newGroup(jumpPage, 1, "Infinite Jump")
	addCheckbox(g, "Enabled", "InfiniteJump")

	local info = newGroup(jumpPage, 2, "Info")
	addNote(info, "jump again in mid-air")
	addNote(info, "just press jump")
end

-- movement > noclip
local noclipPage = newPage("movement_noclip", true)
do
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

-- settings tab
local settingsPage = newPage("settings_general", true)
do
	local m = newGroup(settingsPage, 1, "Menu")
	addSlider(m, "UI Transparency", 0, 70, "UITransparency", function(v)
		if menuOpen then
			panel.GroupTransparency = v / 100
		end
	end)
	addCheckbox(m, "Watermark", "Watermark", function(on)
		hud.Visible = on
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

-- settings > keybinds
local keyPage = newPage("settings_keybinds", true)
do
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
	for _, id in ipairs({ "aim", "Enabled", "ShowFOV", "Triggerbot" }) do
		addKeybindRow(c, id)
	end

	local mv = newGroup(keyPage, 1, "Movement")
	for _, id in ipairs({ "Fly", "Noclip", "Speed", "InfiniteJump" }) do
		addKeybindRow(mv, id)
	end

	local v = newGroup(keyPage, 2, "Visuals")
	for _, id in ipairs({ "ESP", "Chams", "ShowNames", "Tracers", "Boxes", "BoxFill" }) do
		addKeybindRow(v, id)
	end

	local m = newGroup(keyPage, 2, "Menu")
	for _, id in ipairs({ "menu", "Watermark", "BlurEnabled", "Notifications" }) do
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

-- Every page is shown (but see-through) for one frame so the layouts can measure
-- themselves, then the other pages are hidden and the panel is sized to the first tab.
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

		-- centre the menu now that its real height is known
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

-- Core logic -------------------------------------------------------------
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
		return char:FindFirstChild("Head")
	end
	return char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("HumanoidRootPart")
end

-- Players further away than this are ignored by the aimbot (keeps it off the lobby)
local MAX_AIM_DISTANCE = 1000 -- studs

local function getTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local best, bestDist = nil, Settings.FOV

	-- distance is measured from your character (or the camera if you have none)
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or Camera.CFrame.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local part = char and getAimPart(char)
			if hum and hum.Health > 0 and part
				and (part.Position - origin).Magnitude <= MAX_AIM_DISTANCE then
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist < bestDist and isVisible(part, char) then
						best, bestDist = part, dist
					end
				end
			end
		end
	end
	return best
end

-- Triggerbot ---------------------------------------------------------------
-- Casts a ray through the cursor. If a living player is the first thing hit, it
-- waits TriggerDelay ms, then activates the tool you are holding.
-- Like the aimbot, it only works while the mouse is locked, so with a free cursor
-- (the lobby, menus) it never fires.
local triggerSeenAt = nil
local lastShot = 0

local function playerUnderCrosshair()
	local cam = workspace.CurrentCamera
	local m = UserInputService:GetMouseLocation()
	local ray = cam:ViewportPointToRay(m.X, m.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * MAX_AIM_DISTANCE, params)
	if not result then return nil end

	-- walks up from the part hit (works for accessories too)
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local plr = model and Players:GetPlayerFromCharacter(model)
	local hum = model and model:FindFirstChildOfClass("Humanoid")
	if plr and plr ~= LocalPlayer and hum and hum.Health > 0 then
		return plr
	end
	return nil
end

-- Fires a left click. No tool is needed: it tries an executor click first, then
-- VirtualInputManager, and only uses tool:Activate() if neither is available.
local function fireClick()
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

-- Tracers ----------------------------------------------------------------
-- A line from the centre of the screen to every other player within 1000 studs, including players behind you. Built from
-- thin rotated Frames, so it works without the Drawing library. The colour comes
-- from the Tracer Color row in ESP Colours. Needs ESP and Tracers both switched on.
local tracerLines = {} -- [Player] = Frame
local TRACER_MAX_DISTANCE = 1000 -- studs: players further away get no tracer

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

	-- distance is measured from your character (or the camera if you have none)
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local line = tracerLines[plr]
			local shown = false

			if hum and root and hum.Health > 0
				and (root.Position - origin).Magnitude <= TRACER_MAX_DISTANCE then
				local p = cam:WorldToViewportPoint(root.Position)

				-- direction of the line on screen
				local delta
				if p.Z > 0 then
					delta = Vector2.new(p.X, p.Y) - from -- in front: straight to the player
				else
					-- behind you the screen position is mirrored, so work it out from the
					-- camera instead: the line points the way the player is and runs off the edge
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

-- Boxes --------------------------------------------------------------------
-- A 2D box around every other player, sized from their position on screen. Made from
-- a Frame with an outline, so it needs no Drawing library. The fill is a see-through
-- version of the same Frame. Needs ESP and Boxes both switched on.
local boxFrames = {} -- [Player] = Frame

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

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local box = boxFrames[plr]
			local shown = false

			if hum and root and hum.Health > 0 then
				local top = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 2.8, 0))
				local bottom = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
				if top.Z > 0 and bottom.Z > 0 then -- only players in front of the camera
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

-- Fly ----------------------------------------------------------------------
-- While Fly is on you move through the air with W A S D (relative to where the
-- camera looks), Space goes up and Left Control goes down. Speed comes from the
-- Fly tab. The character is set to PlatformStand so its animations don't fight the
-- movement, and everything goes back to normal when Fly is switched off.
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

		-- ignore the movement keys while typing in a text box (chat etc.)
		local dir = UserInputService:GetFocusedTextBox() and Vector3.new(0, 0, 0) or flyDirection()
		root.AssemblyLinearVelocity = dir * Settings.FlySpeed
		root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		-- stay upright and face the way the camera looks
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

-- Speed ----------------------------------------------------------------------
-- While Speed is on, your Humanoid's WalkSpeed is set every frame (games often reset
-- it). Switching it off puts back the speed you had before.
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

-- Infinite jump ---------------------------------------------------------------
-- Every time you press jump (even in mid-air) the Humanoid is told to jump again.
track(UserInputService.JumpRequest:Connect(function()
	if not Settings.InfiniteJump then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

-- Noclip ---------------------------------------------------------------------
-- While Noclip is on, every solid part of your character is made non-solid each
-- physics step (the Humanoid keeps turning them back on, so it has to be repeated),
-- which lets you walk straight through walls. You still stand on the floor, because
-- the Humanoid holds you up with a ray rather than with your parts. Switching it off
-- puts back only the parts that were solid before.
local noclipOrig = {} -- [BasePart] = true for every part noclip turned non-solid

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

-- Vortex mode ----------------------------------------------------------------
-- While Vortex Mode is on (Fly is not needed), every body part except the head swirls
-- around you. Each joint (Motor6D) is switched off and the parts are placed
-- directly every frame, which works on R6, R15 and custom rigs. The head stays
-- at its normal position so the camera doesn't move. Everything is put back
-- when the effect ends (or on respawn).
--
-- Other players: the VortexServer script stores your on/off state as attributes on
-- your Player, and every player's menu runs this same effect for anyone who has it
-- on. Without that script you still see your own vortex, but nobody else does.
local vortexStates = {} -- [Player] = state

-- the swirling parts are only solid when Vortex Collision is on (the head never is)
local function vortexCollides(j)
	return (Settings.VortexCollide and not Settings.Noclip and not j.head) and true or false
end

local function vortexEase(st)
	local b = st.blend
	return b * b * (3 - 2 * b)
end

-- places every part: the normal animated pose blended with the swirl
local function vortexPlace(st, root, ease)
	local joints = st.joints
	local t = os.clock()
	local spin = t * st.speed * 0.5
	local radius = st.radius
	local center = root.Position
	local count = math.max(st.orbitCount, 1)

	local rest = { [root] = root.CFrame } -- where each part is with a normal body

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

	-- put every part back in its normal pose BEFORE reconnecting the joints (no snap)
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

local function vortexRestoreAll()
	for plr in pairs(vortexStates) do
		vortexRestore(plr)
	end
end

local function vortexBuild(plr, char, hum, root)
	local st = {
		char = char,
		hum = hum,
		root = root,
		joints = {},        -- ordered from the root outwards
		orbitCount = 0,     -- how many parts swirl (everything except the head)
		blend = 0,          -- 0 = normal body, 1 = full vortex
		dirty = false,      -- a joint was added, rebuild the list
		requiresNeck = nil, -- original Humanoid.RequiresNeck value
		conns = {},
		ncc = {},           -- NoCollisionConstraints that stop parts shoving your own body
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

	-- order the joints from the root outwards, so a part's parent is always placed first
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

	-- R15 kills your character if the neck joint is broken, so turn that off while active
	if plr == LocalPlayer then
		st.requiresNeck = hum.RequiresNeck
		hum.RequiresNeck = false
	end

	-- switch the joints off: from now on the parts are positioned directly
	for _, j in ipairs(st.joints) do
		j.motor.Enabled = false
		j.part.CanCollide = vortexCollides(j)
	end

	-- the swirling parts never collide with your own root or head (so they can't shove you)
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

	-- if a joint is added later (the rig finishes loading, a morph), rebuild the list
	table.insert(st.conns, char.DescendantAdded:Connect(function(d)
		if d:IsA("Motor6D") then
			st.dirty = true
		end
	end))

	return st
end

-- Runs before physics each step: keeps collisions off (the Humanoid turns them back
-- on) and places the parts so physics never gets a chance to drag them away.
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

-- tells the server about your vortex state so other players can see it
local vortexRemote
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
			vortexRestore(plr) -- respawned or lost the character
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

-- Key presses: keybind capture (Settings > Keybinds), then every bound key.
-- Keys are not used while typing in chat (processed), except while capturing a new one.
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
				newInput = false -- clear the key
			elseif input.KeyCode ~= Enum.KeyCode.Unknown then
				newInput = input.KeyCode
			else
				return
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then
			newInput = input.UserInputType
		else
			return -- left click is for the menu itself, other inputs are ignored
		end

		-- a key can only belong to one switch, so take it away from any other
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

	if processed then return end -- typing in chat, etc.

	for _, b in ipairs(Binds) do
		if b.input and inputMatches(input, b.input) then
			if b.kind == "toggle" then
				local t = toggles[b.key]
				if t then t.toggle() end
			elseif b.kind == "menu" then
				setMenuVisible(not menuOpen)
			elseif b.kind == "hold" then
				Settings.Holding = true
			end
		end
	end
end))

-- Camera restore: if the camera gets teleported right after aiming ends,
-- put the rotation back to where the aimbot ended.
local RETURN_WINDOW = 1.0            -- seconds after aiming ends that snap-backs are blocked
local JUMP_ANGLE = math.rad(25)      -- a one-frame camera change bigger than this counts as a teleport
local aimEndedAt = 0
local savedCFrame = nil

-- The aimbot only works while the mouse is locked (shift lock, first person, or a game
-- that holds the cursor at the centre). With a free cursor it does nothing.
local aiming = false -- true on frames where the aimbot is actually applied

track(UserInputService.InputEnded:Connect(function(input)
	if inputMatches(input, getBind("aim").input) then
		if aiming then
			aimEndedAt = os.clock()
			savedCFrame = workspace.CurrentCamera.CFrame -- where the aimbot ended
		end
		Settings.Holding = false
	end
end))

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
	Camera = workspace.CurrentCamera

	-- keep FOV circle on the cursor
	local m = UserInputService:GetMouseLocation()
	circle.Position = UDim2.fromOffset(m.X, m.Y)
	circle.Visible = Settings.Enabled and Settings.ShowFOV

	-- restore the aim position if the camera gets teleported after aiming ends
	if savedCFrame and not Settings.Holding then
		if os.clock() - aimEndedAt > RETURN_WINDOW then
			savedCFrame = nil
		else
			local cur = Camera.CFrame
			local angle = math.acos(math.clamp(cur.LookVector:Dot(savedCFrame.LookVector), -1, 1))
			local mouseMoved = UserInputService:GetMouseDelta().Magnitude

			if angle > JUMP_ANGLE and mouseMoved < 2 then
				-- keep the current position, put the rotation back to where the aimbot ended
				Camera.CFrame = CFrame.new(cur.Position) * (savedCFrame - savedCFrame.Position)
			else
				savedCFrame = cur -- normal movement, keep following it
			end
		end
	end

	-- only apply while the mouse is locked (not free, and not while the menu is open)
	local mouseLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
	aiming = Settings.Enabled and Settings.Holding and mouseLocked and not menuOpen
	if not aiming then return end

	local target = getTarget()
	if not target then return end

	-- frame-rate independent smoothing
	local s = math.clamp(Settings.Smoothness / 100, 0, 0.98)
	local alpha = 1 - s ^ (dt * 60)

	local goal = CFrame.lookAt(Camera.CFrame.Position, target.Position)
	Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end)

-- Cleanup (called automatically if this script is started again) ---------
local function cleanup()
	alive = false

	-- switch every feature off
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

	-- give back your normal walk speed
	pcall(function()
		if speedHum and speedHum.Parent then speedHum.WalkSpeed = speedOrig end
	end)

	-- make solid parts solid again
	pcall(noclipRestore)

	-- put the body parts back and tell the server to stop
	pcall(vortexRestoreAll)
	pcall(function()
		if vortexRemote then
			vortexRemote:FireServer(false, Settings.VortexSpeed, Settings.VortexRadius)
		end
	end)

	-- stop flying: give the character back its normal physics
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

	-- hand the mouse back to the game if the menu was open
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
