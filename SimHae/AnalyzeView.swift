//
//  AnalyzeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct AnalyzeView: View {
    var body: some View {
        ZStack {
            
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Text("최근 꾼 7개 꿈을 바탕으로 무의식을 분석했어요.")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.top, 32)
                        .padding(.bottom, 12)
                    
                    Text("여기에 7개 카드가 기울여져서 들어가야함..")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(8)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 100, style: .circular)
                                .fill(Color(hex: "#9963FF").opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100, style: .circular)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "#E8D9FF"),
                                                    Color(hex: "#7534E4"),
                                                    Color(hex: "#E8D9FF")
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    
                    Text("현실적인 부담감에 무기력해진 상태(서버연동)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 36)
                    
                    Text("지금 님의 상태는 꿈을 분석해봤을때 현실적인 부담감에 무기력해진 상태입니다. 어쩌고저쩌고 설명입니다. 지금 님의 상태는 꿈을 분석해봤을때 현실적인 부담감에 무기력해진 상태입니다. 어쩌고저쩌고 설명입니다. 어쩌고저쩌고 설명입니다. ")
                        .font(.body)
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .multilineTextAlignment(.leading)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(hex: "#7534E4").opacity(0.2))
                        )
                    //                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    //                                )
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    
                    Text("해파리의 제안")
                        .padding(.top, 48)
                        .padding(.bottom, 24)
                    
                    Image("jellyCha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("현재 느끼고 있는 즐거움과 압박감을 구분하고, 그 각각의 감정이 어떤 상황에서 발생하는지를 살펴보세요. 일상에서 당신이 좋아하는 활동을 지속적으로 찾아내고, 그것이 가져다주는 만족감을 경험해보는 것이 중요합니다. 또한, 자신에게 가해지는 압박감을 어떻게 줄일 수 있을지 고민해보세요. 때로는 자신에게 유연함을 주고, 완벽함이 아닌 과정에 집중하는 것이 도움이 될 수 있습니다. 감정의 갈등을 이해하고 수용하는 것은 자아를 더욱 강화하는 데 기여할 것입니다.")
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(hex: "#FFFFFF").opacity(0.1))
                        )
                        .padding(.top, 24)
                }
                
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
            .safeAreaPadding(.top)
        }
    }
}
#Preview {
    AnalyzeView()
}
