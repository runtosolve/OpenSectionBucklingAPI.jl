# OpenSectionBucklingAPI

This repository contains the OpenSectionBucklingAPI, which provides an interface for analyzing the buckling behavior of open sections in structural engineering.

## Getting Started

### 1. Set Up the Company Julia Registry

Most dependencies of this package live in the [RunToSolve Julia Registry](https://github.com/runtosolve/RunToSolveJuliaRegistry). Add it once per machine using [LocalRegistry.jl](https://github.com/GunnarFarneback/LocalRegistry.jl):

```julia
using Pkg
Pkg.add("LocalRegistry")

using LocalRegistry
LocalRegistry.add_registry("https://github.com/runtosolve/RunToSolveJuliaRegistry")
```

Confirm it was added:

```julia
Pkg.Registry.status()   # should list RunToSolveJuliaRegistry alongside General
```

After adding the registry you can install and use this package normally:

```julia
Pkg.add("OpenSectionBucklingAPI")
```

### 2. Clone and Activate Locally (for development)

```bash
git clone https://github.com/runtosolve/OpenSectionBucklingAPI.jl
cd OpenSectionBucklingAPI.jl
```

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()   # resolves all dependencies, including those from the company registry
```

---

## Releasing a New Version

Follow these steps to bump the version and register it in the company registry.

### Step 1 — Bump the version in `Project.toml`

Edit `version` in `Project.toml` following [SemVer](https://semver.org/):

```toml
version = "0.2.3"   # was 0.2.2
```

Commit and push the change:

```bash
git add Project.toml
git commit -m "bump version to 0.2.3"
git push
```

### Step 2 — Tag the release on GitHub (optional but recommended)

A git tag is not required by LocalRegistry, but it is good practice for tracking releases. Create a tag that matches the new version and push it:

```bash
git tag v0.2.3
git push origin v0.2.3
```

Or create a GitHub Release through the web UI — both approaches work.

### Step 3 — Register the new version in the company registry

From a Julia session inside the package directory (environment activated):

```julia
using LocalRegistry
register()
```

`LocalRegistry.register` will:
1. Read the new version from `Project.toml`.
2. Resolve the git tree hash for the tagged commit.
3. Write/update the package entry in the registry.
4. Commit the change to the local registry clone and push it automatically.

### Step 4 — Update the package in a dependent project

In the project that depends on `OpenSectionBucklingAPI`, update the registry and then pull the new version:

```julia
using Pkg
Pkg.Registry.update()
Pkg.update("OpenSectionBucklingAPI")
```

To pin a specific version instead of taking the latest:

```julia
Pkg.add(name="OpenSectionBucklingAPI", version="0.2.3")
```

**Optional — verify the registration worked:**

```julia
Pkg.Registry.update()
Pkg.status("OpenSectionBucklingAPI")   # should show the new version as available
```
