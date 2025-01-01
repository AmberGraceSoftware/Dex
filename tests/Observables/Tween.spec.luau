--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tween = require(ReplicatedStorage.Packages.Dex.Observables.Tween)
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)

return function()
    local function waitUntilClockChange()
        local start = os.clock()
        -- selene: allow(empty_loop)
        while os.clock() == start do end
    end

    it("constructs an Tween observable with reactive dispatch", function()
        local target = State.new(0)
        local tween = Tween.new(target:Map(function(current)
            return {
                goal = current,
                info = TweenInfo.new(1, Enum.EasingStyle.Linear)
            }
        end))
        local unsub = tween:Subscribe(function() end)
        expect(tween).to.be.ok()
        expect(tween:Current()).to.equal(0)
        waitUntilClockChange()
        expect(tween:Current()).to.equal(0)
        target:Set(1)
        waitUntilClockChange()
        expect(tween:Current()).to.never.equal(0)
        unsub()
    end)
    it("constructs an Tween observable with method dispatch", function()
        local tween = Tween.new(0)
        local unsub = tween:Subscribe(function() end)
        expect(tween).to.be.ok()
        expect(tween:Current()).to.equal(0)
        waitUntilClockChange()
        expect(tween:Current()).to.equal(0)
        tween:Play({
            goal = 1,
            info = TweenInfo.new(1, Enum.EasingStyle.Linear)
        })
        waitUntilClockChange()
        expect(tween:Current()).to.never.equal(0)
        unsub()
    end)
end
