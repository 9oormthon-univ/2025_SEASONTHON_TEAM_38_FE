//
//  LoginView.swift
//  SimHae
//
//  Created by 홍준범 on 9/17/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    
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
            
            SignInWithAppleButton(.signIn) { request in
                // 1) 랜덤 nonce 생성
                let nonce = randomNonceString()
                authVM.currentNonce = nonce
                
                // 2) hashed nonce를 request에 넣기
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
                
                print("➡️ Generated nonce:", nonce)
                
            } onCompletion: { result in
                authVM.handleAuthorization(result: result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 48)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
            
        }
        .background {
            Image(.detailView)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    
}

#Preview {
    LoginView()
}
