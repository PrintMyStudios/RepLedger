import SwiftUI
import StoreKit

/// Full paywall screen for Coach subscription upgrade.
struct CoachPaywallView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.purchaseManager) private var purchaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    headerSection

                    includedSection

                    coachFeaturesSection

                    pricingSection

                    purchaseButton

                    restoreLink

                    termsText
                }
                .padding(theme.spacing.lg)
            }
            .background(theme.colors.background)
            .navigationTitle("RepLedger Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            // Pre-select annual as best value
            selectedProduct = purchaseManager.coachProducts.last
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.md) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.colors.accent)

            Text("RepLedger Coach")
                .font(theme.typography.titleMedium)
                .foregroundStyle(theme.colors.text)

            Text("Train clients and grow your coaching business")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, theme.spacing.lg)
    }

    // MARK: - Included Section

    private var includedSection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(theme.colors.success)
                Text("Includes everything in Pro, plus:")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.text)
            }
            .padding(.bottom, theme.spacing.xs)
        }
    }

    // MARK: - Coach Features

    private var coachFeaturesSection: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.sm) {
            PaywallFeatureRow(
                icon: "person.crop.circle.badge.plus",
                title: "Client Management",
                subtitle: "Add and organize your training clients"
            )

            PaywallFeatureRow(
                icon: "doc.text.fill",
                title: "Program Assignment",
                subtitle: "Assign templates and programs to clients"
            )

            PaywallFeatureRow(
                icon: "chart.bar.doc.horizontal",
                title: "Compliance Tracking",
                subtitle: "Monitor client progress and adherence"
            )

            PaywallFeatureRow(
                icon: "infinity",
                title: "Unlimited Clients",
                subtitle: "No limit on the number of clients per seat"
            )
        }
    }

    // MARK: - Pricing

    private var pricingSection: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.md) {
            if purchaseManager.coachProducts.isEmpty {
                ProgressView()
                    .frame(height: 100)
            } else {
                ForEach(purchaseManager.coachProducts, id: \.id) { product in
                    ProductOptionButton(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        isBestValue: product.id == ProductID.coachAnnual.rawValue
                    ) {
                        selectedProduct = product
                    }
                }
            }

            // Error banner
            if case .error(let message) = purchaseManager.state {
                ErrorBanner(message: message) {
                    purchaseManager.clearError()
                }
            }

            // Pending message
            if case .pending = purchaseManager.state {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(theme.colors.warning)
                    Text("Purchase pending approval")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(theme.spacing.md)
                .background(theme.colors.warning.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        let isLoading = {
            if case .purchasing = purchaseManager.state { return true }
            return false
        }()

        return RLButton(
            "Continue",
            icon: "arrow.right",
            isLoading: isLoading,
            isDisabled: selectedProduct == nil
        ) {
            Task { await purchase() }
        }
    }

    // MARK: - Restore Link

    private var restoreLink: some View {
        let theme = themeManager.current
        let isRestoring = purchaseManager.state == .restoring

        return Button {
            Task { await purchaseManager.restorePurchases() }
        } label: {
            HStack(spacing: theme.spacing.xs) {
                if isRestoring {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text("Restore Purchases")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .disabled(isRestoring)
    }

    // MARK: - Terms

    private var termsText: some View {
        let theme = themeManager.current

        return Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Payment will be charged to your Apple ID account.")
            .font(theme.typography.captionSmall)
            .foregroundStyle(theme.colors.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.top, theme.spacing.md)
    }

    // MARK: - Actions

    private func purchase() async {
        guard let product = selectedProduct else { return }
        let result = await purchaseManager.purchase(product)
        if case .success = result {
            dismiss()
        }
    }
}

// MARK: - Product Option Button (shared)

private struct ProductOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: theme.spacing.sm) {
                        Text(product.displayName)
                            .font(theme.typography.bodyLarge)
                            .foregroundStyle(theme.colors.text)

                        if isBestValue {
                            RLPill("Best Value", style: .filled, color: .success, size: .small)
                        }
                    }

                    Text(product.description)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(theme.typography.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.text)
            }
            .padding(theme.spacing.md)
            .background(isSelected ? theme.colors.accent.opacity(0.1) : theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(isSelected ? theme.colors.accent : theme.colors.border, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Error Banner (shared)

private struct ErrorBanner: View {
    @Environment(ThemeManager.self) private var themeManager

    let message: String
    let onDismiss: () -> Void

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(theme.colors.error)

            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.text)
                .lineLimit(2)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.error.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
    }
}

// MARK: - Preview

#Preview("CoachPaywallView") {
    CoachPaywallView()
        .environment(ThemeManager())
}
