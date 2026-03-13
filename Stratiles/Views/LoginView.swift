import AuthenticationServices
import SwiftUI
import StratilesCore

struct LoginView: View {
    let onAuthenticated: () -> Void

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appeared = false
    private let oauth = OAuthSessionCoordinator()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HeatmapPreview()
                .frame(maxWidth: 200)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .padding(.bottom, 40)

            Text("Stratiles")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

            Text("Your Strava activity heatmap,\nright on your Home Screen.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
                .opacity(appeared ? 1 : 0)

            Spacer()

            VStack(spacing: 16) {
                Button {
                    Task { await connectWithStrava() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(Theme.stravaOrange)
                    } else {
                        Image("ConnectWithStrava")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 48)
                    }
                }
                .disabled(isLoading)
                .opacity(appeared ? 1 : 0)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, 8)

            Text("We only read your activity data.\nNothing is stored on our servers.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    private func connectWithStrava() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let config = try StravaConfiguration.current()
            let authorizeURL = try makeAuthorizeURL(clientID: config.clientID)
            let callbackURL = try await oauth.authenticate(url: authorizeURL, callbackScheme: StravaConfiguration.callbackURLScheme)

            let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems

            // Check for OAuth error parameters before looking for the code
            if let error = queryItems?.first(where: { $0.name == "error" })?.value {
                let description = queryItems?.first(where: { $0.name == "error_description" })?.value
                if error == "access_denied" {
                    throw LoginError.oauthError("Strava authorization was denied. Please try again and grant access to continue.")
                } else {
                    throw LoginError.oauthError(description ?? "Strava returned an error: \(error)")
                }
            }

            guard let code = queryItems?.first(where: { $0.name == "code" })?.value else {
                throw LoginError.missingCode
            }

            do {
                _ = try await StravaAPIClient.shared.exchangeAuthorizationCode(code)
            } catch {
                throw LoginError.tokenExchangeFailed(error.localizedDescription)
            }
            onAuthenticated()
        } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
            // User dismissed the login sheet — not an error.
        } catch let error as LoginError {
            await MainActor.run {
                errorMessage = error.errorDescription
            }
        } catch {
            await MainActor.run {
                errorMessage = "Unable to connect to Strava. Please check your internet connection and try again."
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    private func makeAuthorizeURL(clientID: String) throws -> URL {
        var components = URLComponents(string: "https://www.strava.com/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: StravaConfiguration.callbackURL),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "activity:read_all"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
        ]

        guard let url = components.url else {
            throw LoginError.invalidAuthorizeURL
        }

        return url
    }
}

enum LoginError: LocalizedError {
    case invalidAuthorizeURL
    case missingCode
    case oauthError(String)
    case tokenExchangeFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidAuthorizeURL:
            return "Unable to build Strava authorization URL."
        case .missingCode:
            return "Strava did not return an authorization code. Please try again."
        case .oauthError(let message):
            return message
        case .tokenExchangeFailed(let message):
            return "Failed to complete sign-in: \(message)"
        }
    }
}

#Preview {
    LoginView(onAuthenticated: ({ print("Hello!") }))
}
