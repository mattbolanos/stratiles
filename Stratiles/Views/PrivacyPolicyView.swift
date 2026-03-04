import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Last updated: February 28, 2025")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    policySection("Overview",
                        "Stratiles is an iOS app that displays your Strava activity data as a heatmap widget on your Home Screen. Your privacy is important to us. This policy explains what data we access, how it is used, and your rights."
                    )

                    policySection("Data We Access",
                        "When you connect your Strava account, Stratiles reads the following via the Strava API:",
                        bullets: [
                            "Activity dates",
                            "Activity types (run, ride, swim, etc.)",
                            "Activity distances",
                        ],
                        footer: "We request the activity:read_all scope from Strava. No other data (heart rate, GPS routes, personal profile details) is accessed."
                    )

                    policySection("Data Storage",
                        "All activity data is stored locally on your device. It is never sent to, stored on, or processed by any external server. There is no user account, no cloud sync, and no analytics."
                    )

                    policySection("Authentication",
                        "Strava OAuth tokens are exchanged through a lightweight proxy server. This proxy injects the Strava API credentials and forwards requests to Strava. It does not log, store, or inspect any data passing through it.",
                        bullets: [
                            "The Strava login page opens in an ephemeral browser session that does not share cookies with Safari or any other app.",
                            "No cookies from the login page are stored on your device — they are discarded when the session ends.",
                            "Any cookie consent prompts shown during login come from Strava's website, not Stratiles.",
                        ]
                    )

                    policySection("Tracking & Analytics",
                        "Stratiles does not include any analytics SDKs, advertising frameworks, or tracking pixels. We do not collect usage data of any kind."
                    )

                    policySection("Third-Party Services",
                        "The only third-party service Stratiles communicates with is the Strava API. Your use of Strava is governed by Strava's Privacy Policy."
                    )

                    policySection("Deleting Your Data",
                        "To remove all data stored by Stratiles:",
                        bullets: [
                            "Sign out within the app (Settings \u{2192} Sign Out)",
                            "Delete the app from your device",
                        ],
                        footer: "To revoke Stratiles' access to your Strava account, visit Strava \u{2192} Settings \u{2192} My Apps and remove Stratiles."
                    )

                    policySection("Changes to This Policy",
                        "If this policy changes, the updated version will be posted with a new \"Last updated\" date."
                    )

                    policySection("Contact",
                        "Questions or concerns? Open an issue on our GitHub repository."
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func policySection(_ title: String, _ text: String, bullets: [String] = [], footer: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Text("\u{2022}")
                    Text(bullet)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            if let footer {
                Text(footer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
