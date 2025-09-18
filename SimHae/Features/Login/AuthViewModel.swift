//
//  AppleLoginViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/17/25.
//

import Foundation
import Combine
import AuthenticationServices
import CryptoKit


struct AppleLoginRequest: Encodable {
    let identityToken: String
    let nonce: String
}

struct AppleLoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

protocol AuthServicing {
    func loginWithApple(identityToken: String, nonce: String) -> AnyPublisher<Void, Error>
    func logout() -> AnyPublisher<Void, Error>
    var isAuthenticated: Bool { get }
}

// 요청/응답 모델
struct LogoutRequest: Encodable { let refreshToken: String }
struct EmptyEnvelopeData: Decodable {} // data가 비어오는 경우용


final class AuthService: AuthServicing {
    func loginWithApple(identityToken: String, nonce: String) -> AnyPublisher<Void, Error> {
        print("➡️ 서버에 Apple 로그인 요청:", identityToken.prefix(20), "...")
        let req = APIClient.shared.request("/auth/apple",
                                           method: "POST",
                                           body: AppleLoginRequest(identityToken: identityToken, nonce: nonce),
                                           authorized: false)
        // Envelope로 감싸진 응답을 디코딩
                return APIClient.shared.run(Envelope<AppleLoginResponse>.self, with: req)
                    .tryMap { env in
                        // 상태코드/메시지 확인 (옵션)
                        guard (200...299).contains(env.status) else {
                            throw URLError(.badServerResponse)
                        }
                        // 토큰 저장
                        TokenStore.accessToken  = env.data.accessToken
                        TokenStore.refreshToken = env.data.refreshToken
                        return ()
                    }
                    .eraseToAnyPublisher()
            }

    // 서버 로그아웃 호출
        func logout() -> AnyPublisher<Void, Error> {
            guard let refresh = TokenStore.refreshToken else {
                // 이미 토큰이 없으면 그냥 성공으로 처리
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            let req = APIClient.shared.request("/auth/logout",
                                               method: "POST",
                                               body: LogoutRequest(refreshToken: refresh),
                                               authorized: false)

            // 서버가 표준 Envelope를 준다고 가정 (data 비어있을 수 있음)
            return APIClient.shared.run(Envelope<EmptyEnvelopeData>.self, with: req)
                .map { _ in () } // 응답 바디는 버림
                .eraseToAnyPublisher()
        }

    var isAuthenticated: Bool {
        TokenStore.accessToken != nil && TokenStore.refreshToken != nil
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: AuthServicing
    private var bag = Set<AnyCancellable>()
    
    // nonce 저장
    var currentNonce: String?

    init(service: AuthServicing = AuthService()) {
        self.service = service
        self.isAuthenticated = service.isAuthenticated
    }

    /// Apple 버튼 콜백 전체를 받아 내부에서 처리
    func handleAuthorization(result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let err):
            self.errorMessage = err.localizedDescription
            print("❌ Apple auth 실패:", err)


        case .success(let auth):
            guard
                let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = cred.identityToken,
                let identityToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                self.errorMessage = "Apple ID 토큰을 읽지 못했어요."
                return
            }
            
            loginWithApple(identityToken: identityToken, nonce: nonce)
        }
    }

    func loginWithApple(identityToken: String, nonce: String) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        service.loginWithApple(identityToken: identityToken, nonce: nonce)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    self.currentNonce = nil
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    print("❌ 로그인 실패:", err)
                }
            } receiveValue: { [weak self] in
                print("로그인 성공 → isAuthenticated = true")
                self?.isAuthenticated = true
            }
            .store(in: &bag)
    }

    // 네트워크 로그아웃 → 토큰 삭제 → 상태 전환
        func logout() {
            guard !isLoading else { return }
            isLoading = true
            errorMessage = nil

            service.logout()
                .catch { [weak self] err -> AnyPublisher<Void, Never> in
                    // 서버 실패해도 로컬은 정리하고 넘어가자(사용자 경험용)
                    self?.errorMessage = err.localizedDescription
                    return Just(()).eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    // 로컬 토큰 정리
                    TokenStore.clear()
                    self?.isAuthenticated = false
                    self?.isLoading = false
                }
                .store(in: &bag)
        }
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
        }
    }
    return result
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}

//로그찍기
enum NetworkLogger {
    static func logRequest(_ req: URLRequest) {
#if DEBUG
        print("🟦 [REQ]", req.httpMethod ?? "", req.url?.absoluteString ?? "")
        if let headers = req.allHTTPHeaderFields { print("🟦 Headers:", headers) }
        if let body = req.httpBody, let json = String(data: body, encoding: .utf8) {
            print("🟦 Body:", json)
        }
#endif
    }

    static func logResponse(data: Data?, response: URLResponse?, error: Error?) {
#if DEBUG
        if let http = response as? HTTPURLResponse {
            print("🟩 [RES] \(http.statusCode) \(http.url?.absoluteString ?? "")")
            print("🟩 Headers:", http.allHeaderFields)
        } else {
            print("🟩 [RES] (no HTTPURLResponse)")
        }

        if let data, let text = String(data: data, encoding: .utf8) {
            print("🟩 Body:", text)
        }
        if let error {
            print("🟥 [ERR]", error.localizedDescription)
        }
#endif
    }
}
