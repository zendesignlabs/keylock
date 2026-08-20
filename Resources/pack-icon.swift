import AppKit
let args = CommandLine.arguments
let src = NSImage(contentsOfFile: args[1])!
let canvas: CGFloat = 1024
// Scale artwork so the squircle matches the standard 824pt icon grid
let target: CGFloat = 824
let scale = target / max(src.size.width, src.size.height)
let w = src.size.width * scale, h = src.size.height * scale
let img = NSImage(size: NSSize(width: canvas, height: canvas))
img.lockFocus()
src.draw(in: NSRect(x: (canvas - w)/2, y: (canvas - h)/2, width: w, height: h),
         from: .zero, operation: .sourceOver, fraction: 1)
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
rep.size = NSSize(width: canvas, height: canvas)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
