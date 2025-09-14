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
    
    @Published var isRecordingFlag: Bool = false
    
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
        
        // ✅ 추가: 녹음 상태 전달
                speechRecognizer.$isTranscribing
                    .receive(on: DispatchQueue.main)
                    .assign(to: &self.$isRecordingFlag)
    }
    
    var isRecording: Bool { speechRecognizer.isTranscribing }

       func toggleRecording() {
           isRecording
           ? speechRecognizer.stopTranscribing()
           : speechRecognizer.startTranscribing()
       }
    
    // ✅ 추가: 외부에서 호출 가능한 stop / reset
       func stop() {
           if isRecording { speechRecognizer.stopTranscribing() }
       }
    
    func reset() {
            stop()
            transcript = ""
            errorMessage = nil
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
