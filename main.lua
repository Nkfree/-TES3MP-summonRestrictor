local config = {}
config.summonLimit = 3 -- general limit - how many summons can be active per player
config.levelBased = true -- if true ignores previous setting and limits summons according to predefined levels
config.levelBasedStartLimit = 3 -- number of summons

local summonEffects = {}
summonEffects["ancestor_ghost_summon"] = 106
summonEffects["atronach_flame_summon"] = 114
summonEffects["atronach_frost_summon"] = 115
summonEffects["atronach_storm_summon"] = 116
summonEffects["BM_bear_black_summon"] = 139
summonEffects["BM_wolf_bone_summon"] = 140
summonEffects["BM_wolf_grey_summon"] = 138
summonEffects["bonelord_summon"] = 110
summonEffects["Bonewalker_Greater_summ"] = 109
summonEffects["bonewalker_summon"] = 108
summonEffects["centurion_sphere_summon"] = 134
summonEffects["clannfear_summon"] = 103
summonEffects["daedroth_summon"] = 104
summonEffects["dremora_summon"] = 105
summonEffects["fabricant_summon"] = 137
summonEffects["golden saint_summon"] = 113
summonEffects["hunger_summon"] = 112
summonEffects["scamp_summon"] = 102
summonEffects["skeleton_summon"] = 107
summonEffects["winged twilight_summon"] = 111

local function getLimitPerLevel(pid)

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        local level = tes3mp.GetLevel(pid)
        local limit = config.levelBasedStartLimit

        if level > 6 and level <= 13 then
            limit = 4
        elseif level > 13 and level <= 21 then
            limit = 5
        elseif level > 21 and level <= 30 then
            limit = 6
        elseif level > 30 and level <= 40 then
            limit = 7
        elseif level > 40 and level <= 51 then
            limit = 8
        elseif level > 51 and level <= 63 then
            limit = 9
        elseif level > 63 then
            limit = 10
        end

        return limit
    end
end

local function setLimitPerLevel(pid)
    local limit = getLimitPerLevel(pid)
    Players[pid].summonLimit = limit
end

-- THIS IS ADMIN/SERVER OWNER COMMAND
local function printSummons(pid, cmd) -- prints summons table of self or other players if pid is specified as second command

    if Players[pid].data.staffRank < 2 then
        return
    end

    local id = pid
    local message = "[ ]\n"

    if cmd[2] then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            id = tonumber(cmd[2])
        else
            return
        end
    end

    if tableHelper.getCount(Players[id].summons) > 0 then
        message = "[ " .. tableHelper.getSimplePrintableTable(Players[id].summons) .. " ]\n"
    end

    tes3mp.SendMessage(pid, message, false)
end

local function printAvailableSummons(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        local currentLimit = Players[pid].summonLimit
        local message = "You have total of %d available summons.\n"
        tes3mp.SendMessage(pid, string.format(message, currentLimit), false)
    end
end

local function OnPlayerAuthentifiedHandler(eventStatus, pid)
    setLimitPerLevel(pid)
end

local function OnPlayerLevelHandler(eventStatus, pid)
    setLimitPerLevel(pid)
end

local function OnPlayerDisconnectValidator(eventStatus, pid)
    if Players[pid].summonLimit then Players[pid].summonLimit = nil end
end

-- if config.levelBased is set to false this will be used
local function GeneralOnObjectSpawnValidator(eventStatus, pid, cellDescription, objects)

	for index = 0, tes3mp.GetObjectListSize() - 1 do
		local object = {}
		object.refId = tes3mp.GetObjectRefId(index)
		object.summonerPid = tes3mp.GetObjectSummonerPid(index)
        if object.summonerPid ~= nil and object.summonerPid > -1 then
            if tableHelper.getCount(Players[object.summonerPid].summons) >= config.summonLimit then
                logicHandler.RunConsoleCommandOnPlayer(object.summonerPid, "player->RemoveEffects," .. summonEffects[object.refId], false)
                return customEventHooks.makeEventStatus(false, false)
            end
        end
	end        
end

-- if config.levelBased is set to true this will be used
local function LevelBasedOnObjectSpawnValidator(eventStatus, pid, cellDescription, objects)
	for index = 0, tes3mp.GetObjectListSize() - 1 do
		local object = {}
		object.refId = tes3mp.GetObjectRefId(index)
		object.summonerPid = tes3mp.GetObjectSummonerPid(index)
        if object.summonerPid ~= nil and object.summonerPid > -1 then
            if tableHelper.getCount(Players[object.summonerPid].summons) >= Players[pid].summonLimit then
                logicHandler.RunConsoleCommandOnPlayer(object.summonerPid, "player->RemoveEffects," .. summonEffects[object.refId], false)
                return customEventHooks.makeEventStatus(false, false)
            end
        end
	end   
end

customEventHooks.registerHandler("OnPlayerAuthentified", OnPlayerAuthentifiedHandler)
customEventHooks.registerHandler("OnPlayerLevel", OnPlayerLevelHandler)

if config.levelBased == true then
    customEventHooks.registerValidator("OnObjectSpawn", LevelBasedOnObjectSpawnValidator)
else
    customEventHooks.registerValidator("OnObjectSpawn", GeneralOnObjectSpawnValidator)
end

customEventHooks.registerValidator("OnPlayerDisconnect", OnPlayerDisconnectValidator)
customCommandHooks.registerCommand("summons", printSummons)
customCommandHooks.registerCommand("summ", printAvailableSummons)