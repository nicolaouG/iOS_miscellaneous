//
//  Widget.swift
//  TestWidget
//
//  Created by george on 14/01/2021.
//  Copyright © 2021 George Nicolaou. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    /**
     When widget is displayed for the first time.
     */
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(isPlaceholder: true)
    }

    /**
     When widget is previewed in the widget gallery
     */
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(configuration: configuration, points: "100", isPlaceholder: true)
        completion(entry)
    }

    /**
     Add one or more timeline entries. Set the entries' dates to refresh the widget accordingly and establish a reload policy for the widget
     */
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let group = UserDefaults(suiteName: AppGroup.groupId)
        let points = group?.string(forKey: AppGroupKeys.points.rawValue) ?? "111"
        /// Generate a timeline consisting of 2 entries a minute apart, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 2 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, points: points)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    let points: String
    let voucher: UIImage
    let isLoggedOut: Bool
    let isPlaceholder: Bool
    let widgetFamily: WidgetFamily
    
    init(date: Date = Date(),
         configuration: ConfigurationIntent = ConfigurationIntent(),
         points: String = "",
         voucher: UIImage = UIImage(named: "placeholder_full") ?? UIImage(systemName: "lasso.sparkles") ?? UIImage(),
         isLoggedOut: Bool = false,
         isPlaceholder: Bool = false,
         widgetFamily: WidgetFamily = .systemSmall) {
        self.date = date
        self.configuration = configuration
        self.points = points
        self.voucher = voucher
        self.isLoggedOut = isLoggedOut
        self.isPlaceholder = isPlaceholder
        self.widgetFamily = widgetFamily
    }
}


struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        switch entry.configuration.widgetContent {
        case .vouchers:
            Image(uiImage: entry.voucher)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .widgetURL(URL(string: WidgetLink.vouchers.rawValue))
            
        default: // .points
            VStack {
                Text(entry.date, style: .time)
                Text(entry.points)
            }
            .widgetURL(URL(string: WidgetLink.points.rawValue))
        }
    }
}


@main
struct MyAppWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
}

struct MyAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(points: "200"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetEntryView(entry: SimpleEntry(points: "300"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetEntryView(entry: SimpleEntry(points: "400"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
