local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local placeId = game.PlaceId
local jobId = game.JobId

local http_request = request or http_request or syn and syn.request

local executor = "Unknown Executor"
pcall(function()
    if identifyexecutor then
        executor = identifyexecutor()
    end
end)

local device = "PC"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    device = "Mobile"
end

local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    gameName = info.Name
end)

local display_name = LocalPlayer.DisplayName
local username = LocalPlayer.Name
local user_id = LocalPlayer.UserId
local account_age = LocalPlayer.AccountAge
local creation_date = os.date("%x", os.time() - (account_age * 86400))

local join_script = 'game:GetService("TeleportService"):TeleportToPlaceInstance('..placeId..',"'
    ..jobId..'", game.Players.LocalPlayer)'

local webhook_url = "YOUR_WEBHOOK_URL_HERE"

local embed_data = {
    ["title"] = gameName .. " - Profile Link",
    ["url"] = "https://www.roblox.com/users/" .. user_id .. "/profile",
    ["color"] = 7506394,

    ["fields"] = {
        {
            ["name"] = "Roblox Information",
            ["value"] = "```\n" ..
                        "Display: " .. display_name .. "\n" ..
                        "Username: " .. username .. "\n" ..
                        "UserID: " .. user_id .. "\n" ..
                        "Creation date: " .. creation_date .. "\n" ..
                        "Account age: " .. account_age .. " days```",
            ["inline"] = false
        },
        {
            ["name"] = "Context",
            ["value"] =
                "**Executor:** `" .. executor .. "`\n" ..
                "**Device:** `" .. device .. "`\n" ..
                "**Job ID:** `" .. jobId .. "`",
            ["inline"] = false
        },
        {
            ["name"] = "Server Join Script",
            ["value"] = "```lua\n"..join_script.."```",
            ["inline"] = false
        }
    },

    ["footer"] = {
        ["text"] = "execution logged"
    },

    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

local payload = HttpService:JSONEncode({
    ["embeds"] = {embed_data}
})

if webhook_url ~= "YOUR_WEBHOOK_URL_HERE" and http_request then
    pcall(function()
        http_request({
            Url = webhook_url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end
