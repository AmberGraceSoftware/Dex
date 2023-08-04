--!strict
--[[
    Runs the latest Luau LSP release with synced-up FFlags.

    Requires globalTypes.d.lua to be downloaded into the root project directory
]]

local CURRENT_FFLAGS_API =
    "https://clientsettingscdn.roblox.com/v1/settings/application?applicationName=PCDesktopClient"

local net = (require :: any)("@lune/net")
local process = (require :: any)("@lune/process")

local function RunLuauLSP()
    -- Generate fflag parameter list
    local response = net.request(CURRENT_FFLAGS_API)
    local fflags = net.jsonDecode(response.body).applicationSettings

    -- Build shell command
    local args = {
        "analyze",
        "tests",
        "src",
        "--sourcemap=sourcemap.json",
        "--definitions=globalTypes.d.lua",
        "--definitions=testez.d.luau"
    }
    for flag, value in fflags do
        local luauFlag = flag:match("^FFlag(Luau.*)")
        if luauFlag then
            table.insert(
                args,
                "--flag:" .. luauFlag .. "=" .. tostring(value)
            )
        end
    end
    print("luau-lsp " .. table.concat(args, " "))
    local result = process.spawn("luau-lsp", args)
    if result.ok then
        print("Luau LSP exited with no errors")
        print(result.stdout)
    else
        error(result.stderr)
    end
end

return RunLuauLSP()