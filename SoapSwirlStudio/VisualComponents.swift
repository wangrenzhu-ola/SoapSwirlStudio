import SwiftUI

struct SoapLoafPreview: View {
    let style: SoapSwirlStyleParams
    let compact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: style.baseColorHex), Color(hex: style.accentColorHex).opacity(0.62)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: compact ? 116 : 170)
                    .overlay(SwirlRibbon(color: Color(hex: style.accentColorHex), intensity: style.swirlIntensity).padding(18))
                    .shadow(color: Color(hex: style.accentColorHex).opacity(0.25), radius: 18, y: 12)

                Text("Handmade soap loaf")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(14)
            }
            .accessibilityLabel("Handmade soap loaf preview for \(style.scentMood)")

            HStack(spacing: 12) {
                CutFacePreview(style: style)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Swirl path")
                        .font(.headline)
                    Text(style.pourStyle)
                        .foregroundStyle(.secondary)
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
            Circle()
                .trim(from: 0.12, to: 0.92)
                .stroke(Color(hex: style.accentColorHex), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(style.swirlIntensity * 210))
                .padding(18)
            Circle()
                .fill(Color.white.opacity(0.36))
                .frame(width: 20, height: 20)
                .offset(x: 13, y: -10)
        }
        .frame(width: 94, height: 94)
        .overlay(alignment: .bottom) {
            Text("Cut-face")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
                .offset(y: 10)
        }
        .accessibilityLabel("Cut-face preview slot")
    }
}

struct SwirlRibbon: View {
    let color: Color
    let intensity: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 6) / 6
                var path = Path()
                let height = size.height
                let width = size.width
                path.move(to: CGPoint(x: 0, y: height * (0.35 + 0.12 * sin(phase))))
                for x in stride(from: 0.0, through: width, by: 12) {
                    let y = height * (0.46 + sin((x / width * .pi * 3.5) + phase * .pi * 2) * (0.10 + intensity * 0.14))
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                context.stroke(path, with: .color(color.opacity(0.82)), style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
