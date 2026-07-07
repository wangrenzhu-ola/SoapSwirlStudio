import SwiftUI

struct SoapLoafPreview: View {
    let style: SoapSwirlStyleParams
    let compact: Bool

    private var pattern: SoapPourPattern { .pattern(for: style.pourStyle) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: style.baseColorHex), Color(hex: style.accentColorHex).opacity(0.62)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: compact ? 116 : 170)
                    .overlay(
                        SwirlPatternPreview(style: style, surface: .loaf)
                            .padding(compact ? 12 : 18)
                    )
                    .shadow(color: Color(hex: style.accentColorHex).opacity(0.25), radius: 18, y: 12)

                Text("Handmade soap loaf")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(14)
            }
            .accessibilityLabel("Handmade soap loaf preview for \(style.scentMood) using \(pattern.accessibilitySummary)")

            HStack(spacing: 12) {
                CutFacePreview(style: style)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Swirl path")
                        .font(.headline)
                    Text(pattern.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SoapTheme.ink)
                    Text(pattern.accessibilitySummary.capitalized)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SoapTheme.clay)
                    Text(style.cutFaceNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
    }
}

struct CutFacePreview: View {
    let style: SoapSwirlStyleParams

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: style.baseColorHex))
            SwirlPatternPreview(style: style, surface: .cutFace)
                .padding(8)
            Circle()
                .fill(Color.white.opacity(0.34))
                .frame(width: 18, height: 18)
                .offset(x: 18, y: -18)
        }
        .frame(width: 104, height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(alignment: .bottom) {
            Text("Cut-face")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
                .offset(y: 10)
        }
        .accessibilityLabel("Cut-face preview showing \(SoapPourPattern.pattern(for: style.pourStyle).accessibilitySummary)")
    }
}

private enum SwirlPreviewSurface {
    case loaf
    case cutFace
}

private struct SwirlPatternPreview: View {
    let style: SoapSwirlStyleParams
    let surface: SwirlPreviewSurface

    private var pattern: SoapPourPattern { .pattern(for: style.pourStyle) }
    private var accent: Color { Color(hex: style.accentColorHex) }
    private var secondaryAccent: Color { Color(hex: style.baseColorHex).opacity(0.74) }

    var body: some View {
        Canvas { context, size in
            switch pattern {
            case .ribbonPour:
                drawRibbonPour(context: &context, size: size)
            case .moonComb:
                drawMoonComb(context: &context, size: size)
            case .dropSwirl:
                drawDropSwirl(context: &context, size: size)
            case .inThePot:
                drawInThePot(context: &context, size: size)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var strength: CGFloat { CGFloat(max(0.15, min(style.swirlIntensity, 0.95))) }
    private var lineWidth: CGFloat { surface == .loaf ? 8 + strength * 14 : 5 + strength * 9 }

    private func drawRibbonPour(context: inout GraphicsContext, size: CGSize) {
        let stripeCount = surface == .loaf ? 3 : 4
        for stripe in 0..<stripeCount {
            var path = Path()
            let yBase = size.height * (0.22 + CGFloat(stripe) * 0.22)
            path.move(to: CGPoint(x: -8, y: yBase))
            for x in stride(from: 0.0, through: size.width + 8, by: 10) {
                let wave = sin((x / max(size.width, 1)) * .pi * (2.0 + Double(stripe)) + Double(stripe))
                let y = yBase + CGFloat(wave) * (10 + strength * 18)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            context.stroke(path, with: .color(accent.opacity(0.82 - Double(stripe) * 0.09)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }

    private func drawMoonComb(context: inout GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width * 0.58, y: size.height * 0.50)
        let arcs = surface == .loaf ? 5 : 4
        for arc in 0..<arcs {
            var path = Path()
            let radius = min(size.width, size.height) * (0.18 + CGFloat(arc) * 0.095 + strength * 0.03)
            path.addArc(center: center, radius: radius, startAngle: .degrees(115), endAngle: .degrees(310), clockwise: false)
            context.stroke(path, with: .color(accent.opacity(0.86 - Double(arc) * 0.08)), style: StrokeStyle(lineWidth: lineWidth * 0.72, lineCap: .round))
        }
        var comb = Path()
        for tooth in 0..<5 {
            let x = size.width * (0.20 + CGFloat(tooth) * 0.13)
            comb.move(to: CGPoint(x: x, y: size.height * 0.18))
            comb.addQuadCurve(to: CGPoint(x: x + size.width * 0.18, y: size.height * 0.82), control: CGPoint(x: x + size.width * 0.05, y: size.height * (0.38 + strength * 0.18)))
        }
        context.stroke(comb, with: .color(secondaryAccent.opacity(0.58)), style: StrokeStyle(lineWidth: max(3, lineWidth * 0.36), lineCap: .round))
    }

    private func drawDropSwirl(context: inout GraphicsContext, size: CGSize) {
        let drops = surface == .loaf ? 10 : 7
        for drop in 0..<drops {
            let column = CGFloat(drop % 5)
            let row = CGFloat(drop / 5)
            let x = size.width * (0.14 + column * 0.18) + CGFloat(drop % 2) * 8
            let y = size.height * (0.24 + row * 0.32) + CGFloat((drop * 17) % 19)
            let radius = (surface == .loaf ? 9 : 7) + strength * CGFloat(12 + (drop % 3) * 3)
            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            var ring = Path(ellipseIn: rect)
            context.stroke(ring, with: .color(accent.opacity(0.80)), style: StrokeStyle(lineWidth: max(3, lineWidth * 0.38), lineCap: .round))
            ring = Path(ellipseIn: rect.insetBy(dx: radius * 0.42, dy: radius * 0.42))
            context.fill(ring, with: .color(accent.opacity(0.35)))
        }
    }

    private func drawInThePot(context: inout GraphicsContext, size: CGSize) {
        let strands = surface == .loaf ? 6 : 5
        for strand in 0..<strands {
            var path = Path()
            let startY = size.height * (0.15 + CGFloat(strand) * 0.14)
            path.move(to: CGPoint(x: -10, y: startY))
            for x in stride(from: 0.0, through: size.width + 12, by: 8) {
                let p = x / max(size.width, 1)
                let marble = sin(Double(p) * .pi * Double(3 + strand % 3) + Double(strand))
                    + cos(Double(p) * .pi * Double(5 + strand % 2)) * 0.45
                let y = startY + CGFloat(marble) * (8 + strength * 24)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            let color = strand.isMultiple(of: 2) ? accent : secondaryAccent
            context.stroke(path, with: .color(color.opacity(0.74)), style: StrokeStyle(lineWidth: lineWidth * (strand.isMultiple(of: 2) ? 0.78 : 0.44), lineCap: .round, lineJoin: .round))
        }
    }
}

struct SoapStatusPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.68), in: Capsule())
            .overlay(Capsule().stroke(Color.black.opacity(0.06)))
    }
}

struct PrivacyNoticeCard: View {
    var openLegalSurface: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Privacy note", systemImage: "lock.shield")
                .font(.headline)
            Text("Your soap swirl sketches are stored locally on this device. Starter examples are local placeholders, not online recipes or a live service.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let openLegalSurface {
                Button {
                    openLegalSurface()
                } label: {
                    Label("Privacy Policy & User Agreement", systemImage: "doc.text.magnifyingglass")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Open Privacy Policy and User Agreement")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
