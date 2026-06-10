import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DataTransferView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @State private var exportItem: ExportDocument?
    @State private var showImporter = false
    @State private var importError: String?
    @State private var importSuccess = false

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(spacing: 14) {
                    AppSectionHeader(
                        title: "Backup & Restore",
                        subtitle: "Move your data between devices",
                        icon: "externaldrive.fill"
                    )
                    transferCell(
                        title: "Export JSON",
                        subtitle: "Full backup with all settings",
                        icon: "doc.text.fill",
                        action: exportJSON
                    )
                    transferCell(
                        title: "Export CSV",
                        subtitle: "Spreadsheet-friendly log export",
                        icon: "tablecells.fill",
                        action: exportCSV
                    )
                    transferCell(
                        title: "Import JSON",
                        subtitle: "Restore from a backup file",
                        icon: "square.and.arrow.down.fill",
                        action: { showImporter = true }
                    )
                    if importSuccess {
                        AppCard(accentColor: "AppComfortGood") {
                            Label("Import completed successfully.", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    if let importError {
                        AppCard(accentColor: "AppComfortAlert") {
                            Text(importError)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                }
                .padding(16)
            }
            .appScreenStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Export / Import")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $exportItem) { item in
            ShareSheet(items: [item.url])
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            handleImport(result)
        }
    }

    private func transferCell(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AppCard {
                HStack(spacing: 14) {
                    AppIconCircle(systemName: icon, colorName: "AppPrimary", size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func exportJSON() {
        do {
            let data = try DataExportService.exportJSON(from: storage)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("pressure_backup.json")
            try data.write(to: url)
            exportItem = ExportDocument(url: url)
            FeedbackService.success()
        } catch {
            importError = "Export failed."
        }
    }

    private func exportCSV() {
        let csv = DataExportService.exportCSV(from: storage)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("pressure_backup.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportItem = ExportDocument(url: url)
            FeedbackService.success()
        } catch {
            importError = "Export failed."
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            importError = "Could not open file."
            FeedbackService.warning()
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Permission denied."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                try DataExportService.importJSON(data, into: storage)
                importSuccess = true
                importError = nil
                FeedbackService.success()
            } catch {
                importError = "Invalid backup file."
                FeedbackService.warning()
            }
        }
    }
}

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
