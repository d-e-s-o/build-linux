build-linux
===========

Build a Linux kernel from source with caching support.

We provide no backwards compatibility guarantees short of not clobbering
`git` commit history. Be sure to pin the snapshot you consume.

Usage
-----

```yaml
- uses: d-e-s-o/build-linux@<ref>
  with:
    config: <path-to-config>
```
