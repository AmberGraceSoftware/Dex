--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Timer = require(ReplicatedStorage.Packages.Dec.Observables.Timer)

return function()
    local function waitUntilClockChange()
        local start = os.clock()
        while os.clock() == start do end
    end

    it("should start the timer and update with new values", function()
        local timer = Timer.new({duration = 5})
        expect(timer:Current()).to.equal(5)

        timer:Play()
        waitUntilClockChange()
        expect(timer:Current() < 5).to.be.equal(true)
    end)

    it("should stop the timer and not update with new values", function()
        local timer = Timer.new({duration = 5})
        expect(timer:Current()).to.equal(5)

        timer:Play()
        waitUntilClockChange()
        local valueAfterStart = timer:Current()
        expect(valueAfterStart < 5).to.be.equal(true)

        timer:Stop()
        waitUntilClockChange()
        expect(timer:Current()).to.equal(5)
    end)

    it("should pause the timer and not update with new values", function()
        local timer = Timer.new({duration = 5})
        expect(timer:Current()).to.equal(5)

        timer:Play()
        waitUntilClockChange()
        local valueAfterStart = timer:Current()
        expect(valueAfterStart < 5).to.be.equal(true)

        timer:Pause()
        valueAfterStart = timer:Current()
        waitUntilClockChange()
        expect(timer:Current()).to.equal(valueAfterStart)
    end)

    it("should set the current time position of the timer", function()
        local timer = Timer.new({duration = 5})
        expect(timer:Current()).to.equal(5)

        timer:Play()
        waitUntilClockChange()
        expect(timer:Current() < 5).to.be.equal(true)

        timer:SetTimePosition(3)
        waitUntilClockChange()
        expect(timer:Current() < 3).to.equal(true)
        expect(timer:Current() > 2).to.equal(true)
    end)
    
    it("should create a sliced Alpha observable at [4, 2]", function()
        local timer = Timer.new({duration = 5})
        local alphaObservable = timer:Alpha(4, 2)
        expect(alphaObservable).to.be.ok()
        timer:Play()
        waitUntilClockChange()
        expect(alphaObservable:Current()).to.equal(0)
    end)
    
    it("should create a sliced Alpha observable at [5, 1]", function()
        local timer = Timer.new({duration = 5})
        local alphaObservable = timer:Alpha(5, 1)
        expect(alphaObservable).to.be.ok()
        expect(alphaObservable:Current()).to.equal(0)
        timer:Play()
        waitUntilClockChange()
        expect(alphaObservable:Current() == 0).to.be.equal(false)
    end)
end
