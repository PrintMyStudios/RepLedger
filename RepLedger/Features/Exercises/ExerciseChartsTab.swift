import SwiftUI
import Charts

/// Charts tab showing progress over time.
struct ExerciseChartsTab: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings
    @Environment(\.purchaseManager) private var purchaseManager

    @State private var showProPaywall = false

    let exercise: Exercise
    let history: [ExerciseHistorySummary]

    var body: some View {
        let theme = themeManager.current

        Group {
            if history.isEmpty {
                RLEmptyState(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Data Yet",
                    subtitle: "Complete workouts with this exercise to see progress charts."
                )
            } else {
                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        // FREE: Weight over time
                        ChartSection(title: "Best Weight Over Time") {
                            weightChart
                        }

                        // FREE: e1RM over time
                        ChartSection(title: "Estimated 1RM Over Time") {
                            e1rmChart
                        }

                        // PRO: Volume trends (blur REAL data)
                        ChartSection(title: "Volume Trends") {
                            if purchaseManager.isPro {
                                volumeChart
                            } else {
                                ProChartGate(chartTitle: "Volume Trends", onUnlock: {
                                    showProPaywall = true
                                }) {
                                    volumeChart
                                }
                            }
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
        .sheet(isPresented: $showProPaywall) {
            ProPaywallView()
        }
    }

    // MARK: - Charts

    private var weightChart: some View {
        let theme = themeManager.current
        let data = chartData.filter { $0.weight != nil }

        return Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Weight", convertWeight(point.weight ?? 0))
            )
            .foregroundStyle(theme.colors.accent)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("Date", point.date),
                y: .value("Weight", convertWeight(point.weight ?? 0))
            )
            .foregroundStyle(theme.colors.accent)
        }
        .chartYAxisLabel(settings.liftingUnit.abbreviation)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 200)
    }

    private var e1rmChart: some View {
        let theme = themeManager.current
        let data = chartData.filter { $0.e1rm != nil }

        return Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("e1RM", convertWeight(point.e1rm ?? 0))
            )
            .foregroundStyle(theme.colors.success)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("Date", point.date),
                y: .value("e1RM", convertWeight(point.e1rm ?? 0))
            )
            .foregroundStyle(theme.colors.success)
        }
        .chartYAxisLabel(settings.liftingUnit.abbreviation)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 200)
    }

    private var volumeChart: some View {
        let theme = themeManager.current

        return Chart(chartData) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Volume", convertWeight(point.volume))
            )
            .foregroundStyle(theme.colors.accent.gradient)
        }
        .chartYAxisLabel(settings.liftingUnit.abbreviation)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 200)
    }

    // MARK: - Helpers

    private var chartData: [ChartDataPoint] {
        history.map { item in
            ChartDataPoint(
                id: item.workoutId,  // Use stable workoutId for identity
                date: item.date,
                weight: item.bestWeight,
                e1rm: item.bestE1RM,
                volume: item.totalVolume
            )
        }.sorted { $0.date < $1.date }
    }

    private func convertWeight(_ kg: Double) -> Double {
        switch settings.liftingUnit {
        case .kg: return kg
        case .lb: return kg * 2.20462
        }
    }
}

// MARK: - Chart Data Point

private struct ChartDataPoint: Identifiable {
    let id: UUID  // Use stable workoutId for identity (avoids re-render jank)
    let date: Date
    let weight: Double?
    let e1rm: Double?
    let volume: Double
}

// MARK: - Chart Section

private struct ChartSection<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(theme.colors.text)

            RLCard {
                content()
            }
        }
    }
}

// MARK: - Pro Chart Gate

private struct ProChartGate<Chart: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let chartTitle: String
    let onUnlock: () -> Void
    @ViewBuilder let chart: () -> Chart

    var body: some View {
        let theme = themeManager.current

        ZStack {
            // Blur the real chart data (looks more premium than placeholder)
            chart()
                .blur(radius: 8)
                .allowsHitTesting(false)

            // Pro upgrade overlay
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundStyle(theme.colors.text)

                Text("Unlock \(chartTitle)")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.text)

                Button {
                    onUnlock()
                } label: {
                    Text("Unlock with Pro")
                        .font(theme.typography.caption)
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.sm)
                        .background(theme.colors.accent)
                        .foregroundStyle(theme.colors.textOnAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(theme.spacing.lg)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        }
        .frame(height: 200)
    }
}

// MARK: - Preview

#Preview("ExerciseChartsTab") {
    ExerciseChartsTab(
        exercise: Exercise.seeded(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell),
        history: [
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Workout 1",
                date: Date().addingTimeInterval(-86400 * 14),
                setCount: 3,
                totalVolume: 2000,
                bestWeight: 80,
                bestE1RM: 96
            ),
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Workout 2",
                date: Date().addingTimeInterval(-86400 * 10),
                setCount: 4,
                totalVolume: 2400,
                bestWeight: 85,
                bestE1RM: 102
            ),
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Workout 3",
                date: Date().addingTimeInterval(-86400 * 7),
                setCount: 4,
                totalVolume: 2800,
                bestWeight: 90,
                bestE1RM: 108
            ),
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Workout 4",
                date: Date().addingTimeInterval(-86400 * 3),
                setCount: 4,
                totalVolume: 3200,
                bestWeight: 95,
                bestE1RM: 114
            ),
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Workout 5",
                date: Date(),
                setCount: 4,
                totalVolume: 3600,
                bestWeight: 100,
                bestE1RM: 120
            )
        ]
    )
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
