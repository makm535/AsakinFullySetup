--- Credentials world fossil.
local worldFossil = { "" }
--- Maximum world for each bots.
local worldEachBot = 0

--- Credentials world to taking tools.
local storageTools = { '' }

--- Credentials world to storing fossil.
local storageSave = { 'world:id' }
--- Minimum fossil to store
local minimumSave = 10

local webhookURL =
'https://discord.com/api/webhooks/1239555487670861936/Ae92vnu7iVI9qic5V-OJX41ykjfYBPOybQYX5KAQhWrN2TEvTZvWfGHQZjaA86iCUwzU'
local webhookStatus =
'https://discord.com/api/webhooks/1229313951184191528/nHZzCUZ01kDXNdlvXFAgkXZ5G-4k-Iggt0QqRxPfrd8X242v0fEJgrI8W9c6KkmgU9T1'

--- Enable or disable replace rock.
local replaceRock = false
--- Enable or disable remove removing bots after all world has been harvested
local removeBots = false

local delayPunch = 300

--- Don't Touch

---@class WorldData
---@field public world string
---@field public id string

---@class TileCache
---@field public x number
---@field public y number

local stuck, nuked, messageId
local client = getBot()

local uptime = os.time()

local worldList = {}
local info = {}
local fossil = {}

---@param a string
---@return WorldData
local function parseWorld(a)
    local world, id = a, ''
    if a:find(':') then
        world, id = a:match('(.+):(.+)')
    elseif a:find('|') then
        world, id = a:match('(.+)|(.+)')
    end
    return { world = world, id = id }
end

---@param data string|table
---@return WorldData[]?
local function loadWorld(data)
    local worlds = {}
    if type(data) == 'table' then
        for _, data in pairs(data) do
            table.insert(worlds, parseWorld(data))
        end
    elseif type(data) == 'string' then
        if data:match('^%a:\\.+%.%w+$') or data:match('^.+%.%w+$') then
            local file = io.open(data, 'r')
            if not file then
                return error('File or directory: ' .. data .. ' not found. Please check and try again.', 0)
            end
            for line in file:lines() do
                table.insert(worlds, parseWorld(line))
            end
            file:close()
        elseif data:match('^https?://[%w-_%.%?%.:/%+=&]+$') then
            local http = HttpClient.new()
            http.url = data
            http:setMethod(Method.get)
            local response = http:request()
            if response.error ~= 0 then
                return error('HTTP request failed with status code ' ..
                    response.status .. '. Reason: ' .. response:getError(), 0)
            end
            for line in response.body:gmatch('[^\n]+') do
                table.insert(worlds, parseWorld(line))
            end
        else
            return error('Data does not match expected patterns', 0)
        end
    else
        return error("Invalid data type. Expected string or table.", 0)
    end
    return worlds
end

---@return WorldData[]?
local function spreadWorld()
    local worlds = {}
    local found, data = pcall(loadWorld, worldFossil)
    if not found or type(data) ~= 'table' then
        return error(data, 0)
    end
    local split = worldEachBot == 0 and math.floor(#data / #getBots()) or worldEachBot
    local start = ((client.index - 1) * split) + 1
    local stop = client.index * split
    for index = start, stop do
        if data[index] then
            table.insert(worlds, data[index])
        end
    end
    return worlds
end

---@param url string
---@param content any
local function sendWebhook(url, content)
    if url ~= '' then
        local webhook = Webhook.new(url)
        webhook.username = 'Neuroman'
        webhook.avatar_url = 'https://raw.githubusercontent.com/syaarl/Neurotation/main/images/Neuroman.png'
        webhook.content = content
        webhook:send()
    end
end

---@return string
---@nodiscard
local function formatStatus()
    for i, v in pairs(BotStatus) do
        if v == client.status then
            return tostring(i:gsub("_", " "):gsub("^%l", string.upper))
        end
    end
    return "Unknown"
end

---@return string
---@nodiscard
local function emojiRecon()
    if client.status == BotStatus.online then
        return "<a:online:1235638419284037763>"
    end
    return "<a:offline:1238731608220237845>"
end

---@param seconds  number
local function formatSeconds(seconds)
    local days = math.floor(seconds / (24 * 3600))
    local hours = math.floor((seconds % (24 * 3600)) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    return string.format("%d Days %d Hours %d Minutes", days, hours, minutes)
end

---@param task string
local function botInfo(task)
    if webhookURL ~= '' then
        local fields = {
            {
                name = '<:pickaxe:1226659803162611815> Bot Task',
                value = task,
                inline = false
            },
            {
                name = '<:bot:1083907990362529922> Bot Name',
                value = client.name .. ' (' .. client.level .. ')',
                inline = true
            },
            {
                name = emojiRecon() .. ' Bot Status',
                value = formatStatus() .. ' (' .. client:getPing() .. ')',
                inline = true
            },
            {
                name = '<:polishedfossil:1224583845144432711>P Polished Inventory',
                value = getInventory():findItem(4134),
                inline = true
            },
            {
                name = '<:scrollbulletin:1228977435668910151> World Statistic',
                value = '',
                inline = false
            },
            {
                name = '<:Uptime:1156642727811874838> Uptime',
                value = formatSeconds(os.difftime(os.time(), uptime)),
                inline = true
            }
        }
        for _, world in pairs(info) do
            fields[#fields - 1].value = fields[#fields - 1].value ..
                '<:Globe:1179469791086530681> ||' ..
                world .. '|| (<:fossilrock:1228297533449830441> ' .. (fossil[world] or 0) .. ')\n'
        end
        local webhook = Webhook.new(webhookURL)
        webhook.username = 'Neuroman'
        webhook.embed1.use = true
        webhook.embed1.color = math.random(111111, 999999)
        webhook.embed1.description = '**Neurofossil**'
        for _, field in pairs(fields) do
            webhook.embed1:addField(field.name, field.value, field.inline)
        end
        webhook.embed1.thumbnail =
        'https://cdn.discordapp.com/attachments/1231975510523777136/1236607687509147738/pngegg.png?ex=6638a027&is=66374ea7&hm=53f2d79b2a9f4aa78c4f0f097de2395c68033c4995fec84d1da8eec85c0bc741&'
        webhook.embed1.footer.text = '[Lucifer] Neurotation Developed By Shiro\nLast updated: '
        webhook.embed1.footer.icon_url = 'https://raw.githubusercontent.com/syaarl/Neurotation/main/images/footer.png'
        webhook.embed1.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        webhook:edit(messageId)
    end
end


local function reconInfo()
    sendWebhook(webhookStatus,
        emojiRecon() .. ' ' .. client.name .. ' (slot-' .. client.index .. ') status is ' .. formatStatus() ..
        ' @everyone')
end

local function reconnect()
    if client.status ~= BotStatus.online then
        reconInfo()
        sleep(100)
        local sended = false
        local tries = 0
        while client.status ~= BotStatus.online do
            if tries ~= 0 and (tries % 50) == 0 then
                client.auto_reconnect = false
                for i = 1, (60 * 3) do
                    sleep(1000)
                    if client.status == BotStatus.online then
                        break
                    end
                end
                client.auto_reconnect = true
            end
            tries = tries + 1
            if tries % 2 == 1 then
                client:connect()
            end
            for i = 1, 5 do
                sleep(1000)
                if client.status == BotStatus.online then
                    sleep(4000)
                    break
                elseif client.status == BotStatus.account_banned then
                    if not sended then
                        reconInfo()
                        sended = true
                    end
                end
            end
        end
        reconInfo()
    end
end

---@param world string
---@param id? string
local function warp(world, id)
    world = world:upper()
    id = id or ''
    nuked = false
    stuck = false
    if not client:isInWorld(world) then
        local tries = 0
        addEvent(Event.variantlist, function(var, netid)
            if var:get(0):getString() == 'OnConsoleMessage' then
                if var:get(1):getString() == 'That world is inaccessible.' then
                    nuked = true
                    unlistenEvents()
                end
            end
        end)
        while not client:isInWorld(world) and not nuked do
            if tries ~= 0 and (tries % 15) == 0 then
                for i = 1, 60 * 3 do
                    sleep(1000)
                    if client:isInWorld(world) then
                        sleep(4000)
                        break
                    end
                end
            end
            tries = tries + 1
            if (tries % 2) == 1 then
                client:warp(id == '' and world or world .. ('|' .. id))
            end
            for i = 1, 5 do
                listenEvents(1)
                if client:isInWorld(world) then
                    sleep(4000)
                    break
                end
            end
        end
        removeEvent(Event.variantlist)
    end
    if client:isInWorld(world) and id ~= '' then
        local tries = 0
        while getTile(client.x, client.y).fg == 6 and not stuck do
            if tries ~= 0 and (tries % 10) == 0 then
                stuck = true
            end
            tries = tries + 1
            if (tries % 2) == 1 then
                client:warp(id == '' and world or world .. ('|' .. id))
            end
            for i = 1, 5 do
                sleep(1000)
                if getTile(client.x, client.y).fg ~= 6 then
                    break
                end
            end
        end
    end
end

local function isCanFindpath(x, y)
    return (#client:getPath(x, y) == 0 and client:isInTile(x, y)) or
        (#client:getPath(x, y) > 0 and not client:isInTile(x, y))
end

local function reposition(world, id, x, y)
    if client.status ~= BotStatus.online then
        reconnect()
    end
    if client.status == BotStatus.online then
        if world then
            warp(world, id)
        end
        if x and y and isCanFindpath(x, y) then
            while not client:isInTile(x, y) do
                client:findPath(x, y)
                reposition(world, id)
            end
        end
    end
end

local function range(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

---@return TileCache[]
local function getTilesFossil()
    local tiles = {}
    for _, tile in pairs(getTiles()) do
        if tile.fg == 3918 and hasAccess(tile.x, tile.y) > 0 and tile.flags < 4096 then
            table.insert(tiles, { x = tile.x, y = tile.y })
        end
    end
    return tiles
end

local function isPunchable(x, y)
    local tile = getTile(x, y)
    if not tile.fg then return false end
    return tile.fg % 2 == 0 and tile.fg ~= 0 and tile.fg ~= 8 and tile.fg ~= 3918 and hasAccess(x, y) > 0 and
        tile.flags < 4096
end

---@param x number
---@param y number
local function haveRelated(x, y)
    local dirrection = { { 0, 1 }, { -1, 0 }, { 1, 0 }, { -1, -1 },
        { -1, 1 }, { 0, -1 }, { 1, -1 }, { 1, 1 } }
    for _, dir in pairs(dirrection) do
        if isPunchable(dir[1] + x, dir[2] + y) then
            return true
        end
    end
    return false
end

---@param x number
---@param y number
---@return TileCache
local function clossestPath(x, y)
    local clossestTile = {}
    local distances = math.huge
    local rangeY = y - client.y
    local rangeX = x - client.x
    for ye = client.y, y, rangeY >= 0 and 1 or -1 do
        for ex = client.x, x, rangeX >= 0 and 1 or -1 do
            if isCanFindpath(ex, ye) and haveRelated(ex, ye) then
                local distance = range(ex, ye, x, y)
                if distance < distances then
                    clossestTile = { x = ex, y = ye }
                    distances = distance
                    print(distances)
                end
            end
        end
    end
    return clossestTile
end

---@param x number
---@param y number
---@return TileCache?
local function clossestPunch(x, y)
    print('Find Clossest punch')
    local tile = {}
    local distances = math.huge
    local dirrection = { { 0, 1 }, { -1, 0 }, { 1, 0 }, { 0, -1 }, { -1, -1 },
        { -1, 1 }, { 1, -1 }, { 1, 1 } }
    for _, dir in pairs(dirrection) do
        local ex, ye = client.x + dir[1], client.y + dir[2]
        if isPunchable(ex, ye) then
            local distance = range(ex, ye, x, y)
            if distance < distances then
                tile = { x = ex, y = ye }
                distances = distance
            end
        end
    end
    return tile
end

---@param x number
---@param y number
local function successPath(x, y)
    local dirrection = { { 0, 1 }, { -1, 0 }, { 1, 0 },
        { 0, -1 } }
    for _, dir in pairs(dirrection) do
        local ex, ye = (client.x + dir[1]), (client.y + dir[2])
        if ex == x and ye == y then
            return true
        end
    end
    return false
end

---@param url string
---@param content string
---@return string?
local function createMessageID(url, content)
    url = url .. '?wait=1'
    local http = HttpClient.new()
    http.url = url
    http.headers['Content-Type'] = 'application/json'
    http:setMethod(Method.post)
    http.content = [[
    {
        "username":"Neuroman",
        "avatar_url":"https://raw.githubusercontent.com/maysens/Neurotation/main/images/logo.png",
        "embeds": [
            {
                "title":"]] .. content .. [[",
                "color": ]] .. math.random(111111, 999999) .. [[
            }
        ]
    }
]]
    local result = http:request()
    if result.error == 0 then
        local resultData = result.body:match('"id"%s*:%s*"([^"]+)"')
        if resultData then
            return resultData
        end
    else
        print("Request Error: " .. result:getError())
    end
    return nil
end

local function getTools()
    if #storageTools == 0 then
        return error('There is currently no storage available for taking tools.')
    end
    local itemTools = { 3932, 3934 }
    for _, itm in pairs(itemTools) do
        while getInventory():findItem(itm) == 0 do
            botInfo('Taking tools')
            for i, data in pairs(storageTools) do
                local world, id = data, ''
                if world:find(':') then world, id = data:match('(.+):(.+)') end
                warp(world, id)
                if not nuked then
                    if not stuck then
                        for _, object in pairs(getObjects()) do
                            if object.id == itm then
                                local object_x, object_y = math.floor((object.x + 10) * (1 / 32)),
                                    math.floor((object.y + 10) * (1 / 32))
                                while not client:isInTile(object_x, object_y) do
                                    client:findPath(object_x, object_y)
                                    reposition(world, id, object_x, object_y)
                                end
                                if client:isInTile(object_x, object_y) then
                                    client:collectObject(object.oid, 3)
                                    sleep(500)
                                end
                                if getInventory():findItem(itm) > 0 then
                                    while getInventory():findItem(itm) > 1 do
                                        client:moveTo(-1, 0)
                                        sleep(100)
                                        client:setDirection(false)
                                        sleep(500)
                                        client:drop(itm, getInventory():findItem(itm) - 1)
                                        sleep(500)
                                        reposition(world, id)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

local function wear(id)
    while getInventory():findItem(id) > 0 and not getInventory():getItem(id).isActive do
        client:wear(id)
        sleep(500)
    end
end

local function unwear(id)
    while getInventory():findItem(id) > 0 and getInventory():getItem(id).isActive do
        client:unwear(id)
        sleep(500)
    end
end

local function checkFossil(x, y)
    for _, object in pairs(getObjects()) do
        local object_x, object_y = math.floor((object.x + 10) * (1 / 32)), math.floor((object.y + 10) * (1 / 32))
        if x == object_x and y == object_y then
            if object.id == 3936 then
                return true
            end
        end
    end
    return false
end

local function getBrushNRock(World, Id)
    if #storageTools == 0 then
        return error('There is currently no storage available for taking tools.')
    end
    local itemTools = { 4132 }
    if replaceRock then
        table.insert(itemTools, 10)
    end
    for _, itm in pairs(itemTools) do
        if getInventory():findItem(itm) == 0 then
            while getInventory():findItem(itm) == 0 do
                for i, data in pairs(storageTools) do
                    local world, id = data, ''
                    if world:find(':') then world, id = data:match('(.+):(.+)') end
                    warp(world, id)
                    if not nuked then
                        if not stuck then
                            for _, object in pairs(getObjects()) do
                                if object.id == itm then
                                    local object_x, object_y = math.floor((object.x + 10) * (1 / 32)),
                                        math.floor((object.y + 10) * (1 / 32))
                                    if not client:isInTile(object_x, object_y) then
                                        client:findPath(object_x, object_y)
                                        sleep(500)
                                    end
                                    if client:isInTile(object_x, object_y) then
                                        client:collectObject(object.oid, 3)
                                        sleep(500)
                                    end
                                end
                                if getInventory():findItem(itm) > 0 then
                                    print('[' .. client.index .. '] Success taking tools ' .. getInfo(itm).name)
                                    break
                                end
                            end
                        else
                            table.remove(storageTools, i)
                        end
                    else
                        table.remove(storageTools, i)
                    end
                end
            end
            warp(World, Id)
        end
    end
end

---@param x number
---@param y number
---@param num number
local function tileDrop(x, y, num)
    local count = 0
    local stack = 0
    for _, obj in pairs(getObjects()) do
        if ((obj.x + 10) // 32) == x and ((obj.y + 10) // 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    return stack < 20 and count <= (4000 - num)
end

local function isStored()
    local tools = { 4134, 3936 }
    for _, itm in pairs(tools) do
        if getInventory():findItem(itm) >= minimumSave then
            return true
        end
    end
    return false
end

local function storingItems(world, id)
    local tools = { 4134, 3936 }
    if isStored() then
        botInfo('Storing Fossil')
        if #storageSave == 0 then
            return error('There is currently no storage available for storing fossil.')
        end
        for i, data in pairs(storageSave) do
            if isStored() then
                local World, Id = data, ''
                if data:find(':') then World, Id = data:match('(.+):(.+)') end
                warp(World, Id)
                if not nuked then
                    if not stuck then
                        for _, itm in pairs(tools) do
                            for y = 53, 0, -1 do
                                for x = 0, 99 do
                                    if isCanFindpath(x, y) and tileDrop(x, y, getInventory():findItem(itm)) and isCanFindpath(x - 1, y) then
                                        while not client:isInTile(x - 1, y) do
                                            client:findPath(x - 1, y)
                                            reposition(World, Id, x - 1, y)
                                        end
                                        if client:isInTile(x - 1, y) then
                                            while tileDrop(x, y, getInventory():findItem(itm)) and getInventory():findItem(itm) > 0 do
                                                client:setDirection(false)
                                                sleep(500)
                                                client:drop(itm, getInventory():findItem(itm))
                                                sleep(500)
                                                reposition(World, Id, x - 1, y)
                                            end
                                        end
                                    end
                                    if getInventory():findItem(itm) == 0 then
                                        break
                                    end
                                end
                            end
                        end
                    else
                        table.remove(storageSave, i)
                    end
                else
                    table.remove(storageSave, i)
                end
            end
        end
        warp(world, id)
    end
end

local function foundY(x)
    for y = 53, 0, -1 do
        if isCanFindpath(x, y) and not isCanFindpath(x, y + 1) then
            return y
        end
    end
end

local function main()
    sleep((client.index - 1) * 500)
    client.move_interval = 100
    client.move_range = 8
    client.collect_range = 3
    client.auto_collect = false
    local success, result = pcall(spreadWorld)
    if not success or type(result) ~= 'table' then
        return error(result, 0)
    end
    while not messageId and webhookURL ~= '' do
        messageId = createMessageID(webhookURL, 'Creating message id for bot ' .. client.name)
    end
    worldList = result
    for _, data in pairs(worldList) do
        warp(data.world, data.id)
        table.insert(info, data.world)
        if not nuked then
            if not stuck then
                botInfo('Start harvesting ' .. data.world)
                local tiles = getTilesFossil()
                fossil[data.world] = #tiles
                for i, tile in pairs(tiles) do
                    botInfo(i .. '. Harvesting fossil at path ' .. tile.x .. ':' .. tile.y)
                    local y = foundY(tile.x)
                    while not client:isInTile(tile.x, y) do
                        client:findPath(tile.x, y)
                        reposition(data.world, data.id, tile.x, y)
                    end
                    ---@type TileCache
                    local path = { x = client.x, y = client.y }
                    while not successPath(tile.x, tile.y) do
                        path = clossestPath(tile.x, tile.y)
                        while not client:isInTile(path.x, path.y) do
                            client:findPath(path.x, path.y)
                            reposition(data.world, data.id, path.x, path.y)
                        end
                        if successPath(tile.x, tile.y) then
                            break
                        end
                        local pos = clossestPunch(tile.x, tile.y)
                        if not pos or not pos.x or not pos.y then
                            break
                        end
                        while isPunchable(pos.x, pos.y) do
                            client:hit(pos.x, pos.y)
                            sleep(180)
                            reposition(data.world, data.id, path.x, path.y)
                        end
                    end
                    if successPath(tile.x, tile.y) then
                        while getTile(tile.x, tile.y).flags == 0 and getTile(tile.x, tile.y).fg == 3918 do
                            for i = 1, 15 do
                                if getTile(tile.x, tile.y).flags == 0 and getTile(tile.x, tile.y).fg == 3918 then
                                    if getInventory():findItem(3932) == 0 then
                                        getTools()
                                        reposition(data.world, data.id, path.x, path.y)
                                    end
                                    wear(3932)
                                    client:hit(tile.x, tile.y)
                                    sleep(delayPunch)
                                    reposition(data.world, data.id, path.x, path.y)
                                else
                                    break
                                end
                            end
                            sleep(math.random(7000, 8000))
                        end
                        unwear(3932)
                        while getTile(tile.x, tile.y).flags == 64 and getTile(tile.x, tile.y).fg == 3918 do
                            if getInventory():findItem(3934) == 0 then
                                getTools()
                                reposition(data.world, data.id, path.x, path.y)
                            end
                            wear(3934)
                            client:hit(tile.x, tile.y)
                            sleep(math.random(170, 180))
                            reposition(data.world, data.id, path.x, path.y)
                        end
                        getBrushNRock(data.world, data.id)
                        reposition(data.world, data.id, path.x, path.y)
                        while checkFossil(tile.x, tile.y) do
                            client:place(tile.x, tile.y, 4132)
                            sleep(math.random(170, 180))
                            reposition(data.world, data.id, path.x, path.y)
                        end
                        client.auto_collect = true
                        sleep(1500)
                        if replaceRock then
                            while getTile(tile.x, tile.y).fg == 0 do
                                client:place(tile.x, tile.y, 10)
                                sleep(180)
                                reposition(data.world, data.id, path.x, path.y)
                            end
                        end
                        client.auto_collect = false
                        unwear(3934)
                        unwear(3932)
                        storingItems(data.world, data.id)
                    else
                        botInfo('Failed to harvesting at path ' .. tile.x .. ':' .. tile.y)
                        sleep(1000)
                    end
                end
                botInfo('Finished ' .. data.world)
            else
                fossil[data.world] = 'STUCK'
            end
        else
            fossil[data.world] = 'NUKED'
        end
    end
    if removeBots then
        removeBot()
    end
end

main()