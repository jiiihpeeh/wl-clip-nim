import std/os, supersnappy

proc compressSnappyFile(inputPath, outputPath: string) =
  let data = readFile(inputPath)
  let compressed = compress(data)
  writeFile(outputPath, compressed)

when isMainModule:
  if paramCount() == 2:
    compressSnappyFile(paramStr(1), paramStr(2))
  else:
    quit("Usage: gzipfile <input> <output>")
