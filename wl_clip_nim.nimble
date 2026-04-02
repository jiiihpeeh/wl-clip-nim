# Package
version = "0.1.0"
author = "jiiihpeeh"
description = "Wayland clipboard access via Rust FFI"
license = "MIT"
srcDir = "src"
skipFiles = @["wlclip.nim"]

requires "nim >= 2.0"
requires "https://github.com/guzba/supersnappy"

import std/[os, strutils]

task(buildRust, "Build Rust library"):
  let isLinux = gorgeEx("uname -s").output.strip == "Linux"
  if not isLinux:
    quit("This package only supports Linux")
  
  let rustDir = thisDir() / "src" / "rust"
  let compressBin = thisDir() / "build-tools" / "compress"
  let decompressBin = thisDir() / "build-tools" / "decompress"
  let targets = @["x86_64-unknown-linux-gnu", "aarch64-unknown-linux-gnu"]

  if not fileExists(decompressBin):
    echo "Compiling decompress..."
    exec("nim c -d:release -o:" & decompressBin & " " & thisDir() & "/build-tools/decompress.nim")
    try:
      exec("strip " & decompressBin)
    except:
      echo "Warning: strip failed, continuing without stripping"

  if not fileExists(compressBin):
    echo "Compiling compress..."
    exec("nim c -d:release -o:" & compressBin & " " & thisDir() & "/build-tools/compress.nim")
    try:
      exec("strip " & compressBin)
    except:
      echo "Warning: strip failed, continuing without stripping"

  for target in targets:
    let libsDir = rustDir / "libs" / target
    let compressedLib = libsDir / "libwlclip.a.sz"
    let finalLib = libsDir / "libwlclip.a"

    if not fileExists(libsDir):
      exec("mkdir -p " & libsDir)

    echo "Building Rust library from source for target: ", target
    let cargoCmd = "cd " & rustDir & " && cargo build --release --target " & target
    try:
      exec(cargoCmd)
      echo "Rust library built successfully"
    except:
      echo "Warning: Failed to build for ", target, ", skipping..."

    let builtLib = rustDir / "target" / target / "release" / "libwlclip.a"
    if fileExists(builtLib):
      exec("cp " & builtLib & " " & finalLib)
      echo "Library copied to: ", finalLib
      echo "Compressing to: ", compressedLib
      exec(compressBin & " " & finalLib & " " & compressedLib)
      echo "Library compressed successfully"

  echo "Rust build task complete."

proc ensureLib*() =
  let libsDir = thisDir() / "src" / "rust" / "libs"
  let decompressBin = thisDir() / "build-tools" / "decompress"
  let compressBin = thisDir() / "build-tools" / "compress"
  let targets = @["x86_64-unknown-linux-gnu", "aarch64-unknown-linux-gnu"]

  if not fileExists(decompressBin):
    echo "Compiling decompress..."
    exec("nim c -d:release -o:" & decompressBin & " " & thisDir() & "/build-tools/decompress.nim")
    try:
      exec("strip " & decompressBin)
    except:
      echo "Warning: strip failed, continuing without stripping"

  if not fileExists(compressBin):
    echo "Compiling compress..."
    exec("nim c -d:release -o:" & compressBin & " " & thisDir() & "/build-tools/compress.nim")
    try:
      exec("strip " & compressBin)
    except:
      echo "Warning: strip failed, continuing without stripping"

  for target in targets:
    let compressedLib = libsDir / target / "libwlclip.a.sz"
    let finalLib = libsDir / target / "libwlclip.a"
    if not fileExists(finalLib) and fileExists(compressedLib):
      echo "Decompressing Rust library from: ", compressedLib
      exec(decompressBin & " " & compressedLib & " " & finalLib)
      echo "Library decompressed to: ", finalLib
    elif not fileExists(compressedLib) and not fileExists(finalLib):
      quit("Rust library not found: " & compressedLib)

task(test, "Run tests"):
  ensureLib()
  exec("nim c -r --path:src test/wlclip_test.nim")

task(example, "Run example"):
  ensureLib()
  exec("nim c -r --path:src example/example.nim")

task(docGen, "Generate documentation"):
  exec("nim doc src/wlclip.nim")
  exec("mkdir -p docs")
  exec("mv src/htmldocs/* docs/")

before develop:
  ensureLib()

before install:
  ensureLib()
