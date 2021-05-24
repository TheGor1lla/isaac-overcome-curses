local OvercomeCurses = RegisterMod("OvercomeCurses", 1)

local game = Game()
local player = Isaac.GetPlayer(0)
local bossKilled = false

local function onBossKill(_, player)

	local level = game:GetLevel()
	local room = level.GetCurrentRoom(level)
	local curse = level.GetCurses(level)

	if room:GetType() == RoomType.ROOM_BOSS and bossKilled == false then
		if room:GetAliveBossesCount() == 0 then
--			Isaac.RenderText("You overcame the " .. level.GetCurseName(level), 150, 50, 1, 1, 1, 255)
			level:RemoveCurses(curse)

			player:AnimateHappy()
			bossKilled = true
		end
	end
end

OvercomeCurses:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, onBossKill)

local function resetBossStatus()

	bossKilled = false
end

OvercomeCurses:AddCallback(ModCallbacks.MC_POST_GAME_END, resetBossStatus)
OvercomeCurses:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetBossStatus)
OvercomeCurses:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetBossStatus)
