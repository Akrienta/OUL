local _0x8325 = game:GetService("Players")
local _0x2C20 = game:GetService("RunService")
local _0x85F6 = game:GetService("UserInputService")
local _0x4BE0 = game:GetService("TweenService")
local _0x1F4A = game:GetService("Lighting")
if _0x2C20:IsServer() then
local _0xF6C1 = game:GetService("ReplicatedStorage")
local _0xE192 = _0xF6C1:FindFirstChild("OULVortexEvent")
if not _0xE192 then
_0xE192 = Instance.new("RemoteEvent")
_0xE192.Name ="OULVortexEvent"_0xE192.Parent = _0xF6C1
end
_0xF6C1:SetAttribute("OULVortexServerSide", true)
local _0x5BF0 = {}
local _0x1B79 = {}
local _0x7088 = {}
_0xE192.OnServerEvent:Connect(function(player, _0xD32A, speed, radius)
local _0x67E0 = os.clock()
if _0x7088[player] and _0x67E0 - _0x7088[player] < 0.05 then return end
_0x7088[player] = _0x67E0
if typeof(_0xD32A) ~="boolean"then return end
speed, radius = tonumber(speed), tonumber(radius)
if not speed or not radius or speed ~= speed or radius ~= radius then return end
_0x5BF0[player] = {
_0xD32A = _0xD32A,
speed = math.clamp(speed, 1, 100),
radius = math.clamp(radius, 2, 60),
}
end)
local function _0x9321(_0xC09B, ease)
local _0x80EB = _0xC09B.root
local _0xCAC0 = os.clock()
local _0xDE50 = _0xCAC0 * _0xC09B.speed * 0.5
local _0xEBCD = _0x80EB.Position
local _0xB46E = math.max(_0xC09B.orbitCount, 1)
local _0x4320 = { [_0x80EB] = _0x80EB.CFrame }
for _0xDCCD, j in ipairs(_0xC09B.joints) do
local _0x752D = j.motor
local _0x5EA5 = _0x752D.Part0
if _0x752D.Parent and _0x5EA5 and j.part.Parent then
local _0xAD48 = (_0x4320[_0x5EA5] or _0x5EA5.CFrame) * j.c0 * _0x752D.Transform * j.c1:Inverse()
_0x4320[j.part] = _0xAD48
local _0xB100 = _0xAD48
if not j.head then
local _0x6003 = j.slot
local _0x434E = (_0x6003 - 0.5) / _0xB46E
local _0xD919 = math.acos(1 - 2 * _0x434E)
local _0x2C41 = _0x6003 * 2.399963
local _0x7018 = Vector3.new(math.sin(_0xD919) * math.cos(_0x2C41), math.cos(_0xD919), math.sin(_0xD919) * math.sin(_0x2C41))
local _0x5CB5 = CFrame.Angles(_0xDE50 * 0.6, _0xDE50, _0xDE50 * 0.35)local _0xCCFE = 5 + _0xC09B.radius * (0.5 + 0.5 * math.sin(_0xCAC0 * _0xC09B.speed * (0.12 + (_0x6003 % 4) * 0.035) + _0x6003 * 1.7))
local _0x6BF8 = _0xEBCD + _0x5CB5:VectorToWorldSpace(_0x7018) * _0xCCFE
local _0x5C68 = CFrame.new(_0x6BF8) * CFrame.Angles(_0xCAC0 * 2 + _0x6003, _0xCAC0 * 1.3 + _0x6003 * 0.6, _0xCAC0 * 1.7)
_0xB100 = _0xAD48:Lerp(_0x5C68, ease)
end
j.part.CFrame = _0xB100
end
end
end
local function _0x522D(player)
local _0xC09B = _0x1B79[player]
if not _0xC09B then return end
_0x1B79[player] = nil
for _0xDCCD, _0x75F5 in ipairs(_0xC09B.ncc or {}) do
pcall(function() _0x75F5:Destroy() end)
end
if _0xC09B.root and _0xC09B.root.Parent then
pcall(_0x9321, _0xC09B, 0)
end
for _0xDCCD, j in ipairs(_0xC09B.joints) do
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
if _0xC09B.hum and _0xC09B.requiresNeck ~= nil then
_0xC09B.hum.RequiresNeck = _0xC09B.requiresNeck
end
end)
end
local function _0xCEF3(_0x1DBF, _0x9777, _0x80EB)
local _0xC09B = {
_0x1DBF = _0x1DBF, _0x9777 = _0x9777, _0x80EB = _0x80EB,
_0x8A92 = {}, orbitCount = 0, blend = 0,
speed = 6, radius = 5,
requiresNeck = _0x9777.RequiresNeck,
}
local _0x0812 = {}
for _0xDCCD, _0x752D in ipairs(_0x1DBF:GetDescendants()) do
if _0x752D:IsA("Motor6D") and _0x752D.Part0 and _0x752D.Part1 and _0x752D.Part1:IsDescendantOf(_0x1DBF) then
_0x0812[#_0x0812 + 1] = _0x752D
end
end
local _0x6018, _0x5A13, _0x7C85 = { [_0x80EB] = true }, {}, 0
local _0xDE71 = true
while _0xDE71 do
_0xDE71 = false
for _0xDCCD, _0x752D in ipairs(_0x0812) do
if not _0x5A13[_0x752D] and _0x6018[_0x752D.Part0] and not _0x6018[_0x752D.Part1] then
_0x5A13[_0x752D], _0x6018[_0x752D.Part1] = true, true
_0xDE71 = true
local _0x8ED8 = _0x752D.Part1.Name =="Head"if not _0x8ED8 then _0x7C85 += 1 end
_0xC09B.joints[#_0xC09B.joints + 1] = {
motor = _0x752D, _0xB1E8 = _0x752D.Part1, c0 = _0x752D.C0, _0xE4E6 = _0x752D.C1,
enabled = _0x752D.Enabled, canCollide = _0x752D.Part1.CanCollide,
anchored = _0x752D.Part1.Anchored, _0x9C99 = _0x8ED8, _0x7C85 = _0x7C85,
}
end
end
end
_0xC09B.orbitCount = _0x7C85
_0x9777.RequiresNeck = false
_0xC09B.ncc = {}
for _0xDCCD, j in ipairs(_0xC09B.joints) do
j.motor.Enabled = false
j.part.CanCollide = false
j.part.Anchored = truelocal _0x75F5 = Instance.new("NoCollisionConstraint")
_0x75F5.Name ="OULVortexNC"_0x75F5.Part0 = _0x80EB
_0x75F5.Part1 = j.part
_0x75F5.Parent = _0x80EB
_0xC09B.ncc[#_0xC09B.ncc + 1] = _0x75F5
end
return _0xC09B
end
_0x2C20.Heartbeat:Connect(function(dt)
for player, _0x0866 in pairs(_0x5BF0) do
local _0x1DBF = player.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x9777 and _0x9777.RootPart
local _0xC09B = _0x1B79[player]
if _0xC09B and (_0xC09B.char ~= _0x1DBF or _0xC09B.root ~= _0x80EB) then
_0x522D(player)
_0xC09B = nil
end
if _0x0866.want and _0x9777 and _0x80EB and _0x9777.Health > 0 then
if not _0xC09B then
_0xC09B = _0xCEF3(_0x1DBF, _0x9777, _0x80EB)
_0x1B79[player] = _0xC09B
end
_0xC09B.speed, _0xC09B.radius = _0x0866.speed, _0x0866.radius
_0xC09B.blend = math.min(1, _0xC09B.blend + dt / 0.5)
elseif _0xC09B then
_0xC09B.blend = math.max(0, _0xC09B.blend - dt / 0.5)
if _0xC09B.blend <= 0 then
_0x522D(player)
_0xC09B = nil
end
end
if _0xC09B then
local _0x051B = _0xC09B.blend
_0x9321(_0xC09B, _0x051B * _0x051B * (3 - 2 * _0x051B))
end
end
end)
_0x8325.PlayerRemoving:Connect(function(player)
_0x522D(player)
_0x5BF0[player] = nil
_0x7088[player] = nil
end)
return
end
local _0x6FE4 = _0x8325.LocalPlayer
local _0x7C80 = workspace.CurrentCameralocal _0xACD6
do
local _0x5C80 =""local _0xAF7F ="OUL_logo.png"local _0xB441 = Color3.fromRGB(145, 90, 255)
local _0xC106 = Color3.fromRGB(50, 145, 255)
function _0xACD6(parent, _0x7B8B, _0x4CCB, _0xCF3D, zIndex)
zIndex = zIndex or 101
local _0x87D7
if _0x5C80 ~=""then
_0x87D7 ="rbxassetid://".. _0x5C80
else
pcall(function()
if isfile and getcustomasset and isfile(_0xAF7F) then
_0x87D7 = getcustomasset(_0xAF7F)
end
end)
end
if _0x87D7 then
local _0x7DC3 = Instance.new("ImageLabel")
_0x7DC3.Name ="OULLogo"_0x7DC3.BackgroundTransparency = 1
_0x7DC3.BorderSizePixel = 0
_0x7DC3.Size = UDim2.fromOffset(_0x7B8B, _0x7B8B)
_0x7DC3.Position = UDim2.fromOffset(_0x4CCB, _0xCF3D)
_0x7DC3.ScaleType = Enum.ScaleType.Fit
_0x7DC3.Image = _0x87D7
_0x7DC3.ZIndex = zIndex
_0x7DC3.Parent = parent
Instance.new("UICorner", _0x7DC3).CornerRadius = UDim.new(1, 0)
return _0x7DC3
end
local _0x2D02 = Instance.new("Frame")
_0x2D02.Name ="OULLogo"_0x2D02.BackgroundTransparency = 1
_0x2D02.BorderSizePixel = 0
_0x2D02.Size = UDim2.fromOffset(_0x7B8B, _0x7B8B)
_0x2D02.Position = UDim2.fromOffset(_0x4CCB, _0xCF3D)
_0x2D02.ZIndex = zIndex
_0x2D02.Parent = parent
Instance.new("UICorner", _0x2D02).CornerRadius = UDim.new(1, 0)
local _0xAC75 = Instance.new("UIStroke")
_0xAC75.Color = Color3.fromRGB(255, 255, 255)
_0xAC75.Thickness = math.max(1.5, _0x7B8B / 10)
_0xAC75.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0xAC75.Parent = _0x2D02
local _0xB5A0 = Instance.new("UIGradient")
_0xB5A0.Color = ColorSequence.new(_0xB441, _0xC106)
_0xB5A0.Rotation = 45
_0xB5A0.Parent = _0xAC75
local _0x7CFA = Instance.new("TextLabel")
_0x7CFA.BackgroundTransparency = 1
_0x7CFA.Size = UDim2.new(1, 0, 1, 0)
_0x7CFA.Text ="OUL"_0x7CFA.Font = Enum.Font.GothamBold
_0x7CFA.TextSize = math.max(6, math.floor(_0x7B8B * 0.36))
_0x7CFA.TextColor3 = Color3.fromRGB(240, 242, 252)
_0x7CFA.ZIndex = zIndex
_0x7CFA.Parent = _0x2D02
return _0x2D02
end
end
local _0x3159 = { _0x30A5 = nil }
function _0x3159.create()
local _0x2820 = 0.2local _0x62D1 = 8local _0x7EB4 = Color3.fromRGB(215, 228, 245)
local _0x2D35 = Color3.fromRGB(110, 150, 190)
local _0xAB3F = Enum.Font.RobotoMono
local _0x63F4 = 110
local _0x44ED = 2local _0x66D9 = Instance.new("ScreenGui")
_0x66D9.Name ="OULLoaderUI"_0x66D9.ResetOnSpawn = false
_0x66D9.IgnoreGuiInset = true
_0x66D9.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_0x66D9.DisplayOrder = 1000001
pcall(function() _0x66D9.OnTopOfCoreBlur = true end)
local _0xC688 = false
pcall(function()
local _0x0E56 = gethui and gethui() or game:GetService("CoreGui")
_0x66D9.Parent = _0x0E56
_0xC688 = (_0x66D9.Parent == _0x0E56)
end)
if not _0xC688 then
_0x66D9.Parent = _0x6FE4:WaitForChild("PlayerGui")
end
local _0x80EB = Instance.new("Frame")
_0x80EB.Size = UDim2.fromScale(1, 1)
_0x80EB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0x80EB.BackgroundTransparency = 1
_0x80EB.BorderSizePixel = 0
_0x80EB.Active = true
_0x80EB.ZIndex = 10
_0x80EB.Parent = _0x66D9local _0x6461 = Instance.new("BlurEffect")
_0x6461.Name ="OULLoaderBlur"_0x6461.Size = 0
_0x6461.Parent = _0x1F4Alocal _0x3486 = Instance.new("TextButton")
_0x3486.Size = UDim2.fromOffset(0, 0)
_0x3486.BackgroundTransparency = 1
_0x3486.Text =""_0x3486.Modal = true
_0x3486.Parent = _0x80EB
local _0x83BC = Instance.new("Frame")
_0x83BC.Size = UDim2.fromScale(1, 1)
_0x83BC.BackgroundTransparency = 1
_0x83BC.BorderSizePixel = 0
_0x83BC.ZIndex = 11
_0x83BC.Parent = _0x80EB
local _0x71F1 = _0xACD6(_0x83BC, _0x63F4, 0, 0, 11)
_0x71F1.AnchorPoint = Vector2.new(0.5, 0.5)
_0x71F1.Position = UDim2.new(0.5, 0, 0.5, -22)
local _0xF40F = Instance.new("TextLabel")
_0xF40F.BackgroundTransparency = 1
_0xF40F.AnchorPoint = Vector2.new(0.5, 0)
_0xF40F.Position = UDim2.new(0.5, 0, 0.5, 40)
_0xF40F.Size = UDim2.fromOffset(300, 20)
_0xF40F.Font = _0xAB3F
_0xF40F.TextSize = 16
_0xF40F.TextColor3 = _0x7EB4
_0xF40F.Text ="Loading"_0xF40F.ZIndex = 11
_0xF40F.Parent = _0x83BC
local _0x3847 = Instance.new("TextLabel")
_0x3847.BackgroundTransparency = 1
_0x3847.AnchorPoint = Vector2.new(0.5, 0)
_0x3847.Position = UDim2.new(0.5, 0, 0.5, 62)
_0x3847.Size = UDim2.fromOffset(300, 16)
_0x3847.Font = _0xAB3F
_0x3847.TextSize = 12
_0x3847.TextColor3 = _0x2D35
_0x3847.Text ="0%"_0x3847.ZIndex = 11
_0x3847.Parent = _0x83BClocal _0x20E6 = {}
for _0xDCCD, _0x6727 in ipairs(_0x83BC:GetDescendants()) do
local _0x689E
if _0x6727:IsA("ImageLabel") then _0x689E ="ImageTransparency"elseif _0x6727:IsA("TextLabel") then _0x689E ="TextTransparency"elseif _0x6727:IsA("UIStroke") then _0x689E ="Transparency"end
if _0x689E then
_0x20E6[#_0x20E6 + 1] = { obj = _0x6727, _0x689E = _0x689E, _0x44B0 = _0x6727[_0x689E] }
_0x6727[_0x689E] = 1
end
end
local function _0xBA71(_0xAE1F, dur)
local _0x7439 = TweenInfo.new(dur, Enum.EasingStyle.Quad, _0xAE1F and Enum.EasingDirection.Out or Enum.EasingDirection.In)
_0x4BE0:Create(_0x80EB, _0x7439, { BackgroundTransparency = _0xAE1F and _0x2820 or 1 }):Play()
_0x4BE0:Create(_0x6461, _0x7439, { Size = _0xAE1F and _0x62D1 or 0 }):Play()
for _0xDCCD, it in ipairs(_0x20E6) do
_0x4BE0:Create(it.obj, _0x7439, { [it.prop] = _0xAE1F and it.base or 1 }):Play()
end
end
local _0x1FA9 = true
local _0x2BD1, _0xA729, _0xD635 = 0, 0,""local _0xB7E4 = os.clock()
local _0x2051 = {}
local function _0x49A7()
_0x71F1.Rotation = _0x2BD1 * 360 * _0x44ED
local _0x8E01 = math.floor(_0x2BD1 * 100 + 0.5)
_0x3847.Text = (_0xD635 ~="") and (_0x8E01 .."%  -  ".. _0xD635) or (_0x8E01 .."%")
end
local _0x8AD1 = _0x2C20.RenderStepped:Connect(function(dt)
local _0x1F89 = _0xA729 - _0x2BD1
if _0x1F89 > 0 then
_0x2BD1 = math.min(_0xA729, _0x2BD1 + math.max(_0x1F89 * 10, 0.5) * dt)
end
_0x49A7()
end)
_0xBA71(true, 0.25)function _0x2051.set(_0xCF40, _0x0472)
if not _0x1FA9 then return end
_0xB7E4 = os.clock()
_0xA729 = math.clamp(_0xCF40, 0, 1)
if _0x0472 then _0xD635 = _0x0472 end
local _0x0310 = os.clock()
while _0x1FA9 and _0x2BD1 < _0xA729 - 0.02 and os.clock() - _0x0310 < 1.2 do
_0x2C20.RenderStepped:Wait()
end
endfunction _0x2051.reset(_0x0472)
if not _0x1FA9 then return end
_0xB7E4 = os.clock()
_0x2BD1, _0xA729 = 0, 0
_0xD635 = _0x0472 or""_0x49A7()
end
function _0x2051.destroy()
if not _0x1FA9 then return end
_0x1FA9 = false
pcall(function() _0x8AD1:Disconnect() end)
pcall(function() _0x6461:Destroy() end)
pcall(function() _0x66D9:Destroy() end)
endfunction _0x2051.finish(block)
local function _0xC28E()
if not _0x1FA9 then return end
_0xB7E4 = os.clock()
_0xA729 = 1
_0xD635 ="Done"local _0x0310 = os.clock()
while _0x1FA9 and _0x2BD1 < 0.999 and os.clock() - _0x0310 < 1.5 do
_0x2C20.RenderStepped:Wait()
end
task.wait(0.25)
if not _0x1FA9 then return end
_0xBA71(false, 0.4)
task.wait(0.45)
_0x2051.destroy()
end
if block then _0xC28E() else task.spawn(_0xC28E) end
endtask.spawn(function()
while _0x1FA9 do
task.wait(1)
if _0x1FA9 and os.clock() - _0xB7E4 > 20 then
_0x2051.destroy()
end
end
end)
return _0x2051
end
function _0x3159.step(_0xCF40, _0x0472)
local _0x75F5 = _0x3159.cur
if _0x75F5 then _0x75F5.set(_0xCF40, _0x0472) end
end
function _0x3159.finish(block)
local _0x75F5 = _0x3159.cur
if _0x75F5 then _0x75F5.finish(block) end
end
function _0x3159.destroy()
local _0x75F5 = _0x3159.cur
_0x3159.cur = nil
if _0x75F5 then _0x75F5.destroy() end
end_0x3159.cur = _0x3159.create()
_0x3159.step(0.4,"Starting")
_0x3159.step(0.8,"Preparing key system")
_0x3159.finish(true)dolocal _0x93F9 = {"MXG1-910A-JP8L-X81V","298U-SBSQ-1URP-ZLX4","7W5W-I42X-H85M-GN77","8747-7RBB-XVL9-CSCT","EMFY-IVQ7-AK32-39HY","IGGW-RRAZ-N3PH-33KS","J8V4-5LN3-I1B8-HUAY","PMQU-XOA5-0ALT-1IW2","SNB7-3SVA-T460-YMMZ","T3IS-IAHW-I85C-UQZA","VKBQ-BO6W-A3E9-6NOV","MR89-L17Y-4XL4-A1AM","1YNI-JR1G-7VVR-XNEQ","15EW-UJAA-JYYZ-P0KB","XN66-WJUS-IGLS-6X5W","RL4T-1B8S-R1EI-OVPQ","L7AW-ZWI3-XJMN-U6NC","0AE1-FZIL-UNYX-DQV7","EK90-RZ8I-LD3G-LWW8","JIVR-5S6H-RWO3-DMLW","0MCU-JDFC-FIIX-WVRZ",
}
local function _0x3FA8(_0x35C0)
_0x35C0 = tostring(_0x35C0 or"")
_0x35C0 = string.gsub(_0x35C0,"^%s+","")
_0x35C0 = string.gsub(_0x35C0,"%s+$","")
return string.upper(_0x35C0)
end
local function _0x7E72(_0x35C0)
local _0x54FD = _0x3FA8(_0x35C0)
for _0xDCCD, _0x434E in ipairs(_0x93F9) do
if _0x54FD == _0x3FA8(_0x434E) then return true end
end
return false
endlocal _0x063F = 24 * 60 * 60
local _0xA84D ="OULKeyPass_".. tostring(_0x6FE4.UserId) ..".txt"local function _0x313A()
if type(readfile) ~="function"or type(isfile) ~="function"then return false end
local _0x499B, _0xB863 = pcall(function()
if isfile(_0xA84D) then return readfile(_0xA84D) end
end)
if not _0x499B or type(_0xB863) ~="string"then return false end
local _0xB92E, _0x47D8 = string.match(_0xB863,"^(.-)|(%d+)%s*$")
if not _0xB92E or not _0x47D8 then return false end
_0x47D8 = tonumber(_0x47D8)
if not _0x47D8 then return false end
local _0x3FC4 = os.time() - _0x47D8
if _0x3FC4 < 0 or _0x3FC4 >= _0x063F then return false end
return _0x7E72(_0xB92E)
end
local function _0x8F76(_0xB92E)
if type(writefile) ~="function"then return end
pcall(writefile, _0xA84D, _0x3FA8(_0xB92E) .."|".. tostring(os.time()))
endlocal _0x3433 = _0x313A()
if _0x3433 then_0x3159.cur = _0x3159.create()
_0x3159.step(0.5,"Key remembered")
_0x3159.step(1,"Unlocking")
task.wait(0.15)
_0x3159.cur.reset("Starting")
else
local _0x8123 = Instance.new("ScreenGui")
_0x8123.Name ="OULKeyUI"_0x8123.ResetOnSpawn = false
_0x8123.IgnoreGuiInset = true
_0x8123.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_0x8123.DisplayOrder = 1000000
pcall(function() _0x8123.OnTopOfCoreBlur = true end)
local _0xC688 = false
pcall(function()
local _0x0E56 = gethui and gethui() or game:GetService("CoreGui")
_0x8123.Parent = _0x0E56
_0xC688 = (_0x8123.Parent == _0x0E56)
end)
if not _0xC688 then
_0x8123.Parent = _0x6FE4:WaitForChild("PlayerGui")
endfor _0xDCCD, _0x0E56 in ipairs({ _0x6FE4:FindFirstChild("PlayerGui"), pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil }) do
if _0x0E56 then
for _0xDCCD, _0x75F5 in ipairs(_0x0E56:GetChildren()) do
if _0x75F5.Name =="OULKeyUI"and _0x75F5 ~= _0x8123 then pcall(function() _0x75F5:Destroy() end) end
end
end
end
local _0xADFA = Color3.fromRGB(8, 9, 20)
local _0xDE8E = Color3.fromRGB(34, 34, 48)
local _0x0CD8 = Color3.fromRGB(44, 46, 86)
local _0x9C2E = Color3.fromRGB(140, 95, 255)
local _0x7EB4 = Color3.fromRGB(228, 232, 255)
local _0x2D35 = Color3.fromRGB(130, 136, 175)
local _0xD749 = Color3.fromRGB(90, 200, 120)
local _0xE26B = Color3.fromRGB(235, 90, 90)
local _0x6866 = Enum.Font.RobotoMono
local _0x5DD8 = 0for _0xDCCD, _0x99C5 in ipairs(_0x1F4A:GetChildren()) do
if _0x99C5.Name =="OULKeyBlur"then pcall(function() _0x99C5:Destroy() end) end
end
local _0xF3B8 = Instance.new("BlurEffect")
_0xF3B8.Name ="OULKeyBlur"_0xF3B8.Size = 0
_0xF3B8.Parent = _0x1F4A
_0x4BE0:Create(_0xF3B8, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 8 }):Play()
local _0x129C = Instance.new("Frame")
_0x129C.Size = UDim2.fromScale(1, 1)
_0x129C.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0x129C.BackgroundTransparency = 1
_0x129C.BorderSizePixel = 0
_0x129C.ZIndex = 1
_0x129C.Parent = _0x8123
_0x4BE0:Create(_0x129C, TweenInfo.new(0.3), { BackgroundTransparency = 0.2 }):Play()
local _0xAE9A = Instance.new("Frame")
_0xAE9A.AnchorPoint = Vector2.new(0.5, 0.5)
_0xAE9A.Position = UDim2.fromScale(0.5, 0.5)
_0xAE9A.Size = UDim2.fromOffset(340, 170)
_0xAE9A.BackgroundColor3 = _0xADFA
_0xAE9A.BorderSizePixel = 0
_0xAE9A.Active = true
_0xAE9A.ZIndex = 10
_0xAE9A.Parent = _0x8123
Instance.new("UICorner", _0xAE9A).CornerRadius = UDim.new(0, 6)
local _0x1D35 = Instance.new("UIStroke")
_0x1D35.Color = _0x0CD8
_0x1D35.Thickness = 1
_0x1D35.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x1D35.Parent = _0xAE9Alocal _0x3486 = Instance.new("TextButton")
_0x3486.Size = UDim2.fromOffset(0, 0)
_0x3486.BackgroundTransparency = 1
_0x3486.Text =""_0x3486.Modal = true
_0x3486.Parent = _0xAE9A
local _0x337B = Instance.new("Frame")
_0x337B.Size = UDim2.new(1, 0, 0, 2)
_0x337B.BackgroundColor3 = _0x9C2E
_0x337B.BorderSizePixel = 0
_0x337B.ZIndex = 11
_0x337B.Parent = _0xAE9A
local _0xF40F = Instance.new("TextLabel")
_0xF40F.BackgroundTransparency = 1
_0xF40F.Position = UDim2.fromOffset(14, 10)
_0xF40F.Size = UDim2.new(1, -56, 0, 20)
_0xF40F.Font = _0x6866
_0xF40F.TextSize = 14
_0xF40F.TextXAlignment = Enum.TextXAlignment.Left
_0xF40F.TextColor3 = _0x7EB4
_0xF40F.Text ="OUL  -  Enter Key"_0xF40F.ZIndex = 11
_0xF40F.Parent = _0xAE9A
local _0xB4CD = Instance.new("TextButton")
_0xB4CD.AnchorPoint = Vector2.new(1, 0)
_0xB4CD.Position = UDim2.new(1, -8, 0, 8)
_0xB4CD.Size = UDim2.fromOffset(24, 24)
_0xB4CD.BackgroundTransparency = 1
_0xB4CD.BorderSizePixel = 0
_0xB4CD.AutoButtonColor = false
_0xB4CD.Font = _0x6866
_0xB4CD.TextSize = 14
_0xB4CD.Text ="X"_0xB4CD.TextColor3 = _0x2D35
_0xB4CD.ZIndex = 12
_0xB4CD.Parent = _0xAE9A
Instance.new("UICorner", _0xB4CD).CornerRadius = UDim.new(0, 4)
_0xB4CD.MouseEnter:Connect(function()
_0xB4CD.TextColor3 = _0xE26B
end)
_0xB4CD.MouseLeave:Connect(function()
_0xB4CD.TextColor3 = _0x2D35
end)
local _0x8183 = Instance.new("TextBox")
_0x8183.Position = UDim2.fromOffset(14, 62)
_0x8183.Size = UDim2.new(1, -28, 0, 30)
_0x8183.BackgroundColor3 = _0xDE8E
_0x8183.BorderSizePixel = 0
_0x8183.ClearTextOnFocus = false
_0x8183.PlaceholderText =""_0x8183.PlaceholderColor3 = _0x2D35
_0x8183.Text =""_0x8183.TextColor3 = _0x7EB4
_0x8183.Font = _0x6866
_0x8183.TextSize = 13
_0x8183.ZIndex = 11
_0x8183.Parent = _0xAE9A
Instance.new("UICorner", _0x8183).CornerRadius = UDim.new(0, 4)
local _0x49DE = Instance.new("UIStroke")
_0x49DE.Color = _0x0CD8
_0x49DE.Thickness = 1
_0x49DE.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x49DE.Parent = _0x8183
local _0x3847 = Instance.new("TextLabel")
_0x3847.BackgroundTransparency = 1
_0x3847.Position = UDim2.fromOffset(14, 96)
_0x3847.Size = UDim2.new(1, -28, 0, 14)
_0x3847.Font = _0x6866
_0x3847.TextSize = 11
_0x3847.TextXAlignment = Enum.TextXAlignment.Left
_0x3847.TextColor3 = _0x2D35
_0x3847.Text =""_0x3847.ZIndex = 11
_0x3847.Parent = _0xAE9A
local _0x0B72 = Instance.new("TextButton")
_0x0B72.Position = UDim2.fromOffset(14, 120)
_0x0B72.Size = UDim2.new(1, -28, 0, 32)
_0x0B72.BackgroundColor3 = _0x9C2E
_0x0B72.BorderSizePixel = 0
_0x0B72.AutoButtonColor = false
_0x0B72.Font = _0x6866
_0x0B72.TextSize = 13
_0x0B72.Text ="Submit"_0x0B72.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x0B72.ZIndex = 11
_0x0B72.Parent = _0xAE9A
Instance.new("UICorner", _0x0B72).CornerRadius = UDim.new(0, 4)
_0x0B72.MouseEnter:Connect(function()
if os.clock() >= _0x5DD8 then
_0x0B72.BackgroundColor3 = _0x9C2E:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
end
end)
_0x0B72.MouseLeave:Connect(function()
if os.clock() >= _0x5DD8 then _0x0B72.BackgroundColor3 = _0x9C2E end
end)do
local _0xC60A, _0x413F, _0xD762
_0xAE9A.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
local _0xDBFB = _0x862B.Position.Y - _0xAE9A.AbsolutePosition.Y
if _0xDBFB <= 36 then
_0xC60A, _0x413F, _0xD762 = true, _0x862B.Position, _0xAE9A.Position
end
end
end)
_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and _0x862B.UserInputType == Enum.UserInputType.MouseMovement then
local _0x6727 = _0x862B.Position - _0x413F
_0xAE9A.Position = UDim2.new(_0xD762.X.Scale, _0xD762.X.Offset + _0x6727.X, _0xD762.Y.Scale, _0xD762.Y.Offset + _0x6727.Y)
end
end)
_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then _0xC60A = false end
end)
end
local _0x8711 = nillocal _0x6FED = false
local _0xC8D4 = 3local function _0x1637()
local _0x44B0 = _0xAE9A.Position
for _0xDCCD, dx in ipairs({ 8, -8, 5, -5, 2, 0 }) do
_0xAE9A.Position = UDim2.new(_0x44B0.X.Scale, _0x44B0.X.Offset + dx, _0x44B0.Y.Scale, _0x44B0.Y.Offset)
task.wait(0.035)
end
end
local function _0xEE95()
if _0x6FED or _0x8711 ~= nil then return end
if os.clock() < _0x5DD8 then return end_0x6FED = true
if _0x7E72(_0x8183.Text) then
_0x3847.TextColor3 = _0xD749
_0x8F76(_0x8183.Text)
_0x3847.Text ="key accepted - loading..."_0x49DE.Color = _0xD749
task.wait(0.4)
_0x8711 = true
else
_0x5DD8 = os.clock() + _0xC8D4
_0x3847.TextColor3 = _0xE26B
_0x49DE.Color = _0xE26B
_0x0B72.BackgroundColor3 = _0x9C2E:Lerp(_0xADFA, 0.6)
task.spawn(function()
while _0x8711 == nil do
local _0xEB3F = _0x5DD8 - os.clock()
if _0xEB3F <= 0 then break end
_0x3847.Text = string.format("wrong key - wait %.1fs", _0xEB3F)
task.wait(0.1)
end
if _0x8711 == nil then
_0x3847.Text =""_0x49DE.Color = _0x0CD8
_0x0B72.BackgroundColor3 = _0x9C2E
end
end)
_0x1637()
end
_0x6FED = false
end
_0x0B72.MouseButton1Click:Connect(_0xEE95)
_0x8183.FocusLost:Connect(function(enterPressed)
if enterPressed then _0xEE95() end
end)
_0xB4CD.MouseButton1Click:Connect(function()
if _0x8711 == nil then _0x8711 = false end
end)while _0x8711 == nil do
task.wait(0.1)
end
local function _0xBE71()
pcall(function()
_0x4BE0:Create(_0xF3B8, TweenInfo.new(0.25), { Size = 0 }):Play()
task.delay(0.3, function() pcall(function() _0xF3B8:Destroy() end) end)
end)
end
if _0x8711 ~= true then
pcall(function() _0x8123:Destroy() end)
_0xBE71()
returnend_0x3159.cur = _0x3159.create()
_0x3159.step(0.3,"Checking key")
pcall(function() _0x8123:Destroy() end)
_0xBE71()
_0x3159.step(0.7,"Unlocking")
_0x3159.step(1,"Key accepted")
task.wait(0.15)
_0x3159.cur.reset("Starting")
endendif not _0x3159.cur then _0x3159.cur = _0x3159.create() end
_0x3159.step(0.08,"Preparing")
if shared.OULCleanup then
pcall(shared.OULCleanup)
shared.OULCleanup = nil
end
do
pcall(function() _0x2C20:UnbindFromRenderStep("Aimbot") end)
pcall(function() _0x2C20:UnbindFromRenderStep("AimAssist") end)
pcall(function() _0x2C20:UnbindFromRenderStep("OULMenuMouse") end)
local _0x893C = { _0x6FE4:WaitForChild("PlayerGui") }
pcall(function() table.insert(_0x893C, game:GetService("CoreGui")) end)
pcall(function()
if gethui then table.insert(_0x893C, gethui()) end
end)
for _0xDCCD, container in ipairs(_0x893C) do
for _0xDCCD, _0xBF13 in ipairs({"AimbotUI","AimAssistUI"}) do
pcall(function()
local _0xCAE5 = container:FindFirstChild(_0xBF13)
while _0xCAE5 do
_0xCAE5:Destroy()
_0xCAE5 = container:FindFirstChild(_0xBF13)
end
end)
end
end
local _0xB2B4 = _0x1F4A:FindFirstChild("OULMenuBlur")
while _0xB2B4 do
_0xB2B4:Destroy()
_0xB2B4 = _0x1F4A:FindFirstChild("OULMenuBlur")
end
local _0x8ECF = workspace:FindFirstChild("OULESP")
while _0x8ECF do
_0x8ECF:Destroy()
_0x8ECF = workspace:FindFirstChild("OULESP")
end
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
local _0x1DBF = _0x5D5D.Character
if _0x1DBF then
for _0xDCCD, child in ipairs(_0x1DBF:GetChildren()) do
if child.Name =="ESPChams"or child.Name =="ESPName"then
child:Destroy()
end
end
end
end
end
local _0xE870 = true
local _0x8700 = {}
local function _0x32C1(_0x8AD1)
_0x8700[#_0x8700 + 1] = _0x8AD1
return _0x8AD1
end
local _0x5BA2 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _0xCFE3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _0x87A6 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local _0xF308 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _0xFCF5 = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local _0x4B96 = Enum.Font.RobotoMono
local function _0x6884(obj, props, _0x7439)
_0x4BE0:Create(obj, _0x7439 or _0x5BA2, props):Play()
end
local function _0x91F0(obj, props, animate)
if animate then
_0x6884(obj, props)
else
for _0x434E, _0x803E in pairs(props) do
obj[_0x434E] = _0x803E
end
end
end
local _0x1FFF = {
Text = Color3.fromRGB(228, 232, 255),
Switch = Color3.fromRGB(88, 122, 255),
Accent = Color3.fromRGB(140, 95, 255),
Background = Color3.fromRGB(8, 9, 20),
Outline = Color3.fromRGB(44, 46, 86),
Dim = Color3.fromRGB(110, 165, 210),
Field = Color3.fromRGB(34, 34, 42),
Group = Color3.fromRGB(22, 22, 28),
}
local _0xB695 = {}
local _0xAB72 = {}
local function _0xCF61()
_0x1FFF.Dim = _0x1FFF.Text:Lerp(_0x1FFF.Background, 0.4)
_0x1FFF.Field = _0x1FFF.Background:Lerp(_0x1FFF.Text, 0.1)
_0x1FFF.Group = _0x1FFF.Background:Lerp(_0x1FFF.Text, 0.035)
end
_0xCF61()
local function _0x4EBC(obj, _0x689E, _0x94C5)
obj[_0x689E] = _0x94C5()
_0xB695[#_0xB695 + 1] = { obj = obj, _0x689E = _0x689E, _0x94C5 = _0x94C5 }
end
local function _0x8C5B(obj, _0x129C)
_0x4EBC(obj,"TextColor3", function()
return _0x129C and _0x1FFF.Dim or _0x1FFF.Text
end)
end
local function _0x63C7(_0x94C5)
_0xAB72[#_0xAB72 + 1] = _0x94C5
end
local function _0xD514()
_0xCF61()
for _0xDCCD, _0x051B in ipairs(_0xB695) do
if _0x051B.obj.Parent then
_0x6884(_0x051B.obj, { [_0x051B.prop] = _0x051B.fn() }, _0xF308)
end
end
for _0xDCCD, _0x94C5 in ipairs(_0xAB72) do
_0x94C5()
end
end
local _0xC248 = {
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
ESPDistance = false,
ESPWeapon = false,
Skybox = false,
SkyRainbow = false,
SkyBrightness = 100,
MouseAim = true,
MouseGain = 25,
WallCheck = true,
Watermark = true,
ShowFOV = true,
AimPart ="Head",
AimMode ="Hold",
Fullbright = false,
NoFog = false,
Radar = false,
RadarRange = 250,
RadarSize = 160,
RadarCorner ="TopRight",
RadarX = -1,
RadarY = -1,
UIStyle ="Classic",
RadarDotSize = 7,
RadarLineThickness = 1,
UITransparency = 0,
UIScale = 100,
BGGradient = true,
BGGradMirror = true,
BGGradBright = 70,
BGGradHue = 213,
BGGradDir ="TopRight",
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
VoidSpam = false,
VoidAutoAttack = false,
MenuSnow = false,
SnowAngle = 0,
SnowSpeed = 100,
Rain = false,
ParticleType ="Snow",
RageLowestHP = false,
VoidLowestHP = false,
VoidBehind = false,
VoidAbove = true,
VoidBelow = false,
VoidInterval = 200,
VoidDistance = 1500,
VoidRoam = true,
VoidRoamMs = 100,
AttackInterval = 200,
AttackHeight = 6,
RageMode ="Closest",
RageTarget ="",
}
local _0xFE38
local _0x5028
local _0xDCFD = false
local _0x4ED9 = {}
local _0x5362 = {
Enabled ="Aimbot", ShowFOV ="FOV Circle", IgnoreFOV ="Ignore FOV", TeamCheck ="Team Check", Triggerbot ="Triggerbot",
ESP ="ESP", Chams ="Chams", ShowNames ="Usernames", Tracers ="Tracers",
Boxes ="Boxes", BoxFill ="Box Fill", Skeleton ="Skeleton", ESPHealth ="Health", Skybox ="Skybox", SkyRainbow ="Rainbow Sky", Fly ="Fly", FlyVortex ="Vortex",
Noclip ="Noclip", Speed ="Speed", InfiniteJump ="Infinite Jump",
Watermark ="Watermark", BlurEnabled ="Background Blur", Notifications ="Notifications",
TargetNPCs ="Target Zombies/NPCS", ESPNPCs ="Zombie/NPC ESP",
MouseTP ="Mouse TP", KeybindList ="Keybind List",
Ragebot ="Ragebot", RageOrbit ="Orbit", VoidSpam ="Void Spam", VoidAutoAttack ="Void Auto Attack", RageLowestHP ="Rage Lowest Health", VoidLowestHP ="Void Lowest Health",
Fullbright ="Fullbright", NoFog ="No Fog", Radar ="Radar",
}
local _0x9490 = {}
local function _0xD40A(id, _0x7465, _0xFBC4, _0xB92E, _0x862B)
_0x9490[#_0x9490 + 1] = { id = id, _0x7465 = _0x7465, _0xFBC4 = _0xFBC4, _0xB92E = _0xB92E, _0x862B = _0x862B, _0xCE84 = _0x862B }
end
_0xD40A("menu","Menu","menu", nil, Enum.KeyCode.End)
_0xD40A("panic","Panic (unload)","panic", nil, Enum.KeyCode.Home)
_0xD40A("aim","Aim key","hold", nil, Enum.UserInputType.MouseButton2)
for _0xDCCD, _0x434E in ipairs({"Enabled","ShowFOV","IgnoreFOV","TeamCheck","Triggerbot","Ragebot","VoidSpam","ESP","Chams","ShowNames","Tracers","Boxes","BoxFill","Skeleton","Skybox","Fly","Noclip","Speed","InfiniteJump","Watermark","BlurEnabled","Notifications","KeybindList",
}) do
local _0xCE84
if _0x434E =="Triggerbot"then _0xCE84 = Enum.KeyCode.P end
if _0x434E =="Fly"then _0xCE84 = Enum.KeyCode.Equals end
if _0x434E =="Noclip"then _0xCE84 = Enum.KeyCode.N end
_0xD40A(_0x434E, _0x5362[_0x434E],"toggle", _0x434E, _0xCE84)
end
_0xD40A("MouseTPKey","Mouse TP","press", nil, Enum.KeyCode.T)
local function _0xACF9(id)
for _0xDCCD, _0x051B in ipairs(_0x9490) do
if _0x051B.id == id then return _0x051B end
end
end
local _0xE326 = {
Equals ="=", Minus ="-", Return ="Enter", Backquote ="`", LeftBracket ="[",
RightBracket ="]", Semicolon =";", Quote ="'", Comma =",", Period =".",
Slash ="/", BackSlash ="\\", LeftShift ="LShift", RightShift ="RShift",
LeftControl ="LCtrl", RightControl ="RCtrl", LeftAlt ="LAlt", RightAlt ="RAlt",
Zero ="0", One ="1", Two ="2", Three ="3", Four ="4", Five ="5", Six ="6",
Seven ="7", Eight ="8", Nine ="9",
}
local function _0x8406(_0x862B)
if not _0x862B then return"None"end
if _0x862B.EnumType == Enum.KeyCode then
return _0xE326[_0x862B.Name] or _0x862B.Name
end
if _0x862B == Enum.UserInputType.MouseButton1 then return"Left Click"end
if _0x862B == Enum.UserInputType.MouseButton2 then return"Right Click"end
if _0x862B == Enum.UserInputType.MouseButton3 then return"Middle Click"end
return _0x862B.Name
end
local function _0x470B(_0x862B, bindInput)
if not bindInput then return false end
if bindInput.EnumType == Enum.KeyCode then
return _0x862B.KeyCode == bindInput
end
return _0x862B.UserInputType == bindInput
end
local _0x837F = {}
local function _0x18F9(_0x7465, _0x94C5)
_0x7465.Text = _0x94C5()
_0x837F[#_0x837F + 1] = function()
_0x7465.Text = _0x94C5()
end
end
local function _0xBB85()
for _0xDCCD, _0x94C5 in ipairs(_0x837F) do
_0x94C5()
end
end
local _0xCB3D = nil
local _0xE20A = {}
local function _0xB6C3()
for id, _0x35A4 in pairs(_0xE20A) do
local _0x051B = _0xACF9(id)
if _0xCB3D == _0x051B then
_0x35A4.Text ="press key/mouse"else
_0x35A4.Text = _0x8406(_0x051B.input)
end
end
end
local _0xE515 = {}
local _0x0E49
local _0x9996
local _0xB423, _0x7C18
local _0xFAA9
local _0xCCA4 = 30
local _0x0556 = {
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
BGGrad = Color3.fromRGB(0, 110, 255),
}
local _0xA41E = Color3.fromRGB(255, 255, 255)
local _0xDB5A = false
local _0xCB23 ="saving: connecting..."local _0x1807
local _0x2ADF = function() end
local _0xBBF0 = {}
local function _0xB710(_0xCF40)
return { _0xCF40.X.Scale, _0xCF40.X.Offset, _0xCF40.Y.Scale, _0xCF40.Y.Offset }
end
local function _0xC63F(_0x82B5)
if type(_0x82B5) ~="table"then return nil end
for i = 1, 4 do
if type(_0x82B5[i]) ~="number"or _0x82B5[i] ~= _0x82B5[i] then return nil end
end
return UDim2.new(math.clamp(_0x82B5[1], 0, 1), math.clamp(_0x82B5[2], -4000, 4000), math.clamp(_0x82B5[3], 0, 1), math.clamp(_0x82B5[4], -4000, 4000))
end
local _0xD1D6 = {
available = false,
colorRefreshers = {},
colorGetters = {
["FOV Color"] = function() return _0xA41E end,
["Cham Fill"] = function() return _0x0556.Fill end,
["Cham Outline"] = function() return _0x0556.Outline end,
["Box"] = function() return _0x0556.Box end,
["Box Fill"] = function() return _0x0556.BoxFill end,
["Skeleton"] = function() return _0x0556.Skeleton end,
["Sky Colour"] = function() return _0x0556.Sky end,
["Radar"] = function() return _0x0556.Radar end,
["Radar Lines"] = function() return _0x0556.RadarLines end,
["Gradient Colour"] = function() return _0x0556.BGGrad end,
["Tracers"] = function() return _0x0556.Tracer end,
["Usernames"] = function() return _0x0556.Name end,
["Checkbox"] = function() return _0x1FFF.Switch end,
["Accent"] = function() return _0x1FFF.Accent end,
["Text"] = function() return _0x1FFF.Text end,
["Background"] = function() return _0x1FFF.Background end,
["Outline"] = function() return _0x1FFF.Outline end,
},
}
do
local _0xD6C2 = game:GetService("HttpService")
local _0xF6C1 = game:GetService("ReplicatedStorage")
local _0x757C = 2
local _0x896A = {"Enabled","IgnoreFOV","TeamCheck","Triggerbot","TriggerOnClick","ESP","Chams","BlurEnabled","ShowNames","Tracers","Boxes","BoxFill","Skeleton","ESPHealth","ESPDistance","ESPWeapon","Skybox","SkyRainbow","Watermark","ShowFOV","Fly","Noclip","Speed","Fullbright","NoFog","Rain","Radar","Prediction","InfiniteJump","Notifications","TargetNPCs","ESPNPCs","MouseTP","KeybindList","Ragebot","RageBehind","RageAbove","RageBelow","RageOrbit","MouseAim","VoidRoam","VoidAutoAttack","MenuSnow","PreviewAutoSpin","RageLowestHP","VoidLowestHP","VoidBehind","VoidAbove","VoidBelow","BGGradient","BGGradMirror",
}
local _0x2F64 = {
RadarRange = { 50, 1000 },
SnowAngle = { -60, 60 },
SnowSpeed = { 10, 300 },
RadarSize = { 100, 300 },
RadarDotSize = { 4, 14 },
RadarX = { -1, 10000 },
RadarY = { -1, 10000 },
RadarLineThickness = { 1, 4 },
BGGradBright = { 10, 100 },
BGGradHue = { 0, 360 },
FOV ={ 20, 500 }, Strength = { 1, 500 }, PredictionMs = { 0, 500 }, TriggerDelay = { 0, 300 },
BlurAmount = { 1, 56 }, UITransparency = { 0, 70 }, UIScale = { 50, 150 }, FlySpeed = { 5, 1000 },
VortexSpeed = { 1, 100 }, VortexRadius = { 2, 60 }, SpeedValue = { 16, 250 },
RageDistance = { 2, 20 }, OrbitSpeed = { 1, 30 }, VoidInterval = { 10, 2000 }, VoidDistance = { 1, 10000000 }, VoidRoamMs = { 10, 2000 }, AttackInterval = { 10, 2000 }, AttackHeight = { 0, 50 }, SkyBrightness = { 0, 100 }, MouseGain = { 5, 100 },
}
local _0x8FCE = {"Text","Switch","Accent","Background","Outline"}
local _0x2706 = {"Fill","Outline","Tracer","Name","Box","BoxFill","Skeleton","Sky","Radar","RadarLines","BGGrad"}
local function _0x335C(_0x75F5)
return { math.floor(_0x75F5.R * 255 + 0.5), math.floor(_0x75F5.G * 255 + 0.5), math.floor(_0x75F5.B * 255 + 0.5) }
end
local function _0x4F05(_0x82B5)
if type(_0x82B5) =="table"and type(_0x82B5[1]) =="number"and type(_0x82B5[2]) =="number"and type(_0x82B5[3]) =="number"then
return Color3.fromRGB(math.clamp(_0x82B5[1], 0, 255), math.clamp(_0x82B5[2], 0, 255), math.clamp(_0x82B5[3], 0, 255))
end
end
local function _0xE6BA(i)
if not i then return""end
if i.EnumType == Enum.KeyCode then return"K:".. i.Name end
return"M:".. i.Name
end
local function _0x4B2A(str)
if type(str) ~="string"or #str < 3 then return nil end
local _0xFBC4, _0xBF13 = str:sub(1, 1), str:sub(3)
if _0xFBC4 =="K"then
local _0x499B, _0x803E = pcall(function() return Enum.KeyCode[_0xBF13] end)
if _0x499B then return _0x803E end
elseif _0xFBC4 =="M"and (_0xBF13 =="MouseButton1"or _0xBF13 =="MouseButton2"or _0xBF13 =="MouseButton3") then
return Enum.UserInputType[_0xBF13]
end
return nil
end
local function _0xF824()
local _0x8DA9 = { _0x803E = _0x757C, settings = {}, theme = {}, esp = {}, binds = {}, _0x6BF8 = {} }
for _0xDCCD, _0x434E in ipairs(_0x896A) do
_0x8DA9.settings[_0x434E] = _0xC248[_0x434E] and true or false
end
for _0x434E in pairs(_0x2F64) do
_0x8DA9.settings[_0x434E] = _0xC248[_0x434E]
end
_0x8DA9.settings.AimPart = _0xC248.AimPart
_0x8DA9.settings.AimMode = _0xC248.AimMode
_0x8DA9.settings.RageMode = _0xC248.RageMode
_0x8DA9.settings.RageTarget = _0xC248.RageTarget
_0x8DA9.settings.UIStyle = _0xC248.UIStyle
_0x8DA9.settings.ParticleType = _0xC248.ParticleType
_0x8DA9.settings.BGGradDir = _0xC248.BGGradDir
for _0xDCCD, _0x434E in ipairs(_0x8FCE) do
_0x8DA9.theme[_0x434E] = _0x335C(_0x1FFF[_0x434E])
end
for _0xDCCD, _0x434E in ipairs(_0x2706) do
_0x8DA9.esp[_0x434E] = _0x335C(_0x0556[_0x434E])
end
_0x8DA9.fov = _0x335C(_0xA41E)
if _0xBBF0.hud then _0x8DA9.pos.hud = _0xB710(_0xBBF0.hud) end
if _0xBBF0.keylist then _0x8DA9.pos.keylist = _0xB710(_0xBBF0.keylist) end
for _0xDCCD, _0x051B in ipairs(_0x9490) do
_0x8DA9.binds[_0x051B.id] = _0xE6BA(_0x051B.input)
end
return _0x8DA9
end
local function _0xF590(_0x6727)
local _0x35C0 = type(_0x6727.settings) =="table"and _0x6727.settings or {}
for _0xDCCD, _0x434E in ipairs(_0x896A) do
if type(_0x35C0[_0x434E]) =="boolean"then _0xC248[_0x434E] = _0x35C0[_0x434E] end
end
for _0x434E, _0xB7DF in pairs(_0x2F64) do
if type(_0x35C0[_0x434E]) =="number"and _0x35C0[_0x434E] == _0x35C0[_0x434E] then
_0xC248[_0x434E] = math.clamp(math.floor(_0x35C0[_0x434E] + 0.5), _0xB7DF[1], _0xB7DF[2])
end
end
if _0x35C0.AimPart =="Head"or _0x35C0.AimPart =="Body"then _0xC248.AimPart = _0x35C0.AimPart end
if _0x35C0.AimMode =="Hold"or _0x35C0.AimMode =="Toggle"then _0xC248.AimMode = _0x35C0.AimMode end
if _0x35C0.ParticleType =="Snow"or _0x35C0.ParticleType =="Rain"then _0xC248.ParticleType = _0x35C0.ParticleType end
if type(_0x35C0.RadarCorner) =="string"then
local _0x0713 = { TopRight = true, TopLeft = true, BottomRight = true, BottomLeft = true, Custom = true }
if _0x0713[_0x35C0.RadarCorner] then _0xC248.RadarCorner = _0x35C0.RadarCorner end
end
if _0x35C0.RageMode =="Closest"or _0x35C0.RageMode =="Selected"then _0xC248.RageMode = _0x35C0.RageMode end
if type(_0x35C0.RageTarget) =="string"then _0xC248.RageTarget = _0x35C0.RageTarget:sub(1, 24) end
if _0x35C0.UIStyle =="Classic"or _0x35C0.UIStyle =="Basic"or _0x35C0.UIStyle =="Modern"then
_0xC248.UIStyle = _0x35C0.UIStyle
end
do
local _0xB1AF = { TopLeft = true, Top = true, TopRight = true, Right = true, BottomRight = true, Bottom = true, BottomLeft = true, Left = true }
if type(_0x35C0.BGGradDir) =="string"and _0xB1AF[_0x35C0.BGGradDir] then _0xC248.BGGradDir = _0x35C0.BGGradDir end
end
if type(_0x6727.v) =="number"and _0x6727.v >= _0x757C then
local _0xCAC0 = type(_0x6727.theme) =="table"and _0x6727.theme or {}
for _0xDCCD, _0x434E in ipairs(_0x8FCE) do
local _0x75F5 = _0x4F05(_0xCAC0[_0x434E])
if _0x75F5 then _0x1FFF[_0x434E] = _0x75F5 end
end
_0xCF61()
end
local _0x99C5 = type(_0x6727.esp) =="table"and _0x6727.esp or {}
for _0xDCCD, _0x434E in ipairs(_0x2706) do
local _0x75F5 = _0x4F05(_0x99C5[_0x434E])
if _0x75F5 then _0x0556[_0x434E] = _0x75F5 end
end
_0xA41E = _0x4F05(_0x6727.fov) or _0xA41E
local _0xCF40 = type(_0x6727.pos) =="table"and _0x6727.pos or {}
_0xBBF0.hud = _0xC63F(_0xCF40.hud)
_0xBBF0.keylist = _0xC63F(_0xCF40.keylist)
local _0x051B = type(_0x6727.binds) =="table"and _0x6727.binds or {}
for _0xDCCD, _0x4EBC in ipairs(_0x9490) do
local _0x803E = _0x051B[_0x4EBC.id]
if _0x803E ==""then
if _0x4EBC.kind ~="menu"and _0x4EBC.kind ~="panic"then _0x4EBC.input = nil end
elseif _0x803E ~= nil then
local _0x3077 = _0x4B2A(_0x803E)
if _0x3077 then _0x4EBC.input = _0x3077 end
end
end
end
local function _0x99B2(_0x0472)
_0xCB23 = _0x0472
if _0x1807 then _0x1807.Text = _0x0472 end
end
local _0xE8B6 = type(readfile) =="function"and type(writefile) =="function"local _0x8AB5 ="OULMenu_".. tostring(_0x6FE4.UserId) ..".json"local _0xB395 = false
if _0xE8B6 then
local _0x7F83, _0x83BC = pcall(readfile, _0x8AB5)
if _0x7F83 and type(_0x83BC) =="string"and _0x83BC ~=""then
local _0x0C21, _0x5EDF = pcall(function()
return _0xD6C2:JSONDecode(_0x83BC)
end)
if _0x0C21 and type(_0x5EDF) =="table"then
local _0xFF3F, _0xABB0 = pcall(_0xF590, _0x5EDF)
if not _0xFF3F then warn("[OUL save] could not apply the saved file: ".. tostring(_0xABB0)) end
end
end
_0xDB5A = true
_0x99B2("saving: local file")
local function _0x24DB()
local _0x9672, _0x59BD = pcall(function()
return _0xD6C2:JSONEncode(_0xF824())
end)
if not _0x9672 then return false, _0x59BD end
local _0x80CA, _0xABB0 = pcall(writefile, _0x8AB5, _0x59BD)
return _0x80CA, _0xABB0, _0x59BD
end
_0x2ADF = function()
local _0x499B, _0xABB0 = _0x24DB()
_0x99B2(_0x499B and"saved to file"or"save failed (see Output)")
if not _0x499B then warn("[OUL save] ".. tostring(_0xABB0)) end
if _0x9996 then _0x9996(_0x499B and"Settings saved"or"Save failed - see Output") end
end
local _0x1348 = _0xD6C2:JSONEncode(_0xF824())
task.spawn(function()
while _0xE870 do
task.wait(1)
if not _0xE870 then break end
local _0x9672, _0x59BD = pcall(function()
return _0xD6C2:JSONEncode(_0xF824())
end)
if _0x9672 and _0x59BD ~= _0x1348 then
_0x1348 = _0x59BD
local _0x499B, _0xABB0 = pcall(writefile, _0x8AB5, _0x59BD)
_0x99B2(_0x499B and"saved to file"or"save failed (see Output)")
if not _0x499B then warn("[OUL save] ".. tostring(_0xABB0)) end
end
end
end)
else
local _0x6D50 = _0xF6C1:FindFirstChild("OULSaveSettings")
local _0x0E7F = _0xF6C1:WaitForChild("OULLoadSettings", 3)
_0x6D50 = _0x6D50 or _0xF6C1:WaitForChild("OULSaveSettings", 1)
local _0xB1EF = _0xF6C1:FindFirstChild("OULSaveStatus") or _0xF6C1:WaitForChild("OULSaveStatus", 1)
if _0x0E7F and _0x6D50 then
local _0x8711, _0x5A13 = nil, false
task.spawn(function()
local _0x499B, _0xA5EC = pcall(function()
return _0x0E7F:InvokeServer()
end)
if _0x499B then _0x8711 = _0xA5EC end
_0x5A13 = true
end)
local _0xDF42 = os.clock()
while not _0x5A13 and os.clock() - _0xDF42 < 10 do
task.wait()
end
if type(_0x8711) =="table"and _0x8711.loaded then
_0xDB5A = true
_0x99B2("saving: on")
if type(_0x8711.data) =="table"then
local _0x499B, _0xABB0 = pcall(_0xF590, _0x8711.data)
if not _0x499B then warn("[OUL save] could not apply saved settings: ".. tostring(_0xABB0)) end
end
elseif type(_0x8711) =="table"then
_0x99B2("saving off: load failed")
warn("[OUL save] the server could not load your data, so saving is off: ".. tostring(_0x8711.reason))
else
_0x99B2("saving off: no reply")
warn("[OUL save] the server did not answer in time, so saving is off")
end
else
_0x99B2("saving off: no server script")
warn("[OUL save] OULSaveServer not found in ReplicatedStorage/ServerScriptService, so your settings will not be saved")
end
if _0xDB5A then
if _0xB1EF then
_0x32C1(_0xB1EF.OnClientEvent:Connect(function(_0x499B, _0xD635)
if _0x499B then
_0x99B2("saved")
else
_0x99B2("save failed (see Output)")
warn("[OUL save] ".. tostring(_0xD635))
end
if _0xB395 then
_0xB395 = false
if _0x9996 then _0x9996(_0x499B and"Settings saved"or"Save failed - see Output") end
end
end))
end
_0x2ADF = function()
_0xB395 = true
_0x99B2("saving...")
pcall(function()
_0x6D50:FireServer(_0xF824(), true)
end)
end
local _0x1348 = _0xD6C2:JSONEncode(_0xF824())
task.spawn(function()
while _0xE870 do
task.wait(1)
if not _0xE870 then break end
local _0x499B, _0x59BD = pcall(function()
return _0xD6C2:JSONEncode(_0xF824())
end)
if _0x499B and _0x59BD ~= _0x1348 then
_0x1348 = _0x59BD
_0x99B2("saving...")
pcall(function()
_0x6D50:FireServer(_0xF824())
end)
end
end
end)
else
_0x2ADF = function()
if _0x9996 then _0x9996("Saving is off - see the status line") end
end
end
end
local _0xBE51 ="OULConfigs"local _0x6A16 = _0xBE51 .."/_autoload.txt"_0xD1D6.available = _0xE8B6
and type(listfiles) =="function"and type(delfile) =="function"and type(isfolder) =="function"and type(makefolder) =="function"and type(isfile) =="function"local function _0xF0D1(_0xBF13)
return _0xBE51 .."/".. _0xBF13 ..".json"endlocal _0xADE1 ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local _0x1EE3 = {}
for i = 1, 64 do _0x1EE3[_0xADE1:byte(i)] = i - 1 end
local function _0xE68D(_0x5EDF)
local _0xD0D8 = {}
for i = 1, #_0x5EDF, 3 do
local _0x82B5, _0x051B, _0x75F5 = _0x5EDF:byte(i, i + 2)
local _0x54FD = _0x82B5 * 65536 + (_0x051B or 0) * 256 + (_0x75F5 or 0)
local _0x45CC = math.floor(_0x54FD / 262144) % 64
local _0x614C = math.floor(_0x54FD / 4096) % 64
local _0x619B = math.floor(_0x54FD / 64) % 64
local _0x5033 = _0x54FD % 64
_0xD0D8[#_0xD0D8 + 1] = _0xADE1:sub(_0x45CC + 1, _0x45CC + 1)
_0xD0D8[#_0xD0D8 + 1] = _0xADE1:sub(_0x614C + 1, _0x614C + 1)
_0xD0D8[#_0xD0D8 + 1] = _0x051B and _0xADE1:sub(_0x619B + 1, _0x619B + 1) or"="_0xD0D8[#_0xD0D8 + 1] = _0x75F5 and _0xADE1:sub(_0x5033 + 1, _0x5033 + 1) or"="end
return table.concat(_0xD0D8)
end
local function _0x0CA7(str)
str = string.gsub(str,"[^%w%+/]","")
local _0xD0D8 = {}
for i = 1, #str, 4 do
local _0xE4E6, _0xE2B5, _0x3AC1, _0xDCDC = str:byte(i, i + 3)
local _0xA01D, _0x3CEB = _0x1EE3[_0xE4E6], _0x1EE3[_0xE2B5]
local _0x0374, _0x6733 = _0x3AC1 and _0x1EE3[_0x3AC1], _0xDCDC and _0x1EE3[_0xDCDC]
if not _0xA01D or not _0x3CEB then return nil end
if (_0x3AC1 and not _0x0374) or (_0xDCDC and not _0x6733) then return nil end
local _0x54FD = _0xA01D * 262144 + _0x3CEB * 4096 + (_0x0374 or 0) * 64 + (_0x6733 or 0)
_0xD0D8[#_0xD0D8 + 1] = string.char(math.floor(_0x54FD / 65536) % 256)
if _0x0374 then _0xD0D8[#_0xD0D8 + 1] = string.char(math.floor(_0x54FD / 256) % 256) end
if _0x6733 then _0xD0D8[#_0xD0D8 + 1] = string.char(_0x54FD % 256) end
end
return table.concat(_0xD0D8)
end
local _0x91F9 ="OUL1:"function _0xD1D6.exportCode()
local _0x8DA9 = _0xF824()
_0x8DA9.pos = {}
_0x8DA9.settings.RageTarget = nil
_0x8DA9.settings.RadarX, _0x8DA9.settings.RadarY = nil, nil
local _0x499B, _0x59BD = pcall(function() return _0xD6C2:JSONEncode(_0x8DA9) end)
if not _0x499B then return nil, _0x59BD end
return _0x91F9 .. _0xE68D(_0x59BD)
endfunction _0xD1D6.importCode(_0xDB42)
_0xDB42 = string.gsub(tostring(_0xDB42 or""),"%s+","")
if #_0xDB42 > 30000 then return false,"code too long"end
if _0xDB42:sub(1, #_0x91F9) ~= _0x91F9 then return false,"not an OUL code"end
local _0xE48E = _0x0CA7(_0xDB42:sub(#_0x91F9 + 1))
if not _0xE48E or _0xE48E ==""then return false,"code is damaged"end
local _0x499B, _0x5EDF = pcall(function() return _0xD6C2:JSONDecode(_0xE48E) end)
if not _0x499B or type(_0x5EDF) ~="table"or type(_0x5EDF.settings) ~="table"then
return false,"code is damaged"end
local _0x1285, _0x0F50 = _0xBBF0.hud, _0xBBF0.keylist
local _0xFF3F, _0xABB0 = pcall(_0xF590, _0x5EDF)
_0xBBF0.hud, _0xBBF0.keylist = _0x1285, _0x0F50
if not _0xFF3F then return false, _0xABB0 end
return true
endfunction _0xD1D6.clean(_0xBF13)
_0xBF13 = tostring(_0xBF13 or"")
_0xBF13 = _0xBF13:gsub("[^%w%-_ ]",""):gsub("^%s+",""):gsub("%s+$","")
return _0xBF13:sub(1, 24)
end
function _0xD1D6.list()
local _0x06B5 = {}
local _0x499B, _0x6F83 = pcall(listfiles, _0xBE51)
if _0x499B and type(_0x6F83) =="table"then
for _0xDCCD, _0xBF16 in ipairs(_0x6F83) do
local _0x54FD = string.match(_0xBF16,"([^/\\]+)%.json$")
if _0x54FD then _0x06B5[#_0x06B5 + 1] = _0x54FD end
end
end
table.sort(_0x06B5, function(_0x82B5, _0x051B) return _0x82B5:lower() < _0x051B:lower() end)
return _0x06B5
end
function _0xD1D6.save(_0xBF13)
_0xBF13 = _0xD1D6.clean(_0xBF13)
if _0xBF13 ==""then return false,"bad name"end
return pcall(function()
if not isfolder(_0xBE51) then makefolder(_0xBE51) end
writefile(_0xF0D1(_0xBF13), _0xD6C2:JSONEncode(_0xF824()))
end)
end
function _0xD1D6.load(_0xBF13)
return pcall(function()
_0xF590(_0xD6C2:JSONDecode(readfile(_0xF0D1(_0xBF13))))
end)
end
function _0xD1D6.getAutoload()
local _0x499B, _0x803E = pcall(function()
if isfile(_0x6A16) then return readfile(_0x6A16) end
end)
if _0x499B and type(_0x803E) =="string"then
_0x803E = _0xD1D6.clean(_0x803E)
if _0x803E ~=""then return _0x803E end
end
return nil
end
function _0xD1D6.setAutoload(_0xBF13)
return pcall(function()
if not isfolder(_0xBE51) then makefolder(_0xBE51) end
writefile(_0x6A16, _0xBF13 or"")
end)
end
function _0xD1D6.delete(_0xBF13)
return pcall(function()
if isfile(_0xF0D1(_0xBF13)) then delfile(_0xF0D1(_0xBF13)) end
if _0xD1D6.getAutoload() == _0xBF13 then writefile(_0x6A16,"") end
end)
end
if _0xD1D6.available then
local _0x2215 = _0xD1D6.getAutoload()
local _0xD0FA = _0x2215 and select(2, pcall(isfile, _0xF0D1(_0x2215)))
if _0x2215 and _0xD0FA then
local _0x499B, _0xABB0 = _0xD1D6.load(_0x2215)
if not _0x499B then warn("[OUL config] autoload failed: ".. tostring(_0xABB0)) end
end
end
end
_0x3159.step(0.25,"Loading settings")
local _0xE6C4 = {"ragdoll","corpse","dead","bodies","debris","gib"}
local function _0x7DFD(_0x114D)
local _0x9777 = _0x114D:FindFirstChildOfClass("Humanoid")
if not _0x9777 or _0x9777.Health <= 0 then return false end
if _0x9777:GetState() == Enum.HumanoidStateType.Dead then return false end
if _0x114D:GetAttribute("Dead") or _0x114D:GetAttribute("IsDead") or _0x9777:GetAttribute("Dead") then
return false
end
if not _0x8325:GetPlayerFromCharacter(_0x114D) then
if _0x8325:FindFirstChild(_0x114D.Name) then return false end
local _0x7D20 = _0x114D
while _0x7D20 and _0x7D20 ~= workspace do
local _0x54FD = string.lower(_0x7D20.Name)
for _0xDCCD, _0x0866 in ipairs(_0xE6C4) do
if string.find(_0x54FD, _0x0866, 1, true) then return false end
end
_0x7D20 = _0x7D20.Parent
end
end
return true
end
local _0x72FA = {}
task.spawn(function()
while _0xE870 do
local _0xEC0F = {}
for _0xDCCD, _0x6727 in ipairs(workspace:GetDescendants()) do
if _0x6727:IsA("Humanoid") then
local _0x114D = _0x6727.Parent
if _0x114D and _0x114D:IsA("Model") and _0x114D ~= _0x6FE4.Character
and not _0x8325:GetPlayerFromCharacter(_0x114D) and _0x7DFD(_0x114D) then
_0xEC0F[#_0xEC0F + 1] = _0x114D
end
end
end
_0x72FA = _0xEC0F
task.wait(1)
end
end)
local function _0x0AF4()
local _0xEC0F = {}
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
local _0x75F5 = _0x5D5D.Character
_0xEC0F[#_0xEC0F + 1] = { _0x5D5D, (_0x75F5 and _0x7DFD(_0x75F5)) and _0x75F5 or nil }
end
end
if _0xC248.ESPNPCs then
for _0xDCCD, _0x114D in ipairs(_0x72FA) do
if _0x114D.Parent and _0x7DFD(_0x114D) then
_0xEC0F[#_0xEC0F + 1] = { _0x114D, _0x114D }
end
end
end
return _0xEC0F
end
_0x3159.step(0.35,"Setting up ESP")
local _0x6B8C = Instance.new("Folder")
_0x6B8C.Name ="OULESP"_0x6B8C.Parent = workspace
local _0x16AC
do
local _0x4683 = nil
_0x16AC = function()
if _0xC248.Fullbright or _0xC248.NoFog then
if not _0x4683 then
_0x4683 = {
Brightness = _0x1F4A.Brightness,
ClockTime = _0x1F4A.ClockTime,
GlobalShadows = _0x1F4A.GlobalShadows,
OutdoorAmbient = _0x1F4A.OutdoorAmbient,
Ambient = _0x1F4A.Ambient,
FogStart = _0x1F4A.FogStart,
FogEnd = _0x1F4A.FogEnd,
}
end
end
if _0xC248.Fullbright then
_0x1F4A.Brightness = 2
_0x1F4A.ClockTime = 14
_0x1F4A.GlobalShadows = false
_0x1F4A.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
_0x1F4A.Ambient = Color3.fromRGB(200, 200, 200)
elseif _0x4683 then
_0x1F4A.Brightness = _0x4683.Brightness
_0x1F4A.ClockTime = _0x4683.ClockTime
_0x1F4A.GlobalShadows = _0x4683.GlobalShadows
_0x1F4A.OutdoorAmbient = _0x4683.OutdoorAmbient
_0x1F4A.Ambient = _0x4683.Ambient
end
if _0xC248.NoFog then
_0x1F4A.FogStart = 100000
_0x1F4A.FogEnd = 100000
for _0xDCCD, _0x75F5 in ipairs(_0x1F4A:GetChildren()) do
if _0x75F5:IsA("Atmosphere") then
if _0x75F5:GetAttribute("OULOrigDensity") == nil then
_0x75F5:SetAttribute("OULOrigDensity", _0x75F5.Density)
end
_0x75F5.Density = 0
end
end
elseif _0x4683 then
_0x1F4A.FogStart = _0x4683.FogStart
_0x1F4A.FogEnd = _0x4683.FogEnd
for _0xDCCD, _0x75F5 in ipairs(_0x1F4A:GetChildren()) do
if _0x75F5:IsA("Atmosphere") then
_0x75F5.Density = _0x75F5:GetAttribute("OULOrigDensity") or _0x75F5.Density
end
end
end
if not _0xC248.Fullbright and not _0xC248.NoFog then
_0x4683 = nil
end
end
_0x32C1(_0x2C20.Heartbeat:Connect(function()
if (_0xC248.Fullbright or _0xC248.NoFog) and _0x4683 then
_0x16AC()
end
end))
end
do
local _0x33E5 = Instance.new("Frame")
_0x33E5.Name ="OULRadar"_0x33E5.BackgroundTransparency = 1
_0x33E5.AnchorPoint = Vector2.new(0.5, 0.5)
_0x33E5.Size = UDim2.fromOffset(_0xC248.RadarSize, _0xC248.RadarSize)
_0x33E5.Visible = false
_0x33E5.ZIndex = 90
_0x33E5.Parent = _0xD27F
local _0x00AB = false
pcall(function()
if Drawing and Drawing.new then
local _0xCAC0 = Drawing.new("Circle")
_0xCAC0.Visible = false
_0xCAC0:Remove()
_0x00AB = true
end
end)
_0xD1D6.radarMode = _0x00AB and"Drawing"or"GUI"local _0x57DA = Color3.fromRGB(0, 0, 0)
local _0x2C6B = { 1, 2 / 3, 1 / 3 }
local _0x0E00, _0xF4A4 = 16, 50
local function _0x310E(_0xAD48)
local _0x6F78 = workspace.CurrentCamera.ViewportSize
local _0xEF6D = _0xC248.RadarCorner
if _0xEF6D =="Custom"then
if _0xC248.RadarX < 0 or _0xC248.RadarY < 0 then
_0xC248.RadarX = _0x6F78.X - _0x0E00 - _0xAD48
_0xC248.RadarY = _0xF4A4 + _0xAD48
end
return math.clamp(_0xC248.RadarX, _0xAD48, _0x6F78.X - _0xAD48), math.clamp(_0xC248.RadarY, _0xAD48, _0x6F78.Y - _0xAD48)
end
local _0x8383 = (_0xEF6D =="TopLeft"or _0xEF6D =="BottomLeft") and (_0x0E00 + _0xAD48) or (_0x6F78.X - _0x0E00 - _0xAD48)
local _0x3967 = (_0xEF6D =="TopLeft"or _0xEF6D =="TopRight") and (_0xF4A4 + _0xAD48) or (_0x6F78.Y - _0x0E00 - _0xAD48)
return _0x8383, _0x3967
end
local _0xDBC2 = {}
local function _0x402C(_0xFBC4)
local _0x1191 = Drawing.new(_0xFBC4)
_0x1191.Visible = false
_0xDBC2[#_0xDBC2 + 1] = _0x1191
return _0x1191
end
local _0x2ABE, _0x1950, _0x7C14 = {}, {}, nil
if _0x00AB then
for _0xDCCD = 1, #_0x2C6B do
local _0x367F, _0x5FB1 = _0x402C("Circle"), _0x402C("Circle")
for _0xDCCD, _0x75F5 in ipairs({ _0x367F, _0x5FB1 }) do
_0x75F5.NumSides = 64
_0x75F5.Filled = false
end
_0x367F.Color, _0x367F.Transparency = _0x57DA, 0.45
_0x5FB1.Transparency = 1
_0x2ABE[#_0x2ABE + 1] = { _0x367F, _0x5FB1 }
end
for _0xDCCD = 1, 2 do
local _0x367F, _0x5FB1 = _0x402C("Line"), _0x402C("Line")
_0x367F.Color, _0x367F.Transparency = _0x57DA, 0.45
_0x5FB1.Transparency = 0.8
_0x1950[#_0x1950 + 1] = { _0x367F, _0x5FB1 }
end
_0x7C14 = _0x402C("Circle")
_0x7C14.Filled = true
_0x7C14.Radius = 3
_0x7C14.NumSides = 16
_0x7C14.Transparency = 1
end
local _0x38E3, _0xC2A9, _0x3D61 = {}, {}, nil
for _0xDCCD, frac in ipairs(_0x2C6B) do
local _0x2D02 = Instance.new("Frame")
_0x2D02.AnchorPoint = Vector2.new(0.5, 0.5)
_0x2D02.Position = UDim2.fromScale(0.5, 0.5)
_0x2D02.Size = UDim2.fromScale(frac, frac)
_0x2D02.BackgroundTransparency = 1
_0x2D02.ZIndex = 90
_0x2D02.Parent = _0x33E5
Instance.new("UICorner", _0x2D02).CornerRadius = UDim.new(1, 0)
local _0xC09B = Instance.new("UIStroke")
_0xC09B.Transparency = 0.1
_0xC09B.Parent = _0x2D02
_0x38E3[#_0x38E3 + 1] = _0xC09B
end
for i = 1, 2 do
local _0x4883 = Instance.new("Frame")
_0x4883.AnchorPoint = Vector2.new(0.5, 0.5)
_0x4883.Position = UDim2.fromScale(0.5, 0.5)
_0x4883.Size = (i == 1) and UDim2.new(1, 0, 0, 1) or UDim2.new(0, 1, 1, 0)
_0x4883.BackgroundTransparency = 0.3
_0x4883.BorderSizePixel = 0
_0x4883.ZIndex = 90
_0x4883.Parent = _0x33E5
_0xC2A9[#_0xC2A9 + 1] = _0x4883
end
do
local _0xB2A7 = Instance.new("Frame")
_0xB2A7.AnchorPoint = Vector2.new(0.5, 0.5)
_0xB2A7.Position = UDim2.fromScale(0.5, 0.5)
_0xB2A7.Size = UDim2.fromOffset(6, 6)
_0xB2A7.BorderSizePixel = 0
_0xB2A7.ZIndex = 91
_0xB2A7.Parent = _0x33E5
Instance.new("UICorner", _0xB2A7).CornerRadius = UDim.new(1, 0)
_0x3D61 = _0xB2A7
end
local _0x2A83 = {}
local _0xC60A, _0x18A1 = false, Vector2.zero
_0x32C1(_0x85F6.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
if not (_0xC248.Radar and _0xC248.RadarCorner =="Custom") then return end
if _0x85F6.MouseBehavior == Enum.MouseBehavior.LockCenter then return end
local _0xAD48 = _0xC248.RadarSize / 2
local _0x8383, _0x3967 = _0x310E(_0xAD48)
local _0x752D = _0x85F6:GetMouseLocation()
if (_0x752D - Vector2.new(_0x8383, _0x3967)).Magnitude <= _0xAD48 then
_0xC60A = true
_0x18A1 = Vector2.new(_0x8383, _0x3967) - _0x752D
end
end))
local function _0x700C(_0xB92E)
local _0x6727 = _0x2A83[_0xB92E]
if _0x6727 then
pcall(function()
if _0x00AB then _0x6727:Remove() else _0x6727:Destroy() end
end)
if _0x00AB then
for i, _0x1191 in ipairs(_0xDBC2) do
if _0x1191 == _0x6727 then
table.remove(_0xDBC2, i)
break
end
end
end
_0x2A83[_0xB92E] = nil
end
end
local function _0x6817()
for _0xDCCD, _0x1191 in ipairs(_0xDBC2) do
pcall(function() _0x1191.Visible = false end)
end
end
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not _0xC248.Radar then
_0xC60A = false
_0x33E5.Visible = false
if _0x00AB then _0x6817() end
for _0xB92E in pairs(_0x2A83) do _0x700C(_0xB92E) end
return
end
local _0x7B8B = _0xC248.RadarSize
local _0xAD48 = _0x7B8B / 2
if _0xC60A then
if _0xC248.RadarCorner =="Custom"and _0x85F6:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
local _0x752D = _0x85F6:GetMouseLocation() + _0x18A1
_0xC248.RadarX, _0xC248.RadarY = _0x752D.X, _0x752D.Y
else
_0xC60A = false
end
end
local _0x8383, _0x3967 = _0x310E(_0xAD48)
local _0xB7DF = _0xC248.RadarRange
local _0xC1D8 = _0x0556.RadarLines
local _0xFFAC = _0xC248.RadarLineThickness
local _0xB5E5 = _0xC248.RadarDotSize
if _0x00AB then
_0x33E5.Visible = false
for i, frac in ipairs(_0x2C6B) do
local _0x367F, _0x5FB1 = _0x2ABE[i][1], _0x2ABE[i][2]
_0x367F.Position, _0x5FB1.Position = Vector2.new(_0x8383, _0x3967), Vector2.new(_0x8383, _0x3967)
_0x367F.Radius, _0x5FB1.Radius = _0xAD48 * frac, _0xAD48 * frac
_0x367F.Thickness = _0xFFAC + 2
_0x5FB1.Thickness = _0xFFAC
_0x5FB1.Color = _0xC1D8
_0x367F.Visible, _0x5FB1.Visible = true, true
end
for i, _0x7238 in ipairs(_0x1950) do
local _0x29E7, _0x9D52
if i == 1 then
_0x29E7, _0x9D52 = Vector2.new(_0x8383 - _0xAD48, _0x3967), Vector2.new(_0x8383 + _0xAD48, _0x3967)
else
_0x29E7, _0x9D52 = Vector2.new(_0x8383, _0x3967 - _0xAD48), Vector2.new(_0x8383, _0x3967 + _0xAD48)
end
local _0x367F, _0x5FB1 = _0x7238[1], _0x7238[2]
_0x367F.From, _0x367F.To = _0x29E7, _0x9D52
_0x5FB1.From, _0x5FB1.To = _0x29E7, _0x9D52
_0x367F.Thickness = _0xFFAC + 2
_0x5FB1.Thickness = _0xFFAC
_0x5FB1.Color = _0xC1D8
_0x367F.Visible, _0x5FB1.Visible = true, true
end
_0x7C14.Position = Vector2.new(_0x8383, _0x3967)
_0x7C14.Color = _0xC1D8
_0x7C14.Visible = true
else
_0x33E5.Size = UDim2.fromOffset(_0x7B8B, _0x7B8B)
_0x33E5.Position = UDim2.fromOffset(_0x8383, _0x3967)
_0x33E5.Visible = true
for _0xDCCD, _0xC09B in ipairs(_0x38E3) do
_0xC09B.Color = _0xC1D8
_0xC09B.Thickness = _0xFFAC
end
for _0xDCCD, _0x4883 in ipairs(_0xC2A9) do
_0x4883.BackgroundColor3 = _0xC1D8
end
_0x3D61.BackgroundColor3 = _0xC1D8
end
local _0x3FD0 = _0x6FE4.Character
local _0xCCAE = _0x3FD0 and _0x3FD0:FindFirstChild("HumanoidRootPart")
if not _0xCCAE then
for _0xB92E in pairs(_0x2A83) do _0x700C(_0xB92E) end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x0DD5 = _0x0DE2.CFrame.LookVector
local _0x1A03 = Vector3.new(_0x0DD5.X, 0, _0x0DD5.Z)
if _0x1A03.Magnitude < 0.001 then _0x1A03 = Vector3.new(0, 0, -1) end
local _0x44B0 = CFrame.lookAt(Vector3.zero, _0x1A03)
local _0x8DF9 = {}
for _0xDCCD, ent in ipairs(_0x0AF4()) do
local _0xB92E, _0x1DBF = ent[1], ent[2]
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if _0x80EB then
_0x8DF9[_0xB92E] = true
local _0xA43A = _0x80EB.Position - _0xCCAE.Position
local _0xDBFB = _0x44B0:VectorToObjectSpace(Vector3.new(_0xA43A.X, 0, _0xA43A.Z))
local _0x803E = Vector2.new(_0xDBFB.X, _0xDBFB.Z) / _0xB7DF
if _0x803E.Magnitude > 1 then _0x803E = _0x803E.Unit end
local _0x6727 = _0x2A83[_0xB92E]
if _0x00AB then
if not _0x6727 then
_0x6727 = _0x402C("Circle")
_0x6727.Filled = true
_0x6727.NumSides = 16
_0x6727.Transparency = 1
_0x2A83[_0xB92E] = _0x6727
end
_0x6727.Color = _0x0556.Radar
_0x6727.Radius = _0xB5E5 / 2
_0x6727.Position = Vector2.new(_0x8383, _0x3967) + _0x803E * _0xAD48
_0x6727.Visible = true
else
if not _0x6727 then
_0x6727 = Instance.new("Frame")
_0x6727.AnchorPoint = Vector2.new(0.5, 0.5)
_0x6727.BorderSizePixel = 0
_0x6727.ZIndex = 92
_0x6727.Parent = _0x33E5
Instance.new("UICorner", _0x6727).CornerRadius = UDim.new(1, 0)
_0x2A83[_0xB92E] = _0x6727
end
_0x6727.Size = UDim2.fromOffset(_0xB5E5, _0xB5E5)
_0x6727.BackgroundColor3 = _0x0556.Radar
_0x6727.Position = UDim2.fromOffset(_0xAD48 + _0x803E.X * _0xAD48, _0xAD48 + _0x803E.Y * _0xAD48)
end
end
end
for _0xB92E in pairs(_0x2A83) do
if not _0x8DF9[_0xB92E] then _0x700C(_0xB92E) end
end
end))
_0xD1D6.radarCleanup = function()
for _0xDCCD, _0x1191 in ipairs(_0xDBC2) do
pcall(function() _0x1191:Remove() end)
end
_0xDBC2 = {}
_0x2A83 = {}
end
end
local _0xD435 = {}
local _0xD62F = {}
local function _0x9034(_0x5D5D)
local _0xCAC0 = _0xD62F[_0x5D5D]
if _0xCAC0 then
_0xCAC0:Destroy()
_0xD62F[_0x5D5D] = nil
end
end
local function _0x9A3C(_0x5D5D, _0x1DBF)
local _0x9C99 = _0x1DBF:FindFirstChild("Head")
if not _0x9C99 then return end
_0x9034(_0x5D5D)
local _0xFEC6 = Instance.new("BillboardGui")
_0xFEC6.Name ="ESPName"_0xFEC6.Adornee = _0x9C99
_0xFEC6.AlwaysOnTop = true
_0xFEC6.Size = UDim2.fromOffset(200, 20)
_0xFEC6.StudsOffset = Vector3.new(0, 2.2, 0)
_0xFEC6.Enabled = _0xC248.ESP and _0xC248.ShowNames
local _0x7CFA = Instance.new("TextLabel")
_0x7CFA.Name ="Label"_0x7CFA.Size = UDim2.new(1, 0, 1, 0)
_0x7CFA.BackgroundTransparency = 1
_0x7CFA.Text = _0x5D5D.Name
_0x7CFA.Font = Enum.Font.Code
_0x7CFA.TextSize = 13
_0x7CFA.TextColor3 = _0x0556.Name
_0x7CFA.TextStrokeTransparency = 0
_0x7CFA.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_0x7CFA.Parent = _0xFEC6
_0xFEC6.Parent = _0x6B8C
_0xD62F[_0x5D5D] = _0xFEC6
end
local function _0x72F0(_0x5A2F)
_0x0556.Fill = _0x5A2F
for _0xDCCD, _0xCF21 in pairs(_0xD435) do
_0xCF21.FillColor = _0x5A2F
end
end
local function _0x8436(_0x5A2F)
_0x0556.Outline = _0x5A2F
for _0xDCCD, _0xCF21 in pairs(_0xD435) do
_0xCF21.OutlineColor = _0x5A2F
end
end
local function _0x0669(_0x5A2F)
_0x0556.Tracer = _0x5A2F
end
local function _0x3675(_0x5A2F)
_0x0556.Box = _0x5A2F
end
local function _0x9383(_0x5A2F)
_0x0556.BoxFill = _0x5A2F
end
local function _0x5A59(_0x5A2F)
_0x0556.Name = _0x5A2F
for _0xDCCD, _0xFEC6 in pairs(_0xD62F) do
local _0x7CFA = _0xFEC6:FindFirstChild("Label")
if _0x7CFA then
_0x7CFA.TextColor3 = _0x5A2F
end
end
end
local function _0x9A0D(_0x5D5D)
_0x9034(_0x5D5D)
local _0xCF21 = _0xD435[_0x5D5D]
if _0xCF21 then
_0xCF21:Destroy()
_0xD435[_0x5D5D] = nil
end
end
local function _0x38C0(_0x5D5D, _0x1DBF)
_0x9A0D(_0x5D5D)
if not _0x1DBF then return end
local _0xCF21 = Instance.new("Highlight")
_0xCF21.Name ="ESPChams"_0xCF21.Adornee = _0x1DBF
_0xCF21.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
_0xCF21.FillColor = _0x0556.Fill
_0xCF21.OutlineColor = _0x0556.Outline
_0xCF21.FillTransparency = 0.5
_0xCF21.OutlineTransparency = 0
_0xCF21.Enabled = _0xC248.ESP and _0xC248.Chams
_0xCF21.Parent = _0x1DBF
_0xD435[_0x5D5D] = _0xCF21
end
local function _0x1CE0()
local _0x0DE2 = workspace.CurrentCamera
local _0x4A2C = _0x0DE2 and _0x0DE2.CFrame.Position or Vector3.zero
local _0xEC0F = {}
local _0xC157 = {}
for _0xDCCD, ent in ipairs(_0x0AF4()) do
local _0xB92E, _0x1DBF = ent[1], ent[2]
_0xC157[_0xB92E] = true
if _0x1DBF then
local _0xCF21 = _0xD435[_0xB92E]
if not _0xCF21 or not _0xCF21.Parent or _0xCF21.Adornee ~= _0x1DBF then
_0x38C0(_0xB92E, _0x1DBF)
_0xCF21 = _0xD435[_0xB92E]
end
local _0x9C99 = _0x1DBF:FindFirstChild("Head")
local _0xFEC6 = _0xD62F[_0xB92E]
if _0x9C99 and (not _0xFEC6 or not _0xFEC6.Parent or _0xFEC6.Adornee ~= _0x9C99) then
_0x9A3C(_0xB92E, _0x1DBF)
_0xFEC6 = _0xD62F[_0xB92E]
end
if _0xFEC6 then
_0xFEC6.Enabled = _0xC248.ESP and _0xC248.ShowNames
end
local _0x80EB = _0x1DBF:FindFirstChild("HumanoidRootPart") or _0x1DBF.PrimaryPart
local _0xD840 = _0x80EB and (_0x80EB.Position - _0x4A2C).Magnitude or math.huge
if _0xCF21 then
table.insert(_0xEC0F, { _0xCF21 = _0xCF21, _0xD840 = _0xD840, npc = _0xB92E:IsA("Model") })
end
else
_0x9A0D(_0xB92E)
end
end
for _0xB92E in pairs(_0xD435) do
if not _0xC157[_0xB92E] then _0x9A0D(_0xB92E) end
end
for _0xB92E in pairs(_0xD62F) do
if not _0xC157[_0xB92E] then _0x9034(_0xB92E) end
end
table.sort(_0xEC0F, function(_0x82B5, _0x051B)
if _0x82B5.npc ~= _0x051B.npc then return not _0x82B5.npc end
return _0x82B5.dist < _0x051B.dist
end)
for i, item in ipairs(_0xEC0F) do
item.h.Enabled = _0xC248.ESP and _0xC248.Chams and i <= _0xCCA4
end
end
local function _0x6057(_0x5D5D)
if _0x5D5D == _0x6FE4 then return end
_0x32C1(_0x5D5D.CharacterAdded:Connect(function(_0x1DBF)
pcall(function()
_0x38C0(_0x5D5D, _0x1DBF)
_0x1CE0()
end)
task.spawn(function()
_0x1DBF:WaitForChild("HumanoidRootPart", 10)
if _0xE870 and _0x5D5D.Character == _0x1DBF then
pcall(function()
_0x38C0(_0x5D5D, _0x1DBF)
_0x1CE0()
end)
end
end)
end))
_0x32C1(_0x5D5D.CharacterRemoving:Connect(function()
_0x9A0D(_0x5D5D)
end))
if _0x5D5D.Character then
_0x38C0(_0x5D5D, _0x5D5D.Character)
end
end
_0xFE38 = function()
_0x1CE0()
end
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
_0x6057(_0x5D5D)
end
_0x32C1(_0x8325.PlayerAdded:Connect(_0x6057))
_0x32C1(_0x8325.PlayerRemoving:Connect(_0x9A0D))
task.spawn(function()
while _0xE870 do
task.wait(0.25)
local _0x499B, _0xABB0 = pcall(_0x1CE0)
if not _0x499B then
warn("[OUL esp] ".. tostring(_0xABB0))
end
end
end)
_0x3159.step(0.45,"Building interface")
local _0xD27F = Instance.new("ScreenGui")
_0xD27F.Name ="AimbotUI"_0xD27F.ResetOnSpawn = false
_0xD27F.IgnoreGuiInset = true
_0xD27F.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_0xD27F.DisplayOrder = 999999
pcall(function() _0xD27F.OnTopOfCoreBlur = true end)
do
local _0xF571
pcall(function()
if gethui then
_0xF571 = gethui()
else
_0xF571 = game:GetService("CoreGui")
end
end)
local _0x499B = false
if _0xF571 then
_0x499B = pcall(function()
_0xD27F.Parent = _0xF571
end) and _0xD27F.Parent == _0xF571
end
if not _0x499B then
_0xD27F.Parent = _0x6FE4:WaitForChild("PlayerGui")
end
end
local _0x839A = Instance.new("Frame")
_0x839A.AnchorPoint = Vector2.new(0.5, 0.5)
_0x839A.BackgroundTransparency = 1
_0x839A.Size = UDim2.fromOffset(_0xC248.FOV * 2, _0xC248.FOV * 2)
_0x839A.Parent = _0xD27F
Instance.new("UICorner", _0x839A).CornerRadius = UDim.new(1, 0)
local _0xD92F = Instance.new("UIStroke", _0x839A)
_0xD92F.Color = _0xA41E
_0xD92F.Thickness = 1.5
_0xD92F.Transparency = 0.3local _0x199D = Instance.new("Frame")
_0x199D.Name ="OULMenuDim"_0x199D.Size = UDim2.fromScale(1, 1)
_0x199D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0x199D.BackgroundTransparency = 1
_0x199D.BorderSizePixel = 0
_0x199D.Active = false
_0x199D.ZIndex = 0
_0x199D.Parent = _0xD27F
local function _0xEF6D(obj, _0xAD48)
local _0x75F5 = Instance.new("UICorner")
_0x75F5.Parent = obj
_0x4EBC(_0x75F5,"CornerRadius", function()
if _0xC248.UIStyle =="Basic"then return UDim.new(0, 0) end
if _0xC248.UIStyle =="Modern"then return UDim.new(0, math.min(_0xAD48 * 1.8 + 3, 18)) end
return UDim.new(0, _0xAD48)
end)
return _0x75F5
end
local function _0x85AD(obj, transparency, modernT)
local _0x35C0 = Instance.new("UIStroke")
_0x35C0.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x35C0.Parent = obj
_0x4EBC(_0x35C0,"Color", function()
return _0x1FFF.Outline
end)
_0x4EBC(_0x35C0,"Thickness", function()
if _0xC248.UIStyle =="Basic"then return 2 end
return 1
end)
_0x4EBC(_0x35C0,"Transparency", function()
if _0xC248.UIStyle =="Modern"then return modernT or 1 end
return transparency or 0
end)
return _0x35C0
end
local function _0x0D0A(parent, _0x0472, _0x7B8B, _0x129C)
local _0x7238 = Instance.new("TextLabel")
_0x7238.BackgroundTransparency = 1
_0x7238.Text = _0x0472
_0x7238.Font = _0x4B96
_0x7238.TextSize = _0x7B8B or 12
_0x7238.TextXAlignment = Enum.TextXAlignment.Left
_0x8C5B(_0x7238, _0x129C)
_0x7238.Parent = parent
return _0x7238
end
local _0x28CA = 96
local _0x6401 = _0x28CA + 600
local _0x8DE0 = 38
local _0xC1DD = 30
local _0x603C = _0x28CA + 8
local _0x9476 = _0x8DE0 + 8
local function _0xBC15()
if _0xC248.UIStyle =="Basic"then
return 8, _0x8DE0 + _0xC1DD + 8
end
return _0x603C, _0x9476
end
local _0x5FD5 = 18
local _0xAE9A = Instance.new("CanvasGroup")
_0xAE9A.Size = UDim2.fromOffset(_0x6401, 300)
do
local _0x6F78 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
_0xAE9A.Position = UDim2.fromOffset(math.floor((_0x6F78.X - _0x6401) / 2), math.floor((_0x6F78.Y - 300) / 2))
end
_0xAE9A.BorderSizePixel = 0
_0xAE9A.Active = true
_0xAE9A.ZIndex = 100
_0xAE9A.GroupTransparency = 1
_0xAE9A.Visible = false
_0xAE9A.Parent = _0xD27F
_0x4EBC(_0xAE9A,"BackgroundColor3", function()
return _0x1FFF.Background
end)
_0xEF6D(_0xAE9A, 5)
_0x85AD(_0xAE9A, nil, 0.45)
_0xD1D6.uiScale = Instance.new("UIScale")
_0xD1D6.uiScale.Scale = _0xC248.UIScale / 100
_0xD1D6.uiScale.Parent = _0xAE9Ado
local _0xA061 = {
Left = 0, TopLeft = 45, Top = 90, TopRight = 135,
Right = 180, BottomRight = 225, Bottom = 270, BottomLeft = 315,
}
local _0xDDB4 = Instance.new("Frame")
_0xDDB4.Name ="OULBgGradient"_0xDDB4.Size = UDim2.fromScale(1, 1)
_0xDDB4.BackgroundTransparency = 1
_0xDDB4.BorderSizePixel = 0
_0xDDB4.ZIndex = 0
_0xDDB4.Parent = _0xAE9A
local _0x44B0 = Instance.new("Frame")
_0x44B0.Size = UDim2.fromScale(1, 1)
_0x44B0.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0x44B0.BorderSizePixel = 0
_0x44B0.ZIndex = 1
_0x44B0.Parent = _0xDDB4
local _0x0C99 = Instance.new("UIGradient")
_0x0C99.Parent = _0x44B0
local _0xD1E7 = Instance.new("Frame")
_0xD1E7.Size = UDim2.fromScale(1, 1)
_0xD1E7.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0xD1E7.BorderSizePixel = 0
_0xD1E7.ZIndex = 2
_0xD1E7.Parent = _0xDDB4
local _0x3E3F = Instance.new("UIGradient")
_0x3E3F.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.05),
NumberSequenceKeypoint.new(0.5, 1),
NumberSequenceKeypoint.new(1, 0.05),
})
_0x3E3F.Parent = _0xD1E7_0xD1D6.updateBG = function(full)
_0xDDB4.Visible = _0xC248.BGGradient
local _0xA817 = Color3.fromRGB(0, 0, 0)
local _0x75F5 = _0x0556.BGGrad:Lerp(_0xA817, 1 - _0xC248.BGGradBright / 100)
local _0xEFA8 = _0x75F5:Lerp(_0xA817, 0.6)
local _0x75A9 = _0xC248.BGGradMirror and _0x75F5 or _0xA817
_0x0C99.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, _0x75F5),
ColorSequenceKeypoint.new(0.5, _0xEFA8),
ColorSequenceKeypoint.new(1, _0x75A9),
})
local _0x4D48 = _0xA061[_0xC248.BGGradDir] or 135
_0x0C99.Rotation = _0x4D48
_0x3E3F.Rotation = _0x4D48 + 90
if full then _0xD514() end
end
_0xD1D6.updateBG(false)
enddo
local _0x337B = Instance.new("Frame")
_0x337B.Size = UDim2.new(1, 0, 0, 2)
_0x337B.BorderSizePixel = 0
_0x337B.ZIndex = 5
_0x337B.Parent = _0xAE9A
_0x4EBC(_0x337B,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0x4EBC(_0x337B,"BackgroundTransparency", function()
return _0xC248.UIStyle =="Modern"and 1 or 0
end)
end
local _0xDE16 = Instance.new("Frame")
_0xDE16.Size = UDim2.new(1, 0, 0, _0x8DE0)
_0xDE16.BackgroundTransparency = 1
_0xDE16.Active = true
_0xDE16.Parent = _0xAE9A
_0xACD6(_0xDE16, 26, 10, (_0x8DE0 - 26) / 2)
do
local _0xCAC0 = _0x0D0A(_0xDE16,"", 14)
_0xCAC0.Name ="OULHeaderTitle"_0xCAC0.Position = UDim2.fromOffset(44, 4)
_0xCAC0.Size = UDim2.fromOffset(280, 17)
_0xCAC0.Visible = false
pcall(function()
_0xCAC0.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)
local _0x08C3 = _0x0D0A(_0xDE16,"", 10, true)
_0x08C3.Name ="OULHeaderSub"_0x08C3.Position = UDim2.fromOffset(44, 21)
_0x08C3.Size = UDim2.fromOffset(280, 13)
_0x08C3.TextTruncate = Enum.TextTruncate.AtEnd
_0x08C3.Visible = false
_0xD1D6.hdrTitle, _0xD1D6.hdrSub = _0xCAC0, _0x08C3
end
local _0x1BF4 = {"combat","visuals","movement","themes","settings"}
local _0x6765 = { combat ="Combat", visuals ="Visuals", movement ="Movement", themes ="Themes", settings ="Settings"}
local _0x08F2 = {
combat = {
{ id ="aimbot", _0x7465 ="Aimbot"},
{ id ="trigger", _0x7465 ="Triggerbot"},
{ id ="antikatana", _0x7465 ="Antikatana"},
{ id ="ragebot", _0x7465 ="Ragebot"},
},
visuals = { { id ="esp", _0x7465 ="ESP"}, { id ="preview", _0x7465 ="Preview"}, { id ="colours", _0x7465 ="Colours"}, { id ="sky", _0x7465 ="Sky"}, { id ="radar", _0x7465 ="Radar"}, { id ="world", _0x7465 ="World"} },
themes = { { id ="style", _0x7465 ="Style"}, { id ="background", _0x7465 ="Background"} },
settings = { { id ="general", _0x7465 ="General"}, { id ="keybinds", _0x7465 ="Keybinds"}, { id ="configs", _0x7465 ="Configs"} },
movement = { { id ="fly", _0x7465 ="Fly"}, { id ="vortex", _0x7465 ="Vortex"}, { id ="noclip", _0x7465 ="Noclip"}, { id ="speed", _0x7465 ="Speed"}, { id ="jump", _0x7465 ="Jump"}, { id ="mousetp", _0x7465 ="Mouse TP"} },
}
local _0xBFFE = 26
local _0x67D4 = 80
local _0xA72A = Instance.new("Frame")
_0xA72A.Size = UDim2.new(0, _0x28CA, 1, -(_0x8DE0 + _0x5FD5))
_0xA72A.Position = UDim2.fromOffset(0, _0x8DE0)
_0xA72A.BackgroundTransparency = 1
_0xA72A.Parent = _0xAE9A
do
local _0x9892 = Instance.new("Frame")
_0x9892.Name ="OULTabLine"_0x9892.Size = UDim2.new(0, 1, 1, -(_0x8DE0 + _0x5FD5))
_0x9892.Position = UDim2.fromOffset(_0x28CA, _0x8DE0)
_0x9892.BorderSizePixel = 0
_0x9892.Parent = _0xAE9A
_0x4EBC(_0x9892,"BackgroundColor3", function()
return _0x1FFF.Outline
end)
end
do
local _0x9BD8 = Instance.new("Frame")
_0x9BD8.Size = UDim2.new(1, 0, 0, 1)
_0x9BD8.Position = UDim2.fromOffset(0, _0x8DE0)
_0x9BD8.BorderSizePixel = 0
_0x9BD8.Parent = _0xAE9A
_0x4EBC(_0x9BD8,"BackgroundColor3", function()
return _0x1FFF.Outline
end)
end
local _0x7C46 = Instance.new("Frame")
_0x7C46.Size = UDim2.fromOffset(2, _0xC1DD - 8)
_0x7C46.Position = UDim2.fromOffset(0, 11)
_0x7C46.BorderSizePixel = 0
_0x7C46.ZIndex = 3
_0x7C46.Parent = _0xA72A
_0x4EBC(_0x7C46,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0xEF6D(_0x7C46, 1)
do
local _0xEC0E = Instance.new("Frame")
_0xEC0E.Name ="OULTabPill"_0xEC0E.BorderSizePixel = 0
_0xEC0E.ZIndex = 0
_0xEC0E.Visible = false
_0xEC0E.BackgroundTransparency = 0.82
_0xEC0E.Size = UDim2.new(1, -12, 0, _0xC1DD - 2)
_0xEC0E.Position = UDim2.fromOffset(6, 8)
_0xEC0E.Parent = _0xA72A
_0x4EBC(_0xEC0E,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0xEF6D(_0xEC0E, 4)
_0xD1D6.tabPill = _0xEC0E
end
do
local _0x9E38 = _0x0D0A(_0xAE9A,"", 11, true)
_0x9E38.Name ="OULFooter"_0x9E38.AnchorPoint = Vector2.new(0, 1)
_0x9E38.Position = UDim2.new(0, _0x603C, 1, -5)
_0x9E38.Size = UDim2.new(1, -(_0x603C + 8), 0, 12)
_0x18F9(_0x9E38, function()
return _0x8406(_0xACF9("menu").input) .."  -  hide / show menu"end)
end
local _0x5904 = Instance.new("TextLabel")
_0x5904.Size = UDim2.fromOffset(112, 32)
_0x5904.AnchorPoint = Vector2.new(1, 0)
_0x5904.Position = _0xBBF0.hud or UDim2.new(1, -10, 0, 8)
_0x5904.BackgroundTransparency = 0.15
_0x5904.BorderSizePixel = 0
_0x5904.Text ="FPS : --"_0x5904.TextXAlignment = Enum.TextXAlignment.Right
do
local _0xC603 = Instance.new("UIPadding")
_0xC603.PaddingRight = UDim.new(0, 12)
_0xC603.Parent = _0x5904
end
_0x5904.Font = _0x4B96
_0x5904.TextSize = 12
_0x5904.Visible = _0xC248.Watermark
_0x5904.ZIndex = 100
_0x5904.Parent = _0xD27F
_0x4EBC(_0x5904,"BackgroundColor3", function()
return _0x1FFF.Background
end)
_0x8C5B(_0x5904)
_0xEF6D(_0x5904, 4)
_0xACD6(_0x5904, 24, 6, 4)
do
local _0x35C0 = Instance.new("UIStroke")
_0x35C0.Thickness = 1
_0x35C0.Transparency = 0.35
_0x35C0.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x35C0.Parent = _0x5904
_0x4EBC(_0x35C0,"Color", function()
return _0x1FFF.Accent
end)
end
do
_0x5904.Active = true
local _0xC60A, _0x413F, _0xD762
_0x5904.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A, _0x413F, _0xD762 = true, _0x862B.Position, _0x5904.Position
end
end)
_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and _0x862B.UserInputType == Enum.UserInputType.MouseMovement then
local _0x6727 = _0x862B.Position - _0x413F
_0x5904.Position = UDim2.new(_0xD762.X.Scale, _0xD762.X.Offset + _0x6727.X, _0xD762.Y.Scale, _0xD762.Y.Offset + _0x6727.Y)
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
if _0xC60A then
_0xBBF0.hud = _0x5904.Position
end
_0xC60A = false
end
end))
end
do
local _0x03D3, _0xC17E = 0, 0
_0x32C1(_0x2C20.RenderStepped:Connect(function(dt)
_0x03D3 += 1
_0xC17E += dt
if _0xC17E >= 0.5 then
_0x5904.Text ="FPS : ".. math.floor(_0x03D3 / _0xC17E + 0.5)
_0x03D3, _0xC17E = 0, 0
end
end))
end
local _0xC8CB = Instance.new("Frame")
_0xC8CB.Name ="KeybindList"_0xC8CB.Size = UDim2.fromOffset(150, 0)
_0xC8CB.AutomaticSize = Enum.AutomaticSize.XY
_0xC8CB.Position = _0xBBF0.keylist or UDim2.new(0, 10, 0.35, 0)
_0xC8CB.BackgroundTransparency = 0.15
_0xC8CB.BorderSizePixel = 0
_0xC8CB.Active = true
_0xC8CB.Visible = _0xC248.KeybindList
_0xC8CB.ZIndex = 100
_0xC8CB.Parent = _0xD27F
_0x4EBC(_0xC8CB,"BackgroundColor3", function()
return _0x1FFF.Background
end)
_0xEF6D(_0xC8CB, 4)
do
local _0x35C0 = Instance.new("UIStroke")
_0x35C0.Thickness = 1
_0x35C0.Transparency = 0.35
_0x35C0.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x35C0.Parent = _0xC8CB
_0x4EBC(_0x35C0,"Color", function()
return _0x1FFF.Accent
end)
local _0xC725 = Instance.new("UIListLayout")
_0xC725.SortOrder = Enum.SortOrder.LayoutOrder
_0xC725.Padding = UDim.new(0, 2)
_0xC725.Parent = _0xC8CB
local _0xD50E = Instance.new("UIPadding")
_0xD50E.PaddingTop = UDim.new(0, 5)
_0xD50E.PaddingBottom = UDim.new(0, 6)
_0xD50E.PaddingLeft = UDim.new(0, 8)
_0xD50E.PaddingRight = UDim.new(0, 8)
_0xD50E.Parent = _0xC8CB
end
do
local _0x9C99 = _0x0D0A(_0xC8CB,"Keybinds", 12)
_0x9C99.Size = UDim2.fromOffset(0, 16)
_0x9C99.AutomaticSize = Enum.AutomaticSize.X
_0x9C99.LayoutOrder = 0
_0x9C99.ZIndex = 101
_0x4EBC(_0x9C99,"TextColor3", function()
return _0x1FFF.Accent
end)
pcall(function()
_0x9C99.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)
end
do
local _0xC60A, _0x413F, _0xD762
_0xC8CB.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A, _0x413F, _0xD762 = true, _0x862B.Position, _0xC8CB.Position
end
end)
_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and _0x862B.UserInputType == Enum.UserInputType.MouseMovement then
local _0x6727 = _0x862B.Position - _0x413F
_0xC8CB.Position = UDim2.new(_0xD762.X.Scale, _0xD762.X.Offset + _0x6727.X, _0xD762.Y.Scale, _0xD762.Y.Offset + _0x6727.Y)
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
if _0xC60A then
_0xBBF0.keylist = _0xC8CB.Position
end
_0xC60A = false
end
end))
end
do
local _0x134C = { menu = true, panic = true, Watermark = true, BlurEnabled = true, Notifications = true, KeybindList = true }
local _0x03B9 = {}
local _0xC56E
local _0xD53A = 0
local function _0x62ED()
local _0x0930, _0xF628 = {}, {}
for _0xDCCD, _0x051B in ipairs(_0x9490) do
if _0x051B.input and not _0x134C[_0x051B.id] then
local _0x27BA, _0xFEC6
if _0x051B.kind =="toggle"then
_0x27BA, _0xFEC6 = _0xC248[_0x051B.key] and true or false,"Toggle"elseif _0x051B.kind =="hold"then
_0x27BA, _0xFEC6 = _0xC248.Holding and true or false, (_0xC248.AimMode =="Toggle") and"Toggle"or"Hold"else
_0x27BA, _0xFEC6 = false,"Press"end
local _0xBF13 = string.gsub(_0x051B.label,"%s*%(hold%)","")
local _0x0472 ="[".. _0x8406(_0x051B.input) .."] ".. _0xBF13 .." (".. _0xFEC6 ..")"_0x0930[#_0x0930 + 1] = { _0x0472 = _0x0472, _0x27BA = _0x27BA }
_0xF628[#_0xF628 + 1] = _0x0472 .. (_0x27BA and"1"or"0")
end
end
local _0x35C0 = table.concat(_0xF628,"|")
if _0x35C0 == _0xC56E then return end
_0xC56E = _0x35C0
for _0xDCCD, _0xAD48 in ipairs(_0x03B9) do
_0xAD48:Destroy()
end
_0x03B9 = {}
for i, _0x99C5 in ipairs(_0x0930) do
local _0x7238 = Instance.new("TextLabel")
_0x7238.BackgroundTransparency = 1
_0x7238.Size = UDim2.fromOffset(0, 14)
_0x7238.AutomaticSize = Enum.AutomaticSize.X
_0x7238.LayoutOrder = i
_0x7238.Font = _0x4B96
_0x7238.TextSize = 12
_0x7238.TextXAlignment = Enum.TextXAlignment.Left
_0x7238.Text = _0x99C5.text
_0x7238.TextColor3 = _0x99C5.on and _0x1FFF.Accent or _0x1FFF.Dim
_0x7238.ZIndex = 101
_0x7238.Parent = _0xC8CB
_0x03B9[i] = _0x7238
end
end
_0x63C7(function()
_0xC56E = nil
end)
_0x32C1(_0x2C20.Heartbeat:Connect(function(dt)
_0xD53A += dt
if _0xD53A < 0.1 then return end
_0xD53A = 0
if _0xC248.KeybindList then
_0x62ED()
end
end))
end
do
local _0xC60A, _0x413F, _0xD762
_0xDE16.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A, _0x413F, _0xD762 = true, _0x862B.Position, _0xAE9A.Position
end
end)
_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and _0x862B.UserInputType == Enum.UserInputType.MouseMovement then
local _0x6727 = _0x862B.Position - _0x413F
_0xAE9A.Position = UDim2.fromOffset(_0xD762.X.Offset + _0x6727.X, _0xD762.Y.Offset + _0x6727.Y)
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A = false
end
end))
end
local _0x5EE6 = Instance.new("Frame")
_0x5EE6.Name ="Toasts"_0x5EE6.BackgroundTransparency = 1
_0x5EE6.AnchorPoint = Vector2.new(1, 1)
_0x5EE6.Position = UDim2.new(1, -14, 1, -14)
_0x5EE6.Size = UDim2.fromOffset(270, 260)
_0x5EE6.ZIndex = 200
_0x5EE6.Parent = _0xD27F
do
local _0x15DE = Instance.new("UIListLayout")
_0x15DE.SortOrder = Enum.SortOrder.LayoutOrder
_0x15DE.VerticalAlignment = Enum.VerticalAlignment.Bottom
_0x15DE.HorizontalAlignment = Enum.HorizontalAlignment.Right
_0x15DE.Padding = UDim.new(0, 6)
_0x15DE.Parent = _0x5EE6
end
local _0xA520 = 0
local _0x8485 = {}
_0x9996 = function(richText)
_0xA520 += 1
local _0xCAC0 = Instance.new("CanvasGroup")
_0xCAC0.Size = UDim2.fromOffset(260, 0)
_0xCAC0.AutomaticSize = Enum.AutomaticSize.Y_0xCAC0.BorderSizePixel = 0
_0xCAC0.GroupTransparency = 1
_0xCAC0.LayoutOrder = _0xA520
_0xCAC0.ZIndex = 200
_0xCAC0.Parent = _0x5EE6
_0x4EBC(_0xCAC0,"BackgroundColor3", function()
return _0x1FFF.Background
end)
_0xEF6D(_0xCAC0, 4)
local _0xAC75 = _0x85AD(_0xCAC0, 0.2)
_0x4EBC(_0xAC75,"Color", function()
return _0x1FFF.Accent
end)
local _0x7238 = Instance.new("TextLabel")
_0x7238.BackgroundTransparency = 1
_0x7238.Size = UDim2.new(1, 0, 0, 16)
_0x7238.AutomaticSize = Enum.AutomaticSize.Y
_0x7238.TextWrapped = true
_0x7238.Font = _0x4B96
_0x7238.TextSize = 12
_0x7238.RichText = true
_0x7238.Text = richText
_0x7238.ZIndex = 201
_0x7238.Parent = _0xCAC0
_0x8C5B(_0x7238)
do
local _0x5EA1 = Instance.new("UIPadding")
_0x5EA1.PaddingLeft = UDim.new(0, 8)
_0x5EA1.PaddingRight = UDim.new(0, 8)
_0x5EA1.PaddingTop = UDim.new(0, 5)
_0x5EA1.PaddingBottom = UDim.new(0, 5)
_0x5EA1.Parent = _0xCAC0
end
_0x8485[#_0x8485 + 1] = _0xCAC0
while #_0x8485 > 5 do
local _0xCAE5 = table.remove(_0x8485, 1)
pcall(function() _0xCAE5:Destroy() end)
end
_0x6884(_0xCAC0, { GroupTransparency = 0 }, _0xCFE3)
task.delay(2.2, function()
if _0xCAC0.Parent then
_0x6884(_0xCAC0, { GroupTransparency = 1 }, TweenInfo.new(0.3))
task.delay(0.35, function()
pcall(function() _0xCAC0:Destroy() end)
end)
end
end)
end
_0x0E49 = function(_0xBF13, _0x27BA)
if not _0xC248.Notifications then return end
local _0x5A2F = _0x27BA and"rgb(90,200,120)"or"rgb(235,90,90)"_0x9996(_0xBF13 .."  <font color=\"".. _0x5A2F .."\">".. (_0x27BA and"ON"or"OFF") .."</font>")
end
local _0x6EEE = _0x1F4A:FindFirstChild("OULMenuBlur") or Instance.new("BlurEffect")
_0x6EEE.Name ="OULMenuBlur"_0x6EEE.Size = 0
_0x6EEE.Parent = _0x1F4A
local _0x33EE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _0x8C4E = false
local _0xA197 = 0
local _0x8ED5, _0x7612
local function _0x80F0()
local _0xA729 = (_0x8C4E and _0xC248.BlurEnabled) and _0xC248.BlurAmount or 0
_0x4BE0:Create(_0x6EEE, _0x33EE, { Size = _0xA729 }):Play()
end
do
local _0xA8AA = Instance.new("TextButton")
_0xA8AA.Size = UDim2.fromOffset(0, 0)
_0xA8AA.BackgroundTransparency = 1
_0xA8AA.Text =""_0xA8AA.Modal = true
_0xA8AA.Parent = _0xAE9A
end
local function _0x6FF4(_0xAE1F)
if _0xAE1F and not _0x8C4E then
_0x8ED5 = _0x85F6.MouseBehavior
_0x7612 = _0x85F6.MouseIconEnabled
elseif not _0xAE1F and _0x8C4E and _0x8ED5 then
_0x85F6.MouseBehavior = _0x8ED5
_0x85F6.MouseIconEnabled = _0x7612
_0x8ED5 = nil
end
_0x8C4E = _0xAE1F
_0xA197 += 1
local _0x6F30 = _0xA197
if _0xAE1F then
_0xAE9A.Visible = true
_0x6884(_0xAE9A, { GroupTransparency = _0xC248.UITransparency / 100 }, _0xCFE3)
_0x6884(_0x199D, { BackgroundTransparency = 0.5 }, _0xCFE3)
else
_0x6884(_0xAE9A, { GroupTransparency = 1 }, _0x87A6)
_0x6884(_0x199D, { BackgroundTransparency = 1 }, _0x87A6)
task.delay(_0x87A6.Time, function()
if _0xA197 == _0x6F30 then
_0xAE9A.Visible = false
end
end)
end
_0x80F0()
end
_0x2C20:BindToRenderStep("OULMenuMouse", Enum.RenderPriority.Last.Value, function()
if _0x8C4E then
_0x85F6.MouseBehavior = Enum.MouseBehavior.Default
_0x85F6.MouseIconEnabled = true
end
end)
local _0x40B9 = {}
local _0x53CF = setmetatable({}, { __mode ="k"})
local function _0x2A2C(parent)
local _0x54FD = (_0x53CF[parent] or 0) + 1
_0x53CF[parent] = _0x54FD
return _0x54FD
end
local _0xA0EA = {}
local _0xF3C9 = {}
local _0x1D79 = setmetatable({}, { __mode ="k"})
local function _0x894E(parent, _0x0472)
local _0x1371 = _0x1D79[parent]
if _0x1371 and _0x0472 and _0x0472 ~=""then
_0xF3C9[#_0xF3C9 + 1] = { _0x0472 = _0x0472, _0x2153 = _0x1371.name }
end
end
local _0x8B85
local _0x8CF4
local _0x928D = { combat ="aimbot", visuals ="esp", movement ="fly", themes ="style", settings ="general"}
local _0x9AC1 = {}
local _0xB9B7
local function _0x6BFC(_0xBF13, hasSubs)
local _0x34A5 = Instance.new("CanvasGroup")
_0x34A5.BackgroundTransparency = 1
_0x34A5.BorderSizePixel = 0
_0x34A5.Position = UDim2.fromOffset(_0x603C, _0x9476 + (hasSubs and _0xBFFE or 0))
_0x34A5.Size = UDim2.new(1, -(_0x603C + 8), 0, 100)
_0x34A5.GroupTransparency = 1
_0x34A5.Visible = false
_0x34A5.Parent = _0xAE9A
local _0xB13A = {}
for i = 1, 4 do
local _0xD4F0 = Instance.new("Frame")
_0xD4F0.BackgroundTransparency = 1
_0xD4F0.Size = UDim2.new(0.5, -4, 0, 0)
_0xD4F0.AutomaticSize = Enum.AutomaticSize.Y
_0xD4F0.Position = UDim2.new((i - 1) * 0.5, (i - 1) * 4, 0, 0)
_0xD4F0.Parent = _0x34A5
local _0xC725 = Instance.new("UIListLayout")
_0xC725.Padding = UDim.new(0, 8)
_0xC725.SortOrder = Enum.SortOrder.LayoutOrder
_0xC725.Parent = _0xD4F0
_0xC725:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
if _0xB9B7 then _0xB9B7(false) end
end)
_0xB13A[i] = { _0x34A5 = _0xD4F0, _0xC725 = _0xC725 }
end
local _0x2153 = { _0xBF13 = _0xBF13, _0x34A5 = _0x34A5, _0xB13A = _0xB13A, subOffset = hasSubs and _0xBFFE or 0 }
_0xA0EA[_0xBF13] = _0x2153
return _0x2153
end
local function _0xCD1A(_0x2153, colIndex, titleText)
local _0xD4F0 = _0x2153.cols[colIndex].frame
local _0x66D9 = Instance.new("Frame")
_0x66D9.Size = UDim2.new(1, 0, 0, 0)
_0x66D9.AutomaticSize = Enum.AutomaticSize.Y
_0x66D9.BorderSizePixel = 0
_0x66D9.LayoutOrder = _0x2A2C(_0xD4F0)
_0x66D9:SetAttribute("OULHome", colIndex)
_0x66D9:SetAttribute("OULOrd", _0x66D9.LayoutOrder)
_0x66D9.Parent = _0xD4F0
_0x4EBC(_0x66D9,"BackgroundColor3", function()
return _0x1FFF.Group
end)
_0x4EBC(_0x66D9,"BackgroundTransparency", function()
return _0xC248.BGGradient and 0.4 or 0
end)
_0xEF6D(_0x66D9, 4)
_0x85AD(_0x66D9, nil, 0.72)
local _0x9C99 = _0x0D0A(_0x66D9, titleText, 12)
_0x9C99.Size = UDim2.new(1, 0, 0, 20)
_0x9C99.TextXAlignment = Enum.TextXAlignment.Center
_0x9C99.TextTruncate = Enum.TextTruncate.AtEnd
local function _0x1939(animate)
local _0xDFF5 = _0xC248.UIStyle =="Modern"_0x9C99.TextXAlignment = _0xDFF5 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
_0x91F0(_0x9C99, {
Position = UDim2.fromOffset(_0xDFF5 and 22 or 0, 0),
Size = UDim2.new(1, _0xDFF5 and -42 or 0, 0, 20),
}, animate)
end
_0x1939(false)
_0x63C7(function() _0x1939(true) end)
pcall(function()
_0x9C99.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)
local _0x4883 = Instance.new("Frame")
_0x4883.Position = UDim2.fromOffset(0, 20)
_0x4883.BorderSizePixel = 0
_0x4883.Parent = _0x66D9
_0x4EBC(_0x4883,"BackgroundColor3", function()
if _0xC248.UIStyle =="Basic"then return _0x1FFF.Accent end
return _0x1FFF.Outline
end)
_0x4EBC(_0x4883,"BackgroundTransparency", function()
if _0xC248.UIStyle =="Basic"then return 0 end
if _0xC248.UIStyle =="Modern"then return 0.7 end
return 0.4
end)
_0x4EBC(_0x4883,"Size", function()
if _0xC248.UIStyle =="Basic"then return UDim2.new(1, 0, 0, 3) end
return UDim2.new(1, 0, 0, 1)
end)
local _0x83BC = Instance.new("Frame")
_0x83BC.BackgroundTransparency = 1
_0x83BC.Position = UDim2.fromOffset(0, 21)
_0x83BC.Size = UDim2.new(1, 0, 0, 0)
_0x83BC.AutomaticSize = Enum.AutomaticSize.Y
_0x83BC.Parent = _0x66D9
local _0xC725 = Instance.new("UIListLayout")
_0xC725.Padding = UDim.new(0, 4)
_0xC725.SortOrder = Enum.SortOrder.LayoutOrder
_0xC725.Parent = _0x83BC
local _0xD50E = Instance.new("UIPadding")
_0xD50E.PaddingTop = UDim.new(0, 6)
_0xD50E.PaddingBottom = UDim.new(0, 7)
_0xD50E.PaddingLeft = UDim.new(0, 8)
_0xD50E.PaddingRight = UDim.new(0, 8)
_0xD50E.Parent = _0x83BC
do
local function _0xE8FB(obj)
_0x4EBC(obj,"BackgroundTransparency", function()
return _0xC248.UIStyle =="Modern"and 0 or 1
end)
end
local _0x2365 = Instance.new("Frame")
_0x2365.AnchorPoint = Vector2.new(0, 0.5)
_0x2365.Position = UDim2.fromOffset(9, 10)
_0x2365.Size = UDim2.fromOffset(4, 10)
_0x2365.BorderSizePixel = 0
_0x2365.Parent = _0x66D9
Instance.new("UICorner", _0x2365).CornerRadius = UDim.new(1, 0)
_0x4EBC(_0x2365,"BackgroundColor3", function() return _0x1FFF.Accent end)
_0xE8FB(_0x2365)
local _0x49F6 = Instance.new("Frame")
_0x49F6.BackgroundTransparency = 1
_0x49F6.BorderSizePixel = 0
_0x49F6.AnchorPoint = Vector2.new(1, 0.5)
_0x49F6.Position = UDim2.new(1, -8, 0, 10)
_0x49F6.Size = UDim2.fromOffset(12, 12)
_0x49F6.Parent = _0x66D9
for i = 1, 2 do
local _0x051B = Instance.new("Frame")
_0x051B.AnchorPoint = Vector2.new(0.5, 0.5)
_0x051B.Size = UDim2.fromOffset(7, 2)
_0x051B.Position = UDim2.fromOffset(i == 1 and 4 or 9, 6)
_0x051B.Rotation = i == 1 and -40 or 40
_0x051B.BorderSizePixel = 0
_0x051B.Parent = _0x49F6
_0x4EBC(_0x051B,"BackgroundColor3", function() return _0x1FFF.Dim end)
_0xE8FB(_0x051B)
end
local _0xADC3 = Instance.new("TextButton")
_0xADC3.BackgroundTransparency = 1
_0xADC3.Text =""_0xADC3.AutoButtonColor = false
_0xADC3.Size = UDim2.new(1, 0, 0, 20)
_0xADC3.ZIndex = 5
_0xADC3.Parent = _0x66D9
local _0x65C4 = false
local function _0xB8BE(_0x75F5, animate)
_0x65C4 = _0x75F5
_0x83BC.Visible = not _0x75F5
_0x83BC.AutomaticSize = _0x75F5 and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
_0x83BC.Size = UDim2.new(1, 0, 0, 0)
_0x91F0(_0x49F6, { Rotation = _0x75F5 and 180 or 0 }, animate)
end
_0xADC3.MouseButton1Click:Connect(function()
if _0xC248.UIStyle =="Modern"then
_0xB8BE(not _0x65C4, true)
end
end)if titleText =="Info"and _0xC248.UIStyle =="Modern"then
_0xB8BE(true, false)
end
_0x63C7(function()
if _0x65C4 and _0xC248.UIStyle ~="Modern"then
_0xB8BE(false, true)
end
end)
end
_0x1D79[_0x83BC] = _0x2153
return _0x83BC
end
local function _0x8649(parent, _0x0472)
local _0x7238 = _0x0D0A(parent, _0x0472, 11, true)
_0x7238.Size = UDim2.new(1, 0, 0, 14)
_0x7238.LayoutOrder = _0x2A2C(parent)
return _0x7238
end
local function _0xCEB3(parent, _0x0472, _0xB92E, onChanged)
_0x894E(parent, _0x0472)
local _0x8BD7 = Instance.new("TextButton")
_0x8BD7.Size = UDim2.new(1, 0, 0, 20)
_0x8BD7.BackgroundTransparency = 1
_0x8BD7.Text =""_0x8BD7.AutoButtonColor = false
_0x8BD7.LayoutOrder = _0x2A2C(parent)
_0x8BD7.Parent = parent
local _0x8183 = Instance.new("Frame")
_0x8183.Size = UDim2.fromOffset(14, 14)
_0x8183.AnchorPoint = Vector2.new(0, 0.5)
_0x8183.Position = UDim2.new(0, 0, 0.5, 0)
_0x8183.BorderSizePixel = 0
_0x8183.Parent = _0x8BD7
_0xEF6D(_0x8183, 3)
local _0xAC75 = _0x85AD(_0x8183, 0.2)
local _0x1426 = Instance.new("Frame")
_0x1426.Size = UDim2.fromOffset(0, 0)
_0x1426.AnchorPoint = Vector2.new(0.5, 0.5)
_0x1426.Position = UDim2.new(0.5, 0, 0.5, 0)
_0x1426.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0x1426.BorderSizePixel = 0
_0x1426.Parent = _0x8183
_0xEF6D(_0x1426, 2)
local _0x7465 = _0x0D0A(_0x8BD7, _0x0472, 12)
_0x7465.Position = UDim2.fromOffset(22, 0)
_0x7465.Size = UDim2.new(1, -22, 1, 0)local function _0x2C73()
local _0xDFF5 = _0xC248.UIStyle =="Modern"_0x8183.AnchorPoint = _0xDFF5 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
_0x8183.Position = _0xDFF5 and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
_0x8183.Size = _0xDFF5 and UDim2.fromOffset(30, 16) or UDim2.fromOffset(14, 14)
_0x1426.AnchorPoint = _0xDFF5 and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5)
_0x7465.Position = _0xDFF5 and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
_0x7465.Size = _0xDFF5 and UDim2.new(1, -38, 1, 0) or UDim2.new(1, -22, 1, 0)
end
local function _0x41DF(animate)
local _0x27BA = _0xC248[_0xB92E]
local _0xDFF5 = _0xC248.UIStyle =="Modern"_0x91F0(_0x8183, { BackgroundColor3 = _0x27BA and _0x1FFF.Switch or _0x1FFF.Field }, animate)
if _0xDFF5 then
_0x91F0(_0x1426, {
Size = UDim2.fromOffset(12, 12),
Position = _0x27BA and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
}, animate)
else
_0x91F0(_0x1426, {
Size = _0x27BA and UDim2.fromOffset(6, 6) or UDim2.fromOffset(0, 0),
Position = UDim2.new(0.5, 0, 0.5, 0),
}, animate)
end
end
_0x8BD7.MouseEnter:Connect(function()
_0x6884(_0xAC75, { Transparency = 0 })
_0x6884(_0x8183, { BackgroundColor3 = _0xC248[_0xB92E] and _0x1FFF.Switch or _0x1FFF.Field:Lerp(_0x1FFF.Text, 0.12) })
end)
_0x8BD7.MouseLeave:Connect(function()
_0x6884(_0xAC75, { Transparency = 0.2 })
_0x41DF(true)
end)
_0x40B9[_0xB92E] = _0x41DF
local function _0xB072()
if _0x4ED9[_0xB92E] then return end
_0xC248[_0xB92E] = not _0xC248[_0xB92E]
_0x41DF(true)
if onChanged then onChanged(_0xC248[_0xB92E]) end
if _0x0E49 then _0x0E49(_0x5362[_0xB92E] or _0x0472, _0xC248[_0xB92E]) end
end
_0xE515[_0xB92E] = { toggle = _0xB072 }
_0x8BD7.MouseButton1Click:Connect(_0xB072)
_0x63C7(function()
_0x2C73()
_0x41DF(true)
end)
_0x2C73()
_0x41DF(false)
return _0x8BD7
end
local function _0xBBEF(parent, _0x0472, min, max, _0xB92E, onChanged)
_0x894E(parent, _0x0472)
local _0x8BD7 = Instance.new("Frame")
_0x8BD7.BackgroundTransparency = 1
_0x8BD7.BorderSizePixel = 0
_0x8BD7.Size = UDim2.new(1, 0, 0, 20)
_0x8BD7.LayoutOrder = _0x2A2C(parent)
_0x8BD7.Parent = parent
local _0xE8BC = Instance.new("Frame")
_0xE8BC.BorderSizePixel = 0
_0xE8BC.ClipsDescendants = true
_0xE8BC.Parent = _0x8BD7
_0x4EBC(_0xE8BC,"BackgroundColor3", function()
return _0x1FFF.Field
end)
_0xEF6D(_0xE8BC, 3)
_0x85AD(_0xE8BC, 0.4)
local _0x9062 = Instance.new("Frame")
_0x9062.BorderSizePixel = 0
_0x9062.BackgroundTransparency = 0.15
_0x9062.Parent = _0xE8BC
_0x4EBC(_0x9062,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0xEF6D(_0x9062, 3)
local _0x7465 = _0x0D0A(_0x8BD7, _0x0472, 12)
_0x7465.ZIndex = 3
_0x7465.TextTruncate = Enum.TextTruncate.AtEndlocal _0x862B = Instance.new("TextBox")
_0x862B.BorderSizePixel = 0
_0x862B.ClearTextOnFocus = false
_0x862B.Font = _0x4B96
_0x862B.TextSize = 12
_0x862B.TextXAlignment = Enum.TextXAlignment.Center
_0x862B.PlaceholderText = tostring(min) .."-".. tostring(max)
_0x862B.ZIndex = 4
_0x862B.Parent = _0x8BD7
_0x4EBC(_0x862B,"BackgroundColor3", function() return _0x1FFF.Field end)
_0x4EBC(_0x862B,"TextColor3", function() return _0x1FFF.Text end)
_0x4EBC(_0x862B,"PlaceholderColor3", function() return _0x1FFF.Dim end)
_0xEF6D(_0x862B, 3)
_0x85AD(_0x862B, 0.4)local _0x05C7 = Instance.new("Frame")
_0x05C7.BackgroundTransparency = 1
_0x05C7.BorderSizePixel = 0
_0x05C7.ZIndex = 5
_0x05C7.Parent = _0x8BD7
local function _0xC725(animate)
local _0xDFF5 = _0xC248.UIStyle =="Modern"_0x7465.TextXAlignment = _0xDFF5 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
if _0xDFF5 then
_0x91F0(_0x8BD7, { Size = UDim2.new(1, 0, 0, 34) }, animate)
_0x91F0(_0x7465, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -60, 0, 18) }, animate)
_0x91F0(_0x862B, { Position = UDim2.new(1, -52, 0, 0), Size = UDim2.fromOffset(52, 18) }, animate)
_0x91F0(_0xE8BC, { Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 8) }, animate)
_0x91F0(_0x05C7, { Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 16) }, animate)
else
_0x91F0(_0x8BD7, { Size = UDim2.new(1, 0, 0, 20) }, animate)
_0x91F0(_0x7465, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -54, 1, 0) }, animate)
_0x91F0(_0x862B, { Position = UDim2.new(1, -50, 0, 0), Size = UDim2.fromOffset(50, 20) }, animate)
_0x91F0(_0xE8BC, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -54, 1, 0) }, animate)
_0x91F0(_0x05C7, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -54, 1, 0) }, animate)
end
end
_0xC725(false)
_0x63C7(function() _0xC725(true) end)
local function _0xDA5B(_0x803E)
_0x803E = math.clamp(math.floor(_0x803E + 0.5), min, max)
_0xC248[_0xB92E] = _0x803E
local _0x82B5 = (_0x803E - min) / (max - min)
_0x9062.Size = UDim2.new(_0x82B5, 0, 1, 0)
if not _0x862B:IsFocused() then
_0x862B.Text = tostring(_0x803E)
end
if onChanged then onChanged(_0x803E) end
end_0x862B:GetPropertyChangedSignal("Text"):Connect(function()
local _0x54D4 = string.gsub(_0x862B.Text,"[^%d%.%-]","")
if _0x54D4 ~= _0x862B.Text then
_0x862B.Text = _0x54D4
end
end)
_0x862B.FocusLost:Connect(function()
local _0x54FD = tonumber(_0x862B.Text)
if _0x54FD and _0x54FD == _0x54FD and math.abs(_0x54FD) ~= math.huge then
_0xDA5B(_0x54FD)
end
_0x862B.Text = tostring(_0xC248[_0xB92E])
end)
local _0xC60A = false
local function _0x309F(_0x4CCB)
local _0x82B5 = math.clamp((_0x4CCB - _0xE8BC.AbsolutePosition.X) / math.max(_0xE8BC.AbsoluteSize.X, 1), 0, 1)
_0xDA5B(min + _0x82B5 * (max - min))
end
_0x05C7.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1
or _0x862B.UserInputType == Enum.UserInputType.Touch then
_0xC60A = true
_0x6884(_0x9062, { BackgroundTransparency = 0 })
_0x309F(_0x862B.Position.X)
end
end)
_0x05C7.MouseEnter:Connect(function()
_0x6884(_0x9062, { BackgroundTransparency = 0 })
end)
_0x05C7.MouseLeave:Connect(function()
if not _0xC60A then
_0x6884(_0x9062, { BackgroundTransparency = 0.15 })
end
end)
_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and (_0x862B.UserInputType == Enum.UserInputType.MouseMovement
or _0x862B.UserInputType == Enum.UserInputType.Touch) then
_0x309F(_0x862B.Position.X)
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if (_0x862B.UserInputType == Enum.UserInputType.MouseButton1
or _0x862B.UserInputType == Enum.UserInputType.Touch) and _0xC60A then
_0xC60A = false
_0x6884(_0x9062, { BackgroundTransparency = 0.15 })
end
end))
_0xDA5B(_0xC248[_0xB92E])
_0x40B9[_0xB92E] = function() _0xDA5B(_0xC248[_0xB92E]) end
return _0x8BD7
end
local function _0xE028(parent, _0x0472, _0xB92E, optA, optB, onChanged)
_0x894E(parent, _0x0472)
local _0x8BD7 = Instance.new("Frame")
_0x8BD7.Size = UDim2.new(1, 0, 0, 22)
_0x8BD7.BackgroundTransparency = 1
_0x8BD7.LayoutOrder = _0x2A2C(parent)
_0x8BD7.Parent = parent
local _0x7465 = _0x0D0A(_0x8BD7, _0x0472, 12)
_0x7465.Size = UDim2.new(0, 64, 1, 0)
local _0xA633 = Instance.new("Frame")
_0xA633.Size = UDim2.new(1, -68, 1, 0)
_0xA633.Position = UDim2.fromOffset(68, 0)
_0xA633.BorderSizePixel = 0
_0xA633.Parent = _0x8BD7
_0x4EBC(_0xA633,"BackgroundColor3", function()
return _0x1FFF.Field
end)
_0xEF6D(_0xA633, 3)
_0x85AD(_0xA633, 0.4)
local _0xEC0E = Instance.new("Frame")
_0xEC0E.Size = UDim2.new(0.5, -4, 1, -4)
_0xEC0E.BorderSizePixel = 0
_0xEC0E.Parent = _0xA633
_0x4EBC(_0xEC0E,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0xEF6D(_0xEC0E, 2)
local _0x498C = {}
local function _0x41DF(animate)
local _0x511B = (_0xC248[_0xB92E] == optA) and 1 or 2
local _0x6BF8 = UDim2.new((_0x511B - 1) * 0.5, 2, 0, 2)
if animate then
_0x6884(_0xEC0E, { Position = _0x6BF8 }, _0xFCF5)
else
_0xEC0E.Position = _0x6BF8
end
for i, _0x35A4 in ipairs(_0x498C) do
_0x91F0(_0x35A4, {
TextColor3 = (i == _0x511B) and Color3.fromRGB(255, 255, 255) or _0x1FFF.Dim,
}, animate)
end
end
for i, _0xBF13 in ipairs({ optA, optB }) do
local _0x35A4 = Instance.new("TextButton")
_0x35A4.Size = UDim2.new(0.5, 0, 1, 0)
_0x35A4.Position = UDim2.new((i - 1) * 0.5, 0, 0, 0)
_0x35A4.BackgroundTransparency = 1
_0x35A4.Text = _0xBF13
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 12
_0x35A4.BorderSizePixel = 0
_0x35A4.AutoButtonColor = false
_0x35A4.ZIndex = 2
_0x35A4.Parent = _0xA633
_0x35A4.MouseButton1Click:Connect(function()
_0xC248[_0xB92E] = _0xBF13
_0x41DF(true)
if onChanged then onChanged(_0xBF13) end
end)
_0x498C[i] = _0x35A4
end
_0x63C7(function()
_0x41DF(true)
end)
_0x40B9[_0xB92E] = _0x41DF
_0x41DF(false)
return _0x8BD7
end
local function _0x3E65(parent, _0x0472, _0x5A2F, hoverColor, onClick)
_0x894E(parent, _0x0472)
local _0x35A4 = Instance.new("TextButton")
_0x35A4.Size = UDim2.new(1, 0, 0, 22)
_0x35A4.BorderSizePixel = 0
_0x35A4.BackgroundColor3 = _0x5A2F
_0x35A4.Text = _0x0472
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 12
_0x35A4.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x35A4.AutoButtonColor = false
_0x35A4.LayoutOrder = _0x2A2C(parent)
_0x35A4.Parent = parent
_0xEF6D(_0x35A4, 3)
_0x35A4.MouseEnter:Connect(function()
_0x6884(_0x35A4, { BackgroundColor3 = hoverColor })
end)
_0x35A4.MouseLeave:Connect(function()
_0x6884(_0x35A4, { BackgroundColor3 = _0x5A2F })
end)
_0x35A4.MouseButton1Click:Connect(onClick)
return _0x35A4
end
local _0xA955 = {
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
local _0x2657 = {
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
local function _0xF8FA(_0xCE84)
for _0xDCCD, _0x75F5 in ipairs(_0xA955) do
if _0x75F5 == _0xCE84 then
return _0xA955
end
end
local _0xEC0F = { _0xCE84 }
for i = 1, #_0xA955 - 1 do
_0xEC0F[#_0xEC0F + 1] = _0xA955[i]
end
return _0xEC0F
end
local _0x224A = 8 * 18 + 7 * 5
local _0xF64B = 60
local function _0xB1B5(parent, _0x0472, colors, onPick, _0xCE84, hueS, hueV)
_0x894E(parent, _0x0472)
hueS = hueS or 0.75
hueV = hueV or 1
local _0xDDB4 = Instance.new("Frame")
_0xDDB4.Size = UDim2.new(1, 0, 0, 0)
_0xDDB4.AutomaticSize = Enum.AutomaticSize.Y
_0xDDB4.BackgroundTransparency = 1
_0xDDB4.LayoutOrder = _0x2A2C(parent)
_0xDDB4.Parent = parent
local _0x6452 = Instance.new("UIListLayout")
_0x6452.Padding = UDim.new(0, 2)
_0x6452.SortOrder = Enum.SortOrder.LayoutOrder
_0x6452.Parent = _0xDDB4
local _0x9C99 = Instance.new("TextButton")
_0x9C99.Size = UDim2.new(1, 0, 0, 20)
_0x9C99.BackgroundTransparency = 1
_0x9C99.Text =""_0x9C99.AutoButtonColor = false
_0x9C99.LayoutOrder = 1
_0x9C99.Parent = _0xDDB4
local _0x7465 = _0x0D0A(_0x9C99, _0x0472, 12)
_0x7465.Size = UDim2.new(1, -36, 1, 0)
local _0x6EF9 = Instance.new("Frame")
_0x6EF9.Size = UDim2.fromOffset(28, 12)
_0x6EF9.AnchorPoint = Vector2.new(1, 0.5)
_0x6EF9.Position = UDim2.new(1, 0, 0.5, 0)
_0x6EF9.BackgroundColor3 = _0xCE84 or colors[1]
_0x6EF9.BorderSizePixel = 0
_0x6EF9.Parent = _0x9C99
_0xEF6D(_0x6EF9, 3)
local _0xC680 = _0x85AD(_0x6EF9, 0.2)
_0x9C99.MouseEnter:Connect(function()
_0x6884(_0xC680, { Transparency = 0 })
end)
_0x9C99.MouseLeave:Connect(function()
_0x6884(_0xC680, { Transparency = 0.2 })
end)
local _0x51C3 = Instance.new("Frame")
_0x51C3.Size = UDim2.new(1, 0, 0, 0)
_0x51C3.BackgroundTransparency = 1
_0x51C3.ClipsDescendants = true
_0x51C3.LayoutOrder = 2
_0x51C3.Parent = _0xDDB4
local _0xF666 = Instance.new("Frame")
_0xF666.Size = UDim2.fromOffset(_0x224A, 41)
_0xF666.Position = UDim2.fromOffset(0, 2)
_0xF666.BackgroundTransparency = 1
_0xF666.Parent = _0x51C3
local _0xF79D = Instance.new("UIGridLayout")
_0xF79D.CellSize = UDim2.fromOffset(18, 18)
_0xF79D.CellPadding = UDim2.fromOffset(5, 5)
_0xF79D.FillDirectionMaxCells = 8
_0xF79D.SortOrder = Enum.SortOrder.LayoutOrder
_0xF79D.Parent = _0xF666
local _0x02D7
local _0xAA6F = {}
local function _0x176C(index, animate)
for j, _0xC09B in ipairs(_0xAA6F) do
local _0xCAC0 = (j == index) and 0 or 1
if animate then
_0x6884(_0xC09B, { Transparency = _0xCAC0 })
else
_0xC09B.Transparency = _0xCAC0
end
end
end
local function _0x320C(_0x5A2F)
_0x6884(_0x6EF9, { BackgroundColor3 = _0x5A2F })
end
for i, _0x5A2F in ipairs(colors) do
local _0x9785 = Instance.new("TextButton")
_0x9785.BackgroundColor3 = _0x5A2F
_0x9785.BorderSizePixel = 0
_0x9785.Text =""_0x9785.AutoButtonColor = false
_0x9785.LayoutOrder = i
_0x9785.Parent = _0xF666
_0xEF6D(_0x9785, 3)
local _0xC09B = Instance.new("UIStroke")
_0xC09B.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0xC09B.Color = Color3.fromRGB(255, 255, 255)
_0xC09B.Thickness = 2
_0xC09B.Transparency = 1
_0xC09B.Parent = _0x9785
_0xAA6F[i] = _0xC09B
_0x9785.MouseButton1Click:Connect(function()
_0x176C(i, true)
if _0x02D7 then _0x02D7.Visible = false end
_0x320C(_0x5A2F)
onPick(_0x5A2F)
end)
end
local _0xE8BC = Instance.new("Frame")
_0xE8BC.Size = UDim2.fromOffset(_0x224A, 8)
_0xE8BC.Position = UDim2.fromOffset(0, 50)
_0xE8BC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0xE8BC.BorderSizePixel = 0
_0xE8BC.Parent = _0x51C3
_0xEF6D(_0xE8BC, 3)
local _0x1C6A = {}
for i = 0, 6 do
_0x1C6A[#_0x1C6A + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, hueS, hueV))
end
local _0x39C3 = Instance.new("UIGradient")
_0x39C3.Color = ColorSequence.new(_0x1C6A)
_0x39C3.Parent = _0xE8BC
_0x02D7 = Instance.new("Frame")
_0x02D7.Size = UDim2.fromOffset(4, 12)
_0x02D7.AnchorPoint = Vector2.new(0.5, 0.5)
_0x02D7.Position = UDim2.new(0, 0, 0.5, 0)
_0x02D7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0x02D7.BorderSizePixel = 0
_0x02D7.Visible = false
_0x02D7.Parent = _0xE8BC
_0xEF6D(_0x02D7, 2)
local _0x102B = Instance.new("UIStroke")
_0x102B.Color = Color3.fromRGB(20, 20, 28)
_0x102B.Thickness = 1
_0x102B.Transparency = 0.2
_0x102B.Parent = _0x02D7
local function _0x1135(_0x4CCB)
local _0x82B5 = math.clamp((_0x4CCB - _0xE8BC.AbsolutePosition.X) / _0xE8BC.AbsoluteSize.X, 0, 1)
local _0x5A2F = Color3.fromHSV(math.min(_0x82B5, 0.999), hueS, hueV)
_0x02D7.Visible = true
_0x02D7.Position = UDim2.new(_0x82B5, 0, 0.5, 0)
_0x176C(nil, true)
_0x6EF9.BackgroundColor3 = _0x5A2F
onPick(_0x5A2F)
end
local _0xC60A = false
_0xE8BC.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A = true
_0x1135(_0x862B.Position.X)
end
end)
_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and _0x862B.UserInputType == Enum.UserInputType.MouseMovement then
_0x1135(_0x862B.Position.X)
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1 then
_0xC60A = false
end
end))
local _0x1FA9 = false
_0x9C99.MouseButton1Click:Connect(function()
_0x1FA9 = not _0x1FA9
_0x6884(_0x51C3, { Size = UDim2.new(1, 0, 0, _0x1FA9 and _0xF64B or 0) }, _0xFCF5)
end)
for i, _0x5A2F in ipairs(colors) do
if _0x5A2F == _0xCE84 then
_0x176C(i, false)
end
end
local _0xB40B = _0xD1D6.colorGetters[_0x0472]
if _0xB40B then
table.insert(_0xD1D6.colorRefreshers, function()
local _0x75F5 = _0xB40B()
_0x6EF9.BackgroundColor3 = _0x75F5
_0x02D7.Visible = false
local _0x8142
for i, _0x5A2F in ipairs(colors) do
if _0x5A2F == _0x75F5 then _0x8142 = i end
end
_0x176C(_0x8142, false)
end)
end
return _0xDDB4
end
local _0x3118 = {}
local _0x2E9B = {}
local _0x487D = {}
local _0x060F = {}
local _0x49BA = {}
local _0x632A = {}
local function _0xF400(_0xAD22, _0x08C3)
return _0x08C3 and (_0xAD22 .."_".. _0x08C3) or _0xAD22
end
local function _0x93C3(animate)
for _0xBF13, _0x35A4 in pairs(_0x3118) do
_0x91F0(_0x35A4, { TextColor3 = (_0xBF13 == _0x8B85) and _0x1FFF.Text or _0x1FFF.Dim }, animate)
end
for tabId, _0x8047 in pairs(_0x487D) do
for subId, _0x35A4 in pairs(_0x8047) do
local _0x27BA = (tabId == _0x8B85 and _0x928D[tabId] == subId)
_0x91F0(_0x35A4, { TextColor3 = _0x27BA and _0x1FFF.Text or _0x1FFF.Dim }, animate)
end
end
endlocal _0xBEFA = 270_0xD1D6.absK = function()
local _0x434E = _0xDE16.AbsoluteSize.Y / _0x8DE0
if _0x434E < 0.2 or _0x434E ~= _0x434E or _0x434E > 5 then _0x434E = 1 end
return _0x434E
end
_0xD1D6.allGroups = function(_0xCF40)
local _0xEC0F = {}
for i = 1, #_0xCF40.cols do
for _0xDCCD, ch in ipairs(_0xCF40.cols[i].frame:GetChildren()) do
if ch:IsA("Frame") and ch:GetAttribute("OULHome") then
_0xEC0F[#_0xEC0F + 1] = ch
end
end
end
table.sort(_0xEC0F, function(_0x82B5, _0x051B)
local _0x1486, _0x7FDE = _0x82B5:GetAttribute("OULHome"), _0x051B:GetAttribute("OULHome")
if _0x1486 ~= _0x7FDE then return _0x1486 < _0x7FDE end
return _0x82B5:GetAttribute("OULOrd") < _0x051B:GetAttribute("OULOrd")
end)
return _0xEC0F
end
_0xD1D6.restoreHome = function(_0xCF40)
for _0xDCCD, _0x66D9 in ipairs(_0xD1D6.allGroups(_0xCF40)) do
local _0x2104 = _0xCF40.cols[_0x66D9:GetAttribute("OULHome")].frame
if _0x66D9.Parent ~= _0x2104 then _0x66D9.Parent = _0x2104 end
local _0x40AB = _0x66D9:GetAttribute("OULOrd")
if _0x66D9.LayoutOrder ~= _0x40AB then _0x66D9.LayoutOrder = _0x40AB end
end
end_0xD1D6.reflowBasic = function(_0xCF40)
local _0x39D3 = _0xD1D6.allGroups(_0xCF40)
local _0x434E = _0xD1D6.absK()
local _0x6F78 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local _0xDCCD, _0x6800 = _0xBC15()
local _0xC5EF = (_0x6F78.Y - 20) / (_0xC248.UIScale / 100) - (_0x6800 + _0xCF40.subOffset + _0x5FD5 + 8)
local _0x19CC, _0x64FD = {}, 0
for i, _0x66D9 in ipairs(_0x39D3) do
_0x19CC[i] = _0x66D9.AbsoluteSize.Y / _0x434E
_0x64FD = _0x64FD + _0x19CC[i]
end
local function _0x0C1C(_0x54FD)
local _0xA729 = (_0x64FD + 8 * #_0x39D3) / _0x54FD
local _0xB626, _0x9E53, _0xB46E, _0xD4F0, _0x919D = {}, 0, 0, 1, 0
for i = 1, #_0x39D3 do
_0x9E53 = _0x9E53 + _0x19CC[i] + (_0xB46E > 0 and 8 or 0)
_0xB46E = _0xB46E + 1
_0xB626[i] = _0xD4F0
_0x919D = math.max(_0x919D, _0x9E53)
if _0x9E53 >= _0xA729 and _0xD4F0 < _0x54FD then
_0xD4F0, _0x9E53, _0xB46E = _0xD4F0 + 1, 0, 0
end
end
return _0xB626, _0x919D
end
local _0xF9FC, _0xB626, _0x919D = 4, nil, 0
for _0x54FD = 1, 4 do
local _0x82B5, _0x752D = _0x0C1C(_0x54FD)
if _0x752D <= _0xC5EF or _0x54FD == 4 then
_0xF9FC, _0xB626, _0x919D = _0x54FD, _0x82B5, _0x752D
break
end
end
for i, _0x66D9 in ipairs(_0x39D3) do
local _0xA729 = _0xCF40.cols[_0xB626[i]].frame
if _0x66D9.Parent ~= _0xA729 then _0x66D9.Parent = _0xA729 end
if _0x66D9.LayoutOrder ~= i then _0x66D9.LayoutOrder = i end
end
return _0xF9FC, _0x919D
end
local function _0xBA5B(_0xCF40)
local _0x7F5B = _0xC248.UIStyle
if _0x7F5B =="Basic"and _0xCF40.basicH then return _0xCF40.basicH end
local _0x434E = _0xD1D6.absK()
local _0xCF21 = 0
for i = 1, 2 do
_0xCF21 = math.max(_0xCF21, _0xCF40.cols[i].layout.AbsoluteContentSize.Y / _0x434E)
end
return _0xCF21
end
_0xB9B7 = function(animate)
local _0xD93F, _0x6800 = _0xBC15()
local _0xA0A4 = _0xC248.UIStyle =="Basic"for _0xDCCD, _0xCF40 in pairs(_0xA0EA) do
if _0xA0A4 then
local _0x54FD, _0xCF21 = _0xD1D6.reflowBasic(_0xCF40)
_0xCF40.basicN, _0xCF40.basicH = _0x54FD, _0xCF21
for i = 1, 4 do
local _0x75F5 = _0xCF40.cols[i].frame
if i <= _0x54FD then
_0x75F5.Size = UDim2.new(1 / _0x54FD, -math.floor(8 * (_0x54FD - 1) / _0x54FD), 0, 0)
_0x75F5.Position = UDim2.new((i - 1) / _0x54FD, math.floor(8 * (i - 1) / _0x54FD), 0, 0)
else
_0x75F5.Size = UDim2.new(0, 0, 0, 0)
end
end
else
_0xD1D6.restoreHome(_0xCF40)
_0xCF40.basicN, _0xCF40.basicH = nil, nil
local _0xE4E6, _0xE2B5 = _0xCF40.cols[1].frame, _0xCF40.cols[2].frame
_0xE4E6.Size = UDim2.new(0.5, -4, 0, 0)
_0xE4E6.Position = UDim2.new(0, 0, 0, 0)
_0xE2B5.Size = UDim2.new(0.5, -4, 0, 0)
_0xE2B5.Position = UDim2.new(0.5, 4, 0, 0)
_0xCF40.cols[3].frame.Size = UDim2.new(0, 0, 0, 0)
_0xCF40.cols[4].frame.Size = UDim2.new(0, 0, 0, 0)
end
_0xCF40.frame.Position = UDim2.fromOffset(_0xD93F, _0x6800 + _0xCF40.subOffset)
_0xCF40.frame.Size = UDim2.new(1, -(_0xD93F + 8), 0, _0xBA5B(_0xCF40))
end
if not _0x8CF4 or not _0xA0EA[_0x8CF4] then return end
local _0x30A5 = _0xA0EA[_0x8CF4]local _0x8556 = _0x6401
if _0xA0A4 and _0x30A5.basicN then
_0x8556 = math.max(_0x6401, 16 + _0x30A5.basicN * _0xBEFA + (_0x30A5.basicN - 1) * 8)
end
_0xD1D6.panelW = _0x8556
if _0xC248.UIStyle ~="Modern"then
for _0xDCCD, _0x051B in pairs(_0x632A) do
_0x051B.frame.Size = UDim2.new(1, -(_0xD93F + 8), 0, _0xBFFE - 4)
end
end
local _0xBD9E = math.max(_0xBA5B(_0x30A5) + _0x30A5.subOffset, #_0x1BF4 * _0xC1DD + 8)
local _0xA729 = UDim2.fromOffset(_0x8556, _0x6800 + _0xBD9E + _0x5FD5 + 8)
if animate then
_0x6884(_0xAE9A, { Size = _0xA729 }, _0xFCF5)
else
_0xAE9A.Size = _0xA729
endlocal _0x6F78 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
if _0x6F78 then
local _0x4691 = _0xC248.UIScale / 100
local _0x76F2 = math.max(0, _0x6F78.X - _0xA729.X.Offset * _0x4691)
local _0x208A = math.max(0, _0x6F78.Y - _0xA729.Y.Offset * _0x4691)
local _0x4CCB = math.clamp(_0xAE9A.Position.X.Offset, 0, _0x76F2)
local _0xCF3D = math.clamp(_0xAE9A.Position.Y.Offset, 0, _0x208A)
if _0x4CCB ~= _0xAE9A.Position.X.Offset or _0xCF3D ~= _0xAE9A.Position.Y.Offset then
_0xAE9A.Position = UDim2.fromOffset(_0x4CCB, _0xCF3D)
end
end
end
_0xD1D6.updateHeader = function()
local _0xCAC0, _0x37CC = _0xD1D6.hdrTitle, _0xD1D6.hdrSub
if not _0xCAC0 or not _0x37CC then return end
local _0xDFF5 = _0xC248.UIStyle =="Modern"_0xCAC0.Visible, _0x37CC.Visible = _0xDFF5, _0xDFF5
if not _0xDFF5 then return end
local _0xEA56 = {
combat ="aim assist, triggers and rage tools",
visuals ="esp, colours, sky and radar",
movement ="fly, vortex, noclip and speed",
themes ="ui style, colours and gradient",
settings ="menu, keybinds and configs",
}
local _0xCD48
for _0xDCCD, _0xC09B in ipairs(_0x08F2[_0x8B85] or {}) do
if _0xC09B.id == _0x928D[_0x8B85] then _0xCD48 = _0xC09B.label end
end
_0xCAC0.Text = _0x6765[_0x8B85] or""_0x37CC.Text = (_0xCD48 and (_0xCD48 .."  -  ") or"") .. (_0xEA56[_0x8B85] or"")
end
local function _0xB065(tabId, subId, instant)
_0x8B85 = tabId
if subId then
_0x928D[tabId] = subId
else
subId = _0x928D[tabId]
end
local _0xB92E = _0xF400(tabId, subId)
_0x8CF4 = _0xB92E
for _0x54FD, _0xCF40 in pairs(_0xA0EA) do
local _0x27BA = (_0x54FD == _0xB92E)
_0x9AC1[_0xCF40] = _0x27BA
if _0x27BA then
_0xCF40.frame.Visible = true
if instant then
_0xCF40.frame.GroupTransparency = 0
else
_0x6884(_0xCF40.frame, { GroupTransparency = 0 }, _0xCFE3)
end
elseif instant then
_0xCF40.frame.GroupTransparency = 1
_0xCF40.frame.Visible = false
else
_0x6884(_0xCF40.frame, { GroupTransparency = 1 }, _0x87A6)
task.delay(_0x87A6.Time, function()
if not _0x9AC1[_0xCF40] then
_0xCF40.frame.Visible = false
end
end)
end
end
if _0xC248.UIStyle =="Basic"then
local _0x35A4 = _0x3118[tabId]
task.defer(function()
if _0x35A4.Parent and _0xA72A.Parent then
local _0x6BF8 = UDim2.fromOffset(_0x35A4.AbsolutePosition.X - _0xA72A.AbsolutePosition.X + 4, _0xC1DD - 4)
local _0x7B8B = UDim2.fromOffset(math.max(_0x35A4.AbsoluteSize.X - 8, 4), 2)
if instant then
_0x7C46.Position, _0x7C46.Size = _0x6BF8, _0x7B8B
else
_0x6884(_0x7C46, { Position = _0x6BF8, Size = _0x7B8B }, _0xFCF5)
end
end
end)
else
local _0x511B = _0x2E9B[tabId]
local _0x6BF8 = UDim2.fromOffset(0, 8 + (_0x511B - 1) * _0xC1DD + 3)
local _0x7B8B = UDim2.fromOffset(2, _0xC1DD - 8)
if instant then
_0x7C46.Position, _0x7C46.Size = _0x6BF8, _0x7B8B
else
_0x6884(_0x7C46, { Position = _0x6BF8, Size = _0x7B8B }, _0xFCF5)
end
local _0xEC0E = _0xD1D6.tabPill
if _0xEC0E then
local _0x57C3 = UDim2.fromOffset(6, 8 + (_0x511B - 1) * _0xC1DD)
if instant then
_0xEC0E.Position = _0x57C3
else
_0x6884(_0xEC0E, { Position = _0x57C3 }, _0xFCF5)
end
end
end
for id, _0xE8BC in pairs(_0x632A) do
_0xE8BC.frame.Visible = (id == tabId)
end
local _0xE8BC = _0x632A[tabId]
if _0xE8BC and _0x49BA[tabId][subId] then
local _0xC566 = _0x49BA[tabId][subId]
local _0xDFF5 = _0xC248.UIStyle =="Modern"local _0x7AF5 = _0xDFF5 and UDim2.fromOffset(_0xC566.x + 2, 2) or UDim2.fromOffset(_0xC566.x + 6, _0xBFFE - 8)
local _0xE7BF = _0xDFF5 and UDim2.fromOffset(_0xC566.w - 4, _0xBFFE - 8) or UDim2.fromOffset(_0xC566.w - 12, 2)
if instant then
_0xE8BC.line.Position = _0x7AF5
_0xE8BC.line.Size = _0xE7BF
else
_0x6884(_0xE8BC.line, { Position = _0x7AF5, Size = _0xE7BF }, _0xFCF5)
end
end
_0x93C3(not instant)
_0xB9B7(not instant)
_0xD1D6.updateHeader()
end
for i, _0xBF13 in ipairs(_0x1BF4) do
_0x2E9B[_0xBF13] = i
local _0x35A4 = Instance.new("TextButton")
_0x35A4.Size = UDim2.new(1, 0, 0, _0xC1DD - 2)
_0x35A4.Position = UDim2.fromOffset(0, 8 + (i - 1) * _0xC1DD)
_0x35A4.BackgroundTransparency = 1
_0x35A4.Text = _0x6765[_0xBF13]
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 13
_0x35A4.TextXAlignment = Enum.TextXAlignment.Left
_0x35A4.AutoButtonColor = false
_0x35A4.Parent = _0xA72A
local _0xD8CE = Instance.new("UIPadding")
_0xD8CE.PaddingLeft = UDim.new(0, 14)
_0xD8CE.Parent = _0x35A4
_0x3118[_0xBF13] = _0x35A4
_0x35A4.MouseButton1Click:Connect(function()
if _0x8B85 ~= _0xBF13 then
_0xB065(_0xBF13, nil, false)
end
end)
_0x35A4.MouseEnter:Connect(function()
if _0x8B85 ~= _0xBF13 then
_0x6884(_0x35A4, { TextColor3 = _0x1FFF.Text })
end
end)
_0x35A4.MouseLeave:Connect(function()
if _0x8B85 ~= _0xBF13 then
_0x6884(_0x35A4, { TextColor3 = _0x1FFF.Dim })
end
end)
end
for tabId, subs in pairs(_0x08F2) do
local _0xBE9C = math.min(_0x67D4, math.floor((_0x6401 - _0x603C - 8) / #subs))
local _0xE8BC = Instance.new("Frame")
_0xE8BC.BackgroundTransparency = 1
_0xE8BC.Size = UDim2.new(1, -(_0x603C + 8), 0, _0xBFFE - 4)
_0xE8BC.Position = UDim2.fromOffset(_0x603C, _0x9476 - 4)
_0xE8BC.Visible = false
_0xE8BC.BorderSizePixel = 0
_0xE8BC.Parent = _0xAE9A
_0x4EBC(_0xE8BC,"BackgroundColor3", function()
return _0x1FFF.Field
end)
_0x4EBC(_0xE8BC,"BackgroundTransparency", function()
return _0xC248.UIStyle =="Modern"and 0 or 1
end)
_0xEF6D(_0xE8BC, 4)
local _0xFA6C = Instance.new("Frame")
_0xFA6C.Size = UDim2.new(1, 0, 0, 1)
_0xFA6C.Position = UDim2.fromOffset(0, _0xBFFE - 6)
_0xFA6C.BorderSizePixel = 0
_0xFA6C.Parent = _0xE8BC
_0x4EBC(_0xFA6C,"BackgroundColor3", function()
return _0x1FFF.Outline
end)
_0x4EBC(_0xFA6C,"BackgroundTransparency", function()
return _0xC248.UIStyle =="Modern"and 1 or 0.4
end)
local _0x4883 = Instance.new("Frame")
_0x4883.Size = UDim2.fromOffset(_0xBE9C - 12, 2)
_0x4883.Position = UDim2.fromOffset(6, _0xBFFE - 8)
_0x4883.BorderSizePixel = 0
_0x4883.ZIndex = 1
_0x4883.Parent = _0xE8BC
_0x4EBC(_0x4883,"BackgroundColor3", function()
return _0x1FFF.Accent
end)
_0x4EBC(_0x4883,"BackgroundTransparency", function()
return _0xC248.UIStyle =="Modern"and 0.7 or 0
end)
_0xEF6D(_0x4883, 3)
_0x487D[tabId] = {}
_0x060F[tabId] = {}
_0x49BA[tabId] = {}
local _0x4CCB = 0
for i, _0x08C3 in ipairs(subs) do
_0x060F[tabId][_0x08C3.id] = i
_0x49BA[tabId][_0x08C3.id] = { _0x4CCB = _0x4CCB, _0x0866 = _0xBE9C }
local _0x37CC = Instance.new("TextButton")
_0x37CC.Size = UDim2.fromOffset(_0xBE9C, _0xBFFE - 8)
_0x37CC.Position = UDim2.fromOffset(_0x4CCB, 0)
_0x37CC.BackgroundTransparency = 1
_0x37CC.Text = _0x08C3.label
_0x37CC.Font = _0x4B96
_0x37CC.TextSize = 12
_0x37CC.AutoButtonColor = false
_0x37CC.ZIndex = 2
_0x37CC.Parent = _0xE8BC
_0x487D[tabId][_0x08C3.id] = _0x37CC
_0x37CC.MouseButton1Click:Connect(function()
if not (_0x8B85 == tabId and _0x928D[tabId] == _0x08C3.id) then
_0xB065(tabId, _0x08C3.id, false)
end
end)
_0x37CC.MouseEnter:Connect(function()
if not (_0x8B85 == tabId and _0x928D[tabId] == _0x08C3.id) then
_0x6884(_0x37CC, { TextColor3 = _0x1FFF.Text })
end
end)
_0x37CC.MouseLeave:Connect(function()
if not (_0x8B85 == tabId and _0x928D[tabId] == _0x08C3.id) then
_0x6884(_0x37CC, { TextColor3 = _0x1FFF.Dim })
end
end)
_0x4CCB = _0x4CCB + _0xBE9C
end
_0x632A[tabId] = { _0x34A5 = _0xE8BC, _0x4883 = _0x4883 }
end
_0x63C7(function()
_0x93C3(true)
end)
local function _0xA1F3()
local _0xB47D = _0xC248.UIStyle =="Basic"local _0xD93F, _0x6800 = _0xBC15()
if _0xB47D then
_0xA72A.Size = UDim2.new(1, -16, 0, _0xC1DD)
_0xA72A.Position = UDim2.fromOffset(8, _0x8DE0 + 4)
else
_0xA72A.Size = UDim2.new(0, _0x28CA, 1, -(_0x8DE0 + _0x5FD5))
_0xA72A.Position = UDim2.fromOffset(0, _0x8DE0)
end
if _0xD1D6.tabPill then
_0xD1D6.tabPill.Visible = (_0xC248.UIStyle =="Modern")
end
local _0x9892 = _0xAE9A:FindFirstChild("OULTabLine")
if _0x9892 then
_0x9892.Visible = not _0xB47D
end
local _0x9E38 = _0xAE9A:FindFirstChild("OULFooter")
if _0x9E38 then
_0x9E38.Position = UDim2.new(0, _0xD93F, 1, -5)
_0x9E38.Size = UDim2.new(1, -(_0xD93F + 8), 0, 12)
end
for i, _0xBF13 in ipairs(_0x1BF4) do
local _0x35A4 = _0x3118[_0xBF13]
if _0xB47D then
_0x35A4.Size = UDim2.new(1 / #_0x1BF4, -6, 1, -4)
_0x35A4.Position = UDim2.new((i - 1) / #_0x1BF4, 3, 0, 2)
_0x35A4.TextXAlignment = Enum.TextXAlignment.Center
else
_0x35A4.Size = UDim2.new(1, 0, 0, _0xC1DD - 2)
_0x35A4.Position = UDim2.fromOffset(0, 8 + (i - 1) * _0xC1DD)
_0x35A4.TextXAlignment = Enum.TextXAlignment.Left
end
end
for tabId, subs in pairs(_0x08F2) do
local _0xE8BC = _0x632A[tabId]
if _0xE8BC then
local _0xC5E0 = _0x6401 - _0xD93F - 8
local _0xBE9C = math.min(_0x67D4, math.floor(_0xC5E0 / #subs))
_0xE8BC.frame.Position = UDim2.fromOffset(_0xD93F, _0x6800 - 4)
local _0xADA2 = _0xC248.UIStyle =="Modern"_0xE8BC.frame.Size = UDim2.new(0, _0xADA2 and (_0xBE9C * #subs) or _0xC5E0, 0, _0xBFFE - 4)
local _0x4CCB = 0
for _0xDCCD, _0x08C3 in ipairs(subs) do
_0x49BA[tabId][_0x08C3.id] = { _0x4CCB = _0x4CCB, _0x0866 = _0xBE9C }
local _0x37CC = _0x487D[tabId][_0x08C3.id]
_0x37CC.Position = UDim2.fromOffset(_0x4CCB, _0xADA2 and 2 or 0)
_0x37CC.Size = UDim2.fromOffset(_0xBE9C, _0xBFFE - 8)
_0x4CCB = _0x4CCB + _0xBE9C
end
end
end
_0xB9B7(false)
_0xB065(_0x8B85, nil, true)
end
do
_0x3159.step(0.55,"Building menu")
local _0x47A8 = _0x6BFC("combat_aimbot", true)
local _0x66D9 = _0xCD1A(_0x47A8, 1,"Aimbot")
_0xCEB3(_0x66D9,"Enabled","Enabled")
_0xCEB3(_0x66D9,"Ignore FOV","IgnoreFOV")
_0xCEB3(_0x66D9,"Team Check","TeamCheck")
_0xCEB3(_0x66D9,"Target Zombies/NPCS","TargetNPCs")
_0xBBEF(_0x66D9,"FOV", 20, 500,"FOV", function(_0x803E)
_0x839A.Size = UDim2.fromOffset(_0x803E * 2, _0x803E * 2)
end)
_0xBBEF(_0x66D9,"Strength", 1, 500,"Strength")
_0xCEB3(_0x66D9,"Prediction","Prediction")
_0xBBEF(_0x66D9,"Prediction (ms)", 0, 500,"PredictionMs")
_0xE028(_0x66D9,"Target","AimPart","Head","Body")
_0xCEB3(_0x66D9,"Real mouse input","MouseAim")
_0xBBEF(_0x66D9,"Mouse gain (%)", 5, 100,"MouseGain")
_0xE028(_0x66D9,"Key mode","AimMode","Hold","Toggle", function()
_0xC248.Holding = false
_0xBB85()
end)
local _0x803E = _0xCD1A(_0x47A8, 2,"FOV Circle")
_0xCEB3(_0x803E,"Show FOV","ShowFOV")
_0xB1B5(_0x803E,"FOV Color", _0xF8FA(_0xA41E), function(_0x5A2F)
_0xD92F.Color = _0x5A2F
_0xA41E = _0x5A2F
end, _0xA41E)
local _0x7439 = _0xCD1A(_0x47A8, 2,"Info")
_0x18F9(_0x8649(_0x7439,""), function()
local _0x434E = string.lower(_0x8406(_0xACF9("aim").input))
if _0xC248.AimMode =="Toggle"then
return"press ".. _0x434E .." to toggle aim"end
return"hold ".. _0x434E .." to aim"end)
_0x8649(_0x7439,"range: 1000 studs")
_0x8649(_0x7439,"needs mouse lock")
_0x8649(_0x7439,"strength: 1 = soft pull,")
_0x8649(_0x7439,"500 = straight lock")
_0x8649(_0x7439,"prediction leads moving")
_0x8649(_0x7439,"real mouse input: moves your")
_0x8649(_0x7439,"actual mouse (needs mousemoverel)")
_0x8649(_0x7439,"overshoots? lower mouse gain")
_0x8649(_0x7439,"targets by their speed")
_0x3E65(_0x7439,"Print team info", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
if _0x5028 then _0x5028() end
end)
end
do
local _0xF9EB = _0x6BFC("combat_trigger", true)
local _0xCAC0 = _0xCD1A(_0xF9EB, 1,"Triggerbot")
_0xCEB3(_0xCAC0,"Enabled","Triggerbot")
_0xBBEF(_0xCAC0,"Delay (ms)", 0, 300,"TriggerDelay")
_0xCEB3(_0xCAC0,"Left click only","TriggerOnClick")
local _0x7439 = _0xCD1A(_0xF9EB, 2,"Info")
_0x18F9(_0x8649(_0x7439,""), function()
return _0x8406(_0xACF9("Triggerbot").input) .."  -  triggerbot on / off"end)
_0x8649(_0x7439,"uses Team Check")
_0x8649(_0x7439,"(set in the Aimbot tab)")
_0x8649(_0x7439,"range: 1000 studs")
_0x8649(_0x7439,"needs mouse lock")
end
local function _0xB47B(pageName, boxTitle)
local _0x2153 = _0x6BFC(pageName, true)
local _0x66D9 = _0xCD1A(_0x2153, 1, boxTitle)
local _0xF10E = _0x8649(_0x66D9,"In Development")
_0xF10E.TextSize = 12
_0xF10E.TextXAlignment = Enum.TextXAlignment.Center
_0x4EBC(_0xF10E,"TextColor3", function()
return _0x1FFF.Accent
end)
return _0x2153
end
_0xB47B("combat_antikatana","Antikatana")
do
local _0xE0E1 = _0x6BFC("combat_ragebot", true)
local _0x66D9 = _0xCD1A(_0xE0E1, 1,"Ragebot")
_0xCEB3(_0x66D9,"Rage","Ragebot")
_0xE028(_0x66D9,"Mode","RageMode","Closest","Selected")
_0xCEB3(_0x66D9,"Target Lowest Health","RageLowestHP")
local _0xDE2C = {"RageBehind","RageAbove","RageBelow"}
local function _0x9531(_0xB92E)
return function(_0x27BA)
if not _0x27BA then return end
for _0xDCCD, _0x434E in ipairs(_0xDE2C) do
if _0x434E ~= _0xB92E then
_0xC248[_0x434E] = false
if _0x40B9[_0x434E] then _0x40B9[_0x434E](true) end
end
end
end
end
_0xCEB3(_0x66D9,"Behind","RageBehind", _0x9531("RageBehind"))
_0xCEB3(_0x66D9,"Above","RageAbove", _0x9531("RageAbove"))
_0xCEB3(_0x66D9,"Below","RageBelow", _0x9531("RageBelow"))
_0xBBEF(_0x66D9,"Distance", 2, 20,"RageDistance")
_0xCEB3(_0x66D9,"Orbit","RageOrbit")
_0xBBEF(_0x66D9,"Orbit Speed", 1, 30,"OrbitSpeed")
local _0x02EC = _0xCD1A(_0xE0E1, 1,"Void Spam")
_0xCEB3(_0x02EC,"Void Spam","VoidSpam")
_0xCEB3(_0x02EC,"Auto Attack (M1)","VoidAutoAttack")
_0xCEB3(_0x02EC,"Target Lowest Health","VoidLowestHP")
_0xBBEF(_0x02EC,"Void Interval", 10, 2000,"VoidInterval")
_0xBBEF(_0x02EC,"Void Distance", 1, 10000000,"VoidDistance")
_0xCEB3(_0x02EC,"Roam in void","VoidRoam")
_0xBBEF(_0x02EC,"Roam Interval (ms)", 10, 2000,"VoidRoamMs")
_0xBBEF(_0x02EC,"Attack Interval", 10, 2000,"AttackInterval")
_0xBBEF(_0x02EC,"Attack Distance", 0, 50,"AttackHeight")
local _0xAC2C = {"VoidBehind","VoidAbove","VoidBelow"}
local function _0x69B0(_0xB92E)
return function(_0x27BA)
if not _0x27BA then return end
for _0xDCCD, _0x434E in ipairs(_0xAC2C) do
if _0x434E ~= _0xB92E then
_0xC248[_0x434E] = false
if _0x40B9[_0x434E] then _0x40B9[_0x434E](true) end
end
end
end
end
_0xCEB3(_0x02EC,"Teleport Behind","VoidBehind", _0x69B0("VoidBehind"))
_0xCEB3(_0x02EC,"Teleport Above","VoidAbove", _0x69B0("VoidAbove"))
_0xCEB3(_0x02EC,"Teleport Below","VoidBelow", _0x69B0("VoidBelow"))
local _0xB4F6 = _0xCD1A(_0xE0E1, 2,"Selected Target")
local _0x8183 = Instance.new("TextBox")
_0x8183.Size = UDim2.new(1, 0, 0, 22)
_0x8183.BorderSizePixel = 0
_0x8183.ClearTextOnFocus = false
_0x8183.PlaceholderText ="username..."_0x8183.Text = _0xC248.RageTarget
_0x8183.Font = _0x4B96
_0x8183.TextSize = 12
_0x8183.TextXAlignment = Enum.TextXAlignment.Left
_0x8183.LayoutOrder = _0x2A2C(_0xB4F6)
_0x8183.Parent = _0xB4F6
_0x4EBC(_0x8183,"BackgroundColor3", function() return _0x1FFF.Field end)
_0x4EBC(_0x8183,"TextColor3", function() return _0x1FFF.Text end)
_0x4EBC(_0x8183,"PlaceholderColor3", function() return _0x1FFF.Dim end)
_0xEF6D(_0x8183, 3)
_0x85AD(_0x8183, 0.4)
do
local _0x1104 = Instance.new("UIPadding")
_0x1104.PaddingLeft = UDim.new(0, 6)
_0x1104.Parent = _0x8183
end
local _0x962A = Instance.new("ScrollingFrame")
_0x962A.Size = UDim2.new(1, 0, 0, 96)
_0x962A.BorderSizePixel = 0
_0x962A.ScrollBarThickness = 3
_0x962A.CanvasSize = UDim2.new()
_0x962A.AutomaticCanvasSize = Enum.AutomaticSize.Y
_0x962A.LayoutOrder = _0x2A2C(_0xB4F6)
_0x962A.Parent = _0xB4F6
_0x4EBC(_0x962A,"BackgroundColor3", function() return _0x1FFF.Field end)
_0xEF6D(_0x962A, 3)
_0x85AD(_0x962A, 0.4)
do
local _0x6253 = Instance.new("UIListLayout")
_0x6253.Padding = UDim.new(0, 2)
_0x6253.SortOrder = Enum.SortOrder.LayoutOrder
_0x6253.Parent = _0x962A
local _0x24B8 = Instance.new("UIPadding")
_0x24B8.PaddingTop = UDim.new(0, 3)
_0x24B8.PaddingLeft = UDim.new(0, 3)
_0x24B8.PaddingRight = UDim.new(0, 3)
_0x24B8.Parent = _0x962A
end
local _0xC56E
local function _0xDF5D()
local _0x06B5 = {}
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then _0x06B5[#_0x06B5 + 1] = _0x5D5D.Name end
end
table.sort(_0x06B5, function(_0x82B5, _0x051B) return _0x82B5:lower() < _0x051B:lower() end)
local _0x7877 = string.lower(_0xC248.RageTarget or"")
local _0xF628 = table.concat(_0x06B5,"|") .."#".. _0x7877
if _0xF628 == _0xC56E then return end
_0xC56E = _0xF628
for _0xDCCD, _0x75F5 in ipairs(_0x962A:GetChildren()) do
if _0x75F5:IsA("TextButton") then _0x75F5:Destroy() end
end
for i, _0xBF13 in ipairs(_0x06B5) do
local _0x27BA = (_0x7877 ~=""and string.lower(_0xBF13) == _0x7877)
local _0x051B = Instance.new("TextButton")
_0x051B.Size = UDim2.new(1, -6, 0, 20)
_0x051B.BorderSizePixel = 0
_0x051B.AutoButtonColor = false
_0x051B.Font = _0x4B96
_0x051B.TextSize = 12
_0x051B.TextXAlignment = Enum.TextXAlignment.Left
_0x051B.LayoutOrder = i
_0x051B.Text ="  ".. _0xBF13
_0x051B.BackgroundTransparency = _0x27BA and 0 or 1
_0x051B.BackgroundColor3 = _0x1FFF.Accent
_0x051B.TextColor3 = _0x27BA and Color3.fromRGB(255, 255, 255) or _0x1FFF.Text
_0x051B.Parent = _0x962A
_0xEF6D(_0x051B, 3)
_0x051B.MouseButton1Click:Connect(function()
_0xC248.RageTarget = _0xBF13
_0x8183.Text = _0xBF13
_0xC56E = nil
_0xDF5D()
end)
end
end
_0x8183.FocusLost:Connect(function()
_0xC248.RageTarget = string.gsub(_0x8183.Text,"^%s+",""):gsub("%s+$",""):sub(1, 24)
_0xC56E = nil
_0xDF5D()
end)
_0x40B9.RageTarget = function()
_0x8183.Text = _0xC248.RageTarget
_0xC56E = nil
_0xDF5D()
end
_0x63C7(function() _0xC56E = nil _0xDF5D() end)
_0x32C1(_0x8325.PlayerAdded:Connect(function() task.defer(_0xDF5D) end))
_0x32C1(_0x8325.PlayerRemoving:Connect(function() task.defer(_0xDF5D) end))
_0xDF5D()
local _0x7439 = _0xCD1A(_0xE0E1, 2,"Info")
_0xFAA9 = _0x8649(_0x7439,"Target: none")
_0x18F9(_0x8649(_0x7439,""), function()
return _0x8406(_0xACF9("Ragebot").input) .."  -  rage on / off"end)
_0x8649(_0x7439,"Closest: sticks you to the")
_0x8649(_0x7439,"nearest player until they die")
_0x8649(_0x7439,"Selected: sticks to the name")
_0x8649(_0x7439,"picked above (ignores teams)")
_0x8649(_0x7439,"behind, above or below")
_0x8649(_0x7439,"orbit: spin around them")
_0x8649(_0x7439,"(distance = orbit radius)")
_0x8649(_0x7439,"uses Team Check")
_0x8649(_0x7439,"Void Spam: sits far from the")
_0x8649(_0x7439,"nearest player, then jumps above the")
_0x8649(_0x7439,"target (Closest / Selected)")
_0x8649(_0x7439,"Void Interval: ms in the void")
_0x8649(_0x7439,"Attack Interval: ms on target")
_0x8649(_0x7439,"pauses normal Rage while on")
end
do
local _0x0791 = _0x6BFC("visuals_esp", true)
local _0x66D9 = _0xCD1A(_0x0791, 1,"ESP")
_0xCEB3(_0x66D9,"Enabled","ESP", function()
_0xFE38()
end)
_0xCEB3(_0x66D9,"Chams","Chams", function()
_0xFE38()
end)
_0xCEB3(_0x66D9,"Show Usernames","ShowNames", function()
_0xFE38()
end)
_0xCEB3(_0x66D9,"Tracers","Tracers")
_0xCEB3(_0x66D9,"Boxes","Boxes")
_0xCEB3(_0x66D9,"Box Fill","BoxFill")
_0xCEB3(_0x66D9,"Skeleton","Skeleton")
_0xCEB3(_0x66D9,"Health","ESPHealth")
_0xCEB3(_0x66D9,"Distance","ESPDistance")
_0xCEB3(_0x66D9,"Weapon","ESPWeapon")
_0xCEB3(_0x66D9,"Zombie/NPC ESP","ESPNPCs")
local _0x7439 = _0xCD1A(_0x0791, 2,"Info")
_0x8649(_0x7439,"chams show through walls")
_0x8649(_0x7439,"everything needs ESP on")
_0x8649(_0x7439,"boxes: outline + optional")
_0x8649(_0x7439,"see-through fill")
_0x8649(_0x7439,"skeleton: bone lines")
_0x8649(_0x7439,"health: bar beside player")
_0x8649(_0x7439,"distance: top right of box")
_0x8649(_0x7439,"weapon: held tool, under box")
_0x8649(_0x7439,"colours are in Colours")
enddo
local _0x6FDB = 320
local _0xD838 = 40local _0xE3C9 = 0.8local _0xD6B3 = 0.012if _0xC248.PreviewAutoSpin == nil then _0xC248.PreviewAutoSpin = false end
local _0x73D0 = _0x6BFC("visuals_preview", true)
local _0x8047 = _0xCD1A(_0x73D0, 1,"ESP Preview")
local _0xDDB4 = Instance.new("Frame")
_0xDDB4.Name ="OULPreview"_0xDDB4.Size = UDim2.new(1, 0, 0, _0x6FDB)
_0xDDB4.BorderSizePixel = 0
_0xDDB4.ClipsDescendants = true
_0xDDB4.Active = true
_0xDDB4.LayoutOrder = _0x2A2C(_0x8047)
_0xDDB4.Parent = _0x8047
_0x4EBC(_0xDDB4,"BackgroundColor3", function()
return _0x1FFF.Background:Lerp(Color3.fromRGB(0, 0, 0), 0.35)
end)
_0xEF6D(_0xDDB4, 4)
_0x85AD(_0xDDB4, 0.4)
local _0xB277 = Instance.new("ViewportFrame")
_0xB277.Name ="PreviewViewport"_0xB277.Size = UDim2.fromScale(1, 1)
_0xB277.BackgroundTransparency = 1
_0xB277.BorderSizePixel = 0
_0xB277.Ambient = Color3.fromRGB(160, 160, 170)
_0xB277.LightColor = Color3.fromRGB(255, 255, 255)
_0xB277.LightDirection = Vector3.new(0.3, -0.5, 1)
_0xB277.ZIndex = 2
_0xB277.Parent = _0xDDB4
local _0x0DE2 = Instance.new("Camera")
_0x0DE2.FieldOfView = _0xD838
_0x0DE2.Parent = _0xB277
_0xB277.CurrentCamera = _0x0DE2
local _0xDD1E = Instance.new("Frame")
_0xDD1E.Name ="PreviewOverlay"_0xDD1E.Size = UDim2.fromScale(1, 1)
_0xDD1E.BackgroundTransparency = 1
_0xDD1E.BorderSizePixel = 0
_0xDD1E.ZIndex = 3
_0xDD1E.Parent = _0xDDB4
local _0xF03D = Instance.new("Frame")
_0xF03D.Name ="Box"_0xF03D.BorderSizePixel = 0
_0xF03D.BackgroundColor3 = _0x0556.BoxFill
_0xF03D.BackgroundTransparency = 1
_0xF03D.Visible = false
_0xF03D.Parent = _0xDD1E
local _0x7FA2 = Instance.new("UIStroke")
_0x7FA2.Thickness = 1.5
_0x7FA2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0x7FA2.Color = _0x0556.Box
_0x7FA2.Parent = _0xF03D
local _0x0DF2 = Instance.new("Frame")
_0x0DF2.Name ="HealthBar"_0x0DF2.BorderSizePixel = 0
_0x0DF2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0x0DF2.BackgroundTransparency = 0.35
_0x0DF2.Visible = false
_0x0DF2.Parent = _0xDD1E
local _0xD204 = Instance.new("Frame")
_0xD204.BorderSizePixel = 0
_0xD204.AnchorPoint = Vector2.new(0, 1)
_0xD204.Parent = _0x0DF2
local _0xBC28 = Instance.new("Frame")
_0xBC28.Name ="Tracer"_0xBC28.AnchorPoint = Vector2.new(0.5, 0.5)
_0xBC28.BorderSizePixel = 0
_0xBC28.Visible = false
_0xBC28.Parent = _0xDD1E
local _0x6ABB = Instance.new("TextLabel")
_0x6ABB.Name ="Name"_0x6ABB.AnchorPoint = Vector2.new(0.5, 0.5)
_0x6ABB.Size = UDim2.fromOffset(200, 20)
_0x6ABB.BackgroundTransparency = 1
_0x6ABB.Font = Enum.Font.Code
_0x6ABB.TextSize = 13
_0x6ABB.TextStrokeTransparency = 0
_0x6ABB.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_0x6ABB.Text = _0x6FE4.Name
_0x6ABB.Visible = false
_0x6ABB.Parent = _0xDD1E
local function _0x50EF(_0xBF13, align, _0x7368, _0x0866)
local _0xCAC0 = Instance.new("TextLabel")
_0xCAC0.Name = _0xBF13
_0xCAC0.AnchorPoint = _0x7368
_0xCAC0.Size = UDim2.fromOffset(_0x0866, 14)
_0xCAC0.BackgroundTransparency = 1
_0xCAC0.Font = Enum.Font.Code
_0xCAC0.TextSize = 12
_0xCAC0.TextXAlignment = align
_0xCAC0.TextStrokeTransparency = 0
_0xCAC0.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_0xCAC0.Visible = false
_0xCAC0.Parent = _0xDD1E
return _0xCAC0
end
local _0x0534 = _0x50EF("Distance", Enum.TextXAlignment.Right, Vector2.new(1, 0), 90)
_0x0534.Text ="12 studs"local _0x192F = _0x50EF("Weapon", Enum.TextXAlignment.Center, Vector2.new(0.5, 0), 160)
local _0x36B2 = Instance.new("TextLabel")
_0x36B2.Name ="EspOff"_0x36B2.AnchorPoint = Vector2.new(0.5, 0)
_0x36B2.Position = UDim2.new(0.5, 0, 0, 6)
_0x36B2.Size = UDim2.new(1, -12, 0, 14)
_0x36B2.BackgroundTransparency = 1
_0x36B2.Font = _0x4B96
_0x36B2.TextSize = 11
_0x36B2.Text ="ESP is off - turn it on in the ESP tab"_0x36B2.Visible = false
_0x36B2.Parent = _0xDD1E
_0x8C5B(_0x36B2, true)local _0x114D, _0x4C77, _0x5264, _0xBD1E = nil, {}, {}, {}
local _0xC9A4 = {}
local _0x9911 = nil
local _0x8504, _0xC60A = 0, false
local _0xC07B, _0x2584 = true, false
local _0x0FE0 = 0
local _0x8D16
local _0x4F77
local _0x2543, _0x236A = false, false
local function _0x867A(_0x0472)
if _0x8D16 then _0x8D16.Text = _0x0472 end
endlocal function _0x3513(_0x4AB6, fovDeg, _0x0866, _0xCF21, _0xCF40)
local _0xDBFB = _0x4AB6:PointToObjectSpace(_0xCF40)
local _0xFA1B = -_0xDBFB.Z
if _0xFA1B <= 0.05 then return nil end
local _0xBF16 = 1 / math.tan(math.rad(fovDeg) / 2)
local _0x0502 = (_0xDBFB.X / _0xFA1B) * _0xBF16 / (_0x0866 / _0xCF21)
local _0x63F8 = (_0xDBFB.Y / _0xFA1B) * _0xBF16
return Vector2.new((_0x0502 * 0.5 + 0.5) * _0x0866, (0.5 - _0x63F8 * 0.5) * _0xCF21)
endlocal _0xD140 = {
{"HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), 1 },
{"UpperTorso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), 0 },
{"Head", Vector3.new(1.2, 1.1, 1.1), Vector3.new(0, 1.55, 0), 0 },
{"LeftUpperArm", Vector3.new(0.9, 2, 0.9), Vector3.new(1.45, 0, 0), 0 },
{"RightUpperArm", Vector3.new(0.9, 2, 0.9), Vector3.new(-1.45, 0, 0), 0 },
{"LeftUpperLeg", Vector3.new(0.9, 2, 1), Vector3.new(0.5, -2, 0), 0 },
{"RightUpperLeg", Vector3.new(0.9, 2, 1), Vector3.new(-0.5, -2, 0), 0 },
}
local _0x50F5 = {
{"UpperTorso","Head"}, {"UpperTorso","LeftUpperArm"}, {"UpperTorso","RightUpperArm"},
{"UpperTorso","LeftUpperLeg"}, {"UpperTorso","RightUpperLeg"},
}
local function _0x9B45()
local _0x752D = Instance.new("Model")
_0x752D.Name ="PreviewRig"local _0x6358 = {}
for _0xDCCD, _0x6727 in ipairs(_0xD140) do
local _0xCF40 = Instance.new("Part")
_0xCF40.Name = _0x6727[1]
_0xCF40.Size = _0x6727[2]
_0xCF40.CFrame = CFrame.new(_0x6727[3])
_0xCF40.Transparency = _0x6727[4]
_0xCF40.Anchored = true
_0xCF40.CanCollide = false
_0xCF40.Material = Enum.Material.SmoothPlastic
_0xCF40.Color = Color3.fromRGB(163, 162, 165)
_0xCF40.TopSurface = Enum.SurfaceType.Smooth
_0xCF40.BottomSurface = Enum.SurfaceType.Smooth
_0xCF40.Parent = _0x752D
_0x6358[_0x6727[1]] = _0xCF40
end
_0x752D.PrimaryPart = _0x6358.HumanoidRootPart
local _0xEC0F = {}
for _0xDCCD, _0x051B in ipairs(_0x50F5) do
_0xEC0F[#_0xEC0F + 1] = { _0x6358[_0x051B[1]], _0x6358[_0x051B[2]] }
end
return _0x752D, _0xEC0F
endlocal function _0xA243(_0x752D, _0x80EB)
local _0x8A92 = {}
for _0xDCCD, _0x6727 in ipairs(_0x752D:GetDescendants()) do
if _0x6727:IsA("JointInstance") and _0x6727.Part0 and _0x6727.Part1
and _0x6727.Part0:IsDescendantOf(_0x752D) and _0x6727.Part1:IsDescendantOf(_0x752D) then
_0x8A92[#_0x8A92 + 1] = _0x6727
end
end
local _0xB100 = { [_0x80EB] = CFrame.new() }
local _0xDE71 = true
while _0xDE71 do
_0xDE71 = false
for _0xDCCD, j in ipairs(_0x8A92) do
local _0x82B5, _0x051B = j.Part0, j.Part1
if _0xB100[_0x82B5] and not _0xB100[_0x051B] then
_0xB100[_0x051B] = _0xB100[_0x82B5] * j.C0 * j.C1:Inverse()
_0xDE71 = true
elseif _0xB100[_0x051B] and not _0xB100[_0x82B5] then
_0xB100[_0x82B5] = _0xB100[_0x051B] * j.C1 * j.C0:Inverse()
_0xDE71 = true
end
end
end
return _0xB100
endlocal function _0x1431(_0x9839)
local _0x80EB = _0x9839:FindFirstChild("HumanoidRootPart")
if not (_0x80EB and _0x80EB:IsA("BasePart")) then
_0x9839:Destroy()
return nil
end
for _0xDCCD, _0x6727 in ipairs(_0x9839:GetDescendants()) do
if _0x6727:IsA("LuaSourceContainer") or _0x6727:IsA("Sound") or _0x6727:IsA("ForceField")
or _0x6727:IsA("Humanoid") or _0x6727:IsA("Highlight") or _0x6727:IsA("BillboardGui") then
pcall(function() _0x6727:Destroy() end)
end
end
local _0xB100 = _0xA243(_0x9839, _0x80EB)
local _0xAE1F = 0
for _0xDCCD, _0x6727 in ipairs(_0x9839:GetDescendants()) do
if _0x6727:IsA("BasePart") then
local _0x75F5 = _0xB100[_0x6727]
if _0x75F5 then
_0x6727.CFrame = _0x75F5
_0x6727.Anchored = true
_0x6727.CanCollide = false
if _0x6727 ~= _0x80EB and _0x6727.Transparency < 0.99 then _0xAE1F = _0xAE1F + 1 end
else
pcall(function() _0x6727:Destroy() end)end
end
end
if _0xAE1F < 5 then
_0x9839:Destroy()
return nil
end
local _0xEC0F = {}
for _0xDCCD, _0x6727 in ipairs(_0x9839:GetDescendants()) do
if _0x6727:IsA("Motor6D") and _0x6727.Part0 and _0x6727.Part1
and _0x6727.Part0.Parent == _0x9839 and _0x6727.Part1.Parent == _0x9839
and _0x6727.Part0.Name ~="HumanoidRootPart"and _0x6727.Part1.Name ~="HumanoidRootPart"then
_0xEC0F[#_0xEC0F + 1] = { _0x6727.Part0, _0x6727.Part1 }
end
end
_0x9839.Name ="PreviewRig"_0x9839.PrimaryPart = _0x80EB
return _0x9839, _0xEC0F
end
local function _0xEC2A()
local _0x1DBF = _0x6FE4.Character
if not _0x1DBF then return nil end
local _0x73C5 = _0x1DBF.Archivable
_0x1DBF.Archivable = true
local _0x499B, _0x9839 = pcall(function() return _0x1DBF:Clone() end)
_0x1DBF.Archivable = _0x73C5
if not _0x499B or typeof(_0x9839) ~="Instance"then return nil end
return _0x1431(_0x9839)
endlocal function _0xD6CF(_0x27BA)
if _0x2584 == _0x27BA then return end
_0x2584 = _0x27BA
for _0xDCCD, _0x75F5 in ipairs(_0xBD1E) do
_0x75F5.Transparency = _0x27BA and 0.5 or 1
end
end
local function _0xDC9B(_0x752D, boneList)
if _0x114D then pcall(function() _0x114D:Destroy() end) end
_0x114D, _0x4C77 = _0x752D, boneList
_0x5264, _0xBD1E = {}, {}
_0x2584 = false
for _0xDCCD, _0x6727 in ipairs(_0x752D:GetDescendants()) do
if _0x6727:IsA("BasePart") and _0x6727.Name ~="HumanoidRootPart"and _0x6727.Transparency < 0.99 then
_0x5264[#_0x5264 + 1] = _0x6727
end
end
_0x752D.Parent = _0xB277_0x752D:PivotTo(CFrame.new())
local _0x75E5, _0xAF37 = _0x752D:GetBoundingBox()
local _0xB8C9 = math.max(_0x75E5.Position.Y + _0xAF37.Y / 2, 4.4)
local _0x7B5C = math.min(_0x75E5.Position.Y - _0xAF37.Y / 2, -3.3)
_0x9911 = {
_0xEBCD = Vector3.new(_0x75E5.Position.X, (_0xB8C9 + _0x7B5C) / 2, _0x75E5.Position.Z),
_0xCF21 = _0xB8C9 - _0x7B5C,
_0x0866 = math.max(_0xAF37.X, _0xAF37.Z, 4),
}
_0x0FE0 = 0
local _0x8441 = Instance.new("Folder")
_0x8441.Name ="Chams"_0x8441.Parent = _0x752D
for _0xDCCD, _0xCF40 in ipairs(_0x5264) do
local _0x499B, _0x75F5 = pcall(function() return _0xCF40:Clone() end)
if _0x499B and _0x75F5 then
for _0xDCCD, ch in ipairs(_0x75F5:GetChildren()) do
if not ch:IsA("DataModelMesh") then ch:Destroy() end
end
_0x75F5.Name ="Cham"_0x75F5.Anchored = true
_0x75F5.CanCollide = false
_0x75F5.Material = Enum.Material.Neon
_0x75F5.Color = _0x0556.Fill
_0x75F5.Transparency = 1
if _0x75F5:IsA("MeshPart") then _0x75F5.TextureID =""end
_0x75F5.Size = _0xCF40.Size * 1.06
_0x75F5.CFrame = _0xCF40.CFrame
_0x75F5.Parent = _0x8441
_0xBD1E[#_0xBD1E + 1] = _0x75F5
end
end
for _0xDCCD, _0x7238 in ipairs(_0xC9A4) do _0x7238:Destroy() end
_0xC9A4 = {}
for i = 1, #_0x4C77 do
local _0x7238 = Instance.new("Frame")
_0x7238.Name ="Bone"_0x7238.AnchorPoint = Vector2.new(0.5, 0.5)
_0x7238.BorderSizePixel = 0
_0x7238.Visible = false
_0x7238.Parent = _0xDD1E
_0xC9A4[i] = _0x7238
end
endlocal function _0xB177(_0xF22C)
if not _0x9911 then return end
local _0xC4A0 = math.tan(math.rad(_0xD838) / 2)
local _0xA771 = (_0x9911.h / 2 + 0.8) / _0xC4A0
local _0x3BF9 = (_0x9911.w / 2 + 0.8) / (_0xC4A0 * _0xF22C)
local _0xD840 = math.max(_0xA771, _0x3BF9)
_0x0DE2.CFrame = CFrame.lookAt(_0x9911.center + Vector3.new(0, 0, -_0xD840), _0x9911.center)
_0x0FE0 = _0xF22C
end
local function _0xEA93(_0x34A5, _0x82CE, _0xBDF6, thickness, _0x5A2F)
local _0xA43A = _0xBDF6 - _0x82CE
local _0xEFA8 = (_0x82CE + _0xBDF6) / 2
_0x34A5.Size = UDim2.fromOffset(_0xA43A.Magnitude, thickness)
_0x34A5.Position = UDim2.fromOffset(_0xEFA8.X, _0xEFA8.Y)
_0x34A5.Rotation = math.deg(math.atan2(_0xA43A.Y, _0xA43A.X))
_0x34A5.BackgroundColor3 = _0x5A2F
_0x34A5.Visible = true
end
local function _0x2E24(dt)
if not (_0x8C4E and _0xAE9A.Visible and _0x8CF4 =="visuals_preview") then return endlocal _0x434E = _0xD1D6.absK and _0xD1D6.absK() or 1
local _0x73FA, _0xF264 = _0xDDB4.AbsoluteSize.X / _0x434E, _0xDDB4.AbsoluteSize.Y / _0x434E
if _0x73FA < 40 or _0xF264 < 40 then return end
if _0xC07B then
_0xC07B = false
local _0x752D, _0x051B = _0xEC2A()
if _0x752D then
_0x2543 = false
_0xDC9B(_0x752D, _0x051B)
_0x867A("model: your avatar")
elselocal _0x71AD, _0xCCCD = _0x9B45()
_0x2543 = true
_0xDC9B(_0x71AD, _0xCCCD)
_0x867A("model: dummy (loading avatar)")
if not _0x236A then
_0x236A = true
task.spawn(function()
local _0x499B, _0x997E = pcall(function()
return _0x8325:CreateHumanoidModelFromUserId(_0x6FE4.UserId)
end)
_0x236A = false
if not (_0x499B and typeof(_0x997E) =="Instance") then
_0x867A("model: dummy (avatar load failed)")
return
end
if not (_0xE870 and _0x2543) then
_0x997E:Destroy()
return
end
local _0x48C6, _0x92DB = _0x1431(_0x997E)
if _0x48C6 then
_0x2543 = false
_0xDC9B(_0x48C6, _0x92DB)
_0x867A("model: your avatar (by user id)")
else
_0x867A("model: dummy (avatar load failed)")
end
end)
end
end
end
if not _0x114D then return end
local _0xF22C = _0x73FA / _0xF264
if math.abs(_0xF22C - _0x0FE0) > 0.005 then _0xB177(_0xF22C) end
if _0xC248.PreviewAutoSpin and not _0xC60A then
_0x8504 = (_0x8504 + dt * _0xE3C9) % (math.pi * 2)
end
_0x114D:PivotTo(CFrame.Angles(0, _0x8504, 0))local _0x3A2C = _0xC248.ESP == true
local function _0xD32A(_0xB92E) return _0x3A2C and _0xC248[_0xB92E] == true end
local _0x4F81 = false
for _0xDCCD, _0xB92E in ipairs({"Boxes","ESPHealth","ESPDistance","ESPWeapon","ShowNames","Tracers","Skeleton","Chams"}) do
if _0xD32A(_0xB92E) then
_0x4F81 = true
break
end
end
_0x36B2.Text = _0x3A2C and"No ESP options enabled - turn some on in the ESP tab"or"ESP is off - turn it on in the ESP tab"_0x36B2.Visible = not _0x4F81
_0xD6CF(_0xD32A("Chams"))
if _0x2584 then
for _0xDCCD, _0x75F5 in ipairs(_0xBD1E) do
if _0x75F5.Color ~= _0x0556.Fill then _0x75F5.Color = _0x0556.Fill end
end
end
local _0x4AB6 = _0x0DE2.CFrame
local function _0xC59A(_0xCF40) return _0x3513(_0x4AB6, _0xD838, _0x73FA, _0xF264, _0xCF40) endlocal _0x80EB = _0x114D.PrimaryPart
local _0xA5F8 = _0x80EB.CFrame
local _0x0DD5 = _0xA5F8.LookVector
local _0x8312 = (_0x0DD5.X * _0x0DD5.X + _0x0DD5.Z * _0x0DD5.Z > 0.0001) and math.atan2(-_0x0DD5.X, -_0x0DD5.Z) or 0
local _0x44B0 = CFrame.new(_0xA5F8.Position) * CFrame.Angles(0, _0x8312, 0)
local _0x0250, _0x7025, _0x76F2, _0x208A = math.huge, math.huge, -math.huge, -math.huge
local _0xCC4B = true
for i = 0, 7 do
local _0x8F0E = (i % 2 == 0) and -2 or 2
local _0x6998 = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
local _0x035B = (i < 4) and -1 or 1
local _0xC566 = _0xC59A(_0x44B0:PointToWorldSpace(Vector3.new(_0x8F0E, _0x6998, _0x035B)))
if not _0xC566 then
_0xCC4B = false
break
end
_0x0250, _0x76F2 = math.min(_0x0250, _0xC566.X), math.max(_0x76F2, _0xC566.X)
_0x7025, _0x208A = math.min(_0x7025, _0xC566.Y), math.max(_0x208A, _0xC566.Y)
end
_0xCC4B = _0xCC4B and (_0x208A - _0x7025) > 2if _0xD32A("Boxes") and _0xCC4B then
_0xF03D.Position = UDim2.fromOffset(_0x0250, _0x7025)
_0xF03D.Size = UDim2.fromOffset(_0x76F2 - _0x0250, _0x208A - _0x7025)
_0xF03D.BackgroundColor3 = _0x0556.BoxFill
_0xF03D.BackgroundTransparency = _0xD32A("BoxFill") and 0.82 or 1
_0x7FA2.Color = _0x0556.Box
_0xF03D.Visible = true
else
_0xF03D.Visible = false
endif _0xD32A("ESPHealth") and _0xCC4B then
local _0xCF21 = _0x208A - _0x7025
local _0x8E01 = 1_0x0DF2.Position = UDim2.fromOffset(_0x0250 - 7, _0x7025)
_0x0DF2.Size = UDim2.fromOffset(4, _0xCF21)
_0xD204.Position = UDim2.new(0, 1, 1, -1)
_0xD204.Size = UDim2.new(1, -2, 0, math.max((_0xCF21 - 2) * _0x8E01, 0))
_0xD204.BackgroundColor3 = Color3.fromRGB(235, 70, 70):Lerp(Color3.fromRGB(90, 220, 120), _0x8E01)
_0x0DF2.Visible = true
else
_0x0DF2.Visible = false
endif _0xD32A("ESPDistance") and _0xCC4B then
_0x0534.Position = UDim2.fromOffset(_0x76F2 - 3, _0x7025 + 2)
_0x0534.TextColor3 = _0x0556.Name
_0x0534.Visible = true
else
_0x0534.Visible = false
end
if _0xD32A("ESPWeapon") and _0xCC4B then
local _0x1DBF = _0x6FE4.Character
local _0xA5E9 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Tool")
_0x192F.Text = _0xA5E9 and _0xA5E9.Name or"Weapon"_0x192F.Position = UDim2.fromOffset((_0x0250 + _0x76F2) / 2, _0x208A + 2)
_0x192F.TextColor3 = _0x0556.Name
_0x192F.Visible = true
else
_0x192F.Visible = false
endif _0xD32A("ShowNames") then
local _0x9C99 = _0x114D:FindFirstChild("Head")
local _0x7368 = (_0x9C99 and _0x9C99:IsA("BasePart")) and _0x9C99.Position or (_0xA5F8.Position + Vector3.new(0, 1.6, 0))
local _0xC566 = _0xC59A(_0x7368 + Vector3.new(0, 2.2, 0))
if _0xC566 then
_0x6ABB.Position = UDim2.fromOffset(_0xC566.X, _0xC566.Y)
_0x6ABB.TextColor3 = _0x0556.Name
_0x6ABB.Visible = true
else
_0x6ABB.Visible = false
end
else
_0x6ABB.Visible = false
endif _0xD32A("Tracers") then
local _0xC566 = _0xC59A(_0xA5F8.Position)
if _0xC566 then
_0xEA93(_0xBC28, Vector2.new(_0x73FA / 2, _0xF264), _0xC566, 1.5, _0x0556.Tracer)
else
_0xBC28.Visible = false
end
else
_0xBC28.Visible = false
endlocal _0xEE5E = _0xD32A("Skeleton")
for i, _0x051B in ipairs(_0x4C77) do
local _0x4883 = _0xC9A4[i]
if _0x4883 then
local _0x2BD1 = false
if _0xEE5E and _0x051B[1].Parent and _0x051B[2].Parent then
local _0xB479, _0x92DB = _0xC59A(_0x051B[1].Position), _0xC59A(_0x051B[2].Position)
if _0xB479 and _0x92DB then
_0xEA93(_0x4883, _0xB479, _0x92DB, 1.5, _0x0556.Skeleton)
_0x2BD1 = true
end
end
if not _0x2BD1 then _0x4883.Visible = false end
end
end
end
_0x32C1(_0x2C20.RenderStepped:Connect(function(dt)
local _0x499B, _0xABB0 = pcall(_0x2E24, dt)
if not _0x499B and _0xABB0 ~= _0x4F77 then
_0x4F77 = _0xABB0
warn("[OUL preview] ".. tostring(_0xABB0))
end
end))local _0x84ED = Instance.new("TextButton")
_0x84ED.Name ="DragCatcher"_0x84ED.Size = UDim2.fromScale(1, 1)
_0x84ED.BackgroundTransparency = 1
_0x84ED.BorderSizePixel = 0
_0x84ED.Text =""_0x84ED.AutoButtonColor = false
_0x84ED.ZIndex = 10
_0x84ED.Parent = _0xDDB4
local _0x6900 = game:GetService("GuiService")
local _0x1235 = 0
local function _0x079A(_0x4CCB)
_0xC60A = true
_0x1235 = _0x4CCB
end
_0x84ED.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1
or _0x862B.UserInputType == Enum.UserInputType.Touch then
_0x079A(_0x862B.Position.X)
end
end)_0x32C1(_0x85F6.InputBegan:Connect(function(_0x862B)
if _0xC60A or _0x862B.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
if not (_0x8C4E and _0xAE9A.Visible and _0x8CF4 =="visuals_preview") then return end
local _0x942D = _0xDDB4:FindFirstAncestorOfClass("ScreenGui")
local _0x61E7 = (_0x942D and _0x942D.IgnoreGuiInset) and Vector2.zero or _0x6900:GetGuiInset()
local _0x752D = _0x85F6:GetMouseLocation() - _0x61E7
local _0x6BF8, _0x7B8B = _0xDDB4.AbsolutePosition, _0xDDB4.AbsoluteSize
if _0x752D.X >= _0x6BF8.X and _0x752D.X <= _0x6BF8.X + _0x7B8B.X and _0x752D.Y >= _0x6BF8.Y and _0x752D.Y <= _0x6BF8.Y + _0x7B8B.Y then
_0x079A(_0x752D.X)
end
end))_0x32C1(_0x85F6.InputChanged:Connect(function(_0x862B)
if _0xC60A and (_0x862B.UserInputType == Enum.UserInputType.MouseMovement
or _0x862B.UserInputType == Enum.UserInputType.Touch) then
local _0x4CCB = _0x862B.Position.X
_0x8504 = (_0x8504 + (_0x4CCB - _0x1235) * _0xD6B3) % (math.pi * 2)
_0x1235 = _0x4CCB
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType == Enum.UserInputType.MouseButton1
or _0x862B.UserInputType == Enum.UserInputType.Touch then
_0xC60A = false
end
end))_0x32C1(_0x6FE4.CharacterAdded:Connect(function()
task.delay(1.5, function()
if _0xE870 then _0xC07B = true end
end)
end))local _0xCD7C, _0x4C15 = Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170)
local _0x3CB7 = _0xCD1A(_0x73D0, 2,"Preview")
_0xCEB3(_0x3CB7,"Auto spin","PreviewAutoSpin")
_0x3E65(_0x3CB7,"Reset angle", _0xCD7C, _0x4C15, function() _0x8504 = 0 end)
_0x3E65(_0x3CB7,"Refresh model", _0xCD7C, _0x4C15, function() _0xC07B = true end)
local _0x7439 = _0xCD1A(_0x73D0, 2,"Info")
_0x8D16 = _0x8649(_0x7439,"model: not built yet")
_0x8649(_0x7439,"drag the preview to rotate")
_0x8649(_0x7439,"shows only what you have")
_0x8649(_0x7439,"enabled in the ESP tab")
_0x8649(_0x7439,"(ESP master switch too)")
_0x8649(_0x7439,"weapon: shows 'Weapon' if")
_0x8649(_0x7439,"you hold no tool here")
_0x8649(_0x7439,"chams: fill colour only here")
_0x8649(_0x7439,"tracer starts at the bottom")
_0x8649(_0x7439,"Refresh model after respawn")
enddo
local _0x8E19 = _0x6BFC("visuals_colours", true)
local _0xE4E6 = _0xCD1A(_0x8E19, 1,"Chams")
_0xB1B5(_0xE4E6,"Cham Fill", _0xF8FA(_0x0556.Fill), _0x72F0, _0x0556.Fill)
_0xB1B5(_0xE4E6,"Cham Outline", _0xF8FA(_0x0556.Outline), _0x8436, _0x0556.Outline)
local _0x849B = _0xCD1A(_0x8E19, 1,"Boxes")
_0xB1B5(_0x849B,"Box", _0xF8FA(_0x0556.Box), _0x3675, _0x0556.Box)
_0xB1B5(_0x849B,"Box Fill", _0xF8FA(_0x0556.BoxFill), _0x9383, _0x0556.BoxFill)
local _0xE2B5 = _0xCD1A(_0x8E19, 2,"Text & Lines")
_0xB1B5(_0xE2B5,"Tracers", _0xF8FA(_0x0556.Tracer), _0x0669, _0x0556.Tracer)
_0xB1B5(_0xE2B5,"Usernames", _0xF8FA(_0x0556.Name), _0x5A59, _0x0556.Name)
_0xB1B5(_0xE2B5,"Skeleton", _0xF8FA(_0x0556.Skeleton), function(_0x5A2F)
_0x0556.Skeleton = _0x5A2F
end, _0x0556.Skeleton)
end
do
local _0x8683 = _0x6BFC("visuals_radar", true)
local _0x66D9 = _0xCD1A(_0x8683, 1,"Radar")
_0xCEB3(_0x66D9,"Enabled","Radar", function(_0x27BA)
if _0x27BA and _0x9996 then _0x9996("Radar  -  ".. tostring(_0xD1D6.radarMode) .." mode") end
end)
_0xBBEF(_0x66D9,"Range (studs)", 50, 1000,"RadarRange")
_0xBBEF(_0x66D9,"Size", 100, 300,"RadarSize")
_0xBBEF(_0x66D9,"Dot Size", 4, 14,"RadarDotSize")
_0xBBEF(_0x66D9,"Line Thickness", 1, 4,"RadarLineThickness")
local _0x6BF8 = _0xCD1A(_0x8683, 1,"Position")
do
local _0xF666 = Instance.new("Frame")
_0xF666.Size = UDim2.new(1, 0, 0, 106)
_0xF666.BackgroundTransparency = 1
_0xF666.LayoutOrder = _0x2A2C(_0x6BF8)
_0xF666.Parent = _0x6BF8
local _0xF79D = Instance.new("UIGridLayout")
_0xF79D.CellSize = UDim2.new(0.5, -3, 0, 30)
_0xF79D.CellPadding = UDim2.fromOffset(6, 6)
_0xF79D.SortOrder = Enum.SortOrder.LayoutOrder
_0xF79D.Parent = _0xF666
local _0x498C = {}
local _0x0713 = {
{ id ="TopLeft", _0x7465 ="Top Left", order = 1 },
{ id ="TopRight", _0x7465 ="Top Right", order = 2 },
{ id ="BottomLeft", _0x7465 ="Bottom Left", order = 3 },
{ id ="BottomRight", _0x7465 ="Bottom Right", order = 4 },
{ id ="Custom", _0x7465 ="Custom (drag)", order = 5 },
}
local function _0x41DF(animate)
for id, _0x35A4 in pairs(_0x498C) do
_0x91F0(_0x35A4, {
BackgroundTransparency = (_0xC248.RadarCorner == id) and 0 or 1,
TextColor3 = (_0xC248.RadarCorner == id) and Color3.fromRGB(255, 255, 255) or _0x1FFF.Dim,
}, animate)
end
end
for _0xDCCD, _0x75F5 in ipairs(_0x0713) do
local _0x35A4 = Instance.new("TextButton")
_0x35A4.LayoutOrder = _0x75F5.order
_0x35A4.BorderSizePixel = 0
_0x35A4.AutoButtonColor = false
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 12
_0x35A4.Text = _0x75F5.label
_0x35A4.Parent = _0xF666
_0x4EBC(_0x35A4,"BackgroundColor3", function() return _0x1FFF.Accent end)
_0xEF6D(_0x35A4, 3)
_0x85AD(_0x35A4, 0.4)
_0x498C[_0x75F5.id] = _0x35A4
_0x35A4.MouseButton1Click:Connect(function()
_0xC248.RadarCorner = _0x75F5.id
_0x41DF(true)
end)
end
_0x63C7(function() _0x41DF(true) end)
_0x40B9.RadarCorner = _0x41DF
_0x41DF(false)
end
_0x8649(_0x6BF8,"Custom: open the menu, then")
_0x8649(_0x6BF8,"left click + drag the radar")
local _0x7560 = _0xCD1A(_0x8683, 2,"Colours")
_0xB1B5(_0x7560,"Radar", _0xF8FA(_0x0556.Radar), function(_0x5A2F)
_0x0556.Radar = _0x5A2F
end, _0x0556.Radar)
_0xB1B5(_0x7560,"Radar Lines", _0xF8FA(_0x0556.RadarLines), function(_0x5A2F)
_0x0556.RadarLines = _0x5A2F
end, _0x0556.RadarLines)
local _0x7439 = _0xCD1A(_0x8683, 2,"Info")
_0x8649(_0x7439,"rings + crosshair only,")
_0x8649(_0x7439,"no background: stays out")
_0x8649(_0x7439,"of the way of your screen")
_0x8649(_0x7439,"dots = other players")
_0x8649(_0x7439,"range = edge of the rings")
_0x18F9(_0x8649(_0x7439,""), function()
return"mode: ".. tostring(_0xD1D6.radarMode)
end)
end
do
local _0xE997 = _0x6BFC("visuals_sky", true)
local _0x66D9 = _0xCD1A(_0xE997, 1,"Skybox")
_0xCEB3(_0x66D9,"Enabled","Skybox")
_0xCEB3(_0x66D9,"Rainbow","SkyRainbow")local _0x76A7 = {
Color3.fromRGB(0, 0, 0),
Color3.fromRGB(128, 128, 128),
Color3.fromRGB(255, 255, 255),
_0x0556.Sky,
}
for i = 2, 13 do
_0x76A7[#_0x76A7 + 1] = _0xA955[i]
end
_0xB1B5(_0x66D9,"Sky Colour", _0x76A7, function(_0x5A2F)
_0x0556.Sky = _0x5A2F
end, _0x0556.Sky)
_0xBBEF(_0x66D9,"Brightness", 0, 100,"SkyBrightness")
local _0x7439 = _0xCD1A(_0xE997, 2,"Info")
_0x8649(_0x7439,"recolours the whole sky")
_0x8649(_0x7439,"hides the game's own sky")
_0x8649(_0x7439,"and haze (put back when off)")
_0x8649(_0x7439,"rainbow cycles colours")
_0x8649(_0x7439,"brightness: 0 = black,")
_0x8649(_0x7439,"100 = full colour")
_0x8649(_0x7439,"white + brightness = grey")
_0x8649(_0x7439,"needs writefile support")
end
do
local _0xAB4A = _0x6BFC("visuals_world", true)
local _0x66D9 = _0xCD1A(_0xAB4A, 1,"World")
_0xCEB3(_0x66D9,"Fullbright","Fullbright", function()
_0x16AC()
end)
_0xCEB3(_0x66D9,"No Fog","NoFog", function()
_0x16AC()
end)
_0xCEB3(_0x66D9,"Rain","Rain")
local _0x7439 = _0xCD1A(_0xAB4A, 2,"Info")
_0x8649(_0x7439,"fullbright: max brightness,")
_0x8649(_0x7439,"no shadows, flat lighting")
_0x8649(_0x7439,"no fog: removes distance fog")
_0x8649(_0x7439,"and atmosphere haze")
_0x8649(_0x7439,"rain: rain streaks fall over")
_0x8649(_0x7439,"your screen (under the menu)")
_0x8649(_0x7439,"original lighting restored")
_0x8649(_0x7439,"when turned off / unloaded")
enddo
local _0x90A9 = 260
local _0x6214 = 4
local _0x5086 = Color3.fromRGB(170, 185, 205)
local _0xDDB4 = nil
local _0x1F18 = {}
local function _0x7BC2(_0x6727, anywhere)
local _0xFA1B = math.random()
_0x6727.len = 0.016 + _0xFA1B * 0.05_0x6727.speed = 0.9 + _0xFA1B * 0.9_0x6727.x = math.random() * 1.15 - 0.1_0x6727.y = anywhere and math.random() or -_0x6727.len - math.random() * 0.1
_0x6727.frame.Size = UDim2.new(0, _0xFA1B > 0.8 and 2 or 1, _0x6727.len, 0)
_0x6727.frame.BackgroundTransparency = 1 - (0.14 + _0xFA1B * 0.36)
end
local function _0xCEF3()
_0xDDB4 = Instance.new("Frame")
_0xDDB4.Name ="OULScreenRain"_0xDDB4.Size = UDim2.fromScale(1, 1)
_0xDDB4.BackgroundTransparency = 1
_0xDDB4.BorderSizePixel = 0
_0xDDB4.Active = false
_0xDDB4.ZIndex = 0_0xDDB4.Visible = false
_0xDDB4.Parent = _0xD27F
for i = 1, _0x90A9 do
local _0xD098 = Instance.new("Frame")
_0xD098.BackgroundColor3 = _0x5086
_0xD098.BorderSizePixel = 0
_0xD098.Active = false
_0xD098.Rotation = -_0x6214
_0xD098.Parent = _0xDDB4
_0x1F18[i] = { _0x34A5 = _0xD098 }
_0x7BC2(_0x1F18[i], true)
end
end
_0x32C1(_0x2C20.RenderStepped:Connect(function(dt)
if not _0xC248.Rain then
if _0xDDB4 and _0xDDB4.Visible then _0xDDB4.Visible = false end
return
end
if not _0xDDB4 then _0xCEF3() end
_0xDDB4.Visible = true
local _0x7B8B = _0xDDB4.AbsoluteSize
local _0x2221 = math.tan(math.rad(_0x6214)) * _0x7B8B.Y / math.max(_0x7B8B.X, 1)dt = math.min(dt, 0.1)
for _0xDCCD, _0x6727 in ipairs(_0x1F18) do
_0x6727.y += _0x6727.speed * dt
_0x6727.x += _0x6727.speed * _0x2221 * dt
if _0x6727.y > 1 then _0x7BC2(_0x6727, false) end
_0x6727.frame.Position = UDim2.fromScale(_0x6727.x, _0x6727.y)
end
end))
enddo
local _0xB542 = _0x6BFC("movement_fly", true)
local _0x66D9 = _0xCD1A(_0xB542, 1,"Fly")
_0xCEB3(_0x66D9,"Enabled","Fly")
_0xBBEF(_0x66D9,"Speed", 5, 1000,"FlySpeed")
local _0x434E = _0xCD1A(_0xB542, 2,"Controls")
_0x8649(_0x434E,"W A S D  -  move")
_0x8649(_0x434E,"Space  -  up")
_0x8649(_0x434E,"Ctrl  -  down")
_0x18F9(_0x8649(_0x434E,""), function()
return _0x8406(_0xACF9("Fly").input) .."  -  fly on / off"end)
end
do
local _0x3265 = _0x6BFC("movement_vortex", true)
local _0x0866 = _0xCD1A(_0x3265, 2,"WARNING")
for _0xDCCD, _0x4883 in ipairs({"BUGGY / EXPERIMENTAL","can glitch your movement","or camera. If it breaks,","turn it off or reset your","character. Use at your","own risk.",
}) do
local _0x54FD = _0x8649(_0x0866, _0x4883)
_0x4EBC(_0x54FD,"TextColor3", function() return Color3.fromRGB(235, 90, 90) end)
end
local _0x66D9 = _0xCD1A(_0x3265, 1,"Vortex")
_0xCEB3(_0x66D9,"Vortex Mode","FlyVortex", function(_0x27BA)
if _0x27BA and _0x9996 then _0x9996("Vortex is buggy - see the warning") end
end)
_0xBBEF(_0x66D9,"Vortex Speed", 1, 100,"VortexSpeed")
_0xBBEF(_0x66D9,"Vortex Radius", 2, 60,"VortexRadius")
local _0xC09B = _0xCD1A(_0x3265, 2,"Status")
_0xB423 = _0x8649(_0xC09B,"Vortex: off")
_0x7C18 = _0x8649(_0xC09B,"Server: checking...")
_0x8649(_0xC09B,"parts orbit 5+ studs away")
_0x8649(_0xC09B,"works with or without fly")
_0x8649(_0xC09B,"orbit head: only safe if the")
_0x8649(_0xC09B,"server has RequiresNeck off")
_0x8649(_0xC09B,"executor mode: joints are")
_0x8649(_0xC09B,"destroyed so it replicates")
if _0xDCFD then
local _0xD1E7 = Instance.new("TextButton")
_0xD1E7.Name ="DisabledShade"_0xD1E7.Size = UDim2.new(1, 0, 1, 0)
_0xD1E7.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0xD1E7.BackgroundTransparency = 0.45
_0xD1E7.BorderSizePixel = 0
_0xD1E7.Text =""_0xD1E7.AutoButtonColor = false
_0xD1E7.Active = true
_0xD1E7.ZIndex = 50
_0xD1E7.Parent = _0x3265.frame
_0xEF6D(_0xD1E7, 4)
local _0xFEC6 = Instance.new("TextLabel")
_0xFEC6.Name ="DisabledLabel"_0xFEC6.AnchorPoint = Vector2.new(0.5, 0.5)
_0xFEC6.Position = UDim2.new(0.5, 0, 0.5, 0)
_0xFEC6.Size = UDim2.new(1, 0, 0, 24)
_0xFEC6.BackgroundTransparency = 1
_0xFEC6.Text ="Disabled"_0xFEC6.Font = _0x4B96
_0xFEC6.TextSize = 18
_0xFEC6.TextColor3 = Color3.fromRGB(235, 80, 80)
_0xFEC6.ZIndex = 51
_0xFEC6.Parent = _0x3265.frame
pcall(function()
_0xFEC6.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)
end
end
do
local _0x5621 = _0x6BFC("movement_speed", true)
local _0x66D9 = _0xCD1A(_0x5621, 1,"Speed")
_0xCEB3(_0x66D9,"Enabled","Speed")
_0xBBEF(_0x66D9,"Walk Speed", 16, 250,"SpeedValue")
local _0x7439 = _0xCD1A(_0x5621, 2,"Info")
_0x8649(_0x7439,"changes your walk speed")
_0x8649(_0x7439,"normal speed comes back")
_0x8649(_0x7439,"when you switch it off")
end
do
local _0xBAB4 = _0x6BFC("movement_jump", true)
local _0x66D9 = _0xCD1A(_0xBAB4, 1,"Infinite Jump")
_0xCEB3(_0x66D9,"Enabled","InfiniteJump")
local _0x7439 = _0xCD1A(_0xBAB4, 2,"Info")
_0x8649(_0x7439,"jump again in mid-air")
_0x8649(_0x7439,"just press jump")
end
do
local _0x7E46 = _0x6BFC("movement_mousetp", true)
local _0x66D9 = _0xCD1A(_0x7E46, 1,"Mouse TP")
_0xCEB3(_0x66D9,"Enabled","MouseTP")
local _0x7439 = _0xCD1A(_0x7E46, 2,"Info")
_0x18F9(_0x8649(_0x7439,""), function()
return _0x8406(_0xACF9("MouseTPKey").input) .."  -  teleport"end)
_0x8649(_0x7439,"teleports you to where")
_0x8649(_0x7439,"your mouse / crosshair")
_0x8649(_0x7439,"is pointing")
_0x8649(_0x7439,"change the key in Keybinds")
end
do
local _0xDD88 = _0x6BFC("movement_noclip", true)
local _0x66D9 = _0xCD1A(_0xDD88, 1,"Noclip")
_0xCEB3(_0x66D9,"Enabled","Noclip")
local _0x7439 = _0xCD1A(_0xDD88, 2,"Info")
_0x8649(_0x7439,"walk through walls")
_0x18F9(_0x8649(_0x7439,""), function()
return _0x8406(_0xACF9("Noclip").input) .."  -  noclip on / off"end)
_0x8649(_0x7439,"combine with fly to")
_0x8649(_0x7439,"move through anything")
enddo
local _0x9F3D = 130
local _0xB70E = 0local _0xC599 = false
local _0x7F67, _0x5086 = Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 215, 255)
local _0xDDB4 = Instance.new("Frame")
_0xDDB4.Name ="OULMenuSnow"_0xDDB4.BackgroundTransparency = 1
_0xDDB4.BorderSizePixel = 0
_0xDDB4.Size = UDim2.fromOffset(0, 0)
_0xDDB4.Visible = false
_0xDDB4.ZIndex = 200
_0xDDB4.Parent = _0xD27F
local _0x2C48 = {}
local function _0x7BC2(_0xBF16, anywhere)
local _0x6728, _0x2DBB = math.min(0, -_0xB70E), math.max(1, 1 - _0xB70E)
_0xBF16.x = _0x6728 + math.random() * (_0x2DBB - _0x6728)
_0xBF16.y = anywhere and math.random() or -0.05
if _0xC599 then_0xBF16.speed = 0.7 + math.random() * 0.5_0xBF16.sway = 0
_0xBF16.size = math.random(1, 2)
_0xBF16.len = 10 + math.random() * 12
_0xBF16.alpha = 0.25 + math.random() * 0.3
_0xBF16.frame.Size = UDim2.fromOffset(_0xBF16.size, _0xBF16.len)
else
_0xBF16.speed = 0.06 + math.random() * 0.10_0xBF16.sway = 6 + math.random() * 16
_0xBF16.size = math.random(2, 5)
_0xBF16.alpha = 0.15 + math.random() * 0.4
_0xBF16.frame.Size = UDim2.fromOffset(_0xBF16.size, _0xBF16.size)
end
_0xBF16.freq = 0.6 + math.random() * 1.4
_0xBF16.phase = math.random() * math.pi * 2
end
for i = 1, _0x9F3D do
local _0xD098 = Instance.new("Frame")
_0xD098.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0xD098.BorderSizePixel = 0
_0xD098.AnchorPoint = Vector2.new(0.5, 0.5)
_0xD098.ZIndex = 200
_0xD098.Parent = _0xDDB4
Instance.new("UICorner", _0xD098).CornerRadius = UDim.new(1, 0)
local _0xBF16 = { _0x34A5 = _0xD098 }
_0x7BC2(_0xBF16, true)
_0x2C48[i] = _0xBF16
end
local _0x2BD1 = false
_0x32C1(_0x2C20.RenderStepped:Connect(function(dt)
local _0x27BA = _0xC248.MenuSnow and _0x8C4E and _0xAE9A.Visible
if not _0x27BA then
if _0x2BD1 then
_0x2BD1 = false
_0xDDB4.Visible = false
end
return
end
if not _0x2BD1 then
_0x2BD1 = true
_0xDDB4.Visible = true
end
local _0xE53C, _0x759E = _0xAE9A.AbsolutePosition, _0xAE9A.AbsoluteSize
local _0x064E, _0x8E88, _0xC8BC, _0x2A54 = _0xE53C.X, _0xE53C.Y, _0xE53C.X + _0x759E.X, _0xE53C.Y + _0x759E.Y
local _0xC401 = _0xD27F.AbsoluteSize
local _0x0866, _0xCF21 = _0xC401.X, _0xC401.Y
local _0xCAC0 = os.clock()
dt = math.min(dt, 0.1)
local _0x88E8 = math.tan(math.rad(math.clamp(_0xC248.SnowAngle or 0, -60, 60)))
_0xB70E = _0x88E8 * _0xCF21 / math.max(_0x0866, 1)
local _0xFA34 = math.clamp(_0xC248.SnowSpeed or 100, 10, 300) / 100
local _0xA237 = _0xC248.ParticleType =="Rain"if _0xA237 ~= _0xC599 then
_0xC599 = _0xA237
for _0xDCCD, _0xBF16 in ipairs(_0x2C48) do
_0x7BC2(_0xBF16, true)
_0xBF16.frame.BackgroundColor3 = _0xC599 and _0x5086 or _0x7F67
end
endlocal _0x4D48 = _0xC599 and -math.clamp(_0xC248.SnowAngle or 0, -60, 60) or 0
for _0xDCCD, _0xBF16 in ipairs(_0x2C48) do
_0xBF16.frame.Rotation = _0x4D48
_0xBF16.y += _0xBF16.speed * _0xFA34 * dt
_0xBF16.x += _0xBF16.speed * _0xFA34 * _0xB70E * dt
if _0xBF16.y > 1.05 then _0x7BC2(_0xBF16, false) end
local _0x4CCB = _0xBF16.x * _0x0866 + math.sin(_0xCAC0 * _0xBF16.freq + _0xBF16.phase) * _0xBF16.sway
local _0xCF3D = _0xBF16.y * _0xCF21
_0xBF16.frame.Position = UDim2.fromOffset(_0x4CCB, _0xCF3D)
if _0x4CCB > _0x064E - 2 and _0x4CCB < _0xC8BC + 2 and _0xCF3D > _0x8E88 - 2 and _0xCF3D < _0x2A54 + 2 then_0xBF16.frame.BackgroundTransparency = 1
elselocal _0x432A = math.min(_0xBF16.y / 0.1, (1.05 - _0xBF16.y) / 0.15, 1)
_0xBF16.frame.BackgroundTransparency = 1 - (1 - _0xBF16.alpha) * math.clamp(_0x432A, 0, 1)
end
end
end))
enddo
local _0xF866 = _0x6BFC("settings_general", true)
local _0x1015 = _0x6BFC("themes_style", true)
local _0x40CF = _0x6BFC("themes_background", true)
local _0x22FD = _0xCD1A(_0x1015, 1,"UI Style")
_0x8649(_0x22FD,"Basic: square, bold red bars")
_0x8649(_0x22FD,"Modern: cards, switches, pill tabs")
_0x8649(_0x22FD,"your accent colours stay the same")
do
local _0x8BD7 = Instance.new("Frame")
_0x8BD7.Size = UDim2.new(1, 0, 0, 24)
_0x8BD7.BackgroundTransparency = 1
_0x8BD7.LayoutOrder = _0x2A2C(_0x22FD)
_0x8BD7.Parent = _0x22FD
local _0xC3FC = Instance.new("UIListLayout")
_0xC3FC.FillDirection = Enum.FillDirection.Horizontal
_0xC3FC.Padding = UDim.new(0, 4)
_0xC3FC.SortOrder = Enum.SortOrder.LayoutOrder
_0xC3FC.Parent = _0x8BD7
local _0x06B5 = {"Classic","Basic","Modern"}
local _0x5066 = { Classic ="Classic OUL", Basic ="Basic", Modern ="Modern"}
local _0x498C = {}
local function _0x41DF(animate)
for id, _0x35A4 in pairs(_0x498C) do
_0x91F0(_0x35A4, {
BackgroundTransparency = (_0xC248.UIStyle == id) and 0 or 1,
TextColor3 = (_0xC248.UIStyle == id) and Color3.fromRGB(255, 255, 255) or _0x1FFF.Dim,
}, animate)
end
end
for i, id in ipairs(_0x06B5) do
local _0x35A4 = Instance.new("TextButton")
_0x35A4.Size = UDim2.new(1 / 3, -3, 1, 0)
_0x35A4.LayoutOrder = i
_0x35A4.BorderSizePixel = 0
_0x35A4.AutoButtonColor = false
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 11
_0x35A4.Text = _0x5066[id]
_0x35A4.Parent = _0x8BD7
_0x4EBC(_0x35A4,"BackgroundColor3", function() return _0x1FFF.Accent end)
_0xEF6D(_0x35A4, 3)
_0x85AD(_0x35A4, 0.4)
_0x498C[id] = _0x35A4
_0x35A4.MouseButton1Click:Connect(function()
_0xC248.UIStyle = id
_0xD514()
_0xA1F3()
_0x41DF(true)
end)
end
_0x63C7(function() _0x41DF(true) end)
_0x40B9.UIStyle = _0x41DF
_0x41DF(false)
end
local _0x2AB0 = _0xCD1A(_0x1015, 1,"Effects")
_0xCEB3(_0x2AB0,"Menu Particles","MenuSnow")
_0xE028(_0x2AB0,"Type","ParticleType","Snow","Rain")
_0xBBEF(_0x2AB0,"Particle Angle (deg)", -60, 60,"SnowAngle")
_0xBBEF(_0x2AB0,"Particle Speed (%)", 10, 300,"SnowSpeed")
_0x8649(_0x2AB0,"snow or rain falls over the")
_0x8649(_0x2AB0,"screen while the menu is open")
_0x8649(_0x2AB0,"angle 0 = straight down,")
_0x8649(_0x2AB0,"+ blows right, - blows left")
local _0x752D = _0xCD1A(_0xF866, 1,"Menu")
local _0x283A = 0
_0xBBEF(_0x752D,"UI Size (%)", 50, 150,"UIScale", function(_0x803E)
_0x283A += 1
local _0x6F30 = _0x283Atask.delay(0.3, function()
if _0x6F30 ~= _0x283A or not _0xE870 then return end
local _0x56F2 = _0xD1D6.uiScale
if not _0x56F2 or not _0x56F2.Parent then return end
_0x6884(_0x56F2, { Scale = _0x803E / 100 }, _0xFCF5)local _0x6F78 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
if _0x6F78 then
local _0x0866, _0xCF21 = (_0xD1D6.panelW or _0x6401) * _0x803E / 100, _0xAE9A.Size.Y.Offset * _0x803E / 100
_0xAE9A.Position = UDim2.fromOffset(
math.clamp(_0xAE9A.Position.X.Offset, 0, math.max(0, _0x6F78.X - _0x0866)),
math.clamp(_0xAE9A.Position.Y.Offset, 0, math.max(0, _0x6F78.Y - _0xCF21))
)
end
end)
end)
_0xBBEF(_0x752D,"UI Transparency", 0, 70,"UITransparency", function(_0x803E)
if _0x8C4E then
_0xAE9A.GroupTransparency = _0x803E / 100
end
end)
_0xCEB3(_0x752D,"Watermark","Watermark", function(_0x27BA)
_0x5904.Visible = _0x27BA
end)
_0xCEB3(_0x752D,"Keybind List","KeybindList", function(_0x27BA)
_0xC8CB.Visible = _0x27BA
end)
_0xCEB3(_0x752D,"Notifications","Notifications")
_0xCEB3(_0x752D,"Background Blur","BlurEnabled", function()
_0x80F0()
end)
_0xBBEF(_0x752D,"Blur Amount", 1, 56,"BlurAmount", function()
_0x80F0()
end)
local _0xCB8F = _0xCD1A(_0xF866, 2,"Script")
_0x3E65(_0xCB8F,"Unload", Color3.fromRGB(170, 55, 65), Color3.fromRGB(205, 75, 85), function()
local _0x94C5 = shared.OULCleanup
shared.OULCleanup = nil
if _0x94C5 then _0x94C5() end
end)
_0x3E65(_0xCB8F,"Save now", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
_0x2ADF()
end)
_0x1807 = _0x8649(_0xCB8F, _0xCB23)
local _0x5BF3 = _0x1FFF.Switch
local _0xEB9F = _0x1FFF.Accent
local _0xEE3D = _0x1FFF.Text
local _0xF188 = _0x1FFF.Outline
local _0x75F5 = _0xCD1A(_0x1015, 2,"Menu Colours")
_0xB1B5(_0x75F5,"Checkbox", _0xF8FA(_0x5BF3), function(_0x5A2F)
_0x1FFF.Switch = _0x5A2F
_0xD514()
end, _0x5BF3)
_0xB1B5(_0x75F5,"Accent", _0xF8FA(_0xEB9F), function(_0x5A2F)
_0x1FFF.Accent = _0x5A2F
_0xD514()
end, _0xEB9F)
_0xB1B5(_0x75F5,"Text", _0xF8FA(_0xEE3D), function(_0x5A2F)
_0x1FFF.Text = _0x5A2F
_0xD514()
end, _0xEE3D)
_0xB1B5(_0x75F5,"Background", _0x2657, function(_0x5A2F)
_0x1FFF.Background = _0x5A2F
_0xD514()
end, _0x1FFF.Background, 0.55, 0.28)
_0xB1B5(_0x75F5,"Outline", _0xF8FA(_0xF188), function(_0x5A2F)
_0x1FFF.Outline = _0x5A2F
_0xD514()
end, _0xF188, 0.45, 0.6)
local _0xECF3 = _0xCD1A(_0x40CF, 1,"Background")
_0xCEB3(_0xECF3,"Gradient","BGGradient", function() _0xD1D6.updateBG(true) end)
_0xCEB3(_0xECF3,"Both corners","BGGradMirror", function() _0xD1D6.updateBG(false) end)local _0x56C6 = {
Color3.fromRGB(0, 0, 0),
Color3.fromRGB(128, 128, 128),
Color3.fromRGB(255, 255, 255),
_0x0556.BGGrad,
}
for i = 2, 13 do
_0x56C6[#_0x56C6 + 1] = _0xA955[i]
end
_0xB1B5(_0xECF3,"Gradient Colour", _0x56C6, function(_0x5A2F)
_0x0556.BGGrad = _0x5A2F
local _0xCF21, _0x35C0 = _0x5A2F:ToHSV()
if _0x35C0 > 0.1 then
_0xC248.BGGradHue = math.floor(_0xCF21 * 360 + 0.5) % 361
if _0x40B9.BGGradHue then _0x40B9.BGGradHue() end
end
_0xD1D6.updateBG(false)
end, _0x0556.BGGrad)do
local _0x1F0B = true
_0xBBEF(_0xECF3,"Hue", 0, 360,"BGGradHue", function(_0x803E)
if _0x1F0B then return end
_0x0556.BGGrad = Color3.fromHSV(math.min(_0x803E, 359.9) / 360, 0.9, 1)
for _0xDCCD, _0x94C5 in ipairs(_0xD1D6.colorRefreshers) do pcall(_0x94C5) end
_0xD1D6.updateBG(false)
end)
local _0x2B33 = _0x40B9.BGGradHue
_0x40B9.BGGradHue = function(...)
_0x1F0B = true
_0x2B33(...)
_0x1F0B = false
end
_0x1F0B = false
end
_0xBBEF(_0xECF3,"Brightness (%)", 10, 100,"BGGradBright", function()
_0xD1D6.updateBG(false)
end)
_0x8649(_0xECF3,"Direction (where it comes from)")
do
local _0xF666 = Instance.new("Frame")
_0xF666.Size = UDim2.new(1, 0, 0, 74)
_0xF666.BackgroundTransparency = 1
_0xF666.LayoutOrder = _0x2A2C(_0xECF3)
_0xF666.Parent = _0xECF3
local _0xF79D = Instance.new("UIGridLayout")
_0xF79D.CellSize = UDim2.new(1 / 3, -4, 0, 22)
_0xF79D.CellPadding = UDim2.fromOffset(6, 4)
_0xF79D.SortOrder = Enum.SortOrder.LayoutOrder
_0xF79D.Parent = _0xF666
local _0x0B00 = {
{ id ="TopLeft", _0x7465 ="TL"}, { id ="Top", _0x7465 ="Top"}, { id ="TopRight", _0x7465 ="TR"},
{ id ="Left", _0x7465 ="Left"}, { id = nil }, { id ="Right", _0x7465 ="Right"},
{ id ="BottomLeft", _0x7465 ="BL"}, { id ="Bottom", _0x7465 ="Bot"}, { id ="BottomRight", _0x7465 ="BR"},
}
local _0x498C = {}
local function _0x41DF(animate)
for id, _0x35A4 in pairs(_0x498C) do
_0x91F0(_0x35A4, {
BackgroundTransparency = (_0xC248.BGGradDir == id) and 0 or 1,
TextColor3 = (_0xC248.BGGradDir == id) and Color3.fromRGB(255, 255, 255) or _0x1FFF.Dim,
}, animate)
end
end
for i, cell in ipairs(_0x0B00) do
if cell.id then
local _0x35A4 = Instance.new("TextButton")
_0x35A4.LayoutOrder = i
_0x35A4.BorderSizePixel = 0
_0x35A4.AutoButtonColor = false
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 12
_0x35A4.Text = cell.label
_0x35A4.Parent = _0xF666
_0x4EBC(_0x35A4,"BackgroundColor3", function() return _0x1FFF.Accent end)
_0xEF6D(_0x35A4, 3)
_0x85AD(_0x35A4, 0.4)
_0x498C[cell.id] = _0x35A4
_0x35A4.MouseButton1Click:Connect(function()
_0xC248.BGGradDir = cell.id
_0xD1D6.updateBG(false)
_0x41DF(true)
end)
else
local _0x8587 = Instance.new("Frame")
_0x8587.LayoutOrder = i
_0x8587.BackgroundTransparency = 1
_0x8587.Parent = _0xF666
end
end
_0x63C7(function() _0x41DF(true) end)
_0x40B9.BGGradDir = _0x41DF
_0x41DF(false)
end
_0x8649(_0xECF3,"Both corners: bright at the")
_0x8649(_0xECF3,"chosen corner and the opposite")
end
do
local _0xF8F3 = _0x6BFC("settings_keybinds", true)
local function _0x0664(parent, id)
local _0x051B = _0xACF9(id)
_0x894E(parent, _0x051B.label)
local _0x8BD7 = Instance.new("Frame")
_0x8BD7.Size = UDim2.new(1, 0, 0, 22)
_0x8BD7.BackgroundTransparency = 1
_0x8BD7.LayoutOrder = _0x2A2C(parent)
_0x8BD7.Parent = parent
local _0xE272 = (_0x051B.kind ~="menu"and _0x051B.kind ~="panic")
local _0x0940 = _0xE272 and 24 or 0
local _0x7465 = _0x0D0A(_0x8BD7, _0x051B.label, 12)
_0x7465.Size = UDim2.new(1, -(92 + _0x0940), 1, 0)
local _0x35A4 = Instance.new("TextButton")
_0x35A4.Size = UDim2.fromOffset(88, 20)
_0x35A4.AnchorPoint = Vector2.new(1, 0.5)
_0x35A4.Position = UDim2.new(1, -_0x0940, 0.5, 0)
_0x35A4.BorderSizePixel = 0
_0x35A4.AutoButtonColor = false
_0x35A4.Font = _0x4B96
_0x35A4.TextSize = 11
_0x35A4.Text = _0x8406(_0x051B.input)
_0x35A4.Parent = _0x8BD7
_0x4EBC(_0x35A4,"BackgroundColor3", function()
return _0x1FFF.Field
end)
_0x4EBC(_0x35A4,"TextColor3", function()
return _0x1FFF.Text
end)
_0xEF6D(_0x35A4, 3)
_0x85AD(_0x35A4, 0.4)
_0xE20A[id] = _0x35A4
_0x35A4.MouseButton1Click:Connect(function()if os.clock() - (_0xD1D6.bindJustSet or 0) < 0.35 then return end
_0xCB3D = (_0xCB3D == _0x051B) and nil or _0x051B
_0xB6C3()
end)if _0xE272 then
local _0x4CCB = Instance.new("TextButton")
_0x4CCB.Size = UDim2.fromOffset(20, 20)
_0x4CCB.AnchorPoint = Vector2.new(1, 0.5)
_0x4CCB.Position = UDim2.new(1, 0, 0.5, 0)
_0x4CCB.BackgroundTransparency = 1
_0x4CCB.BorderSizePixel = 0
_0x4CCB.AutoButtonColor = false
_0x4CCB.Font = _0x4B96
_0x4CCB.TextSize = 12
_0x4CCB.Text ="X"_0x4CCB.Parent = _0x8BD7
_0x8C5B(_0x4CCB, true)
_0x4CCB.MouseEnter:Connect(function()
_0x6884(_0x4CCB, { TextColor3 = Color3.fromRGB(235, 90, 90) })
end)
_0x4CCB.MouseLeave:Connect(function()
_0x6884(_0x4CCB, { TextColor3 = _0x1FFF.Dim })
end)
_0x4CCB.MouseButton1Click:Connect(function()
if not _0x051B.input then
_0x9996(_0x051B.label .."  -  already empty")
return
end
_0x051B.input = nil
if _0xCB3D == _0x051B then _0xCB3D = nil end
_0xC248.Holding = false
_0xB6C3()
_0xBB85()
_0x9996(_0x051B.label .."  keybind deleted")
end)
end
end
local _0x75F5 = _0xCD1A(_0xF8F3, 1,"Combat")
for _0xDCCD, id in ipairs({"aim","Enabled","ShowFOV","IgnoreFOV","TeamCheck","Triggerbot","Ragebot","VoidSpam"}) do
_0x0664(_0x75F5, id)
end
local _0xE1F6 = _0xCD1A(_0xF8F3, 1,"Movement")
for _0xDCCD, id in ipairs({"Fly","Noclip","Speed","InfiniteJump","MouseTPKey"}) do
_0x0664(_0xE1F6, id)
end
local _0x803E = _0xCD1A(_0xF8F3, 2,"Visuals")
for _0xDCCD, id in ipairs({"ESP","Chams","ShowNames","Tracers","Boxes","BoxFill","Skeleton","Skybox"}) do
_0x0664(_0x803E, id)
end
local _0x752D = _0xCD1A(_0xF8F3, 2,"Menu")
for _0xDCCD, id in ipairs({"menu","panic","Watermark","KeybindList","BlurEnabled","Notifications"}) do
_0x0664(_0x752D, id)
end
_0x8649(_0x752D,"click a bind, then press a key")
_0x8649(_0x752D,"or a mouse button (M1/M2/M3)")
_0x8649(_0x752D,"Esc  -  cancel    Backspace  -  clear")
_0x8649(_0x752D,"X  -  delete that keybind")
_0x8649(_0x752D,"Panic  -  unloads everything")
do
local _0xBE0B
local _0xC356 = false
_0xBE0B = _0x3E65(_0x752D,"Delete all keybinds", Color3.fromRGB(170, 55, 65), Color3.fromRGB(205, 75, 85), function()
if not _0xC356 then
_0xC356 = true
_0xBE0B.Text ="Click again to confirm"task.delay(2.5, function()
if _0xC356 then
_0xC356 = false
_0xBE0B.Text ="Delete all keybinds"end
end)
return
end
_0xC356 = false
_0xBE0B.Text ="Delete all keybinds"local _0x54FD = 0
for _0xDCCD, _0x051B in ipairs(_0x9490) do
if _0x051B.kind ~="menu"and _0x051B.kind ~="panic"and _0x051B.input then
_0x051B.input = nil
_0x54FD += 1
end
end
_0xC248.Holding = false
_0xCB3D = nil
_0xB6C3()
_0xBB85()
_0x9996("Deleted ".. _0x54FD .." keybinds (menu + panic kept)")
end)
end
_0x3E65(_0x752D,"Reset all keybinds", Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170), function()
for _0xDCCD, _0x051B in ipairs(_0x9490) do
_0x051B.input = _0x051B.default
end
_0xCB3D = nil
_0xB6C3()
_0xBB85()
_0x9996("Keybinds reset")
end)
end
do
local _0xDBD2 = _0x6BFC("settings_configs", true)
local _0x66D9 = _0xCD1A(_0xDBD2, 1,"Configs")local function _0x91C6()
for _0xDCCD, _0x94C5 in pairs(_0x40B9) do pcall(_0x94C5, true) end
_0x72F0(_0x0556.Fill)
_0x8436(_0x0556.Outline)
_0x5A59(_0x0556.Name)
_0xD92F.Color = _0xA41E
pcall(_0xD1D6.updateBG, false)
_0xD514()
for _0xDCCD, _0x94C5 in ipairs(_0xD1D6.colorRefreshers) do pcall(_0x94C5) end
_0x5904.Visible = _0xC248.Watermark
_0xC8CB.Visible = _0xC248.KeybindList
if _0xBBF0.hud then _0x5904.Position = _0xBBF0.hud end
if _0xBBF0.keylist then _0xC8CB.Position = _0xBBF0.keylist end
_0xB6C3()
_0xBB85()
_0xFE38()
end
if not _0xD1D6.available then
_0x8649(_0x66D9,"needs executor file support")
_0x8649(_0x66D9,"(listfiles, delfile,")
_0x8649(_0x66D9,"isfolder, makefolder)")
else
local _0xCD7C, _0x4C15 = Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170)
local _0x11C0, _0x89D7 = Color3.fromRGB(170, 55, 65), Color3.fromRGB(205, 75, 85)
local _0xEC0F = Instance.new("ScrollingFrame")
_0xEC0F.Size = UDim2.new(1, 0, 0, 120)
_0xEC0F.BorderSizePixel = 0
_0xEC0F.ScrollBarThickness = 3
_0xEC0F.CanvasSize = UDim2.new()
_0xEC0F.AutomaticCanvasSize = Enum.AutomaticSize.Y
_0xEC0F.LayoutOrder = _0x2A2C(_0x66D9)
_0xEC0F.Parent = _0x66D9
_0x4EBC(_0xEC0F,"BackgroundColor3", function() return _0x1FFF.Field end)
_0xEF6D(_0xEC0F, 3)
_0x85AD(_0xEC0F, 0.4)
local _0x6253 = Instance.new("UIListLayout")
_0x6253.Padding = UDim.new(0, 2)
_0x6253.SortOrder = Enum.SortOrder.LayoutOrder
_0x6253.Parent = _0xEC0F
local _0x24B8 = Instance.new("UIPadding")
_0x24B8.PaddingTop = UDim.new(0, 3)
_0x24B8.PaddingLeft = UDim.new(0, 3)
_0x24B8.PaddingRight = UDim.new(0, 3)
_0x24B8.Parent = _0xEC0F
local _0x3E20 = _0x8649(_0x66D9,"autoload: none")
local _0xD76C, _0xD119, _0x82AE, _0x16A4 = nil, nil, nil, false
local function _0x62ED()
for _0xDCCD, _0x75F5 in ipairs(_0xEC0F:GetChildren()) do
if _0x75F5:IsA("TextButton") then _0x75F5:Destroy() end
end
local _0x06B5 = _0xD1D6.list()
local _0x2215 = _0xD1D6.getAutoload()
local _0x8142 = false
for _0xDCCD, _0x54FD in ipairs(_0x06B5) do
if _0x54FD == _0xD76C then _0x8142 = true end
end
if not _0x8142 then _0xD76C = nil end
for i, _0xBF13 in ipairs(_0x06B5) do
local _0x27BA = (_0xBF13 == _0xD76C)
local _0x051B = Instance.new("TextButton")
_0x051B.Size = UDim2.new(1, -6, 0, 20)
_0x051B.BorderSizePixel = 0
_0x051B.AutoButtonColor = false
_0x051B.Font = _0x4B96
_0x051B.TextSize = 12
_0x051B.TextXAlignment = Enum.TextXAlignment.Left
_0x051B.LayoutOrder = i
_0x051B.Text ="  ".. _0xBF13 .. (_0xBF13 == _0x2215 and"  [auto]"or"")
_0x051B.BackgroundTransparency = _0x27BA and 0 or 1
_0x051B.BackgroundColor3 = _0x1FFF.Accent
_0x051B.TextColor3 = _0x27BA and Color3.fromRGB(255, 255, 255) or _0x1FFF.Text
_0x051B.Parent = _0xEC0F
_0xEF6D(_0x051B, 3)
_0x051B.MouseButton1Click:Connect(function()
_0xD76C = _0xBF13
_0x16A4 = false
if _0x82AE then _0x82AE.Text ="Delete"end
_0x62ED()
end)
end
_0x3E20.Text ="autoload: ".. (_0x2215 or"none")
if _0xD119 then
_0xD119.Text = (_0x2215 and _0x2215 == _0xD76C) and"Remove autoload"or"Set as autoload"end
end
_0x63C7(_0x62ED)
local _0x752D = _0xCD1A(_0xDBD2, 2,"Manage")
local _0x8183 = Instance.new("TextBox")
_0x8183.Size = UDim2.new(1, 0, 0, 22)
_0x8183.BorderSizePixel = 0
_0x8183.ClearTextOnFocus = false
_0x8183.PlaceholderText ="new config name..."_0x8183.Text =""_0x8183.Font = _0x4B96
_0x8183.TextSize = 12
_0x8183.TextXAlignment = Enum.TextXAlignment.Left
_0x8183.LayoutOrder = _0x2A2C(_0x752D)
_0x8183.Parent = _0x752D
_0x4EBC(_0x8183,"BackgroundColor3", function() return _0x1FFF.Field end)
_0x4EBC(_0x8183,"TextColor3", function() return _0x1FFF.Text end)
_0x4EBC(_0x8183,"PlaceholderColor3", function() return _0x1FFF.Dim end)
_0xEF6D(_0x8183, 3)
_0x85AD(_0x8183, 0.4)
local _0x1104 = Instance.new("UIPadding")
_0x1104.PaddingLeft = UDim.new(0, 6)
_0x1104.Parent = _0x8183
_0x3E65(_0x752D,"Create new", _0xCD7C, _0x4C15, function()
local _0xBF13 = _0xD1D6.clean(_0x8183.Text)
if _0xBF13 ==""then _0x9996("Type a config name first") return end
for _0xDCCD, _0x54FD in ipairs(_0xD1D6.list()) do
if string.lower(_0x54FD) == string.lower(_0xBF13) then
_0x9996("That name already exists")
return
end
end
local _0x499B, _0xABB0 = _0xD1D6.save(_0xBF13)
if _0x499B then
_0xD76C = _0xBF13
_0x8183.Text =""_0x9996("Created: ".. _0xBF13)
else
warn("[OUL config] ".. tostring(_0xABB0))
_0x9996("Create failed - see Output")
end
_0x62ED()
end)
_0x3E65(_0x752D,"Save (overwrite)", _0xCD7C, _0x4C15, function()
if not _0xD76C then _0x9996("Select a config first") return end
local _0x499B, _0xABB0 = _0xD1D6.save(_0xD76C)
if not _0x499B then warn("[OUL config] ".. tostring(_0xABB0)) end
_0x9996(_0x499B and ("Saved: ".. _0xD76C) or"Save failed - see Output")
end)
_0x3E65(_0x752D,"Load", _0xCD7C, _0x4C15, function()
if not _0xD76C then _0x9996("Select a config first") return end
local _0x499B, _0xABB0 = _0xD1D6.load(_0xD76C)
if _0x499B then
_0x91C6()
_0x9996("Loaded: ".. _0xD76C)
else
warn("[OUL config] ".. tostring(_0xABB0))
_0x9996("Load failed - see Output")
end
end)
_0xD119 = _0x3E65(_0x752D,"Set as autoload", _0xCD7C, _0x4C15, function()
if not _0xD76C then _0x9996("Select a config first") return end
if _0xD1D6.getAutoload() == _0xD76C then
_0xD1D6.setAutoload("")
_0x9996("Autoload removed")
else
_0xD1D6.setAutoload(_0xD76C)
_0x9996("Autoload: ".. _0xD76C)
end
_0x62ED()
end)
_0x82AE = _0x3E65(_0x752D,"Delete", _0x11C0, _0x89D7, function()
if not _0xD76C then _0x9996("Select a config first") return end
if not _0x16A4 then
_0x16A4 = true
_0x82AE.Text ="Click again to confirm"task.delay(2.5, function()
if _0x16A4 then
_0x16A4 = false
_0x82AE.Text ="Delete"end
end)
return
end
_0x16A4 = false
_0x82AE.Text ="Delete"local _0x499B, _0xABB0 = _0xD1D6.delete(_0xD76C)
if not _0x499B then warn("[OUL config] ".. tostring(_0xABB0)) end
_0x9996(_0x499B and ("Deleted: ".. _0xD76C) or"Delete failed - see Output")
_0xD76C = nil
_0x62ED()
end)
_0x8649(_0x752D,"autoload applies on launch")
_0x62ED()
enddo
local _0xCD7C, _0x4C15 = Color3.fromRGB(70, 90, 140), Color3.fromRGB(90, 112, 170)
local _0x7AA0 = _0xCD1A(_0xDBD2, 1,"Share Config")
_0x8649(_0x7AA0,"Export makes a code to send")
_0x8649(_0x7AA0,"to friends. To use one, paste")
_0x8649(_0x7AA0,"it below and press Import.")
local _0x3AEF = Instance.new("TextBox")
_0x3AEF.Size = UDim2.new(1, 0, 0, 22)
_0x3AEF.BorderSizePixel = 0
_0x3AEF.ClearTextOnFocus = false
_0x3AEF.ClipsDescendants = true
_0x3AEF.PlaceholderText ="share code..."_0x3AEF.Text =""_0x3AEF.Font = _0x4B96
_0x3AEF.TextSize = 11
_0x3AEF.TextXAlignment = Enum.TextXAlignment.Left
_0x3AEF.LayoutOrder = _0x2A2C(_0x7AA0)
_0x3AEF.Parent = _0x7AA0
_0x4EBC(_0x3AEF,"BackgroundColor3", function() return _0x1FFF.Field end)
_0x4EBC(_0x3AEF,"TextColor3", function() return _0x1FFF.Text end)
_0x4EBC(_0x3AEF,"PlaceholderColor3", function() return _0x1FFF.Dim end)
_0xEF6D(_0x3AEF, 3)
_0x85AD(_0x3AEF, 0.4)
do
local _0x1104 = Instance.new("UIPadding")
_0x1104.PaddingLeft = UDim.new(0, 6)
_0x1104.PaddingRight = UDim.new(0, 6)
_0x1104.Parent = _0x3AEF
end
local function _0xEFDB(_0x0472)
local _0x94C5 = (type(setclipboard) =="function"and setclipboard)
or (type(toclipboard) =="function"and toclipboard)
if _0x94C5 then return (pcall(_0x94C5, _0x0472)) end
return false
end
_0x3E65(_0x7AA0,"Export (copy code)", _0xCD7C, _0x4C15, function()
local _0xDB42, _0xABB0 = _0xD1D6.exportCode()
if not _0xDB42 then
warn("[OUL share] ".. tostring(_0xABB0))
_0x9996("Export failed - see Output")
return
end
_0x3AEF.Text = _0xDB42
if _0xEFDB(_0xDB42) then
_0x9996("Code copied to clipboard")
else
_0x9996("Code ready - copy it from the box")
end
end)
_0x3E65(_0x7AA0,"Import code", _0xCD7C, _0x4C15, function()
local _0x499B, _0xABB0 = _0xD1D6.importCode(_0x3AEF.Text)
if _0x499B then
_0x91C6()
_0x9996("Config imported")
else
warn("[OUL share] ".. tostring(_0xABB0))
_0x9996("Import failed - ".. tostring(_0xABB0))
end
end)
_0x8649(_0x7AA0,"does not include HUD/radar")
_0x8649(_0x7AA0,"positions or ragebot target")
end
end
do
_0x3159.step(0.75,"Finishing menu")
local _0x187D = 4
local _0xC3F6 = 32
local _0x8183 = Instance.new("TextBox")
_0x8183.Name ="Search"_0x8183.Size = UDim2.fromOffset(170, 22)
_0x8183.AnchorPoint = Vector2.new(1, 0.5)
_0x8183.Position = UDim2.new(1, -10, 0.5, 0)
_0x8183.BorderSizePixel = 0
_0x8183.ClearTextOnFocus = false
_0x8183.PlaceholderText ="search settings..."_0x8183.Text =""_0x8183.Font = _0x4B96
_0x8183.TextSize = 12
_0x8183.TextXAlignment = Enum.TextXAlignment.Left
_0x8183.ZIndex = 110
_0x8183.Parent = _0xDE16
_0x4EBC(_0x8183,"BackgroundColor3", function() return _0x1FFF.Field end)
_0x4EBC(_0x8183,"TextColor3", function() return _0x1FFF.Text end)
_0x4EBC(_0x8183,"PlaceholderColor3", function() return _0x1FFF.Dim end)
_0xEF6D(_0x8183, 3)
_0x85AD(_0x8183, 0.4)
do
local _0xD50E = Instance.new("UIPadding")
_0xD50E.PaddingLeft = UDim.new(0, 6)
_0xD50E.Parent = _0x8183
end
local _0x31A9 = Instance.new("ScrollingFrame")
_0x31A9.Name ="SearchResults"_0x31A9.Size = UDim2.fromOffset(250, 0)
_0x31A9.AnchorPoint = Vector2.new(1, 0)
_0x31A9.Position = UDim2.new(1, -10, 0, _0x8DE0 - 2)
_0x31A9.BorderSizePixel = 0
_0x31A9.ScrollBarThickness = 3
_0x31A9.CanvasSize = UDim2.new()
_0x31A9.AutomaticCanvasSize = Enum.AutomaticSize.Y
_0x31A9.Visible = false
_0x31A9.ZIndex = 150
_0x31A9.Parent = _0xAE9A
_0x4EBC(_0x31A9,"BackgroundColor3", function() return _0x1FFF.Group end)
_0xEF6D(_0x31A9, 4)
_0x85AD(_0x31A9, 0)
do
local _0xC725 = Instance.new("UIListLayout")
_0xC725.Padding = UDim.new(0, 2)
_0xC725.SortOrder = Enum.SortOrder.LayoutOrder
_0xC725.Parent = _0x31A9
local _0xD50E = Instance.new("UIPadding")
_0xD50E.PaddingTop = UDim.new(0, 3)
_0xD50E.PaddingBottom = UDim.new(0, 3)
_0xD50E.PaddingLeft = UDim.new(0, 3)
_0xD50E.PaddingRight = UDim.new(0, 3)
_0xD50E.Parent = _0x31A9
end
local _0xBA18
local function _0xAEF7(_0x05C7)
_0x8183.Text =""_0x31A9.Visible = false
_0x8183:ReleaseFocus()
if _0x8B85 ~= _0x05C7.tab or _0x928D[_0x05C7.tab] ~= _0x05C7.sub then
_0xB065(_0x05C7.tab, _0x05C7.sub, false)
end
end
local function _0x7F10(parent, _0x0472, _0x7B8B, _0xCF3D, _0xCF21, _0x5A2F)
local _0x7238 = Instance.new("TextLabel")
_0x7238.BackgroundTransparency = 1
_0x7238.Position = UDim2.fromOffset(6, _0xCF3D)
_0x7238.Size = UDim2.new(1, -12, 0, _0xCF21)
_0x7238.Font = _0x4B96
_0x7238.TextSize = _0x7B8B
_0x7238.Text = _0x0472
_0x7238.TextColor3 = _0x5A2F
_0x7238.TextXAlignment = Enum.TextXAlignment.Left
_0x7238.TextTruncate = Enum.TextTruncate.AtEnd
_0x7238.ZIndex = 152
_0x7238.Parent = parent
end
local function _0x62ED()
for _0xDCCD, _0x75F5 in ipairs(_0x31A9:GetChildren()) do
if _0x75F5:IsA("TextButton") then _0x75F5:Destroy() end
end
_0xBA18 = nil
local _0x7877 = string.lower(_0x8183.Text)
_0x7877 = (string.gsub(_0x7877,"^%s+",""))
_0x7877 = (string.gsub(_0x7877,"%s+$",""))
if _0x7877 ==""then
_0x31A9.Visible = false
return
end
local _0x2A3D = {}
for _0xDCCD, _0x99C5 in ipairs(_0xF3C9) do
local _0xAD22, _0x08C3 = string.match(_0x99C5.page,"^(%w+)_(%w+)$")
local _0xCD48 =""for _0xDCCD, _0xC09B in ipairs(_0x08F2[_0xAD22] or {}) do
if _0xC09B.id == _0x08C3 then _0xCD48 = _0xC09B.label end
end
local _0x12CB = (_0x6765[_0xAD22] or _0xAD22) .." > ".. _0xCD48
local _0xBF13 = string.lower(_0x99C5.text)
local _0x391F
if string.find(_0xBF13, _0x7877, 1, true) then
_0x391F = (string.sub(_0xBF13, 1, #_0x7877) == _0x7877) and 1 or 2
elseif string.find(string.lower(_0x12CB), _0x7877, 1, true) then
_0x391F = 3
end
if _0x391F then
_0x2A3D[#_0x2A3D + 1] = { _0x0472 = _0x99C5.text, _0xAD22 = _0xAD22, _0x08C3 = _0x08C3, _0x12CB = _0x12CB, _0x391F = _0x391F }
end
end
table.sort(_0x2A3D, function(_0x82B5, _0x051B)
if _0x82B5.rank ~= _0x051B.rank then return _0x82B5.rank < _0x051B.rank end
if _0x82B5.text ~= _0x051B.text then return _0x82B5.text < _0x051B.text end
return _0x82B5.path < _0x051B.path
end)
_0x31A9.Visible = true
if #_0x2A3D == 0 then
local _0x051B = Instance.new("TextButton")
_0x051B.Size = UDim2.new(1, 0, 0, 22)
_0x051B.BackgroundTransparency = 1
_0x051B.Text =""_0x051B.AutoButtonColor = false
_0x051B.ZIndex = 151
_0x051B.Parent = _0x31A9
_0x7F10(_0x051B,"no matching settings", 12, 0, 22, _0x1FFF.Dim)
_0x31A9.Size = UDim2.fromOffset(250, 28)
return
end
_0xBA18 = _0x2A3D[1]
for i = 1, math.min(#_0x2A3D, 40) do
local _0x05C7 = _0x2A3D[i]
local _0x051B = Instance.new("TextButton")
_0x051B.Size = UDim2.new(1, 0, 0, _0xC3F6)
_0x051B.BorderSizePixel = 0
_0x051B.BackgroundColor3 = _0x1FFF.Accent
_0x051B.BackgroundTransparency = 1
_0x051B.Text =""_0x051B.AutoButtonColor = false
_0x051B.LayoutOrder = i
_0x051B.ZIndex = 151
_0x051B.Parent = _0x31A9
_0xEF6D(_0x051B, 3)
_0x7F10(_0x051B, _0x05C7.text, 12, 3, 15, _0x1FFF.Text)
_0x7F10(_0x051B, _0x05C7.path, 10, 18, 12, _0x1FFF.Dim)
_0x051B.MouseEnter:Connect(function() _0x6884(_0x051B, { BackgroundTransparency = 0.6 }) end)
_0x051B.MouseLeave:Connect(function() _0x6884(_0x051B, { BackgroundTransparency = 1 }) end)
_0x051B.MouseButton1Click:Connect(function() _0xAEF7(_0x05C7) end)
end
_0x31A9.Size = UDim2.fromOffset(250, math.min(#_0x2A3D, _0x187D) * (_0xC3F6 + 2) + 8)
end
_0x8183:GetPropertyChangedSignal("Text"):Connect(_0x62ED)
_0x8183.Focused:Connect(_0x62ED)
_0x8183.FocusLost:Connect(function(enterPressed)
if enterPressed and _0xBA18 then
_0xAEF7(_0xBA18)
return
end
task.delay(0.2, function()
if not _0x8183:IsFocused() then
_0x31A9.Visible = false
end
end)
end)
_0x63C7(_0x62ED)
end
_0x8B85 ="combat"_0x8CF4 = _0xF400("combat", _0x928D.combat)
for _0xBF13, _0xCF40 in pairs(_0xA0EA) do
local _0x27BA = (_0xBF13 == _0x8CF4)
_0x9AC1[_0xCF40] = _0x27BA
_0xCF40.frame.Visible = true
_0xCF40.frame.GroupTransparency = _0x27BA and 0 or 1
end
_0x93C3(false)
task.spawn(function()
_0x2C20.RenderStepped:Wait()
if _0xE870 then
_0xB9B7(false)
_0xA1F3()
local _0x6F78 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
if _0x6F78 then
_0xAE9A.Position = UDim2.fromOffset(
math.floor((_0x6F78.X - _0x6401) / 2),
math.floor((_0x6F78.Y - _0xAE9A.Size.Y.Offset) / 2)
)
end
end
end)
_0x6FF4(true)
_0x3159.step(0.85,"Setting up combat")
local _0x0047
do
local _0xBEF3 = {"team","squad","faction","side","clan","party","alliance"}
local _0x4C6F = {"kill","score","death","point","damage","rank","level","win","count","size","chat"}
local function _0x3F23(_0xBF13)
local _0x54FD = string.lower(_0xBF13)
for _0xDCCD, _0x0866 in ipairs(_0x4C6F) do
if string.find(_0x54FD, _0x0866, 1, true) then return false end
end
for _0xDCCD, _0x0866 in ipairs(_0xBEF3) do
if string.find(_0x54FD, _0x0866, 1, true) then return true end
end
return false
end
local function _0x9EB1(inst, _0xD0D8)
if not inst then return end
for _0x434E, _0x803E in pairs(inst:GetAttributes()) do
if _0xD0D8[_0x434E] == nil and _0x3F23(_0x434E) then _0xD0D8[_0x434E] = _0x803E end
end
for _0xDCCD, _0x75F5 in ipairs(inst:GetChildren()) do
if _0x75F5:IsA("ValueBase") and _0xD0D8[_0x75F5.Name] == nil and _0x3F23(_0x75F5.Name) then
_0xD0D8[_0x75F5.Name] = _0x75F5.Value
end
end
local _0x465B = inst:FindFirstChild("leaderstats")
if _0x465B then
for _0xDCCD, _0x75F5 in ipairs(_0x465B:GetChildren()) do
if _0x75F5:IsA("ValueBase") and _0xD0D8[_0x75F5.Name] == nil and _0x3F23(_0x75F5.Name) then
_0xD0D8[_0x75F5.Name] = _0x75F5.Value
end
end
end
end
local function _0xBF07(_0x5D5D)
local _0x24D5 = _0x6FE4
if _0x24D5.Team and _0x5D5D.Team then
return _0x24D5.Team == _0x5D5D.Team
end
local _0x82B5, _0x051B = {}, {}
_0x9EB1(_0x24D5, _0x82B5)
_0x9EB1(_0x24D5.Character, _0x82B5)
_0x9EB1(_0x5D5D, _0x051B)
_0x9EB1(_0x5D5D.Character, _0x051B)
local _0x348A = false
for _0x434E, _0x803E in pairs(_0x82B5) do
if _0x051B[_0x434E] ~= nil then
if _0x051B[_0x434E] == _0x803E then return true end
_0x348A = true
end
end
if _0x348A then return false end
if not _0x24D5.Neutral and not _0x5D5D.Neutral then
return _0x24D5.TeamColor == _0x5D5D.TeamColor
end
return nil
end
_0x0047 = function(_0x5D5D)
if not _0xC248.TeamCheck then return true end
local _0x1DBF = _0x5D5D.Character
if _0x1DBF and _0x1DBF:FindFirstChildOfClass("ForceField") then return false end
return _0xBF07(_0x5D5D) ~= true
end
local function _0x18F5(inst)
if not inst then return"(none)"end
local _0xCAC0 = {}
for _0x434E, _0x803E in pairs(inst:GetAttributes()) do _0xCAC0[#_0xCAC0 + 1] ="@".. _0x434E .."=".. tostring(_0x803E) end
for _0xDCCD, _0x75F5 in ipairs(inst:GetChildren()) do
if _0x75F5:IsA("ValueBase") then _0xCAC0[#_0xCAC0 + 1] = _0x75F5.Name .."=".. tostring(_0x75F5.Value) end
end
return #_0xCAC0 > 0 and table.concat(_0xCAC0,", ") or"(none)"end
local function _0x4B7D(_0x5D5D)
local _0xBF16 = {}
_0x9EB1(_0x5D5D, _0xBF16)
_0x9EB1(_0x5D5D.Character, _0xBF16)
local _0xCAC0 = {}
for _0x434E, _0x803E in pairs(_0xBF16) do _0xCAC0[#_0xCAC0 + 1] = _0x434E .."=".. tostring(_0x803E) end
return #_0xCAC0 > 0 and table.concat(_0xCAC0,", ") or"(none)"end
_0x5028 = function()
print("[OUL team] ===== you: ".. _0x6FE4.Name .." =====")
print("[OUL team] Team:", _0x6FE4.Team,"| TeamColor:", _0x6FE4.TeamColor,"| Neutral:", _0x6FE4.Neutral)
print("[OUL team] team-like fields:", _0x4B7D(_0x6FE4))
print("[OUL team] player values:", _0x18F5(_0x6FE4))
print("[OUL team] character values:", _0x18F5(_0x6FE4.Character))
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
print("[OUL team] ----- ".. _0x5D5D.Name .." -----")
print("[OUL team] Team:", _0x5D5D.Team,"| TeamColor:", _0x5D5D.TeamColor,"| Neutral:", _0x5D5D.Neutral)
print("[OUL team] sameTeam:", _0xBF07(_0x5D5D),"| canDamage:", _0x0047(_0x5D5D))
print("[OUL team] team-like fields:", _0x4B7D(_0x5D5D))
print("[OUL team] player values:", _0x18F5(_0x5D5D))
print("[OUL team] character values:", _0x18F5(_0x5D5D.Character))
end
end
_0x9996("Team info printed to Output")
end
end
local function _0x3D05(_0xB1E8, character)
if not _0xC248.WallCheck then return true end
local _0x1AF3 = RaycastParams.new()
_0x1AF3.FilterType = Enum.RaycastFilterType.Exclude
_0x1AF3.FilterDescendantsInstances = { _0x6FE4.Character, character }
local _0xE755 = _0x7C80.CFrame.Position
local _0x8711 = workspace:Raycast(_0xE755, _0xB1E8.Position - _0xE755, _0x1AF3)
return _0x8711 == nil
end
local function _0x3D42(_0x1DBF)
if _0xC248.AimPart =="Head"then
return _0x1DBF:FindFirstChild("Head") or _0x1DBF:FindFirstChild("HumanoidRootPart")
end
return _0x1DBF:FindFirstChild("UpperTorso")
or _0x1DBF:FindFirstChild("Torso")
or _0x1DBF:FindFirstChild("HumanoidRootPart")
end
local _0xCD60 = 1000
local function _0x44BC()
local _0xB920 = workspace.CurrentCamera.ViewportSize / 2
local _0x2BBD, _0x9059 = nil, _0xC248.IgnoreFOV and math.huge or _0xC248.FOV
local _0x3FD0 = _0x6FE4.Character
local _0xCCAE = _0x3FD0 and _0x3FD0:FindFirstChild("HumanoidRootPart")
local _0xE755 = _0xCCAE and _0xCCAE.Position or _0x7C80.CFrame.Position
local function _0xCD68(_0x1DBF, _0x5D5D)
local _0x9777 = _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0xB1E8 = _0x3D42(_0x1DBF)
if not (_0x9777 and _0xB1E8 and _0x7DFD(_0x1DBF)) then return end
if _0x5D5D then
if not _0x0047(_0x5D5D) then return end
elseif _0xC248.TeamCheck and _0x1DBF:FindFirstChildOfClass("ForceField") then
return
end
if (_0xB1E8.Position - _0xE755).Magnitude > _0xCD60 then return end
local _0xE45E, _0x8C46 = _0x7C80:WorldToViewportPoint(_0xB1E8.Position)
if not _0x8C46 then return end
local _0xD840 = (Vector2.new(_0xE45E.X, _0xE45E.Y) - _0xB920).Magnitude
if _0xD840 < _0x9059 and _0x3D05(_0xB1E8, _0x1DBF) then
_0x2BBD, _0x9059 = _0xB1E8, _0xD840
end
end
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 and _0x5D5D.Character then
_0xCD68(_0x5D5D.Character, _0x5D5D)
end
end
if _0xC248.TargetNPCs then
for _0xDCCD, _0x114D in ipairs(_0x72FA) do
if _0x114D.Parent then
_0xCD68(_0x114D, nil)
end
end
end
return _0x2BBD
end
do
local _0x0A1A = nil
local _0xEC50 = 0
local _0x5B42 = _0x85F6:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
local _0x70F4 = { began = 0, ended = 0, expires = 0 }
local function _0x0041()
_0x70F4.began += 1
_0x70F4.ended += 1
_0x70F4.expires = os.clock() + 0.25
end
_0x32C1(_0x85F6.InputBegan:Connect(function(_0x862B)
if _0x862B.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
if _0x70F4.began > 0 and os.clock() < _0x70F4.expires then
_0x70F4.began -= 1
else
_0x5B42 = true
end
end))
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0x862B.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
if _0x70F4.ended > 0 and os.clock() < _0x70F4.expires then
_0x70F4.ended -= 1
else
_0x5B42 = false
end
end))
local function _0x2AB7()
local _0x0DE2 = workspace.CurrentCamera
local _0x752D = _0x85F6:GetMouseLocation()
local _0x8274 = _0x0DE2:ViewportPointToRay(_0x752D.X, _0x752D.Y)
local _0x1AF3 = RaycastParams.new()
_0x1AF3.FilterType = Enum.RaycastFilterType.Exclude
_0x1AF3.FilterDescendantsInstances = { _0x6FE4.Character }
local _0x8711 = workspace:Raycast(_0x8274.Origin, _0x8274.Direction * _0xCD60, _0x1AF3)
if not _0x8711 then return nil end
local _0x114D = _0x8711.Instance:FindFirstAncestorOfClass("Model")
while _0x114D and not _0x114D:FindFirstChildOfClass("Humanoid") do
_0x114D = _0x114D.Parent and _0x114D.Parent:FindFirstAncestorOfClass("Model")
end
if not _0x114D or _0x114D == _0x6FE4.Character then return nil end
local _0x9777 = _0x114D:FindFirstChildOfClass("Humanoid")
if not _0x9777 or not _0x7DFD(_0x114D) then return nil endif _0x114D:FindFirstChildOfClass("ForceField") then return nil end
local _0x5D5D = _0x8325:GetPlayerFromCharacter(_0x114D)
if _0x5D5D then
if _0x5D5D ~= _0x6FE4 and _0x0047(_0x5D5D) then
return _0x5D5D
end
return nil
end
if not _0xC248.TargetNPCs then return nil end
return _0x114D
end
local function _0x58F1()
_0x0041()
if mouse1click then
if pcall(mouse1click) then return end
end
local _0x499B = pcall(function()
local _0x4D00 = game:GetService("VirtualInputManager")
local _0x752D = _0x85F6:GetMouseLocation()
_0x4D00:SendMouseButtonEvent(_0x752D.X, _0x752D.Y, 0, true, game, 0)
_0x4D00:SendMouseButtonEvent(_0x752D.X, _0x752D.Y, 0, false, game, 0)
end)
if _0x499B then return end
local _0x1DBF = _0x6FE4.Character
local _0xA5E9 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Tool")
if _0xA5E9 then
_0xA5E9:Activate()
end
end
_0x32C1(_0x2C20.Heartbeat:Connect(function()
local _0xB621 = _0x85F6.MouseBehavior == Enum.MouseBehavior.LockCenter
if not _0xC248.Triggerbot or _0x8C4E or not _0xB621 or _0x85F6:GetFocusedTextBox() then
_0x0A1A = nil
return
end
if _0xC248.TriggerOnClick and not _0x5B42 then
_0x0A1A = nil
return
end
if not _0x2AB7() then
_0x0A1A = nil
return
end
local _0x67E0 = os.clock()
_0x0A1A = _0x0A1A or _0x67E0
if _0x67E0 - _0x0A1A >= _0xC248.TriggerDelay / 1000 and _0x67E0 - _0xEC50 >= 0.1 then
_0xEC50 = _0x67E0
_0x58F1()
end
end))_0xD1D6.fireClick = _0x58F1
end
local _0xA935 = {}
local _0x1C2F = 1000
local function _0x084B(_0x5D5D)
local _0x4883 = _0xA935[_0x5D5D]
if _0x4883 then
_0x4883:Destroy()
_0xA935[_0x5D5D] = nil
end
end
_0x32C1(_0x8325.PlayerRemoving:Connect(_0x084B))
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not (_0xC248.ESP and _0xC248.Tracers) then
for _0x5D5D in pairs(_0xA935) do
_0x084B(_0x5D5D)
end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x7B8B = _0x0DE2.ViewportSize
local _0x29E7 = Vector2.new(_0x7B8B.X / 2, _0x7B8B.Y / 2)
local _0x3FD0 = _0x6FE4.Character
local _0xCCAE = _0x3FD0 and _0x3FD0:FindFirstChild("HumanoidRootPart")
local _0xE755 = _0xCCAE and _0xCCAE.Position or _0x0DE2.CFrame.Position
local _0x6B5F = _0x0AF4()
local _0x8DF9 = {}
for _0xDCCD, _0x99C5 in ipairs(_0x6B5F) do _0x8DF9[_0x99C5[1]] = true end
for _0x434E in pairs(_0xA935) do
if not _0x8DF9[_0x434E] then _0x084B(_0x434E) end
end
for _0xDCCD, ent in ipairs(_0x6B5F) do
local _0x5D5D = ent[1]
if _0x5D5D ~= _0x6FE4 then
local _0x1DBF = ent[2]
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
local _0x4883 = _0xA935[_0x5D5D]
local _0x2BD1 = false
if _0x9777 and _0x80EB and _0x9777.Health > 0
and (_0x80EB.Position - _0xE755).Magnitude <= _0x1C2F then
local _0xCF40 = _0x0DE2:WorldToViewportPoint(_0x80EB.Position)
local _0xA43A
if _0xCF40.Z > 0 then
_0xA43A = Vector2.new(_0xCF40.X, _0xCF40.Y) - _0x29E7
else
local _0x24B8 = _0x0DE2.CFrame:PointToObjectSpace(_0x80EB.Position)
local _0x7018 = Vector2.new(_0x24B8.X, -_0x24B8.Y)
_0x7018 = _0x7018.Magnitude > 0.001 and _0x7018.Unit or Vector2.new(0, 1)
_0xA43A = _0x7018 * math.max(_0x7B8B.X, _0x7B8B.Y)
end
if _0xA43A.Magnitude > 4000 then
_0xA43A = _0xA43A.Unit * 4000
end
_0x2BD1 = true
if not _0x4883 then
_0x4883 = Instance.new("Frame")
_0x4883.Name ="OULTracer"_0x4883.AnchorPoint = Vector2.new(0.5, 0.5)
_0x4883.BorderSizePixel = 0
_0x4883.Parent = _0xD27F
_0xA935[_0x5D5D] = _0x4883
end
local _0x9D52 = _0x29E7 + _0xA43A
_0x4883.BackgroundColor3 = _0x0556.Tracer
_0x4883.Size = UDim2.fromOffset(_0xA43A.Magnitude, 1.5)
_0x4883.Position = UDim2.fromOffset((_0x29E7.X + _0x9D52.X) / 2, (_0x29E7.Y + _0x9D52.Y) / 2)
_0x4883.Rotation = math.deg(math.atan2(_0xA43A.Y, _0xA43A.X))
_0x4883.Visible = true
end
if not _0x2BD1 and _0x4883 then
_0x4883.Visible = false
end
end
end
end))
local _0x5C88 = {}
local function _0xD0C9(_0x5D5D)
local _0xBF16 = _0x5C88[_0x5D5D]
if _0xBF16 then
_0xBF16:Destroy()
_0x5C88[_0x5D5D] = nil
end
end
_0x32C1(_0x8325.PlayerRemoving:Connect(_0xD0C9))
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not (_0xC248.ESP and _0xC248.Boxes) then
for _0x5D5D in pairs(_0x5C88) do
_0xD0C9(_0x5D5D)
end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x6B5F = _0x0AF4()
local _0x8DF9 = {}
for _0xDCCD, _0x99C5 in ipairs(_0x6B5F) do _0x8DF9[_0x99C5[1]] = true end
for _0x434E in pairs(_0x5C88) do
if not _0x8DF9[_0x434E] then _0xD0C9(_0x434E) end
end
for _0xDCCD, ent in ipairs(_0x6B5F) do
local _0x5D5D = ent[1]
if _0x5D5D ~= _0x6FE4 then
local _0x1DBF = ent[2]
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
local _0x8183 = _0x5C88[_0x5D5D]
local _0x2BD1 = false
if _0x9777 and _0x80EB and _0x9777.Health > 0 then
local _0x0DD5 = _0x80EB.CFrame.LookVector
local _0x8504 = (_0x0DD5.X * _0x0DD5.X + _0x0DD5.Z * _0x0DD5.Z > 0.0001) and math.atan2(-_0x0DD5.X, -_0x0DD5.Z) or 0
local _0x44B0 = CFrame.new(_0x80EB.Position) * CFrame.Angles(0, _0x8504, 0)
local _0x0250, _0x7025, _0x76F2, _0x208A = math.huge, math.huge, -math.huge, -math.huge
local _0x2099 = true
for i = 0, 7 do
local _0x8F0E = (i % 2 == 0) and -2 or 2
local _0x6998 = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
local _0x035B = (i < 4) and -1 or 1
local _0xC566 = _0x0DE2:WorldToViewportPoint(_0x44B0:PointToWorldSpace(Vector3.new(_0x8F0E, _0x6998, _0x035B)))
if _0xC566.Z <= 0 then
_0x2099 = false
break
end
_0x0250 = math.min(_0x0250, _0xC566.X)
_0x76F2 = math.max(_0x76F2, _0xC566.X)
_0x7025 = math.min(_0x7025, _0xC566.Y)
_0x208A = math.max(_0x208A, _0xC566.Y)
end
if _0x2099 then
local _0x0866 = _0x76F2 - _0x0250
local _0xCF21 = _0x208A - _0x7025
if _0xCF21 > 2 then
_0x2BD1 = true
if not _0x8183 then
_0x8183 = Instance.new("Frame")
_0x8183.Name ="OULBox"_0x8183.BorderSizePixel = 0
_0x8183.Parent = _0xD27F
local _0xAC75 = Instance.new("UIStroke")
_0xAC75.Thickness = 1.5
_0xAC75.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_0xAC75.Parent = _0x8183
_0x5C88[_0x5D5D] = _0x8183
end
_0x8183.Position = UDim2.fromOffset(_0x0250, _0x7025)
_0x8183.Size = UDim2.fromOffset(_0x0866, _0xCF21)
_0x8183.BackgroundColor3 = _0x0556.BoxFill
_0x8183.BackgroundTransparency = _0xC248.BoxFill and 0.7 or 1
_0x8183:FindFirstChildOfClass("UIStroke").Color = _0x0556.Box
_0x8183.Visible = true
end
end
end
if not _0x2BD1 and _0x8183 then
_0x8183.Visible = false
end
end
end
end))
do
local _0xA923 = {}
local _0x83C5 = 1000
local function _0xCEC8(_0xB92E)
local _0x35C0 = _0xA923[_0xB92E]
if _0x35C0 then
for _0xDCCD, _0x7238 in ipairs(_0x35C0.lines) do _0x7238:Destroy() end
_0xA923[_0xB92E] = nil
end
end
_0x32C1(_0x8325.PlayerRemoving:Connect(_0xCEC8))
local function _0xA8E4(_0x1DBF)
local _0xD0D8 = {}
for _0xDCCD, _0xB1E8 in ipairs(_0x1DBF:GetChildren()) do
if _0xB1E8:IsA("BasePart") then
for _0xDCCD, _0x752D in ipairs(_0xB1E8:GetChildren()) do
if _0x752D:IsA("Motor6D") then
local _0x82B5, _0x051B = _0x752D.Part0, _0x752D.Part1
if _0x82B5 and _0x051B and _0x82B5.Parent == _0x1DBF and _0x051B.Parent == _0x1DBF
and _0x82B5.Name ~="HumanoidRootPart"and _0x051B.Name ~="HumanoidRootPart"then
_0xD0D8[#_0xD0D8 + 1] = { _0x82B5, _0x051B }
end
end
end
end
end
return _0xD0D8
end
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not (_0xC248.ESP and _0xC248.Skeleton) then
for _0xB92E in pairs(_0xA923) do _0xCEC8(_0xB92E) end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x3FD0 = _0x6FE4.Character
local _0xCCAE = _0x3FD0 and _0x3FD0:FindFirstChild("HumanoidRootPart")
local _0xE755 = _0xCCAE and _0xCCAE.Position or _0x0DE2.CFrame.Position
local _0x6B5F = _0x0AF4()
local _0x8DF9 = {}
for _0xDCCD, _0x99C5 in ipairs(_0x6B5F) do
if _0x99C5[2] then _0x8DF9[_0x99C5[1]] = true end
end
for _0xB92E in pairs(_0xA923) do
if not _0x8DF9[_0xB92E] then _0xCEC8(_0xB92E) end
end
local _0x67E0 = os.clock()
for _0xDCCD, ent in ipairs(_0x6B5F) do
local _0xB92E, _0x1DBF = ent[1], ent[2]
if _0xB92E ~= _0x6FE4 and _0x1DBF then
local _0x9777 = _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF:FindFirstChild("HumanoidRootPart")
local _0x35C0 = _0xA923[_0xB92E]
if _0x35C0 and _0x35C0.char ~= _0x1DBF then
_0xCEC8(_0xB92E)
_0x35C0 = nil
end
if _0x9777 and _0x80EB and _0x9777.Health > 0
and (_0x80EB.Position - _0xE755).Magnitude <= _0x83C5 then
if not _0x35C0 then
_0x35C0 = { _0x1DBF = _0x1DBF, _0x8A92 = {}, lines = {}, built = 0 }
_0xA923[_0xB92E] = _0x35C0
end
if _0x67E0 - _0x35C0.built > 2 then
_0x35C0.built = _0x67E0
_0x35C0.joints = _0xA8E4(_0x1DBF)
end
for i, j in ipairs(_0x35C0.joints) do
local _0x4883 = _0x35C0.lines[i]
if not _0x4883 then
_0x4883 = Instance.new("Frame")
_0x4883.Name ="OULBone"_0x4883.AnchorPoint = Vector2.new(0.5, 0.5)
_0x4883.BorderSizePixel = 0
_0x4883.Parent = _0xD27F
_0x35C0.lines[i] = _0x4883
end
local _0x82B5, _0x051B = j[1], j[2]
local _0x2BD1 = false
if _0x82B5.Parent and _0x051B.Parent then
local _0xB479 = _0x0DE2:WorldToViewportPoint(_0x82B5.Position)
local _0x92DB = _0x0DE2:WorldToViewportPoint(_0x051B.Position)
if _0xB479.Z > 0 and _0x92DB.Z > 0 then
local _0x82CE, _0xBDF6 = Vector2.new(_0xB479.X, _0xB479.Y), Vector2.new(_0x92DB.X, _0x92DB.Y)
local _0xA43A = _0xBDF6 - _0x82CE
local _0xEFA8 = (_0x82CE + _0xBDF6) / 2
_0x4883.Size = UDim2.fromOffset(_0xA43A.Magnitude, 1.5)
_0x4883.Position = UDim2.fromOffset(_0xEFA8.X, _0xEFA8.Y)
_0x4883.Rotation = math.deg(math.atan2(_0xA43A.Y, _0xA43A.X))
_0x4883.BackgroundColor3 = _0x0556.Skeleton
_0x2BD1 = true
end
end
_0x4883.Visible = _0x2BD1
end
for i = #_0x35C0.joints + 1, #_0x35C0.lines do
_0x35C0.lines[i].Visible = false
end
elseif _0x35C0 then
for _0xDCCD, _0x7238 in ipairs(_0x35C0.lines) do _0x7238.Visible = false end
end
end
end
end))
end
do
local _0x0D84 = {}
local function _0x2013(_0xB92E)
local _0x051B = _0x0D84[_0xB92E]
if _0x051B then
_0x051B.bg:Destroy()
_0x0D84[_0xB92E] = nil
end
end
_0x32C1(_0x8325.PlayerRemoving:Connect(_0x2013))
local function _0xEB5D(_0x0DE2, _0x80EB)
local _0x0DD5 = _0x80EB.CFrame.LookVector
local _0x8504 = (_0x0DD5.X * _0x0DD5.X + _0x0DD5.Z * _0x0DD5.Z > 0.0001) and math.atan2(-_0x0DD5.X, -_0x0DD5.Z) or 0
local _0x44B0 = CFrame.new(_0x80EB.Position) * CFrame.Angles(0, _0x8504, 0)
local _0x0250, _0x7025, _0x76F2, _0x208A = math.huge, math.huge, -math.huge, -math.huge
for i = 0, 7 do
local _0x8F0E = (i % 2 == 0) and -2 or 2
local _0x6998 = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
local _0x035B = (i < 4) and -1 or 1
local _0xC566 = _0x0DE2:WorldToViewportPoint(_0x44B0:PointToWorldSpace(Vector3.new(_0x8F0E, _0x6998, _0x035B)))
if _0xC566.Z <= 0 then return nil end
_0x0250 = math.min(_0x0250, _0xC566.X)
_0x76F2 = math.max(_0x76F2, _0xC566.X)
_0x7025 = math.min(_0x7025, _0xC566.Y)
_0x208A = math.max(_0x208A, _0xC566.Y)
end
return _0x0250, _0x7025, _0x76F2, _0x208A
end
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not (_0xC248.ESP and _0xC248.ESPHealth) then
for _0xB92E in pairs(_0x0D84) do _0x2013(_0xB92E) end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x6B5F = _0x0AF4()
local _0x8DF9 = {}
for _0xDCCD, _0x99C5 in ipairs(_0x6B5F) do
if _0x99C5[2] then _0x8DF9[_0x99C5[1]] = true end
end
for _0xB92E in pairs(_0x0D84) do
if not _0x8DF9[_0xB92E] then _0x2013(_0xB92E) end
end
for _0xDCCD, ent in ipairs(_0x6B5F) do
local _0xB92E, _0x1DBF = ent[1], ent[2]
if _0x1DBF then
local _0x9777 = _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF:FindFirstChild("HumanoidRootPart")
local _0x051B = _0x0D84[_0xB92E]
local _0x2BD1 = false
if _0x9777 and _0x80EB and _0x9777.Health > 0 then
local _0x0250, _0x7025, _0x76F2, _0x208A = _0xEB5D(_0x0DE2, _0x80EB)
if _0x0250 and _0x208A - _0x7025 > 2 then
_0x2BD1 = true
if not _0x051B then
local _0xECF3 = Instance.new("Frame")
_0xECF3.Name ="OULHealthBar"_0xECF3.BorderSizePixel = 0
_0xECF3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_0xECF3.BackgroundTransparency = 0.35
_0xECF3.Parent = _0xD27F
local _0x9062 = Instance.new("Frame")
_0x9062.BorderSizePixel = 0
_0x9062.AnchorPoint = Vector2.new(0, 1)
_0x9062.Parent = _0xECF3
_0x051B = { _0xECF3 = _0xECF3, _0x9062 = _0x9062 }
_0x0D84[_0xB92E] = _0x051B
end
local _0xCF21 = _0x208A - _0x7025
local _0x8E01 = math.clamp(_0x9777.Health / math.max(_0x9777.MaxHealth, 1), 0, 1)
_0x051B.bg.Position = UDim2.fromOffset(_0x0250 - 7, _0x7025)
_0x051B.bg.Size = UDim2.fromOffset(4, _0xCF21)
_0x051B.fill.Position = UDim2.new(0, 1, 1, -1)
_0x051B.fill.Size = UDim2.new(1, -2, 0, math.max((_0xCF21 - 2) * _0x8E01, 0))
_0x051B.fill.BackgroundColor3 = Color3.fromRGB(235, 70, 70):Lerp(Color3.fromRGB(90, 220, 120), _0x8E01)
_0x051B.bg.Visible = true
end
end
if not _0x2BD1 and _0x051B then
_0x051B.bg.Visible = false
end
end
end
end))
enddo
local _0x5066 = {}
local _0x3AD2 = 1000
local function _0xD3C0(_0xB92E)
local _0x7238 = _0x5066[_0xB92E]
if _0x7238 then
_0x7238.dist:Destroy()
_0x7238.weapon:Destroy()
_0x5066[_0xB92E] = nil
end
end
_0x32C1(_0x8325.PlayerRemoving:Connect(_0xD3C0))
local function _0x4455(align, _0x7368, _0x0866)
local _0xCAC0 = Instance.new("TextLabel")
_0xCAC0.BackgroundTransparency = 1
_0xCAC0.AnchorPoint = _0x7368
_0xCAC0.Size = UDim2.fromOffset(_0x0866, 14)
_0xCAC0.Font = Enum.Font.Code
_0xCAC0.TextSize = 12
_0xCAC0.TextXAlignment = align
_0xCAC0.TextStrokeTransparency = 0
_0xCAC0.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_0xCAC0.Visible = false
_0xCAC0.Parent = _0xD27F
return _0xCAC0
end
local function _0xEB5D(_0x0DE2, _0x80EB)
local _0x0DD5 = _0x80EB.CFrame.LookVector
local _0x8504 = (_0x0DD5.X * _0x0DD5.X + _0x0DD5.Z * _0x0DD5.Z > 0.0001) and math.atan2(-_0x0DD5.X, -_0x0DD5.Z) or 0
local _0x44B0 = CFrame.new(_0x80EB.Position) * CFrame.Angles(0, _0x8504, 0)
local _0x0250, _0x7025, _0x76F2, _0x208A = math.huge, math.huge, -math.huge, -math.huge
for i = 0, 7 do
local _0x8F0E = (i % 2 == 0) and -2 or 2
local _0x6998 = (math.floor(i / 2) % 2 == 0) and -3.2 or 2.8
local _0x035B = (i < 4) and -1 or 1
local _0xC566 = _0x0DE2:WorldToViewportPoint(_0x44B0:PointToWorldSpace(Vector3.new(_0x8F0E, _0x6998, _0x035B)))
if _0xC566.Z <= 0 then return nil end
_0x0250 = math.min(_0x0250, _0xC566.X)
_0x76F2 = math.max(_0x76F2, _0xC566.X)
_0x7025 = math.min(_0x7025, _0xC566.Y)
_0x208A = math.max(_0x208A, _0xC566.Y)
end
return _0x0250, _0x7025, _0x76F2, _0x208A
end
_0x32C1(_0x2C20.RenderStepped:Connect(function()
if not (_0xC248.ESP and (_0xC248.ESPDistance or _0xC248.ESPWeapon)) then
for _0xB92E in pairs(_0x5066) do _0xD3C0(_0xB92E) end
return
end
local _0x0DE2 = workspace.CurrentCamera
local _0x3FD0 = _0x6FE4.Character
local _0xCCAE = _0x3FD0 and _0x3FD0:FindFirstChild("HumanoidRootPart")
local _0xE755 = _0xCCAE and _0xCCAE.Position or _0x0DE2.CFrame.Position
local _0x6B5F = _0x0AF4()
local _0x8DF9 = {}
for _0xDCCD, _0x99C5 in ipairs(_0x6B5F) do
if _0x99C5[2] then _0x8DF9[_0x99C5[1]] = true end
end
for _0xB92E in pairs(_0x5066) do
if not _0x8DF9[_0xB92E] then _0xD3C0(_0xB92E) end
end
for _0xDCCD, ent in ipairs(_0x6B5F) do
local _0xB92E, _0x1DBF = ent[1], ent[2]
if _0x1DBF then
local _0x9777 = _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF:FindFirstChild("HumanoidRootPart")
local _0x7238 = _0x5066[_0xB92E]
local _0x632B, _0x4DF8 = false, false
if _0x9777 and _0x80EB and _0x9777.Health > 0 then
local _0xD840 = (_0x80EB.Position - _0xE755).Magnitude
if _0xD840 <= _0x3AD2 then
local _0x0250, _0x7025, _0x76F2, _0x208A = _0xEB5D(_0x0DE2, _0x80EB)
if _0x0250 and _0x208A - _0x7025 > 2 then
if not _0x7238 then
_0x7238 = {
_0xD840 = _0x4455(Enum.TextXAlignment.Right, Vector2.new(1, 0), 90),
weapon = _0x4455(Enum.TextXAlignment.Center, Vector2.new(0.5, 0), 160),
}
_0x5066[_0xB92E] = _0x7238
end
if _0xC248.ESPDistance then
_0x632B = true
_0x7238.dist.Text = string.format("%d studs", math.floor(_0xD840 + 0.5))
_0x7238.dist.TextColor3 = _0x0556.Name
_0x7238.dist.Position = UDim2.fromOffset(_0x76F2 - 3, _0x7025 + 2)
end
if _0xC248.ESPWeapon then
local _0xA5E9 = _0x1DBF:FindFirstChildOfClass("Tool")
if _0xA5E9 then
_0x4DF8 = true
_0x7238.weapon.Text = _0xA5E9.Name
_0x7238.weapon.TextColor3 = _0x0556.Name
_0x7238.weapon.Position = UDim2.fromOffset((_0x0250 + _0x76F2) / 2, _0x208A + 2)
end
end
end
end
end
if _0x7238 then
_0x7238.dist.Visible = _0x632B
_0x7238.weapon.Visible = _0x4DF8
end
end
end
end))
enddo
local _0x7613 = {}
local _0xB7F5
local _0xA91B = false
local _0x6D1B, _0xE2BE = 0, nil
local _0x4148, _0x6F83 = {}, {}
local _0x3EBE = type(writefile) =="function"and type(getcustomasset) =="function"local function _0x99D4(_0x54FD)
return string.char(
math.floor(_0x54FD / 16777216) % 256,
math.floor(_0x54FD / 65536) % 256,
math.floor(_0x54FD / 256) % 256,
_0x54FD % 256
)
end
local _0xCEA6
local function _0xAABB(str)
if not _0xCEA6 then
_0xCEA6 = {}
for i = 0, 255 do
local _0x75F5 = i
for _0xDCCD = 1, 8 do
if bit32.band(_0x75F5, 1) == 1 then
_0x75F5 = bit32.bxor(0xEDB88320, bit32.rshift(_0x75F5, 1))
else
_0x75F5 = bit32.rshift(_0x75F5, 1)
end
end
_0xCEA6[i] = _0x75F5
end
end
local _0x75F5 = 0xFFFFFFFF
for i = 1, #str do
_0x75F5 = bit32.bxor(_0xCEA6[bit32.band(bit32.bxor(_0x75F5, str:byte(i)), 0xFF)], bit32.rshift(_0x75F5, 8))
end
return bit32.bxor(_0x75F5, 0xFFFFFFFF)
end
local function _0xB869(_0xFBC4, _0x5EDF)
return _0x99D4(#_0x5EDF) .. _0xFBC4 .. _0x5EDF .. _0x99D4(_0xAABB(_0xFBC4 .. _0x5EDF))
end
local function _0x7B16(_0xAD48, _0x66D9, _0x051B)
local _0x6C28 = string.char(0, _0xAD48, _0x66D9, _0x051B)
local _0x82B5, _0x966A = 1, 0
for i = 1, #_0x6C28 do
_0x82B5 = (_0x82B5 + _0x6C28:byte(i)) % 65521
_0x966A = (_0x966A + _0x82B5) % 65521
end
local _0x6B8D ="\120\1".."\1".."\4\0".."\251\255".. _0x6C28 .. _0x99D4(_0x966A * 65536 + _0x82B5)
local _0xBA2E = _0x99D4(1) .. _0x99D4(1) .."\8\2\0\0\0"return"\137PNG\13\10\26\10".. _0xB869("IHDR", _0xBA2E) .. _0xB869("IDAT", _0x6B8D) .. _0xB869("IEND","")
end
local function _0x7877(_0x803E)
return math.clamp(math.floor(_0x803E * 255 / 8 + 0.5) * 8, 0, 255)
end
local function _0x8C10(_0x75F5)
local _0xAD48, _0x66D9, _0x051B = _0x7877(_0x75F5.R), _0x7877(_0x75F5.G), _0x7877(_0x75F5.B)
local _0xB92E = string.format("%02X%02X%02X", _0xAD48, _0x66D9, _0x051B)
if _0x4148[_0xB92E] then return _0x4148[_0xB92E], _0xB92E end
local _0x499B, _0xA5EC = pcall(function()
local _0xBF13 ="OULSky_".. _0xB92E ..".png"writefile(_0xBF13, _0x7B16(_0xAD48, _0x66D9, _0x051B))
_0x6F83[#_0x6F83 + 1] = _0xBF13
return getcustomasset(_0xBF13)
end)
if _0x499B and _0xA5EC then
_0x4148[_0xB92E] = _0xA5EC
return _0xA5EC, _0xB92E
end
return nil, _0xB92E
end
local function _0x6E6A()
for _0xDCCD, _0x75F5 in ipairs(_0x1F4A:GetChildren()) do
if (_0x75F5:IsA("Sky") or _0x75F5:IsA("Atmosphere")) and _0x75F5 ~= _0xB7F5 then
_0x7613[#_0x7613 + 1] = _0x75F5
_0x75F5.Parent = nil
end
end
end
local function _0x5CFB()
if not _0x3EBE then return false end
_0xA91B = true
_0xE2BE = nil
_0xB7F5 = Instance.new("Sky")
_0xB7F5.Name ="OULSky"_0xB7F5.StarCount = 0
_0xB7F5.CelestialBodiesShown = false
_0x6E6A()
_0xB7F5.Parent = _0x1F4A
return true
end
local function _0x84F8(purge)
if _0xA91B then
_0xA91B = false
if _0xB7F5 then pcall(function() _0xB7F5:Destroy() end) _0xB7F5 = nil end
for _0xDCCD, _0x75F5 in ipairs(_0x7613) do
pcall(function() _0x75F5.Parent = _0x1F4A end)
end
_0x7613 = {}
end
if purge then
if type(delfile) =="function"then
for _0xDCCD, _0xBF16 in ipairs(_0x6F83) do pcall(delfile, _0xBF16) end
end
_0x6F83, _0x4148 = {}, {}
end
end
_0x32C1(_0x2C20.Heartbeat:Connect(function(dt)
if _0xC248.Skybox then
if not _0xA91B and not _0x5CFB() then
_0xC248.Skybox = false
if _0x40B9.Skybox then _0x40B9.Skybox(true) end
_0x9996("Skybox needs file support")
return
end
_0x6D1B += dt
if _0x6D1B >= 1 then
_0x6D1B = 0
_0x6E6A()
if _0xB7F5.Parent ~= _0x1F4A then _0xB7F5.Parent = _0x1F4A end
end
local _0x75F5
if _0xC248.SkyRainbow then
_0x75F5 = Color3.fromHSV((math.floor(os.clock() * 6) % 60) / 60, 0.75, 1)
else
_0x75F5 = _0x0556.Sky
end
local _0x9632 = _0xC248.SkyBrightness / 100
_0x75F5 = Color3.new(_0x75F5.R * _0x9632, _0x75F5.G * _0x9632, _0x75F5.B * _0x9632)
local _0x94D5, _0xB92E = _0x8C10(_0x75F5)
if _0x94D5 and _0xB92E ~= _0xE2BE then
_0xE2BE = _0xB92E
_0xB7F5.SkyboxBk, _0xB7F5.SkyboxDn, _0xB7F5.SkyboxFt = _0x94D5, _0x94D5, _0x94D5
_0xB7F5.SkyboxLf, _0xB7F5.SkyboxRt, _0xB7F5.SkyboxUp = _0x94D5, _0x94D5, _0x94D5
end
elseif _0xA91B then
_0x84F8()
end
end))
_0xD1D6.skyRestore = _0x84F8
end
_0x3159.step(0.93,"Setting up movement")
local _0x3C12 = false
local function _0x3965()
local _0xB100 = workspace.CurrentCamera.CFrame
local _0x6727 = Vector3.new(0, 0, 0)
if _0x85F6:IsKeyDown(Enum.KeyCode.W) then _0x6727 = _0x6727 + _0xB100.LookVector end
if _0x85F6:IsKeyDown(Enum.KeyCode.S) then _0x6727 = _0x6727 - _0xB100.LookVector end
if _0x85F6:IsKeyDown(Enum.KeyCode.D) then _0x6727 = _0x6727 + _0xB100.RightVector end
if _0x85F6:IsKeyDown(Enum.KeyCode.A) then _0x6727 = _0x6727 - _0xB100.RightVector end
if _0x85F6:IsKeyDown(Enum.KeyCode.Space) then _0x6727 = _0x6727 + Vector3.new(0, 1, 0) end
if _0x85F6:IsKeyDown(Enum.KeyCode.LeftControl) then _0x6727 = _0x6727 - Vector3.new(0, 1, 0) end
if _0x6727.Magnitude > 0 then
return _0x6727.Unit
end
return _0x6727
end
_0x32C1(_0x2C20.Stepped:Connect(function()
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if not (_0x9777 and _0x80EB and _0x9777.Health > 0) then
_0x3C12 = false
return
end
if _0xC248.Fly then
_0x3C12 = true
_0x9777.PlatformStand = true
local _0x7018 = _0x85F6:GetFocusedTextBox() and Vector3.new(0, 0, 0) or _0x3965()
_0x80EB.AssemblyLinearVelocity = _0x7018 * _0xC248.FlySpeed
_0x80EB.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
local _0x0DD5 = workspace.CurrentCamera.CFrame.LookVector
local _0x35BC = Vector3.new(_0x0DD5.X, 0, _0x0DD5.Z)
if _0x35BC.Magnitude > 0.01 then
_0x80EB.CFrame = CFrame.lookAt(_0x80EB.Position, _0x80EB.Position + _0x35BC)
end
elseif _0x3C12 then
_0x3C12 = false
_0x9777.PlatformStand = false
_0x80EB.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end))
local _0xC5C0, _0xE88A
_0x32C1(_0x2C20.Heartbeat:Connect(function()
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
if _0xC248.Speed and _0x9777 and _0x9777.Health > 0 then
if _0xC5C0 ~= _0x9777 then
if _0xC5C0 and _0xC5C0.Parent then _0xC5C0.WalkSpeed = _0xE88A end
_0xC5C0 = _0x9777
_0xE88A = _0x9777.WalkSpeed
end
_0x9777.WalkSpeed = _0xC248.SpeedValue
elseif _0xC5C0 then
if _0xC5C0.Parent then _0xC5C0.WalkSpeed = _0xE88A end
_0xC5C0 = nil
end
end))
_0x32C1(_0x85F6.JumpRequest:Connect(function()
if not _0xC248.InfiniteJump then return end
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
if _0x9777 and _0x9777.Health > 0 then
_0x9777:ChangeState(Enum.HumanoidStateType.Jumping)
end
end))
local _0xEFCD = {}
local function _0x3E4E()
for _0xB1E8 in pairs(_0xEFCD) do
if _0xB1E8.Parent then
_0xB1E8.CanCollide = true
end
_0xEFCD[_0xB1E8] = nil
end
end
_0x32C1(_0x2C20.Stepped:Connect(function()
local _0x1DBF = _0x6FE4.Character
if _0xC248.Noclip and _0x1DBF then
for _0xDCCD, _0xB1E8 in ipairs(_0x1DBF:GetDescendants()) do
if _0xB1E8:IsA("BasePart") and _0xB1E8.CanCollide then
_0xEFCD[_0xB1E8] = true
_0xB1E8.CanCollide = false
end
end
elseif next(_0xEFCD) then
_0x3E4E()
end
end))
local function _0xC860()
if not _0xC248.MouseTP or _0x8C4E then return end
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if not (_0x9777 and _0x80EB and _0x9777.Health > 0) then return end
local _0x0DE2 = workspace.CurrentCamera
local _0x752D = _0x85F6:GetMouseLocation()
local _0x8274 = _0x0DE2:ViewportPointToRay(_0x752D.X, _0x752D.Y)
local _0x1AF3 = RaycastParams.new()
_0x1AF3.FilterType = Enum.RaycastFilterType.Exclude
_0x1AF3.FilterDescendantsInstances = { _0x1DBF }
local _0x8711 = workspace:Raycast(_0x8274.Origin, _0x8274.Direction * 10000, _0x1AF3)
if not _0x8711 then
if _0x9996 then _0x9996("Mouse TP  -  nothing in range") end
return
end
local _0x023C = Vector3.new(0, _0x9777.HipHeight + _0x80EB.Size.Y / 2, 0)
local _0x6BF8 = _0x8711.Position + _0x8711.Normal * 2 + _0x023C
_0x80EB.CFrame = CFrame.new(_0x6BF8) * (_0x80EB.CFrame - _0x80EB.CFrame.Position)
_0x80EB.AssemblyLinearVelocity = Vector3.zero
endlocal function _0x3F0C(_0x1DBF)
local _0xCF21 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
return _0xCF21 and _0xCF21.Health or math.huge
end
local _0x909B = nil
local _0x6144 = nil
local _0xBB02 = 0
local function _0xEDDA(_0xCCAE)
if _0xC248.RageMode =="Selected"then
local _0x8B86 = string.lower(_0xC248.RageTarget or"")
if _0x8B86 ==""then return nil,"pick a player"end
local _0x57E5
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
local _0x54FD, _0x6727 = string.lower(_0x5D5D.Name), string.lower(_0x5D5D.DisplayName)
if _0x54FD == _0x8B86 or _0x6727 == _0x8B86 then
_0x57E5 = _0x5D5D
break
elseif not _0x57E5 and (string.find(_0x54FD, _0x8B86, 1, true) or string.find(_0x6727, _0x8B86, 1, true)) then
_0x57E5 = _0x5D5D
end
end
end
if not _0x57E5 then return nil,"not in server"end
local _0x1DBF = _0x57E5.Character
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if not (_0x80EB and _0x7DFD(_0x1DBF)) then return nil, _0x57E5.Name .." (dead)"end
return { _0x80EB = _0x80EB, _0xBF13 = _0x57E5.Name, _0x5D5D = _0x57E5 }
end
if not _0xC248.RageLowestHP and _0x909B and _0x909B.plr and _0x909B.plr.Parent == _0x8325 then
local _0x1DBF = _0x909B.plr.Character
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if _0x80EB and _0x80EB == _0x909B.root and _0x7DFD(_0x1DBF) then
return _0x909B
end
end
local _0x2BBD, _0x9059, _0xF221
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
local _0x1DBF = _0x5D5D.Character
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if _0x80EB and _0x7DFD(_0x1DBF) and _0x0047(_0x5D5D) then
local _0x6727 = (_0x80EB.Position - _0xCCAE.Position).Magnitude
local _0x5DE5 = _0xC248.RageLowestHP and _0x3F0C(_0x1DBF) or 0if not _0x9059 or _0x5DE5 < _0xF221 or (_0x5DE5 == _0xF221 and _0x6727 < _0x9059) then
_0x2BBD, _0x9059, _0xF221 = { _0x80EB = _0x80EB, _0xBF13 = _0x5D5D.Name, _0x5D5D = _0x5D5D }, _0x6727, _0x5DE5
end
end
end
end
return _0x2BBD
end
local function _0x254A(_0x0472)
if _0xFAA9 and _0x6144 ~= _0x0472 then
_0x6144 = _0x0472
_0xFAA9.Text = _0x0472
end
end
_0x32C1(_0x2C20.Stepped:Connect(function(_0xDCCD, dt)
if _0xC248.VoidSpam then return endif not _0xC248.Ragebot then
_0x909B = nil
_0x254A("Target: none")
return
end
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0xCCAE = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if not (_0x9777 and _0xCCAE and _0x9777.Health > 0) then return end
local _0x6297
_0x909B, _0x6297 = _0xEDDA(_0xCCAE)
if not _0x909B then
_0x254A("Target: ".. (_0x6297 or"none found"))
return
end
_0x254A("Target: ".. _0x909B.name)
local _0x945A = _0x909B.root.Position
local _0xD840 = _0xC248.RageDistance
if _0xC248.RageOrbit then
_0xBB02 = (_0xBB02 + dt * _0xC248.OrbitSpeed) % (math.pi * 2)
local _0x7469 = 0
if _0xC248.RageAbove then
_0x7469 = _0xD840
elseif _0xC248.RageBelow then
_0x7469 = -_0xD840
end
local _0x6BF8 = _0x945A + Vector3.new(math.cos(_0xBB02) * _0xD840, _0x7469, math.sin(_0xBB02) * _0xD840)
_0xCCAE.CFrame = CFrame.lookAt(_0x6BF8, _0x945A)
_0xCCAE.AssemblyLinearVelocity = Vector3.zero
_0xCCAE.AssemblyAngularVelocity = Vector3.zero
return
end
local _0x0DD5 = _0x909B.root.CFrame.LookVector
local _0x35BC = Vector3.new(_0x0DD5.X, 0, _0x0DD5.Z)
if _0x35BC.Magnitude < 0.01 then return end
_0x35BC = _0x35BC.Unit
local _0x6BF8
if _0xC248.RageAbove then
_0x6BF8 = _0x945A + Vector3.new(0, _0xD840, 0)
elseif _0xC248.RageBelow then
_0x6BF8 = _0x945A - Vector3.new(0, _0xD840, 0)
else
_0x6BF8 = _0x945A - _0x35BC * _0xD840
end
_0xCCAE.CFrame = CFrame.lookAt(_0x6BF8, _0x6BF8 + _0x35BC)
_0xCCAE.AssemblyLinearVelocity = Vector3.zero
_0xCCAE.AssemblyAngularVelocity = Vector3.zero
end))do
local _0x51CF = nillocal _0x0DB4 = Instance.new("TextLabel")
_0x0DB4.Name ="OULVoidTimer"_0x0DB4.AnchorPoint = Vector2.new(0.5, 0)
_0x0DB4.Position = UDim2.new(0.5, 0, 0.5, 40)
_0x0DB4.Size = UDim2.fromOffset(300, 24)
_0x0DB4.BackgroundTransparency = 1
_0x0DB4.Font = _0x4B96
_0x0DB4.TextSize = 18
_0x0DB4.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x0DB4.TextStrokeTransparency = 0.3
_0x0DB4.Visible = false
_0x0DB4.ZIndex = 120
_0x0DB4.Parent = _0xD27Flocal _0xDD14 = game:GetService("GuiService")
local function _0x93C9()if _0x85F6:GetFocusedTextBox() then return end
if _0xDD14.MenuIsOpen then return end
local _0x53FF = _0xD1D6.fireClick
if not _0x8C4E and _0x53FF then
pcall(_0x53FF)
return
end
local _0x1DBF = _0x6FE4.Character
local _0xA5E9 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Tool")
if _0xA5E9 then pcall(function() _0xA5E9:Activate() end) end
end
_0x32C1(_0x2C20.RenderStepped:Connect(function()
local _0xC09B = _0x51CF
if not (_0xC248.VoidSpam and _0xC09B) then
_0x0DB4.Visible = false
return
end
_0x0DB4.Visible = true
if _0xC09B.phase =="attack"and _0xC09B.target then
_0x0DB4.Text ="Attacking  ".. tostring(_0xC09B.target.name)
else
local _0xEB3F = math.max(0, _0xC248.VoidInterval / 1000 - (os.clock() - _0xC09B.since))
_0x0DB4.Text = string.format("Roaming  %.1fs", _0xEB3F)
end
end))
local function _0xD143(_0xCF3D)
local _0xDF44 = workspace.FallenPartsDestroyHeight
local _0xD9BD = (_0xDF44 == _0xDF44 and _0xDF44 > -math.huge) and (_0xDF44 + 300) or -200
return math.max(_0xCF3D, _0xD9BD, -150)
endlocal function _0xB689(_0xC09B)
if _0xC248.RageMode =="Selected"then
local _0xCAC0 = _0xEDDA({ Position = _0xC09B.anchorPos })
if _0xCAC0 and _0xCAC0.root and _0xCAC0.root.Parent then return _0xCAC0.root.Position end
end
local _0x2BBD, _0x9059
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
local _0x75F5 = _0x5D5D.Character
local _0xAD48 = _0x75F5 and _0x75F5:FindFirstChild("HumanoidRootPart")
if _0xAD48 and _0x7DFD(_0x75F5) and _0x0047(_0x5D5D) then
local _0x6727 = (_0xAD48.Position - _0xC09B.anchorPos).Magnitude
if not _0x9059 or _0x6727 < _0x9059 then
_0x2BBD, _0x9059 = _0xAD48.Position, _0x6727
end
end
end
end
return _0x2BBD or _0xC09B.anchorPos
end
local function _0x0343(_0xC09B)
local _0xE7D7 = _0xB689(_0xC09B)
local _0x82B5 = math.random() * math.pi * 2
local _0x6727 = _0xC248.VoidDistance
return Vector3.new(_0xE7D7.X + math.cos(_0x82B5) * _0x6727, _0xD143(_0xE7D7.Y), _0xE7D7.Z + math.sin(_0x82B5) * _0x6727)
end
local function _0x7DB3(_0xC09B, phase)
_0xC09B.phase, _0xC09B.since = phase, os.clock()
_0xC09B.lastClick = nil
_0xC09B.preClicked = false
if phase =="void"then _0xC09B.voidPos, _0xC09B.hopAt = _0x0343(_0xC09B), os.clock() end
endlocal function _0x0D87(_0xC09B)
local _0x9777 = _0xC09B.hum
if _0x9777 and _0x9777.Parent and not _0x9777.PlatformStand then
_0x9777.PlatformStand = true
endif not _0xC09B.guarded and _0x9777 and _0x9777.Parent then
_0xC09B.guarded = true
_0xC09B.neck = _0x9777.RequiresNeck
pcall(function() _0x9777.RequiresNeck = false end)
pcall(function() _0x9777:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
end
local _0x67E0 = os.clock()
if _0x67E0 - (_0xC09B.scanned or 0) > 0.4 then
_0xC09B.scanned = _0x67E0
_0xC09B.cc = _0xC09B.cc or {}
for _0xDCCD, _0x6727 in ipairs(_0xC09B.char:GetDescendants()) do
if _0x6727:IsA("BasePart") and _0x6727.CanCollide then
_0xC09B.cc[_0x6727] = true
_0x6727.CanCollide = false
end
end
end
end
local function _0xEDFD(_0xC09B)
pcall(function()
if _0xC09B.hum and _0xC09B.hum.Parent then _0xC09B.hum.PlatformStand = false end
end)
if _0xC09B.guarded then
pcall(function()
if _0xC09B.hum and _0xC09B.hum.Parent then
_0xC09B.hum.RequiresNeck = _0xC09B.neck
_0xC09B.hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
end
end)
_0xC09B.guarded = false
end
for _0x6727 in pairs(_0xC09B.cc or {}) do
pcall(function() if _0x6727.Parent then _0x6727.CanCollide = true end end)
end
_0xC09B.cc = nil
for _0xDCCD, _0x75F5 in ipairs(_0xC09B.conns or {}) do pcall(function() _0x75F5:Disconnect() end) end
_0xC09B.conns = nil
endlocal function _0x6EA3(_0xC09B)
_0xC09B.conns = {}
local _0x75A9 = _0xC09B.hum.Health
_0xC09B.conns[1] = _0xC09B.hum.HealthChanged:Connect(function(_0xCF21)
if _0xCF21 < _0x75A9 and _0x51CF == _0xC09B then
local _0xCAC0 = _0xC09B.target and (", target ".. tostring(_0xC09B.target.name)) or""warn(string.format("[OUL void] health %.0f -> %.0f during '%s' (y=%.0f, dist from origin=%.0f, kill height %s%s)",
_0x75A9, _0xCF21, tostring(_0xC09B.phase), _0xC09B.root.Position.Y, _0xC09B.root.Position.Magnitude,
tostring(workspace.FallenPartsDestroyHeight), _0xCAC0))
if _0xCF21 <= 0 and _0x9996 then _0x9996("Void Spam: died during ".. tostring(_0xC09B.phase)) end
end
_0x75A9 = _0xCF21
end)
endlocal function _0xDBD6(_0x523E)
local _0xB100 = _0x523E.CFrame
local _0x6727 = _0xC248.AttackHeight
local _0xBD75 = Vector3.new(0, _0x6727, 0)
if _0xC248.VoidBehind then
local _0x0DD5 = _0xB100.LookVector
local _0x35BC = Vector3.new(_0x0DD5.X, 0, _0x0DD5.Z)
if _0x35BC.Magnitude > 0.01 then _0xBD75 = -_0x35BC.Unit * _0x6727 end
elseif _0xC248.VoidBelow then
_0xBD75 = Vector3.new(0, -_0x6727, 0)
end
return CFrame.new(_0xB100.Position + _0xBD75) * (_0xB100 - _0xB100.Position)
end
local function _0x2908(_0x80EB, _0xB100)
_0x80EB.CFrame = _0xB100
_0x80EB.AssemblyLinearVelocity = Vector3.zero
_0x80EB.AssemblyAngularVelocity = Vector3.zero
end
local function _0x9F6F()
local _0xC09B = _0x51CF
if not _0xC09B then return end
_0x51CF = nil
pcall(function()if _0xC09B.phase =="void"and _0xC09B.root and _0xC09B.root.Parent and _0xC09B.anchorCF then
_0x2908(_0xC09B.root, _0xC09B.anchorCF + Vector3.new(0, 3, 0))
end
end)
_0xEDFD(_0xC09B)
_0x254A("Target: none")
end
_0xD1D6.voidSpamRestore = _0x9F6Flocal function _0xC736(_0xCAC0)
if not (_0xCAC0 and _0xCAC0.plr and _0xCAC0.plr.Parent == _0x8325) then return false end
local _0x75F5 = _0xCAC0.plr.Character
local _0xAD48 = _0x75F5 and _0x75F5:FindFirstChild("HumanoidRootPart")
return _0xAD48 ~= nil and _0xAD48 == _0xCAC0.root and _0x7DFD(_0x75F5) and _0x0047(_0xCAC0.plr)
end
local function _0xBDCF(_0xC09B)
if _0xC248.RageMode =="Selected"thenlocal _0xCAC0, _0x6297 = _0xEDDA({ Position = _0xC09B.anchorPos })
if not _0xCAC0 then return nil, _0x6297 end
if not _0x0047(_0xCAC0.plr) then return nil, _0xCAC0.name .." (team)"end
return _0xCAC0
endif not _0xC248.VoidLowestHP and _0xC736(_0xC09B.target) then return _0xC09B.target end
_0xC09B.target = nil
local _0x2BBD, _0x9059, _0xF221
for _0xDCCD, _0x5D5D in ipairs(_0x8325:GetPlayers()) do
if _0x5D5D ~= _0x6FE4 then
local _0x75F5 = _0x5D5D.Character
local _0xAD48 = _0x75F5 and _0x75F5:FindFirstChild("HumanoidRootPart")
if _0xAD48 and _0x7DFD(_0x75F5) and _0x0047(_0x5D5D) then
local _0x6727 = (_0xAD48.Position - _0xC09B.anchorPos).Magnitude
local _0x5DE5 = _0xC248.VoidLowestHP and _0x3F0C(_0x75F5) or 0
if not _0x9059 or _0x5DE5 < _0xF221 or (_0x5DE5 == _0xF221 and _0x6727 < _0x9059) then
_0x2BBD, _0x9059, _0xF221 = { _0x80EB = _0xAD48, _0xBF13 = _0x5D5D.Name, _0x5D5D = _0x5D5D }, _0x6727, _0x5DE5
end
end
end
end
if not _0x2BBD then return nil,"no target"end
return _0x2BBD
end
_0x32C1(_0x2C20.Stepped:Connect(function()
if not _0xC248.VoidSpam then
if _0x51CF then _0x9F6F() end
return
end
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if not (_0x9777 and _0x80EB and _0x9777.Health > 0) then
if _0x51CF then _0xEDFD(_0x51CF) end
_0x51CF = nilreturn
end
if _0x51CF and (_0x51CF.root ~= _0x80EB or _0x51CF.char ~= _0x1DBF) then
_0xEDFD(_0x51CF)
_0x51CF = nil
end
if not _0x51CF then
_0x51CF = { _0x80EB = _0x80EB, _0x1DBF = _0x1DBF, _0x9777 = _0x9777, anchorCF = _0x80EB.CFrame, anchorPos = _0x80EB.Position }
_0x6EA3(_0x51CF)
_0x7DB3(_0x51CF,"void")
end
local _0xC09B = _0x51CF
local _0x67E0 = os.clock()
_0x0D87(_0xC09B)if _0xC248.VoidAutoAttack and _0xC09B.phase =="void"and not _0xC09B.preClicked
and _0x67E0 - _0xC09B.since >= _0xC248.VoidInterval / 1000 - 0.05 then
_0xC09B.preClicked = true
if _0xBDCF(_0xC09B) then _0x93C9() end
endif _0xC09B.phase =="void"and _0x67E0 - _0xC09B.since >= _0xC248.VoidInterval / 1000 then
local _0xCAC0, _0x6297 = _0xBDCF(_0xC09B)
if _0xCAC0 then
_0xC09B.target, _0xC09B.why = _0xCAC0, nil
_0x7DB3(_0xC09B,"attack")
else
_0xC09B.why = _0x6297 or"no target"_0x7DB3(_0xC09B,"void")end
end
if _0xC09B.phase =="attack"then
local _0xCAC0 = _0xC09B.target
if not _0xC736(_0xCAC0) then
_0xC09B.target = nil_0x7DB3(_0xC09B,"void")
elseif _0x67E0 - _0xC09B.since >= _0xC248.AttackInterval / 1000 then
_0x7DB3(_0xC09B,"void")
elselocal _0x523E = _0xCAC0.root
_0xC09B.anchorCF, _0xC09B.anchorPos = _0xDBD6(_0x523E), _0x523E.Position
_0x2908(_0x80EB, _0xC09B.anchorCF)
if _0xC248.VoidAutoAttack and _0x67E0 - (_0xC09B.lastClick or 0) >= 0.12 then
_0xC09B.lastClick = _0x67E0
_0x93C9()
end
_0x254A("Target: ".. _0xCAC0.name)
return
end
endif _0xC248.VoidRoam and _0x67E0 - (_0xC09B.hopAt or 0) >= _0xC248.VoidRoamMs / 1000 then
_0xC09B.voidPos, _0xC09B.hopAt = _0x0343(_0xC09B), _0x67E0
end
_0x2908(_0x80EB, CFrame.new(_0xC09B.voidPos))
_0x254A("Void spam: ".. (_0xC09B.why or"in void"))
end))_0x32C1(_0x2C20.Heartbeat:Connect(function()
local _0xC09B = _0x51CF
if not _0xC09B or not _0xC248.VoidSpam then return end
local _0x80EB = _0xC09B.root
if not (_0x80EB and _0x80EB.Parent) then return end
if _0xC09B.phase =="void"then
_0x2908(_0x80EB, CFrame.new(_0xC09B.voidPos))
elseif _0xC09B.phase =="attack"and _0xC736(_0xC09B.target) then
_0x2908(_0x80EB, _0xDBD6(_0xC09B.target.root))
end
end))
endlocal _0x5CBF, _0x3EB2
do
local _0xF4A3 = nil
local function _0x1F76()
pcall(function()
if type(sethiddenproperty) =="function"then
sethiddenproperty(_0x6FE4,"SimulationRadius", math.huge)
end
end)
pcall(function()
if type(setsimulationradius) =="function"then
setsimulationradius(math.huge, math.huge)
end
end)
pcall(function()
_0x6FE4.MaximumSimulationRadius = math.huge
end)
end
local function _0x6180(_0xC09B, ease)
local _0x80EB = _0xC09B.root
local _0xCAC0 = os.clock()
local _0xDE50 = _0xCAC0 * _0xC09B.speed * 0.5
local _0xEBCD = _0x80EB.Position
local _0xB46E = math.max(_0xC09B.orbitCount, 1)
local _0x4320 = { [_0x80EB] = _0x80EB.CFrame }
for _0xDCCD, j in ipairs(_0xC09B.joints) do
local _0x5EA5 = j.p0
if _0x5EA5.Parent and j.part.Parent then
local _0xAD48 = (_0x4320[_0x5EA5] or _0x5EA5.CFrame) * j.c0 * j.c1:Inverse()
_0x4320[j.part] = _0xAD48
local _0xB100 = _0xAD48
if not j.head then
local _0x6003 = j.slot
local _0x434E = (_0x6003 - 0.5) / _0xB46E
local _0xD919 = math.acos(1 - 2 * _0x434E)
local _0x2C41 = _0x6003 * 2.399963
local _0x7018 = Vector3.new(math.sin(_0xD919) * math.cos(_0x2C41), math.cos(_0xD919), math.sin(_0xD919) * math.sin(_0x2C41))
local _0x5CB5 = CFrame.Angles(_0xDE50 * 0.6, _0xDE50, _0xDE50 * 0.35)local _0xCCFE = 5 + _0xC09B.radius * (0.5 + 0.5 * math.sin(_0xCAC0 * _0xC09B.speed * (0.12 + (_0x6003 % 4) * 0.035) + _0x6003 * 1.7))
local _0x6BF8 = _0xEBCD + _0x5CB5:VectorToWorldSpace(_0x7018) * _0xCCFE
local _0x5C68 = CFrame.new(_0x6BF8) * CFrame.Angles(_0xCAC0 * 2 + _0x6003, _0xCAC0 * 1.3 + _0x6003 * 0.6, _0xCAC0 * 1.7)
_0xB100 = _0xAD48:Lerp(_0x5C68, ease)
end
j.part.CFrame = _0xB100
j.part.AssemblyLinearVelocity = Vector3.zero
j.part.AssemblyAngularVelocity = Vector3.zero
end
end
end
local function _0x5E42(skipRebuild)
local _0xC09B = _0xF4A3
if not _0xC09B then return end
_0xF4A3 = nil
for _0xDCCD, _0x75F5 in ipairs(_0xC09B.ncc or {}) do
pcall(function() _0x75F5:Destroy() end)
end
if skipRebuild then return end
pcall(_0x6180, _0xC09B, 0)
for _0xDCCD, j in ipairs(_0xC09B.joints) do
pcall(function()
if j.part.Parent and j.p0.Parent then
j.part.CanCollide = j.canCollide
j.part.AssemblyLinearVelocity = Vector3.zero
local _0x752D = Instance.new("Motor6D")
_0x752D.Name = j.name
_0x752D.C0 = j.c0
_0x752D.C1 = j.c1
_0x752D.Part0 = j.p0
_0x752D.Part1 = j.part
_0x752D.Parent = j.parent
end
end)
end
pcall(function()
if _0xC09B.hum and _0xC09B.requiresNeck ~= nil then
_0xC09B.hum.RequiresNeck = _0xC09B.requiresNeck
end
end)
pcall(function()
if _0xC09B.cam and _0xC09B.hum then _0xC09B.cam.CameraSubject = _0xC09B.hum end
end)
end
function _0x5CBF()
_0x5E42(false)
end
local function _0x8014(_0x1DBF, _0x9777, _0x80EB)
local _0xC09B = {
_0x1DBF = _0x1DBF, _0x9777 = _0x9777, _0x80EB = _0x80EB,
_0x8A92 = {}, orbitCount = 0, blend = 0,
speed = _0xC248.VortexSpeed, radius = _0xC248.VortexRadius,
requiresNeck = _0x9777.RequiresNeck, lastClaim = 0,
}
local _0x0812 = {}
for _0xDCCD, _0x752D in ipairs(_0x1DBF:GetDescendants()) do
if _0x752D:IsA("Motor6D") and _0x752D.Name ~="Neck"and _0x752D.Part0 and _0x752D.Part1 and _0x752D.Part1:IsDescendantOf(_0x1DBF) then
_0x0812[#_0x0812 + 1] = _0x752D
end
end
local _0x6018, _0x5A13, _0x7C85 = { [_0x80EB] = true }, {}, 0
local _0xDE71 = true
while _0xDE71 do
_0xDE71 = false
for _0xDCCD, _0x752D in ipairs(_0x0812) do
if not _0x5A13[_0x752D] and _0x6018[_0x752D.Part0] and not _0x6018[_0x752D.Part1] then
_0x5A13[_0x752D], _0x6018[_0x752D.Part1] = true, true
_0xDE71 = true
local _0x8ED8 = _0x752D.Part1.Name =="Head"if not _0x8ED8 then _0x7C85 += 1 end
_0xC09B.joints[#_0xC09B.joints + 1] = {
motor = _0x752D, _0xBF13 = _0x752D.Name, parent = _0x752D.Parent,
_0x5EA5 = _0x752D.Part0, _0xB1E8 = _0x752D.Part1, c0 = _0x752D.C0, _0xE4E6 = _0x752D.C1,
canCollide = _0x752D.Part1.CanCollide, _0x9C99 = _0x8ED8, _0x7C85 = _0x7C85,
}
end
end
end
_0xC09B.orbitCount = _0x7C85
_0x9777.RequiresNeck = false
_0x1F76()
_0xC09B.ncc = {}
for _0xDCCD, j in ipairs(_0xC09B.joints) do
pcall(function() j.motor:Destroy() end)
j.part.CanCollide = false
pcall(function()
local _0x75F5 = Instance.new("NoCollisionConstraint")
_0x75F5.Name ="OULVortexNC"_0x75F5.Part0 = _0x80EB
_0x75F5.Part1 = j.part
_0x75F5.Parent = _0x80EB
_0xC09B.ncc[#_0xC09B.ncc + 1] = _0x75F5
end)
end
pcall(function()
_0xC09B.cam = workspace.CurrentCamera
_0xC09B.cam.CameraSubject = _0x80EB
end)
return _0xC09B
end
_0x32C1(_0x2C20.Stepped:Connect(function()
local _0xC09B = _0xF4A3
if _0xC09B and _0xC09B.root.Parent then _0x6180(_0xC09B, _0xC09B.blend * _0xC09B.blend * (3 - 2 * _0xC09B.blend)) end
end))
_0x32C1(_0x2C20.Heartbeat:Connect(function()
local _0xC09B = _0xF4A3
if _0xC09B and _0xC09B.root.Parent then
_0x6180(_0xC09B, _0xC09B.blend * _0xC09B.blend * (3 - 2 * _0xC09B.blend))
local _0x67E0 = os.clock()
if _0x67E0 - _0xC09B.lastClaim > 1 then
_0xC09B.lastClaim = _0x67E0
_0x1F76()
end
end
end))
task.spawn(function()
_0x3EB2 = game:GetService("ReplicatedStorage"):WaitForChild("OULVortexEvent", 5)
end)
local _0xDB34 = { _0xD32A = false, speed = nil, radius = nil, at = 0 }
local function _0xD9D4()
if not _0x3EB2 then return end
local _0xD32A = (not _0xDCFD and _0xE870 and _0xC248.FlyVortex) and true or false
local _0xC566, _0xCCFE = _0xC248.VortexSpeed, _0xC248.VortexRadius
local _0x5581 = _0xD32A ~= _0xDB34.want
local _0xA5B3 = _0xD32A and (_0xC566 ~= _0xDB34.speed or _0xCCFE ~= _0xDB34.radius)
and os.clock() - _0xDB34.at >= 0.1
if _0x5581 or _0xA5B3 then
_0xDB34 = { _0xD32A = _0xD32A, speed = _0xC566, radius = _0xCCFE, at = os.clock() }
_0x3EB2:FireServer(_0xD32A, _0xC566, _0xCCFE)
end
end
local _0x93DD
local function _0xDF7E(dt)
local _0x7A42 = game:GetService("ReplicatedStorage"):GetAttribute("OULVortexServerSide") == true
local _0xD32A = (not _0xDCFD) and (not _0x7A42) and _0xE870 and _0xC248.FlyVortex
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = (_0x9777 and _0x9777.RootPart) or (_0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart"))
local _0xC09B = _0xF4A3
if _0xC09B and (_0xC09B.char ~= _0x1DBF or not _0x80EB or _0xC09B.root ~= _0x80EB) then
_0x5E42(true)
_0xC09B = nil
end
if _0xD32A and _0x9777 and _0x80EB and _0x9777.Health > 0 then
if not _0xC09B then
_0xC09B = _0x8014(_0x1DBF, _0x9777, _0x80EB)
_0xF4A3 = _0xC09B
end
_0xC09B.speed, _0xC09B.radius = _0xC248.VortexSpeed, _0xC248.VortexRadius
_0xC09B.blend = math.min(1, _0xC09B.blend + dt / 0.5)
elseif _0xC09B then
_0xC09B.blend = math.max(0, _0xC09B.blend - dt / 0.5)
if _0xC09B.blend <= 0 then
_0x5E42(false)
_0xC09B = nil
end
end
if _0xB423 then
local _0xD635
if _0xDCFD then
_0xD635 ="disabled"elseif _0x7A42 then
_0xD635 = _0xC248.FlyVortex and"on (server-side)"or"off"elseif not _0xC248.FlyVortex then
_0xD635 ="off"elseif not (_0x9777 and _0x80EB) then
_0xD635 ="waiting for character"elseif _0xC09B and _0xC09B.orbitCount == 0 then
_0xD635 ="no joints found"elseif _0xC09B then
_0xD635 ="on, ".. _0xC09B.orbitCount .." parts (executor)"else
_0xD635 ="starting"end
_0xB423.Text ="Vortex: ".. _0xD635
_0x7C18.Text = (_0x3EB2 and _0x7A42) and"Server: ok (all see it)"or"Server: none (executor)"end
_0xD9D4()
end
_0x32C1(_0x2C20.RenderStepped:Connect(function(dt)
local _0x499B, _0xABB0 = pcall(_0xDF7E, dt)
if not _0x499B then
if _0xABB0 ~= _0x93DD then
_0x93DD = _0xABB0
warn("[OUL vortex] ".. tostring(_0xABB0))
end
if _0xB423 then
_0xB423.Text ="Vortex: error (see Output)"end
end
end))
end
local function _0xFC15()
pcall(function() _0xD27F.Enabled = false end)
pcall(function() _0x6EEE.Size = 0 end)
local _0x94C5 = shared.OULCleanup
shared.OULCleanup = nil
if _0x94C5 then pcall(_0x94C5) end
pcall(function() _0xD27F:Destroy() end)
pcall(function() _0x6EEE:Destroy() end)
pcall(function() _0x6B8C:Destroy() end)
end
_0x32C1(_0x85F6.InputBegan:Connect(function(_0x862B, processed)
if _0xCB3D then
local _0x051B = _0xCB3D
local _0x91A4
if _0x862B.UserInputType == Enum.UserInputType.Keyboard then
if _0x862B.KeyCode == Enum.KeyCode.Escape then
_0xCB3D = nil
_0xB6C3()
return
elseif _0x862B.KeyCode == Enum.KeyCode.Backspace or _0x862B.KeyCode == Enum.KeyCode.Delete then
if _0x051B.kind =="menu"or _0x051B.kind =="panic"then
_0x9996("This key can't be cleared")
return
end
_0x91A4 = false
elseif _0x862B.KeyCode ~= Enum.KeyCode.Unknown then
_0x91A4 = _0x862B.KeyCode
else
return
end
elseif _0x862B.UserInputType == Enum.UserInputType.MouseButton1
or _0x862B.UserInputType == Enum.UserInputType.MouseButton2
or _0x862B.UserInputType == Enum.UserInputType.MouseButton3 then
_0x91A4 = _0x862B.UserInputType
else
return
end
if _0x91A4 then
for _0xDCCD, _0x1191 in ipairs(_0x9490) do
if _0x1191 ~= _0x051B and _0x1191.kind =="panic"and _0x1191.input == _0x91A4 then
_0x9996("That key is the panic key")
return
end
end
for _0xDCCD, _0x1191 in ipairs(_0x9490) do
if _0x1191 ~= _0x051B and _0x1191.input == _0x91A4 then
_0x1191.input = nil
end
end
end
_0x051B.input = _0x91A4 or nil
_0xD1D6.bindJustSet = os.clock()
_0xC248.Holding = false
_0xCB3D = nil
_0xB6C3()
_0xBB85()
_0x9996(_0x051B.label .."  ->  ".. _0x8406(_0x051B.input))
return
end
local _0x5009 = _0xACF9("panic")
if _0x5009 and _0x5009.input and _0x470B(_0x862B, _0x5009.input) then
_0xFC15()
return
end
if processed then return end
for _0xDCCD, _0x051B in ipairs(_0x9490) dolocal _0x56BB = _0x051B.input and _0x051B.input.EnumType == Enum.UserInputType and _0x8C4E and _0x051B.kind ~="menu"if _0x051B.input and not _0x56BB and _0x470B(_0x862B, _0x051B.input) then
if _0x051B.kind =="toggle"then
local _0xCAC0 = _0xE515[_0x051B.key]
if _0xCAC0 then _0xCAC0.toggle() end
elseif _0x051B.kind =="menu"then
_0x6FF4(not _0x8C4E)
elseif _0x051B.kind =="hold"then
if _0xC248.AimMode =="Toggle"then
_0xC248.Holding = not _0xC248.Holding
if _0x0E49 then _0x0E49("Aim lock", _0xC248.Holding) end
else
_0xC248.Holding = true
end
elseif _0x051B.kind =="press"then
_0xC860()
end
end
end
end))
do
local _0x91A2 = 1.0
local _0xCACC = math.rad(25)
local _0x52E6 = 0
local _0x0507 = nil
local _0x0E5A = false
local _0xF01C = nil
_0x32C1(_0x85F6.InputEnded:Connect(function(_0x862B)
if _0xC248.AimMode ~="Toggle"and _0x470B(_0x862B, _0xACF9("aim").input) then
if _0x0E5A then
_0x52E6 = os.clock()
_0x0507 = workspace.CurrentCamera.CFrame
end
_0xC248.Holding = false
end
end))
_0x2C20:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
_0x7C80 = workspace.CurrentCamera
local _0x752D = _0x85F6:GetMouseLocation()
_0x839A.Position = UDim2.fromOffset(_0x752D.X, _0x752D.Y)
_0x839A.Visible = _0xC248.Enabled and _0xC248.ShowFOV and not _0xC248.IgnoreFOV
if _0x0507 and not _0xC248.Holding then
if os.clock() - _0x52E6 > _0x91A2 then
_0x0507 = nil
else
local _0x30A5 = _0x7C80.CFrame
local _0x43A1 = math.acos(math.clamp(_0x30A5.LookVector:Dot(_0x0507.LookVector), -1, 1))
local _0x63AA = _0x85F6:GetMouseDelta().Magnitude
if _0x43A1 > _0xCACC and _0x63AA < 2 then
_0x7C80.CFrame = CFrame.new(_0x30A5.Position) * (_0x0507 - _0x0507.Position)
else
_0x0507 = _0x30A5
end
end
end
local _0xB621 = _0x85F6.MouseBehavior == Enum.MouseBehavior.LockCenter
local _0x2A98 = _0x0E5A
_0x0E5A = _0xC248.Enabled and _0xC248.Holding and _0xB621 and not _0x8C4E
if _0x2A98 and not _0x0E5A and _0xC248.AimMode =="Toggle"then
_0x52E6 = os.clock()
_0x0507 = _0x7C80.CFrame
end
if not _0x0E5A then
_0xF01C = nil
return
end
if _0xF01C then
local _0x114D = _0xF01C:FindFirstAncestorOfClass("Model")
local _0x22A0 = _0xF01C.Parent ~= nil and _0x114D ~= nil and _0x7DFD(_0x114D)
if _0x22A0 then
local _0xDCCD, _0x8C46 = _0x7C80:WorldToViewportPoint(_0xF01C.Position)
if not _0x8C46 or not _0x3D05(_0xF01C, _0x114D) then
_0x22A0 = false
end
end
if not _0x22A0 then
_0xF01C = nil
end
end
if not _0xF01C then
_0xF01C = _0x44BC()
if not _0xF01C then return end
end
local _0xA729 = _0xF01C
local _0xEE39 = (_0xC248.Strength >= 500) and 1 or (1 - math.exp(-_0xC248.Strength * dt))
local _0xB2DC = _0xA729.Position
if _0xC248.Prediction then
local _0xF524 = _0xA729:FindFirstAncestorOfClass("Model")
local _0x523E = _0xF524 and _0xF524:FindFirstChild("HumanoidRootPart")
if _0x523E then
local _0x803E = _0x523E.AssemblyLinearVelocity
_0xB2DC = _0xB2DC + Vector3.new(_0x803E.X, 0, _0x803E.Z) * (_0xC248.PredictionMs / 1000)
end
endif _0xC248.MouseAim and type(mousemoverel) =="function"then
local _0xC566, _0x7EA2 = _0x7C80:WorldToViewportPoint(_0xB2DC)
if _0x7EA2 then
local _0x6F78 = _0x7C80.ViewportSize
local _0x36D7 = _0xC248.MouseGain / 100
local _0xFF96 = (_0xC566.X - _0x6F78.X / 2) * _0xEE39 * _0x36D7
local _0xEAC6 = (_0xC566.Y - _0x6F78.Y / 2) * _0xEE39 * _0x36D7_0xFF96, _0xEAC6 = _0xFF96 + (_0xD1D6.mouseRemX or 0), _0xEAC6 + (_0xD1D6.mouseRemY or 0)
local _0xB961, _0x2275 = math.floor(_0xFF96 + 0.5), math.floor(_0xEAC6 + 0.5)
_0xD1D6.mouseRemX, _0xD1D6.mouseRemY = _0xFF96 - _0xB961, _0xEAC6 - _0x2275
if _0xB961 ~= 0 or _0x2275 ~= 0 then
pcall(mousemoverel, _0xB961, _0x2275)
end
return
end
end
local _0x51FF = CFrame.lookAt(_0x7C80.CFrame.Position, _0xB2DC)
_0x7C80.CFrame = _0x7C80.CFrame:Lerp(_0x51FF, _0xEE39)
end)
end
local function _0x3FD1()
pcall(_0x3159.destroy)
_0xE870 = false
_0xC248.Enabled = false
_0xC248.Holding = false
_0xC248.Fullbright = false
_0xC248.NoFog = false
_0xC248.Radar = false
_0xC248.Triggerbot = false
_0xC248.Ragebot = false
_0xC248.RageOrbit = false
_0xC248.VoidSpam = false
pcall(function()
if _0xD1D6.voidSpamRestore then _0xD1D6.voidSpamRestore() end
end)
_0xC248.ESP = false
_0xC248.Chams = false
_0xC248.ShowNames = false
_0xC248.Tracers = false
_0xC248.ESPHealth = false
_0xC248.Fly = false
_0xC248.FlyVortex = false
_0xC248.Noclip = false
_0xC248.Speed = false
_0xC248.InfiniteJump = false
_0xCB3D = nil
pcall(function()
if _0xC5C0 and _0xC5C0.Parent then _0xC5C0.WalkSpeed = _0xE88A end
end)
pcall(_0x3E4E)
pcall(_0x16AC)
pcall(function()
if _0xD1D6.radarCleanup then _0xD1D6.radarCleanup() end
end)
pcall(function()
if _0xD1D6.skyRestore then _0xD1D6.skyRestore(true) end
end)
pcall(_0x5CBF)
pcall(function()
if _0x3EB2 then
_0x3EB2:FireServer(false, _0xC248.VortexSpeed, _0xC248.VortexRadius)
end
end)
pcall(function()
local _0x1DBF = _0x6FE4.Character
local _0x9777 = _0x1DBF and _0x1DBF:FindFirstChildOfClass("Humanoid")
local _0x80EB = _0x1DBF and _0x1DBF:FindFirstChild("HumanoidRootPart")
if _0x9777 and _0x3C12 then _0x9777.PlatformStand = false end
if _0x80EB and _0x3C12 then _0x80EB.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
end)
for _0xDCCD, _0x8AD1 in ipairs(_0x8700) do
pcall(function() _0x8AD1:Disconnect() end)
end
table.clear(_0x8700)
pcall(function() _0x2C20:UnbindFromRenderStep("Aimbot") end)
pcall(function() _0x2C20:UnbindFromRenderStep("OULMenuMouse") end)
pcall(function()
if _0x8C4E and _0x8ED5 then
_0x85F6.MouseBehavior = _0x8ED5
_0x85F6.MouseIconEnabled = _0x7612
end
end)
for _0x5D5D, _0xCF21 in pairs(_0xD435) do
pcall(function() _0xCF21:Destroy() end)
_0xD435[_0x5D5D] = nil
end
for _0x5D5D, _0xCAC0 in pairs(_0xD62F) do
pcall(function() _0xCAC0:Destroy() end)
_0xD62F[_0x5D5D] = nil
end
for _0x5D5D, _0x7238 in pairs(_0xA935) do
pcall(function() _0x7238:Destroy() end)
_0xA935[_0x5D5D] = nil
end
for _0x5D5D, _0x051B in pairs(_0x5C88) do
pcall(function() _0x051B:Destroy() end)
_0x5C88[_0x5D5D] = nil
end
_0xC248.Boxes = false
_0xC248.Skeleton = false
pcall(function() _0x6B8C:Destroy() end)
pcall(function() _0xD27F:Destroy() end)
pcall(function() _0x6EEE:Destroy() end)
end
shared.OULCleanup = _0x3FD1
_0x3159.finish()
