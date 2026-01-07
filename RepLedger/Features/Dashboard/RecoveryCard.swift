import SwiftUI

struct RecoveryCard: View {
    @Environment(ThemeManager.self) private var themeManager

    @State private var showInfoSheet = false
    @State private var showDetailView = false

    let recovery: [RecoveryItem]
    let isLoading: Bool

    // MARK: - Layout Constants
    private enum Layout {
        static let headerSpacing: CGFloat = 4
        static let contentSpacing: CGFloat = 10
        static let barSpacing: CGFloat = 8
    }

    var body: some View {
        let theme = themeManager.current

        SmallDashboardCard {
            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                // Header row with title and info button
                headerSection(theme: theme)

                // Recovery bars or empty state
                if isLoading {
                    // Loading placeholders
                    VStack(spacing: Layout.barSpacing) {
                        RecoveryProgressBar(
                            muscle: "Loading",
                            percentage: 0.5,
                            theme: theme
                        )
                        .redacted(reason: .placeholder)

                        RecoveryProgressBar(
                            muscle: "Loading",
                            percentage: 0.3,
                            theme: theme
                        )
                        .redacted(reason: .placeholder)
                    }
                } else if recovery.isEmpty {
                    // All recovered state
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.colors.accent)

                        Text("All recovered")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    // Real recovery bars
                    VStack(spacing: Layout.barSpacing) {
                        ForEach(recovery) { item in
                            RecoveryProgressBar(
                                muscle: item.muscle.displayName,
                                percentage: item.recovered,
                                theme: theme
                            )
                        }
                    }
                }

                Spacer(minLength: 0)

                // Tap affordance
                HStack(spacing: 4) {
                    Text("See recovery")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.colors.textTertiary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showDetailView = true
        }
        .sheet(isPresented: $showInfoSheet) {
            RecoveryInfoSheet()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showDetailView) {
            RecoveryDetailView()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recovery status")
        .accessibilityHint("Tap to view recovery details")
    }

    // MARK: - Header Section

    @ViewBuilder
    private func headerSection(theme: any Theme) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Layout.headerSpacing) {
                // Title row
                HStack(spacing: 5) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.colors.textTertiary)

                    Text("RECOVERY")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                // Subtitle
                Text("Most fatigued muscles")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // Info button
            Button {
                showInfoSheet = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Recovery information")
        }
    }
}

// MARK: - Recovery Progress Bar

private struct RecoveryProgressBar: View {
    let muscle: String
    let percentage: Double
    let theme: any Theme

    private var barColor: Color {
        if percentage >= 0.8 {
            return theme.colors.accent
        } else if percentage >= 0.5 {
            return theme.colors.accentOrange
        } else {
            return theme.colors.accentOrange
        }
    }

    private var percentageText: String {
        "\(Int(percentage * 100))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(muscle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)

                Spacer()

                Text(percentageText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(barColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.colors.elevated)

                    // Progress
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Recovery Info Sheet

struct RecoveryInfoSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What is Recovery?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(theme.colors.text)

                        Text("Recovery shows an estimate of how ready each muscle group is for training, based on your recent workout history.")
                            .font(.system(size: 15))
                            .foregroundStyle(theme.colors.textSecondary)
                            .lineSpacing(4)
                    }

                    Divider()
                        .background(theme.colors.divider)

                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it's calculated")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.colors.text)

                        BulletPoint(text: "Based on time since last training", theme: theme)
                        BulletPoint(text: "Volume and intensity of recent sessions", theme: theme)
                        BulletPoint(text: "General recovery guidelines (48-72h)", theme: theme)
                    }

                    Divider()
                        .background(theme.colors.divider)

                    // Color legend
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What the colors mean")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.colors.text)

                        ColorLegendRow(color: theme.colors.accent, label: "80%+", description: "Fully recovered", theme: theme)
                        ColorLegendRow(color: theme.colors.accentOrange, label: "50-79%", description: "Partially recovered", theme: theme)
                        ColorLegendRow(color: theme.colors.accentOrange, label: "Below 50%", description: "Still recovering", theme: theme)
                    }
                }
                .padding(20)
            }
            .background(theme.colors.background)
            .navigationTitle("Recovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(theme.colors.accent)
                }
            }
        }
    }
}

private struct BulletPoint: View {
    let text: String
    let theme: any Theme

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(theme.colors.accent)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

private struct ColorLegendRow: View {
    let color: Color
    let label: String
    let description: String
    let theme: any Theme

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 24, height: 8)

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.colors.text)
                .frame(width: 60, alignment: .leading)

            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

// MARK: - Recovery Detail View (Placeholder)

struct RecoveryDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(theme.colors.accent)

                Text("Recovery Details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.colors.text)

                Text("Full recovery breakdown\ncoming soon")
                    .font(.system(size: 15))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(theme.colors.background)
            .navigationTitle("Recovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(theme.colors.accent)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        HStack(spacing: 12) {
            // Real data
            RecoveryCard(
                recovery: [
                    RecoveryItem(muscle: .chest, recovered: 0.35, hoursSinceTraining: 12),
                    RecoveryItem(muscle: .back, recovered: 0.7, hoursSinceTraining: 36)
                ],
                isLoading: false
            )

            // All recovered
            RecoveryCard(
                recovery: [],
                isLoading: false
            )
        }
        .padding()
    }
    .environment(ThemeManager())
}
