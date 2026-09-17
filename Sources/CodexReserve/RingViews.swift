import SwiftUI

/// Apple Watch palette shared by popover rings + legend dots.
extension Color {
    /// Royal blue = weekly.
    static var codexBlue: Color { Color(red: 65 / 255, green: 105 / 255, blue: 225 / 255) }
}

/// One ring, drawn as a finely sampled polyline in a Canvas.
/// No trim tricks, no arc-angle conventions, no seam blobs: the points are
/// computed directly in canvas coordinates (x right, y DOWN), starting at the
/// top and sweeping screen-clockwise. Full circles are closed polylines with
/// round joins, so the joint is invisible; partial arcs use round caps.
struct Ring: View {
    var fraction: Double? // 0...1 remaining
    var color: Color
    var lineWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - lineWidth / 2
            guard radius > 0 else { return }
            context.stroke(Self.path(center: center, radius: radius, fraction: 1, closed: true),
                           with: .color(.gray.opacity(0.25)),
                           style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            let f = min(1, max(0, fraction ?? 0))
            guard f > 0.001 else { return }
            let style = StrokeStyle(lineWidth: lineWidth,
                                    lineCap: f >= 0.999 ? .butt : .round,
                                    lineJoin: .round)
            context.stroke(Self.path(center: center, radius: radius, fraction: f, closed: f >= 0.999),
                           with: .color(color), style: style)
        }
    }

    /// Points from the top (12 o'clock), sweeping screen-clockwise.
    /// t=0 → north, t=π/2 → east, t=π → south, t=3π/2 → west.
    static func ringPoints(center: CGPoint, radius: CGFloat, fraction: Double) -> [CGPoint] {
        let steps = max(2, Int(ceil(160 * fraction)))
        return (0...steps).map { i in
            let t = 2 * .pi * fraction * Double(i) / Double(steps)
            return CGPoint(x: center.x + radius * sin(t),
                           y: center.y - radius * cos(t))
        }
    }

    static func path(center: CGPoint, radius: CGFloat, fraction: Double, closed: Bool) -> Path {
        var path = Path()
        var pts = ringPoints(center: center, radius: radius, fraction: fraction)
        if closed, let first = pts.first { pts.append(first) }
        guard let first = pts.first else { return path }
        path.move(to: first)
        for pt in pts.dropFirst() { path.addLine(to: pt) }
        return path
    }
}

/// Double ring: outer = weekly (royal blue), inner = 5-hour (Watch green).
/// Solo mode when only one window exists (e.g. Pro has no 5-hour window):
/// a single centered ring in that window's color.
struct DoubleRingView: View {
    var weekly: Double?   // 0...100 remaining
    var fiveHour: Double?
    var size: CGFloat = 120

    var body: some View {
        Group {
            if fiveHour == nil, let weekly {
                Ring(fraction: weekly / 100, color: .codexBlue, lineWidth: size * 0.085)
            } else if weekly == nil, let fiveHour {
                Ring(fraction: fiveHour / 100, color: .green, lineWidth: size * 0.085)
            } else {
                ZStack {
                    Ring(fraction: (weekly ?? 0) / 100,
                         color: weekly == nil ? .gray : .codexBlue,
                         lineWidth: size * 0.085)
                        .frame(width: size, height: size)
                    Ring(fraction: (fiveHour ?? 0) / 100,
                         color: fiveHour == nil ? .gray : .green,
                         lineWidth: size * 0.085)
                        .frame(width: size * 0.70, height: size * 0.70)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

