## High-level Nim API for wlclip
## Uses pre-built static libraries from Rust
## Only supports Linux (or cross-compilation to Linux via -d:linuxForCross)

when not defined(linux) and not defined(linuxForCross):
  {.fatal: "wlclip only supports Linux".}

import std/[json, os]

const thisDir = currentSourcePath().parentDir()

when defined(amd64):
  const libDir = thisDir / "rust/libs/x86_64-unknown-linux-gnu"
elif defined(arm64):
  const libDir = thisDir / "rust/libs/aarch64-unknown-linux-gnu"
else:
  const libDir = thisDir / "rust/libs/x86_64-unknown-linux-gnu"

const libWlClip = libDir / "libwlclip.a"
const includeDir = thisDir

{.passL: libWlClip.}
{.passC: "-I" & includeDir.}
{.emit: "#include \"wlclip.h\"".}

type
  WlClipString* {.importc.} = object
    `ptr`*: cstring
    len*: csize_t
    error*: cstring

  WlClipBytes* {.importc.} = object
    `ptr`*: ptr uint8
    len*: csize_t
    error*: cstring

  WlClipInt* {.importc.} = object
    value*: cint
    error*: cstring

proc wlclip_set_foreground(val: char) {.importc.}
proc wlclip_get_text(): WlClipString {.importc.}
proc wlclip_set_text(text: cstring): WlClipInt {.importc.}
proc wlclip_get_image(): WlClipBytes {.importc.}
proc wlclip_set_image_type(imageData: ptr uint8, len: csize_t, mimeType: cstring): WlClipInt {.importc.}
proc wlclip_get_files(): WlClipString {.importc.}
proc wlclip_set_files(json: cstring): WlClipInt {.importc.}
proc wlclip_free_string(`ptr`: cstring) {.importc.}
proc wlclip_free_bytes(`ptr`: ptr uint8, len: csize_t) {.importc.}

proc setFiles*(files: seq[string]) =
  let json = $(%*files)
  let res = wlclip_set_files(json.cstring)
  if res.error != nil:
    raise newException(ValueError, $res.error)

proc setForeground*(blocking: bool) =
  wlclip_set_foreground(if blocking: char(1) else: char(0))

proc getText*(): string =
  let res = wlclip_get_text()
  defer: wlclip_free_string(res.ptr)
  if res.error != nil:
    raise newException(ValueError, $res.error)
  if res.ptr == nil:
    raise newException(ValueError, "clipboard is empty")
  result = $res.ptr

proc setText*(text: string) =
  let res = wlclip_set_text(text.cstring)
  if res.error != nil:
    raise newException(ValueError, $res.error)

proc detectImageMime*(data: openArray[byte]): string =
  if data.len < 4:
    raise newException(ValueError, "Data too short for magic detection")
  
  let d = cast[ptr UncheckedArray[uint8]](unsafeAddr data[0])
  
  if data.len >= 8 and d[0] == 0x89 and d[1] == 0x50 and d[2] == 0x4E and d[3] == 0x47 and d[4] == 0x0D and d[5] == 0x0A and d[6] == 0x1A and d[7] == 0x0A:
    return "image/png"
  if d[0] == 0xFF and d[1] == 0xD8 and d[2] == 0xFF:
    return "image/jpeg"
  if d[0] == 0x47 and d[1] == 0x49 and d[2] == 0x46 and d[3] == 0x38 and (d[4] == 0x39 or d[4] == 0x37) and d[5] == 0x61:
    return "image/gif"
  if d[0] == 0x42 and d[1] == 0x4D:
    return "image/bmp"
  if data.len >= 4 and ((d[0] == 0x49 and d[1] == 0x49 and d[2] == 0x2A and d[3] == 0x00) or (d[0] == 0x4D and d[1] == 0x4D and d[2] == 0x00 and d[3] == 0x2A)):
    return "image/tiff"
  if data.len >= 12 and d[0] == 0x52 and d[1] == 0x49 and d[2] == 0x46 and d[3] == 0x46 and d[8] == 0x57 and d[9] == 0x45 and d[10] == 0x42 and d[11] == 0x50:
    return "image/webp"
  if data.len >= 12 and d[4] == 0x66 and d[5] == 0x74 and d[6] == 0x79 and d[7] == 0x70 and ((d[8] == 0x61 and d[9] == 0x76 and d[10] == 0x69 and d[11] == 0x66) or (d[8] == 0x61 and d[9] == 0x76 and d[10] == 0x69 and d[11] == 0x73)):
    return "image/avif"
  if data.len >= 12 and d[4] == 0x4A and d[5] == 0x58 and d[6] == 0x4C and d[7] == 0x20:
    return "image/jxl"
  if data.len >= 2 and d[0] == 0xFF and d[1] == 0x0A:
    return "image/jxl"
  
  raise newException(ValueError, "Unsupported image format")

proc getImage*(): seq[byte] =
  let res = wlclip_get_image()
  defer: wlclip_free_bytes(res.ptr, res.len)
  if res.error != nil:
    raise newException(ValueError, $res.error)
  if res.ptr == nil or res.len == 0:
    raise newException(ValueError, "clipboard is empty or contains no image")
  result = @[]
  let slice = cast[ptr UncheckedArray[uint8]](res.ptr)
  for i in 0 ..< res.len:
    result.add(slice[i])

proc setImage*(imageData: openArray[byte]) =
  let mime = detectImageMime(imageData)
  let dataPtr = if imageData.len > 0: unsafeAddr(imageData[0]) else: nil
  let res = wlclip_set_image_type(cast[ptr uint8](dataPtr), imageData.len.csize_t, mime.cstring)
  if res.error != nil:
    raise newException(ValueError, $res.error)

proc getFiles*(): seq[string] =
  let res = wlclip_get_files()
  defer: wlclip_free_string(res.ptr)
  if res.error != nil:
    raise newException(ValueError, $res.error)
  if res.ptr == nil:
    raise newException(ValueError, "clipboard is empty or contains no files")
  let jsonStr = $res.ptr
  let parsed = parseJson(jsonStr)
  result = @[]
  for item in parsed:
    result.add(item.str)
