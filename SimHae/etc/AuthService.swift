import Combine
import Foundation

final class AuthService {
    private let client = APIClient.shared
    struct Resp: Decodable { let status: Int; let message: String? }

    func ensureAnonymousUser() -> AnyPublisher<Resp, Error> {
        let req = client.request("/users/anonymous", method: "POST", body: nil)

        return client.run(Resp.self, with: req)
            .tryMap { resp in
                guard (200...299).contains(resp.status) else {
                    throw URLError(.badServerResponse)
                }
                return resp
            }
            .eraseToAnyPublisher()
    }
}
