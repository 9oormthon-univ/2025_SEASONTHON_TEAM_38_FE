//
//  HomeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Image("HomeBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
            VStack {
                Spacer()
                Image("jellyCha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 160)
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
