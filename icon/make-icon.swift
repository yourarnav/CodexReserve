import AppKit

// CodexBar app icon: dark Apple-esque squircle, outer royal-blue weekly ring,
// inner green 5-hour ring. Rendered at 1024; downscaled by make-icon.sh.
// Usage: swift icon/make-icon.swift /tmp/CodexBarIcon/icon_1024.png

let size: CGFloat = 1024
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/CodexBarIcon/icon_1024.png"

let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

// Squircle background: clean white (light Apple-esque icon).
let bg = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size),
                      xRadius: 230, yRadius: 230)
let bgGrad = NSGradient(colors: [
    NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1),
    NSColor(srgbRed: 0.93, green: 0.93, blue: 0.95, alpha: 1),
])!
bgGrad.draw(in: bg, angle: 90)

// Rings: start at the top, sweep clockwise (AppKit y-up: decreasing angle).
func ring(radius: CGFloat, width: CGFloat, fraction: CGFloat, color: NSColor) {
    let c = NSPoint(x: size / 2, y: size / 2)
    NSColor.black.withAlphaComponent(0.12).setStroke()
    let track = NSBezierPath()
    track.appendArc(withCenter: c, radius: radius, startAngle: 0, endAngle: 360)
    track.lineWidth = width
    track.stroke()

    color.setStroke()
    let arc = NSBezierPath()
    arc.appendArc(withCenter: c, radius: radius,
                  startAngle: 90, endAngle: 90 - 360 * fraction,
                  clockwise: true)
    arc.lineWidth = width
    arc.lineCapStyle = .round
    arc.stroke()
}

ring(radius: 300, width: 112, fraction: 0.62,
     color: NSColor(srgbRed: 65.0 / 255, green: 105.0 / 255, blue: 225.0 / 255, alpha: 1))
ring(radius: 168, width: 100, fraction: 0.80, color: .systemGreen)

img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fputs("icon render failed\n", stderr)
    exit(1)
}
try png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
