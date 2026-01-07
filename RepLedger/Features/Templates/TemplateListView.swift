import SwiftUI
import SwiftData

/// List view for managing workout templates.
/// Shows template count for free users and handles paywall gating.
struct TemplateListView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.purchaseManager) private var purchaseManager

    @Query(sort: \Template.lastUsedAt, order: .reverse) private var templates: [Template]

    @State private var showCreateTemplate = false
    @State private var templateToEdit: Template?
    @State private var showProPaywall = false
    @State private var templateToDelete: Template?

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            Group {
                if templates.isEmpty {
                    RLEmptyState.noTemplates {
                        handleCreateTemplate()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: theme.spacing.md) {
                            // Template count header (for free users)
                            if !purchaseManager.isPro {
                                TemplateCountBanner(
                                    currentCount: templates.count,
                                    maxCount: Template.freeLimit
                                )
                                .padding(.horizontal, theme.spacing.md)
                            }

                            // Template list
                            LazyVStack(spacing: theme.spacing.sm) {
                                ForEach(templates) { template in
                                    Button {
                                        templateToEdit = template
                                    } label: {
                                        TemplateRowView(
                                            template: template,
                                            exerciseCount: template.orderedExerciseIds.count
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            duplicateTemplate(template)
                                        } label: {
                                            Label("Duplicate", systemImage: "doc.on.doc")
                                        }

                                        Button(role: .destructive) {
                                            templateToDelete = template
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, theme.spacing.md)
                        }
                        .padding(.vertical, theme.spacing.md)
                    }
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        handleCreateTemplate()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTemplate) {
                TemplateEditorView(mode: .create)
            }
            .sheet(item: $templateToEdit) { template in
                TemplateEditorView(mode: .edit(template))
            }
            .sheet(isPresented: $showProPaywall) {
                ProPaywallView()
            }
            .alert("Delete Template?", isPresented: Binding(
                get: { templateToDelete != nil },
                set: { if !$0 { templateToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        deleteTemplate(template)
                    }
                    templateToDelete = nil
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete \"\(template.name)\"? This action cannot be undone.")
                }
            }
        }
    }

    private func handleCreateTemplate() {
        if purchaseManager.canCreateTemplate(currentCount: templates.count) {
            showCreateTemplate = true
        } else {
            showProPaywall = true
        }
    }

    private func duplicateTemplate(_ template: Template) {
        if purchaseManager.canCreateTemplate(currentCount: templates.count) {
            let newTemplate = Template(
                name: "\(template.name) (Copy)",
                orderedExerciseIds: template.orderedExerciseIds
            )
            modelContext.insert(newTemplate)
            try? modelContext.save()
        } else {
            showProPaywall = true
        }
    }

    private func deleteTemplate(_ template: Template) {
        modelContext.delete(template)
        try? modelContext.save()
    }
}

/// Banner showing template count for free users
private struct TemplateCountBanner: View {
    @Environment(ThemeManager.self) private var themeManager

    let currentCount: Int
    let maxCount: Int

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(theme.colors.accent)

            Text("\(currentCount) of \(maxCount) templates used")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Spacer()

            if currentCount >= maxCount {
                RLPill("Limit Reached", style: .subtle, color: .warning, size: .small)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Preview

#Preview("TemplateListView") {
    TemplateListView()
        .environment(ThemeManager())
}
