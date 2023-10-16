--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Symbol = require(ReplicatedStorage.Packages.Dex.Symbols.Symbol)

return function()
    it("creates a symbol with the provided name", function()
        local symbol = Symbol.new("TestSymbol")
        expect(symbol._name).to.equal("TestSymbol")
    end)

    it("creates a symbol with the provided name and usage", function()
        local symbol = Symbol.new("TestSymbol", "This is a test symbol")
        expect(symbol._name).to.equal("TestSymbol")
        expect(symbol._usage).to.equal("This is a test symbol")
    end)

    it("has a custom __tostring method", function()
        local symbol = Symbol.new("TestSymbol")
        expect(tostring(symbol)).to.equal("TestSymbol")
    end)

    it("has a custom __tostring method with usage", function()
        local symbol = Symbol.new("TestSymbol", "This is a test symbol")
        expect(tostring(symbol)).to.equal(
            "TestSymbol\n(Usage: This is a test symbol)")
    end)

    it("has the correct _dectype value", function()
        local symbol = Symbol.new("TestSymbol")
        expect(symbol._dectype).to.equal("Symbol")
    end)

    it("Implements __eq which compares symbol name and dectype only", function()
        local symbol1 = Symbol.new("TestSymbol")
        local symbol2 = Symbol.new("TestSymbol")
        expect(symbol1).to.equal(symbol2)
    end)
end