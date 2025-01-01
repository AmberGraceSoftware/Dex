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
    local flagSet = {}
    local getFlagsResult = process.spawn("luau-lsp", {"--show-flags"})
    if getFlagsResult.ok then
        print(getFlagsResult.stdout)
        for flag in getFlagsResult.stdout:gmatch("([a-zA-Z0-9_]+)=") do
            flagSet[flag] = true
        end
    else
        error(getFlagsResult.stderr)
    end
    local args = {
        "analyze",
        "--sourcemap=sourcemap.json",
        "--defs=globalTypes.d.lua",
        "--defs=testez.d.luau"
    }
    for flag, value in fflags do
        local luauFlag = flag:match("^FFlag(.*)")
        if luauFlag and flagSet[luauFlag] then
            table.insert(
                args,
                "--flag:" .. luauFlag .. "=" .. tostring(value)
            )
        end
    end
    table.insert(args, "src")
    table.insert(args, "tests")
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