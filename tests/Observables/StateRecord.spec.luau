--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateRecord = require(ReplicatedStorage.Packages.Dex.Observables.StateRecord)

return function()
    it("should have a set-able value and notify changes to the value", function()
        local stateRecord = StateRecord.new({ key1 = 0, key2 = 0 })
        expect(stateRecord:Current()).to.be.a("table")
        expect(stateRecord:Current().key1).to.equal(0)
        expect(stateRecord:Current("key1")).to.equal(0)
        expect(stateRecord:Current().key2).to.equal(0)
        expect(stateRecord:Current("key2")).to.equal(0)

        stateRecord:Set("key1", 5)
        expect(stateRecord:Current().key1).to.equal(5)
        expect(stateRecord:Current("key1")).to.equal(5)
        expect(stateRecord:Current().key2).to.equal(0)
        expect(stateRecord:Current("key2")).to.equal(0)

        local updateCount = 0
        stateRecord:Subscribe(function()
            updateCount += 1
        end)

        stateRecord:Set("key2", 10)
        expect(stateRecord:Current().key1).to.equal(5)
        expect(stateRecord:Current("key1")).to.equal(5)
        expect(stateRecord:Current().key2).to.equal(10)
        expect(stateRecord:Current("key2")).to.equal(10)
        expect(updateCount).to.equal(1)

        stateRecord:Set("key2", 10)
        expect(stateRecord:Current().key1).to.equal(5)
        expect(stateRecord:Current("key1")).to.equal(5)
        expect(stateRecord:Current().key2).to.equal(10)
        expect(stateRecord:Current("key2")).to.equal(10)
        expect(updateCount).to.equal(1)
    end)

    it("should replace the entire state record", function()
        local stateRecord = StateRecord.new({ key1 = 0, key2 = 0 })
        expect(stateRecord:Current()).to.be.a("table")
        expect(stateRecord:Current().key1).to.equal(0)
        expect(stateRecord:Current().key2).to.equal(0)

        local updateCount = 0
        stateRecord:Subscribe(function()
            updateCount += 1
        end)

        local newRecord = { key1 = 1, key2 = 2, key3 = 3 }
        stateRecord:Replace(newRecord)
        expect(stateRecord:Current().key1).to.equal(1)
        expect(stateRecord:Current().key2).to.equal(2)
        expect(stateRecord:Current().key3).to.equal(3)
        expect(stateRecord:Current("key1")).to.equal(1)
        expect(stateRecord:Current("key2")).to.equal(2)
        expect(stateRecord:Current("key3")).to.equal(3)
        expect(updateCount).to.equal(1)

        stateRecord:Set("key1", 10)
        expect(stateRecord:Current().key1).to.equal(10)
        expect(stateRecord:Current("key1")).to.equal(10)
        expect(stateRecord:Current("key2")).to.equal(2)
        expect(stateRecord:Current("key3")).to.equal(3)
        expect(updateCount).to.equal(2)
    end)

    it("should create index observables for specific keys", function()
        local stateRecord = StateRecord.new({ key1 = 0, key2 = 0 })
        expect(stateRecord:Current()).to.be.a("table")
        expect(stateRecord:Current().key1).to.equal(0)
        expect(stateRecord:Current().key2).to.equal(0)

        local key1Observable = stateRecord:Index("key1")
        expect(key1Observable).to.be.ok()
        expect(key1Observable:Current()).to.equal(0)

        local updateCount = 0
        key1Observable:Subscribe(function()
            updateCount += 1
        end)

        stateRecord:Set("key1", 5)
        expect(key1Observable:Current()).to.equal(5)
        expect(updateCount).to.equal(1)

        stateRecord:Set("key2", 10)
        expect(key1Observable:Current()).to.equal(5)
        expect(updateCount).to.equal(1)

        stateRecord:Set("key1", 8)
        expect(key1Observable:Current()).to.equal(8)
        expect(updateCount).to.equal(2)
    end)
end
