import Foundation

/// Reads ChatGPT auth from ~/.codex/auth.json (or $CODEX_HOME)
/// and hits the same backend the Codex CLI uses:
///   GET https://chatgpt.com/backend-api/codex/usage
/// No `codex` binary required.
enum UsageService {
    static let usageURL = URL(string: "https://chatgpt.com/backend-api/codex/usage")!

    struct Auth {
        var accessToken: String
        var accountID: String
        /// Kept for future OAuth refresh; currently we re-read the file on
        /// 401 in case Codex rotated the token underneath us.
        var refreshToken: String?
    }

    static func loadAuth() throws -> Auth {
        let base: URL = {
            if let home = ProcessInfo.processInfo.environment["CODEX_HOME"], !home.isEmpty {
                return URL(fileURLWithPath: home)
            }
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".codex")
        }()
        let url = base.appendingPathComponent("auth.json")
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        let tokens = json["tokens"] as? [String: Any] ?? [:]
        guard let token = tokens["access_token"] as? String, !token.isEmpty else {
            throw NSError(domain: "CodexReserve", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No access token in ~/.codex/auth.json. Open Codex once and sign in."])
        }
        let accountID = (tokens["account_id"] as? String) ?? ""
        let refreshToken = tokens["refresh_token"] as? String
        return Auth(accessToken: token, accountID: accountID, refreshToken: refreshToken)
    }

    private static func makeRequest(auth: Auth) -> URLRequest {
        var req = URLRequest(url: usageURL, timeoutInterval: 8)
        req.setValue("Bearer \(auth.accessToken)", forHTTPHeaderField: "Authorization")
        if !auth.accountID.isEmpty {
            req.setValue(auth.accountID, forHTTPHeaderField: "chatgpt-account-id")
        }
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    /// 403 with HTML body is transient (Cloudflare) — retry like codex-cli-usage does.
    /// Bounded: 4 tries, 8s per-request timeout, 20s overall deadline.
    static func fetchSnapshot() async throws -> UsageSnapshot {
        var auth = try loadAuth()
        var lastError: Error?
        let delays: [Double] = [0, 0.5, 1.0, 2.0]
        let deadline = Date().addingTimeInterval(20)
        var didReloadOn401 = false
        for delay in delays {
            if Date() > deadline { break }
            if delay > 0 { try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) }
            if Date() > deadline { break }
            do {
                let (data, resp) = try await URLSession.shared.data(for: makeRequest(auth: auth))
                guard let http = resp as? HTTPURLResponse else { continue }
                switch http.statusCode {
                case 200:
                    return try UsageSnapshot.fromAPI(data)
                case 401:
                    // Token may have rotated on disk (Codex rewrote auth.json).
                    // Re-read once and retry before telling the user to sign in.
                    if !didReloadOn401, let fresh = try? loadAuth(),
                       fresh.accessToken != auth.accessToken {
                        didReloadOn401 = true
                        auth = fresh
                        lastError = NSError(domain: "CodexReserve", code: 401,
                                            userInfo: [NSLocalizedDescriptionKey: "Token rotated, retrying…"])
                        continue
                    }
                    throw NSError(domain: "CodexReserve", code: 401,
                                  userInfo: [NSLocalizedDescriptionKey: "Session expired — open Codex to sign in again."])
                case 403:
                    lastError = NSError(domain: "CodexReserve", code: 403,
                                        userInfo: [NSLocalizedDescriptionKey: "Usage service busy (403). Retrying…"])
                    continue // transient, retry
                default:
                    throw NSError(domain: "CodexReserve", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "Unexpected response (\(http.statusCode))."])
                }
            } catch let e as NSError where e.domain == "CodexReserve" && (e.code == 401 || e.code > 404) {
                throw e
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError ?? NSError(domain: "CodexReserve", code: -1,
                                   userInfo: [NSLocalizedDescriptionKey: "Could not reach Codex usage."])
    }
}
