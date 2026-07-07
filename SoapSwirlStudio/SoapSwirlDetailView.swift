import SwiftUI

struct SoapSwirlDetailView: View {
    @EnvironmentObject private var store: SoapSwirlStore
    let recordID: UUID
    @Binding var path: [SoapRoute]
    @State private var showingDeleteConfirm = false
    @State private var deleteError: String?

    private var record: SoapSwirlSketchRecord? {
        store.records.first { $0.id == recordID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let record {
                    SoapLoafPreview(style: record.styleParams, compact: false)
                        .padding(16)
                        .background(Color.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(record.title)
                                .font(.largeTitle.bold())
                            Spacer()
                            Button(action: toggleFavorite) {
                                Image(systemName: record.favorite ? "heart.fill" : "heart")
                            }
                            .accessibilityLabel(record.favorite ? "Remove favorite" : "Favorite soap swirl sketch")
                        }
                        Text(record.styleParams.scentMood)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(record.styleParams.cutFaceNote)
                            .foregroundStyle(.secondary)
                        HStack {
                            SoapStatusPill(title: "Stored on this device", systemImage: "internaldrive")
                            SoapStatusPill(title: "Editable", systemImage: "pencil")
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(spacing: 10) {
                        Button {
                            path.append(.sketcher(SoapSwirlDraft(record: record)))
                        } label: {
                            Label("Edit soap swirl sketch", systemImage: "slider.horizontal.3")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Label("Delete soap swirl sketch", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Delete soap swirl sketch named \(record.title)")
                    }

                    if let deleteError {
                        Text(deleteError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } else {
                    ContentUnavailableView(
                        "Soap swirl sketch not found",
                        systemImage: "tray",
                        description: Text("Return to the Swirl Wall and create or reopen a local soap swirl sketch.")
                    )
                }
            }
            .padding(20)
        }
        .soapScreenBackground()
        .navigationTitle("Sketch Detail")
        .confirmationDialog(
            "Delete this soap swirl sketch?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible,
            presenting: record
        ) { record in
            Button("Delete \(record.title)", role: .destructive) {
                delete(record)
            }
            Button("Keep sketch", role: .cancel) {}
        } message: { record in
            Text("This removes \(record.title) and its local handmade soap loaf, swirl path, and cut-face preview from the Swirl Wall.")
        }
    }

    private func toggleFavorite() {
        guard let record else { return }
        try? store.toggleFavorite(record: record)
    }

    private func delete(_ record: SoapSwirlSketchRecord) {
        do {
            try store.delete(record: record)
            path = []
        } catch {
            deleteError = "Delete failed. The soap swirl sketch is still available locally."
        }
    }
}
