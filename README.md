# wl-clip-nim

Nim bindings for Wayland clipboard access using Rust FFI.

## Features

- **Text clipboard**: Copy/paste text with proper UTF-8 handling
- **Image clipboard**: Copy/paste images (PNG, JPEG, GIF, WebP, AVIF, JXL, BMP, TIFF)
- **File clipboard**: Copy files via `text/uri-list`
- Uses static libraries from Rust - pre-compiled and snappy-compressed for x86_64 and aarch64

## Requirements

- **Nim** 2.0+
- **Wayland compositor**
- **Linux** only (or cross-compilation to Linux)

## Credits

Built on top of [wl-clipboard-rs](https://github.com/YaLTeR/wl-clipboard-rs) by YaLTeR.

## Installation

```bash
nimble install https://github.com/jiiihpeeh/wl-clip-nim
```

Or for development:

```bash
git clone https://github.com/jiiihpeeh/wl-clip-nim
cd wl-clip-nim
nimble develop
```

## Building & Running

### Using nimble tasks (recommended)

```bash
nimble example   # Run the example (auto-decompresses library if needed)
nimble test      # Run tests (auto-decompresses library if needed)
```

### Building Rust from source

Requires Rust toolchain (`cargo`). This rebuilds and recompresses the library:

```bash
nimble buildRust   # Build Rust via cargo, copy .a, compress to .gz
nimble example
```

### Manual compilation

```bash
# Libraries are compressed (.sz) to save space - auto-decompressed on first run if needed
nim c -r --path:src example/example.nim
```

## Usage

```nim
import wlclip

# Copy text to clipboard
wlclip.setText("Hello from Nim!")

# Read text from clipboard
let text = wlclip.getText()
echo "Clipboard: ", text

# Copy image (auto-detects MIME type)
wlclip.setImage(pngData)

# Read image (returns raw bytes)
let imgData = wlclip.getImage()

# Copy files
wlclip.setFiles(@["/path/to/file1", "/path/to/file2"])
let files = wlclip.getFiles()

# Foreground mode (wait for compositor)
wlclip.setForeground(true)
```

## Architecture

The Rust source code is in `src/rust/src/lib.rs`. It wraps the [wl-clipboard-rs](https://github.com/YaLTeR/wl-clipboard-rs) library.

The Nim code directly links against the static library via FFI:
- `src/rust/libs/x86_64-unknown-linux-gnu/libwlclip.a.sz` - for amd64
- `src/rust/libs/aarch64-unknown-linux-gnu/libwlclip.a.sz` - for arm64

Libraries are compressed to save space. The `nimble buildRust` task builds from source and recompresses. Other nimble tasks auto-decompress if the uncompressed library is missing.

## Cross-compilation

Compile from non-Linux with:
```bash
nim c -d:linuxForCross --cpu:amd64 --path:src example/example.nim
```

## Documentation

API documentation: https://jiiihpeeh.github.io/wl-clip-nim/docs/

To regenerate docs locally:
```bash
 nimble docGen   # Generates docs in ./docs/
```

## License

MIT License
