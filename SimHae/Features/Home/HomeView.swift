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
            TopBarView(tokenCount: 10)
            Spacer()
            Spacer()
            
                Text("상어는 잠재의식에 있는 탐욕을 상징해요.\n상어가 나오는 꿈을 꾸신 적이 있나요?")
                .foregroundStyle(Color(hex: "#E8D9FF"))
                .padding(.horizontal, 32)
                .padding(.vertical, 18)
                .multilineTextAlignment(.center)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(hex: "#FFFFFF").opacity(0.1))
                )
            Spacer()
                Image("jellyCha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
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
