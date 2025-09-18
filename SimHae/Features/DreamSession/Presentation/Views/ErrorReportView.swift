//
//  ErrorReportView.swift
//  SimHae
//
//  Created by 홍준범 on 9/18/25.
//

import SwiftUI

struct ErrorReportView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    var body: some View {
        Form {
            Section {
                Text("제목")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                TextField("제목을 입력해 주세요.", text: $title)
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(hex: "#FFFFFF").opacity(0.1))
                    )
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                Text("내용")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("오류 내용을 자세히 입력해 주세요.")
                                        .foregroundStyle(.white.opacity(0.3))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 14)
                    }
                    TextEditor(text: $content )
                        .foregroundStyle(.white)
                        .padding(8)
                        .frame(minHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#FFFFFF").opacity(0.1))
                        )
                }

            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                Text("오류 이미지")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("파일 첨부")
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(hex: "#FFFFFF").opacity(0.1))
                    )

            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                Button {
                    
                } label: {
                    Text("신고 제출하기")
                        .foregroundStyle(Color(hex: "#626262"))
                        .padding()
                        .frame(minWidth: 340)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color(hex: "#FFFFFF").opacity(0.1))
                        )
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    ErrorReportView()
}
