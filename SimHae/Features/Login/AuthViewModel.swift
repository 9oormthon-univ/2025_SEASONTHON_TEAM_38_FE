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
    func logout()
    var isAuthenticated: Bool { get }
}

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

    func logout() {
        TokenStore.clear()
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
                print("❌ Apple ID 토큰 추출 실패")
                return
            }
            print("✅ Apple ID 토큰 추출 성공:", identityToken.prefix(30), "...")
            print("✅ Nonce:", nonce)
            
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
                    print("✅ 로그인 파이프라인 완료")
                    self.currentNonce = nil
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    print("❌ 로그인 실패:", err)
                }
            } receiveValue: { [weak self] in
                print("✅ 로그인 성공 → isAuthenticated = true")
                self?.isAuthenticated = true
            }
            .store(in: &bag)
    }

    func logout() {
        service.logout()
        isAuthenticated = false
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
