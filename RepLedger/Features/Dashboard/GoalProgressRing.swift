import SwiftUI

struct GoalProgressRing: View {
    @Environment(ThemeManager.self) private var themeManager

    let current: Int
    let target: Int
    let size: CGFloat

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }

    var body: some View {
        let theme = themeManager.current

        ZStack {
            // Background circle
            Circle()
                .stroke(theme.colors.border, lineWidth: 4)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    theme.colors.accent,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Center text
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(current)")
                        .font(.system(size: size * 0.25, weight: .bold))
                        .foregroundStyle(theme.colors.text)

                    Text("/\(target)")
                        .font(.system(size: size * 0.15))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        GoalProgressRing(current: 4, target: 5, size: 64)
    }
    .environment(ThemeManager())
}
