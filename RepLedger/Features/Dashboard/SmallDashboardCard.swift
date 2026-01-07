import SwiftUI

// MARK: - Layout Constants (outside generic type)
private enum SmallDashboardCardLayout {
    static let cardPadding: CGFloat = 14
    static let minHeight: CGFloat = 130
    static let cornerRadius: CGFloat = 12
}

/// Shared container for small dashboard cards (Recovery, Latest PR)
/// Ensures consistent height, padding, and styling across the row
struct SmallDashboardCard<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let theme = themeManager.current

        content
            .padding(SmallDashboardCardLayout.cardPadding)
            .frame(maxWidth: .infinity, minHeight: SmallDashboardCardLayout.minHeight, alignment: .topLeading)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: SmallDashboardCardLayout.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: SmallDashboardCardLayout.cornerRadius)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
            .rlShadow(theme.shadows.card)
    }
}

#Preview {
    let theme = ObsidianTheme()
    ZStack {
        theme.colors.background.ignoresSafeArea()
        HStack(spacing: 12) {
            SmallDashboardCard {
                VStack(alignment: .leading) {
                    Text("Card 1")
                        .foregroundStyle(theme.colors.text)
                    Spacer()
                    Text("Bottom")
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            SmallDashboardCard {
                VStack(alignment: .leading) {
                    Text("Card 2")
                        .foregroundStyle(theme.colors.text)
                    Text("More content here")
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .padding()
    }
    .environment(ThemeManager())
}
