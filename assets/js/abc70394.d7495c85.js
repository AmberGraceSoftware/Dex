"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4070],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>f});var r=n(67294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function c(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var l=r.createContext({}),s=function(e){var t=r.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},p=function(e){var t=s(e.components);return r.createElement(l.Provider,{value:t},e.children)},u="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,i=e.originalType,l=e.parentName,p=c(e,["components","mdxType","originalType","parentName"]),u=s(n),d=o,f=u["".concat(l,".").concat(d)]||u[d]||m[d]||i;return n?r.createElement(f,a(a({ref:t},p),{},{components:n})):r.createElement(f,a({ref:t},p))}));function f(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var i=n.length,a=new Array(i);a[0]=d;var c={};for(var l in t)hasOwnProperty.call(t,l)&&(c[l]=t[l]);c.originalType=e,c[u]="string"==typeof e?e:o,a[1]=c;for(var s=2;s<i;s++)a[s]=n[s];return r.createElement.apply(null,a)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},77795:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>a,default:()=>m,frontMatter:()=>i,metadata:()=>c,toc:()=>s});var r=n(87462),o=(n(67294),n(3905));const i={sidebar_position:14},a="Combining Components",c={unversionedId:"Chapter2/Combine",id:"Chapter2/Combine",title:"Combining Components",description:"Tutorials are still in progress, and will be released section-by-section",source:"@site/docs/Chapter2/Combine.md",sourceDirName:"Chapter2",slug:"/Chapter2/Combine",permalink:"/docs/Chapter2/Combine",draft:!1,editUrl:"https://github.com/AmberGraceSoftware/Dex/edit/master/docs/Chapter2/Combine.md",tags:[],version:"current",sidebarPosition:14,frontMatter:{sidebar_position:14},sidebar:"defaultSidebar",previous:{title:"Triggering Effects",permalink:"/docs/Chapter2/Effects"},next:{title:"Structuring your Application",permalink:"/docs/Chapter2/ApplicationStructure"}},l={},s=[{value:"Section Outline:",id:"section-outline",level:2}],p={toc:s},u="wrapper";function m(e){let{components:t,...n}=e;return(0,o.kt)(u,(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"combining-components"},"Combining Components"),(0,o.kt)("admonition",{type:"warning"},(0,o.kt)("p",{parentName:"admonition"},"Tutorials are still in progress, and will be released section-by-section")),(0,o.kt)("h2",{id:"section-outline"},"Section Outline:"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},"Introducing ",(0,o.kt)("inlineCode",{parentName:"li"},"virtualInstance:Combine(virtualInstance)"),", use cases, how it\nopens the door for re-useable Components and composition over inheritance"),(0,o.kt)("li",{parentName:"ul"},"Making an input wrapper that uses ",(0,o.kt)("inlineCode",{parentName:"li"},":Combine()")),(0,o.kt)("li",{parentName:"ul"},"Making a view router using ",(0,o.kt)("inlineCode",{parentName:"li"},":Combine()")," to only mount a component while it\nis currently visible"),(0,o.kt)("li",{parentName:"ul"},"Things to avoid, best practices (i.e. Pure functions)")))}m.isMDXComponent=!0}}]);