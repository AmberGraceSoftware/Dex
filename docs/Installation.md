---
sidebar_position: 2
---

# Installation

Dec can either be imported into your Roblox project, or installed via Wally.

## Roblox Studio Installation

To add Dec to your Roblox Studio project, download the
[latest `.rbxmx` release from Github](https://github.com/AmberGraceSoftware/Dec/releases/latest),
then drag the model file into Roblox Studio. Place the Dec library somewhere in
ReplicatedStorage.

## Rojo + Wally Installation

To install Dec using Wally, first install [Rojo](https://rojo.space/docs/v7/)
and [Wally](https://wally.run/install), then search for the last published Dec
release on the [Wally website](https://wally.run/package/ambergracesoftware/dec),
or run the following command to get the latest version:
```sh
$ wally search ambergracesoftware/dec
```
To add Dec to your project, add an entry under the `[dependencies]` section of
your project's `wally.toml` file, replacing `X.Y.Z` with Dec's latest version
number:
```toml
Dec = "ambergracesoftware/dec@X.Y.Z"
```

Finally, run
```sh
$ wally install
```
On the command line to get have the latest install added to your project's
Packages folder.

It is also recommended you run the
[wally-package-types](https://crates.io/crates/wally-package-types) tool after
installing or updating Dec, as well as the
[Luau LSP](https://github.com/JohnnyMorganz/luau-lsp) in order to utilize Dec
with Luau's type safety features.