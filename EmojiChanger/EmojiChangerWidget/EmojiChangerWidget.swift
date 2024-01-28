//
//  EmojiChangerWidget.swift
//  EmojiChangerWidget
//
//  Created by Md. Nahidul Islam on 28/1/2024.
//

import SwiftUI
import WidgetKit
import AppIntents

struct EmojiTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> EmojiTimelineEntry {
        EmojiTimelineEntry(date: Date(), emojis: [.init(id: "Dog", avatar: "🐶")])
    }
    
    func snapshot(for configuration: SelectEmojiIntent, in context: Context) async -> EmojiTimelineEntry {
        let entry = EmojiTimelineEntry(date: Date(), emojis: configuration.emojis)
        return entry
    }

    func timeline(for configuration: SelectEmojiIntent, in context: Context) async -> Timeline<EmojiTimelineEntry> {
        let timeline = Timeline(
            entries: [EmojiTimelineEntry(date: Date(), emojis: configuration.emojis)],
            policy: .atEnd
        )
        return timeline
    }
}

struct EmojiTimelineEntry: TimelineEntry {
    let date: Date
    let emojis: [EmojiDetail]
}

struct EmojiChangerWidgetView: View {
    var entry: EmojiTimelineProvider.Entry

    var body: some View {
        HStack {
            ForEach(entry.emojis) { emoji in
                Text(emoji.avatar)
                    .font(.system(size: 50))
            }
        }
        .containerBackground(.teal, for: .widget)
    }
}

struct EmojiChangerWidget: Widget {
    let kind: String = "EmojiChangerWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectEmojiIntent.self,
            provider: EmojiTimelineProvider()) { entry in
                EmojiChangerWidgetView(entry: entry)
            }
            .configurationDisplayName("Emoji Details")
            .description("Displays a emoji's details")
            .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    EmojiChangerWidget()
} timeline: {
    EmojiTimelineEntry(date: Date(), emojis: [.init(id: "Dog", avatar: "🐶")])
}

struct SelectEmojiIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Emoji"
    static var description = IntentDescription("Selects the emoji to display.")

    @Parameter(title: "Emojis", size: 4)
    var emojis: [EmojiDetail]

    init(emojis: [EmojiDetail]) {
        self.emojis = emojis
    }

    init() {}
}

struct EmojiDetail: AppEntity {
    let id: String
    let avatar: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Emojis"
    static var defaultQuery = EmojiQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(avatar) \(id)")
    }

    static let allEmojis: [EmojiDetail] = [
        EmojiDetail(id: "Dog", avatar: "🐶"),
        EmojiDetail(id: "Cat", avatar: "🐱"),
        EmojiDetail(id: "Monkey", avatar: "🐒"),
        EmojiDetail(id: "Fish", avatar: "🐟")
    ]
}

struct EmojiQuery: EntityQuery {
    // Identifiers are selected items in the edit widget
    // filter only the selected items
    func entities(for identifiers: [EmojiDetail.ID]) async throws -> [EmojiDetail] {
        EmojiDetail.allEmojis.filter { identifiers.contains($0.id) }
    }
    
    // The list shows this array of contents
    func suggestedEntities() async throws -> [EmojiDetail] {
        EmojiDetail.allEmojis
    }
    
    // This item is suggested as default, selecting nil will show "Choose"
    func defaultResult() async -> EmojiDetail? {
        try? await suggestedEntities().first
    }
}
