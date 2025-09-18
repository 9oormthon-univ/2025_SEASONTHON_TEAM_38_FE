//
//  TopBarView.swift
//  SimHae
//
//  Created by 홍준범 on 9/18/25.
//

import Foundation
import SwiftUI

struct TopBarView: View {
    var tokenCount: Int
    
    var body: some View {
        HStack {
            // 왼쪽 프로필 버튼
            NavigationLink(destination: MyPageView()) {
                Image(.user)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(hex: "#B184FF"))
            }
            .padding(.top, 24)
            .padding(.leading, 24)
            
            Spacer()
            
            // 중앙 로고
            Image(.appLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 18)
                .padding(.top, 24)
                .padding(.leading, 28)
            
            Spacer()
            
            // 오른쪽 토큰 박스
            HStack(spacing: 4) {
                NavigationLink(destination: PaymentView()) {
                    Image(.token1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(hex: "#B184FF"))
                }
                
                Text("\(tokenCount)")
                    .foregroundStyle(Color(hex: "#B184FF"))
            }
            .padding(4)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(hex: "#843CFF").opacity(0.2))
                    .stroke(Color(hex: "B184FF"))
            )
            .padding(.top, 24)
            .padding(.trailing, 16)
        }
    }
}
