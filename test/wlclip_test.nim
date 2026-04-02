import wlclip, unittest, std/[os, tempfiles, base64]

suite "wlclip tests":
  
  test "setForeground does not raise":
    setForeground(true)
    setForeground(false)
  
  test "setText and getText roundtrip":
    let testText = "Hello from wlclip test!"
    setText(testText)
    let result = getText()
    check result == testText
  
  test "setText handles empty string":
    setText("")
    let result = getText()
    check result == ""
  
  test "setText handles unicode":
    let testText = "Hello 世界 🦊"
    setText(testText)
    let result = getText()
    check result == testText
  
  test "setText handles multiline":
    let testText = "line1\nline2\nline3"
    setText(testText)
    let result = getText()
    check result == testText
  
  test "setText handles special chars":
    let testText = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
    setText(testText)
    let result = getText()
    check result == testText
  
  test "setFiles and getFiles roundtrip":
    let (cfile, tmpFile) = createTempFile("wlclip_test", ".txt")
    defer: removeFile(tmpFile)
    close(cfile)
    setFiles(@[tmpFile])
    let result = getFiles()
    check result.len == 1
    check result[0] == tmpFile
  
  test "setImage and getImage roundtrip":
    let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8DwH2KpfhSAYf4HwAAtQMDRTCRqQAAAABJRU5ErkJggg=="
    let pngBytes = cast[seq[byte]](decode(pngBase64))
    setImage(pngBytes)
    let result = getImage()
    check result == pngBytes
