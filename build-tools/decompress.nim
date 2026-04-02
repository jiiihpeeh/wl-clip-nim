import std/os, supersnappy

proc decompressSnappyFile(inputPath, outputPath: string) =
  let data = readFile(inputPath)
  let decompressed = uncompress(data)
  writeFile(outputPath, decompressed)

when isMainModule:
  if paramCount() == 2:
    decompressSnappyFile(paramStr(1), paramStr(2))
  else:
    quit("Usage: gunzip <input> <output>")
