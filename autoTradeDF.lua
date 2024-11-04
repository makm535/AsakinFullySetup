local worldList = {}
local playerTarget = "chargermen"

dirtfarmLeft = #worldList
contentList = {}

local StructureTrade = {
    keyReceived = false,
    itemPlaced = false,
    tradeAccepted = false,
    tradeAccepted2 = false,
    tradeCancelled = false,
    tradeSuccessful = false,
    alreadyTrade = false,
    finalConfirm = false
}

local SecondaryStructure = {
    wrenched = false,
    wrenchedPlayer = false,
    worldlockCount = 0
}

local function split_lines(input)
    local lines = {}
    for line in input:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end
    
for _, line in ipairs(split_lines(read(getBot().name:upper()))) do
    table.insert(worldList,line)
    table.insert(contentList,line)
end

function getCurrentTime()
    local time = os.date("*t")
    local hour = time.hour
    local period = "AM"

    if hour >= 12 then
        period = "PM"
        if hour > 12 then
            hour = hour - 12
        end
    end

    if hour == 0 then
        hour = 12
    end

    local minute = string.format("%02d", time.min)

    return hour .. ":" .. minute .. " " .. period
end

local function connectionIndex()
    local tableIndex = {}
    local currentIndex = 0

    for i, bot in pairs(getBots()) do
        if bot:getProxy().ip == proxy then
            table.insert(tableIndex, i)
        end
    end

    for i, index in ipairs(tableIndex) do
        if index == getBot().index then
            currentIndex = i
            break
        end
    end
    
    return currentIndex
end

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        message = variant:get(1):getString()
        if message:find("That world is inaccessible") then
            nuked = true
            unlistenEvents()
        elseif message:find("Players lower than level") then
            playerLimit = true
            unlistenEvents()
        end
    end
end)

local function enterWorld(world,id)
    if not getBot():isInWorld(world:upper()) then
        nuked = false
        playerLimit = false
        local attempt = 0 
        while not getBot():isInWorld(world:upper()) do
            getBot():warp(world)
            listenEvents(12)
            while getBot().status ~= 1 do
                getBot():connect()
                sleep(math.random(25000,35000))
            end
            if not getBot():isInWorld(world:upper()) and not nuked and not playerLimit then
                attempt = attempt + 1
                if attempt >= 5 then
                    print("Hard warp")
                    sleep(60000 * 5)
                    while getBot().status ~= 1 do
                        getBot():connect()
                        sleep(math.random(10000,15000))
                    end
                    attempt = 0
                end
            end
            if nuked then
                local modified_str = string.gsub(getBot().custom_status, "|([^|]+|%d+)$", "")
                getBot().custom_status = modified_str .. "|Joined|" .. os.time()
                return {success = false,nukes = true,playerLimits = false,wrongpass = false}
            end
            if playerLimit then
                local modified_str = string.gsub(getBot().custom_status, "|([^|]+|%d+)$", "")
                getBot().custom_status = modified_str .. "|Joined|" .. os.time()
                return {success = false,nukes = false,playerLimits = true,wrongpass = false}
            end
        end
    end
    local attempt = 0
    if id ~= "" and getBot():getWorld():getTile(getBot().x,getBot().y).fg == 6 then
        while getBot():getWorld():getTile(getBot().x,getBot().y).fg == 6 do
            getBot():warp(world,id)
            sleep(2000)
            if getBot():getWorld():getTile(getBot().x,getBot().y).fg == 6 then
                attempt = attempt + 1
                if attempt >= 4 then
                    local modified_str = string.gsub(getBot().custom_status, "|([^|]+|%d+)$", "")
                    getBot().custom_status = modified_str .. "|Joined|" .. os.time()
                    return {success = false,nukes = false,playerLimits = false,wrongpass = true}
                end
            end
        end
    end
    local modified_str = string.gsub(getBot().custom_status, "|([^|]+|%d+)$", "")
    getBot().custom_status = modified_str .. "|Joined|" .. os.time()
    return {success = true,nukes = false,playerLimits = false,wrongpass = false}
end

local function internetValue()
    local httpClient = HttpClient.new()
    httpClient:setMethod(Method.get)
    httpClient.url = "https://www.google.com/"
    httpClient.headers["User-Agent"] = "Lucifer"
    local httpResult = httpClient:request()
    return httpResult.status
end

local function checkPlayerCount()
    local client = HttpClient.new()
    client:setMethod(Method.get)
    client.url = 'https://growtopiagame.com/detail'
    AmountPlayer = client:request().body:match([[{"online_user":"(%d+)"]])
    return tonumber(AmountPlayer)
end

local function reconnect(world,id,x,y)
    if getBot().status ~= 1 then
        print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - This bot is got disconnected!")
        local attempt = 0
        local first = connectCondition()
        while getBot().status ~= 1 do
            local internets = internetValue()
            if internets ~= 0 then
                local playerCount = checkPlayerCount()
                local condition = false
                if playerCount > 8000 then
                    getBot():connect()
                    sleep(35000)
                    if getBot().status ~= 1 then
                        if getBot().status == 3 or getBot().status == 4 then
                            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - This bot is got banned!")
                            
                            removeBot()
                        elseif getBot().status == 0 or getBot().status == BotStatus.http_block then
                            attempt = attempt + 1
                            if attempt >= 6 then
                                print("[" .. getCurrentTime() .. "] - Alert: You might got an ercon.")
                                sleep(60000 * 20)
                                attempt = 0
                            end
                        end
                    end
                else
                    print("[" .. getCurrentTime() .. "] - Alert: Server might currently down!")
                    while true do
                        local values = internetValue()
                        if values ~= 0 then
                            local playerCount = checkPlayerCount()
                            if playerCount >= 8000 then
                                break
                            else
                                sleep(30000)
                            end
                        else
                            break
                        end
                    end
                end
            else
                print("[" .. getCurrentTime() .. "] - Alert: There is currently an internet interruption occurring.")
                
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
        getBot().move_range = 3
        getBot().move_interval = 235
        getBot().custom_status = "Reconnected|" .. os.time() .. "|None|0"
        while getBot():isInWorld() do
            getBot():leaveWorld()
            sleep(5000)
        end
        enterWorld(world,id)
        sleep(1000)
        if x and y then
            while not getBot():isInTile(x,y) do
                getBot():findPath(x,y)
                sleep(1000)
            end
        end
        sleep(2000)
    end
end

function isExisting()
    for _,player in pairs(getBot():getWorld():getPlayers()) do
        if player.name:lower() == playerTarget:lower() then
            return true, player.netid
        end
    end
    return false, nil
end
    
addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnDialogRequest" then
        message = variant:get(1):getString()
        if message:find("|`wEdit World Lock``|") then
            SecondaryStructure.wrenched = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnTalkBubble" then
        message = variant:get(2):getString()
        if message:find("You got a `#World Key``") then
            StructureTrade.keyReceived = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnTextOverlay" then
        message = variant:get(1):getString():lower()
        if message:find("has canceled") then
            StructureTrade.tradeCancelled = true
        end
        if message:find("canceling trade since") then
            StructureTrade.tradeCancelled = true
        end
        if message:find("left the trade") then
            StructureTrade.tradeCancelled = true
        end
        if message:find("trade canceled") then
            StructureTrade.tradeCancelled = true
        end
        if message:find("too busy to trade") then
            StructureTrade.tradeCancelled = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnTradeStatus" then
        message = variant:get(3):getString():lower()
        if variant:get(4):getString():find("add_slot|1424") then
            StructureTrade.itemPlaced = true
        end
        if message:find(playerTarget:lower()) then
            message2 = variant:get(4):getString():lower()
            if message2:find("accepted|1") then
                StructureTrade.tradeAccepted = true
            else
                StructureTrade.tradeAccepted = false
            end
            if message2:find("add_slot|242|") then
                count = string.match(message2,"add_slot|242|(%d+)")
                SecondaryStructure.worldlockCount = tonumber(count)
                print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Balance player: " .. SecondaryStructure.worldlockCount)
            else
                SecondaryStructure.worldlockCount = 0
                print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Balance player: " .. SecondaryStructure.worldlockCount)
            end
        elseif message:find(getBot().name:lower()) then
            message2 = variant:get(4):getString():lower()
            if message2:find("accepted|1") then
                StructureTrade.tradeAccepted2 = true
            else
                StructureTrade.tradeAccepted2 = false
            end
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnDialogRequest" then
        message = variant:get(1):getString()
        if message:find("add_slot|1424") then
            StructureTrade.itemPlaced = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        message = variant:get(1):getString():lower()
        if message:find("canceling trade since") then
            StructureTrade.tradeCancelled = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnStartTrade" then
        StructureTrade.tradeSuccessful = true
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnDialogRequest" then
        message = variant:get(1):getString()
        if message:find("`wSend Message``") then
            SecondaryStructure.wrenchedPlayer = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnDialogRequest" then
        message = variant:get(1):getString()
        if message:find("World Lock|left|242") then
            StructureTrade.finalConfirm = true
        end
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnTalkBubble" then
        message = variant:get(2):getString()
        if message:find("Trade accepted") then
            StructureTrade.alreadyTrade = true
        end
    end
end)

function convert()
    local packet = GameUpdatePacket.new()
    packet.type = 10
    packet.int_data = 242
    getBot():sendRaw(packet)
end

function getCountLock()
    local worldlock_count = 0
    for _,item in pairs(getBot():getInventory():getItems()) do
        if item.id == 242 then
            worldlock_count = worldlock_count + item.count
        elseif item.id == 1796 then
            worldlock_count = worldlock_count + (100 * item.count)
        end
    end
    return worldlock_count
end

function startTheTrade(world,id)
    local countLock = getCountLock()
    if getBot():getInventory():getItemCount(242) >= 100 then
        while getBot():getInventory():getItemCount(242) >= 100 do
            convert()
            sleep(1000)
        end
    end
    local tilex = 0
    local tiley = 0
    print("-------------------------------------------------------")
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - You have " .. dirtfarmLeft .. " left.")
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trading the world " .. world:upper())
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Getting the key")
    
    while not SecondaryStructure.wrenched do
        for _,tile in pairs(getTiles()) do
            if tile.fg == 242 then
                getBot():wrench(tile.x,tile.y)
                listenEvents(4)
                tilex = tile.x
                tiley = tile.y
                if getBot().status ~= 1 then
                    reconnect(world,id)
                    SecondaryStructure.wrenched = false
                    return startTheTrade(world,id)
                end
            end
        end
        sleep(200)
    end
    while not StructureTrade.keyReceived do
        getBot():sendPacket(2, "action|dialog_return\ndialog_name|lock_edit\ntilex|".. tilex .. "|\ntiley|".. tiley .. "|\nbuttonClicked|getKey\n\ncheckbox_public|0\ncheckbox_disable_music|0\ntempo|100\ncheckbox_disable_music_render|0\ncheckbox_set_as_home_world|0\nminimum_entry_level|1")
        listenEvents(3)
        if getBot().status ~= 1 then
            reconnect(world,id)
            return startTheTrade(world,id)
        end
    end
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Done get key")
    local done = false
    while not done do
        if not StructureTrade.tradeSuccessful then
            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trading the target player")
            while not StructureTrade.tradeSuccessful do
                local player, ids = isExisting()
                if player == true then
                    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Sending Trade Packet")
                    getBot():say("/trade " .. playerTarget)
                    getBot():sendPacket(2, "action|trade_started\n|netid|"..ids)
                    listenEvents(4)
                    if getBot().status ~= 1 then
                        reconnect(world,id)
                        SecondaryStructure.wrenched = false
                        StructureTrade.keyReceived = false
                        SecondaryStructure.wrenchedPlayer = false
                        StructureTrade.tradeSuccessful = false
                        StructureTrade.tradeCancelled = false
                        return startTheTrade(world,id)
                    end
                    if StructureTrade.tradeSuccessful == true then
                        if StructureTrade.tradeCancelled == true then
                            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                            StructureTrade.tradeSuccessful = false
                            StructureTrade.tradeCancelled = false
                        end
                    end
                end
                if StructureTrade.tradeSuccessful == true then break end
                SecondaryStructure.wrenchedPlayer = false
                sleep(50)
            end
            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Done trade the target player.")
        end
        sleep(50)
        if StructureTrade.tradeSuccessful and not StructureTrade.itemPlaced then
            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Placing the world key")
            while not StructureTrade.itemPlaced do
                getBot():sendPacket(2, "action|mod_trade\nitemID|1424")
                listenEvents(4)
                if getBot().status ~= 1 then
                    reconnect(world,id)
                    SecondaryStructure.wrenched = false
                    StructureTrade.keyReceived = false
                    SecondaryStructure.wrenchedPlayer = false
                    StructureTrade.tradeSuccessful = false
                    StructureTrade.tradeCancelled = false
                    StructureTrade.itemPlaced = false
                    return startTheTrade(world,id)
                end
                if StructureTrade.tradeCancelled == true then
                    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                    SecondaryStructure.wrenchedPlayer = false
                    StructureTrade.tradeSuccessful = false
                    StructureTrade.tradeCancelled = false
                    StructureTrade.itemPlaced = false
                    StructureTrade.tradeAccepted = false
                    StructureTrade.tradeAccepted2 = false
                    SecondaryStructure.worldlockCount = 0
                    break
                end
            end
            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Done place world key")
        end
        if StructureTrade.itemPlaced == true and StructureTrade.tradeSuccessful == true then
            local trulala = false
            while not trulala do
                while not StructureTrade.tradeAccepted or SecondaryStructure.worldlockCount < 10 do
                    listenEvents(3)
                    if getBot().status ~= 1 then
                        reconnect(world,id)
                        SecondaryStructure.wrenched = false
                        StructureTrade.keyReceived = false
                        SecondaryStructure.wrenchedPlayer = false
                        StructureTrade.tradeSuccessful = false
                        StructureTrade.tradeCancelled = false
                        StructureTrade.itemPlaced = false
                        StructureTrade.tradeAccepted = false
                        StructureTrade.tradeAccepted2 = false
                        SecondaryStructure.worldlockCount = 0
                        return startTheTrade(world,id)
                    end
                    if StructureTrade.tradeCancelled == true then
                        print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                        SecondaryStructure.wrenchedPlayer = false
                        StructureTrade.tradeSuccessful = false
                        StructureTrade.tradeCancelled = false
                        StructureTrade.itemPlaced = false
                        StructureTrade.tradeAccepted = false
                        StructureTrade.tradeAccepted2 = false
                        SecondaryStructure.worldlockCount = 0
                        trulala = true
                        break
                    end 
                end
                if not trulala then
                    while not StructureTrade.tradeAccepted2 and SecondaryStructure.worldlockCount >= 10 do
                        getBot():sendPacket(2, "action|trade_accept\nstatus|1")
                        listenEvents(3)
                        if StructureTrade.tradeAccepted2 == true then
                            if not StructureTrade.finalConfirm then
                                while not StructureTrade.tradeCancelled do
                                    getBot():sendPacket(2, "action|dialog_return\ndialog_name|trade_confirm\nbuttonClicked|back")
                                    listenEvents(3)
                                end
                            end
                        end
                        if getBot().status ~= 1 then
                            reconnect(world,id)
                            SecondaryStructure.wrenched = false
                            StructureTrade.keyReceived = false
                            SecondaryStructure.wrenchedPlayer = false
                            StructureTrade.tradeSuccessful = false
                            StructureTrade.tradeCancelled = false
                            StructureTrade.itemPlaced = false
                            StructureTrade.tradeAccepted = false
                            StructureTrade.tradeAccepted2 = false
                            SecondaryStructure.worldlockCount = 0
                            StructureTrade.finalConfirm = false
                            return startTheTrade(world,id)
                        end
                        if StructureTrade.tradeCancelled == true then
                            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                            SecondaryStructure.wrenchedPlayer = false
                            StructureTrade.tradeSuccessful = false
                            StructureTrade.tradeCancelled = false
                            StructureTrade.itemPlaced = false
                            StructureTrade.tradeAccepted = false
                            StructureTrade.tradeAccepted2 = false
                            SecondaryStructure.worldlockCount = 0
                            StructureTrade.alreadyTrade = false
                            StructureTrade.finalConfirm = false
                            trulala = true
                            break
                        end
                    end
                end
                if StructureTrade.tradeAccepted2 == true then
                    while not StructureTrade.alreadyTrade do
                        getBot():sendPacket(2, "action|dialog_return\ndialog_name|trade_confirm\nbuttonClicked|accept")
                        listenEvents(2)
                        if getBot().status ~= 1 then
                            reconnect(world,id)
                            SecondaryStructure.wrenched = false
                            StructureTrade.keyReceived = false
                            SecondaryStructure.wrenchedPlayer = false
                            StructureTrade.tradeSuccessful = false
                            StructureTrade.tradeCancelled = false
                            StructureTrade.itemPlaced = false
                            StructureTrade.tradeAccepted = false
                            StructureTrade.tradeAccepted2 = false
                            SecondaryStructure.worldlockCount = 0
                            StructureTrade.alreadyTrade = false
                            StructureTrade.finalConfirm = false
                            return startTheTrade(world,id)
                        end
                        if StructureTrade.tradeCancelled == true then
                            print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                            SecondaryStructure.wrenchedPlayer = false
                            StructureTrade.tradeSuccessful = false
                            StructureTrade.tradeCancelled = false
                            StructureTrade.itemPlaced = false
                            StructureTrade.tradeAccepted = false
                            StructureTrade.tradeAccepted2 = false
                            SecondaryStructure.worldlockCount = 0
                            StructureTrade.alreadyTrade = false
                            StructureTrade.finalConfirm = false
                            trulala = true
                            break
                        end
                    end
                    if StructureTrade.alreadyTrade == true then
                        print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Waiting to accept the trade")
                        while getCountLock() == countLock do
                            listenEvents(2)
                            if getBot().status ~= 1 then
                                reconnect(world,id)
                                SecondaryStructure.wrenched = false
                                StructureTrade.keyReceived = false
                                SecondaryStructure.wrenchedPlayer = false
                                StructureTrade.tradeSuccessful = false
                                StructureTrade.tradeCancelled = false
                                StructureTrade.itemPlaced = false
                                StructureTrade.tradeAccepted = false
                                StructureTrade.tradeAccepted2 = false
                                SecondaryStructure.worldlockCount = 0
                                StructureTrade.alreadyTrade = false
                                StructureTrade.finalConfirm = false
                                return startTheTrade(world,id)
                            end
                            if StructureTrade.tradeCancelled == true then
                                print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade cancelled")
                                SecondaryStructure.wrenchedPlayer = false
                                StructureTrade.tradeSuccessful = false
                                StructureTrade.tradeCancelled = false
                                StructureTrade.itemPlaced = false
                                StructureTrade.tradeAccepted = false
                                StructureTrade.tradeAccepted2 = false
                                SecondaryStructure.worldlockCount = 0
                                StructureTrade.alreadyTrade = false
                                StructureTrade.finalConfirm = false
                                trulala = true
                                break
                            end
                        end
                        if getCountLock() ~= countLock then
                            done = true
                            trulala = true
                            break
                        end
                    end
                end
            end
        end
        if done == true then
            break
        end
    end
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trade successful")
    SecondaryStructure.wrenched = false
    StructureTrade.keyReceived = false
    SecondaryStructure.wrenchedPlayer = false
    StructureTrade.tradeSuccessful = false
    StructureTrade.tradeCancelled = false
    StructureTrade.itemPlaced = false
    StructureTrade.tradeAccepted = false
    StructureTrade.tradeAccepted2 = false
    SecondaryStructure.worldlockCount = 0
    StructureTrade.alreadyTrade = false
    StructureTrade.finalConfirm = false
end

local function removeContent(str)
    for i, world in pairs(contentList) do
        if world:lower() == str:lower() then
            table.remove(contentList,i)
        end
    end
end

local function write_world(filename)
    local file = io.open(filename, "w")
    for _, line in ipairs(contentList) do
        file:write(line .. "\n")
    end
    file:close()
end

while getBot():isInWorld() do
    getBot():leaveWorld()
    sleep(6000)
end

for i,worlds in pairs(worldList) do
    enterWorld(worlds,"")
    sleep(500)
    startTheTrade(worlds,"")
    sleep(1000)
    removeContent(worlds)
    sleep(1000)
    write_world(getBot().name:upper())
    sleep(200)
    getBot():say(worldList[i + 1])
    sleep(500)
    getBot():say("/msg " .. playerTarget .. " " .. worldList[i + 1])
    dirtfarmLeft = (#worldList - i)
end