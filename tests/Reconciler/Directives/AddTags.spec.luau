--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    describe("AddChild", function()
        it("Adds a static tag list", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            vInst:AddTags({"Foo", "Fighters", "Baz"})

            Dex.Root(host):Render(vInst)

            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)
        end)
        it("Adds an observable tag list", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            local tags = Dex.State({"Foo", "Fighters", "Baz"})
            vInst:AddTags(tags)

            Dex.Root(host):Render(vInst)
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags:Set({"Fighters", "Baz"})
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags:Set({"Foo", "Fighters"})
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
        end)
        it("Adds a nested-observable tag list", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            local tags = Dex.State({"Foo", "Fighters", "Baz"})
            local nestingTags = Dex.State(tags :: any)
            vInst:AddTags(nestingTags)

            Dex.Root(host):Render(vInst)
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags:Set({"Fighters", "Baz"})
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            nestingTags:Set({"Foo", "Fighters"})
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)

            nestingTags:Set(tags)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)
        end)
        it("Adds a list of observable tags", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            local tags = {
                Dex.State("Foo" :: any),
                Dex.State("Fighters" :: any),
                Dex.State("Baz" :: any)
            }
            local nestingTags = Dex.State(tags :: any)
            vInst:AddTags(nestingTags)

            Dex.Root(host):Render(vInst)
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set("Bar")
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Bar")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set(nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set("Fighters")
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set(Dex.Nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            nestingTags:Set({})
            expect(#host:GetTags()).to.equal(0)
        end)
        it("Adds handles duplicate observable tags", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            local tags = {
                Dex.State("Foo" :: any),
                Dex.State("Fighters" :: any),
                Dex.State("Baz" :: any)
            }
            vInst:AddTags(tags)

            Dex.Root(host):Render(vInst)
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set("Foo")
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set(nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set("Fighters")
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            tags[2]:Set(Dex.Nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)
        end)
        it("Dedupes multiple tag directives", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            local tags1 = {
                Dex.State("Foo" :: any),
                Dex.State("Fighters" :: any),
            }
            vInst:AddTags(tags1)

            local tags2 = Dex.State({
                "Foo",
                "Bar"
            })
            vInst:AddTags(tags2)

            Dex.Root(host):Render(vInst)
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Bar")).to.equal(true)

            tags1[2]:Set("Bar")
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Bar")).to.equal(true)

            tags2:Set({})
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Bar")).to.equal(true)

            tags1[1]:Set(Dex.Nil)
            expect(#host:GetTags()).to.equal(1)
            expect(host:HasTag("Bar")).to.equal(true)

            tags2:Set({"Foo", "Fighters"})
            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Bar")).to.equal(true)
        end)
    end)
end