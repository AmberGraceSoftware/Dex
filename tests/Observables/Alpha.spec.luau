--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Alpha = require(ReplicatedStorage.Packages.Dec.Observables.Alpha)
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)
return function()
    it("should derive a new Alpha Observable", function()
        local sourceState = State.new(5)
        local alphaObservable = Alpha.new(sourceState, 0, 10)
        expect(alphaObservable:Current()).to.equal(5/10)
        
        sourceState:Set(2)
        expect(alphaObservable:Current()).to.equal(2/10)
        
        sourceState:Set(8)
        expect(alphaObservable:Current()).to.equal(8/10)
    end)

    it("should derive a sliced Alpha Observable", function()
        local sourceState = State.new(0.2)
        local slicedAlpha = Alpha.new(sourceState, 0, 1):Slice(0.2, 0.4)
        expect(slicedAlpha:Current()).to.equal(0)
        
        sourceState:Set(0.3)
        expect(slicedAlpha:Current()).to.be.near(0.5)
        
        sourceState:Set(0.4)
        expect(slicedAlpha:Current()).to.equal(1)
    end)
    
    it("should derive a curved Alpha Observable", function()
        local sourceState = State.new(0.2)
        local curvedAlpha = Alpha.new(sourceState, 0, 1)
            :Curve(Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        expect(curvedAlpha:Current()).to.be.near(0.04)
        
        sourceState:Set(0.5)
        expect(curvedAlpha:Current()).to.be.near(0.25)
        
        sourceState:Set(1)
        expect(curvedAlpha:Current()).to.equal(1)
    end)
    
    it("should derive an inverted Alpha Observable", function()
        local sourceState = State.new(0.2)
        local invertedAlpha = Alpha.new(sourceState, 0, 1):Invert()
        expect(invertedAlpha:Current()).to.equal(0.8)
        
        sourceState:Set(0.5)
        expect(invertedAlpha:Current()).to.equal(0.5)
        
        sourceState:Set(1)
        expect(invertedAlpha:Current()).to.equal(0)
    end)
    
    it("should derive a lerped Observable based on Alpha", function()
        local sourceState = State.new(0.2)
        local lerpedObservable = Alpha.new(sourceState, 0, 1):Lerp(10, 20)
        expect(lerpedObservable:Current()).to.be.near(12)
        
        sourceState:Set(0.5)
        expect(lerpedObservable:Current()).to.equal(15)
        
        sourceState:Set(1)
        expect(lerpedObservable:Current()).to.equal(20)
    end)
end
