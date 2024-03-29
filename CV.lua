if not game:IsLoaded() then
	game.Loaded:Wait()
end

if game.CreatorType ~= Enum.CreatorType.Group then
	return end
if game.CreatorId ~= 5212858 then
	return end


-- libs
local Library = loadstring(game:HttpGet('https://gist.githubusercontent.com/flurinios-accorney/ab48b0a316294adcb235374031af4c50/raw/linoraui.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://gist.githubusercontent.com/flurinios-accorney/23cffd623d3d73bbc0d70a3204862b9a/raw/linorathememanager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://gist.githubusercontent.com/flurinios-accorney/c58d7836d55e6ae5ef1f62108c29bff8/raw/linorasavemanager.lua'))()

-- services
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")
local debris = game:GetService("Debris")

-- player
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", math.huge)

-- vars
local ver = 'v0.11.1'

local messageCache = {}
local activeMessages = {}
local LastRefresh = 0
local lastCheckedChance = 0

local keywords = {
	"clip","hack","exploit",
	"fly","flew","record",
	"nofall","script"
}

local combat
local ambient
local special

local lastTimePos = {ambient = 0, combat = 0, special = 0}

local ambientsReference = {
	forest = 7143662033,
	snow = 8295196681,
	siege = 9863526644,
	sanctuaryinside = 9360784208,
	--castle = 11435572663,
	layer2 = 9558324744,
	erisia = 7632923661,
	lava = 10576406481,
	kyrsa = 12115948047,
	kyrsatrain = 12115948047,
	kyrsalibrary = 12115948047,
	sanctuaryoutside = 10511015615,
	depths = 4657617399,
	sailing = 4649072374,
	cave = 4745345282,
	specialcave = 4745345282,
	mountain = 4863842872,
	jungle = 6022579794,
	desert = 8207455512,
	temple = 5019613268,
	manor = 5990454765,
	manor_lab = 6066767800,
	chaser = 6066767800,
	hive = 6246012947,
	summer = 6668751588,
	town = 6970325515,
	ferryman = 5995252439,
	primadon = 6435543635,
	fragment = 6677358684,
	voidsea = 7085013640,
	duke = 9334052363
}
local ambients = {
	duke = {
		ambient = {
			volume = 0.9
		},
		combat = {
			volume = 0.9,
			begin = 11
		}
	},
	forest = {
		ambient = {
			volume = 0.55
		},
		combat = {
			volume = 0.55
		}
	},
	snow = {
		ambient = {},
		combat = {}
	},
	siege = {
		ambient = {}
	},
	sanctuaryinside = {
		ambient = {
			volume = 0.1
		},
		combat = {}
	},
	layer2 = {
		ambient = {},
		combat = {
			volume = 1.2
		}
	},
	erisia = {
		ambient = {},
		combat = {}
	},
	lava = {
		ambient = {},
		combat = {}
	},
	kyrsa = {
		ambient = {},
		combat = {
			volume = 1.2
		}
	},
	kyrsatrain = {
		ambient = {},
		combat = {
			volume = 1.2
		}
	},
	kyrsalibrary = {
		ambient = {},
		combat = {
			volume = 1.2
		}
	},
	sanctuaryoutside = {
		ambient = {},
		combat = {
			volume = 1.2
		}
	},
	depths = {
		ambient = {
			volume = 1.5
		},
		combat = {
			volume = 0.6
		},
		special = {
			chance = 10,
			volume = 1.5
		}
	},
	sailing = {
		ambient = {},
		combat = {}
	},
	cave = {
		ambient = {
			volume = 0.6
		},
		combat = {}
	},
	specialcave = {
		ambient = {
			volume = 0.6
		},
		combat = {}
	},
	mountain = {
		ambient = {
			volume = 0.75
		},
		combat = {}
	},
	jungle = {
		ambient = {
			volume = 0.8
		},
		combat = {
			volume = 0.75
		}
	},
	desert = {
		ambient = {
			volume = 0.5
		},
		combat = {
			volume = 0.55
		}
	},
	temple = {
		ambient = {
			volume = 0.6
		},
		combat = {
			volume = 0.6
		}
	},
	manor = {
		ambient = {}
	},
	manor_lab = {
		ambient = {}
	},
	chaser = {
		ambient = {
			volume = 1
		},
		combat = {
			volume = 1
		}
	},
	hive = {
		ambient = {
			volume = 0.5
		},
		combat = {
			volume = 0.5
		}
	},
	summer = {
		ambient = {},
		combat = {
			volume = 0.45
		}
	},
	town = {
		ambient = {
			volume = 0.45
		}
	},
	ferryman = {
		ambient = {
			volume = 1
		},
		combat = {
			volume = 1
		}
	},
	primadon = {
		ambient = {
			volume = 0.7
		}
	},
	fragment = {
		ambient = {
			volume = 0.3
		}
	},
	voidsea = {
		ambient = {
			volume = 0.4
		}
	}
}

local nameColors = {
	Color3.fromRGB(253, 41, 67),
	Color3.fromRGB(1, 162, 255),
	Color3.fromRGB(2, 184, 87),
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color,
	BrickColor.new("Light yellow").Color,
	BrickColor.new("Pastel Blue").Color,
	BrickColor.new("Light orange brown").Color,
	BrickColor.new("Nougat").Color,
	BrickColor.new("Med. reddish violet").Color,
	BrickColor.new("Earth orange").Color,
	BrickColor.new("Dark green").Color,
	BrickColor.new("Lig. Yellowich orange").Color,
	BrickColor.new("Light bluish violet").Color,
	BrickColor.new("Tr. Red").Color,
	BrickColor.new("Tr. Lg blue").Color,
	BrickColor.new("Tr. Flu. Reddish orange").Color,
	BrickColor.new("Br. yellowish orange").Color,
	BrickColor.new("Bright bluish green").Color,
	BrickColor.new("Earth yellow").Color,
	BrickColor.new("Bright bluish violet").Color,
	BrickColor.new("Tr. Brown").Color,
	BrickColor.new("Tr. Medi. reddish violet").Color,
	BrickColor.new("Med. yellowish green").Color,
	BrickColor.new("Med. bluish green").Color,
	BrickColor.new("Gold").Color,
	BrickColor.new("Neon green").Color,
	BrickColor.new("Sand violet").Color,
	BrickColor.new("Tr. Flu. Blue").Color,
	BrickColor.new("Gun metallic").Color,
	BrickColor.new("Red flip/flop").Color,
	BrickColor.new("Curry").Color,
	BrickColor.new("Flame yellowish orange").Color,
	BrickColor.new("Lemon metalic").Color,
	BrickColor.new("Turquoise").Color,
	BrickColor.new("Rust").Color,
	BrickColor.new("Lilac").Color,
	BrickColor.new("Lapis").Color,
	BrickColor.new("Shamrock").Color,
	BrickColor.new("Mulberry").Color,
	BrickColor.new("Moss").Color,
	BrickColor.new("Sage green").Color,
	BrickColor.new("Plum").Color,
	BrickColor.new("Olivine").Color,
	BrickColor.new("Crimson").Color,
	BrickColor.new("Mint").Color,
	BrickColor.new("Carnation pink").Color,
	BrickColor.new("Persimmon").Color,
	BrickColor.new("Wheat").Color,
	BrickColor.new("Mauve").Color,
	BrickColor.new("Sunrise").Color,
	BrickColor.new("Khaki").Color,
	BrickColor.new("Burgundy").Color,
	BrickColor.new("Burlap").Color,
	BrickColor.new("Linen").Color,
	BrickColor.new("Copper").Color,
	BrickColor.new("Flint").Color,
	BrickColor.new("Hot pink").Color
}
local chatColors = {
	[3296052431] = Color3.fromRGB(215, 197, 154)
}
local color_offset = 0


-- clear old connections
if shared.CV_PlayerAddedCon then shared.CV_PlayerAddedCon:Disconnect() end
if shared.CV_PlayerRemovingCon then shared.CV_PlayerRemovingCon:Disconnect() end
if shared.CV_RenderSteppedCon then shared.CV_RenderSteppedCon:Disconnect() end
if shared.CV_ChatCon then
	for i,v in pairs(shared.CV_ChatCon) do
		shared.CV_ChatCon[i]:Disconnect()
	end
end
shared.CV_ChatCon = {}
--[[if shared.CV_CharCon then
	for i,v in pairs(shared.CV_CharCon) do
		shared.CV_CharCon[i]:Disconnect()
	end
end
shared.CV_CharCon = {}]]


-- tweening drawing api stuff
local function tweenDrawing(Render, RenderInfo, RenderTo, doCheck)
	local Start = {}
	local CurrentTime = 0
	
	for Index, Value in pairs(RenderTo) do
		local success = true
		if doCheck then
			-- check if render still exists
			success = pcall(function() Render.ZIndex = Render.ZIndex end)
		end
		
		if Render and success then
			Start[Index] = Render[Index]
			RenderTo[Index] = Value - Start[Index]
		end
	end
	
	local Connection
	Connection = runService.RenderStepped:Connect(function(Delta)
		if CurrentTime < RenderInfo.Time and Render then
			CurrentTime = CurrentTime + Delta
			
			local TweenedValue = tweenService:GetValue((CurrentTime / RenderInfo.Time), RenderInfo.EasingStyle, RenderInfo.EasingDirection)
			
			for Index, Value in pairs(RenderTo) do
				local success = true
				if doCheck then
					-- check if render still exists
					success = pcall(function() Render.ZIndex = Render.ZIndex end)
				end
				
				if Render and success then
					if typeof(Value) == "number" then
						Render[Index] = (Value * TweenedValue) + Start[Index]
					elseif typeof(Value) == "Vector2" then
						Render[Index] = Vector2.new((Value.X * TweenedValue) + Start[Index].X, (Value.Y * TweenedValue) + Start[Index].Y)
					elseif typeof(Value) == "function" then
						Render[Index] = Value(TweenedValue)
					end
				else
					Connection:Disconnect()
				end
			end
		else
			Connection:Disconnect()
		end
	end)
end


-- utils
local function downloadAudio(name)
	local Time = tick()
	local success, file = pcall(game.HttpGet, game, 'https://raw.githubusercontent.com/flurinios-accorney/stuff/main/'..name)
	if not success then
		Library:Notify("[ERROR] Failed to download audio ("..name..")", 7)
		return false
	end
	
	Time = tostring(tick() - Time)
	local succ, cess = pcall(writefile, "CustomMusic/"..name, file)
	if not succ then
		Library:Notify("[ERROR] Failed to write file audio ("..name..")", 7)
		return false
	end
	
	Library:Notify("[Done!] Audio ("..name..") is now downloaded. (Took "..string.sub(Time,1,4).." seconds)", 5)
	return true
end

local function getVersion()
	local success, file = pcall(game.HttpGet, game, 'https://raw.githubusercontent.com/flurinios-accorney/stuff/main/version.json')
	if not success then
		Library:Notify("[ERROR] Failed to download version", 7)
		return false, nil
	end
	return true, file
end

local function downloadVersion()
	local success, file = getVersion()
	if not success then
		return false
	end
	
	local succ, cess = pcall(writefile, "CustomMusic/Version.json", file)
	if not succ then
		Library:Notify("[ERROR] Failed to write file version", 7)
		return false
	end
	return true
end

local function preloadAmbients()
	if not isfolder("CustomMusic") then
		makefolder("CustomMusic")
	end
	
	Library:Notify("Checking for updates..", 3)
	local localVersion = isfile("CustomMusic/Version.json") and httpService:JSONDecode(readfile("CustomMusic/Version.json")).version or nil
	local succ, file = getVersion()
	if not succ then
		printconsole("Failed to download version",255,0,0)
		return
	end
	local cloudVersion = httpService:JSONDecode(file).version
	-- outdated
	if localVersion ~= cloudVersion then
		Library:Notify("[WARNING] Local version outdated, updating..", 7)
		
		local files = listfiles("CustomMusic")
		-- remove old files
		for i,v in pairs(files) do
			delfile(v)
		end
		
		-- update version file
		local succ = downloadVersion()
		if not succ then
			printconsole("Failed to download version",255,0,0)
			return
		end
	end
	
	Library:Notify("Preloading ambients..", 3)
	for i,v in pairs(ambients) do
		-- ambient
		local nameAmbient = i..".ambient.mp3"
				
		if not isfile("CustomMusic/"..nameAmbient) then
			local succ = downloadAudio(nameAmbient)
			if not succ then
				printconsole("Failed to download: "..nameAmbient,255,0,0)
				return
			end
		end
		
		v.ambient.id = getsynasset("CustomMusic/"..nameAmbient)
		
		if not v.ambient.volume then
			v.ambient.volume = .55
		end
		
		-- combat
		if v.combat then
			local nameCombat = i..".combat.mp3"
			
			if not isfile("CustomMusic/"..nameCombat) then
				local succ = downloadAudio(nameCombat)
				if not succ then
					printconsole("Failed to download: "..nameCombat,255,0,0)
					return
				end
			end
			
			v.combat.id = getsynasset("CustomMusic/"..nameCombat)
			
			if not v.combat.volume then
				v.combat.volume = .55
			end
		else
			v.combat = v.ambient
		end
		
		-- special
		if v.special then
			local nameSpecial = i..".special.mp3"
			
			if not isfile("CustomMusic/"..nameSpecial) then
				local succ = downloadAudio(nameSpecial)
				if not succ then
					printconsole("Failed to download: "..nameSpecial,255,0,0)
					return
				end
			end
			
			v.special.id = getsynasset("CustomMusic/"..nameSpecial)
			
			if not v.special.volume then
				v.special.volume = .55
			end
		end
	end
end

local function isInDanger()
	local statsGui = playerGui:WaitForChild("StatsGui", math.huge)
	local danger = statsGui:WaitForChild("Danger", math.huge)
	return danger.Visible
end

local function getChance(x)
	local valid = (os.clock() - lastCheckedChance) > 10
	if valid then
		lastCheckedChance = os.clock()
	end
	if math.random(1,100) < x and valid then
		return true
	end
	return false
end

local function getArea()
	local worldClient = playerGui:WaitForChild("WorldClient", math.huge)
	local tracks = worldClient:WaitForChild("Tracks", math.huge)
	local tracksAmbient = tracks:WaitForChild("Ambient", math.huge)
	
	for i,v in pairs(ambientsReference) do
		if v == tonumber(tracksAmbient.SoundId:sub(14,#tracksAmbient.SoundId)) then
			return i
		end
	end
end

local function getAmbient()
	local area = getArea()
	
	local song = ambients[area]
	if not song then
		return nil
	end
	
	return {ambient = song.ambient, combat = song.combat, special = song.special, name = area}
end

local function getNameValue(pName)
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

local function getNameColor(player)
	return nameColors[((getNameValue(player.Name) + color_offset) % #nameColors) + 1]
end

local function getChatColor(player)
	return chatColors[player.UserId]
end

local function getColor(player, msg, isName)
	if isName then
		return activeMessages[player.UserId].NameColor
	end
	if activeMessages[player.UserId].ChatColor then
		return activeMessages[player.UserId].ChatColor
	end
	
	if player.UserId == localPlayer.UserId then
		return Color3.fromRGB(255, 255, 0)
	end
	for i,v in pairs(keywords) do
		if string.lower(msg):match(v) then
			return Color3.fromRGB(255, 0, 0)
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

local function getTotalOldMessages()
	local oldMessages = 0
	for index,value in pairs(activeMessages) do
		table.foreach(value.OldInstances, function()
			oldMessages = oldMessages + 1
		end)
	end
	return oldMessages
end

local function getHigherMessages(instanceIndex)
	local messages = {}
	for index,value in pairs(activeMessages) do
		table.foreach(value.OldInstances, function(guid,instance)
			local thisIndex = instance.index
			if instanceIndex <= thisIndex then
				messages[#messages+1] = {guid = guid, instance = instance}
			end
		end)
	end
	return messages
end

local function getPlayerFrame(player, characterName)
	local leaderboard = playerGui:WaitForChild("LeaderboardGui", math.huge)
	local leaderboardFrame = leaderboard:WaitForChild("MainFrame", math.huge)
	local scrollingFrame = leaderboardFrame:WaitForChild("ScrollingFrame", math.huge)
	
	for _,frame in pairs(scrollingFrame:GetChildren()) do
		if frame.ClassName == "Frame" then
			if frame.Player.Text == characterName or frame.Player.Text == player.Name then
				return frame
			end
		end
	end
	return
end

local function rgbToInt(r,g,b)
	return (r * 0x10000) + (g * 0x100) + b
end

local function addToCache(player, characterName, msg, guid)
	local tbl = {
		Player = {
			Name = player.Name,
			UserId = player.UserId,
			CharName = characterName
		},
		Message = {
			Text = msg,
			GUID = guid
		},
		Timestamp = os.time()
	}
	
	-- cap messageCache to 100 messages
	if #messageCache+1 > 100 then
		table.remove(messageCache, 1)
	end
	table.insert(messageCache, tbl)
end

local function exportWithHook()
	if #messageCache < 1 then
		return false, "No messages saved"
	end
	
	local function sendHook(fields, page)
		local data = {
			["username"] = "Logs Export",
			["content"] = "",
			["embeds"] = {{
				["title"] = "***Saved Messages `Page #"..tostring(page).."`***",
				["description"] = "",
				["type"] = "rich",
				["color"] = rgbToInt(255, 225, 0),
				["fields"] = fields,
				["timestamp"] = DateTime.now():ToIsoDate()
			}}
		}
		
		local encoded = httpService:JSONEncode(data)
		local response = syn.request(
			{
				Url = Options.WebhookUrl.Value,
				Method = 'POST',
				Headers = {
					['Content-Type'] = 'application/json'
				},
				Body = encoded
			}
		)
		return response.Success, not response.Success and response.Body or ''
	end
	
	local fields = {}
	local page = 1
	for index,value in pairs(messageCache) do
		local dateNow = os.date('%c', value.Timestamp)
		local name = "[**"..value.Player.Name.."**]" .. " " .. "[**"..value.Player.CharName.."**]" .. " " .. "[**"..value.Player.UserId.."**]"
		local text = '**`[' .. dateNow .. ']:`** ' .. value.Message.Text
		
		local newTable = {
			["name"] = name,
			["value"] = text:sub(1,200),
			["inline"] = false
		}
		
		table.insert(fields, newTable)
		
		if #fields > 24 then
			local response, body = sendHook(fields, page)
			if not response then
				return false, body
			end
			
			fields = {}
			page = page + 1
		end
		if #messageCache == index and #fields > 0 then
			local response, body = sendHook(fields, page)
			if not response then
				return false, body
			end
		end
	end
	
	return true, ''
end

local function lowerAllOldMessages(removedIndex)
	for index,value in pairs(activeMessages) do
		table.foreach(value.OldInstances, function(guid,instance)
			local oldIndex = instance.index
			activeMessages[index].OldInstances[guid].index = removedIndex < oldIndex and oldIndex - 1 or oldIndex
		end)
	end
end

local function removeFromGroup(userId, group, guid)
	local index = activeMessages[userId][group][guid].index
	
	activeMessages[userId][group][guid].text.label1:Remove()
	activeMessages[userId][group][guid].text.label2:Remove()
	activeMessages[userId][group][guid] = nil
	
	if index then
		lowerAllOldMessages(index)
	end
end

local function clearMessage(player, group, guid)
	if not activeMessages[player.UserId] then
		return
	end
	
	-- delete specific message
	if guid then
		if not activeMessages[player.UserId][group][guid] then
			return
		end
		
		removeFromGroup(player.UserId, group, guid)
		return
	end
	-- delete all messages
	table.foreach(activeMessages[player.UserId][group], function(guid,instance)
		removeFromGroup(player.UserId, group, guid)
	end)
end

local function isClipped(uiObject, parent)
	local boundryTop = parent.AbsolutePosition
	local boundryBot = boundryTop + parent.AbsoluteSize
	
	local top = uiObject.AbsolutePosition
	local bot = top + uiObject.AbsoluteSize
	
	local function cmpVectors(a, b)
		return (a.X < b.X) or (a.Y < b.Y)
	end
	return cmpVectors(top, boundryTop) or cmpVectors(boundryBot, bot)
end

local function newText(player, textTable, frame, group, extra)
	local guid = httpService:GenerateGUID(false)
	
	if group == "Instances" then
		-- add to messageCache
		addToCache(player, extra.characterName, textTable.label2, guid)
	end
	
	local label1 = Drawing.new("Text")
	label1.Visible = false
	label1.ZIndex = 1
	label1.Transparency = .8
	if extra.color then
		label1.Color = extra.color.name and extra.color.name or getColor(player, textTable.label1, true)
	else
		label1.Color = getColor(player, textTable.lavel1, true)
	end
	label1.Text = textTable.label1
	label1.Size = extra.size and extra.size or Options.MessagesNearNameSize.Value
	label1.Center = false
	label1.Outline = true
	label1.OutlineColor = Color3.fromRGB(0, 0, 0)
	
	local label2 = Drawing.new("Text")
	label2.Visible = false
	label2.ZIndex = 1
	label2.Transparency = .8
	if extra.color then
		label2.Color = extra.color.text and extra.color.text or getColor(player, textTable.label2, false)
	else
		label2.Color = getColor(player, textTable.label2, false)
	end
	label2.Text = textTable.label2
	label2.Size = extra.size and extra.size or Options.MessagesNearNameSize.Value
	label2.Center = false
	label2.Outline = true
	label2.OutlineColor = Color3.fromRGB(0, 0, 0)
	
	activeMessages[player.UserId][group][guid] = {}
	activeMessages[player.UserId][group][guid].text = {label1 = label1, label2 = label2}
	activeMessages[player.UserId][group][guid].frame = frame
	activeMessages[player.UserId][group][guid].index = extra.index and extra.index or nil
	
	task.wait(extra.delay and extra.delay or 4)
	
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local tweenTable = {Transparency = 0}
	task.spawn(tweenDrawing, label1, tweenInfo, tweenTable, true)
	task.spawn(tweenDrawing, label2, tweenInfo, tweenTable, true)
	
	task.wait(5)
	
	-- delete message
	clearMessage(player, group, guid)
end


-- ui
local Window = Library:CreateWindow('Hub | '..ver)
--Window.Holder.Visible = true

local Tabs = {
	Main = Window:AddTab('Deepwoken'),
	['Settings'] = Window:AddTab('Settings')
}

local Sliders = Tabs.Main:AddRightGroupbox('Sliders')
local Toggles = Tabs.Main:AddLeftGroupbox('Toggles')
local Buttons = Tabs.Main:AddLeftGroupbox('Buttons')
local Webhooks = Tabs.Main:AddRightGroupbox('Webhooks')
local Ambients = Tabs.Main:AddLeftGroupbox('Ambients')

local ShowMessagesName = Toggles:AddToggle('MessagesNearName', {
	Text = 'Show messages near name',
	Default = true
})
local ShowOldMessages = Toggles:AddToggle('OldMessages', {
	Text = 'Show old messages',
	Default = true
})
local PlayCustomAmbient = Ambients:AddToggle('PlayCustomAmbient', {
	Text = 'Play custom ambients',
	Default = false
})
local OldMessagesLogaritmicSize = Toggles:AddToggle('OldMessagesLogaritmicSize', {
	Text = 'Use logaritm messages size',
	Default = false
})

local ClearMessages = Buttons:AddButton('Clear messages', function()
	SaveManager:Save('Default')
	for index,value in pairs(activeMessages) do
		local player = value.Player
		
		clearMessage(player, "Instances")
		clearMessage(player, "OldInstances")
	end
end)
local SendMessages = Webhooks:AddButton('Export messages', function()
	SaveManager:Save('Default')
	local success, body = exportWithHook()
	if not success then
		Library:Notify("[ERROR] Failed to export saved messages", 7)
		printconsole(body,225,225,0)
		return
	end
	Library:Notify("[Done!] Successfully exported saved messages", 5)
end)
local ClearCachedMessages = Webhooks:AddButton('Clear saved messages', function()
	SaveManager:Save('Default')
	messageCache = {}
end)

Webhooks:AddLabel('Export is capped at 100!')
local cachedLabel = Webhooks:AddLabel('Currently: 0 logged')

Webhooks:AddInput('WebhookUrl', {
    Default = '',
    Text = 'Webhook',
    Placeholder = 'https://'
})

Sliders:AddSlider('MessagesNearNameSize', {
    Text = 'New messages size',
    Default = 21,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Compact = false
})
Sliders:AddSlider('OldMessagesSize', {
    Text = 'Old messages size',
    Default = 18,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Compact = false
})
Sliders:AddSlider('RefreshRate', {
    Text = 'Refresh rate (ms)',
    Default = 15,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Compact = false
})
Ambients:AddSlider('AmbientVolume', {
    Text = 'Custom ambient volume',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true
})

PlayCustomAmbient:OnChanged(function()
	SaveManager:Save('Default')
end)
ShowMessagesName:OnChanged(function()
	if not ShowMessagesName.Value and ShowOldMessages.Value then
		ShowOldMessages:SetValue(false)
	end
	
	SaveManager:Save('Default')
end)
ShowOldMessages:OnChanged(function()
	if not ShowMessagesName.Value and ShowOldMessages.Value then
		ShowOldMessages:SetValue(false)
	end
	
	SaveManager:Save('Default')
end)
OldMessagesLogaritmicSize:OnChanged(function()
	SaveManager:Save('Default')
end)
Options.MessagesNearNameSize:OnChanged(function()
	SaveManager:Save('Default')
end)
Options.OldMessagesSize:OnChanged(function()
	SaveManager:Save('Default')
end)
Options.RefreshRate:OnChanged(function()
	SaveManager:Save('Default')
end)
Options.AmbientVolume:OnChanged(function()
	SaveManager:Save('Default')
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

--SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('ChatVisualizer')
SaveManager:SetFolder('ChatVisualizer/Deepwoken')

SaveManager:BuildConfigSection(Tabs['Settings'])
ThemeManager:ApplyToTab(Tabs['Settings'])

SaveManager:Load('Default')


-- update loop
local function updateCurrentInstance(player, guid, instance)
	local frame = instance.frame
	if not frame then
		-- delete message
		clearMessage(player, "Instances", guid)
		return
	end
	
	if not ShowMessagesName.Value then
		activeMessages[player.UserId].Instances[guid].text.label2.Visible = false
		return
	end
	
	local parent = frame.Parent
	if not parent then
		activeMessages[player.UserId].Instances[guid].text.label2.Visible = false
		return
	end
	
	if isClipped(frame, parent) then
		activeMessages[player.UserId].Instances[guid].text.label2.Visible = false
		return
	end
	
	local canvasHeadache = parent.CanvasPosition.Y / parent.AbsoluteCanvasSize.Y
	local YabsolutePos = frame.AbsolutePosition.Y + canvasHeadache - parent.AbsolutePosition.Y
	local Yoffset = frame.AbsoluteSize.Y / 2
	local Xoffset = -25 + instance.text.label2.TextBounds.X
	
	local X = frame.AbsolutePosition.X - Xoffset
	local Y = YabsolutePos + Yoffset
	local pos = Vector2.new(X, Y)
	
	activeMessages[player.UserId].Instances[guid].text.label2.Position = pos
	activeMessages[player.UserId].Instances[guid].text.label2.Visible = true
end

local function updateOldInstance(player, guid, instance)
	local leaderboard = playerGui:WaitForChild("LeaderboardGui", math.huge)
	
	local frame = instance.frame
	if not frame then
		-- delete message
		clearMessage(player, "OldInstances", guid)
		return
	end
	
	local instanceIndex = activeMessages[player.UserId].OldInstances[guid].index
	local messages = getHigherMessages(instanceIndex)
	
	local indexOffset = 0
	table.foreach(messages, function(index,value)
		indexOffset = indexOffset + (value.instance.text.label1.TextBounds.Y + 1)
	end)
	
	local YscreenSize = leaderboard.AbsoluteSize.Y
	local Yoffset = 30 + indexOffset
	local Xoffset = 100
	
	local Xname = Xoffset
	local Xmsg = Xoffset + instance.text.label1.TextBounds.X + 1
	local Y = YscreenSize - Yoffset
	local posName = Vector2.new(Xname, Y)
	local posMsg = Vector2.new(Xmsg, Y)
	
	activeMessages[player.UserId].OldInstances[guid].text.label1.Position = posName
	activeMessages[player.UserId].OldInstances[guid].text.label2.Position = posMsg
	activeMessages[player.UserId].OldInstances[guid].text.label1.Visible = true
	activeMessages[player.UserId].OldInstances[guid].text.label2.Visible = true
end

local function updateMessages()
	cachedLabel.TextLabel.Text = 'Currently: ' .. #messageCache .. ' logged'
	
	for index,value in pairs(activeMessages) do
		local player = value.Player
		
		table.foreach(value.Instances, function(guid,instance)
			task.spawn(updateCurrentInstance, player, guid, instance)
		end)
		table.foreach(value.OldInstances, function(guid,instance)
			task.spawn(updateOldInstance, player, guid, instance)
		end)
	end
end

local function updateDistances()
	for index,value in pairs(activeMessages) do
		local player = value.Player
		
		local character = player.Character
		if not character then
			return
		end
		local rootPart = character:WaitForChild("HumanoidRootPart", math.huge)
		if not rootPart then
			return
		end
		
		local distance = (workspace.CurrentCamera.CFrame.p-rootPart.Position).Magnitude
		activeMessages[player.UserId].Distance = tostring(math.floor(distance))
	end
end

local function clearOldSound(sound)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	tweenService:Create(sound, tweenInfo, {Volume = 0}):Play()
	debris:AddItem(sound, 1)
end

local chaserStage2Triggered = false
local function updateAmbient()
	local area = getAmbient()
	if not area then
		return
	end
	if not area.ambient.id then
		return
	end
	
	if not localPlayer.Character then
		if combat then
			task.spawn(clearOldSound, combat)
			combat = nil
		end
		if ambient then
			task.spawn(clearOldSound, ambient)
			ambient = nil
		end
		if special then
			task.spawn(clearOldSound, special)
			special = nil
		end
		return
	end
	
	local isCombat = isInDanger()
	
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local shouldTweenWhat = -1
	
	local ferrymanHealth, ferrymanMaxHealth
	if area.name == "ferryman" then
		for i,c in pairs(workspace:WaitForChild("Live", math.huge):GetChildren()) do
			if c:FindFirstChild("FerrymanController") then
				ferrymanHealth = c:WaitForChild("Humanoid", math.huge).Health
				ferrymanMaxHealth = c:WaitForChild("Humanoid", math.huge).MaxHealth
			end
		end
	end
	local chaserHealth, chaserMaxHealth
	if area.name == "chaser" then
		for i,c in pairs(workspace:WaitForChild("Live", math.huge):GetChildren()) do
			if c:FindFirstChild("ChaserController") then
				chaserHealth = c:WaitForChild("Humanoid", math.huge).Health
				chaserMaxHealth = c:WaitForChild("Humanoid", math.huge).MaxHealth
			end
		end
	end
	
	-- new
	if not combat or combat.SoundId ~= area.combat.id and isCombat then
		if combat then
			task.spawn(clearOldSound, combat)
		end
		
		lastTimePos.combat = area.combat.begin and area.combat.begin or 0
		
		local newCombat = Instance.new("Sound")
		newCombat.Name = "Combat"
		newCombat.Looped = true
		newCombat.Volume = 0
		newCombat.Parent = coreGui
		newCombat.SoundId = area.combat.id
		combat = newCombat
	end
	if not ambient or ambient.SoundId ~= area.ambient.id and not isCombat then
		if ambient then
			task.spawn(clearOldSound, ambient)
		end
		
		lastTimePos.ambient = area.ambient.begin and area.ambient.begin or 0
		
		local newAmbient = Instance.new("Sound")
		newAmbient.Name = "Ambient"
		newAmbient.Looped = true
		newAmbient.Volume = 0
		newAmbient.Parent = coreGui
		newAmbient.SoundId = area.ambient.id
		ambient = newAmbient
	end
	if not special and area.special or special and special.SoundId ~= area.special.id then
		if special then
			task.spawn(clearOldSound, special)
		end
		
		lastTimePos.special = area.special.begin and area.special.begin or 0
		
		local newSpecial = Instance.new("Sound")
		newSpecial.Name = "Special"
		newSpecial.Looped = false
		newSpecial.Volume = 0
		newSpecial.Parent = coreGui
		newSpecial.SoundId = area.special.id
		special = newSpecial
	end
	
	local function isFerryman()
		if ferrymanHealth then
			if ferrymanHealth <= (ferrymanMaxHealth / 2) then
				return true, 2
			end
			return true, 1
		end
		return false, nil
	end
	local function isChaser()
		if chaserHealth then
			if chaserStage2Triggered then
				return true, 2
			end
			if chaserHealth <= (chaserMaxHealth * 0.8) - 1250 then
				chaserStage2Triggered = true
				return true, 2
			end
			return true, 1
		end
		chaserStage2Triggered = false
		return false, nil
	end
	
	local function shouldPlayCombat()
		local ferryman, stageFerryman = isFerryman()
		local chaser, stageChaser = isChaser()
		
		if ferryman and stageFerryman == 2 then
			return true
		end
		if chaser and stageChaser == 2 then
			return true
		end
		if isCombat and combat.SoundId ~= ambient.SoundId and not ferryman and not chaser then
			return true
		end
		return false
	end
	
	-- play - stop
	if shouldPlayCombat() then
		if not combat.IsPlaying then
			if special and special.IsPlaying then
				lastTimePos.special = special.TimePosition
				local tween = tweenService:Create(special, tweenInfo, {Volume = 0})
				tween.Completed:Connect(function(playbackState)
					special:Pause()
				end)
				tween:Play()
			end
			if ambient.IsPlaying then
				lastTimePos.ambient = ambient.TimePosition
				local tween = tweenService:Create(ambient, tweenInfo, {Volume = 0})
				tween.Completed:Connect(function(playbackState)
					ambient:Pause()
				end)
				tween:Play()
			end
			
			shouldTweenWhat = 1
			combat.TimePosition = lastTimePos.combat
			combat.Volume = 0
			combat:Resume()
		end
	else
		if not ambient.IsPlaying then
			if not special or not special.IsPlaying then
				if combat.IsPlaying then
					lastTimePos.combat = combat.TimePosition
					local tween = tweenService:Create(combat, tweenInfo, {Volume = 0})
					tween.Completed:Connect(function(playbackState)
						combat:Pause()
					end)
					tween:Play()
				end
				
				shouldTweenWhat = 0
				ambient.TimePosition = lastTimePos.ambient
				ambient.Volume = 0
				ambient:Resume()
			end
		end
		if special and not special.IsPlaying and getChance(area.special.chance) then
			if ambient.IsPlaying then
				lastTimePos.special = area.special.begin and area.special.begin or 0
				lastTimePos.ambient = ambient.TimePosition
				local tween = tweenService:Create(ambient, tweenInfo, {Volume = 0})
				tween.Completed:Connect(function(playbackState)
					ambient:Pause()
				end)
				tween:Play()
			end
			if combat.IsPlaying then
				lastTimePos.combat = combat.TimePosition
				local tween = tweenService:Create(combat, tweenInfo, {Volume = 0})
				tween.Completed:Connect(function(playbackState)
					combat:Pause()
				end)
				tween:Play()
			end
			
			shouldTweenWhat = 2
			special.TimePosition = lastTimePos.special
			special.Volume = 0
			special:Resume()
		end
	end
	
	-- volume
	local ambientVolume = PlayCustomAmbient.Value and area.ambient.volume * Options.AmbientVolume.Value or 0
	local combatVolume = PlayCustomAmbient.Value and area.combat.volume * Options.AmbientVolume.Value or 0
	local specialVolume
	if special then
		specialVolume = PlayCustomAmbient.Value and area.special.volume * Options.AmbientVolume.Value or 0
	end
	
	if shouldPlayCombat() then
		if shouldTweenWhat == 1 then
			tweenService:Create(combat, tweenInfo, {Volume = combatVolume}):Play()
		else
			combat.Volume = combatVolume
		end
	else
		if shouldTweenWhat == 0 then
			tweenService:Create(ambient, tweenInfo, {Volume = ambientVolume}):Play()
		elseif shouldTweenWhat == 2 then
			tweenService:Create(special, tweenInfo, {Volume = specialVolume}):Play()
		else
			if not special or not special.IsPlaying then
				ambient.Volume = ambientVolume
			else
				special.Volume = specialVolume
			end
		end
	end
end


-- player events
local function chatted(player, msg)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:WaitForChild("Humanoid", math.huge)
	if not humanoid then
		return
	end
	local characterName = humanoid:GetAttribute("CharacterName")
	
	local frame = getPlayerFrame(player, characterName)
	if not frame then
		return
	end
	
	task.spawn(function()
		-- handle old messages yet to disappear
		table.foreach(activeMessages[player.UserId].Instances, function(guid,instance)
			if not ShowOldMessages.Value then
				return
			end
			
			local distance = activeMessages[player.UserId].Distance
			local name = "["..player.Name.."]["..characterName.."]["..distance.."]: "
			local text = instance.text.label2.Text
			
			local minlen = 3
			
			local minSize = 17
			local maxSize = 21
			
			local len = string.len(text)
			local iHateYou = math.log(len, 1.7) + 16
			local size = len > minlen and iHateYou or minSize
			local clampedMin = size < minSize and minSize or size
			local clampedMax = clampedMin > maxSize and maxSize or clampedMin
			
			-- add instance to bottom left
			local extra = {}
			extra.index = getTotalOldMessages()+1
			extra.size = OldMessagesLogaritmicSize.Value and clampedMax or Options.OldMessagesSize.Value
			extra.delay = 8
			task.spawn(newText, player, {label1 = name, label2 = text}, instance.frame, "OldInstances", extra)
			
			-- remove instance from top right
			clearMessage(player, "Instances", guid)
		end)
	end)
	
	task.spawn(newText, player, {label1 = "", label2 = msg}, frame, "Instances", {characterName = characterName})
end

local function playerAdded(player)
	local newPlayer = {
		Player = player,
		Instances = {},
		OldInstances = {},
		NameColor = getNameColor(player),
		ChatColor = getChatColor(player),
		Distance = "N/A"
	}
	activeMessages[player.UserId] = newPlayer
	
	local pChattedCon = player.Chatted:Connect(function(msg)
		chatted(player, msg)
	end)
	shared.CV_ChatCon[player.UserId] = pChattedCon
end

local function playerRemoving(player)
	-- delete all previous messages
	clearMessage(player, "Instances")
	clearMessage(player, "OldInstances")
	activeMessages[player.UserId] = nil
	shared.CV_ChatCon[player.UserId]:Disconnect()
end


-- main
preloadAmbients()

shared.CV_PlayerAddedCon = players.PlayerAdded:Connect(playerAdded)
shared.CV_PlayerRemovingCon = players.PlayerRemoving:Connect(playerRemoving)

for i,player in pairs(players:GetChildren()) do
	if not activeMessages[player.UserId] then
		playerAdded(player)
	end
end

shared.CV_RenderSteppedCon = runService.RenderStepped:Connect(function(deltaTime)
	if (os.clock() - LastRefresh) > (Options.RefreshRate.Value / 1000) then
		LastRefresh = os.clock()
		
		task.spawn(updateMessages)
		task.spawn(updateAmbient)
		task.spawn(updateDistances)
	end
end)
