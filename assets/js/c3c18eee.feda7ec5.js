"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7409],{3905:(e,n,t)=>{t.d(n,{Zo:()=>p,kt:()=>h});var a=t(67294);function r(e,n,t){return n in e?Object.defineProperty(e,n,{value:t,enumerable:!0,configurable:!0,writable:!0}):e[n]=t,e}function i(e,n){var t=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);n&&(a=a.filter((function(n){return Object.getOwnPropertyDescriptor(e,n).enumerable}))),t.push.apply(t,a)}return t}function o(e){for(var n=1;n<arguments.length;n++){var t=null!=arguments[n]?arguments[n]:{};n%2?i(Object(t),!0).forEach((function(n){r(e,n,t[n])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(t)):i(Object(t)).forEach((function(n){Object.defineProperty(e,n,Object.getOwnPropertyDescriptor(t,n))}))}return e}function l(e,n){if(null==e)return{};var t,a,r=function(e,n){if(null==e)return{};var t,a,r={},i=Object.keys(e);for(a=0;a<i.length;a++)t=i[a],n.indexOf(t)>=0||(r[t]=e[t]);return r}(e,n);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)t=i[a],n.indexOf(t)>=0||Object.prototype.propertyIsEnumerable.call(e,t)&&(r[t]=e[t])}return r}var s=a.createContext({}),c=function(e){var n=a.useContext(s),t=n;return e&&(t="function"==typeof e?e(n):o(o({},n),e)),t},p=function(e){var n=c(e.components);return a.createElement(s.Provider,{value:n},e.children)},d="mdxType",u={inlineCode:"code",wrapper:function(e){var n=e.children;return a.createElement(a.Fragment,{},n)}},m=a.forwardRef((function(e,n){var t=e.components,r=e.mdxType,i=e.originalType,s=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),d=c(t),m=r,h=d["".concat(s,".").concat(m)]||d[m]||u[m]||i;return t?a.createElement(h,o(o({ref:n},p),{},{components:t})):a.createElement(h,o({ref:n},p))}));function h(e,n){var t=arguments,r=n&&n.mdxType;if("string"==typeof e||r){var i=t.length,o=new Array(i);o[0]=m;var l={};for(var s in n)hasOwnProperty.call(n,s)&&(l[s]=n[s]);l.originalType=e,l[d]="string"==typeof e?e:r,o[1]=l;for(var c=2;c<i;c++)o[c]=t[c];return a.createElement.apply(null,o)}return a.createElement.apply(null,t)}m.displayName="MDXCreateElement"},41818:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>s,contentTitle:()=>o,default:()=>u,frontMatter:()=>i,metadata:()=>l,toc:()=>c});var a=t(87462),r=(t(67294),t(3905));const i={sidebar_position:9},o="VirtualInstance Directives",l={unversionedId:"Chapter1/Directives",id:"Chapter1/Directives",title:"VirtualInstance Directives",description:"Dex tries to allow access to all use cases in Roblox's Data Model through VirtualInstances.",source:"@site/docs/Chapter1/Directives.md",sourceDirName:"Chapter1",slug:"/Chapter1/Directives",permalink:"/docs/Chapter1/Directives",draft:!1,editUrl:"https://github.com/AmberGraceSoftware/Dex/edit/master/docs/Chapter1/Directives.md",tags:[],version:"current",sidebarPosition:9,frontMatter:{sidebar_position:9},sidebar:"defaultSidebar",previous:{title:"Mapping Child Components",permalink:"/docs/Chapter1/MappingChildComponents"},next:{title:"Animating UI Components",permalink:"/docs/Chapter1/Animations"}},s={},c=[{value:"Basic Directives",id:"basic-directives",level:2},{value:"Defining Attributes",id:"defining-attributes",level:2},{value:"Defining Tags",id:"defining-tags",level:2},{value:"Connecting Events",id:"connecting-events",level:2},{value:"Listening to Property &amp; Attribute Changed events",id:"listening-to-property--attribute-changed-events",level:2},{value:"FindChild Directive",id:"findchild-directive",level:2},{value:"Combining VirtualInstances",id:"combining-virtualinstances",level:2},{value:"Lifecycle Callbacks",id:"lifecycle-callbacks",level:2}],p={toc:c},d="wrapper";function u(e){let{components:n,...t}=e;return(0,r.kt)(d,(0,a.Z)({},p,t,{components:n,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"virtualinstance-directives"},"VirtualInstance Directives"),(0,r.kt)("p",null,"Dex tries to allow access to all use cases in Roblox's ",(0,r.kt)("a",{parentName:"p",href:"https://create.roblox.com/docs/projects/data-model"},"Data Model")," through VirtualInstances."),(0,r.kt)("p",null,"VirtualInstances aim to be as declarative as possible (i.e. described in\nterms of ",(0,r.kt)("em",{parentName:"p"},"how they are put together in relation to state")," rather than in terms\nof the exact instructions for how to put them together). Dex uses a concept\ncalled ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Directives"))," to bridge this gap."),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Directives"))," are methods which declare special instructions on how to put\ntogether an instance heirarchy based on application state. They can be ",(0,r.kt)("em",{parentName:"p"},"added"),"\nto a VirtualInstance but ",(0,r.kt)("em",{parentName:"p"},"never removed.")," Once a VirtualInstance is rendered by\nDex, it becomes ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"frozen")),", meaning no more directives can be added or removed\nfrom the VirtualInstance."),(0,r.kt)("h2",{id:"basic-directives"},"Basic Directives"),(0,r.kt)("p",null,"The ",(0,r.kt)("a",{parentName:"p",href:"/API/VirtualInstance#SetProperties"},":SetProperties()")," and\n",(0,r.kt)("a",{parentName:"p",href:"/API/VirtualInstance#AddChildren"},":AddChildren()")," directives define a\nVirtualInstance's properties and children respectively. The first two arguments\nof VirtualInstance constructors (such as ",(0,r.kt)("a",{parentName:"p",href:"/api/Dex#New"},"Dex.New"),") automatically\nadd a ",(0,r.kt)("inlineCode",{parentName:"p"},":SetProperties()")," and ",(0,r.kt)("inlineCode",{parentName:"p"},":AddChildren()")," directive when defined."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'-- Creating a VirtualInstance with "Properties" and "Children" tables defined:\nlocal virtualInstance1 = Dex.New("Frame", {\n    BackgroundTransparency = 1\n}, {\n    Dex.New("TextLabel")\n})\n\n-- . . . Is equivalent to adding a "SetProperties" and "AddChildren" directive!\nlocal virtualInstance2 = Dex.New("Frame")\nvirtualInstance2:SetProperties({\n    BackgroundTransparency = 1,\n})\nvirtualInstance2:AddChildren({\n    Dex.New("TextLabel"),\n})\n')),(0,r.kt)("p",null,"You can add these directives multiple times to split up the logic of a UI\ncomponent:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function Component(props: {\n    layoutOrder: number,\n    coins: Dex.Observable<number>,\n})\n    -- Layout\n    local label = Dex.New("TextLabel", {\n        LayoutOrder = props.layoutOrder\n    })\n\n    -- Coins display\n    label:SetProperties({\n        Text = props.coins:Map(function(currentCoins)\n            return string.format("%.2f", currentCoins)\n        end)\n    })\n\n    return label\nend\n')),(0,r.kt)("p",null,"The previous section also goes over the ",(0,r.kt)("a",{parentName:"p",href:"./MappingChildComponents"},(0,r.kt)("inlineCode",{parentName:"a"},":MapChildren()"),",\n",(0,r.kt)("inlineCode",{parentName:"a"},":MapChildrenByKey()"),", and\n",(0,r.kt)("inlineCode",{parentName:"a"},":MapChildrenByValue()")," directives"),", which are more\noptimized ways of specifying the children of a VirtualInstance."),(0,r.kt)("p",null,"Let's go over a few more ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Directives"))," and their use cases."),(0,r.kt)("h2",{id:"defining-attributes"},"Defining Attributes"),(0,r.kt)("p",null,"Dex can render attributes in a similar way to properties by adding a\n",(0,r.kt)("inlineCode",{parentName:"p"},":SetAttributes()")," directive. This takes in a table that can hold both ",(0,r.kt)("em",{parentName:"p"},"Static"),"\nand ",(0,r.kt)("em",{parentName:"p"},"Observable")," values:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function FrameWithAttributes(props: {\n    id: Dex.Observable<string>\n})\n    local frame = Dex.New("Frame")\n    frame:SetAttributes({\n        id = props.id,\n    })\n    return frame\nend\n')),(0,r.kt)("p",null,"When rendered, this component will generate a frame with attributes that adjusts\nto be equal to a state passed in via props:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local frame = FrameWithAttributes({\n    id = Dex.State("ValueFromProps")\n})\n')),(0,r.kt)("center",null,(0,r.kt)("img",{width:"80%",src:"/TutorialAssets/Chapter1/Directives/RenderedAttributes.png"})),(0,r.kt)("h2",{id:"defining-tags"},"Defining Tags"),(0,r.kt)("p",null,"Dex also provides an ",(0,r.kt)("inlineCode",{parentName:"p"},":AddTags()")," directives, which adds\n",(0,r.kt)("a",{parentName:"p",href:"https://create.roblox.com/docs/reference/engine/classes/CollectionService"},"CollectionService Tags"),"\nto a VirtualInstance while it is being rendered."),(0,r.kt)("p",null,"The tag list can be an observable, and can also contain a list of observable\nstring values:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function TaggedUIScaleConstraint(props: {\n    darkMode: Dex.Observable<boolean>\n})\n    local uiScale = Dex.New("UIScale")\n    frame:AddTags(props.darkMode:Map(function(darkModeEnabled)\n        if darkModeEnabled then\n            return {"ApplyDarkMode", "AutoScaling"}\n        else\n            return {"AutoScaling"}\n        end\n    end))\n    return uiScale\nend\n')),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local uiScale = TaggedUIScaleConstraint({\n    darkMode = Dex.State(false)\n})\n")),(0,r.kt)("center",null,(0,r.kt)("img",{width:"80%",src:"/TutorialAssets/Chapter1/Directives/RenderedTags.png"})),(0,r.kt)("h2",{id:"connecting-events"},"Connecting Events"),(0,r.kt)("p",null,"The ",(0,r.kt)("inlineCode",{parentName:"p"},":SetProperties()")," directive can connect to listeners by providing a\nfunction as a value for an event name:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function Button()\n    return Dex.Premade("GuiButton", {\n        Activated = function()\n            print("Button was pressed!")\n        end,\n    })\nend\n')),(0,r.kt)("p",null,"Alternatively, Dex provides a separate directive ",(0,r.kt)("inlineCode",{parentName:"p"},":Connect()")," which achieves\nthe same result:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function Button()\n    local button = Dex.Premade("GuiButton")\n    button:Connect("Activated", function()\n        print("Button was pressed!")\n    end)\n    return button\nend\n')),(0,r.kt)("p",null,"Dex will automatically clean up the connection/disconnection of these event\nlisteners while a VirtualInstance is being rendered."),(0,r.kt)("h2",{id:"listening-to-property--attribute-changed-events"},"Listening to Property & Attribute Changed events"),(0,r.kt)("p",null,"The ",(0,r.kt)("a",{parentName:"p",href:"https://dex.ambergracesoftware.com/api/VirtualInstance#OutProperty"},":OutProperty()"),"\nand ",(0,r.kt)("a",{parentName:"p",href:"https://dex.ambergracesoftware.com/api/VirtualInstance#OutProperty"},":OutAttribute()"),"\ndirectives listen to changes in a specific property or attribute while the\nVirtualInstance is being rendered. These directives return an Observable\nobject which changes when the property or attribute changes, and are initialized\nto the value and type of the second argument passed into the directive:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function LabelComponent(props: {\n    text: Dex.Observable<string>m\n})\n    local label = Dex.Premade("TextLabel", {\n        Text = props.text,\n    })\n    -- Create an Observable which tracks the ContentText (translated text) of\n    -- the label in realtime. This observable initializes to an empty string\n    -- (second argument) until label is mounted and a ContentText is defined.\n    local contentText = label:OutProperty("Text", "")\n\n    -- Print whenever the translated text changes\n    label:SubscribeWhileMounted(contentText, function(currentContentText)\n        print("Translated text is", currentContentText)\n    end)\nend\n')),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"For more on output directives such as ",(0,r.kt)("inlineCode",{parentName:"p"},":OutProperty()"),", ",(0,r.kt)("inlineCode",{parentName:"p"},":OutAttribute()"),",\n",(0,r.kt)("inlineCode",{parentName:"p"},":OutInitialProperty()"),", ",(0,r.kt)("inlineCode",{parentName:"p"},":OutInitialAttribute()"),", and ",(0,r.kt)("inlineCode",{parentName:"p"},":OutInstance()"),", see\n",(0,r.kt)("a",{parentName:"p",href:"/docs/Chapter2/EventsOutputObservables"},"the Advanced tutorial on using these directives"))),(0,r.kt)("h2",{id:"findchild-directive"},"FindChild Directive"),(0,r.kt)("p",null,"When working with premade VirtualInstance templates, you may commonly need to\ndefine a child VirtualInstance, then set it as a child of another\nVirtualInstance:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local child = Dex.Premade("Frame")\nparentVirtualInstance:AddChild("ChildName", child)\n')),(0,r.kt)("p",null,"The ",(0,r.kt)("inlineCode",{parentName:"p"},":FindChild()")," directive conveniently simplifies this idiom into a single\nstatement:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local child = parentVirtualInstance:FindChild("ChildName")\n')),(0,r.kt)("h2",{id:"combining-virtualinstances"},"Combining VirtualInstances"),(0,r.kt)("p",null,"Dex provides a special directive, ",(0,r.kt)("a",{parentName:"p",href:"/api/VirtualInstance#Combine"},":Combine"),",\nwhich combines the directive of one or more premade VirtualInstances with\nanother VirtualInstance. The VirtualInstances passed to the ",(0,r.kt)("inlineCode",{parentName:"p"},":Combine()"),"\ndirective must meet the following requirements:"),(0,r.kt)("ul",null,(0,r.kt)("li",{parentName:"ul"},'They must be of "Premade" type, with an equivalent or related ClassName to the\ntarget VirtualInstance.'),(0,r.kt)("li",{parentName:"ul"},"They must not already be rendered by Dex and/or combined with another\nVirtualInstance.")),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function PrintOnPress()\n    return Dex.Premade("GuiButton", {\n        Activated = function()\n            print("Button was pressed!")\n        end,\n    })\nend\n')),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function Button()\n    local button = Dex.New("TextButton", {\n        Text = "Click Me!",\n    })\n    button:Combine(PrintOnPress())\n    return button\nend\n')),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"For more on using the ",(0,r.kt)("inlineCode",{parentName:"p"},":Combine()")," directive effectively, see\n",(0,r.kt)("a",{parentName:"p",href:"/docs/Chapter2/Combine"},"the Advanced tutorial on using Combine"))),(0,r.kt)("h2",{id:"lifecycle-callbacks"},"Lifecycle Callbacks"),(0,r.kt)("p",null,"A VirtualInstance is ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Mounted"))," when it is first rendered by Dex (either\npassed in as an argument to ",(0,r.kt)("a",{parentName:"p",href:"/api/Root#Render"},"Root:Render()"),", or created as a\nchild of another VirtualInstance). When the VirtualInstance stops being\nrendered, it is ",(0,r.kt)("strong",{parentName:"p"},(0,r.kt)("em",{parentName:"strong"},"Unmounted")),", meaning any created instances, side effects,\netc. are automatically cleaned up by Dex."),(0,r.kt)("p",null,"Dex provides the directives ",(0,r.kt)("a",{parentName:"p",href:"/api/VirtualInstance#OnMont"},":OnMount()")," and\n",(0,r.kt)("a",{parentName:"p",href:"/api/VirtualInstance#OnUnmount"},":OnUnmount()")," to listen to these events for\ncustom side effects."),(0,r.kt)("p",null,"Example:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local function Component()\n    local frame = Dex.New("Frame")\n    frame:OnMount(function()\n        print("Frame was mounted!")\n    end)\n    frame:OnUnmount(function()\n        print("Frame was unmounted!")\n    end)\n    return frame\nend\n')),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("h2",{parentName:"admonition",id:"subscribeonmounted-directive"},"SubscribeOnMounted directive"),(0,r.kt)("p",{parentName:"admonition"},"Dex provides the directive ",(0,r.kt)("a",{parentName:"p",href:"/api/VirtualInstance#SubscribeWhileMounted"},":SubscribeOnMounted()"),"\nto listen for changes to an Observable, and automatically clean up this listener\nwhen a VirtualInstance is no longer being rendered by Dex."),(0,r.kt)("p",{parentName:"admonition"},"Under the hood, ",(0,r.kt)("a",{parentName:"p",href:"/api/VirtualInstance#SubscribeWhileMounted"},":SubscribeOnMounted()"),"\nuses ",(0,r.kt)("inlineCode",{parentName:"p"},":OnMount()")," and ",(0,r.kt)("inlineCode",{parentName:"p"},":OnUnmount()")," to set up and take down the side effect of\nsubscribing to an observable:"),(0,r.kt)("pre",{parentName:"admonition"},(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local function SubscribeWhileMounted<T>(\n    self: VirtualInstance,\n    input: Observable<T>,\n    listener: (T) -> (),\n    immediatelyCallListener: boolean\n)\n    local unsubscribe: (() -> ())? = nil\n    self:OnMount(function()\n        unsubscribe = input:Subscribe(listener, immediatelyCallListener)\n    end)\n    self:OnUnmount(function()\n        if unsubscribe then\n            unsubscribe()\n        end\n    end)\nend\n")),(0,r.kt)("p",{parentName:"admonition"},"For custom side effects, this same pattern can be used to set up and take down\nthese custom effects while a VirtualInstance is being rendered.")))}u.isMDXComponent=!0}}]);