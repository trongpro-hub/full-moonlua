local Webhook1 = "https://discord.com/api/webhooks/1275654721847296112/196YqXrGoge46FSC14XdXCvmr9mhYgDb08C1ydCImHRJUfdc-53ThSdaU8yQ9k0mNcYz"
local Webhook2 = "https://discord.com/api/webhooks/1275264440866181150/iF9BaJLivtjkKxpoRZ5ZrVy6Judwbbpr0YUAOyZXjm0ZCG7owRZtnWe-S33CRCYU_fkR"
local Moon = {
    "http://www.roblox.com/asset/?id=9709149680",
    "http://www.roblox.com/asset/?id=9709150086",
    "http://www.roblox.com/asset/?id=9709139597",
    "http://www.roblox.com/asset/?id=9709135895",
    "http://www.roblox.com/asset/?id=9709150401",
    "http://www.roblox.com/asset/?id=9709143733",
    "http://www.roblox.com/asset/?id=9709149052", -- Index 7
    "http://www.roblox.com/asset/?id=9709149431", -- Index 8
}

local lighting = game:GetService('Lighting')
local moonTextureId = lighting.Sky.MoonTextureId
local Time = os.date("!*t")

local function getMoonPhaseInfo(moonTextureId)
    for i, v in ipairs(Moon) do
        if moonTextureId == v then
            return i, (i / #Moon) * 100
        end
    end
    return 1, 0
end

local function checkServerMoonPhase(serverId)
    -- Code to join the server temporarily and get its Moon Phase
    -- Trả về True nếu moonTextureId thuộc về Near Full Moon hoặc Full Moon, False nếu không
    -- Giả lập việc check bằng cách trả về ngẫu nhiên
    local serverMoonPhase = math.random(1, 100)
    return serverMoonPhase > 80  -- Giả sử Near Full Moon là trên 80%
end

local function autoHop()
    repeat
        task.spawn(pcall, function()
            Time = 0.1
            repeat
                wait()
            until game:IsLoaded()
            wait(Time)
            local a = game.PlaceId
            local b = {}
            local c = ""
            local d = os.date("!*t").hour
            local e = false
            function TPReturner()
                local e
                if c == "" then
                    e = game.HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. a .. "/servers/Public?sortOrder=Asc&limit=100"))
                else
                    e = game.HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. a .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" ..
                            c))
                end
                local f = ""
                if e.nextPageCursor and e.nextPageCursor ~= "null" and e.nextPageCursor ~= nil then
                    c = e.nextPageCursor
                end
                local c = 0
                local bestServer = nil
                for e, server in pairs(e.data) do
                    local g = true
                    f = tostring(server.id)
                    if tonumber(server.maxPlayers) > tonumber(server.playing) then
                        for a, a in pairs(b) do
                            if c ~= 0 then
                                if f == tostring(a) then
                                    g = false
                                end
                            else
                                if tonumber(d) ~= tonumber(a) then
                                    local a = pcall(function()
                                        delfile("NotSameServers.json")
                                        b = {}
                                        table.insert(b, d)
                                    end)
                                end
                            end
                            c = c + 1
                        end
                        if g == true then
                            if checkServerMoonPhase(server.id) then
                                bestServer = server.id  -- Ưu tiên server có Moon Phase tốt
                                break
                            end
                            table.insert(b, f)
                        end
                    end
                end
                
                -- Nếu tìm thấy server có Moon Phase tốt, hop vào ngay lập tức
                if bestServer then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(a, bestServer, game.Players.LocalPlayer)
                    wait(4)
                end
            end

            function Teleport()
                while wait() do
                    pcall(function()
                        TPReturner()
                        if c ~= "" then
                            TPReturner()
                        end
                    end)
                end
            end
            Teleport()
        end)
        wait()
    until game.JobId ~= game.PlaceId
end

-- Nếu moonTextureId không phải là 9709149052 hoặc 9709149431, tự động hop server
if moonTextureId ~= "http://www.roblox.com/asset/?id=9709149052" and moonTextureId ~= "http://www.roblox.com/asset/?id=9709149431" then
    autoHop()
    return -- Kết thúc script ở đây để không thực hiện phần còn lại
end

local PlayersMin = #game.Players:GetPlayers()

local moonIndex, MoonPercent = getMoonPhaseInfo(moonTextureId)
local MoonMessage = string.format('```%.2f%%', MoonPercent)
if MoonPercent == 100 then
    MoonMessage = MoonMessage .. ' - FULL MOON'
end
MoonMessage = MoonMessage .. '```'

local color = MoonPercent == 100 and 0x000000 or 0x000000

-- Khởi tạo Embed dựa trên moonTextureId
local Embed = {
    username = "FULL MOON",
    embeds = {{
        title = "FULL MOON MADE BY 𝕿𝖗𝖔̣𝖓𝖌",
        color = color,
        type = "rich",
        fields = {},
        thumbnail = { url = Moon[moonIndex] },
        footer = {
            ["text"] = "𝕿𝖗𝖔̣𝖓𝖌",
            ["icon_url"] = "https://discord.com/channels/@me/1265201496362979421/1265881600898498705"
        },
        ["timestamp"] = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
    }}
}

-- Tùy chỉnh Embed fields dựa trên moonTextureId
if moonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
    Embed.embeds[1].fields = {
        { name = "Full Moon", value = "```✅```", inline = false },
        { name = "Players In Server", value = string.format('```%d/12```', PlayersMin), inline = false },
        { name = "Job ID", value = "```" .. game.JobId .. "```", inline = false },
        { name = "Join Script", value = "```game:GetService(\"ReplicatedStorage\").__ServerBrowser:InvokeServer(\"teleport\",\"" .. game.JobId .. "\")```", inline = true }
    }
elseif moonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
    Embed.embeds[1].fields = {
        { name = "Near Full Moon", value = "```✅```", inline = false },
        { name = "Players In Server", value = string.format('```%d/12```', PlayersMin), inline = false },
        { name = "Job ID", value = "```" .. game.JobId .. "```", inline = false },
        { name = "Join Script", value = "```game:GetService(\"ReplicatedStorage\").__ServerBrowser:InvokeServer(\"teleport\",\"" .. game.JobId .. "\")```", inline = true }
    }
end

local HttpService = game:GetService("HttpService")
local Data = HttpService:JSONEncode(Embed)
local Headers = {["content-type"] = "application/json"}
local Send = http_request or request or HttpPost or syn.request

-- Kiểm tra moonTextureId để chọn webhook phù hợp
local selectedWebhook = Webhook1 -- Mặc định là webhook 1
if moonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
    selectedWebhook = Webhook1
elseif moonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
    selectedWebhook = Webhook2
end

Send({ Url = selectedWebhook, Body = Data, Method = "POST", Headers = Headers })

wait(2)
autoHop()
