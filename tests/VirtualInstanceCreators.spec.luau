--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInstanceCreators = require(ReplicatedStorage.Packages.Dec.VirtualInstanceCreators)

return function()
    it("should create a new VirtualInstance using New()", function()
        local className = "Part"
        local props = {Size = Vector3.new(10, 10, 10)}
        local children = {Child1 = VirtualInstanceCreators.New("Part")}

        local virtualInstance = VirtualInstanceCreators.New(className, props,
            children)

        expect(virtualInstance._dectype).to.equal("VirtualInstance")
        expect(virtualInstance._constructorType).to.equal("New")
        expect(virtualInstance._constructorTypeArgument).to.equal(className)
        expect(#virtualInstance._directives).to.equal(2)
        expect(virtualInstance._directives[1]._payload).to.equal(props)
        expect(virtualInstance._directives[2]._payload).to.equal(children)
    end)

    it("should create a new VirtualInstance using Clone()", function()
        local template = VirtualInstanceCreators.New("Part")
        local props = {Size = Vector3.new(5, 5, 5)}
        local children = {Child2 = VirtualInstanceCreators.New("Part")}

        local virtualInstance = VirtualInstanceCreators.Clone(template, props,
            children)

        expect(virtualInstance._dectype).to.equal("VirtualInstance")
        expect(virtualInstance._constructorType).to.equal("Clone")
        expect(virtualInstance._constructorTypeArgument).to.equal(template)
        expect(#virtualInstance._directives).to.equal(2)
        expect(virtualInstance._directives[1]._payload).to.equal(props)
        expect(virtualInstance._directives[2]._payload).to.equal(children)
    end)

    it("should create a new VirtualInstance using Premade()", function()
        local props = {Size = Vector3.new(3, 3, 3)}
        local children = {Child3 = VirtualInstanceCreators.New("Part")}

        local virtualInstance =
            VirtualInstanceCreators.Premade("Frame", props, children)

        expect(virtualInstance._dectype).to.equal("VirtualInstance")
        expect(virtualInstance._constructorType).to.equal("Premade")
        expect(virtualInstance._constructorTypeArgument).to.equal("Frame")
        expect(#virtualInstance._directives).to.equal(2)
        expect(virtualInstance._directives[1]._payload).to.equal(props)
        expect(virtualInstance._directives[2]._payload).to.equal(children)
    end)
end