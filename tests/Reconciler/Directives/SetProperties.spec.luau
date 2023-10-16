--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    describe("SetProperties", function()
        it("Sets static properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local virtualInstance = Dex.Premade("TextLabel", {
                Text = "Foo",
            })
            virtualInstance:SetProperties({
                LayoutOrder = 123,
            })
            Dex.Root(host):Render(virtualInstance)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)
        end)
        it("Sets observable properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local textState = Dex.State("Foo")
            local layoutOrderState = Dex.State(123)

            local virtualInstance = Dex.Premade("TextLabel", {
                Text = textState,
            })
            virtualInstance:SetProperties({
                LayoutOrder = layoutOrderState,
            })
            Dex.Root(host):Render(virtualInstance)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)

            textState:Set("Fighters")
            layoutOrderState:Set(456)

            expect(host.Text).to.equal("Fighters")
            expect(host.LayoutOrder).to.equal(456)
        end)
        it("Adds connections to a VirtualInstance", function()
            local host = Instance.new("TextLabel")

            local didChange = false
            local virtualInstance = Dex.Premade("TextLabel", {
                Changed = function()
                    didChange = true
                end
            })
            Dex.Root(host):Render(virtualInstance)

            expect(didChange).to.equal(false)

            host.Text = "Foo"
            expect(didChange).to.equal(true)
        end)
        it("Sets reference to another VirtualInstance", function()
            local host = Instance.new("ViewportFrame")

            local camera = Dex.New("Camera")
            local virtualInstance = Dex.Premade("ViewportFrame", {
                CurrentCamera = camera
            }, {camera})
            Dex.Root(host):Render(virtualInstance)

            expect(#host:GetChildren()).to.equal(1)
            expect(host.CurrentCamera).to.equal(host:GetChildren()[1])
        end)
        it("Sets a static reference to Dex.Nil", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local virtualInstance = Dex.Premade("ViewportFrame", {
                CurrentCamera = Dex.Nil
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dex.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Sets an observable reference to Dex.Nil", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local observableReference = Dex.State(Dex.Nil :: any)
            local virtualInstance = Dex.Premade("ViewportFrame", {
                CurrentCamera = observableReference
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dex.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)

            observableReference:Set(camera)

            expect(host.CurrentCamera).to.equal(camera)

            observableReference:Set(Dex.Nil)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Sets an observable reference to VirtualInstance", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local observableReference = Dex.State(Dex.Nil :: any)
            local cameraVInst = Dex.Premade("Camera")
            local virtualInstance = Dex.Premade("ViewportFrame", {
                CurrentCamera = observableReference
            }, {
                Camera = cameraVInst
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dex.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)

            observableReference:Set(cameraVInst)

            expect(host.CurrentCamera).to.equal(camera)

            observableReference:Set(Dex.Nil)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Resolves nested observable properties", function()
            local host = Instance.new("TextLabel")
            local layoutOrderState = Dex.State(123)
            local nestingState = Dex.State(layoutOrderState :: any)

            local virtualInstance = Dex.Premade("TextLabel", {})
            virtualInstance:SetProperties({
                LayoutOrder = nestingState,
            })
            Dex.Root(host):Render(virtualInstance)
            expect(host.LayoutOrder).to.equal(123)

            layoutOrderState:Set(456)
            expect(host.LayoutOrder).to.equal(456)

            nestingState:Set(789)
            layoutOrderState:Set(10_11_12)
            expect(host.LayoutOrder).to.equal(789)

            nestingState:Set(layoutOrderState)
            expect(host.LayoutOrder).to.equal(10_11_12)
        end)
        it("Uses the last defined key when multiple directives are used", function()
            local host = Instance.new("TextLabel")
            local layoutOrderState1 = Dex.State(123)
            local layoutOrderState2 = Dex.State(456)

            local virtualInstance = Dex.Premade("TextLabel")
            virtualInstance:SetProperties({LayoutOrder = layoutOrderState1})
            virtualInstance:SetProperties({LayoutOrder = layoutOrderState2})
            Dex.Root(host):Render(virtualInstance)
            expect(host.LayoutOrder).to.equal(456)

            layoutOrderState1:Set(789)
            expect(host.LayoutOrder).to.equal(456)

            layoutOrderState2:Set(10_11_12)
            expect(host.LayoutOrder).to.equal(10_11_12)
        end)
        it("Connects both listeners when two directives defining a function are used", function()
            local host = Instance.new("TextLabel")
            
            local changedCount1 = 0
            local changedCount2 = 0
            local virtualInstance = Dex.Premade("TextLabel")
            virtualInstance:SetProperties({
                Changed = function()
                    changedCount1 += 1
                end
            })
            virtualInstance:SetProperties({
                Changed = function()
                    changedCount2 += 1
                end
            })
            Dex.Root(host):Render(virtualInstance)
            expect(changedCount1).to.equal(0)
            expect(changedCount2).to.equal(0)

            host.Name = "Foo"
            expect(changedCount1).to.equal(1)
            expect(changedCount2).to.equal(1)
        end)
    end)
end
