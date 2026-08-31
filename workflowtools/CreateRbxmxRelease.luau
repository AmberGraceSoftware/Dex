--!strict
--[[
    Lune script for generating .rbxmx releases
]]

local fs = (require :: any)("@lune/fs")
local process = (require :: any)("@lune/process")

local function main()
    process.exec("mkdir", {"temp"})
    process.exec("cp", {"-r", "src", "temp"})
    process.exec("cp", {"aftman.toml", "temp"})
    process.exec("cp", {"release.project.json", "temp"})
    process.exec("cp", {"release.project.json", "temp"})
    local licenseContent = fs.readFile("LICENSE")
    local out = "return [=[\n" .. licenseContent ..  "\n]=]"
    fs.writeFile("temp/src/LICENSE.luau", out)
    process.exec("cd", {"temp"})
    process.exec("rojo", {"build", "--output=Dex.rbxmx", "temp/release.project.json"})
    process.exec("rm", {"-rf", "temp"})
end

main()