--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("DestroyPremadeChildren", function()
        it("Destroys all children of a mounted instance with no filter", function()
            local host = Instance.new("Frame")
            for i = 1, 3 do
                local child = Instance.new("Frame")
                child.Name = "Child" .. i
                child.Parent = host
            end
            
            local parent = Dec.Premade("Frame")
            parent:DestroyPremadeChildren()

            Dec.Root(host):Render(parent)

            expect(#host:GetChildren()).to.equal(0)
        end)
        it("Destroys all children of a mounted instance with name filter", function()
            local host = Instance.new("Frame")
            for i = 1, 3 do
                local child = Instance.new("Frame")
                child.Name = "Child" .. i
                child.Parent = host
            end
            
            local parent = Dec.Premade("Frame")
            parent:DestroyPremadeChildren("Child2")

            Dec.Root(host):Render(parent)

            expect(#host:GetChildren()).to.equal(2)
            local children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)

            expect(children[1].Name).to.equal("Child1")
            expect(children[2].Name).to.equal("Child3")
        end)
        it("Destroys all children of a mounted instance with predicate filter", function()
            local host = Instance.new("Frame")
            for i = 1, 3 do
                local child = Instance.new("Frame")
                child.Name = "Child" .. i
                child.LayoutOrder = i
                child.Parent = host
            end
            
            local parent = Dec.Premade("Frame")
            parent:DestroyPremadeChildren(function(child)
                if child:IsA("Frame") then
                    return child.LayoutOrder == 3
                end
                return false
            end)
            
            Dec.Root(host):Render(parent)

            expect(#host:GetChildren()).to.equal(2)
            local children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)

            expect(children[1].Name).to.equal("Child1")
            expect(children[2].Name).to.equal("Child2")
        end)
    end)
end
