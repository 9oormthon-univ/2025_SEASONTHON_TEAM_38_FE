//
//  DreamLoadingView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct DreamLoadingView: View {
    @ObservedObject var vm: DreamSessionViewModel
    @State private var goSummary = false
    
    var body: some View {
        ZStack {
            Image("DreamSessionBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Image("jellyCha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                let style = Date.FormatStyle.dateTime
                    .year().month().day().weekday(.wide)
                    .locale(Locale(identifier: "ko_KR"))

                Text("\(vm.input.date.formatted(style))의 꿈을 \n 해몽중이에요.")
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "#E8D9FF"))
                    .padding()
                    .padding(.bottom, 40)
                
                if let message = vm.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
            }
            .onChange(of: vm.restate) { new in
                if new != nil { goSummary = true }
            }
            .navigationDestination(isPresented: $goSummary) {
                DreamSummaryView(vm: vm)
            }
        }
    }
}

//#Preview {
//    DreamLoadingView()
//}
