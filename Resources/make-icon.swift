// Renders the KeyLock app icon at 1024pt using the app's own visual language:
// dark squircle, teal glow, gradient ring, keyboard glyph.
// Run via build-icon.sh, which downsizes and packs it into icon.icns.
import AppKit

let canvas: CGFloat = 1024
let image = NSImage(size: NSSize(width: canvas, height: canvas))
image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("no context") }

// macOS icon grid: 824pt squircle centered on a 1024pt transparent canvas
let inset: CGFloat = 100
let rect = CGRect(x: inset, y: inset, width: canvas - inset * 2, height: canvas - inset * 2)
let squircle = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)

// Background: near-black with a slight vertical lift, matching the window
let bg = NSGradient(colors: [
    NSColor(red: 0.11, green: 0.12, blue: 0.15, alpha: 1),
    NSColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1),
])!
bg.draw(in: squircle, angle: -90)

// Teal radial glow behind the ring
squircle.addClip()
let glowColors = [
    NSColor(red: 0.19, green: 0.84, blue: 0.78, alpha: 0.35).cgColor,
    NSColor.clear.cgColor,
] as CFArray
let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glowColors, locations: [0, 1])!
ctx.drawRadialGradient(
    glow,
    startCenter: CGPoint(x: canvas / 2, y: canvas / 2), startRadius: 0,
    endCenter: CGPoint(x: canvas / 2, y: canvas / 2), endRadius: 430,
    options: []
)

// Ring: teal→mint gradient stroked along a circle, drawn as many short arcs
let center = CGPoint(x: canvas / 2, y: canvas / 2)
let ringRadius: CGFloat = 265
let ringWidth: CGFloat = 40
let teal = NSColor(red: 0.19, green: 0.84, blue: 0.78, alpha: 1)
let mint = NSColor(red: 0.55, green: 0.96, blue: 0.78, alpha: 1)
let steps = 720
for i in 0..<steps {
    let t = CGFloat(i) / CGFloat(steps)
    // blend teal→mint→teal so the gradient wraps seamlessly
    let phase = t < 0.5 ? t * 2 : (1 - t) * 2
    let color = NSColor(
        red: teal.redComponent + (mint.redComponent - teal.redComponent) * phase,
        green: teal.greenComponent + (mint.greenComponent - teal.greenComponent) * phase,
        blue: teal.blueComponent + (mint.blueComponent - teal.blueComponent) * phase,
        alpha: 1
    )
    color.setStroke()
    let a0 = t * 2 * .pi - .pi / 2
    let a1 = (CGFloat(i) + 1.5) / CGFloat(steps) * 2 * .pi - .pi / 2
    let arc = NSBezierPath()
    arc.appendArc(
        withCenter: center, radius: ringRadius,
        startAngle: a0 * 180 / .pi, endAngle: a1 * 180 / .pi
    )
    arc.lineWidth = ringWidth
    arc.lineCapStyle = .round
    arc.stroke()
}

// Inner face: subtle glassy disc, like the button face in the app
let faceRadius: CGFloat = 210
let faceRect = CGRect(x: center.x - faceRadius, y: center.y - faceRadius, width: faceRadius * 2, height: faceRadius * 2)
let face = NSBezierPath(ovalIn: faceRect)
let faceGrad = NSGradient(colors: [
    NSColor(white: 1, alpha: 0.10),
    NSColor(white: 1, alpha: 0.03),
])!
faceGrad.draw(in: face, angle: -90)
NSColor(white: 1, alpha: 0.10).setStroke()
face.lineWidth = 4
face.stroke()

// Keyboard glyph, teal, centered
let config = NSImage.SymbolConfiguration(pointSize: 460, weight: .medium)
if let symbol = NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let tinted = NSImage(size: symbol.size)
    tinted.lockFocus()
    symbol.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 1)
    teal.set()
    NSRect(origin: .zero, size: symbol.size).fill(using: .sourceAtop)
    tinted.unlockFocus()

    let glyphWidth: CGFloat = 250
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
