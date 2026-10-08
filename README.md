# ooglyph: Sovereign Glyph Search & Iconography Viewer

<div align="center">

```
================================================================================
                                ooglyph
          Sovereign openOODA Glyph Search & Iconography Viewer
================================================================================
```

**Sovereign Glyph Search & Iconography Viewer**  
*Interactive glyph search and viewer for Nerd Font symbols and Unicode iconography.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/ooglyph/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S ooglyph-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/ooglyph/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/ooglyph/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
ooglyph-uninstall
# or: curl -fsSL https://openooda-tools.github.io/ooglyph/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: ooglyph [options] [<search_term>]

Interactive glyph search and viewer for Nerd Font symbols and Unicode iconography.

Options:
  -h, --help               display this help and exit
  -v, --version            output version information and exit
  -c, --category <NAME>    filter glyphs by category (developer, ui, status, box, circadian)
  -u, --codepoint <HEX>    lookup glyph by exact codepoint (e.g. U+E7A8, 0x2714)
      --categories         list all taxonomy categories and item counts
  -1, --char-only          output only the raw symbol character of first match
  -j, --json               output structured JSON metrics
  -D, --demo               interactive multi-category glyph showcase
      --no-color           suppress ANSI color escape sequences
      --test               execute internal multi-tier verification suite
      --mcp                run as Model Context Protocol stdio server
```

---

## 3. Theming Integration (`oote`)

`ooglyph` synchronizes visual styles and badge colors with [oote](https://github.com/openOODA-tools/oote):
* **Configuration:** Reads active palette from `~/.openooda/theme.oot`.
* **Environment Overrides:** Respects `$OODA_THEME` and suppresses color under `$NO_COLOR` or `--no-color`.

---

## 4. Model Context Protocol (MCP)

When invoked with `--mcp`, `ooglyph` runs a JSON-RPC 2.0 stdio server providing 5 tools for AI coding agents:

1. `glyph_search`: Search glyph database by keyword, tag, or symbol name.
2. `glyph_lookup`: Lookup a glyph by exact character or Unicode codepoint (`U+XXXX`).
3. `glyph_categories`: List available symbol categories and icon counts.
4. `glyph_table`: Generate a formatted table for a specific symbol category.
5. `glyph_demo`: Run interactive showcase of curated icon sets.

```bash
ooglyph --mcp
```

---

## 5. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`, `&McpCap`). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 6. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
