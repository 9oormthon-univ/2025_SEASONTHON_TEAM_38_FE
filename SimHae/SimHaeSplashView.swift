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
        if isActive {
            ContentView()
        } else {
            ZStack {
                Image("SplashImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SimHaeSplashView()
}
