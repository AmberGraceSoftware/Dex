--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("SetProperties", function()
        it("Sets static properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local virtualInstance = Dec.Premade("TextLabel", {
                Text = "Foo",
            })
            virtualInstance:SetProperties({
                LayoutOrder = 123,
            })
            Dec.Root(host):Render(virtualInstance)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)
        end)
        it("Sets observable properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local textState = Dec.State("Foo")
            local layoutOrderState = Dec.State(123)

            local virtualInstance = Dec.Premade("TextLabel", {
                Text = textState,
            })
            virtualInstance:SetProperties({
                LayoutOrder = layoutOrderState,
            })
            Dec.Root(host):Render(virtualInstance)

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
            local virtualInstance = Dec.Premade("TextLabel", {
                Changed = function()
                    didChange = true
                end
            })
            Dec.Root(host):Render(virtualInstance)

            expect(didChange).to.equal(false)

            host.Text = "Foo"
            expect(didChange).to.equal(true)
        end)
        it("Sets reference to another VirtualInstance", function()
            local host = Instance.new("ViewportFrame")

            local camera = Dec.New("Camera")
            local virtualInstance = Dec.Premade("ViewportFrame", {
                CurrentCamera = camera
            }, {camera})
            Dec.Root(host):Render(virtualInstance)

            expect(#host:GetChildren()).to.equal(1)
            expect(host.CurrentCamera).to.equal(host:GetChildren()[1])
        end)
        it("Sets a static reference to Dec.Nil", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local virtualInstance = Dec.Premade("ViewportFrame", {
                CurrentCamera = Dec.Nil
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dec.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Sets an observable reference to Dec.Nil", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local observableReference = Dec.State(Dec.Nil :: any)
            local virtualInstance = Dec.Premade("ViewportFrame", {
                CurrentCamera = observableReference
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dec.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)

            observableReference:Set(camera)

            expect(host.CurrentCamera).to.equal(camera)

            observableReference:Set(Dec.Nil)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Sets an observable reference to VirtualInstance", function()
            local host = Instance.new("ViewportFrame")
            local camera = Instance.new("Camera")
            camera.Parent = host
            host.CurrentCamera = camera

            local observableReference = Dec.State(Dec.Nil :: any)
            local cameraVInst = Dec.Premade("Camera")
            local virtualInstance = Dec.Premade("ViewportFrame", {
                CurrentCamera = observableReference
            }, {
                Camera = cameraVInst
            })

            expect(host.CurrentCamera).to.equal(camera)

            Dec.Root(host):Render(virtualInstance)

            expect(host.CurrentCamera).to.equal(nil)

            observableReference:Set(cameraVInst)

            expect(host.CurrentCamera).to.equal(camera)

            observableReference:Set(Dec.Nil)

            expect(host.CurrentCamera).to.equal(nil)
        end)
        it("Resolves nested observable properties", function()
            local host = Instance.new("TextLabel")
            local layoutOrderState = Dec.State(123)
            local nestingState = Dec.State(layoutOrderState :: any)

            local virtualInstance = Dec.Premade("TextLabel", {})
            virtualInstance:SetProperties({
                LayoutOrder = nestingState,
            })
            Dec.Root(host):Render(virtualInstance)
            expect(host.LayoutOrder).to.equal(123)

            layoutOrderState:Set(456)
            expect(host.LayoutOrder).to.equal(456)

            nestingState:Set(789)
            layoutOrderState:Set(10_11_12)
            expect(host.LayoutOrder).to.equal(789)

            nestingState:Set(layoutOrderState)
            expect(host.LayoutOrder).to.equal(10_11_12)
        end)
    end)
end
