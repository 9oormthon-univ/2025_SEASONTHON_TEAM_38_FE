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
    private var lastTranscriptCount: Int = 0

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


//    /// 음성 transcript -> input.text 반영
//    private func bindSpeech() {
//        
//        
//        speech.$transcript
//            .removeDuplicates()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] t in
//                guard let self else { return }
//                if self.speech.isRecording {
//                    self.input.content = t
//                }
//            }
//            .store(in: &bag)
//    }
    
    private func bindSpeech() {
            // ✅ 1) 녹음 상태 전이 감지: 시작할 때 준비
            speech.$isRecordingFlag
                .removeDuplicates()
                .sink { [weak self] isRecording in
                    guard let self else { return }
                    if isRecording {
                        // 새 세션 시작 → 이번 세션 카운터 리셋
                        self.lastTranscriptCount = 0
                        // 기존 내용이 있으면 공백 하나 붙여 깔끔하게 이어쓰기
                        if !self.input.content.isEmpty,
                           !self.input.content.hasSuffix(" ") {
                            self.input.content += " "
                        }
                    } else {
                        // 세션 종료 시에는 아무것도 안 함 (내용 유지)
                    }
                }
                .store(in: &bag)

            // ✅ 2) transcript가 변할 때 "새로 추가된 부분"만 이어붙이기
            speech.$transcript
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] t in
                    guard let self else { return }
                    guard self.speech.isRecording else { return } // 녹음 중일 때만 반영

                    // 이번 세션에서 새로 생긴 부분만 계산
                    let full = t
                    let startIdx = full.index(full.startIndex, offsetBy: min(self.lastTranscriptCount, full.count))
                    let newChunk = String(full[startIdx...])

                    if !newChunk.isEmpty {
                        self.input.content += newChunk
                        self.lastTranscriptCount = full.count
                    }
                }
                .store(in: &bag)
        }
    func startNewSession(for date: Date) {
            restate = nil
            interpretation = nil
            actions = []
            errorMessage = nil
            isSubmitting = false
            input = DreamInput(content: "", date: date)
            // ✅ 새로운 기록 세션 시작 시 카운터도 리셋
            lastTranscriptCount = 0
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
    
    @MainActor
    func resetAll(selectedDate: Date? = nil) {
        // 입력 값 초기화
        input.content = ""
        input.date = selectedDate ?? Date()
        actions = []
           // 음성 녹음/텍스트 초기화 등도 필요하면 함께
           if speech.isRecording { speech.toggleRecording() }
           speech.transcript = ""
        // 음성 인식/전사 초기화
        speech.reset()
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
