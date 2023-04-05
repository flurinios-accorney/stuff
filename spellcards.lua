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

-- ui
local screenGui = Instance.new("ScreenGui")
syn.protect_gui(screenGui)
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
shared.SC_UI = screenGui


local function newSpellSign(text, element)
	local mainFrame = Instance.new("Frame")
	local line = Instance.new("Frame")
	local gradient = Instance.new("UIGradient")
	local imageLabel = Instance.new("ImageLabel")
	local imageLabel2 = Instance.new("ImageLabel")
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

	imageLabel.Parent = mainFrame
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.new(0, -85, 1, -60)
	imageLabel.Size = UDim2.new(0, 80, 0, 80)
	imageLabel.Image = "rbxassetid://5304862649"
	imageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
	imageLabel.ImageTransparency = 0.2
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.ZIndex = 2
	
	imageLabel2.Parent = mainFrame
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Position = UDim2.new(0, -100, 1, -75)
	imageLabel2.Size = UDim2.new(0, 110, 0, 110)
	imageLabel2.Image = "rbxassetid://5304862649"
	imageLabel2.ImageColor3 = elementColors[element] or Color3.fromRGB(255,255,255)
	imageLabel2.ImageTransparency = .5
	imageLabel2.ScaleType = Enum.ScaleType.Crop

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

	return {
		mainFrame = mainFrame,
		textLabel = textLabel,
		line = line,
		imageLabel = imageLabel,
		imageLabel2 = imageLabel2,
		scale = scale
	}
end

local function newMove(move)
	if lastSpell then
		lastSpell.mainFrame:Destroy()
	end

	local ui = newSpellSign(move.Custom and move.Type..' "'..move.Name..'"' or move.Type..' Sign "'..move.Name..'"', move.Type)
	lastSpell = ui
	
	local tweenInfoScale = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tweenInfoScaleExit = TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	local tweenInfoImageColor = TweenInfo.new(.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	local tweenInfoMid = TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoFinal = TweenInfo.new(.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoExit = TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoSpin = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenInfoFade = TweenInfo.new(.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

	local fadeTweenPlaying = false

	task.spawn(function()
		local tweenInfoSpin = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		while ui.imageLabel and ui.imageLabel2 do
			local spinTween = tweenService:Create(ui.imageLabel, tweenInfoSpin, {Rotation = ui.imageLabel.Rotation + 20})
			local spin2Tween = tweenService:Create(ui.imageLabel2, tweenInfoSpin, {Rotation = -ui.imageLabel.Rotation - 20})
			spinTween:Play()
			spin2Tween:Play()
			task.wait(.23)
		end
	end)
	task.spawn(function()
		if move.Type == "Radiant" then
			local t = .6
			local r = math.random() * t
			local tweenInfoRadiant = TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			while not fadeTweenPlaying and ui.imageLabel2 do
				local hue = (tick()+r) % t / t
				local color = Color3.fromHSV(hue, 1, 1)
				local colorTween = tweenService:Create(ui.imageLabel2, tweenInfoRadiant, {ImageColor3 = color})
				colorTween:Play()
				task.wait()
			end
		elseif move.Type == "Tacet" then
			local tweenInfoMurmur = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			while not fadeTweenPlaying and ui.imageLabel2 do
				local transparency = ui.imageLabel2.ImageTransparency == 0 and .95 or 0
				local murmurTween = tweenService:Create(ui.imageLabel2, tweenInfoMurmur, {ImageTransparency = transparency})
				murmurTween:Play()
				task.wait(.4)
			end
		end
	end)
	
	local scaleTween = tweenService:Create(ui.scale, tweenInfoScale, {Scale = 1})
	local scaleExitTween = tweenService:Create(ui.scale, tweenInfoScaleExit, {Scale = 1.2})
	
	local imageColorTween = tweenService:Create(ui.imageLabel, tweenInfoImageColor, {ImageColor3 = Color3.fromRGB(0,0,0)})
	local image2ColorTween = tweenService:Create(ui.imageLabel2, tweenInfoImageColor, {ImageColor3 = Color3.fromRGB(0,0,0)})
	
	local midTween = tweenService:Create(ui.mainFrame, tweenInfoMid, {Position = UDim2.new(0.95, 0, 0.7, 0)})
	local finalTween = tweenService:Create(ui.mainFrame, tweenInfoFinal, {Position = UDim2.new(0.95, 0, 0.15, 0)})
	local exitTween = tweenService:Create(ui.mainFrame, tweenInfoExit, {Position = UDim2.new(0.95, 0, 0.2, 0)})

	local fadeTweenImage = tweenService:Create(ui.imageLabel, tweenInfoFade, {ImageTransparency = 1})
	local fadeTweenImage2 = tweenService:Create(ui.imageLabel2, tweenInfoFade, {ImageTransparency = 1})
	local fadeTweenText = tweenService:Create(ui.textLabel, tweenInfoFade, {TextTransparency = 1, TextStrokeTransparency = 1})
	local fadeTweenLine = tweenService:Create(ui.line, tweenInfoFade, {BackgroundTransparency = 1})

	midTween.Completed:Connect(function(playbackState)
		task.wait(.05)
		finalTween:Play()
	end)
	fadeTweenLine.Completed:Connect(function(playbackState)
		task.wait(.1)
		ui.mainFrame:Destroy()
	end)
	
	midTween:Play()
	scaleTween:Play()

	task.wait(3)
	fadeTweenPlaying = true
	scaleExitTween:Play()
	imageColorTween:Play()
	image2ColorTween:Play()
	fadeTweenImage:Play()
	fadeTweenImage2:Play()
	fadeTweenText:Play()
	fadeTweenLine:Play()
	exitTween:Play()
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

			local con
			con = tool.Equipped:Connect(function()
				local str = tool.Name
				local start_idx = string.find(str, "{{") + 2
				local end_idx = string.find(str, "}}") - 1
				local final_str = string.sub(str, start_idx, end_idx)
				
				if customNames[final_str] then
					Type = customNames[final_str].Type
					final_str = customNames[final_str].Name
				end
				
				newMove({Type = Type, Name = final_str, Custom = custom})
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
