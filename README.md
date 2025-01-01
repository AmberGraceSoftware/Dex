# Dex

<p align="center">
    <img src="logo/Logo256.png" />
    <br/>
    <br/>
    Dex is a library for building reactive User Interfaces on Roblox.
    <br/>
    <br/>
</p>

Dex provides tools to prototype animated, responsive UI Components, and
manage state across an entire Roblox project. Dex Components can be written
entirely in Luau, or use premade assets built using Studio's UI editor.

<br/>

| DISCLAIMER: Dex is a work in progress, and does NOT currently have a full release! Please do not use Dex in production-bound code until v1.0.0 has been released. |
| --- |

<br/>

# Documentation

Please see the [Documentation Site](https://dex.ambergracesoftware.com) for
tutorials, a full API reference, and more!

<br/>

# Installation

Dex can either be imported into your Roblox project, or installed via Wally.

#### Roblox Studio Installation

To add Dex to your Roblox Studio project, download the
[latest `.rbxmx` release from Github](https://github.com/AmberGraceSoftware/Dex/releases/latest),
then drag the model file into Roblox Studio. Place the Dex library somewhere in
ReplicatedStorage.

#### Rojo + Wally Installation

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

<br/>

# Contributing

To contribute to Dex's development, you may fork this repository.

Dex uses the following toolchain for library development:
- [aftman](https://github.com/LPGhatguy/aftman)
    - Run `aftman install` in the root directory
    - Run `wally install` to install Dex's dev dependencies (i.e. testez)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Luau LSP VS Code Extension](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp), which should be configured to include the testez declaration file.
![](https://i.imgur.com/x9LjJDy.png)
- [Selene VS Code extension](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.selene-vscode)
- [Moonwave](https://eryn.io/moonwave/)
    - Install via `npm i -g moonwave@latest`
    - Run `moonwave dev` to live test the docs site in your local branch

Dex uses unit testing to validate code quality. Because Roblox Studio tests
cannot currently be fully automated, unit tests must be run manually before
changes can be merged into the main branch. To perform this process:
- Sync the build via `rojo build --output Dex.rbxlx`
- Set `workspace.SignalBehavior` to `Immediate`, as some unit tests require this to be true.
- Open the build in Roblox Studio, and run the command line script located in `game.ServerScriptStorage.TestRunner`
- Copy the "proof checksum" generated in Studio's output and replace the contents `testing_proof_checksum.txt` with this checksum, then commit this directly to the branch.
- Github will automatically start an action which compares the source code with the proof checksum. If it matches, and the unit tests were all successful, the current branch will be marked as safe to merge.
