if not game:IsLoaded() then
	game.Loaded:Wait()
end

if game.CreatorType ~= Enum.CreatorType.Group then
	return end
if game.CreatorId ~= 5212858 then
	return end


-- clear old
if shared.SC_UI then
	shared.SC_UI:Destroy()
end
if shared.SC_charAdd then
	shared.SC_charAdd:Disconnect()
end
if shared.SC_backpackAdd then
	shared.SC_backpackAdd:Disconnect()
end
if shared.SC_tools then
	for i,c in pairs(shared.SC_tools) do
		pcall(function() shared.SC_tools[i]:Disconnect() end)
	end
end
shared.SC_tools = {}

-- services
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")

-- vars
local player = players.LocalPlayer
local character = player.Character
while not character do
	task.wait(.1)
	character = player.Character
end
local backpack = player:WaitForChild("Backpack", math.huge) or player.Backpack:Wait()

local lastSpell
local registered = {}

local mantraStars = {
	-- flamecharm
	-- combat
	["Fire Blade"] = 0,
	["Flame Repulsion"] = 0,
	["Burning Servants"] = 0,
	["Fire Gun"] = 0,
	["Flame Grab"] = 0,
	["Flame Blind"] = 0,
	["Fire Palm"] = 1,
	["Fire Eruption"] = 1,
	["Fire Forge"] = 1,
	["Rising Flame"] = 2,
	["Flame Assault"] = 2,
	["Ash Slam"] = 3,
	-- mobility
	["Flame Leap"] = 2,
	-- support
	["Flame of Denial"] = 0,
	["Graceful Flame"] = 1,
	["Flame Wisp"] = 2,
	
	-- thundercall
	-- combat
	["Lightning Blade"] = 0,
	["Jolt Grab"] = 0,
	["Electro Carve"] = 0,
	["Lightning Beam"] = 0,
	["Lightning Impact"] = 1,
	["Lightning Clones"] = 1,
	["Lightning Strike"] = 1,
	["Thunder Kick"] = 1,
	["Storm Blades"] = 1,
	["Grand Javelin"] = 2,
	["Bolt Piercer"] = 2,
	["Rising Thunder"] = 3,
	-- mobility
	["Lightning Assault"] = 2,
	["Lightning Cloak"] = 3,
	-- support
	["Lightning Stream"] = 1,
	["Spark Swap"] = 3,
	
	-- frostdraw
	-- combat
	["Ice Spikes"] = 0,
	["Ice Beam"] = 0,
	["Frost Grab"] = 0,
	["Warden's Blades"] = 0,
	["Frozen Servants"] = 0,
	["Ice Daggers"] = 1,
	["Ice Blade"] = 1,
	["Ice Chain"] = 1,
	["Ice Eruption"] = 1,
	["Ice Forge"] = 1,
	["Ice Smash"] = 1,
	["Ice Lance"] = 2,
	["Ice Fissure"] = 3,
	-- mobility
	["Glacial Arc"] = 1,
	["Ice Skate"] = 3,
	-- support
	["Iceberg"] = 3,
	
	-- galebreathe
	["Wind Blade"] = 0,
	["Air Force"] = 0,
	["Tornado Kick"] = 0,
	["Gale Lunge"] = 1,
	["Tornado"] = 1,
	["Heavenly Wind"] = 1,
	["Galetrap"] = 1,
	["Gale Punch"] = 1,
	["Champion's Whirlthrow"] = 2,
	["Rising Wind"] = 2,
	["Wind Gun"] = 2,
	["Wind Carve"] = 2,
	["Astral Wind"] = 3,
	-- mobility
	-- support
	["Gale Wisp"] = 2,
	
	-- shadowcast
	-- combat
	["Dark Blade"] = 0,
	["Shadow Gun"] = 0,
	["Clutching Shadow"] = 0,
	["Shadow Chains"] = 1,
	["Shadow Eruption"] = 1,
	["Shadow Seekers"] = 1,
	["Encircle"] = 1,
	["Shadow Roar"] = 2,
	["Rising Shadow"] = 2,
	["Shadow Meteors"] = 2,
	["Shade Bringer"] = 3,
	["Eclipse Kick"] = 3,
	["Shadow Vortex"] = 3,
	-- mobility
	["Shadow Assault"] = 2,
	-- support
	["Shade Devour"] = 1,
	
	-- attunement-less
	-- strength
	["Strong Left"] = 0,
	["Rapid Punches"] = 1,
	["Strong Leap"] = 0,
	["Tacet Drop Kick"] = 0,
	-- fortitude
	["Rally"] = 0,
	["Reinforce"] = 0,
	["Brace"] = 0,
	["Shoulder Bash"] = 0,
	-- agility
	["Revenge"] = 0,
	["Dash"] = 0,
	["Adrenaline Surge"] = 0,
	-- intelligence
	["Summon Cauldron"] = 0,
	["Prediction"] = 0,
	-- willpower
	["Gaze"] = 0,
	["Glare"] = 0,
	["Exhaustion Strike"] = 0,
	-- charisma
	["Taunt"] = 0,
	["Sing"] = 0,
	["Disguise"] = 0,
	-- weapon: light
	["Rapid Slashes"] = 0,
	-- weapon: medium
	["Master's Flourish"] = 0,
	["Prominence Draw"] = 0,
	-- weapon: heavy
	["Pressure Blast"] = 0,
	["Punishment"] = 0,
	
	-- monster
	["Enforcer Pull"] = 2,
	["Beast Burrow"] = 2,
	["Coral Spear"] = 2,
	["Dread Breath"] = 2,
	["Brachial Spear"] = 2,
	["Mecha Gatling"] = 2,
	
	-- oath
	-- blindseer
	["Mindsoothe"] = 0,
	["Tranquil Circle"] = 0,
	["Sightless Beam"] = 0,
	-- visionshaper
	["Illusory Servants"] = 0,
	["Illusionary Realm"] = 0,
	["Illusionary Counter"] = 0,
	-- linkstrider
	["Symbiotic Sustain"] = 0,
	["Parasitic Leech"] = 0,
	-- starkindred
	["Ascension"] = 0,
	["Celestial Assault"] = 0,
	["Sinister Halo"] = 0,
	-- arcwarder
	["Arc Suit"] = 0,
	["Arc Beam"] = 0,
	["Arc Wave"] = 0,
	-- dawnwalker
	["Blinding Dawn"] = 3,
	["Radiant Kick"] = 3,
	-- contractor
	["Judgement"] = 0,
	["Lords Slice"] = 0,
	["Equalizer"] = 0,
}
local elementColors = {
	Wind = Color3.fromRGB(0,255,0),
	Ice = Color3.fromRGB(0,255,255),
	Shadow = Color3.fromRGB(10,10,10),
	Fire = Color3.fromRGB(255,80,0),
	Lightning = Color3.fromRGB(255,255,0),
	Radiant = Color3.fromRGB(255,255,255)
}
local customTypes = {
	Dash = "Mobility",
	Reinforce = "Fortitude",
	Taunt = "Charismatic",
	["Exhaustion Strike"] = "Willpower",
	["Rapid Slashes"] = "Weapon Art",
	["StrongPunch"] = "Destructive",
	["Master's Flourish"] = "Weapon Art",
	QuickDraw = "Weapon Art"
}
local customNames = {
	["Tacet Drop Kick"] = {Type = "Tacet", Name = "Drop Kick"}
}
local touhouTypes = {
	["Asteroid Belt"] = {Type = "Magic Space", Name = nil},
	["Master Spark"] = {Type = "Love Sign", Name = "Master Spark Frozen"},
	["Luminous Strike"] = {Type = "Light Sign", Name = nil},
	["Stream Laser"] = {Type = "Light Sign", Name = nil},
	["Stardust Reverie"] = {Type = "Magic Sign", Name = nil},
	["Blazing Star"] = {Type = "Comet", Name = nil},
	["Earthlight Ray"] = {Type = "Light Sign", Name = nil},
	["Starlight Typhoon"] = {Type = "Love Storm", Name = nil}
}

-- ui
local screenGui = Instance.new("ScreenGui")
syn.protect_gui(screenGui)
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
shared.SC_UI = screenGui

local function newSpellSign(text, element, stars)
	local mainFrame = Instance.new("Frame")
	local line = Instance.new("Frame")
	local line2 = Instance.new("Frame")
	local line3 = Instance.new("Frame")
	local gradient = Instance.new("UIGradient")
	local gradient2
	local gradient3
	local gradientImage = Instance.new("UIGradient")
	local gradientImage2
	local gradientImage3
	local gradientText = Instance.new("UIGradient")
	local imageLabel = Instance.new("ImageLabel")
	local imageLabel2 = Instance.new("ImageLabel")
	local imageLabel3 = Instance.new("ImageLabel")
	local textLabel = Instance.new("TextLabel")
	local scale = Instance.new("UIScale")

	mainFrame.Parent = screenGui
	mainFrame.BackgroundTransparency = 1
	mainFrame.AnchorPoint = Vector2.new(1,0)
	mainFrame.Position = UDim2.new(0.55, 0, 0.7, 0) -- mid pos UDim2.new(0.95, 0, 0.7, 0), final pos UDim2.new(0.95, 0, 0.15, 0)
	mainFrame.Size = UDim2.new(0, 500, 0, 50)

	scale.Parent = mainFrame
	scale.Scale = 1.7

	line.Parent = mainFrame
	line.BorderSizePixel = 0
	line.Position = UDim2.new(0, 0, 1, 0)
	line.Size = UDim2.new(1, 0, 0, -4)
	line.ZIndex = 3

	line2.Parent = line
	line2.BackgroundTransparency = 0.5
	line2.BorderSizePixel = 0
	line2.Position = UDim2.new(0, 20, 1, 4)
	line2.Size = UDim2.new(1, -40, 0, -3)
	line2.ZIndex = 3

	line3.Parent = line2
	line3.BackgroundTransparency = 0.8
	line3.BorderSizePixel = 0
	line3.Position = UDim2.new(0, 40, 1, 3)
	line3.Size = UDim2.new(1, -80, 0, -2)
	line3.ZIndex = 3

	gradient.Parent = line
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(0.121, Color3.fromRGB(255, 73, 73)),
		ColorSequenceKeypoint.new(0.294, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.751, Color3.fromRGB(208, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.975),
		NumberSequenceKeypoint.new(0.16, 0.244),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.707, 0.525),
		NumberSequenceKeypoint.new(1, 1)
	}

	gradient2 = gradient:Clone()
	gradient2.Parent = line2

	gradient3 = gradient:Clone()
	gradient3.Parent = line3
	
	gradientImage.Parent = imageLabel
	gradientImage.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.0363, Color3.fromRGB(255, 51, 51)),
		ColorSequenceKeypoint.new(0.138, Color3.fromRGB(255, 169, 169)),
		ColorSequenceKeypoint.new(0.232, Color3.fromRGB(255, 208, 208)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}
	gradientImage.Rotation = -90
	
	gradientImage2 = gradientImage:Clone()
	gradientImage2.Parent = imageLabel2
	
	gradientImage3 = gradientImage:Clone()
	gradientImage3.Parent = imageLabel3
	
	gradientText.Parent = textLabel
	gradientText.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.0363, Color3.fromRGB(255, 83, 83)),
		ColorSequenceKeypoint.new(0.138, Color3.fromRGB(255, 234, 234)),
		ColorSequenceKeypoint.new(0.232, Color3.fromRGB(255, 215, 215)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}
	gradientText.Rotation = -90

	imageLabel.Parent = mainFrame
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = stars > 1 and UDim2.new(0, -85, 1, -60) or UDim2.new(0, -115, 1, -90)
	imageLabel.Size = stars > 1 and UDim2.new(0, 80, 0, 80) or UDim2.new(0, 140, 0, 140)
	imageLabel.Image = "rbxassetid://5304862649"
	if stars > 1 then
		imageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
	else
		imageLabel.ImageColor3 = elementColors[element] or Color3.fromRGB(255,255,255)
	end
	imageLabel.ImageTransparency = stars > 0 and 0.2 or 1
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.ZIndex = 3

	imageLabel2.Parent = mainFrame
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Position = UDim2.new(0, -115, 1, -90)
	imageLabel2.Size = UDim2.new(0, 140, 0, 140)
	imageLabel2.Image = "rbxassetid://5304862649"
	imageLabel2.ImageColor3 = elementColors[element] or Color3.fromRGB(255,255,255)
	imageLabel2.ImageTransparency = stars > 2 and .5 or 1
	imageLabel2.ScaleType = Enum.ScaleType.Crop

	imageLabel3.Parent = mainFrame
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Position = UDim2.new(0, -145, 1, -120)
	imageLabel3.Size = UDim2.new(0, 200, 0, 200)
	imageLabel3.Image = "rbxassetid://5304862649"
	imageLabel3.ImageColor3 = elementColors[element] or Color3.fromRGB(255,255,255)
	imageLabel3.ImageTransparency = stars > 1 and .8 or 1
	imageLabel3.ScaleType = Enum.ScaleType.Crop

	textLabel.Parent = mainFrame
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 20, 0, 0)
	textLabel.Size = UDim2.new(1, -20, 1, -4)
	textLabel.RichText = true
	textLabel.Font = Enum.Font.SpecialElite
	textLabel.Text = '<i>'..text..'</i>'
	textLabel.TextColor3 = Color3.fromRGB(255,255,255)
	textLabel.TextSize = 28
	textLabel.TextStrokeTransparency = 0
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	textLabel.ZIndex = 3

	return {
		mainFrame = mainFrame,
		textLabel = textLabel,
		line = line,
		line2 = line2,
		line3 = line3,
		imageLabel = imageLabel,
		imageLabel2 = imageLabel2,
		imageLabel3 = imageLabel3,
		scale = scale,
		gradientImage = gradientImage,
		gradientImage2 = gradientImage2,
		gradientImage3 = gradientImage3
	}
end

local function fadeIn(spell)
	local tweenInfoMid = TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoFinal = TweenInfo.new(.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoScale = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	
	local midTween = tweenService:Create(spell.mainFrame, tweenInfoMid, {Position = UDim2.new(0.95, 0, 0.7, 0)})
	local finalTween = tweenService:Create(spell.mainFrame, tweenInfoFinal, {Position = UDim2.new(0.95, 0, 0.15, 0)})
	local scaleTween = tweenService:Create(spell.scale, tweenInfoScale, {Scale = 1})
	
	midTween.Completed:Connect(function(playbackState)
		task.wait(.05)
		finalTween:Play()
	end)
	
	midTween:Play()
	scaleTween:Play()
end

local function fadeOut(spell)
	local tweenInfoScaleExit = TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoImageColor = TweenInfo.new(.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoFade = TweenInfo.new(.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoExit = TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	
	local scaleExitTween = tweenService:Create(spell.scale, tweenInfoScaleExit, {Scale = 1.2})
	
	local imageColorTween = tweenService:Create(spell.imageLabel, tweenInfoImageColor, {ImageColor3 = Color3.fromRGB(0,0,0)})
	local image2ColorTween = tweenService:Create(spell.imageLabel2, tweenInfoImageColor, {ImageColor3 = Color3.fromRGB(0,0,0)})
	local image3ColorTween = tweenService:Create(spell.imageLabel3, tweenInfoImageColor, {ImageColor3 = Color3.fromRGB(0,0,0)})
	
	local fadeTweenImage = tweenService:Create(spell.imageLabel, tweenInfoFade, {ImageTransparency = 1})
	local fadeTweenImage2 = tweenService:Create(spell.imageLabel2, tweenInfoFade, {ImageTransparency = 1})
	local fadeTweenImage3 = tweenService:Create(spell.imageLabel3, tweenInfoFade, {ImageTransparency = 1})
	
	local fadeTweenText = tweenService:Create(spell.textLabel, tweenInfoFade, {TextTransparency = 1, TextStrokeTransparency = 1})
	
	local fadeTweenLine = tweenService:Create(spell.line, tweenInfoFade, {BackgroundTransparency = 1})
	local fadeTweenLine2 = tweenService:Create(spell.line2, tweenInfoFade, {BackgroundTransparency = 1})
	local fadeTweenLine3 = tweenService:Create(spell.line3, tweenInfoFade, {BackgroundTransparency = 1})
	
	local exitTween = tweenService:Create(spell.mainFrame, tweenInfoExit, {Position = UDim2.new(0.95, 0, 0.2, 0)})
	
	
	fadeTweenLine.Completed:Connect(function(playbackState)
		task.wait(.1)
		spell.mainFrame:Destroy()
	end)
	
	scaleExitTween:Play()
	
	imageColorTween:Play()
	image2ColorTween:Play()
	image3ColorTween:Play()

	fadeTweenImage:Play()
	fadeTweenImage2:Play()
	fadeTweenImage3:Play()

	fadeTweenText:Play()

	fadeTweenLine:Play()
	fadeTweenLine2:Play()
	fadeTweenLine3:Play()

	exitTween:Play()
end

local function newMove(move)
	-- fade out last ui
	if lastSpell then
		task.spawn(fadeOut, lastSpell)
	end

	local ui = newSpellSign(move.Custom and move.Type..' "'..move.Name..'"' or move.Type..' Sign "'..move.Name..'"', move.Type, move.Stars)
	lastSpell = ui

	local fadingOut = false

	-- spin
	task.spawn(function()
		local increment = 100
		local con
		con = runService.Heartbeat:Connect(function(deltaTime)
			if not ui.imageLabel or not ui.imageLabel2 or not ui.imageLabel3 then
				con:Disconnect()
				return
			end

			ui.imageLabel.Rotation = ui.imageLabel.Rotation + increment * deltaTime
			ui.gradientImage.Rotation = -90 - ui.imageLabel.Rotation
			
			ui.imageLabel2.Rotation = -ui.imageLabel.Rotation - increment * deltaTime
			ui.gradientImage2.Rotation = -90 - ui.imageLabel2.Rotation
			
			ui.imageLabel3.Rotation = ui.imageLabel.Rotation + increment * deltaTime
			ui.gradientImage3.Rotation = -90 - ui.imageLabel3.Rotation
		end)
	end)
	-- special types
	task.spawn(function()
		if move.Type == "Radiant" then
			local t = .6
			local r = math.random() * t
			local tweenInfoRadiant = TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			while not fadingOut and ui.imageLabel2 do
				local hue = (tick()+r) % t / t
				local color = Color3.fromHSV(hue, 1, 1)
				local colorTween = tweenService:Create(ui.imageLabel2, tweenInfoRadiant, {ImageColor3 = color})
				local color2Tween = tweenService:Create(ui.imageLabel3, tweenInfoRadiant, {ImageColor3 = color})
				colorTween:Play()
				color2Tween:Play()
				task.wait()
			end
		elseif move.Type == "Tacet" then
			local tweenInfoMurmur = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			while not fadingOut and ui.imageLabel2 do
				local transparency = ui.imageLabel2.ImageTransparency == 0.5 and .98 or 0.5
				local murmurTween = tweenService:Create(ui.imageLabel2, tweenInfoMurmur, {ImageTransparency = transparency})
				local murmur2Tween = tweenService:Create(ui.imageLabel3, tweenInfoMurmur, {ImageTransparency = transparency})
				murmurTween:Play()
				murmur2Tween:Play()
				task.wait(.4)
			end
		end
	end)

	-- spawn in
	task.spawn(fadeIn, ui)

	task.wait(3)
	if lastSpell ~= ui then
		return
	end

	-- fade out
	fadingOut = true
	task.spawn(fadeOut, ui)
end


local function checkTool(tool)
	if tool.ClassName == "Tool" and tool:FindFirstChild("MantraType") or tool.ClassName == "Tool" and tool:FindFirstChild("Element") then
		if not registered[tool.Name] then
			registered[tool.Name] = tool

			local Type = tool:FindFirstChild("Element") and tool:FindFirstChild("Element").Value or tool:FindFirstChild("MantraType").Value
			local custom = false
			if customTypes[Type] then
				Type = customTypes[Type]
				custom = true
			end
			local stars = mantraStars[tool:FindFirstChild("DefaultName").Value] and mantraStars[tool:FindFirstChild("DefaultName").Value] or 0

			local con
			con = tool.Equipped:Connect(function()
				local str = tool.Name
				local start_idx = string.find(str, "{{") + 2
				local end_idx = string.find(str, "}}") - 1
				local final_str = string.sub(str, start_idx, end_idx)
				
				if customNames[tool:FindFirstChild("DefaultName").Value] then
					Type = customNames[tool:FindFirstChild("DefaultName").Value].Type
					final_str = customNames[tool:FindFirstChild("DefaultName").Value].Name
					custom = true
				end
				if touhouTypes[final_str] then
					Type = touhouTypes[final_str].Type
					final_str = touhouTypes[final_str].Name and touhouTypes[final_str].Name or final_str
					custom = true
				end
				
				newMove({Type = Type, Name = final_str, Stars = stars, Custom = custom})
			end)
			shared.SC_tools[tool.Name] = con
		end
	end
end

local charAdd
charAdd = player.CharacterAdded:Connect(function()
	registered = {}
	backpack = player:WaitForChild("Backpack", math.huge) or player.Backpack:Wait()
	
	if shared.SC_backpackAdd then
		shared.SC_backpackAdd:Disconnect()
	end
	local backpackAdd
	backpackAdd = backpack.ChildAdded:Connect(checkTool)
	shared.SC_backpackAdd = backpackAdd
end)
shared.SC_charAdd = charAdd

for i,t in pairs(backpack:GetChildren()) do
	checkTool(t)
end
local backpackAdd
backpackAdd = backpack.ChildAdded:Connect(checkTool)
shared.SC_backpackAdd = backpackAdd
