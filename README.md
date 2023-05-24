# Dec
Dec is a reactive UI library for Roblox.

It combines all of the best features of modern libraries like Roact, Fusion, and more for building reusable, performant, declarative UI components.

## Features

Dec is a **work in progress project** that started from a simple concept of ways to improve upon its predecessor, [Pract](https://github.com/AmberGraceRBLX/Pract), while using the most loved features of Elttob's [Fusion](https://elttob.uk/Fusion) with a cleaned up and much safer syntax for observables.

One of Dec's core features is its unique Virtual Instance reconciler, similar to [React's Virtual DOM](https://react.dev), which makes Dec a truly declarative UI framework while providing first class support and familiar syntax that you would expect from standalone Roblox UI development. Like Fusion, Dec does not enforce a distinct Component types and instead uses Observables to reconcile components and instance properties when and where it is needed. Dec benefits from the same performance gains that Fusion has over [Roact](https://roblox.github.io/roact) while still retaining its VirtualInstance reconciler that allows Dec to have a truly declarative syntax. Dec also has first class support for object pooling, tweening, and more with a very simple and familiar syntax. It also has interoperability with Fusion and Roact for legacy code conversion.



## Project Progress
- [X] API, concepts, and types defined
- [X] Basic Public API Skeleton Structure
- [ ] Reconciler API Skeleton Structure (Currently In Progress)
- [ ] CI Workflows
- [X] VirtualInstance API Implementation
- [ ] State and Observables API Implementation
- [ ] Reconciler Full Implementation
- [ ] Full Fusion and Roact interop
- [ ] Unit Test Skeleton Structure
- [ ] Complete Code Coverage of Most Modules
- [ ] Documentation Site using Moonwave
- [ ] Add usage guides to docs site
- [ ] Create a simple open-source demo game using Dec?
- [ ] Create a simple open-source demo plugin using Dec?
- [ ] Video tutorials?
- [ ] Marketing, making a cool logo, etc.
