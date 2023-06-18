--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stopwatch = require(ReplicatedStorage.Packages.Dec.Observables.Stopwatch)

return function()
    local function waitUntilClockChange()
        local start = os.clock()
        while os.clock() == start do end
    end

    it("should start the stopwatch and update with new values", function()
        local stopwatch = Stopwatch.new(5)
        expect(stopwatch:Current()).to.equal(0)

        stopwatch:Start()
        waitUntilClockChange()
        expect(stopwatch:Current()).to.never.equal(0)
    end)

    it("should stop the stopwatch and not update with new values", function()
        local stopwatch = Stopwatch.new(5)
        expect(stopwatch:Current()).to.equal(0)

        stopwatch:Start()
        waitUntilClockChange()
        local valueAfterStart = stopwatch:Current()
        expect(valueAfterStart).to.never.equal(0)

        stopwatch:Stop()
        waitUntilClockChange()
        expect(stopwatch:Current()).to.equal(0)
    end)

    it("should pause the stopwatch and not update with new values", function()
        local stopwatch = Stopwatch.new(5)
        expect(stopwatch:Current()).to.equal(0)

        stopwatch:Start()
        waitUntilClockChange()
        local valueAfterStart = stopwatch:Current()
        expect(valueAfterStart).to.never.equal(0)
        stopwatch:Pause()
        valueAfterStart = stopwatch:Current()
        waitUntilClockChange()
        expect(stopwatch:Current()).to.equal(valueAfterStart)
    end)

    it("should set the current time position of the stopwatch", function()
        local stopwatch = Stopwatch.new(5)
        expect(stopwatch:Current()).to.equal(0)

        stopwatch:Start()
        waitUntilClockChange()
        expect(stopwatch:Current()).to.never.equal(0)

        stopwatch:SetTimePosition(3)
        waitUntilClockChange()
        expect(stopwatch:Current() > 3).to.be.equal(true)
    end)

    it("should create a curved Alpha observable", function()
        local stopwatch = Stopwatch.new(5)
        local alphaObservable = stopwatch:CurvedAlpha(Enum.EasingStyle.Quad)
        expect(alphaObservable).to.be.ok()
        stopwatch:Start()
        waitUntilClockChange()
        expect(alphaObservable:Current() > 0).to.be.equal(true)
        expect(alphaObservable:Current() < 1).to.be.equal(true)
    end)

    it("should create a sliced Alpha observable", function()
        local stopwatch = Stopwatch.new(5)
        local alphaObservable = stopwatch:SliceAlpha(2, 4)
        expect(alphaObservable).to.be.ok()
        stopwatch:Start()
        waitUntilClockChange()
        expect(alphaObservable:Current() == 0).to.be.equal(true)
    end)
end
