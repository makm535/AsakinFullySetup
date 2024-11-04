-- Auto Harvest Script V2.1 by CRAWL

local BOT = {}

BOT["RSJIEPXW"] = {
    botNumber = 1,
    farmList = {"LMIVM"},
    farmDoorID = "",
    storageBlock = {"BZ770"},
    blockDoorID = "YES",
    maxBlock = 10000
}

local botPerWorld = 1
local itemSeedID = 15
local ignoreGems = false
local delayHarvest = 190
local delayWarp = 5000
local webhookUrl = "https://discord.com/api/webhooks/1220413920997543986/sPhNqvC6F3X8MZbPXUM47w0KM_QzZE4yb5dliKZ4nn2WuJwlV-a0_LcO5V74OP7g66MG"
local disableWebhook = false

-------------------------------------------------------------

function warp(world,id)
    if getWorld():upper() ~= world:upper() then
        local attempt = 0
        nuked = false
        while getWorld():upper() ~= world:upper() and not nuked do
            sendPacket(3, "action|join_request\nname|" .. world:upper() .. "\ninvitedWorld|0")
            sleep(delayWarp)
            while getStatus() ~= "nuke detected" and getStatus() ~= "online" do
                connect()
                sleep(math.random(13000,25000))
            end
            if getWorld():upper() ~= world:upper() and getStatus() ~= "nuke detected" then
                attempt = attempt + 1
                if attempt >= 4 then
                    disconnect()
                    sleep(60000 * 15)
                    while getStatus() ~= "online" do
                        connect()
                        sleep(math.random(13000,25000))
                    end
                    attempt = 0
                end
            end
            if getStatus() == "nuke detected" then
                nuked = true
                return
            end
        end
    end
    if not nuked and id ~= "" then
        while getTile(getPos().tileX,getPos().tileY).fg == 6 do
            sendPacket(3, "action|join_request\nname|" .. world:upper() .. "|" .. id:upper() .. "\ninvitedWorld|0")
            sleep(2000)
            while getStatus() ~= "online" do
                connect()
                sleep(math.random(13000,25000))
            end
        end
    end
end

function gscanObject(itemID)
    local count = 0
    for _,object in pairs(getObjects()) do
        if object.id == itemID then
            count = count + object.count
        end
    end
    return count
end

