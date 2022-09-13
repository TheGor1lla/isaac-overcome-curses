--[[
Cursebox holds all the available curses and their overcome status.
Each Curse has an ID. Labyrinth(2) cannot be removed, while Cursed(16) and Giant(128)
only appear in challenges and mods. Most other mods use CURSE_OF_THE_CUSTOM(256)

CURSE_OF_DARKNESS       1
CURSE_OF_LABYRINTH      2
CURSE_OF_THE_LOST       4
CURSE_OF_THE_UNKNOWN    8
CURSE_OF_THE_CURSED     16
CURSE_OF_MAZE           32
CURSE_OF_BLIND          64
CURSE_OF_THE_GIANT      128
CURSE_OF_THE_CUSTOM     256
]]

Cursebox = {}
Cursebox.__index = Cursebox

function Cursebox:Create()
    local crsbx = {}
    setmetatable(crsbx, Cursebox)
    crsbx.curses    = {}
    crsbx.curses["1"] = true
    crsbx.curses["2"] = true
    crsbx.curses["4"] = true
    crsbx.curses["8"] = true
    crsbx.curses["16"] = true
    crsbx.curses["32"] = true
    crsbx.curses["64"] = true
    crsbx.curses["128"] = true
    crsbx.curses["256"] = true
    return crsbx
end

local function idToCurseName(id)
    if          id == "1"   then return "DARKNESS"
        elseif  id == "2"   then return "LABYRINTH"
        elseif  id == "4"   then return "LOST"
        elseif  id == "8"   then return "UNKNOWN"
        elseif  id == "16"  then return "CURSED"
        elseif  id == "32"  then return "MAZE"
        elseif  id == "64"  then return "BLIND"
        elseif  id == "128" then return "GIANT"
        elseif  id == "256" then return "CUSTOM"
        else                     return "NOT FOUND"
    end
end

local function curseNameToId(name)
    if          name == "DARKNESS"  then return "1"
        elseif  name == "LABYRINTH" then return "2"
        elseif  name == "LOST"      then return "4"
        elseif  name == "UNKNOWN"   then return "8"
        elseif  name == "CURSED"    then return "16"
        elseif  name == "MAZE"      then return "32"
        elseif  name == "BLIND"     then return "64"
        elseif  name == "GIANT"     then return "128"
        elseif  name == "CUSTOM"    then return "256"
        else                             return "0"
    end
end

function Cursebox:getStatus()
    local cursesToBeRemoved = ""
    for k,v in pairs(self.curses) do
        cursesToBeRemoved = cursesToBeRemoved .. idToCurseName(k) .. " "
    end
    return "Removing Curses: " .. cursesToBeRemoved
end

function Cursebox:helpText()
    return "Usage: \n" ..
           "overcome list: Shows all curses that will be removed on boss kill \n" ..
           "overcome help: Shows this message \n" ..
           "overcome add: Adds curse to be removed. Possible values are: DARKNESS, LOST, UNKNOWN, CURSED, MAZE, BLIND, GIANT, CUSTOM (most workshop curses) \n" ..
           "overcome remove: Set a curse you will no longer be able to overcome after killing a boss."
end

function Cursebox:add(name)
    self.curses[curseNameToId(name)] = true
end

function Cursebox:remove(name)
    self.curses[curseNameToId(name)] = nil
end

function Cursebox:invert(name)
    curseId = curseNameToId(name)
    if self.curses[curseId] == true then self.curses[curseId] = nil else self.curses[curseId] = true end
end

function Cursebox:getStatusForCurse(name)
    if self.curses[curseNameToId(name)] == nil then return false else return true end
end
