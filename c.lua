sx, sy = guiGetScreenSize()

local baseX = 3440
zoom = 1 
local minZoom = 2
if sx < baseX then
	zoom = math.min(minZoom, baseX/sx)
end 

function format(value)
    local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

local data = {
    s = {},
    font = dxCreateFont("bold.ttf", 150/zoom, false, "antialiased"),
    font2 = dxCreateFont("bold.ttf", 50/zoom, false, "antialiased"),
    font3 = dxCreateFont("light.ttf", 40/zoom, false, "antialiased"),
    fade = 255,
    tick = nil,
    leveling = {},
}

data.s.polygon = {sx/2 - (550/zoom)/2, - 50/zoom, 550/zoom, 590/zoom}
data.s.level = {data.s.polygon[1] + 148/zoom, data.s.polygon[2] + 222/zoom, 250/zoom, 145/zoom}
data.s.info = {data.s.polygon[1] + 148/zoom, data.s.polygon[2] + data.s.polygon[4] - 125/zoom, 250/zoom, 40/zoom}
data.s.reward = {data.s.info[1], data.s.info[2] + data.s.info[4], 250/zoom, 40/zoom}


--[[addEventHandler("onClientRender", root, function()
    local leveldata = getElementData(localPlayer, "LevelSystem")
    dxDrawText(leveldata['level'].." Level", 0, sy - 200, 200, sy - 200, tocolor(255, 255, 255, data.s.fade), 0.50, data.font3, "left", "center", false, false, false, false, false)
    dxDrawText(leveldata['exp'].." Exp", 0, sy - 170, 200, sy - 170, tocolor(255, 255, 255, data.s.fade), 0.50, data.font3, "left", "center", false, false, false, false, false)
    dxDrawText(getNeededExp(localPlayer).." Needed per level", 0, sy - 140, 200, sy - 140, tocolor(255, 255, 255, data.s.fade), 0.50, data.font3, "left", "center", false, false, false, false, false)
    dxDrawText((getNeededExp(localPlayer) - leveldata['exp']).." Needed to level up", 0, sy - 110, 200, sy - 110, tocolor(255, 255, 255, data.s.fade), 0.50, data.font3, "left", "center", false, false, false, false, false)
end)]]--

render = function()
    local currentTick = getTickCount()
    if data.tick then
        local elapsedTime = currentTick - data.tick
        if elapsedTime >= data.leveling[2] then
            data.fade = math.max(0, data.fade - 0.9 * (elapsedTime / data.leveling[2]))
            if data.fade <= 0 then
                removeEventHandler("onClientRender", root, render)
                data.leveling = {}
                data.tick = nil
                data.fade = 255
            end
        end
    end
    if not next(data.leveling) then return end
    dxDrawImage(data.s.polygon[1], data.s.polygon[2], data.s.polygon[3], data.s.polygon[4], "img/polygon_a.png", 0, 0, 0, tocolor(255, 255, 255, data.fade))
    dxDrawText(data.leveling[1], data.s.level[1] + 3, data.s.level[2] + 3, data.s.level[3] + data.s.level[1] + 3, data.s.level[4] + data.s.level[2] + 3, tocolor(0, 0, 0, data.fade), 0.50, data.font, "center", "center", false, false, false, false, false)
    dxDrawText(data.leveling[1], data.s.level[1], data.s.level[2], data.s.level[3] + data.s.level[1], data.s.level[4] + data.s.level[2], tocolor(255, 255, 255, data.fade), 0.50, data.font, "center", "center", false, false, false, false, false)

    dxDrawText("New Level!", data.s.info[1] + 2, data.s.info[2] + 2, data.s.info[3] + data.s.info[1] + 2, data.s.info[4] + data.s.info[2] + 2, tocolor(0, 0, 0, data.fade), 0.50, data.font2, "center", "center", false, false, false, false, false)
    dxDrawText("New Level!", data.s.info[1], data.s.info[2], data.s.info[3] + data.s.info[1], data.s.info[4] + data.s.info[2], tocolor(255, 255, 255, data.fade), 0.50, data.font2, "center", "center", false, false, false, false, false)

    dxDrawText("+ "..format(data.leveling[3] * reward).."$", data.s.reward[1] + 1, data.s.reward[2] + 1, data.s.reward[3] + data.s.reward[1] + 1, data.s.reward[4] + data.s.reward[2] + 1, tocolor(0, 0, 0, data.fade), 0.50, data.font3, "center", "center", false, false, false, false, false)
    dxDrawText("+ "..format(data.leveling[3] * reward).."$", data.s.reward[1], data.s.reward[2], data.s.reward[3] + data.s.reward[1], data.s.reward[4] + data.s.reward[2], tocolor(255, 255, 255, data.fade), 0.50, data.font3, "center", "center", false, false, false, false, false)
end



local leveling = function(plr, count)
    if localPlayer == plr then
        local leveldata = getElementData(plr, "LevelSystem")
        leveldata.exp = leveldata.exp + count
        setElementData(plr, "LevelSystem", {level = leveldata.level, exp = leveldata.exp})
        if getElementData(plr, "LevelSystem").exp >= getElementData(plr, "LevelSystem").level * exp_multiplier then
            local count = 0
            while (getElementData(plr, "LevelSystem").exp >= getElementData(plr, "LevelSystem").level * exp_multiplier) do
                local info = getElementData(plr, "LevelSystem")
                local exp = info.exp
                exp = exp - info.level * exp_multiplier
                local level = info.level + 1
                setElementData(plr, "LevelSystem", {level = level, exp = exp})
                count = count + 1
            end
            triggerServerEvent("LevelSystem:Reward", resourceRoot, count * reward)
            if next(data.leveling) then
                leveldata = getElementData(plr, "LevelSystem")
                data.tick = getTickCount()
                data.fade = 255
                data.leveling = {leveldata.level, 3500, count}
            else
                leveldata = getElementData(plr, "LevelSystem")
                data.tick = getTickCount()
                data.leveling = {leveldata.level, 3500, count}
                addEventHandler("onClientRender", root, render)
            end
            playSound("sound.mp3", false)
        end
    end
end

addExp = function(plr, count)
    if plr == localPlayer then
        if not getElementData(plr, "LevelSystem") then return print("[ERROR LevelSystem] : ElementData 'LevelSystem' not found. Use getLevelingData function when player join to server to get all player data.") end
        if tonumber(count) and tonumber(count) > 0 then
            leveling(plr, count)
        end
    end
end

getNeededExp = function(plr)
    if plr == localPlayer then
        return getElementData(plr, "LevelSystem").level * exp_multiplier
    end
end



addEvent("LevelSystem:AddExp", true)
addEventHandler("LevelSystem:AddExp", resourceRoot, function(count)
    addExp(localPlayer, count)
end)