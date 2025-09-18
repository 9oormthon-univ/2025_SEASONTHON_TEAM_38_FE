//
//  SimHaeWidget.swift
//  SimHaeWidget
//
//  Created by 홍준범 on 9/18/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct SimHaeWidgetEntryView : View {
    var entry: Provider.Entry

    private let quotes: [String] = [
        "사람들은 의식하든 의식하지 \n못하든, 매일 꿈을 꿔요.\n안 꾸는 사람은 없답니다.",
        "상어는 잠재의식에 있는 탐욕을\n상징해요. 상어가 나오는 꿈을\n꾸신 적이 있나요?",
        "꿈을 기록하기 시작하면 꿈을 \n더 많이 꿀 수 있어요.\n무의식의 길을 열어 보세요.",
        "꿈에 나오는 인물, 특히 멘토나 \n조력자는 기록해 두세요.\n 큰 도움이 됩니다.",
        "꿈에 나온 무언가를 검색하기 전에,\n당신에게 어떤 의미인지 \n알아보세요."
    ]
    
    private var todayQuote: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let dateString = formatter.string(from: Date())
            let seed = Int(dateString) ?? 0
            let index = seed % quotes.count
            return quotes[index]
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 36)
            HStack {
                Text(todayQuote)
                    .foregroundStyle(.white)
                
                Image(systemName: "mic")
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.white)
                    .font(.system(size: 32))
                    .frame(width: 68, height: 68)
                    .background(
                        Circle()
                            .fill(Color(hex: "#843CFF").opacity(0.7))
                            .overlay(
                                Circle()
                                    .fill(Color(hex: "#843CFF").opacity(0.7)))
                    )
                    .offset(x: 8, y: -12)
            }
            Spacer()
        }
        .widgetURL(URL(string: "simhae://add"))
    }
}

struct SimHaeWidget: Widget {
    let kind: String = "SimHaeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SimHaeWidgetEntryView(entry: entry)
                    .contentMargins(.zero)
                    .containerBackground(for: .widget) {
                        Image("widget-m")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    }
            } else {
                SimHaeWidgetEntryView(entry: entry)
                    .padding(0)
                    .background()
            }
        }
        .configurationDisplayName("SimHae Widget")
    }
}
struct SmallSimHaeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                
                Text("어떤 꿈을 꾸셨나요??")
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .bold))
                
                Image("mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, -54)
            }
            .widgetURL(URL(string: "simhae://add"))
    }
}

struct SmallSimHaeWidget: Widget {
    let kind: String = "SmallSimHaeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SmallSimHaeWidgetView(entry: entry)
                .contentMargins(.zero)
                .containerBackground(for: .widget) {
                    Image("widget-s")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
        }
        .configurationDisplayName("Small SimHae Widget")
        .supportedFamilies([.systemSmall])   // 작은 사이즈만 지원
    }
}


#Preview(as: .systemSmall) {
    SimHaeWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}

extension Color {
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)

            let r = Double((int >> 16) & 0xFF) / 255.0
            let g = Double((int >> 8) & 0xFF) / 255.0
            let b = Double(int & 0xFF) / 255.0

            self.init(red: r, green: g, blue: b)
        }
}
