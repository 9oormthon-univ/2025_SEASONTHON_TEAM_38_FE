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
//    @Published var micLevel: Double = 0
    @Published var hasPermission: Bool = false
    @Published var errorMessage: String?
    
    @ObservedObject private(set) var speechRecognizer: SpeechRecognizer
    
    private var bag = Set<AnyCancellable>()
    private var pollCancellable: AnyCancellable?
    
    init(speechRecognizer: SpeechRecognizer) {
        self.speechRecognizer = speechRecognizer

        // 🔥 Forward objectWillChange
        speechRecognizer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)

        // transcript 연동
        speechRecognizer.$transcript
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.transcript = text
            }
            .store(in: &bag)
    }
    
    var isRecording: Bool { speechRecognizer.isTranscribing }

       func toggleRecording() {
           isRecording
           ? speechRecognizer.stopTranscribing()
           : speechRecognizer.startTranscribing()
       }
    private func startRecording() {
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
