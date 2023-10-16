--!strict
--[[
    Lune script for generating .rbxmx releases
]]

local fs = (require :: any)("@lune/fs")
local process = (require :: any)("@lune/process")

local function main()
    process.spawn("mkdir", {"temp"})
    process.spawn("cp", {"-r", "src", "temp"})
    process.spawn("cp", {"aftman.toml", "temp"})
    process.spawn("cp", {"release.project.json", "temp"})
    process.spawn("cp", {"release.project.json", "temp"})
    local licenseContent = fs.readFile("LICENSE")
    local out = "return [=[\n" .. licenseContent ..  "\n]=]"
    fs.writeFile("temp/src/LICENSE.luau", out)
    process.spawn("cd", {"temp"})
    process.spawn("rojo", {"build", "--output=Dex.rbxmx", "temp/release.project.json"})
    process.spawn("rm", {"-rf", "temp"})
end

main()