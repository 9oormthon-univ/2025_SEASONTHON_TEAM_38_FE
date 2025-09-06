//
//  AnalyzeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct AnalyzeView: View {
    @StateObject private var vm = AnalyzeViewModel()
    var body: some View {
        ZStack {
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if vm.isLoading {
                VStack {
                    Spacer()
                    
                    Image("jellyCha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("나의 무의식 상태를\n분석중이에요.")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .padding()
                        .padding(.bottom, 40)
                    
                    ProgressView()
                    
                    Spacer()
                }
            } else if vm.notEnoughData {
                    VStack {
                        Text("최근 꾼 꿈을 바탕으로\n나의 무의식 상태를 알 수 있어요.")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: "#E8D9FF"))
                            .padding()
                            .padding(.bottom, 40)
                        
                        Image("jellyCha")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Text("무의식 분석을 위해서는\n최소 7개의 꿈 해석이 필요해요.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                            .padding()
                            .padding(.bottom, 40)
                    }
                } else {
                ScrollView {
                    VStack {
                        Text("최근 꾼 7개 꿈을 바탕으로 무의식을 분석했어요.")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "#B184FF"))
                            .padding(.top, 32)
                            .padding(.bottom, 12)
                        
                        DreamRibbonCloud(items: vm.summary?.recentDreams ?? [] )
                        
                        if let title = vm.summary?.title {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.top, 36)
                        }
                        
                        if let analysis = vm.summary?.analysis {
                            Text(analysis)
                                .font(.body)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .multilineTextAlignment(.leading)
                                .padding(28)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(hex: "#7534E4").opacity(0.2))
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                                .padding(.bottom, 24)
                        }
                        
                        Text("해파리의 제안")
                            .padding(.top, 48)
                            .padding(.bottom, 24)
                        
                        Image("jellyCha")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        
                        if let suggestion = vm.summary?.suggestion {
                            Text(suggestion)
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
                        
                        
                        if let err = vm.errorMessage {
                            Text(err)
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .padding(.bottom, 40)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
                .safeAreaPadding(.top)
                .refreshable {
                    vm.load()
                }
            }
            
            
        }
        .onAppear {
            vm.load()
        }
    }
}
#Preview {
    AnalyzeView()
}

struct DreamRibbonCloud: View {
    let items: [String]              // recentDreams (최대 7개 사용 가정)
    var angle: Double = -28          // 모든 칩에 같은 기울기
    var spacing: CGFloat = 62        // 칩 간격
    var widthFactor: CGFloat = 0.3  // 칩 너비(화면 대비)
    
    var body: some View {
        GeometryReader { geo in
            let chipW = min(geo.size.width * widthFactor, 420)
            let chipH: CGFloat = 56
            let count = min(items.count, 7)
            
            // 가운데 정렬을 위한 시작 x 오프셋
            let startX = -spacing * CGFloat(max(count - 1, 0)) / 2
            // 모두 같은 y 라인에 배치 (한 줄)
            let baseY: CGFloat = 0
            
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    DreamChip(text: items[i])
                        .frame(width: chipW, height: chipH)
                        .rotationEffect(.degrees(angle))                 // ← 기울기만
                        .offset(x: startX + CGFloat(i) * spacing, y: baseY) // ← y는 고정
                        .shadow(color: Color.purple.opacity(0.30), radius: 16, x: 0, y: 8)
                        .zIndex(Double(i)) // 겹침 순서가 신경 쓰이면 조절(반대로 하고 싶으면 -Double(i))
                }
            }
            // 세로 가운데 정렬
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .compositingGroup() // 회전/그림자 렌더링 깔끔하게
        }
        .frame(height: 120) // 전체 블록 높이(필요하면 조절)
    }
}

private struct DreamChip: View {
    let text: String
    
    var body: some View {
        // 네온 느낌 칩
        Text(text)
            .lineLimit(1)
            .truncationMode(.tail)
            .font(.caption)
            .foregroundStyle(Color(hex: "#9963FF"))
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .frame(width: 140)
            .background(
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .fill(Color(hex: "#9963FF").opacity(0.3))
            )
            .padding(.top, 8)
            .padding(.bottom, 24)
    }
}
