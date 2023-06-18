--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AngleSpring = require(ReplicatedStorage.Packages.Dec.Observables.AngleSpring)
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)
return function()
    local function waitUntilClockChange()
        local start = os.clock()
        while os.clock() == start do end
    end
    it("should create an AngleSpring which eases towards target", function()
        local target = State.new(0)
        local easingObservable = AngleSpring.new(target)
        expect(easingObservable).to.be.ok()

        target:Set(math.pi - 0.05)
        waitUntilClockChange()
        expect(easingObservable:Current() < 0.1).to.equal(true)
        expect(easingObservable:Current()).to.never.equal(0)

        target:Set(0.5)
        waitUntilClockChange()
        expect(easingObservable:Current() < 0.1).to.equal(true)
        expect(easingObservable:Current()).to.never.equal(0)

        easingObservable:ResetVelocity()
        target:Set(-math.pi + 0.05)
        local highestPoint = easingObservable:Current()
        waitUntilClockChange()
        expect(easingObservable:Current() < highestPoint).to.equal(true)
    end)

    it("should wrap the angle to the range [-pi, pi]", function()
        local target = State.new(0)
        local easingObservable = AngleSpring.new(target)
        expect(easingObservable).to.be.ok()

        target:Set(math.pi + 1)
        waitUntilClockChange()
        expect(easingObservable:Current() < 0).to.equal(true)
    end)

    it("should provide wrapped target angle through CurrentTarget", function()
        local target = State.new(3 * math.pi)
        local easingObservable = AngleSpring.new(target)

        expect(easingObservable).to.be.ok()
        expect(easingObservable:CurrentTarget()).to.near(math.pi)

        target:Set(-2.5 * math.pi)
        expect(easingObservable:CurrentTarget()).to.near(-0.5 * math.pi)
    end)

    it("should throw an error for unsupported data types", function()
        local target = State.new(true)
        expect(function()
            AngleSpring.new(target)
        end).to.throw("Data type 'boolean' cannot be eased using AngleSpring")
    end)
end
