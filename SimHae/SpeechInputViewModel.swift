//
//  SpeechInputViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import SwiftUI
import Combine

final class SpeechInputViewModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var micLevel: Double = 0
    @Published var hasPermission: Bool = false
    @Published var errorMessage: String?

    private let speechRecognizer: SpeechRecognizer
    private var bag = Set<AnyCancellable>()
    private var pollCancellable: AnyCancellable?

    init(speechRecognizer: SpeechRecognizer) {
        self.speechRecognizer = speechRecognizer
    }

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        isRecording = true
        Task { @MainActor in
            await speechRecognizer.startTranscribing()
        }

        // transcript 폴링 → transcript 업데이트
        pollCancellable?.cancel()
        pollCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.transcript = self.speechRecognizer.transcript
                }
            }
    }

    private func stopRecording() {
        isRecording = false
        pollCancellable?.cancel()
        pollCancellable = nil
        Task { @MainActor in
            await speechRecognizer.stopTranscribing()
        }
    }
}

// 추후 필요하면 추가
//    func requestPermissions() {
//        Task { @MainActor in
//            do {
//                try await speechRecognizer.requestAuthorization()
//                hasPermission = true
//            } catch {
//                hasPermission = false
//                errorMessage = (error as? SpeechRecognizer.RecognizerError)?.message
//            }
//        }
//    }
