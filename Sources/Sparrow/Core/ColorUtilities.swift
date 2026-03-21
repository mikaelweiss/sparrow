#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Utilities for parsing colors and computing contrast.
/// Used by the Theme builder to auto-derive foreground colors from backgrounds.
enum ColorUtilities {

    // MARK: - Parsing

    /// Parse a hex color string (#RRGGBB or RRGGBB) to HSL components.
    static func hexToHSL(_ hex: String) -> (h: Double, s: Double, l: Double)? {
        var clean = hex.trimmingCharacters(in: .whitespaces)
        if clean.hasPrefix("#") { clean.removeFirst() }
        guard clean.count == 6, let rgb = UInt32(clean, radix: 16) else { return nil }

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        let l = (maxC + minC) / 2.0

        if delta == 0 {
            return (0, 0, l * 100)
        }

        let s = delta / (1 - abs(2 * l - 1))

        var h: Double
        if maxC == r {
            h = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
        } else if maxC == g {
            h = 60 * ((b - r) / delta + 2)
        } else {
            h = 60 * ((r - g) / delta + 4)
        }
        if h < 0 { h += 360 }

        return (round(h * 10) / 10, round(s * 1000) / 10, round(l * 1000) / 10)
    }

    /// Parse "hsl(H S% L%)" or "hsl(H, S%, L%)" format.
    static func parseHSL(_ value: String) -> (h: Double, s: Double, l: Double)? {
        let stripped = value
            .replacingOccurrences(of: "hsl(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: ",", with: " ")
        let parts = stripped.split(separator: " ", omittingEmptySubsequences: true)
            .compactMap { Double($0) }
        guard parts.count == 3 else { return nil }
        return (parts[0], parts[1], parts[2])
    }

    // MARK: - Contrast

    /// Compute relative luminance from HSL values (s and l in 0-100 range).
    static func relativeLuminance(h: Double, s: Double, l: Double) -> Double {
        let sNorm = s / 100
        let lNorm = l / 100
        let c = (1 - abs(2 * lNorm - 1)) * sNorm
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = lNorm - c / 2

        var r, g, b: Double
        switch h {
        case 0..<60:    (r, g, b) = (c, x, 0)
        case 60..<120:  (r, g, b) = (x, c, 0)
        case 120..<180: (r, g, b) = (0, c, x)
        case 180..<240: (r, g, b) = (0, x, c)
        case 240..<300: (r, g, b) = (x, 0, c)
        default:        (r, g, b) = (c, 0, x)
        }

        r += m; g += m; b += m

        func linearize(_ v: Double) -> Double {
            v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    /// Given HSL components, return a contrasting foreground color string.
    /// Uses WCAG luminance threshold: light backgrounds get dark text, dark backgrounds get light text.
    static func contrastingForeground(h: Double, s: Double, l: Double) -> String {
        let lum = relativeLuminance(h: h, s: s, l: l)
        // Threshold ~0.179 is the midpoint for 4.5:1 contrast ratio
        return lum > 0.179 ? "hsl(240 5.9% 10%)" : "hsl(0 0% 98%)"
    }

    // MARK: - Public API

    /// Convert a hex string to an HSL CSS value. Passes through values that are already HSL.
    static func ensureHSL(_ value: String) -> String {
        if value.hasPrefix("hsl") { return value }
        if let hsl = hexToHSL(value) {
            return "hsl(\(hsl.h) \(hsl.s)% \(hsl.l)%)"
        }
        return value
    }

    /// Given a color (hex or HSL string), return a contrasting foreground color.
    static func autoForeground(for color: String) -> String {
        if let hsl = parseHSL(color) {
            return contrastingForeground(h: hsl.h, s: hsl.s, l: hsl.l)
        }
        if let hsl = hexToHSL(color) {
            return contrastingForeground(h: hsl.h, s: hsl.s, l: hsl.l)
        }
        // Unknown format — default to light text
        return "hsl(0 0% 98%)"
    }
}
