//
//  SimHaeSplashView.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import SwiftUI

struct SimHaeSplashView: View {
    @State private var isActive = false
    
    var body: some View {
        Image("SplashImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    SimHaeSplashView()
}
