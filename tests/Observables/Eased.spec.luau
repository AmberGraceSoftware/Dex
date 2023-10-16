--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Eased = require(ReplicatedStorage.Packages.Dex.Observables.Eased)
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)

return function()
    local function waitUntilClockChange()
        local start = os.clock()
        while os.clock() == start do end
    end

    it("constructs an Eased observable with the provided TweenInfo", function()
        local target = State.new(0)
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local easingObservable = Eased.new(target, tweenInfo)
        expect(easingObservable).to.be.ok()
    end)

    it("should update output value based on changes in the input", function()
        local target = State.new(0)
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local easingObservable = Eased.new(target, tweenInfo)
        expect(easingObservable:Current()).to.equal(0)

        target:Set(1)
        waitUntilClockChange()
        expect(easingObservable:Current()).to.never.equal(0)
    end)
end
