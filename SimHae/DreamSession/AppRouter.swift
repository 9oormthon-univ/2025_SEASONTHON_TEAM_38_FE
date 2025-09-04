//
//  AppRouter.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import Foundation
import SwiftUI

final class AppRouter: ObservableObject {
    @Published var tab: TabBarItem = .home
    @Published var path = NavigationPath()
    
    func resetToHome() {
        path = NavigationPath()
        tab = .home
    }
}
