import SwiftUI

struct ScentColorSetupView: View {
    @Binding var path: [SoapRoute]
    @State private var draft = SoapSwirlDraft.blank
    @FocusState private var focusedField: Field?

    private enum Field { case title, mood }

    var body: some View {
        Form {
            Section {
                SoapLoafPreview(style: draft.styleParams, compact: true)
                    .listRowBackground(Color.clear)
                Text("Build the first pour: choose the scent mood and color base. You can accept a local starter palette, edit every field, or continue manually.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Your soap swirl sketch") {
                TextField("Sketch title", text: $draft.title)
                    .focused($focusedField, equals: .title)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Soap swirl sketch title")
                TextField("Scent mood", text: $draft.scentMood)
                    .focused($focusedField, equals: .mood)
                    .accessibilityLabel("Scent mood")
                ColorTokenPicker(title: "Base loaf color", selection: $draft.baseColorHex, options: ColorToken.baseOptions)
                ColorTokenPicker(title: "Accent swirl color", selection: $draft.accentColorHex, options: ColorToken.accentOptions)
            }

            Section("Local draft starters") {
                Button("Use citrus ribbon suggestion") { applySuggestion(.citrus) }
                Button("Use clay moon suggestion") { applySuggestion(.clay) }
                Text("Starter palettes are generated on this device and require your confirmation before saving.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    focusedField = nil
                    path.append(.sketcher(draft))
                } label: {
                    Label("Continue to Swirl Path Sketcher", systemImage: "scribble")
                        .frame(maxWidth: .infinity)
                }
                .disabled(draft.trimmedTitle.isEmpty)
                .accessibilityLabel("Continue to Swirl Path Sketcher")
            }
        }
        .soapScreenBackground()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Scent Color Setup")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") { focusedField = nil }
            }
        }
    }

    private func applySuggestion(_ suggestion: DraftSuggestion) {
        draft.title = suggestion.title
        draft.scentMood = suggestion.scentMood
        draft.baseColorHex = suggestion.baseColorHex
        draft.accentColorHex = suggestion.accentColorHex
        draft.pourStyle = suggestion.pourStyle
        draft.cutFaceNote = suggestion.cutFaceNote
    }
}

private enum DraftSuggestion {
    case citrus, clay

    var title: String { self == .citrus ? "Citrus Ribbon Loaf" : "Clay Moon Cut" }
    var scentMood: String { self == .citrus ? "Bright orange peel and cream" : "Quiet cedar clay" }
    var baseColorHex: String { self == .citrus ? "F8E7D2" : "D8C1AA" }
    var accentColorHex: String { self == .citrus ? "D9725B" : "6E6A83" }
    var pourStyle: String { self == .citrus ? "Ribbon pour" : "Moon comb pull" }
    var cutFaceNote: String { self == .citrus ? "A creamy loaf with coral ribbons and a soft crescent cut-face." : "Muted clay base with a slate arc crossing the cut-face preview." }
}

struct ColorToken: Identifiable, Hashable {
    let id: String
    let name: String
    let hex: String

    static let baseOptions = [
        ColorToken(id: "cream", name: "Warm cream", hex: "F8E7D2"),
        ColorToken(id: "oat", name: "Oat milk", hex: "EFE2C8"),
        ColorToken(id: "clay", name: "Clay base", hex: "D8C1AA")
    ]

    static let accentOptions = [
        ColorToken(id: "coral", name: "Coral ribbon", hex: "D9725B"),
        ColorToken(id: "sage", name: "Sage trace", hex: "788B6F"),
        ColorToken(id: "slate", name: "Slate moon", hex: "6E6A83")
    ]
}

struct ColorTokenPicker: View {
    let title: String
    @Binding var selection: String
    let options: [ColorToken]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 8)], spacing: 8) {
                ForEach(options) { option in
                    Button {
                        selection = option.hex
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: option.hex))
                                .frame(width: 24, height: 24)
                            Text(option.name)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                            if selection == option.hex { Image(systemName: "checkmark") }
                        }
                        .padding(10)
                        .background(selection == option.hex ? Color.white.opacity(0.85) : Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select \(option.name) for \(title)")
                }
            }
        }
        .padding(.vertical, 4)
    }
}
