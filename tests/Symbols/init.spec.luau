--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Symbols = require(ReplicatedStorage.Packages.Dex.Symbols)
local Symbol = require(ReplicatedStorage.Packages.Dex.Symbols.Symbol)
return function()
    it("defines the Nil symbol", function()
        local Nil = Symbols.Nil
        expect(Nil._name).to.equal("Nil")
        expect(Nil._usage).to.be.a("string")
    end)
    it("defines equivalent Nil across a different Dex runtimes", function()
        local externalNil = Symbol.new("Nil")
        local Nil = Symbols.Nil
        expect(Nil).to.equal(externalNil)
    end)
end