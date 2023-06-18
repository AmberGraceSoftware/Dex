--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Packages.Dec.Observables.Observable)

local function makeStaticObservable<T>(value: T)
    return Observable.new(function()
        return value
    end, function()
        return function() end
    end)
end

return function()
    it("returns the current value", function()
		local observable = makeStaticObservable(42)
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
        local observable = makeStaticObservable(42)

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
        local observable = makeStaticObservable(42)
        observable:Destroy()

        expect(function()
            observable:Subscribe(function() end)
        end).to.throw()
        expect((next(observable._listeners))).to.equal(nil)
        expect(observable._closeUpdateStream).to.equal(nil)
    end)

    it("performs addition on scalar values", function()
        local a = makeStaticObservable(2)
        local b = makeStaticObservable(3)
        expect((a + b):Current()).to.equal(5)
        expect((2 + b):Current()).to.equal(5)
        expect((a + 3):Current()).to.equal(5)
    end)

    it("performs subtraction on scalar values", function()
        local a = makeStaticObservable(5)
        local b = makeStaticObservable(3)
        expect((a - b):Current()).to.equal(2)
        expect((5 - b):Current()).to.equal(2)
        expect((a - 3):Current()).to.equal(2)
    end)

    it("performs multiplication on scalar values", function()
        local a = makeStaticObservable(2)
        local b = makeStaticObservable(3)
        expect((a * b):Current()).to.equal(6)
        expect((2 * b):Current()).to.equal(6)
        expect((a * 3):Current()).to.equal(6)
    end)

    it("performs division on scalar values", function()
        local a = makeStaticObservable(6)
        local b = makeStaticObservable(3)
        expect((a / b):Current()).to.equal(2)
        expect((6 / b):Current()).to.equal(2)
        expect((a / 3):Current()).to.equal(2)
    end)

    it("performs exponentiation on scalar values", function()
        local a = makeStaticObservable(2)
        local b = makeStaticObservable(3)
        expect((a ^ b):Current()).to.equal(8)
        expect((2 ^ b):Current()).to.equal(8)
        expect((a ^ 3):Current()).to.equal(8)
    end)

    it("performs only valid operations on Vector3 values", function()
        local a = makeStaticObservable(Vector3.new(1, 2, 3))
        local b = makeStaticObservable(Vector3.new(4, 5, 6))
        expect((a + b):Current()).to.equal(Vector3.new(5, 7, 9))
        expect((a + Vector3.new(4, 5, 6)):Current()).to
            .equal(Vector3.new(5, 7, 9))
        
        a = makeStaticObservable(Vector3.new(5, 6, 7))
        b = makeStaticObservable(Vector3.new(2, 3, 4))
        expect((a - b):Current()).to.equal(Vector3.new(3, 3, 3))
        expect((a - Vector3.new(2, 3, 4)):Current()).to
            .equal(Vector3.new(3, 3, 3))
        
        expect(function()
            print(a ^ b)
        end).to.throw()
    end)

    it("performs componentwise product on Vector2 values", function()
        local a = makeStaticObservable(Vector2.new(3, 4))
        local b = makeStaticObservable(Vector2.new(2, 3))
        expect((a * b):Current()).to.equal(Vector2.new(6, 12))
        expect((a * Vector2.new(2, 3)):Current()).to.equal(Vector2.new(6, 12))
    end)

    it("performs componentwise operations on UDim values", function()
        local aUDim = makeStaticObservable(UDim.new(2, 30))
        local bUDim = makeStaticObservable(UDim.new(1, 2))
        expect((aUDim + bUDim):Current()).to.equal(UDim.new(3, 32))
        expect((aUDim - bUDim):Current()).to.equal(UDim.new(1, 28))
        expect((aUDim * bUDim):Current()).to.equal(UDim.new(2, 60))
        expect((aUDim / bUDim):Current()).to.equal(UDim.new(2, 15))
        expect((aUDim ^ bUDim):Current()).to.equal(UDim.new(2, 900))

        local aUDim2 = makeStaticObservable(UDim2.new(2, 30, 2, 30))
        local bUDim2 = makeStaticObservable(UDim2.new(1, 2, 1, 2))
        expect((aUDim2 + bUDim2):Current()).to.equal(UDim2.new(3, 32, 3, 32))
        expect((aUDim2 - bUDim2):Current()).to.equal(UDim2.new(1, 28, 1, 28))
        expect((aUDim2 * bUDim2):Current()).to.equal(UDim2.new(2, 60, 2, 60))
        expect((aUDim2 / bUDim2):Current()).to.equal(UDim2.new(2, 15, 2, 15))
        expect((aUDim2 ^ bUDim2):Current()).to.equal(UDim2.new(2, 900, 2, 900))
    end)

    it("performs matrix operations on CFrame values", function()
        local a = makeStaticObservable(CFrame.new(10, 0, 0))
        local b = makeStaticObservable(CFrame.new(0, 10, 0))
        expect((a * b):Current()).to.equal(CFrame.new(10, 10, 0))
        
        expect(function()
            print(a + b)
        end).to.throw()
        expect(function()
            print(a - b)
        end).to.throw()
        expect(function()
            print(a / b)
        end).to.throw()
        expect(function()
            print(-a)
        end).to.throw()
        expect(function()
            print(a ^ b)
        end).to.throw()
    end)
end
