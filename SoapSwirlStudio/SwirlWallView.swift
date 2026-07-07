import SwiftUI

struct SwirlWallView: View {
    @EnvironmentObject private var store: SoapSwirlStore
    @Binding var path: [SoapRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SwirlWallHero(path: $path)

                if store.records.isEmpty {
                    EmptySwirlWallCard(startAction: startNewSketch)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Swirl Wall")
                            .font(.title2.bold())
                        ForEach(store.records) { record in
                            Button {
                                path.append(.detail(record.id))
                            } label: {
                                SwirlRecordCard(record: record)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open soap swirl sketch named \(record.title)")
                        }
                    }
                }

                StarterExamplesSection()
                PrivacyNoticeCard {
                    path.append(.legalPrivacy)
                }
            }
            .padding(20)
        }
        .soapScreenBackground()
        .navigationTitle("SoapSwirl Studio")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.append(.premium)
                } label: {
                    Label("Premium local packs", systemImage: "sparkles")
                }
                .accessibilityLabel("Open Premium local packs")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: startNewSketch) {
                    Label("New soap swirl sketch", systemImage: "plus")
                }
                .accessibilityLabel("Create a new soap swirl sketch")
            }
        }
    }

    private func startNewSketch() {
        path.append(.scentSetup)
    }
}

private struct SwirlWallHero: View {
    @Binding var path: [SoapRoute]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sketch scent, swirl, and cut-face in one calm pass.")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(SoapTheme.ink)
                    Text("Build a local soap swirl sketch from your own colors, then save it to the Swirl Wall.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                SoapStatusPill(title: "en-US", systemImage: "character.book.closed")
            }

            SoapLoafPreview(style: .defaultPalette, compact: false)

            HStack {
                Button {
                    path.append(.scentSetup)
                } label: {
                    Label("Start Scent Color Setup", systemImage: "paintpalette")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    path.append(.premium)
                } label: {
                    Label("Local Packs", systemImage: "square.stack.3d.up")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color.white.opacity(0.9)))
    }
}

private struct EmptySwirlWallCard: View {
    let startAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("No soap swirl sketches yet", systemImage: "scribble.variable")
                .font(.title3.bold())
            Text("Your first handmade soap loaf, swirl path, and cut-face preview will appear here after you save it.")
                .foregroundStyle(.secondary)
            SoapLoafPreview(style: .defaultPalette, compact: true)
            Button("Create your first soap swirl sketch", action: startAction)
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Create your first soap swirl sketch from the empty Swirl Wall")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct StarterExamplesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Starter examples")
                .font(.headline)
            ForEach(StarterExample.examples) { example in
                VStack(alignment: .leading, spacing: 5) {
                    Text(example.title)
                        .font(.subheadline.weight(.semibold))
                    Text(example.disclosureCopy)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

struct SwirlRecordCard: View {
    let record: SoapSwirlSketchRecord

    var body: some View {
        HStack(spacing: 14) {
            CutFacePreview(style: record.styleParams)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(record.title)
                        .font(.headline)
                    if record.favorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(SoapTheme.coral)
                            .accessibilityLabel("Favorite")
                    }
                }
                Text(record.styleParams.scentMood)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(record.styleParams.cutFaceNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("Updated \(record.updatedAt.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(Locale(identifier: "en_US"))))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
