--!strict
local Types = require(game.ReplicatedStorage.Packages.Dec.Types)

return function()
    it("returns no values", function()
        expect(Types).to.equal(nil)
    end)
end
