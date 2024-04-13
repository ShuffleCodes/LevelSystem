local db = dbConnect("sqlite", "database.db")


getLevelingData = function(plr)
    local q = dbQuery(db, "SELECT * FROM Leveling WHERE Serial = ?", getPlayerSerial(source))
    local x = dbPoll(q, -1)
    if #x > 0 then
        setElementData(plr, "LevelSystem", {level = x[1].Level, exp = x[1].Exp})
    end
end

addEventHandler("onPlayerJoin", root, function()
    local q = dbQuery(db, "SELECT * FROM Leveling WHERE Serial = ?", getPlayerSerial(source))
    local x = dbPoll(q, -1)
    if #x == 0 then
        dbExec(db, "INSERT INTO Leveling (Serial, Level, Exp) VALUES (?, ?, ?)", getPlayerSerial(source), 1, 0)
    end
    getLevelingData(source)
end)

addEventHandler("onPlayerQuit", root, function()
    if getElementData(source, "LevelSystem") then
        local data = getElementData(source, "LevelSystem")
        dbExec(db, "UPDATE Leveling SET Level = ?, Exp = ? WHERE Serial = ?", data.level, data.exp, getPlayerSerial(source))
    end
end)

addEvent("LevelSystem:Reward", true)
addEventHandler("LevelSystem:Reward", resourceRoot, function(reward)
    if not isElement(client) then return end
    givePlayerMoney(client, reward)
end)


addExp = function(plr, count)
    triggerClientEvent(plr, "LevelSystem:AddExp", resourceRoot, count)
end

