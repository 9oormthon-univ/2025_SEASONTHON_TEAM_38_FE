//
//  AnalyzeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct AnalyzeView: View {
    @ObservedObject var vm: AnalyzeViewModel
    var body: some View {
        Group {
            
            if vm.showIntro {
                FirstAnalyzeIntro {
                    vm.startAnalyze()
                }
            }
            else if vm.isLoading {
                VStack {
                    TopBarView(tokenCount: 10)
                    
                    Spacer()
                    
                    ZStack {
                        Image(.thinkingJelly)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                        
                        LottieView(name: "thinking", loopMode: .loop)
                            .frame(width: 90, height: 90)
                            .offset(x: 85, y: -130)
                    }
                    
                    Text("나의 무의식 상태를\n분석중이에요.")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .padding()
                        .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
            else {
                VStack {
                    TopBarView(tokenCount: 10)
                    ScrollView {
                        VStack {
                            
                            
                            HStack {
                                Spacer()
                                
                                Text("최근 꾼 7개 꿈을 바탕으로\n무의식을 분석했어요.")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color(hex: "#B184FF"))
                                    .padding(.leading, 40)
                                    .padding(.top, 32)
                                    .padding(.bottom, 12)
                                
                                Spacer()
                                
                                Button {
                                    vm.reload()
                                } label: {
                                    Image("refresh")
                                        .resizable()
                                        .padding(12)
                                        .frame(width: 42, height: 42)
                                        .foregroundStyle(Color(hex: "#843CFF"))
                                        .background(
                                            Circle()
                                                .fill(Color(hex: "#FFFFFF").opacity(0.6))
                                        )
                                        .padding(.trailing, 16)
                                        .padding(.top, 32)
                                        .padding(.bottom, 12)
                                }
                            }
                            
                            DreamRibbonCloud(items: vm.summary?.recentDreams ?? [] )
                            
                            if let title = vm.summary?.title {
                                Text(title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.top, 36)
                                    .padding(.bottom, 12)
                            }
                            
                            if let sections = vm.summary?.analysis {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(sections.indices, id: \.self) { i in
                                            AnalysisSectionCard(
                                                title: sections[i].title,
                                                text: sections[i].content
                                            )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            Text("해파리의 제안")
                                .padding(.top, 48)
                                .padding(.bottom, 24)
                            
                            Image("jellyCha")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                            
                            if let suggestion = vm.summary?.suggestion {
                                Text(suggestion.splitWord())
                                    .foregroundStyle(Color(hex: "#E8D9FF"))
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .padding(28)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .fill(Color(hex: "#FFFFFF").opacity(0.1))
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.top, 24)
                            }
                            
                            
                            if let err = vm.errorMessage {
                                Text(err)
                                    .foregroundStyle(.red)
                                    .font(.footnote)
                                    .padding(.bottom, 40)
                            }
                        }
                    }
                    .padding(.bottom, 70)
                }
            }
        }
        .background{
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
        }
        .task {
            vm.loadIfNeeded()
        }
    }
}


struct DreamRibbonCloud: View {
    let items: [String]
    var spacing: CGFloat = 120
    var widthFactor: CGFloat = 0.30
    
    // 가로 흐름
    var flowSpeed: CGFloat = 36
    
    // 세로 파동(공통)
    var baseAmpY: Double = 24
    var waveSpeed: Double = 2.0
    var phaseStep: Double = .pi/8   // 슬롯 한 칸당 위상차(대칭)
    
    // 🔧 붙어 보이는 느낌을 깨는 파라미터
    var edgeBoost: Double = 0.28    // 가장자리로 갈수록 진폭을 최대 +18%
    var ampJitter: Double = 0.1    // 칩별 미세 지터(±6%)
    
    var body: some View {
        GeometryReader { geo in
            let chipW = min(geo.size.width * widthFactor, 420)
            let count = min(items.count, 7)
            let contentWidth = max(CGFloat(count) * spacing, geo.size.width)
            
            if count == 0 {
                Color.clear
            } else {
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let cycle = CGFloat(fmod(t * flowSpeed, contentWidth))
                    
                    ZStack {
                        sequenceView(chipW: chipW, count: count, time: t)
                            .offset(x: cycle - contentWidth)
                        sequenceView(chipW: chipW, count: count, time: t)
                            .offset(x: cycle)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .compositingGroup()
                }
            }
        }
        .frame(height: 120)
    }
    
    @ViewBuilder
    private func sequenceView(chipW: CGFloat, count: Int, time t: TimeInterval) -> some View {
        let startX = -spacing * CGFloat(max(count - 1, 0)) / 2
        let center = (Double(count) - 1.0) / 2.0   // 5칩이면 2.0
        
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let dist  = Double(i) - center                    // -2,-1,0,1,2 ...
                let phase = dist * phaseStep                      // 슬롯별 위상(대칭)
                
                // 진폭 스케일
                // 1) 가장자리 부스트: 중앙 0, 가장자리 1 → 1 + edgeBoost * ratio
                let edgeRatio = (center == 0) ? 0 : abs(dist) / center
                // 2) 인덱스 기반 지터: [-1, +1] → ±ampJitter
                let jitter    = (pseudoRand(i) * 2 - 1) * ampJitter
                // 최종 스케일
                let ampScale  = 1.0 + edgeBoost * edgeRatio + jitter
                
                let dy = (baseAmpY * ampScale) * sin(t * waveSpeed + phase)
                
                DreamChip(text: items[i])
                    .frame(width: chipW, height: 56)
                    .offset(x: startX + CGFloat(i) * spacing,
                            y: CGFloat(dy))
                    .shadow(color: .purple.opacity(0.25), radius: 12, x: 0, y: 6)
                    .zIndex(Double(i))
            }
        }
    }
    
    /// 인덱스 -> 0..1 사이 고정 난수(프레임마다 변하지 않음)
    private func pseudoRand(_ i: Int) -> Double {
        let x = sin(Double(i) * 12.9898) * 43758.5453
        return x - floor(x)
    }
}

private struct DreamChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .lineLimit(1)
            .truncationMode(.tail)
            .font(.caption)
            .foregroundStyle(Color(hex: "#9963FF"))
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .fill(Color(hex: "#9963FF").opacity(0.3))
            )
            .padding(.top, 8)
            .padding(.bottom, 24)
    }
}

private struct FirstAnalyzeIntro: View {
    let onStart: () -> Void
    var body: some View {
        VStack {
            TopBarView(tokenCount: 10)
            
            Spacer()
            Spacer()
            
            Text("최근 꿈 꿈을 바탕으로\n나의 무의식 상태를 알 수 있어요.")
                .foregroundStyle(Color(hex: "#E8D9FF"))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Image("jellyCha")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            Text("무의식 분석을 위해서는\n최소 7개의 꿈 해몽이 필요해요.")
                .foregroundStyle(.gray)
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Spacer()
            Spacer()
            
            Button("분석 시작하기") {
                onStart()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "5F21CC").opacity(0.3).blur(radius: 40))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "4312A0"), lineWidth: 1.5))
            .foregroundStyle(Color(hex: "B184FF"))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
            
            
        }
        .background{
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
        }
    }
}
