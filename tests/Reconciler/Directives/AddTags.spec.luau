--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("AddChild", function()
        it("Adds a static tag list", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            vInst:AddTags({"Foo", "Fighters", "Baz"})

            Dec.Root(host):Render(vInst)

            expect(#host:GetTags()).to.equal(3)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Fighters")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)
        end)
        it("Adds an observable tag list", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            local tags = Dec.State({"Foo", "Fighters", "Baz"})
            vInst:AddTags(tags)

            Dec.Root(host):Render(vInst)
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
            local vInst = Dec.Premade("Frame")
            local tags = Dec.State({"Foo", "Fighters", "Baz"})
            local nestingTags = Dec.State(tags :: any)
            vInst:AddTags(nestingTags)

            Dec.Root(host):Render(vInst)
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
            local vInst = Dec.Premade("Frame")
            local tags = {
                Dec.State("Foo" :: any),
                Dec.State("Fighters" :: any),
                Dec.State("Baz" :: any)
            }
            local nestingTags = Dec.State(tags :: any)
            vInst:AddTags(nestingTags)

            Dec.Root(host):Render(vInst)
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

            tags[2]:Set(Dec.Nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)

            nestingTags:Set({})
            expect(#host:GetTags()).to.equal(0)
        end)
        it("Adds handles duplicate observable tags", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            local tags = {
                Dec.State("Foo" :: any),
                Dec.State("Fighters" :: any),
                Dec.State("Baz" :: any)
            }
            vInst:AddTags(tags)

            Dec.Root(host):Render(vInst)
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

            tags[2]:Set(Dec.Nil)
            expect(#host:GetTags()).to.equal(2)
            expect(host:HasTag("Foo")).to.equal(true)
            expect(host:HasTag("Baz")).to.equal(true)
        end)
    end)
end