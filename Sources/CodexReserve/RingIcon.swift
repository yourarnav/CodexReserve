import AppKit

/// Whole menu-bar strip drawn by hand: `weekly%W  ⭕(single green 5h ring)  5h%`.
/// A status button only supports text on ONE side of its image, so everything
/// is composed into a single image. Pure AppKit — always renders.
enum RingIcon {
    static var numberFont: NSFont { NSFont.systemFont(ofSize: 13, weight: .bold) }
    static var suffixFont: NSFont { NSFont.systemFont(ofSize: 10, weight: .bold) }
    static let barHeight: CGFloat = 22
    static let ringsWidth: CGFloat = 22
    static let gap: CGFloat = 5
    static let pad: CGFloat = 1

    static let fiveHourGreen = NSColor.systemGreen
    static let weeklyBlue = NSColor(srgbRed: 65.0 / 255, green: 105.0 / 255, blue: 225.0 / 255, alpha: 1)

    /// Left label: weekly number + small "W" so it's identifiable at a glance.
    static func leftLabel(weekly: Double?) -> NSAttributedString {
        let s = NSMutableAttributedString(
            string: weekly.map { "\(Int($0.rounded()))%" } ?? "–",
            attributes: [.font: numberFont, .foregroundColor: NSColor.labelColor])
        s.append(NSAttributedString(
            string: "W",
            attributes: [.font: suffixFont, .foregroundColor: NSColor.secondaryLabelColor]))
        return s
    }

    static func rightLabel(fiveHour: Double?) -> NSAttributedString {
        NSAttributedString(
            string: fiveHour.map { "\(Int($0.rounded()))%" } ?? "–",
            attributes: [.font: numberFont, .foregroundColor: NSColor.labelColor])
    }

    static func make(weekly: Double?, fiveHour: Double?) -> NSImage {
        if fiveHour == nil, let weekly {
            return strip(left: leftLabel(weekly: weekly),
                         fraction: weekly / 100,
                         color: weeklyBlue,
                         right: nil)
        }
        if weekly == nil, let fiveHour {
            return strip(left: rightLabel(fiveHour: fiveHour),
                         fraction: fiveHour / 100,
                         color: fiveHourGreen,
                         right: nil)
        }
        return strip(left: leftLabel(weekly: weekly),
                     fraction: fiveHour.map { $0 / 100 },
                     color: fiveHour == nil ? .tertiaryLabelColor : fiveHourGreen,
                     right: rightLabel(fiveHour: fiveHour))
    }

    /// Composes `left [rings] right`. Nil right = solo mode (no trailing dash).
    private static func strip(left: NSAttributedString, fraction: Double?,
                              color: NSColor, right: NSAttributedString?) -> NSImage {
        let leftSize = left.size()
        let rightSize = right?.size() ?? .zero
        let rightBlock = right == nil ? 0 : gap + rightSize.width
        let width = pad + leftSize.width + gap + ringsWidth + rightBlock + pad

        // Flipped context so NSString draws upright.
        let img = NSImage(size: NSSize(width: width, height: barHeight), flipped: true) { rect in
            left.draw(at: NSPoint(x: pad, y: (rect.height - leftSize.height) / 2))
            let cx = pad + leftSize.width + gap + ringsWidth / 2
            let center = NSPoint(x: cx, y: rect.height / 2)
            drawRing(center: center, radius: 8.8, lineWidth: 3.6,
                     fraction: fraction, color: color)
            if let right {
                let rx = pad + leftSize.width + gap + ringsWidth + gap
                right.draw(at: NSPoint(x: rx, y: (rect.height - rightSize.height) / 2))
            }
            return true
        }
        img.isTemplate = false // full color — never render as a faded silhouette
        return img
    }

    /// Flipped coords (+y down): visual top = 270°, visual-clockwise = increasing angle.
    private static func drawRing(center: NSPoint, radius: CGFloat, lineWidth: CGFloat,
                                 fraction: Double?, color: NSColor) {
        NSColor.tertiaryLabelColor.withAlphaComponent(0.55).setStroke()
        let track = NSBezierPath()
        track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
        track.lineWidth = lineWidth
        track.stroke()

        guard let fraction else { return }
        let f = min(1, max(0, fraction))
        color.setStroke()
        let arc = NSBezierPath()
        if f >= 0.999 {
            arc.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
        } else {
            arc.appendArc(withCenter: center, radius: radius,
                          startAngle: 270, endAngle: 270 + 360 * max(f, 0.02),
                          clockwise: false)
        }
        arc.lineWidth = lineWidth
        arc.lineCapStyle = .round
        arc.stroke()
    }
}
