build-linux
===========

Build a Linux kernel from source with caching support.

We provide no backwards compatibility guarantees short of not clobbering
`git` commit history. Be sure to pin the snapshot you consume.

Usage
-----

```yaml
- uses: actions/checkout@v7
- uses: d-e-s-o/build-linux@<ref>
  id: build
  with:
    config: <path-to-config>
- run: ls "${{ steps.build.outputs.build-dir }}"
```

The action does not check out the consuming repository. Do that
beforehand, as `config` and `patches` are interpreted relative to the
workspace.

The build happens on the runner itself, using `apt-get` to install the
handful of tools that may be required. An `x86_64` Ubuntu runner is
assumed. Kernels are built with Clang, which cross compiles to any of
its backends without an additional toolchain, so `arch` may name a
target other than the runner's own.

Inputs
------

- `config` (required): path to the kernel configuration to use. It is
  applied on top of `allnoconfig`, so any option not mentioned in it
  ends up disabled.
- `arch`: the architecture to build for, spelled the way the kernel
  build system spells it. Supported values are `x86` and `arm64`.
  Defaults to `x86`.
- `kernel-repo`: the Linux kernel repository to build. Defaults to
  `torvalds/linux`.
- `rev`: the revision to build at. Defaults to the default branch's
  `HEAD`. Pin it if you want reproducible runs that share caches.
- `patches`: newline separated list of paths or glob patterns for
  patches to apply on top of the checked out kernel source. Patches are
  applied with `git am`.
- `vmlinux`: whether to include `vmlinux` in the artifacts. Defaults to
  `false`.
- `modules`: whether to include kernel modules in the artifacts.
  Defaults to `false`.

Outputs
-------

- `build-dir`: path to the directory containing the built kernel.
- `kernel-image`: path to the bootable kernel image, inside
  `build-dir`.

The directory always contains the kernel image that `kernel-image`
points at (`bzImage` on `x86`, `Image` on `arm64`). With `vmlinux`
enabled it also contains a `boot/` directory with what `make install`
places there (`vmlinuz-<release>`, `System.map-<release>`) next to the
uncompressed `vmlinux-<release>`. Note that on `arm64` the installed
`vmlinuz-<release>` is uncompressed, despite the name. With `modules`
enabled the directory contains `lib/modules/<release>/`.

Caching
-------

The build directory is cached, keyed by the action definition and all
inputs, with `config` and `patches` hashed by content. Caches are
restored on any branch, but only saved on the repository's default
branch. On a cache hit no kernel source is checked out and no build
runs.
