import SwiftUI

struct PressureTrackerView: View {
    @EnvironmentObject private var storage: AppStorageManager
    @StateObject private var viewModel = PressureTrackerViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        topBar
                        if viewModel.hasData {
                            if let forecast = PressureForecastService.forecast(
                                from: storage.pressureHistory,
                                current: viewModel.currentPressure
                            ) {
                                ForecastCard(forecast: forecast)
                            }
                            gaugeSection
                            chartSection
                            alertButton
                            historyButton
                            if viewModel.isTracking {
                                stopButton
                            }
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .appScreenStyle()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.configure(storage: storage)
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    viewModel.resumeTimerIfNeeded()
                } else {
                    viewModel.pauseTimer()
                }
            }
            .sheet(isPresented: $viewModel.showHistory) {
                PressureHistorySheet(points: viewModel.weekHistory)
            }
            .sheet(isPresented: $viewModel.showAlertSheet) {
                alertThresholdSheet
            }
            .successOverlay(show: $viewModel.showSuccess)
        }
    }

    private var topBar: some View {
        AppCard(showAccentStripe: false) {
            HStack(spacing: 14) {
                LogoMark().frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(storage.selectedLocation?.name ?? "My Area")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text(Date(), style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                if viewModel.isTracking {
                    AppChip(text: "Live", icon: "dot.radiowaves.left.and.right", tint: "AppComfortGood")
                }
            }
        }
        .padding(.top, 8)
    }

    private var gaugeSection: some View {
        let level = storage.comfortLevel(for: viewModel.currentPressure)
        return AppCard(accentColor: level.colorName) {
            VStack(spacing: 10) {
                PressureGaugeView(
                    pressure: viewModel.currentPressure,
                    needleAngle: viewModel.needleAngle,
                    comfortColorName: level.colorName
                )
                .frame(height: 210)
                Text(String(format: "%.1f hPa", viewModel.currentPressure))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                AppChip(text: ComfortZoneService.label(for: level), icon: "gauge", tint: level.colorName)
            }
        }
    }

    private var chartSection: some View {
        AppCard(accentColor: "AppAccent") {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Last 24 Hours", subtitle: "Pressure trend", icon: "chart.xyaxis.line")
                PressureLineChart(points: viewModel.last24Hours)
                    .frame(height: 150)
            }
        }
    }

    private var alertButton: some View {
        Button("Set Alert Threshold") { viewModel.showAlertSheet = true }
            .buttonStyle(PrimaryButtonStyle())
    }

    private var historyButton: some View {
        Button("View History") { viewModel.openHistory() }
            .buttonStyle(SecondaryButtonStyle())
    }

    private var stopButton: some View {
        Button("Stop Tracking") { viewModel.stopTracking() }
            .buttonStyle(SecondaryButtonStyle())
    }

    private var emptyState: some View {
        AppEmptyState(
            icon: "speedometer",
            title: "Tap to Start Tracking",
            message: "Enable live barometric monitoring to see pressure trends and forecasts.",
            buttonTitle: "Start Tracking"
        ) {
            viewModel.startTracking()
        }
        .padding(.vertical, 24)
    }

    private var alertThresholdSheet: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                Form {
                    Section {
                        TextField("Threshold (hPa)", text: $viewModel.thresholdInput)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: viewModel.shakeTrigger)
                        if let error = viewModel.thresholdError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Alert Threshold")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showAlertSheet = false }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.saveAlertThreshold() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct LogoMark: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2 - 2
            var circle = Path()
            circle.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
            context.stroke(circle, with: .color(Color("AppPrimary")), lineWidth: 3)
            var arc = Path()
            arc.addArc(center: center, radius: r * 0.6, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
            context.stroke(arc, with: .color(Color("AppAccent")), lineWidth: 2)
        }
    }
}

struct PressureGaugeView: View {
    let pressure: Double
    let needleAngle: Double
    var comfortColorName: String = "AppPrimary"

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.55)
            let radius = min(size.width, size.height) * 0.42
            var arc = Path()
            arc.addArc(center: center, radius: radius, startAngle: .degrees(135), endAngle: .degrees(405), clockwise: false)
            context.stroke(arc, with: .color(Color(comfortColorName).opacity(0.55)), lineWidth: 12)
            let tickCount = 10
            for i in 0...tickCount {
                let angle = Angle.degrees(135 + Double(i) / Double(tickCount) * 270)
                let inner = CGPoint(
                    x: center.x + cos(angle.radians) * (radius - 16),
                    y: center.y + sin(angle.radians) * (radius - 16)
                )
                let outer = CGPoint(
                    x: center.x + cos(angle.radians) * radius,
                    y: center.y + sin(angle.radians) * radius
                )
                var tick = Path()
                tick.move(to: inner)
                tick.addLine(to: outer)
                context.stroke(tick, with: .color(Color("AppTextSecondary")), lineWidth: 2)
            }
            let needleRad = needleAngle * .pi / 180
            let tip = CGPoint(x: center.x + cos(needleRad) * (radius - 20), y: center.y + sin(needleRad) * (radius - 20))
            var needle = Path()
            needle.move(to: center)
            needle.addLine(to: tip)
            context.stroke(needle, with: .color(Color("AppAccent")), lineWidth: 4)
            context.fill(Path(ellipseIn: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)), with: .color(Color("AppTextPrimary")))
        }
    }
}

struct PressureLineChart: View {
    let points: [PressureHistoryPoint]

    var body: some View {
        GeometryReader { geo in
            if points.count < 2 {
                VStack {
                    Spacer()
                    Text("Collecting data…")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                }
            } else {
                Canvas { context, size in
                    let values = points.map(\.value)
                    let minV = (values.min() ?? 980) - 2
                    let maxV = (values.max() ?? 1040) + 2
                    let range = max(maxV - minV, 1)
                    var line = Path()
                    for (index, point) in points.enumerated() {
                        let x = size.width * CGFloat(index) / CGFloat(max(points.count - 1, 1))
                        let y = size.height - ((CGFloat(point.value - minV) / CGFloat(range)) * size.height)
                        if index == 0 {
                            line.move(to: CGPoint(x: x, y: y))
                        } else {
                            line.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    context.stroke(line, with: .color(Color("AppAccent")), lineWidth: 2.5)
                    var fill = line
                    fill.addLine(to: CGPoint(x: size.width, y: size.height))
                    fill.addLine(to: CGPoint(x: 0, y: size.height))
                    fill.closeSubpath()
                    context.fill(fill, with: .color(Color("AppAccent").opacity(0.15)))
                }
            }
        }
    }
}

struct PressureHistorySheet: View {
    let points: [PressureHistoryPoint]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    if points.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.largeTitle)
                                .foregroundStyle(Color("AppPrimary"))
                            Text("No history for the past week yet.")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(.top, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Past Week Trends")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            PressureLineChart(points: points)
                                .frame(height: 200)
                                .padding()
                                .background(Color("AppSurface"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            ForEach(points.reversed()) { point in
                                AppCard(accentColor: "AppAccent", showAccentStripe: true) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(point.timestamp, style: .date)
                                                .font(.subheadline.weight(.medium))
                                            Text(point.timestamp, style: .time)
                                                .font(.caption)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                        Spacer()
                                        Text(String(format: "%.1f hPa", point.value))
                                            .font(.headline)
                                            .foregroundStyle(Color("AppAccent"))
                                    }
                                    .foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
