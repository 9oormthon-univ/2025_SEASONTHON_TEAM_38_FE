//
//  DetailViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import Foundation
import Combine

@MainActor
final class DreamDetailViewModel: ObservableObject {
    @Published var detail: DreamDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var isDeleting = false
    
    private let dreamId: String
    private let service: DreamDetailService
    private var bag = Set<AnyCancellable>()
    
    init(dreamId: String, service: DreamDetailService = RealDreamDetailService()) {
        self.dreamId = dreamId
        self.service = service
    }
    
    func fetch() {
        if detail != nil { return }    // 중복 호출 방지 (원하면 제거)
        isLoading = true
        errorMessage = nil
        
        service.fetchDreamDetailPublisher(id: dreamId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] detail in
                self?.detail = detail
            }
            .store(in: &bag)
    }
    
    func delete(onSuccess: (() -> Void)? = nil) {
        guard !isDeleting else { return }
        isDeleting = true
        errorMessage = nil
        
        service.deleteDream(id: dreamId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isDeleting = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                } else {
                    onSuccess?()
                }
            } receiveValue: { _ in }
            .store(in: &bag)
    }
    
    func retry() { detail = nil; fetch() }
}
