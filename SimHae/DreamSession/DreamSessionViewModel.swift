//
//  DreamSessionViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Combine

struct CreateDreamAllDTO: Decodable {
    struct Restate: Decodable {
        let emoji: String
        let title: String
        let content: String
        // 🔹 서버 스키마에 맞춘 신규 필드 (현재 도메인에선 미사용)
        let categoryName: String
        let categoryDescription: String
    }
    struct Unconscious: Decodable {
        let analysis: String
    }
    struct Suggestion: Decodable {
        let suggestion: String
    }
    let restate: Restate
    let unconscious: Unconscious
    let suggestion: Suggestion
}

struct DreamInput: Equatable {
    var content: String
    var date: Date // UI 표시에만 사용, 서버 전송 x
}

struct DreamRestate: Equatable {
    let emoji: String
    let title: String
    let content: String
    let category: String
    let categoryDescription: String
}
struct DreamInterpretation: Equatable {
    let title: String
    let detail: String
}

extension CreateDreamAllDTO {
    func toDomain() -> (DreamRestate, DreamInterpretation, [String]) {
        let restate = DreamRestate(
            emoji: restate.emoji,
            title: restate.title,
            content: restate.content,
            category: restate.categoryName,
            categoryDescription: restate.categoryDescription
        )
        let interp = DreamInterpretation(
            title: "해석",
            detail: unconscious.analysis
        )
        let actions = [suggestion.suggestion]
        return (restate, interp, actions)
    }
}

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

@MainActor
final class DreamSessionViewModel: ObservableObject {
    // 입력
    @Published var input = DreamInput(content: "", date: Date())

    // 결과
    @Published var restate: DreamRestate?
    @Published var interpretation: DreamInterpretation?
    @Published var actions: [String] = []

    // 상태
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?

    // 음성 인식 (조합)
    let speech: SpeechInputViewModel

    private let service: DreamService
    
    private var bag = Set<AnyCancellable>()
    private var networkBag = Set<AnyCancellable>()

    init(service: DreamService, speech: SpeechInputViewModel) {
        self.service = service
        self.speech = speech
        bindSpeech()
    }
    
    // ✅ 편의 이니셜라이저: 처음부터 선택 날짜로 시작
       convenience init(service: DreamService,
                        speech: SpeechInputViewModel,
                        initialDate: Date) {
           self.init(service: service, speech: speech)
           self.input.date = initialDate
       }


    /// 음성 transcript -> input.text 반영
    private func bindSpeech() {
        speech.$transcript
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] t in
                guard let self else { return }
                if self.speech.isRecording {
                    self.input.content = t
                }
            }
            .store(in: &bag)
    }

    /// 제출 가능 조건
    var canSubmit: Bool {
        input.content.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    /// 꿈 분석 요청 → 한 번에 모든 데이터 수신
    func analyzeDream() {
        guard canSubmit else { return }
        errorMessage = nil
        isSubmitting = true

        service.analyze(input: input)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSubmitting = false
                if case let .failure(err) = completion {
                    self.errorMessage = "네트워크 오류: \(err.localizedDescription)"
                }
            } receiveValue: { [weak self] (restate, interp, acts) in
                self?.restate = restate
                self?.interpretation = interp
                self?.actions = acts
            }
            .store(in: &bag)
    }

    /// 상태 초기화
    func reset() {
        isSubmitting = false
        errorMessage = nil
        restate = nil
        interpretation = nil
        actions = []
        input = .init(content: "", date: Date())
        bag.removeAll()
    }
}

extension DreamSessionViewModel {
    func startNewSession(for date: Date) {
        restate = nil
        interpretation = nil
        actions = []
        errorMessage = nil
        isSubmitting = false
        input = DreamInput(content: "", date: date)
    }
}

