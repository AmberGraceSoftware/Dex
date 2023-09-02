--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("AddChild", function()
        it("Adds single VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            vInst:AddChildren({
                Foo = Dec.New("Frame")
            })

            Dec.Root(host):Render(vInst)
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Foo")
        end)
        it("Adds a observable child list", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")

            local childrenState = Dec.State({
                Dec.New("Frame"),
                Dec.New("Frame"),
            })
            vInst:AddChildren(childrenState)

            Dec.Root(host):Render(vInst)
            local children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("1")
            expect(children[2].Name).to.equal("2")
            expect(children[1].ClassName).to.equal("Frame")
            expect(children[2].ClassName).to.equal("Frame")

            childrenState:Set({
                Dec.New("ImageLabel"),
                Dec.New("ImageLabel"),
            })
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("1")
            expect(children[2].Name).to.equal("2")
            expect(children[1].ClassName).to.equal("ImageLabel")
            expect(children[2].ClassName).to.equal("ImageLabel")
        end)
        it("Adds a observable child map", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")

            local childrenState = Dec.State({
                a = Dec.New("Frame"),
                b = Dec.New("Frame"),
            } :: {[string]: Dec.VirtualInstance})
            vInst:AddChildren(childrenState)

            Dec.Root(host):Render(vInst)
            local children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("a")
            expect(children[2].Name).to.equal("b")
            expect(children[1].ClassName).to.equal("Frame")
            expect(children[2].ClassName).to.equal("Frame")

            childrenState:Set({
                c = Dec.New("ImageLabel"),
                d = Dec.New("ImageLabel"),
            })
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("c")
            expect(children[2].Name).to.equal("d")
            expect(children[1].ClassName).to.equal("ImageLabel")
            expect(children[2].ClassName).to.equal("ImageLabel")
        end)
        it("Adds a observable single child value", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")

            local childAState = Dec.State(Dec.New("Frame") :: any)
            vInst:AddChildren({
                a = childAState,
                b = Dec.New("ImageLabel")
            })

            Dec.Root(host):Render(vInst)

            local children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("a")
            expect(children[1].ClassName).to.equal("Frame")
            expect(children[2].Name).to.equal("b")
            expect(children[2].ClassName).to.equal("ImageLabel")

            childAState:Set(nil)
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(1)
            expect(children[1].Name).to.equal("b")
            expect(children[1].ClassName).to.equal("ImageLabel")

            childAState:Set(Dec.New("TextLabel", {Name = "Bar"}))
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("Bar")
            expect(children[1].ClassName).to.equal("TextLabel")
            expect(children[2].Name).to.equal("b")
            expect(children[2].ClassName).to.equal("ImageLabel")

            childAState:Set(Dec.Nil)
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#host:GetChildren()).to.equal(1)
            expect(children[1].Name).to.equal("b")
            expect(children[1].ClassName).to.equal("ImageLabel")
        end)
    end)
end
