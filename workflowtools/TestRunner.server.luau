--!strict
--[[

Run this TestRunner script on the command line in Roblox Studio. The output
will be a "proof" checksum, which should then be copied and pasted into
testing_proof_checksum.txt in Dec's root project folder before a PR is merged.

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

type TestResults = {
    errors: {string},
    failureCount: number,
    skippedCount: number,
    successCount: number,
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

local function captureSourceFileStrings(rootInstances: {Instance})
    local objects: {ModuleScript} = {}
    for _, root in rootInstances do
        if root:IsA("ModuleScript") then
            table.insert(objects, root)
        end
        for _, descendant in root:GetDescendants() do
            if descendant:IsA("ModuleScript") then
                table.insert(objects, descendant)
            end
        end
    end

    table.sort(objects, function(a, b)
        return a:GetFullName() < b:GetFullName()
    end)

    local sourceStrings = table.create(#objects * 2)
    for _, sourceFile in objects do
        table.insert(sourceStrings, sourceFile:GetFullName())
        table.insert(sourceStrings, sourceFile.Source)
    end

    return sourceStrings
end

local function TestRunner()
    -- Generate a checksum of the source code
    local sourceRoots = {ReplicatedStorage.DecTests,
    ReplicatedStorage.Packages.Dec}
    local sourceChecksum = generateSourceFileChecksum(
        captureSourceFileStrings(sourceRoots)
    )

    -- Copy / hide old source trees to de-cache modules for re-runs in studio
    local tempRoots = {}
    local oldRootParents = {}
    for _, root in sourceRoots do
        local newRoot = root:Clone()
        table.insert(tempRoots, newRoot)
        newRoot.Parent = root.Parent
        oldRootParents[root] = root.Parent
        root.Parent = nil
    end
    
    -- Run and intercept default TestEZ output
    local testResults: TestResults? = nil
    local interceptReporter = {
        report = function(results: TestResults)
            TestEZ.Reporters.TextReporter.report(results)
            testResults = results
        end
    }
    TestEZ.TestBootstrap:run({ReplicatedStorage.DecTests}, interceptReporter)

    -- Put old modules back into place and delete cloned ones
    for _, root in tempRoots do
        root:Destroy()
    end
    for root, parent in oldRootParents do
        root.Parent = parent
    end

    -- Output a final "proof of testing" checksum
    task.defer(function()
        local success = false
        if testResults then
            success = (testResults.skippedCount == 0)
                and (testResults.failureCount == 0)
                and (testResults.successCount > 0)
        end
        local success_str = if success then "success" else "fail"
        local proof_checksum
        if testResults then
            proof_checksum = string.format(
                "%s_%d_%d_%d_%s",
                sourceChecksum,
                testResults.successCount,
                testResults.failureCount,
                testResults.skippedCount,
                success_str
            )
        else
            proof_checksum = string.format(
                "%s_0_0_0_%s",
                sourceChecksum,
                success_str
            )
        end
        print("\n\tProof-of-testing checksum (paste into " ..
            "'testing_proof_checksum.txt' file in Dec's root project" .. 
            "directory): ", proof_checksum)
    end)
end

TestRunner()