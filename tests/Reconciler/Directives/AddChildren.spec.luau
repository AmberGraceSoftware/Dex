--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    describe("AddChild", function()
        it("Adds single VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            vInst:AddChildren({
                Foo = Dex.New("Frame")
            })

            Dex.Root(host):Render(vInst)
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Foo")
        end)
        it("Adds a observable child list", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")

            local childrenState = Dex.State({
                Dex.New("Frame"),
                Dex.New("Frame"),
            })
            vInst:AddChildren(childrenState)

            Dex.Root(host):Render(vInst)
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
                Dex.New("ImageLabel"),
                Dex.New("ImageLabel"),
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
            local vInst = Dex.Premade("Frame")

            local childrenState = Dex.State({
                a = Dex.New("Frame"),
                b = Dex.New("Frame"),
            } :: {[string]: Dex.VirtualInstance})
            vInst:AddChildren(childrenState)

            Dex.Root(host):Render(vInst)
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
                c = Dex.New("ImageLabel"),
                d = Dex.New("ImageLabel"),
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
            local vInst = Dex.Premade("Frame")

            local childAState = Dex.State(Dex.New("Frame") :: any)
            vInst:AddChildren({
                a = childAState,
                b = Dex.New("ImageLabel")
            })

            Dex.Root(host):Render(vInst)

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

            childAState:Set(Dex.New("TextLabel", {Name = "Bar"}))
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("Bar")
            expect(children[1].ClassName).to.equal("TextLabel")
            expect(children[2].Name).to.equal("b")
            expect(children[2].ClassName).to.equal("ImageLabel")

            childAState:Set(Dex.Nil)
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(1)
            expect(children[1].Name).to.equal("b")
            expect(children[1].ClassName).to.equal("ImageLabel")
        end)
        it("Adds a nested observable single child value", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")

            local childAState = Dex.State(Dex.New("Frame") :: any)
            local nestedObservable = Dex.State(childAState)
            vInst:AddChildren({
                a = nestedObservable,
                b = Dex.New("ImageLabel")
            })

            Dex.Root(host):Render(vInst)

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

            childAState:Set(Dex.New("TextLabel", {Name = "Bar"}))
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("Bar")
            expect(children[1].ClassName).to.equal("TextLabel")
            expect(children[2].Name).to.equal("b")
            expect(children[2].ClassName).to.equal("ImageLabel")

            nestedObservable:Set(Dex.Nil :: any)
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(1)
            expect(children[1].Name).to.equal("b")
            expect(children[1].ClassName).to.equal("ImageLabel")
        end)
        it("Adds observable list of observable children", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")

            local childAState = Dex.State(Dex.New("Frame") :: any)
            local childMap = Dex.State({
                a = childAState,
                b = Dex.New("ImageLabel")
            } :: {[string]: any})
            vInst:AddChildren(childMap)

            Dex.Root(host):Render(vInst)

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

            childAState:Set(Dex.New("TextLabel", {Name = "Bar"}))
            children = host:GetChildren()
            table.sort(children, function(a, b)
                return a.Name < b.Name
            end)
            expect(#children).to.equal(2)
            expect(children[1].Name).to.equal("Bar")
            expect(children[1].ClassName).to.equal("TextLabel")
            expect(children[2].Name).to.equal("b")
            expect(children[2].ClassName).to.equal("ImageLabel")

            childMap:Set({})
            expect(#host:GetChildren()).to.equal(0)
        end)
    end)
end
