# Portway

A native macOS app for running Windows executables via Wine, without the abandoned-project baggage of other GUI wrappers.

## Why

Existing Wine GUIs for macOS are either unmaintained (Whisky, archived since May 2025 with unresolved bottle-management bugs) or paid (CrossOver). Portway is a from-scratch, actively developed alternative built on top of Apple's [Game Porting Toolkit](https://github.com/gcenx/homebrew-wine), which is still maintained.

## Status

Early, functional v1:

- Create and delete isolated Wine "bottles" (separate Windows environments)
- Run any `.exe` inside a chosen bottle
- Browse a bottle's `C:` drive from Finder

Not yet implemented: per-bottle Windows version / DLL overrides, DXVK/GPU tuning, Steam-specific install flows, Rosetta/x86 fallback for unsupported prefixes.

## Requirements

- macOS 14+ (Apple Silicon)
- [Game Porting Toolkit](https://github.com/gcenx/homebrew-wine): `brew tap gcenx/wine && brew install --cask gcenx/wine/game-porting-toolkit`

## Building

```sh
swift build
swift run
```

## License

MIT
