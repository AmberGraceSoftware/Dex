--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Timer = require(ReplicatedStorage.Packages.Dex.Observables.Timer)
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)

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

    it("Should start immediately when isPlaying is true", function()
        local timer = Timer.new({duration = 5, isPlaying = true})
        local unsub = timer:Subscribe(function() end)
        waitUntilClockChange()
        expect(timer:Current() == 5 ).to.equal(false)
        timer:Stop()
        waitUntilClockChange()
        expect(timer:Current()).to.be.equal(5)
        unsub()
    end)

    it("Should start reactively when isPlaying is observable", function()
        local isPlaying = State.new(false)
        local timer = Timer.new({duration = 5, isPlaying = isPlaying})
        local unsub = timer:Subscribe(function() end)
        waitUntilClockChange()
        expect(timer:Current()).to.equal(5)
        isPlaying:Set(true)
        waitUntilClockChange()
        expect(timer:Current() == 5 ).to.equal(false)
        isPlaying:Set(false)
        waitUntilClockChange()
        expect(timer:Current()).to.be.equal(5)
        unsub()
    end)

    it("Should start reactively when playOnChange is observable", function()
        local trigger = State.new(0)
        local timer = Timer.new({duration = 5, playOnChange = trigger})
        local unsub = timer:Subscribe(function() end)
        waitUntilClockChange()
        expect(timer:Current()).to.equal(5)
        trigger:Set(1)
        waitUntilClockChange()
        expect(timer:Current() == 5 ).to.equal(false)
        timer:Stop()
        waitUntilClockChange()
        expect(timer:Current()).to.be.equal(5)
        trigger:Set(2)
        waitUntilClockChange()
        expect(timer:Current() == 5 ).to.equal(false)
        unsub()
    end)
end
