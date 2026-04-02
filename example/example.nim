## Example usage of wlclip

import wlclip, std/base64

# Copy text to clipboard
wlclip.setText("Hello from Nim!")

# Read text from clipboard
try:
  let text = wlclip.getText()
  echo "Clipboard text: ", text
except WlClipError as e:
  echo "Error: ", e.msg

# Copy PNG image to clipboard
let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8DwH2KpfhSAYf4HwAAtQMDRTCRqQAAAABJRU5ErkJggg=="
wlclip.setImage(cast[seq[byte]](decode(pngBase64)))

# Read PNG image from clipboard
try:
  let pngData = wlclip.getImage()
  echo "Clipboard image size: ", pngData.len, " bytes"
except WlClipError as e:
  echo "No image in clipboard: ", e.msg

# Copy files to clipboard
# wlclip.setFiles(@["/path/to/file1", "/path/to/file2"])

# Read files from clipboard
try:
  let files = wlclip.getFiles()
  echo "Clipboard files: ", files
except WlClipError as e:
  echo "No files in clipboard: ", e.msg

# Set foreground mode
wlclip.setForeground(true)
