--[[
    Custom Script Service By: Daike
    Script Type: Auto fossil In Home World
    Buyer Name: dreadfulgod
]]

local storageTool = "world:name"
local storageFossil = "world:name"
local replaceRock = false
local sendNotify = false
local discordNotify = "webhooklink"
local intervalPunch = 1000

-------------- Dont Touch This Part --------------

function reconnect(world,id,x,y)
    if getBot().status ~= BotStatus.online then
        local attempt = 0
        while getBot().status ~= BotStatus.online do
            getBot():connect()
            sleep(35000)
            if getBot().status ~= BotStatus.online then
                if getBot().status == 3 or getBot().status == 4 then
                    removeBot()
                end
            end
        end
        while getBot():isInWorld() do
            getBot():leaveWorld()
            sleep(5000)
        end
        enterWorld(world,id)
        sleep(1000)
        while not getBot():isInTile(x,y) do
            getBot():findPath(x,y)
            sleep(1000)
        end
        sleep(2000)
    end
end

local function isOrdinateHaveBedRock(x)
    for tiley = 0, 53 do
        if getTile(x,tiley).fg == 8 then
            return true
        end
    end
    return false
end

local function startDigging(world, x, y)
    if not isOrdinateHaveBedRock(x) then
        for tiley = 0, y-1 do
            if getTile(x, tiley).fg ~= 0 then
                getBot():findPath(x, tiley - 1)
                reconnect(world, "", x, tiley - 1)
                while getTile(x, tiley).fg ~= 0 do
                    getBot():hit(x, tiley)
                    sleep(190)
                    reconnect(world, "", x, tiley - 1)
                end
            end
        end
        getBot():findPath(getBot().x,getBot().y+1)
    else
        for tiley = 0, y do
            if getTile(x-1, tiley).fg ~= 0 then
                getBot():findPath(x-1, tiley - 1)
                reconnect(world, "", x-1, tiley - 1)
                while getTile(x-1, tiley).fg ~= 0 do
                    getBot():hit(x-1, tiley)
                    sleep(190)
                    reconnect(world, "", x-1, tiley - 1)
                end
            end
        end
        getBot():findPath(getBot().x,getBot().y+1)
    end
end

startDigging("World",61,44)