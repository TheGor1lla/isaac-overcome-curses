local OvercomeCurses = RegisterMod("OvercomeCurses", 1)

local json = require("json")

local game = Game()
local player = Isaac.GetPlayer(0)
local bossKilled = false
local inBossFight = false

require('Cursebox')
cursebox = Cursebox:Create()

local function splitString(string)
	chunks = {}
	for s in string:gmatch("%S+") do
		table.insert(chunks, s)
	end
	return chunks
end

local function removeSelectedCurses(level)
	for k in pairs(cursebox.curses) do level:RemoveCurses(k) end
end

local function onCmd(_, command, value)
	if command == "overcome" then
		chunks = splitString(value)
		if     chunks[1] == "add"    then cursebox:add(chunks[2])
		elseif chunks[1] == "remove" then cursebox:remove(chunks[2])
		elseif chunks[1] == "list"   then print(cursebox:getStatus())
		elseif chunks[1] == "help"   then print(cursebox:helpText())
		end
	end
end

local function onBossKill(_, player)

	local level = game:GetLevel()
	local room = level.GetCurrentRoom(level)
	local curse = level.GetCurses(level)

	if room:GetType() == RoomType.ROOM_BOSS and bossKilled == false and room:IsCurrentRoomLastBoss() == true then

		if room:GetAliveBossesCount() ~=0 then
			inBossFight = true
		end

		if room:GetAliveEnemiesCount() == 0 and inBossFight == true and curse ~= 0 and cursebox.curses[tostring(curse)] == true then
			-- ToDo Render Text more stylish, maybe instead of AnimateHappy
			--			Isaac.RenderText("You overcame the " .. level.GetCurseName(level), 150, 50, 1, 1, 1, 255)
			removeSelectedCurses(level)
			player:AnimateHappy()
			bossKilled = true
		end
	end
end

local function resetBossStatus()
	bossKilled = false
	inBossFight = false
end

OvercomeCurses:AddCallback(ModCallbacks.MC_EXECUTE_CMD, onCmd)

OvercomeCurses:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, onBossKill)

OvercomeCurses:AddCallback(ModCallbacks.MC_POST_GAME_END, resetBossStatus)
OvercomeCurses:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetBossStatus)
OvercomeCurses:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetBossStatus)

--[[
	SAVE DATA
]]
function OvercomeCurses:onGameExit()
	OvercomeCurses:SaveData(json.encode(cursebox.curses))
end


function OvercomeCurses:onGameStart(isSave)
	if OvercomeCurses:HasData() then
		cursebox.curses = json.decode(OvercomeCurses:LoadData())
	end
end

OvercomeCurses:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OvercomeCurses.onGameStart)
OvercomeCurses:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, OvercomeCurses.onGameExit)


--[[
	MOD MENU
]]

local MOD_NAME = "Overcome Curses"
local VERSION = "1.5"

--[[
	Wrapper for Curse Settings
]]
local function addCurseSetting(id, name, description)
	ModConfigMenu.AddSetting(MOD_NAME, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		Attribute = id,
		Default =  true,
		CurrentSetting = function()
			return cursebox:getStatusForCurse(id)
		end,
		Display = function()
			return name .. ": " .. tostring(cursebox:getStatusForCurse(id))
		end,
		OnChange = function()
			cursebox:invert(id)
		end,
		Info = description or "Set to true to have this curse removed when defeating the floor boss"
	})
end

--[[
	Wrapper for non removable curses and other shenanigans
]]
local function addTrollCurseSetting(id, name, description)
	ModConfigMenu.AddSetting(MOD_NAME, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		Attribute = id,
		Default =  false,
		CurrentSetting = function()
			return false
		end,
		Display = function()
			return name .. ": " .. tostring(false)
		end,
		OnChange = function()
		end,
		Info = description or "Dummy entry"
	})
end

local function setupMyModConfigMenuSettings()
	if ModConfigMenu == nil then
		return
	end
	ModConfigMenu.UpdateCategory(MOD_NAME, {
		Info = {
			"Overcome curses after defeating the floor boss.",
		}})
	ModConfigMenu.AddText(MOD_NAME, "Settings", "Version: " .. VERSION)
	addCurseSetting("DARKNESS", "Curse of Darkness")
	addCurseSetting("LOST", "Curse of the Lost")
	addCurseSetting("UNKNOWN", "Curse of the Unknown")
	addCurseSetting("CURSED", "Curse of the Cursed", "This curse only appears in special seeds, challenges and workshop curses")
	addCurseSetting("MAZE", "Curse of Maze")
	addCurseSetting("BLIND", "Curse of Blind")
	addCurseSetting("GIANT", "Curse of the Giant", "This curse only appears when set manually or as a workshop curse")
	addCurseSetting("CUSTOM", "Curse of the Custom", "Most workshop curses use the same id. Might have weird consequences")
	addTrollCurseSetting("LABYRINTH", "Curse of Labyrinth", "I'm sorry Dave, I'm afraid I can't do that")
end

setupMyModConfigMenuSettings()
