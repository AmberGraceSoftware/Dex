"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4216],{73688:e=>{e.exports=JSON.parse('{"functions":[{"name":"Set","desc":"Sets the value at a specific key.","params":[{"name":"key","desc":"","lua_type":"K"},{"name":"value","desc":"","lua_type":"V"}],"returns":[],"function_type":"method","source":{"line":93,"path":"src/Observables/StateRecord.luau"}},{"name":"Current","desc":"Gets the current value at a specific key, or the current value of the whole\\ndictionary if no first argument is provided.\\n\\n:::caution\\nCurrently, the value returned by `StateRecord:Current()` with no first\\nparameter is mutable! Modifying this value directly may cause unexpected\\nbehavior!\\n:::","params":[{"name":"key","desc":"","lua_type":"K?"}],"returns":[{"desc":"","lua_type":"V | {[K: V]}"}],"function_type":"method","source":{"line":147,"path":"src/Observables/StateRecord.luau"}},{"name":"Replace","desc":"Replaces the entire dictionary with a new value","params":[{"name":"newDict","desc":"","lua_type":"{[K]: V}"}],"returns":[],"function_type":"method","source":{"line":173,"path":"src/Observables/StateRecord.luau"}},{"name":"Index","desc":"Creates a new observable which observes only a specific key within the\\ndictionary. Changes in other keys will not affect subscribers to this\\nindexed state.\\n\\nThe returned observable is also a State object, and setting values in this\\nstate will set values in the original Dict object.\\n\\nExample:\\n```lua\\nlocal playerCoinsDict = Dex.Dict({} :: {[Player]: number})\\n\\n-- Use Index to observe states at a particular key. \\nlocal player = game.Players.LocalPlayer\\nlocal ourCoins = playerCoinsDict:Index(player)\\n\\n-- . . . Updates in dict will be reflected in ourCoins:\\nplayerCoinsDict:Replace({ [player] = 100 })\\nprint(coins:Current()) -- 100\\n\\n-- . . . And vice versa!\\ncoins:Set(42)\\nprint(playerCoinsDict:Current()[player]) -- 42\\n```","params":[{"name":"key","desc":"","lua_type":"K"}],"returns":[{"desc":"","lua_type":"State<V>"}],"function_type":"method","source":{"line":277,"path":"src/Observables/StateRecord.luau"}}],"properties":[],"types":[],"name":"Dict","desc":"#### Inherits [Observable]\\n\\nWriteable observable which refers to a dictionary of known key and value\\ntypes.\\n\\nContains utility functions for observing and updating specific keys within\\nthis table, as well as cheaply observing specific keys within this table.\\n\\n## Constructor\\n\\n---\\n\\n### Dex.Dict\\n```ts\\nDex.Dict<K, V>(\\n    initialValue {[K]: V}\\n) -> Dict<K, V>\\n```\\n\\nCreates a new [Dict] observable with the given initial value.","tags":["Observable"],"source":{"line":62,"path":"src/Observables/StateRecord.luau"}}')}}]);