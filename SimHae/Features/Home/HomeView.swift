//
//  HomeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    private let quotes: [String] = [
        "사람들은 의식하든 의식하지 못하든, 매일 꿈을 꿔요.\n안 꾸는 사람은 없답니다.",
        "상어는 잠재의식에 있는 탐욕을 상징해요.\n 상어가 나오는 꿈을 꾸신 적이 있나요?",
        "꿈을 기록하기 시작하면 꿈을 더 많이 꿀 수 있어요.\n무의식의 길을 열어 보세요.",
        "꿈에 나오는 인물, 특히 멘토나 조력자는\n기록해 두세요. 큰 도움이 됩니다.",
        "꿈에 나온 무언가를 검색하기 전에,\n당신에게 어떤 의미인지 알아보세요."
    ]
    
    private var todayQuote: String {
            // 오늘 날짜를 정수로 변환
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let dateString = formatter.string(from: Date())
            let seed = Int(dateString) ?? 0
            
            // 날짜 기반 인덱스 (매일 바뀜)
            let index = seed % quotes.count
            return quotes[index]
        }
    
    var body: some View {
        
        VStack {
            TopBarView(tokenCount: 10)
            Spacer()
            Spacer()
            
                Text(todayQuote)
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
