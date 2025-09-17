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
    init() {
        NotificationManager.shared.configure()
    }
    
    @StateObject private var authVM = AuthViewModel()
    
    @State private var bag = Set<AnyCancellable>()
    private let auth = AuthService()
    @StateObject private var DreamSessionVM = DreamSessionViewModel(service: RealDreamService(), speech: SpeechInputViewModel(speechRecognizer: SpeechRecognizer()))
    @StateObject private var calendarVM = CalendarViewModel(service: RealCalendarDreamService())
    
    @ObservedObject private var route: NavigationRouter = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    NavigationStack(path: $route.path,
                                    root: {
                        ContentView()
                            .environmentObject(authVM)
                            .preferredColorScheme(.dark)
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
                } else {
                    LoginView()
                        .environmentObject(authVM)
                }
            }
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
