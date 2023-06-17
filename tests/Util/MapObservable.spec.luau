--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)
local MapObservable = require(ReplicatedStorage.Packages.Dec.Util.MapObservable)

return function()
    it("maps a single dependency", function()
        local source = State.new(5)
		local mapped = MapObservable(source)(function(value)
			return value * 2
		end)
        
        expect(mapped:Current()).to.equal(10)
        
        source:Set(7)
        expect(mapped:Current()).to.equal(14)
    end)
    
    it("maps multiple dependencies", function()
        local dep1 = State.new(2)
        local dep2 = State.new(3)
        local mapped = MapObservable(dep1, dep2)(function(value1, value2)
            return value1 + value2
        end)
        
        expect(mapped:Current()).to.equal(5)
        
        dep1:Set(5)
        expect(mapped:Current()).to.equal(8)
        
        dep2:Set(8)
        expect(mapped:Current()).to.equal(13)
    end)
end
