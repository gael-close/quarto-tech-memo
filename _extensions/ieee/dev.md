This is a debug playground for custom Lua filters.
See https://github.com/jgm/pandoc/issues/8988

Type are problematic in Latex IEEE 2-column format.
A workaround is needed. Wrap them and add workaround 
from https://tex.stackexchange.com/a/224096




| Parameter             | Symbol           | Typ | Unit |
| --------------------- | ---------------- | --- | ---- |
| Hall sensitivity      | $S_\mathrm{H}$   | 0.2 | V/T  |
| Effective nr. of bits | $\mathrm{ENOB}$  | 12  | -    |
: Example of engineering table {#tbl-placeholder}

```bash
pandoc dev.md -t latex --lua-filter custom.lua
```