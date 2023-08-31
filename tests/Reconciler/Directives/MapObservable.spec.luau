--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("MapObservable", function()
        it("Updates only mapped children for KVs that change", function()
            local input = Dec.State({"a", "b", "c"})

            local parent = Dec.Premade("Frame")
            parent:MapChildren(input, function(i, letter)
                return Dec.New("TextLabel", {
                    LayoutOrder = i,
                    Text = letter
                })
            end)

            local host = Instance.new("Frame")
            Dec.Root(host):Render(parent)

            -- Verify generated children match original state
            local children = (host:GetChildren() :: any) :: {TextLabel}
            expect(#children).to.equal(3)
            table.sort(children, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(children[1].Text).to.equal("a")
            expect(children[2].Text).to.equal("b")
            expect(children[3].Text).to.equal("c")

            -- Mutate "b" -> "d"
            input:Set({"a", "d", "c"})

            -- Verify that only child 2 was destroyed/re-created
            local newChildren = (host:GetChildren() :: any) :: {TextLabel}
            expect(#newChildren).to.equal(3)
            table.sort(newChildren, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(newChildren[1]).to.equal(children[1])
            expect(newChildren[2].Text).to.equal("d")
            expect(newChildren[3]).to.equal(children[3])
        end)
    end)
    describe("MapObservableByKey", function()
        it("Doesn't create/destroy instances when no keys change", function()
            local input = Dec.State({"a", "b", "c"})

            local parent = Dec.Premade("Frame")
            parent:MapChildrenByKey(input, function(i, letter)
                return Dec.New("TextLabel", {
                    LayoutOrder = i,
                    Text = letter
                })
            end)

            local host = Instance.new("Frame")
            Dec.Root(host):Render(parent)

            -- Verify generated children match original state
            local children = (host:GetChildren() :: any) :: {TextLabel}
            expect(#children).to.equal(3)
            table.sort(children, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(children[1].Text).to.equal("a")
            expect(children[2].Text).to.equal("b")
            expect(children[3].Text).to.equal("c")

            -- Change value but not key
            input:Set({"a", "d", "c"})

            -- Verify that only child 2 was destroyed/re-created
            local newChildren = (host:GetChildren() :: any) :: {TextLabel}
            expect(#newChildren).to.equal(3)
            table.sort(newChildren, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(newChildren[1]).to.equal(children[1])
            expect(newChildren[2]).to.equal(children[2])
            expect(newChildren[2].Text).to.equal("d")
            expect(newChildren[3]).to.equal(children[3])
        end)
    end)
    describe("MapObservableByValue", function()
        it("Doesn't create/destroy instances when no values change", function()
            local input = Dec.State({"a", "b", "c"})

            local parent = Dec.Premade("Frame")
            parent:MapChildrenByValue(input, function(letter, i)
                return Dec.New("TextLabel", {
                    LayoutOrder = i,
                    Text = letter
                })
            end)

            local host = Instance.new("Frame")
            Dec.Root(host):Render(parent)

            -- Verify generated children match original state
            local children = (host:GetChildren() :: any) :: {TextLabel}
            expect(#children).to.equal(3)
            table.sort(children, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(children[1].Text).to.equal("a")
            expect(children[2].Text).to.equal("b")
            expect(children[3].Text).to.equal("c")

            -- Shift value order
            input:Set({"c", "a", "b"})

            -- Verify that only child 2 was destroyed/re-created
            local newChildren = (host:GetChildren() :: any) :: {TextLabel}
            expect(#newChildren).to.equal(3)
            table.sort(newChildren, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            expect(newChildren[2]).to.equal(children[1])
            expect(newChildren[3]).to.equal(children[2])
            expect(newChildren[1]).to.equal(children[3])
        end)
    end)
end
