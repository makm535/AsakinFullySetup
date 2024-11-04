--[[
    Script Type: Lucifer Auto Dirtfarm Script
    Created By: Daike no shori
    Script Version: 1.0.0
]]

getBot().legit_mode = true
getBot().move_range = 6
getBot().move_interval = 235
getBot().auto_reconnect = false

local proxyInfo = ""

-- Storage Platform
local storagePlatform = ""
local storageDoorID = ""

-- Storage Items
local storageItem = ""
local storageItemID = ""

------------------ Dont Touch ------------------
local bot = {}
local world = getBot():getWorld()
local inventory = getBot():getInventory()

local doneDirtfarm = {}
local onGoingDirtFarm = {}

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        message = variant:get(1):getString()
        if message:find("created too many worlds") then
            worldCreationLimit = true
            unlistenEvents()
        end
    end
end)

local function waitForCondition(interval, max, condition)
    local sleepCounter = 0
    while condition() and sleepCounter < max do
        sleep(interval)
        sleepCounter = sleepCounter + interval
    end
    return sleepCounter
end

local function getPlayerCount()

end

local function reconnect(world,id,x,y)
    if getBot().status ~= 1 then
        while not getBot().status ~= 1 do
            local internetValue = 
            if internetValue ~= 0 then
                local playerCount = getPlayerCount()
                if playerCount >= 40000 then
                    getBot():connect()
                    sleep(10000)
                    waitForCondition(10000, 25000 + math.random(5000,9000), function() return not getBot():isInWorld(string.upper(world)) and getBot().status == 1 end)
                    sleep(5000)
                    if getBot().status == 3 then
                        getBot():disconnect()
                        getBot():stopScript()
                    end
                else
                    while true do
                        local values = internetValue()
                        if values ~= 0 then
                            local playerCount = getPlayerCount()
                            if playerCount >= 40000 then
                                break
                            else
                                sleep(30000)
                            end
                        else
                            sleep(20000)
                        end
                    end
                end
            else
                while true do
                    local values = internetValue()
                    if values ~= 0 then
                        break
                    else
                        sleep(60000 * 2)
                    end
                end
            end
        end
        while not getBot():isInWorld(string.upper(world)) do
            getBot():warp(world,id)
            waitForCondition(500, 35000, function() return not getBot():isInWorld(string.upper(world)) and getBot().status == 1 end)
            if getBot().status ~= 1 then return reconnect(world,id,x,y) end
            if not getBot():isInWorld(string.upper(world)) then
                if worldCreationLimit == true then return end
                enterAttempt = attempt + 1
                if enterAttempt >= 4 then
                    waitForCondition(500, 400000, function() return not getBot():isInWorld(string.upper(world)) and getBot().status == 1 end)                
                    return reconnect(world,id,x,y)
                    attempt = 0
                end
            else
                sleep(5000)
            end
        end
        local attempt = 0
        if id ~= "" and getTile(getBot().x,getBot().y).fg == 6 then
            while getTile(getBot().x,getBot().y).fg == 6 do
                getBot():warp(world,id)
                sleep(3000)
                if getBot().status ~= 1 then return reconnect(world,id,x,y) end
                if attempt >= 4 then
                    sleep(60000 * 8)
                    return reconnect(world,id,x,y)
                    attempt = 0
                end
            end
        end
        if x and y then
            while not getBot():isInTile(x,y) do
                if getBot().status ~= 1 then
                    getBot():findPath(x,y)
                    sleep(500)
                else
                    return reconnect(world,id,x,y)
                end
            end
        end 
    end
end

local function enterWorld(world,id)
    if not getBot():isInWorld(string.upper(world)) then
        worldCreationLimit = false
        local enterAttempt = 0
        while not getBot():isInWorld(string.upper(world)) do
            getBot():warp(world,id)
            waitForCondition(500, 35000, function() return not getBot():isInWorld(string.upper(world)) and getBot().status == 1 end)
            reconnect(world,id)
            if not getBot():isInWorld(string.upper(world)) then
                if worldCreationLimit == true then return end
                enterAttempt = attempt + 1
                if enterAttempt >= 3 then
                    waitForCondition(500, 400000, function() return not getBot():isInWorld(string.upper(world)) and getBot().status == 1 end)                
                    reconnect(world,id)
                    attempt = 0
                end
            else
                sleep(5000)
            end
        end
    end
    local attempt = 0
    if id ~= "" and getTile(getBot().x,getBot().y).fg == 6 then
        while getTile(getBot().x,getBot().y).fg == 6 do
            getBot():warp(world,id)
            sleep(3000)
            reconnect(world,id)
            if attempt >= 4 then
                sleep(60000 * 8)
                reconnect(world,id)
                attempt = 0
            end
        end
    end
end

