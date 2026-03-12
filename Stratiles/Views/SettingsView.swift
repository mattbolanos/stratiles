import SwiftUI
import WidgetKit
import StratilesCore

struct SettingsView: View {
    let onSignedOut: () -> Void
    var onActivityTypesChanged: (Set<ActivityType>) -> Void = { _ in }

    @State private var selectedTypes = SharedActivityTypeSettings.loadSelectedTypes()
    @State private var isSigningOut = false
    @State private var showingPrivacyPolicy = false

    var body: some View {
        NavigationStack {
            Form {
              Section {
                    WidgetInstructionRow(step: 1, icon: "plus.app", text: "Long-press your Home Screen")
                    WidgetInstructionRow(step: 2, icon: "hand.tap", text: "Tap Add Widget")
                    WidgetInstructionRow(step: 3, icon: "magnifyingglass", text: "Search for \"Stratiles\"")
                    WidgetInstructionRow(step: 4, icon: "checkmark.circle", text: "Add the widget you want!")
                } header: {
                    if #available(iOS 26.0, *) {
                        Label("Add to Home Screen", systemImage: "square.grid.2x2")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.stravaOrange)
                            .textCase(nil)
                            .labelStyle(.titleAndIcon)
                            .labelIconToTitleSpacing(8)
                    } else {
                        Label("Add to Home Screen", systemImage: "square.grid.2x2")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.stravaOrange)
                            .textCase(nil)
                            .labelStyle(.titleOnly)
                    }
                }

                ForEach(ActivityType.grouped(), id: \.category) { group in
                    Section {
                        ForEach(group.types, id: \.self) { type in
                            Toggle(type.displayName, isOn: binding(for: type))
                        }
                    } header: {
                        if #available(iOS 26.0, *) {
                            Label(group.category.rawValue, systemImage: group.category.icon)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.stravaOrange)
                                .textCase(nil)
                                .labelStyle(.titleAndIcon)
                                .labelIconToTitleSpacing(8)
                        } else {
                            Label(group.category.rawValue, systemImage: group.category.icon)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.stravaOrange)
                                .textCase(nil)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                .tint(Theme.stravaOrange)

                Section {
                    Button(role: .destructive) {
                        Task { await signOut() }
                    } label: {
                        HStack {
                            if isSigningOut {
                                ProgressView()
                            } else {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    .disabled(isSigningOut)
                }

                Section {
                    Link(destination: URL(string: "https://github.com/mattbolanos/stratiles")!) {
                        HStack {
                            Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Link(destination: URL(string: "https://github.com/mattbolanos/stratiles/issues")!) {
                        HStack {
                            Label("Support", systemImage: "questionmark.circle")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    VStack(spacing: 8) {
                        Text("Made with ❤️ by Matt Bolaños")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                        Image("PoweredByStrava")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Stratiles")
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
        .onChange(of: selectedTypes) { _, newValue in
            let nonEmpty = newValue.isEmpty ? ActivityType.defaultSelected : newValue
            selectedTypes = nonEmpty
            SharedActivityTypeSettings.saveSelectedTypes(nonEmpty)
            WidgetCenter.shared.reloadAllTimelines()
            onActivityTypesChanged(nonEmpty)
        }
    }

    private func binding(for type: ActivityType) -> Binding<Bool> {
        Binding(
            get: { selectedTypes.contains(type) },
            set: { isOn in
                if isOn {
                    selectedTypes.insert(type)
                } else {
                    selectedTypes.remove(type)
                }
            }
        )
    }

    private func signOut() async {
        await MainActor.run { isSigningOut = true }
        await TokenManager.shared.clearToken()
        await ActivityCache.shared.clear()
        WidgetCenter.shared.reloadAllTimelines()
        await MainActor.run {
            isSigningOut = false
            onSignedOut()
        }
    }
}

private struct WidgetInstructionRow: View {
    let step: Int
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.subtleOrange)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.stravaOrange)
            }

            Text("\(step). \(text)")
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
