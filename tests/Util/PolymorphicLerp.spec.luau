--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolymorphicLerp = require(ReplicatedStorage.Packages.Dec.Util.PolymorphicLerp)

return function()
    it("performs polymorphic lerp for numbers", function()
        local lerp = PolymorphicLerp("number")
        local result = lerp(10, 20, 0.5)
        expect(result).to.equal(15)
    end)

    it("performs polymorphic lerp for Vector2", function()
        local lerp = PolymorphicLerp("Vector2")
        local result = lerp(Vector2.new(0, 0), Vector2.new(10, 20), 0.5)
        expect(typeof(result)).to.equal("Vector2")
        expect(result.X).to.equal(5)
        expect(result.Y).to.equal(10)
    end)

    it("performs polymorphic lerp for Vector2int16", function()
        local lerp = PolymorphicLerp("Vector2int16")
        local result = lerp(Vector2int16.new(0, 0),
            Vector2int16.new(10, 20), 0.5)
        expect(typeof(result)).to.equal("Vector2int16")
        expect(result.X).to.equal(5)
        expect(result.Y).to.equal(10)
    end)

    it("performs polymorphic lerp for Vector3", function()
        local lerp = PolymorphicLerp("Vector3")
        local result = lerp(Vector3.new(0, 0, 0), Vector3.new(10, 20, 30), 0.5)
        expect(typeof(result)).to.equal("Vector3")
        expect(result.X).to.equal(5)
        expect(result.Y).to.equal(10)
        expect(result.Z).to.equal(15)
    end)

    it("performs polymorphic lerp for Vector3int16", function()
        local lerp = PolymorphicLerp("Vector3int16")
        local result = lerp(Vector3int16.new(0, 0, 0),
            Vector3int16.new(10, 20, 30), 0.5)
        expect(typeof(result)).to.equal("Vector3int16")
        expect(result.X).to.equal(5)
        expect(result.Y).to.equal(10)
        expect(result.Z).to.equal(15)
    end)

        it("performs polymorphic lerp for CFrame", function()
        local lerp = PolymorphicLerp("CFrame")
        local result = lerp(CFrame.new(0, 0, 0), CFrame.new(10, 20, 30), 0.5)
        expect(typeof(result)).to.equal("CFrame")
        expect(result).to.equal(CFrame.new(5, 10, 15))
    end)

    it("performs polymorphic lerp for Color3", function()
        local lerp = PolymorphicLerp("Color3")
        local result = lerp(Color3.new(0, 0, 0), Color3.new(1, 1, 1), 0.5)
        expect(typeof(result)).to.equal("Color3")
        expect(result).to.equal(Color3.new(0.5, 0.5, 0.5))
    end)

    it("performs polymorphic lerp for UDim", function()
        local lerp = PolymorphicLerp("UDim")
        local result = lerp(UDim.new(0, 0), UDim.new(10, 20), 0.5)
        expect(typeof(result)).to.equal("UDim")
        expect(result).to.equal(UDim.new(5, 10))
    end)

    it("performs polymorphic lerp for UDim2", function()
        local lerp = PolymorphicLerp("UDim2")
        local result = lerp(
            UDim2.new(0, 0, 0, 0),
            UDim2.new(10, 20, 30, 40),
            0.5
        )
        expect(typeof(result)).to.equal("UDim2")
        expect(result).to.equal(UDim2.new(5, 10, 15, 20))
    end)

    it("performs polymorphic lerp for boolean", function()
        local lerp = PolymorphicLerp("boolean")
        local result1 = lerp(true, false, 0.5)
        expect(result1).to.equal(true)

        local result2 = lerp(false, true, 0.5)
        expect(result2).to.equal(true)

        local result3 = lerp(true, true, 0.5)
        expect(result3).to.equal(true)
    end)

    it("performs polymorphic lerp for Rect", function()
        local lerp = PolymorphicLerp("Rect")
        local result = lerp(
            Rect.new(0, 0, 0, 0),
            Rect.new(10, 20, 30, 40),
            0.5
        )
        expect(typeof(result)).to.equal("Rect")
        expect(result).to.equal(Rect.new(5, 10, 15, 20))
    end)
end