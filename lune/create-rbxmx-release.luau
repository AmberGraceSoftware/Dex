--!strict
--[[
    Lune script for generating .rbxmx releases
]]

local fs = (require :: any)("@lune/fs")
local process = (require :: any)("@lune/process")

local function main()
    if fs.isDir("temp") then
        fs.removeDir("temp", true)
    end
    fs.writeDir("temp")
    fs.copy("src", "temp/src", true)
    fs.copy("aftman.toml", "temp/aftman.toml")
    fs.copy("release.project.json", "temp/release.project.json")
    fs.copy("default.project.json", "temp/default.project.json")
    local licenseContent = fs.readFile("LICENSE")
    local out = "return [=[\n" .. licenseContent ..  "\n]=]"
    fs.writeFile("temp/src/LICENSE.luau", out)
    process.exec("rojo", {"build", "--output=Dex.rbxmx", "release.project.json"}, {
        cwd = "temp",
    })
    fs.copy("temp/Dex.rbxmx", "Dex.rbxmx", true)
    fs.removeDir("temp", true)
end

main()