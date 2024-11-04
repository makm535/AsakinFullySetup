local worldDirtfarms = {}

local Struct = {
    wrenchedLock = false,
    keyRecieved = false,
    wrenchedPlayer = false
}

local function resetPrimary()
    Struct.wrenchedLock = false
    Struct.keyRecieved = false
end

local function resetSecondary()
    Struct.wrenchedPlayer = false
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
    end
end)

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnTradeStatus" then
        message = variant:get(3):getString():lower()
        if message:find("add_slot|1424") then
            StructureTrade.itemPlaced = true
        end
        if tonumber(variant:get(1):getString()) == 2 then
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

local function getPlayerInfos()
    for _,player in pairs(getBot():getWorld():getPlayers()) do
        if player.name:lower() == playerTarget:lower() then
            return true, player.netid
        end
    end
    return false, nil
end

local function startTheTrade(world)
    print("-------------------------------------------------------")
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - You have " .. dirtfarmLeft .. " left.")
    print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Trading in the world " .. world:upper())
    
    resetPrimary()
    resetSecondary()
    
    if getBot():getInventory():getItemCount() == 0 then
        print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Retrieving the key")
        
        while not SecondaryStructure.wrenched do
            for _,tile in pairs(getTiles()) do
                if tile.fg == 242 then
                    getBot():wrench(tile.x,tile.y)
                    listenEvents(3)
                    tilex = tile.x
                    tiley = tile.y
                end
            end
        end
        
        while not StructureTrade.keyReceived do
            getBot():sendPacket(2, "action|dialog_return\ndialog_name|lock_edit\ntilex|".. tilex .. "|\ntiley|".. tiley .. "|\nbuttonClicked|getKey\n\ncheckbox_public|0\ncheckbox_disable_music|0\ntempo|100\ncheckbox_disable_music_render|0\ncheckbox_set_as_home_world|0\nminimum_entry_level|1")
            listenEvents(3)
        end
        
        print("[" .. getCurrentTime() .. "] [" .. getBot().name:upper() .. "] - Successfully retrieved the key")
        
    end
    
    local stageTwoFinished = false
    
    while not stageTwoFinished do
        
        if not Struct.wrenchedPlayer then
        
            while not Struct.wrenchedPlayer do
                
