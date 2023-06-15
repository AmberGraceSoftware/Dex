--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInstance = require(ReplicatedStorage.Packages.Dec.VirtualInstance)

return function()
    it("adds conventional directives based on constructor parameters", function()
        local hasNoDirectives = VirtualInstance.new(
            "New",
            "Part",
            nil,
            nil,
            1
        )
        expect(#hasNoDirectives._directives).to.equal(0)

        local hasPropsDirective = VirtualInstance.new(
            "New",
            "Part",
            { Name = "Foo" },
            nil,
            1
        )
        expect(#hasPropsDirective._directives).to.equal(1)
        expect(hasPropsDirective._directives[1]._type).to.equal("Properties")

        local hasChildDirective = VirtualInstance.new(
            "New",
            "Part",
            nil,
            {},
            1
        )
        expect(#hasChildDirective._directives).to.equal(2)
        expect(hasChildDirective._directives[2]._type).to.equal("Children")

        local hasPropsAndChildDirectives = VirtualInstance.new(
            "New",
            "Part",
            { Name = "Foo" },
            {},
            1
        )
        expect(#hasPropsAndChildDirectives._directives).to.equal(2)
        expect(hasPropsAndChildDirectives._directives[1]._type).to.equal("Properties")
        expect(hasPropsAndChildDirectives._directives[2]._type).to.equal("Children")
    end)
end
