// Renders the KeyLock app icon at 1024pt: dark squircle, bold mint→teal ring,
// keyboard glyph. Run via build-icon.sh, which packs it into icon.icns.
import AppKit

let canvas: CGFloat = 1024
let image = NSImage(size: NSSize(width: canvas, height: canvas))
image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("no context") }

// Full-bleed squircle (this artwork uses no canvas margin)
let rect = CGRect(x: 0, y: 0, width: canvas, height: canvas)
let squircle = NSBezierPath(roundedRect: rect, xRadius: 230, yRadius: 230)

// Background: near-black, slightly lifted at the top
let bg = NSGradient(colors: [
    NSColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1),
    NSColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1),
])!
bg.draw(in: squircle, angle: -90)
squircle.addClip()

// Bold ring: mint at top → teal at bottom, drawn as a stroked circle
// clipped through a vertical gradient.
let center = CGPoint(x: canvas / 2, y: canvas / 2)
let ringRadius: CGFloat = 400
let ringWidth: CGFloat = 118

ctx.saveGState()
let ringPath = CGMutablePath()
ringPath.addArc(center: center, radius: ringRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
ctx.addPath(ringPath.copy(strokingWithWidth: ringWidth, lineCap: .round, lineJoin: .round, miterLimit: 10))
ctx.clip()
let ringColors = [
    NSColor(red: 0.63, green: 0.96, blue: 0.79, alpha: 1).cgColor, // mint (top)
    NSColor(red: 0.16, green: 0.84, blue: 0.76, alpha: 1).cgColor, // teal (bottom)
] as CFArray
let ringGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: ringColors, locations: [0, 1])!
ctx.drawLinearGradient(
    ringGrad,
    start: CGPoint(x: canvas / 2, y: canvas),
    end: CGPoint(x: canvas / 2, y: 0),
    options: []
)
ctx.restoreGState()

// Keyboard glyph, bright teal, centered and large
let teal = NSColor(red: 0.31, green: 0.90, blue: 0.79, alpha: 1)
let config = NSImage.SymbolConfiguration(pointSize: 460, weight: .medium)
if let symbol = NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let tinted = NSImage(size: symbol.size)
    tinted.lockFocus()
    symbol.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 1)
    teal.set()
    NSRect(origin: .zero, size: symbol.size).fill(using: .sourceAtop)
    tinted.unlockFocus()

    let glyphWidth: CGFloat = 360
    let scale = glyphWidth / tinted.size.width
    let glyphSize = NSSize(width: glyphWidth, height: tinted.size.height * scale)
    tinted.draw(
        in: NSRect(
            x: center.x - glyphSize.width / 2,
            y: center.y - glyphSize.height / 2,
            width: glyphSize.width, height: glyphSize.height
        ),
        from: .zero, operation: .sourceOver, fraction: 1
    )
}

image.unlockFocus()

// Write 1024px PNG
guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { fatalError("encode failed") }
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
