--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInstance = require(ReplicatedStorage.Packages.Dec.VirtualInstance)
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)
local Types = require(ReplicatedStorage.Packages.Dec.Types)

type Observable<T> = Types.Observable<T>

--[[
    Deeply compares two values. If they are tables, checks all nested keys and
    values. 

    Keypath is automatically generated, and is a mutable list of keys used for
    debugging the key path of the mismatch.
]]
local function expectDeepEqual(value: any, expectation: any, keypath: {string}?)
    if expectation == value then
        return
    end
    
    local _keypath: {string} = keypath or {}
    if typeof(expectation) ~= typeof(value) then
        local kpFormat = if #_keypath > 0
            then `, under key path {table.concat(_keypath, ".")}`
            else ""
        error(`Expected value {expectation} ({typeof(expectation)}` ..
            `{kpFormat}), got {value} ({typeof(value)}) instead`)
    end

    if typeof(expectation) ~= "table" then
        local kpFormat = if #_keypath > 0
            then `, under key path {table.concat(_keypath, ".")}`
            else ""
        error(`Expected value {expectation} ({typeof(expectation)}` ..
            `{kpFormat}), got {value} ({typeof(value)}) instead`)
    end

    local kpIndex = #_keypath + 1
    for k, v in expectation do
        _keypath[kpIndex] = k
        expectDeepEqual(value[k], v, _keypath)
    end

    for k, v in value do
        _keypath[kpIndex] = k
        expectDeepEqual(v, expectation[k], _keypath)
    end
    _keypath[kpIndex] = nil
end


return function()
    it("adds conventional directives from constructor parameters", function()
        local hasNoDirectives = VirtualInstance.new(
            "New",
            "Part"
        )
        expect(#hasNoDirectives._directives).to.equal(0)

        local hasPropsDirective = VirtualInstance.new(
            "New",
            "Part",
            { Name = "Foo" }
        )
        expect(#hasPropsDirective._directives).to.equal(1)
        expect(hasPropsDirective._directives[1]._type).to.equal("Properties")

        local hasChildDirective = VirtualInstance.new(
            "New",
            "Part",
            nil,
            {}
        )
        expect(#hasChildDirective._directives).to.equal(1)
        expect(hasChildDirective._directives[1]._type).to.equal("Children")

        local hasPropsAndChildDirectives = VirtualInstance.new(
            "New",
            "Part",
            { Name = "Foo" },
            {}
        )
        expect(#hasPropsAndChildDirectives._directives).to.equal(2)
        expect(hasPropsAndChildDirectives._directives[1]._type)
            .to.equal("Properties")
        expect(hasPropsAndChildDirectives._directives[2]._type)
            .to.equal("Children")
    end)

    local virtualInstance = VirtualInstance.new("New", "Part")

    local expectDirectiveCount = 0
    local function checkLastDirective(expectedType: string,
        expectedPayload: any)
        local lastDirective =
            virtualInstance._directives[#virtualInstance._directives]

        expectDirectiveCount += 1
        expect(#virtualInstance._directives).to.equal(expectDirectiveCount)
        expect(lastDirective._type).to.equal(expectedType)
        expectDeepEqual(lastDirective._payload, expectedPayload)
    end
    it("can add Properties via SetProperties", function()
        local propertyMap = {
            Size = Vector3.new(10, 10, 10),
            Color = Color3.new(1, 1, 1),
        }
        virtualInstance:SetProperties(propertyMap)

        checkLastDirective("Properties", propertyMap)
    end)

    it("can add Attributes via SetAttributes", function()
        local attributeMap = {
            Visible = true,
            CanCollide = false,
        }
        virtualInstance:SetAttributes(attributeMap)

        checkLastDirective("Attributes", attributeMap)
    end)

    it("adds tags to the VirtualInstance", function()
        local tags = { "Tag1", "Tag2" }
        virtualInstance:AddTags(tags)

        checkLastDirective("TagList", tags)
    end)

    it("can add event listeners via Connect", function()
        local eventName = "Touched"
        local listener = function()
            -- event listener logic
        end
        virtualInstance:Connect(eventName, listener)
    
        checkLastDirective("Connect", {
            event = eventName,
            listener = listener,
        })
    end)
    
    it("creates an observable property via OutProperty", function()
        local propertyValue = "Hello"
        local observableProperty = virtualInstance:OutProperty("CFrame",
            propertyValue)
    
        checkLastDirective("OutProperty", {
            property = "CFrame",
            state = observableProperty,
            once = false,
        })
    end)
    
    it("creates initial property Observable via OutInitialProperty", function()
        local initialPropertyValue = "InitialValue"
        local observableInitialProperty = virtualInstance:OutInitialProperty(
            "CFrame", initialPropertyValue)
    
        checkLastDirective("OutProperty", {
            property = "CFrame",
            state = observableInitialProperty,
            once = true,
        })
    end)

    it("creates attribute Observable via OutAttribute", function()
        local attributeValue = 42
        local observableAttribute = virtualInstance:OutAttribute(
            "AttributeName", attributeValue)
    
        checkLastDirective("OutAttribute", {
            attribute = "AttributeName",
            state = observableAttribute,
            once = false,
        })
    end)
    
    it("creates initial attribute Observable via OutInitialAttribute", function()
        local initialAttributeValue = true
        local observableInitialAttribute = virtualInstance:OutInitialAttribute(
            "AttributeName", initialAttributeValue)
    
        checkLastDirective("OutAttribute", {
            attribute = "AttributeName",
            state = observableInitialAttribute,
            once = true,
        })
    end)
    
    it("outputs the reconciled instance via OutInstance", function()
        local outputState = virtualInstance:OutInstance()
    
        checkLastDirective("OutInstance", outputState)
    end)
    
    it("creates a shallow copy via Copy", function()
        local copy = virtualInstance:Copy()
        expect(#copy._directives).to.equal(#virtualInstance._directives)
        expect(copy._directives).to.never.equal(virtualInstance._directives)
        expect(copy).to.never.equal(virtualInstance)
        expectDeepEqual(copy, virtualInstance)
    end)
    
    it("creates a deep copy via DeepCopy", function()
        local copy = virtualInstance:DeepCopy()
        expect(#copy._directives).to.equal(#virtualInstance._directives)
        expect(copy._directives).to.never.equal(virtualInstance._directives)
        expect(copy).to.never.equal(virtualInstance)
        expectDeepEqual(copy, virtualInstance)
    end)
    
    it("adds a child via AddChild", function()
        local child = VirtualInstance.new("Premade")
        virtualInstance:AddChild("ChildName", child)
    
        checkLastDirective("Children", {ChildName = child})
    end)
    
    it("adds multiple children via AddChildren", function()
        local childMap = {
            Child1 = VirtualInstance.new("Premade"),
            Child2 = VirtualInstance.new("Premade"),
        }
        virtualInstance:AddChildren(childMap)
    
        checkLastDirective("Children", childMap)
    end)
    
    it("maps individual children via MapChildren", function()
        local input = State.new({} :: {[string]: number})
        local mapFunction = function(key: string, value: number)
            return VirtualInstance.new("New", "TextLabel", {
                Text = key .. " + 1 is " .. tostring(value + 1)
            })
        end
        virtualInstance:MapChildren(input, mapFunction)
        
        checkLastDirective("MapChildren", {
            input = input,
            map = mapFunction
        })
    end)
    
    it("maps individual children via MapChildrenByKey", function()
        local input = State.new({} :: {[string]: number})
        local mapFunction = function(key: string, value: Observable<number>)
            return VirtualInstance.new("New", "TextLabel", {
                Text = value:Map(function(currentValue)
                    return key .. " + 1 is " .. tostring(currentValue + 1)
                end)
            })
        end
        virtualInstance:MapChildrenByKey(input, mapFunction)
        
        checkLastDirective("MapChildrenByKey", {
            input = input,
            map = mapFunction
        })
    end)
    
    it("maps individual children via MapChildrenByValue", function()
        local input = State.new({} :: {[string]: number})
        local mapFunction = function(value: number, key: Observable<string>)
            return VirtualInstance.new("New", "TextLabel", {
                Text = key:Map(function(currentKey)
                    return currentKey .. " + 1 is " .. tostring(value + 1)
                end)
            })
        end
        virtualInstance:MapChildrenByValue(input, mapFunction)
        
        local lastDirective =
            virtualInstance._directives[#virtualInstance._directives]
        checkLastDirective("MapChildrenByKey", {
            input = lastDirective._payload.input,
            map = mapFunction
        })
    end)
    
    it("adds a mount lifecycle callback via OnMount", function()
        -- Note: Functions in luau are equivalent UNLESS they capture a closure
        -- value outside of their scope
        local closureVal = ""
        local callback = function()
            print(closureVal)
        end
        virtualInstance:OnMount(callback)
    
        checkLastDirective("OnMount", callback)
    end)
    
    it("adds an unmount lifecycle callback via OnUnmount", function()
        -- Note: Functions in luau are equivalent UNLESS they capture a closure
        -- value outside of their scope
        local closureVal = 2
        local callback = function()
            print(closureVal)
        end
        virtualInstance:OnUnmount(callback)
    
        checkLastDirective("OnUnmount", callback)
    end)
    
    it("finds a child via FindChild", function()
        local childPath = "ChildName"
        local childVInst = virtualInstance:FindChild("Frame", childPath)
    
        checkLastDirective("Children", {[childPath] = childVInst})
        expect(childVInst._dectype).to.be.equal("VirtualInstance")
    end)
end
