import SwiftUI

struct PressureInsightsView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @StateObject private var viewModel = PressureInsightsViewModel()

    var body: some View {
        ZStack {
            if viewModel.hasData {
                ScrollView {
                    VStack(spacing: 16) {
                        PeriodComparisonView()
                        WellnessCorrelationView()
                        periodPicker
                        chartSection
                        summaryCards
                        if !viewModel.significantDeviations.isEmpty {
                            deviationsSection
                        }
                        recordsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden)
            } else {
                AppEmptyState(
                    icon: "cloud.snow.fill",
                    title: "No Pressure Data Available",
                    message: "Track your first pressure change to unlock insights and trends.",
                    buttonTitle: "Add Data"
                ) {
                    viewModel.openAdd()
                }
            }
            VStack {
                Spacer()
                Button("Add Data") { viewModel.openAdd() }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.configure(storage: storage)
            viewModel.markViewed()
        }
        .sheet(isPresented: $viewModel.showAddSheet) { addDataSheet }
        .sheet(isPresented: $viewModel.showDetailSheet) {
            if let record = viewModel.selectedRecord {
                RecordDetailSheet(record: record, average: viewModel.averagePressure, locationName: storage.locationName(for: record.locationId))
            }
        }
        .successOverlay(show: $viewModel.showSuccess)
    }

    private var periodPicker: some View {
        AppCard(showAccentStripe: false) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Time Period").font(.caption).foregroundStyle(Color("AppTextSecondary"))
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(PressureInsightsViewModel.InsightPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var chartSection: some View {
        AppCard(accentColor: "AppAccent") {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Pressure Trends", subtitle: viewModel.selectedPeriod.rawValue, icon: "waveform.path.ecg")
                InsightsChart(records: viewModel.filteredRecords, deviations: viewModel.significantDeviations)
                    .frame(height: 170)
            }
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 10) {
            AppMetricCard(
                title: "Average",
                value: String(format: "%.1f hPa", viewModel.averagePressure),
                subtitle: viewModel.selectedPeriod.rawValue,
                icon: "gauge.medium",
                accent: "AppPrimary"
            )
            AppMetricCard(
                title: "Records",
                value: "\(viewModel.filteredRecords.count)",
                subtitle: "In period",
                icon: "tray.full",
                accent: "AppAccent"
            )
        }
    }

    private var deviationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Significant Deviations", icon: "exclamationmark.triangle.fill")
            ForEach(viewModel.significantDeviations) { record in
                Button { viewModel.selectRecord(record) } label: {
                    PressureRecordCell(
                        record: record,
                        locationName: storage.locationName(for: record.locationId),
                        showChevron: true,
                        deviation: record.pressureLevel - viewModel.averagePressure
                    )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var recordsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "All Records", subtitle: "\(viewModel.filteredRecords.count) in period", icon: "list.bullet")
            ForEach(viewModel.filteredRecords) { record in
                Button { viewModel.selectRecord(record) } label: {
                    PressureRecordCell(
                        record: record,
                        locationName: storage.locationName(for: record.locationId)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .contextMenu {
                    Button(role: .destructive) { viewModel.delete(record) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var addDataSheet: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    AppFormCard(title: "New Record") {
                        VStack(spacing: 14) {
                            TextField("Pressure (hPa)", text: $viewModel.pressureInput)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shake(trigger: viewModel.shakeTrigger)
                            LocationPickerRow(selectedLocationId: $viewModel.selectedLocationId)
                            WellnessPickerRow(selected: $viewModel.selectedWellness)
                            if let error = viewModel.pressureError {
                                Text(error).font(.caption).foregroundStyle(Color("AppComfortAlert"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showAddSheet = false }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.saveRecord() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct InsightsChart: View {
    let records: [PressureRecord]
    let deviations: [PressureRecord]

    var body: some View {
        GeometryReader { _ in
            if records.count < 2 {
                Text("Need more data points")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Canvas { context, size in
                    let sorted = records.sorted { $0.timestamp < $1.timestamp }
                    let values = sorted.map(\.pressureLevel)
                    let minV = (values.min() ?? 980) - 2
                    let maxV = (values.max() ?? 1040) + 2
                    let range = max(maxV - minV, 1)
                    var line = Path()
                    for (index, record) in sorted.enumerated() {
                        let x = size.width * CGFloat(index) / CGFloat(max(sorted.count - 1, 1))
                        let y = size.height - ((CGFloat(record.pressureLevel - minV) / CGFloat(range)) * size.height)
                        if index == 0 { line.move(to: CGPoint(x: x, y: y)) }
                        else { line.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    context.stroke(line, with: .color(Color("AppAccent")), lineWidth: 2.5)
                    let deviationIDs = Set(deviations.map(\.id))
                    for (index, record) in sorted.enumerated() {
                        guard deviationIDs.contains(record.id) else { continue }
                        let x = size.width * CGFloat(index) / CGFloat(max(sorted.count - 1, 1))
                        let y = size.height - ((CGFloat(record.pressureLevel - minV) / CGFloat(range)) * size.height)
                        let dot = CGRect(x: x - 5, y: y - 5, width: 10, height: 10)
                        context.fill(Path(ellipseIn: dot), with: .color(Color("AppPrimary")))
                    }
                }
            }
        }
    }
}

private struct RecordDetailSheet: View {
    let record: PressureRecord
    let average: Double
    let locationName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 16) {
                        AppDetailHeader(
                            value: String(format: "%.1f", record.pressureLevel),
                            unit: "hPa",
                            subtitle: record.timestamp.formatted(date: .complete, time: .shortened),
                            chips: detailChips
                        )
                        AppCard(accentColor: "AppAccent") {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Deviation from Average")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text(String(format: "%+.1f hPa", record.pressureLevel - average))
                                    .font(.title3.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Insight Details")
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
        if let wellness = record.wellnessNote {
            chips.append((wellness.title, wellness.systemImage))
        }
        return chips
    }
}
