# Dec
| WARNING: Dec is a work in progress, and does NOT currently have a stable release or any testing. Please be patient. |
| --- |

Dec is a reactive UI library for Roblox.

It combines all of the best features of modern libraries like Roact, Fusion, and more for building reusable, performant, declarative UI components.

## Features

Dec is a **work in progress project** that started from a simple concept of ways to improve upon its predecessor, [Pract](https://github.com/AmberGraceRBLX/Pract), while using the most loved features of Elttob's [Fusion](https://elttob.uk/Fusion) with a cleaned up and much safer syntax for observables.

One of Dec's core features is its unique Virtual Instance reconciler, similar to [React's Virtual DOM](https://react.dev), which makes Dec a truly declarative UI framework while providing first class support and familiar syntax that you would expect from standalone Roblox UI development. Like Fusion, Dec uses observables to reconcile components and instance properties only exactly when and where it is needed, leading to great performance gains over [Roact](https://roblox.github.io/roact). Dec also has built-in support for object pooling, animation, and more with a very simple and familiar syntax.


## Project Progress
- [X] API, concepts, and types defined
- [X] Basic Public API Skeleton Structure
- [X] Reconciler API Skeleton Structure
- [ ] CI Workflows (In Progress)
- [X] VirtualInstance API Implementation
- [X] State and Observables API Implementation
- [X] Reconciler Full Implementation
- [ ] First Stable Release (In Progress)
- [ ] Full Fusion and Roact interop (In Progress)
- [ ] Unit Test Skeleton Structure
- [ ] Complete Code Coverage of Most Modules
- [ ] Documentation Site using Moonwave
- [ ] Add usage guides to docs site
- [ ] Create a simple Todo List Demo (In Progress)
- [ ] Create a simple open-source demo game using Dec?
- [ ] Create a simple open-source demo plugin using Dec?
- [ ] Video tutorials?
- [ ] Marketing, making a cool logo, etc.

## Contributing

To contribute to Dec's development, you may fork this repository.

Dec uses the following toolchain for library development:
- [aftman](https://github.com/LPGhatguy/aftman)
    - Run `aftman install` in the root directory
    - Run `wally install` to install Dec's dev dependencies (i.e. testez)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Luau LSP VS Code Extension](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp), which should be configured to include the testez declaration file.
![](https://i.imgur.com/x9LjJDy.png)
- [Selene VS Code extension](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.selene-vscode)

Dec uses unit testing to validate code quality. Because Roblox Studio tests
cannot currently be fully automated, unit tests must be run manually before
changes can be merged into the main branch. To perform this process:
- Sync the build via `rojo build --output Dec.rbxlx`
- Open the build in Roblox Studio, and run the command line script located in `game.ServerScriptStorage.TestRunner`
- Copy the "proof checksum" generated in Studio's output and replace the contents `proof_of_testing.txt` with this checksum, then commit this directly to the branch.
- Github will automatically start an action which compares the source code with the proof checksum. If it matches, and the unit tests were all successful, the current branch will be marked as safe to merge.