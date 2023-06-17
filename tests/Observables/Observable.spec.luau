--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Packages.Dec.Observables.Observable)

return function()
    it("returns the current value", function()
		local observable = Observable.new(function()
			return 42
		end, function()
            return function() end
        end)
        expect(observable:Current()).to.equal(42)
    end)

    it("returns the updated value", function()
        local value = 0
		local observable = Observable.new(function()
			return value
		end, function()
            return function() end
        end)

        expect(observable:Current()).to.equal(0)

        value = 10
        expect(observable:Current()).to.equal(10)
    end)

    it("calls listener immediately if arg #2 of Subscribe() is true", function()
        local observable = Observable.new(function()
            return 42
        end,function()
            return function() end
        end)

        local wasCalled = false
        observable:Subscribe(function(value)
            wasCalled = true
            expect(value).to.equal(42)
        end, true)

        expect(wasCalled).to.equal(true)
    end)

    it("calls listener when value changes and an update is notified", function()
        local value = 0
        local notify
		local observable = Observable.new(function()
			return value
		end, function(_notify)
            notify = _notify
            return function() end
        end)

        local updateCount = 0
        observable:Subscribe(function()
            updateCount += 1
        end)

        expect(updateCount).to.equal(0)
        expect(observable:Current()).to.equal(0)

        value = 10
        notify()
        expect(updateCount).to.equal(1)
        expect(observable:Current()).to.equal(10)
    end)

    it("does not call the listener when notified but unchanged", function()
        local value = 0
        local notify
		local observable = Observable.new(function()
			return value
		end, function(_notify)
            notify = _notify
            return function() end
        end)

        local updateCount = 0
        observable:Subscribe(function()
            updateCount += 1
        end)

        expect(updateCount).to.equal(0)
        expect(observable:Current()).to.equal(0)

        notify()
        expect(updateCount).to.equal(0)
        expect(observable:Current()).to.equal(0)
    end)

    it("stops calling listener after unsubscribe", function()
        local value = 0
        local notify
		local observable = Observable.new(function()
			return value
		end, function(_notify)
            notify = _notify
            return function() end
        end)

        local updateCount = 0
        local unsubscribe = observable:Subscribe(function()
            updateCount += 1
        end)

        expect(updateCount).to.equal(0)
        expect(observable:Current()).to.equal(0)

        value = 10
        notify()
        expect(updateCount).to.equal(1)
        expect(observable:Current()).to.equal(10)

        unsubscribe()

        value = 20
        notify()
        expect(updateCount).to.equal(1)
        expect(observable:Current()).to.equal(20)
    end)

    it("stops observing when all listeners unsubscribe", function()
        local value = 0
        local notify
		local observable = Observable.new(function()
			return value
		end, function(_notify)
            notify = _notify
            return function() end
        end)

        local updateCount1 = 0
        local unsubscribe1 = observable:Subscribe(function()
            updateCount1 += 1
        end)

        local updateCount2 = 0
        local unsubscribe2 = observable:Subscribe(function()
            updateCount2 += 1
        end)

        expect(updateCount1).to.equal(0)
        expect(updateCount2).to.equal(0)
        expect(observable:Current()).to.equal(0)

        value = 10
        notify()
        expect(updateCount1).to.equal(1)
        expect(updateCount2).to.equal(1)
        expect(observable:Current()).to.equal(10)

        unsubscribe1()
        unsubscribe2()

        value = 20
        notify()
        expect(updateCount1).to.equal(1)
        expect(updateCount2).to.equal(1)
        expect(observable:Current()).to.equal(20)
    end)

    it("destroys the observable", function()
        local value = 0
        local notify
		local observable = Observable.new(function()
			return value
		end, function(_notify)
            notify = _notify
            return function() end
        end)

        local updateCount = 0
        observable:Subscribe(function()
            updateCount += 1
        end)

        expect(updateCount).to.equal(0)
        expect(observable:Current()).to.equal(0)

        value = 10
        notify()
        expect(updateCount).to.equal(1)
        expect(observable:Current()).to.equal(10)

        observable:Destroy()

        value = 20
        notify()
        expect(updateCount).to.equal(1)
        expect(observable:Current()).to.equal(20)
        expect((next(observable._listeners))).to.equal(nil)
        expect(observable._closeUpdateStream).to.equal(nil)
    end)

    it("throws an error when subscribing to a destroyed observable", function()
        local observable = Observable.new(function()
            return 42
        end,function()
            return function() end
        end)
        observable:Destroy()

        expect(function()
            observable:Subscribe(function() end)
        end).to.throw()
        expect((next(observable._listeners))).to.equal(nil)
        expect(observable._closeUpdateStream).to.equal(nil)
    end)
end
