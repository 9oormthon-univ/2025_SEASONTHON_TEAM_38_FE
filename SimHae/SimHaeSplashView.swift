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
        ZStack {
            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                Image("SplashImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SimHaeSplashView()
}
