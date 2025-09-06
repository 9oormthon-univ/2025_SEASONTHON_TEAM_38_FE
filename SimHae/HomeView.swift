//
//  HomeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        VStack {
            Image(.appLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 18)
                .padding(.top, 24)
                Spacer()
                Image("jellyCha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 160)
                Spacer()
        }
        .background {
            Image("HomeBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    HomeView()
}
