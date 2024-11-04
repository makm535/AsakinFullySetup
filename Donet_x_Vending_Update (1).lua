--============ | AUTOSEND BY TAMASTORE | ===============
local NamaBotWebhok   = "Tamasoko" -- Name bot webhoook (optional)
local ColorBotWebhook = "0x00FFFF" -- Color Hex
local Banner          = "https://cdn.discordapp.com/attachments/1203988146564497459/1206231707850641488/standard.gif?ex=65db41d1&is=65c8ccd1&hm=8e02baa662af7a38b58b8b82961a4079de61ec3fa0887fd0117bbfdc272a7c3c&"
--========== | Setting Status Bot | ===================
local StatusWebhook   = true -- If true bot use webhook status
local MessageId       = "MessageID" -- MessageID Webhook Status
local WebhookStatus   = "Webhook" -- Webhook For Status Information
--========= | Setting Donation Log | ==================
local VendingSistem   = true -- You can true and false
local World           = "World Depo" -- Your world depo
local webhookBal      = "Webhook" -- Webhook for donation log
--============= | Setting Emoji | =====================
local Crown   = "<a:diamondcrown:1197521607061676043>"
local Vending = "<:VendingM:1204771583839969322>"
local WL      = "<:WL:1151151006856532058>"
local Status  = "<:monitor:1197853474973552691>"
local Clock   = "<:clocknei_2:1206514211178553384>"
local Globe   = "<:3369earthfreezemen:1183244849869242408>"
local Online  = "<a:online:1197850211914088448>"
local Offline = "<a:offline:1197850388846616586>"
local DL      = "<a:shinydl:1190166079700475954>"
local BGL     = "<a:shinybgl:1190166261259321466>"
local Faq     = "<a:faq:1174339877333119068>"
local Bot     = "<:Bot:1170169208273903677>"
local Balance = "<a:productdet:1174338594819821639>"
--============= | DON'T TOUCH | =====================
bot = getBot()
function WorldTime()
    Farm_Times = os.time() - Depo_Time
    Days = tostring(math.floor(Farm_Times / 86400))
    Hourw = tostring(math.floor(Farm_Times % 86400 / 3600))
    Minutew = tostring(math.floor((Farm_Times % 86400 % 3600) / 60))
    Secondw = tostring(math.floor((Farm_Times % 86400 % 3600) % 60))
    Timew = tostring(Days.." Days "..Hourw.." Hours "..Minutew.." Minutes "..Secondw.." Seconds ")
    return Timew
end

function pshell2(desc)
	wh = Webhook.new(webhookBal)
	wh.username = NamaBotWebhok
	wh.embed1.use = true
	wh.embed1.title = Crown .. " DONATION LOGS ".. Crown
	wh.embed1.footer.text = os.date("!%d %B, %Y at %I:%M %p | Made By Tama Store", os.time() + 7 * 60 * 60)
	wh.embed1.description = desc
	wh.embed1.color = ColorBotWebhook
  	wh:send()
end

function pshell(desc)
	wh = Webhook.new(webhookBal)
  	wh.username = NamaBotWebhok
  	wh.embed1.use = true
  	wh.embed1.title = Vending .. " VENDING LOGS " .. Vending
  	wh.embed1.footer.text = os.date("!%d %B, %Y at %I:%M %p | Made By Tama Store", os.time() + 7 * 60 * 60)
  	wh.embed1.description = desc
  	wh.embed1.color = ColorBotWebhook
  	wh:send()
end

function status(desc)
	wh = Webhook.new(WebhookStatus)
  	wh.username = NamaBotWebhok
  	wh.embed1.use = true
  	wh.embed1.title = Crown .. " STATUS INFORMATION " .. Crown
  	wh.embed1.description = "**[" .. Clock .. "] Last Update: <t:" .. os.time() .. ":R> \n=============================**\n".. desc .."\n**=============================\n[".. Clock .."] Uptime:** ".. WorldTime() .."\n**=============================**"
  	wh.embed1.color = ColorBotWebhook
	wh.embed1.image = Banner
  	wh:edit(MessageId)
end

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" and variant:get(1):getString():find("bought") then
        local message = variant:get(1):getString()
		if VendingSistem then
			if message:find("World Locks") and message:find("bought") then
				if not (message:find("OID") or message:find("CP") or message:find("PL") or message:find("CT") or message:find("SB") or message:find("MSG") or message:find("BC")) then
					player = message:gsub("`", ""):match("9(.+) bought")
					jumlah = message:match("for (.+) World Locks")
					item = message:match("bought (.+) for")
					paymentType = "WorldLock " .. WL
					bot:say("Thanks You!")
					pshell2("**[".. Faq .."] BOUGHT: " .. item .. "\n[" .. Bot .. "] GrowID: " .. player .. " \n[" .. Balance .. "] Amount: " .. jumlah .. " " .. paymentType .. " **")
				else
					bot:say("Mau Ngapain Banh?!")
				end
			end
		end
	elseif variant:get(0):getString() == "OnConsoleMessage" and variant:get(1):getString():find("into the Donation Box") then
        local message = variant:get(1):getString()
		if message:find("into the Donation Box") and (message:find("World Lock") or message:find("Diamond Lock") or message:find("Blue Gem Lock")) then
			if not (message:find("OID") or message:find("CP") or message:find("PL") or message:find("CT") or message:find("SB") or message:find("MSG") or message:find("BC")) then
       			if message:find("World Lock") then
					player = message:match("%[+%p+w+%w+"):sub(6)
					jumlah = message:match("s+%s+%p+%d+"):sub(5)
					paymentType = "WorldLock " .. WL
				elseif message:find("Diamond Lock") then
					player = message:match("%[+%p+w+%w+"):sub(6)
					jumlah = message:match("s+%s+%p+%d+"):sub(5)
					paymentType = "DiamondLock " .. DL
				elseif message:find("Blue Gem Lock") then
					player = message:match("%[+%p+w+%w+"):sub(6)
					jumlah = message:match("s+%s+%p+%d+"):sub(5)
					paymentType = "BlueGemLock " .. BGL
        		end
				bot:say("Thanks You!")
				pshell2("**[" .. Bot .. "] GrowID: " .. player .. " \n[" .. Balance .. "] Amount: " .. jumlah .. " " .. paymentType .. " **")
			else
				bot:say("Mau Ngapain Banh?!")
			end
		end
    end
end)

addEvent(Event.mod_enter, function()
	if WebhookStatus then
		status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Mod_Entered) ".. Offline .."**")
	end
end)

function start()
	pshell2("**SCRIPT STARTED**")
	Depo_Time = os.time()
	while true do
		if bot.status == 1 then
			if bot:isInWorld(World:upper()) then
				if StatusWebhook then
					status("**[".. Bot .."] Name: " .. getBot().name .. " [".. getBot().level .."] (".. bot:getPing() ..")\n[".. Status .."] Status: Online ".. Online .."\n=============================\n[".. Globe .."] World: ".. World .."\n[".. Balance .."]**")
				end
				listenEvents(30)
			else
				bot:warp(World:upper())
				sleep(15000)
			end
		else
			if StatusWebhook then
				if bot.status == 0 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Offline) ".. Offline .."**")
				elseif bot.status == 2 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Wrong_Password) ".. Offline .."**")
				elseif bot.status == 3 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Account_Banned) ".. Offline .."**")
				elseif bot.status == 4 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Location_Banned) ".. Offline .."**")
				elseif bot.status == 5 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Version_Update) ".. Offline .."**")
				elseif bot.status == 6 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(AAP) ".. Offline .."**")
				elseif bot.status == 7 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Server_Overload) ".. Offline .."**")
				elseif bot.status == 8 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(To_Many_Login) ".. Offline .."**")
				elseif bot.status == 9 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Maintenance) ".. Offline .."**")
				elseif bot.status == 10 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Server_Busy) ".. Offline .."**")
				elseif bot.status == 12 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Http_Block) ".. Offline .."**")
				elseif bot.status == 15 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Error_Connecting) ".. Offline .."**")
				elseif bot.status == 16 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Login_Fail) ".. Offline .."**")
				elseif bot.status == 18 then
					status("**[".. Bot .."] Name: " .. getBot().name .. "\n[".. Status .."] Status: Offline(Mod_Entered) ".. Offline .."**")
				end
			end
			bot:connect()
			sleep(30000)
		end
	end
end
start()