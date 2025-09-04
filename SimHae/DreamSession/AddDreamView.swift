//
//  AddDreamView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

import SwiftUI
import Combine

struct AddDreamView: View {
    @ObservedObject var vm: DreamSessionViewModel
    @State private var goToLoading: Bool = false
    @State private var showInfo: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelDialog = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("AddDreamBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geo in
                let w = geo.size.width
                let d = w * 1.8                 // 원 지름(화면 폭 대비 크기)
                let exposure: CGFloat = 0.7   // ⬅️ 화면 아래에서 얼마나 올려서 보이게 할지 비율(0~1 추천)
                
                Circle()
                    .fill(Color(hex: "#13052A").opacity(0.8))
                    .frame(width: d, height: d)
                // 화면 하단에 원의 바닥을 맞춘 뒤, 'exposure * d' 만큼 위로 끌어올린다
                    .position(x: w / 2, y: geo.size.height + d * (0.5 - exposure))
                    .ignoresSafeArea()
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#7534E4").opacity(0.8), lineWidth: 40)
                            .blur(radius: 200)
                        
                    )
                    .shadow(color: Color(hex:" 843CFF").opacity(0.5),
                            radius: 78.9, x:0, y: 0)
                    .background(
                        Circle()
                            .fill(Color.clear)
                            .blur(radius: 50)
                    )
            }
            .allowsHitTesting(false)
            
            VStack {
                
                ZStack {
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color(hex: "#843CFF"))
                        
                        let style = Date.FormatStyle.dateTime
                            .year().month().day().weekday(.wide)
                            .locale(Locale(identifier: "ko_KR"))
                        
                        Text("\(vm.input.date.formatted(style))의 꿈")
                            .foregroundStyle(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.top, 30)
                    
                    if showInfo {
                        CalloutBubble(message: "꿈과 관련해 떠오르는 현실의 기억이나 상황이 있나요?\n함께 입력하면 더 정확한 해몽을 제공할 수 있어요.").offset(y: 15)
                            .transition(.opacity)
                    }
                }
                
                Spacer().frame(height: 120)
                
                TextField("텍스트로 입력하기...", text: $vm.input.content, axis: .vertical)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .padding(.horizontal)
                    .padding(.leading, 10)
                    .padding(.bottom, 110)
                
                Spacer()
            }
            .overlay(alignment: .bottom) {
                ZStack {
                    HStack {
                        Spacer()
                        Button { vm.speech.toggleRecording() } label: {
                            Image(systemName: vm.speech.isRecording ? "stop.fill" : "mic")
                                .foregroundStyle(.white)
                                .font(.system(size: 32))
                                .frame(width: 72, height: 72)
                                .background(
                                    Circle()
                                        .fill(Color.black)
                                        .overlay(
                                            Circle()
                                                .fill(Color(hex: "#843CFF").opacity(0.7)))
                                )
                                .overlay(
                                    Circle()
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
                                            lineWidth: 1
                                        )
                                )
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            vm.analyzeDream()
                            goToLoading = true
                        } label: {
                            Image(systemName: "arrow.right")
                                .foregroundStyle(vm.canSubmit ? .white : .gray)
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle().fill(
                                        vm.canSubmit ? Color(hex: "#843CFF") : Color(hex: "FFFFFF").opacity(0.1)
                                    )
                                )
                        }
                        .navigationDestination(isPresented: $goToLoading) {
                            DreamLoadingView(vm: vm)
                        }
                        .disabled(!vm.canSubmit)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showCancelDialog = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(hex: "#B184FF"))
                            .padding(.leading, 8)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("꿈 기록하기")
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showInfo.toggle()
                        }
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(hex: "#B184FF"))
                            .padding(.trailing, 8)
                    }
                }
            }
            .alert("꿈 입력을 취소하시겠어요?", isPresented: $showCancelDialog) {
                Button("아니요", role: .cancel) {
                    
                }
                Button("네", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("지금까지 입력한 모든 내용이 삭제돼요.")
            }
        }
    }
}

private struct CalloutBubble: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .fill(Color.white.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .stroke(Color(hex: "#4512A0").opacity(0.8), lineWidth: 1)
            )
            .padding(.horizontal, 24)
    }
}
