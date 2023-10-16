---
sidebar_position: 2
---

# Installation

:::warning
Dex is still a work in progress and does not currently have a full release!
Please avoiding Dex in production-bound projects, as the library is not fully
tested, and the API may be subject to change
:::

Dex can be installed using Wally, or imported into your Roblox project directly.

## Roblox Studio Installation

To add Dex to your Roblox Studio project, download the
[latest `.rbxmx` release from Github](https://github.com/AmberGraceSoftware/Dex/releases/latest),
then drag the model file into Roblox Studio. Place the Dex library somewhere in
ReplicatedStorage.

## Rojo + Wally Installation

To install Dex using Wally, first install [Rojo](https://rojo.space/docs/v7/)
and [Wally](https://wally.run/install), then search for the last published Dex
release on the [Wally website](https://wally.run/package/ambergracesoftware/dex),
or run the following command to get the latest version:
```sh
$ wally search ambergracesoftware/dex
```
To add Dex to your project, add an entry under the `[dependencies]` section of
your project's `wally.toml` file, replacing `X.Y.Z` with Dex's latest version
number:
```toml
Dex = "ambergracesoftware/dex@X.Y.Z"
```

Finally, run
```sh
$ wally install
```
On the command line to get have the latest install added to your project's
Packages folder.

It is also recommended you run the
[wally-package-types](https://crates.io/crates/wally-package-types) tool after
installing or updating Dex, as well as the
[Luau LSP](https://github.com/JohnnyMorganz/luau-lsp) in order to utilize Dex
with Luau's type safety features.