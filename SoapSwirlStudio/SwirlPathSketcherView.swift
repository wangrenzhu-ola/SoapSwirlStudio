import SwiftUI

struct SwirlPathSketcherView: View {
    @EnvironmentObject private var store: SoapSwirlStore
    @Binding var path: [SoapRoute]
    @State private var draft: SoapSwirlDraft
    @State private var saveMessage: String?
    @State private var saveError: SoapSwirlSaveError?
    @FocusState private var noteFocused: Bool

    init(initialDraft: SoapSwirlDraft, path: Binding<[SoapRoute]>) {
        _draft = State(initialValue: initialDraft)
        _path = path
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SoapLoafPreview(style: draft.styleParams, compact: false)
                    .padding(16)
                    .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(alignment: .leading, spacing: 14) {
                    Label("Editing swirl path", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        .font(.headline)
                    TextField("Pour style", text: $draft.pourStyle)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Swirl path pour style")
                    VStack(alignment: .leading) {
                        Text("Swirl intensity")
                            .font(.subheadline.weight(.semibold))
                        Slider(value: $draft.swirlIntensity, in: 0.15...0.95) {
                            Text("Swirl intensity")
                        }
                        Text("\(Int(draft.swirlIntensity * 100)) percent ribbon movement")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Toggle("Mark as favorite soap swirl sketch", isOn: $draft.favorite)
                    TextField("Cut-face preview note", text: $draft.cutFaceNote, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .focused($noteFocused)
                        .accessibilityLabel("Cut-face preview note")
                }
                .padding(16)
                .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                if let saveMessage {
                    Label(saveMessage, systemImage: "checkmark.seal")
                        .foregroundStyle(.green)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                if let saveError {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Save failure", systemImage: "exclamationmark.triangle")
                            .font(.headline)
                        Text(saveError.localizedDescription)
                        Text("Your current soap swirl sketch draft remains editable. Retry when ready.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .accessibilityElement(children: .combine)
                }

                VStack(spacing: 10) {
                    Button(action: saveDraft) {
                        Label("Save soap swirl sketch", systemImage: "tray.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: simulateSaveFailure) {
                        Label("Check save recovery and keep draft", systemImage: "arrow.clockwise.heart")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .soapScreenBackground()
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Swirl Path Sketcher")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") { noteFocused = false }
            }
        }
    }

    private func saveDraft() {
        do {
            let record = try store.save(draft: draft)
            draft.id = record.id
            saveError = nil
            saveMessage = "Save success: \(record.title) is on the Swirl Wall."
            path.append(.detail(record.id))
        } catch let error as SoapSwirlSaveError {
            saveMessage = nil
            saveError = error
        } catch {
            saveMessage = nil
            saveError = .storageFailure(error.localizedDescription)
        }
    }

    private func simulateSaveFailure() {
        do {
            _ = try store.save(draft: draft, simulateFailure: true)
        } catch let error as SoapSwirlSaveError {
            saveMessage = nil
            saveError = error
        } catch {
            saveMessage = nil
            saveError = .storageFailure(error.localizedDescription)
        }
    }
}
