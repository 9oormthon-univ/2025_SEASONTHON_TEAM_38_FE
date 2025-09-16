//
//  LoginView.swift
//  SimHae
//
//  Created by 홍준범 on 9/17/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        
        VStack {
            Spacer()
            Spacer()
            Spacer()
            Image(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 130)
            Text("심해 心解")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#B184FF"))
                .padding(.top, -36)
            
            
            Text("꿈은 나보다 나를 더 잘 알고 있어요.")
                .font(.footnote)
                .foregroundStyle(Color(hex: "#B184FF"))
                .padding()
            
            Spacer()
            Spacer()
            
            Button(action: {
                
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Apple로 시작하기")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: 350)
            }
            .frame(width: 350)
            .padding(.vertical, 16)
            .background(Color(hex: "FFFFFF"))
            .foregroundStyle(Color(hex: "000000"))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
            
        }
        .background {
            Image(.detailView)
                .resizable()
                .scaledToFill()
        }
    }
    
    
}

#Preview {
    LoginView()
}
