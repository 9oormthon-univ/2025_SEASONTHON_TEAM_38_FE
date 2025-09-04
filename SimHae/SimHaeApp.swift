//
//  SimHaeApp.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI
import Combine

@main
struct SimHaeApp: App {
    @State private var bag = Set<AnyCancellable>()
    private let auth = AuthService()
    @AppStorage("didRegisterAnonymous") private var didRegisterAnonymous = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .task {
                    // guard !didRegisterAnonymous else { return }  // 임시로 주석! 실제로는 이 코드로 한번만 하면 됨!
                    auth.ensureAnonymousUser()
                        .sink { completion in
                            switch completion {
                            case .finished:
                                didRegisterAnonymous = true
                            case .failure(let error):
                                print("❌ 요청 실패:", error)
                            }
                        } receiveValue: { resp in
                            print("(서버가 잘 응답함) 🆔 내 UUID:", AnonymousId.getOrCreate())
                        }
                        .store(in: &bag)
                }
        }
    }
}
