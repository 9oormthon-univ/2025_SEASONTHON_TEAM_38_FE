//
//  DreamService.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation
import Combine

protocol DreamService {
    func analyze(input: DreamInput) -> AnyPublisher<(DreamRestate, DreamInterpretation, [String]), Error>
}

final class RealDreamService: DreamService {
    private let client = APIClient.shared

    struct CreateReq: Encodable {
        let content: String
        let dreamDate: String
    }

    func analyze(input: DreamInput) -> AnyPublisher<(DreamRestate, DreamInterpretation, [String]), Error> {
        // 날짜 포맷
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale   = .init(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"

        let body = CreateReq(
                   content: input.content,
                   dreamDate: df.string(from: input.date)
               )

        let req = client.request("/ai/dreams/overall", method: "POST", body: body)

        return client.run(Envelope<CreateDreamAllDTO>.self, with: req)
            .tryMap { env in
                guard (200...201).contains(env.status) else {
                    throw URLError(.badServerResponse)
                }
                return env.data.toDomain()
            }
            .eraseToAnyPublisher()
    }
}
