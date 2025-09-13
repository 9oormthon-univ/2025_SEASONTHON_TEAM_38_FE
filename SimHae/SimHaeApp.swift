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
    @StateObject private var DreamSessionVM = DreamSessionViewModel(service: RealDreamService(), speech: SpeechInputViewModel(speechRecognizer: SpeechRecognizer()))
    @StateObject private var calendarVM = CalendarViewModel(service: RealCalendarDreamService())
    
    @ObservedObject private var route: NavigationRouter = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $route.path,
                            root: {
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
                    .ignoresSafeArea(.keyboard)
                    .environmentObject(route)
                    .environmentObject(calendarVM)
                    .navigationDestination(for: RouteType.self,
                                           destination: { type in
                        switch type {
                        case .add: AddDreamView(vm: DreamSessionVM, selectedDate: $calendarVM.selectDate)
                                .environmentObject(route)
                                .environmentObject(calendarVM)
                        case .loading: DreamLoadingView(vm: DreamSessionVM)
                                .environmentObject(route)
                        case .summary: DreamSummaryView(vm: DreamSessionVM)
                                .environmentObject(route)
                                .environmentObject(calendarVM)
                        case .interpretation: DreamInterpretationView(vm: DreamSessionVM)
                                .environmentObject(route)
                                .environmentObject(calendarVM)
                        case .suggestion: DreamSuggestionView(vm: DreamSessionVM)
                                .environmentObject(route)
                                .environmentObject(calendarVM)
                        }
                    })
                
            })
                
        }
    }
}

enum RouteType: Hashable {
    case add, loading, summary, interpretation, suggestion
}

class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(to route: RouteType) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func removeAll() {
        path.removeLast(path.count)
    }
}
