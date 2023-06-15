--!strict
--[[
    Lune script which validates the testing_proof_checksum.txt checksum file by
    checking the "success" flag and comparing the checksum with the file
    structure. Emits detailed warnings on whether the checksum matches (and how
    to run unit tests manually), as well as the successes/failures/skipped tests
    encountered.
]]

local fs = (require :: any)("@lune/fs")

type SourceMap = {
    sourcePath: string,
    robloxPath: string
}

local PROOF_FILE_PATH = "testing_proof_checksum.txt"
local SOURCE_ROOTS: {SourceMap} = {
    {
        sourcePath = "src",
        robloxPath = "ReplicatedStorage.Packages.Dec",
    },
    {
        sourcePath = "tests",
        robloxPath = "ReplicatedStorage.DecTests"
    }
}

-- Polynomial rolling hash checksum
local function generateSourceFileChecksum(sourceStrings: {string})
    local base = 256
    local prime = 1000000007

    local hashValues = {}
    local totalHash = 0

    -- Calculate the hash value for each string
    for _, str in sourceStrings do
        local hash = 0
        for i = 1, #str do
            local charValue = string.byte(str, i)
            hash = (hash * base + charValue) % prime
        end
        table.insert(hashValues, hash)
        totalHash = (totalHash + hash) % prime
    end

    -- Calculate the final hash value using polynomial rolling hash
    for _, hash in ipairs(hashValues) do
        totalHash = (totalHash * base + hash) % prime
    end

    -- Convert hash to hexadecimal string
    return string.format("%x", totalHash)
end

local function isLuauFile(fileNameWithExt: string)
    return fileNameWithExt:match(".+%.luau?$") ~= nil
end

local function extractRojoFileStem(fileNameWithExt: string): string
    local withoutExt = fileNameWithExt:match("(.+)%.luau?$") :: string
    return withoutExt:match("(.+)%.server$")
        or withoutExt:match("(.+)%.client$")
        -- or withoutExt:match("(.+)%.spec$")
        or withoutExt
end

local function captureSourceFileStrings(rootSourceMaps: {SourceMap})
    -- Collect source file paths recursively using a mutable arrays of strings
    local allSourceFiles: {SourceMap} = {}
    do
        local parentPaths = {} :: {string}
        local parentRobloxPaths = {} :: {string}
        local function visitChildPaths()
            local sourcePath = table.concat(parentPaths, "/")
            if fs.isDir(sourcePath) then
                local pathIndex = #parentPaths + 1
                for _, name in fs.readDir(sourcePath) do
                    parentPaths[pathIndex] = name
                    parentRobloxPaths[pathIndex] = name
                    visitChildPaths()
                end
                parentPaths[pathIndex] = nil
                parentRobloxPaths[pathIndex] = nil
            elseif fs.isFile(sourcePath) then
                local fileName = parentPaths[#parentPaths]
                if not isLuauFile(fileName) then
                    return
                end
                local fileStem = extractRojoFileStem(fileName)
                if fileStem then
                    if fileStem == "init" then
                        parentRobloxPaths[#parentPaths] = nil
                    else
                        parentRobloxPaths[#parentPaths] = fileStem
                    end
                    table.insert(allSourceFiles, {
                        sourcePath = sourcePath,
                        robloxPath = table.concat(parentRobloxPaths, ".")
                    })
                end
            end
        end
        for _, root in rootSourceMaps do
            parentPaths = {root.sourcePath}
            parentRobloxPaths = {root.robloxPath}
            visitChildPaths()
        end
    end

    table.sort(allSourceFiles, function(a, b)
        return a.robloxPath < b.robloxPath
    end)

    local sourceStrings = table.create(#allSourceFiles * 2)
    for _, sourceMap in allSourceFiles do
        table.insert(sourceStrings, sourceMap.robloxPath)
        table.insert(sourceStrings, fs.readFile(sourceMap.sourcePath))
    end

    return sourceStrings
end

local function ValidateProofOfTesting()
    -- Validate checksum file format and extract components
    if not fs.isFile(PROOF_FILE_PATH) then
        error("Validation Error: No file exists in this directory named '" .. 
            PROOF_FILE_PATH .. "'") 
    end
    local proofChecksum: string = fs.readFile(PROOF_FILE_PATH)
    local sourceChecksum, successesStr, failsStr, skipsStr, successFlag
        = proofChecksum:match("([%a%d]+)_(%d+)_(%d+)_(%d+)_(%a+)")
    local successes, fails, skips = tostring(successesStr), tostring(failsStr),
        tostring(skipsStr)
    if
        not sourceChecksum
        or not successes
        or not fails
        or not skips
        or not successFlag
    then
        error("Validation Error: Proof of testing file '" .. PROOF_FILE_PATH
            .. "' does not contain a valid proof checksum!")
    end

    -- Calculate and compare with current file structure checksum
    local expectedChecksum = generateSourceFileChecksum(
        captureSourceFileStrings(SOURCE_ROOTS))
    if expectedChecksum ~= sourceChecksum then
        error("Validation Error: Some source code for Dec has changed since " .. 
            "the last time unit tests were ran!\n\nPlease run unit tests " .. 
            "manually and paste the proof checksum output into the '" ..
            PROOF_FILE_PATH .. "' file at the root of the Dec project " .. 
            "directory.\n\n See Dec's readme file for more details.\n\n" .. 
            `Current checksum: {sourceChecksum}; Expected: {expectedChecksum}`
        )
    end
    
    -- Verify successes/failures
    if successFlag == "success" then
        print("All unit tests have passed!\n\n" ..
            `Successes: {successes}; Failures: {fails}; Skipped: {skips}`)
    else
        error("Validation Error: Some unit tests have failed! Please run unit" ..
            "tests manually to see more details.\n\n" ..
            `Successes: {successes}; Failures: {fails}; Skipped: {skips}`)
    end
end

return ValidateProofOfTesting()