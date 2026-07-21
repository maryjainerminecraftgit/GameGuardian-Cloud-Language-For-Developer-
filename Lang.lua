local GITHUB_USER = "YourGitHubName"
local GITHUB_REPO = "YourGitHubRepo"
local GITHUB_BRANCH = "YourGitHubBranch"

local function loadLang(code)
    local url = "https://raw.githubusercontent.com/"
        .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/"
        .. GITHUB_BRANCH .. "/lang/" .. code .. ".json"
    local ok, res = pcall(function()
        return gg.makeRequest(url).content
    end)
    if not ok or not res or res == "" then
        local url2 = "https://raw.githubusercontent.com/"
            .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/"
            .. GITHUB_BRANCH .. "/lang/yl.json"
        local ok2, res2 = pcall(function()
            return gg.makeRequest(url2).content
        end)
        if ok2 and res2 then res = res2 else return nil end
    end
    local t = {}
    for k, v in res:gmatch('"([%w_]+)"%s*:%s*"(.-)"') do
        t[k] = v
    end
    return t
end

local langCodes = {
    "yl"
}

local langNames = {
    "Your Language"
}

local langChoice = gg.choice(langNames, nil, "🌐 Select your language")
if not langChoice then langChoice = 1 end

gg.toast("Loading language...")
local L = loadLang(langCodes[langChoice])

if not L then
    gg.alert("❌ Your internet connection is unstable. Check your internet connection or restart your VPN ❌")
    os.exit()
end

gg.toast(L["lang_loaded"])

local function safeCall(fn)
    local ok, err = pcall(fn)
    if not ok then
        gg.toast("⚠️ Error: " .. tostring(err))
        gg.clearResults()
    end
end

local function openMenu(items, title, backIndex)
    while true do
        local labels = {}
        for _, item in ipairs(items) do
            table.insert(labels, item[1])
        end
        local ch = gg.choice(labels, nil, title)
        if ch == nil or ch == backIndex then return end
        local action = items[ch] and items[ch][2]
        if action then action() end
    end
end

function MainMenu()
    openMenu({
        {L["cups_menu"],      CupsMenu},
        {L["adventure_menu"], AdventureMenu},
        {L["shop_menu"],      ShopMenu},
        {L["exit"],           exitScript}
    }, L["main_menu"], 4)
    exitScript()
end

while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        MainMenu()
    end
    gg.sleep(100)
end
