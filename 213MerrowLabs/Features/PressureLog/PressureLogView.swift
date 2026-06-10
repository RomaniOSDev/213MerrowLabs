import SwiftUI

struct PressureLogView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @StateObject private var viewModel = PressureLogViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                quickPresetsSection

                if viewModel.logs.isEmpty {
                    Spacer()
                    AppEmptyState(
                        icon: "scribble.variable",
                        title: "No entries yet",
                        message: "Log your first pressure change or use a quick preset above.",
                        buttonTitle: "Add Entry"
                    ) {
                        viewModel.openAdd()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            AppSectionHeader(
                                title: "Recent Entries",
                                subtitle: "\(viewModel.logs.count) total",
                                icon: "list.bullet.rectangle"
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                            ForEach(viewModel.logs) { log in
                                PressureLogCell(log: log, locationName: storage.locationName(for: log.locationId))
                                    .padding(.horizontal, 16)
                                    .onTapGesture {
                                        FeedbackService.lightTap()
                                        viewModel.selectForDetail(log)
                                    }
                                    .contextMenu {
                                        Button { viewModel.selectForEdit(log) } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) { viewModel.delete(log) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .scrollContentBackground(.hidden)
                }
            }

            VStack {
                Spacer()
                Button("Add Entry") { viewModel.openAdd() }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.configure(storage: storage)
            storage.logLastViewed = Date()
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            logFormSheet(title: "Add Entry", onSave: viewModel.saveNewEntry)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            logFormSheet(title: "Edit Entry", onSave: viewModel.saveEdit)
        }
        .sheet(isPresented: $viewModel.showDetailSheet) {
            if let log = viewModel.selectedLog {
                LogDetailSheet(log: log, locationName: storage.locationName(for: log.locationId))
            }
        }
        .successOverlay(show: $viewModel.showSuccess)
    }

    private var quickPresetsSection: some View {
        AppCard(showAccentStripe: false) {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Quick Log", subtitle: "One-tap entry with time preset", icon: "bolt.fill")
                QuickPresetButtons { preset in
                    viewModel.quickAdd(preset: preset)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func logFormSheet(title: String, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 16) {
                        AppFormCard(title: "Entry Details") {
                            VStack(spacing: 14) {
                                presetPicker
                                pressureField
                                LocationPickerRow(selectedLocationId: $viewModel.selectedLocationId)
                                WellnessPickerRow(selected: $viewModel.selectedWellness)
                                noteField
                                if let error = viewModel.pressureError {
                                    Text(error).font(.caption).foregroundStyle(Color("AppComfortAlert"))
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showAddSheet = false
                        viewModel.showEditSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave).foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.large])
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Time Preset").font(.caption).foregroundStyle(Color("AppTextSecondary"))
            Picker("Preset", selection: Binding(
                get: { viewModel.selectedPreset ?? .now },
                set: { viewModel.selectedPreset = $0 }
            )) {
                ForEach(TimeOfDayPreset.allCases) { preset in
                    Text(preset.title).tag(preset)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var pressureField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pressure (hPa)").font(.caption).foregroundStyle(Color("AppTextSecondary"))
            TextField("1013.0", text: $viewModel.pressureInput)
                .keyboardType(.decimalPad)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(12)
                .background(Color("AppBackground").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shake(trigger: viewModel.shakeTrigger)
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note").font(.caption).foregroundStyle(Color("AppTextSecondary"))
            TextField("Optional note", text: $viewModel.noteInput)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(12)
                .background(Color("AppBackground").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct LogDetailSheet: View {
    let log: PressureLog
    let locationName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 16) {
                        AppDetailHeader(
                            value: String(format: "%.1f", log.pressure),
                            unit: "hPa",
                            subtitle: log.timestamp.formatted(date: .complete, time: .shortened),
                            chips: detailChips
                        )
                        AppCard(accentColor: log.changeMagnitude >= 0 ? "AppComfortWarning" : "AppComfortAlert") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pressure Change")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text(String(format: "%+.1f hPa from standard", log.changeMagnitude))
                                    .font(.title3.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        if !log.note.isEmpty {
                            AppCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Note").font(.caption).foregroundStyle(Color("AppTextSecondary"))
                                    Text(log.note).foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private var detailChips: [(String, String)] {
        var chips: [(String, String)] = [(locationName, "mappin.circle")]
        if let wellness = log.wellnessNote {
            chips.append((wellness.title, wellness.systemImage))
        }
        if let preset = log.timePreset {
            chips.append((preset.title, preset.systemImage))
        }
        return chips
    }
}
