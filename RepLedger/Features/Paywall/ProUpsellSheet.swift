import SwiftUI

/// Soft upsell sheet shown after completing 3 workouts.
/// Presented as a half-sheet with quick feature highlights.
struct ProUpsellSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showPaywall = false

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.lg) {
            // Dismiss handle
            Capsule()
                .fill(theme.colors.divider)
                .frame(width: 40, height: 4)
                .padding(.top, theme.spacing.sm)

            // Content
            VStack(spacing: theme.spacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("You're on Fire!")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("You've completed 3 workouts! Unlock unlimited templates and advanced analytics with Pro.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Highlight features
            VStack(spacing: theme.spacing.sm) {
                FeatureHighlight(icon: "doc.on.doc.fill", text: "Unlimited Templates")
                FeatureHighlight(icon: "chart.line.uptrend.xyaxis", text: "Volume Trends")
                FeatureHighlight(icon: "square.and.arrow.up", text: "Export Data")
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))

            // Actions
            VStack(spacing: theme.spacing.sm) {
                RLButton("See Pro Features", icon: "crown.fill") {
                    showPaywall = true
                }

                RLButton("Maybe Later", style: .tertiary) {
                    dismiss()
                }
            }

            Spacer()
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.background)
        .sheet(isPresented: $showPaywall) {
            ProPaywallView()
        }
    }
}

// MARK: - Feature Highlight

private struct FeatureHighlight: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let text: String

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 24)

            Text(text)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.text)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(theme.colors.success)
        }
    }
}

// MARK: - Preview

#Preview("ProUpsellSheet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ProUpsellSheet()
                .presentationDetents([.medium])
        }
        .environment(ThemeManager())
}
