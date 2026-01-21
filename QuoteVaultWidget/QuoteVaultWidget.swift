//
//  QuoteVaultWidget.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "Believe you can and you're halfway there.", author: "Theodore Roosevelt")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: "Believe you can and you're halfway there.", author: "Theodore Roosevelt")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, quote: "Believe you can and you're halfway there.", author: "Theodore Roosevelt")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

struct QuoteVaultWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(entry.quote)
                    .font(.system(size: family == .systemSmall ? 14 : 18, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .italic()
                    .lineLimit(family == .systemSmall ? 4 : 5)
                
                Spacer()
                
                HStack {
                    Rectangle()
                        .frame(width: 20, height: 1)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(entry.author)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .padding()
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct QuoteVaultWidget: Widget {
    let kind: String = "QuoteVaultWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteVaultWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quote of the Day")
        .description("Stay inspired with a new quote every day.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    QuoteVaultWidget()
} displayName: {
    "Small Widget"
}

#Preview(as: .systemMedium) {
    QuoteVaultWidget()
} displayName: {
    "Medium Widget"
}

// Color Hex Extension for Widget
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
